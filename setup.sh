#!/usr/bin/env bash
set -Eeuo pipefail

########################################
# Paths
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MANGOWC_REPO="${MANGOWC_REPO:-https://github.com/mangowc/mango}"

SUDO="$(command -v sudo >/dev/null 2>&1 && echo sudo || echo '')"

########################################
# Logging
########################################
log()  { printf '[INFO] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
err()  { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

########################################
# Utils
########################################
cmd() { command -v "$1" >/dev/null 2>&1; }

detect_pkg_manager() {
    cmd apt-get && { echo apt; return; }
    cmd dnf     && { echo dnf; return; }
    cmd pacman  && { echo pacman; return; }
    cmd zypper  && { echo zypper; return; }
    err "No supported package manager found"
}

########################################
# Package install
########################################
install_pkgs() {
    local pm="$1"; shift
    case "$pm" in
        apt)
            $SUDO apt-get update
            $SUDO apt-get install -y "$@"
            ;;
        dnf)
            $SUDO dnf install -y "$@"
            ;;
        pacman)
            $SUDO pacman -Sy --needed --noconfirm "$@"
            ;;
        zypper)
            $SUDO zypper --non-interactive install "$@"
            ;;
    esac
}

########################################
# Dependencies
########################################
install_dependencies() {
    local pm="$1"
    log "Installing MangoWC dependencies ($pm)"

    case "$pm" in
        apt)
            install_pkgs "$pm" \
                build-essential git meson ninja-build pkg-config cmake \
                wayland-protocols libwayland-dev libxkbcommon-dev \
                libinput-dev libdrm-dev libpixman-1-dev \
                libxcb1-dev libxcb-util-dev libxcb-ewmh-dev \
                libxcb-icccm4-dev libxcb-errors-dev \
                libseat-dev libcairo2-dev libpango1.0-dev \
                libpam0g-dev xwayland mate-polkit
            ;;
        dnf)
            install_pkgs "$pm" \
                @development-tools git meson ninja pkgconf cmake \
                wayland-devel wayland-protocols-devel libxkbcommon-devel \
                libinput-devel libdrm-devel pixman-devel \
                libxcb-devel xcb-util-devel xcb-util-wm-devel \
                xcb-util-errors-devel seatd-devel \
                cairo-devel pango-devel pam-devel \
                xorg-x11-server-Xwayland mate-polkit
            ;;
        pacman)
            install_pkgs "$pm" \
                base-devel git meson ninja pkgconf cmake \
                wayland wayland-protocols wlroots \
                libxkbcommon libinput libdrm pixman \
                libxcb xcb-util xcb-util-wm xcb-util-errors \
                libseat cairo pango pam \
                xorg-xwayland mate-polkit
            ;;
        zypper)
            install_pkgs "$pm" -t pattern devel_basis
            install_pkgs "$pm" \
                git meson ninja pkg-config cmake \
                wayland-devel wayland-protocols-devel wlroots-devel \
                libxkbcommon-devel libinput-devel libdrm-devel \
                pixman-devel libxcb-devel xcb-util-devel \
                xcb-util-wm-devel seatd-devel \
                cairo-devel pango-devel pam-devel \
                xwayland mate-polkit
            ;;
    esac
}

########################################
# MangoWC install
########################################
install_mangowc() {
    if cmd mangowc || cmd mango; then
        log "MangoWC already installed"
        return
    fi

    log "Building MangoWC from source"
    tmp="$(mktemp -d)"
    git clone --depth=1 "$MANGOWC_REPO" "$tmp/mango"
    (
        cd "$tmp/mango"
        meson setup build
        ninja -C build
        $SUDO ninja -C build install
    )
    rm -rf "$tmp"
}

########################################
# Safe symlink helper
########################################
link_path() {
    local src="$1"
    local dest="$2"

    [[ -e "$src" ]] || { warn "Source not found: $src"; return; }

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        warn "Backing up existing $dest"
        mv "$dest" "$dest.bak.$(date +%s)"
    fi

    ln -sf "$src" "$dest"
    log "Linked $dest → $src"
}

########################################
# Dotfiles linking
########################################
link_configs() {
    log "Linking dotfiles"

    link_path "$SCRIPT_DIR/mango"        "$HOME/.config/mango"
    link_path "$SCRIPT_DIR/kitty"        "$HOME/.config/kitty"
    link_path "$SCRIPT_DIR/rofi"         "$HOME/.config/rofi"
    link_path "$SCRIPT_DIR/starship.toml" \
              "$HOME/.local/share/mybash/starship.toml"
}

########################################
# Main
########################################
main() {
    pm="$(detect_pkg_manager)"
    log "Detected package manager: $pm"

    install_dependencies "$pm"
    install_mangowc
    link_configs

    log "Done. MangoWC and dotfiles are ready."
}

main "$@"
