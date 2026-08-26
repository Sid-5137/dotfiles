-- ─────────────────────────────────────────────────────────────
-- Hyprland Config (Lua) – ported from hyprlang
-- Nord / Colloid Dark theme · Noctalia v5 shell
-- Target: Hyprland 0.55+ (tested against 0.56.0 API)
-- ─────────────────────────────────────────────────────────────
-- Wiki: https://wiki.hypr.land/Configuring/Start/
-- Split files live next to this one and are pulled in via require().
--
-- CHANGES IN THIS REVISION (search "CHANGED:" to find each one):
--   1. Autostart: seed the systemd/D-Bus activation environment before
--      anything else, and start gnome-keyring's secrets component.
--   2. Autostart: removed the "-- ... rest of your existing autostart"
--      placeholder. Re-add your own exec lines where marked.
--   3. Screenshots: flameshot (X11) -> hyprshot (native Wayland).
--   4. QS_ICON_THEME: flagged, value must match a real icon directory.
--   5. QT_QPA_PLATFORM: allow xcb fallback so Qt apps without the
--      Wayland plugin still start.
-- ─────────────────────────────────────────────────────────────

require("monitors")
require("workspaces")

---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "firefox"
local menu = table.concat({
    "rofi -show drun -show-icons",
    "-theme ~/.config/rofi/noctalia-pill-square.rasi",
}, " ")

-- Noctalia v5 IPC prefix. v4's `qs -c noctalia-shell ipc call ...` is gone.
local ipc = "noctalia msg "

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    -- CHANGED: must run FIRST. hl.env() below only reaches processes that
    -- Hyprland itself spawns. systemd user units and D-Bus-activated
    -- services (the portal, hyprpolkitagent, gnome-keyring) start outside
    -- that tree and would otherwise never see XDG_CURRENT_DESKTOP, which
    -- is what the portal uses to pick its backend. With greetd there is no
    -- session manager doing this for you.
    hl.exec_cmd(table.concat({
        "dbus-update-activation-environment --systemd",
        "XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP",
        "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR",
    }, " "))
    hl.exec_cmd("systemctl --user start hyprland-session.target")

    -- CHANGED: Secret Service provider. Without this, anything using
    -- libsecret (Chrome, VS Code/Cursor, Nextcloud) silently falls back to
    -- storing credentials in plaintext on disk. Plasma used to start a
    -- keyring via its own autostart; that went with the KDE removal.
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh")

    hl.exec_cmd("noctalia")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- CHANGED: the placeholder comment that used to sit here was a stub
    -- left over from the hyprlang port, not working config. Anything your
    -- old hyprland.conf started with exec-once is currently NOT running.
    -- Recover it with:
    --   grep exec-once ~/dotfiles/hypr/hyprland.conf*
    -- and add the lines below. Common ones for this kind of setup:
    -- hl.exec_cmd("wl-paste --watch cliphist store")
    -- hl.exec_cmd("hypridle")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "hypr_Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
-- hl.env("QS_ICON_THEME", "MacTahoe-nord-dark")

-- CHANGED (verify): "YAML" is a data-serialisation format, not an icon
-- theme -- this looks like a typo. The value must match a directory name
-- under ~/.icons or /usr/share/icons. Check with:
--   ls ~/.icons /usr/share/icons
-- and correct the string below if it isn't there.
hl.env("QS_ICON_THEME", "YAML")

-- Styles Qt6 apps only. Qt5 apps read qt5ct and will render unstyled --
-- harmless if you have no Qt5 apps left after the KDE removal.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- CHANGED: was "wayland". The fallback lets Qt apps that ship without the
-- Wayland platform plugin start under XWayland instead of exiting.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
----- PERMISSIONS -----
-----------------------
-- 0.56 gained a permission system. It is OFF by default; uncomment the
-- enforce_permissions block only if you also keep the grants below.
-- Permission changes need a full Hyprland restart, not a reload.

-- hl.config({ ecosystem = { enforce_permissions = true } })
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

local nord = {
    active_border   = "rgba(88C0D0ff)",
    inactive_border = "rgba(434C5Eff)",
}

hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 4,
        border_size = 1,
        col = {
            active_border   = nord.active_border,
            inactive_border = nord.inactive_border,
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 0,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = false,
            range        = 10,
            render_power = 3,
            color        = "rgba(00000055)",
        },

        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            noise              = 0.02,
            brightness         = 0.9,
            popups             = true,
            popups_ignorealpha = 0.2,
            contrast           = 0.9,
            vibrancy           = 0.16,
            new_optimizations  = false,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        focus_on_activate       = true,
        mouse_move_enables_dpms = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
        mfact      = 0.55,
        new_on_top = true,
    },

    cursor = {
        no_warps = false,
    },
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("spring",   { type = "bezier", points = { {0.46, 1.0},  {0.29, 1} } })
hl.curve("closeOut", { type = "bezier", points = { {0.08, 0.92}, {0, 1}    } })
hl.curve("linear",   { type = "bezier", points = { {0, 0},       {1, 1}    } })

hl.animation({ leaf = "windows",     enabled = true, speed = 4, bezier = "spring",   style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 8, bezier = "closeOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "spring" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "linear" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 3, bezier = "linear" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 3, bezier = "linear" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4, bezier = "spring",   style = "fade" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 4, bezier = "spring",   style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 3, bezier = "closeOut", style = "fade" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "spring",   style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 5, bezier = "linear" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout          = "us",
        kb_rules           = "evdev",
        follow_mouse       = 1,
        sensitivity        = 0.8,
        repeat_rate        = 25,
        repeat_delay       = 600,
        numlock_by_default = true,
        force_no_accel     = false,
        -- accel_profile      = "adaptive",
        touchpad = {
            natural_scroll       = true,
            tap_to_click         = true,   -- was tap-to-click; hyphens are invalid in Lua keys
            drag_lock            = true,
            disable_while_typing = true,
        },
    },
})

------------------
---- GESTURES ----
------------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4-finger vertical swipes adjust volume. `action` now takes a Lua function
-- instead of the old `dispatcher, exec, ...` tail.
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function() hl.dispatch(hl.dsp.exec_cmd(ipc .. "volume-up")) end,
})
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function() hl.dispatch(hl.dsp.exec_cmd(ipc .. "volume-down")) end,
})

--------------------
---- LAYER RULES ---
--------------------

-- Namespace regex and no_anim come from Noctalia's own Hyprland page.
-- Noctalia animates its own surfaces, so Hyprland's layer anims fight it.
hl.layer_rule({
    name  = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim      = true,
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name         = "rofi-blur",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0.5,
})

---------------------
---- WINDOW RULES ---
---------------------

hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name    = "thunar-opacity",
    match   = { class = "(?i)thunar" },
    opacity = "0.9 override 0.9 override",
})

hl.window_rule({
    name    = "vesktop-opacity",
    match   = { class = "vesktop" },
    opacity = "0.9 override 0.9 override",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name   = "calculator",
    match  = { class = "org.gnome.Calculator", title = "Calculator" },
    float  = true,
    size   = { 400, 580 },
    center = true,
})

hl.window_rule({
    name   = "noctalia-settings",
    match  = { class = "dev.noctalia.Noctalia" },
    float  = true,
    size   = { 1080, 920 },
    center = true,
})

hl.window_rule({
    name   = "brave-noblur",
    match  = { class = "brave-browser" },
    opaque = true,
})

hl.window_rule({
    name   = "firefox-noblur",
    match  = { class = "firefox" },
    opaque = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Reload config
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload config" })

-- Apps
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu),        { description = "Rofi launcher" })
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(terminal),    { description = "Terminal" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser),     { description = "Browser" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File manager" })

-- Noctalia IPC
hl.bind("ALT + Space",             hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + S",         hl.dsp.exec_cmd(ipc .. "settings-toggle appearance"))
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(ipc .. "panel-toggle noctalia/notes:scratchpad"))
hl.bind("ALT + Tab",               hl.dsp.exec_cmd(ipc .. "window-switcher"))

-- Window control
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + Space",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus (ALT + arrows)
hl.bind("ALT + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + right", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + down",  hl.dsp.focus({ direction = "down" }))

-- Cycle windows
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- Swap windows
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Move floating windows
hl.bind("CTRL + SHIFT + up",    hl.dsp.window.move({ x = 0,   y = -50, relative = true }))
hl.bind("CTRL + SHIFT + down",  hl.dsp.window.move({ x = 0,   y = 50,  relative = true }))
hl.bind("CTRL + SHIFT + left",  hl.dsp.window.move({ x = -50, y = 0,   relative = true }))
hl.bind("CTRL + SHIFT + right", hl.dsp.window.move({ x = 50,  y = 0,   relative = true }))

-- Resize windows
hl.bind("CTRL + ALT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind("CTRL + ALT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))
hl.bind("CTRL + ALT + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
hl.bind("CTRL + ALT + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))

-- Gaps. Done natively in Lua now instead of shelling out to hyprctl + jq.
local gapsIn = 3
local function setGaps(delta)
    gapsIn = math.max(0, gapsIn + delta)
    hl.config({ general = { gaps_in = gapsIn } })
end
hl.bind("ALT + SHIFT + X", function() setGaps(1) end)
hl.bind("ALT + SHIFT + Z", function() setGaps(-1) end)

-- Scratchpad (special workspace)
hl.bind(mainMod .. " + minus",         hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Workspace navigation
hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + left",         hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("CTRL + right",        hl.dsp.window.move({ workspace = "e+1" }))

-- Move window to adjacent workspace silently (follow = false)
hl.bind("CTRL + " .. mainMod .. " + left",  hl.dsp.window.move({ workspace = "e-1", follow = false }))
hl.bind("CTRL + " .. mainMod .. " + right", hl.dsp.window.move({ workspace = "e+1", follow = false }))

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Monitor focus
hl.bind("ALT + SHIFT + left",  hl.dsp.focus({ monitor = "l" }))
hl.bind("ALT + SHIFT + right", hl.dsp.focus({ monitor = "r" }))

-- Move window to monitor
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.move({ monitor = "l" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ monitor = "r" }))

-- Mouse binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------
---- MEDIA KEYS ----
--------------------
-- Routed through Noctalia so you get its OSD. For raw wpctl/brightnessctl
-- instead, swap the exec_cmd bodies -- the bind flags stay the same.

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(ipc .. "volume-up"),        { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(ipc .. "volume-down"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(ipc .. "volume-mute"),      { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. "brightness-up"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"),  { locked = true, repeating = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------
---- SCREENSHOTS ---
--------------------
-- CHANGED: was flameshot, which is X11-native. Under Hyprland it runs
-- through XWayland and commonly captures black or grabs the wrong region
-- on multi-monitor. hyprshot wraps grim + slurp and is Wayland-native.
--   sudo dnf install hyprshot
-- (or install grim + slurp and use the raw commands in the comments below)

hl.bind("Print",         hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures"))
hl.bind("CTRL + Print",  hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))

-- Raw grim/slurp equivalents if you'd rather not add hyprshot:
-- hl.bind("Print",         hl.dsp.exec_cmd([[sh -c 'grim -g "$(slurp)" - | wl-copy']]))
-- hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[sh -c 'grim ~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png']]))
-- hl.bind("CTRL + Print",  hl.dsp.exec_cmd([[sh -c 'grim - | wl-copy']]))

----------------------
---- SOURCE THEME ----
----------------------
-- The old `source = /home/sid/.config/hypr/noctalia/noctalia-colors.conf`
-- pointed at another user's home and cannot be require()d anyway: Lua configs
-- only require .lua files. Point Noctalia's template output at a .lua file
-- that calls hl.config({ general = { col = { ... } } }), then uncomment:
--
-- require("noctalia.noctalia-colors")

-- For Noctalia Color templates
require("noctalia").apply_theme()
