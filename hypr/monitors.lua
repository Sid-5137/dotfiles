-- ─────────────────────────────────────────────────────────────
-- Monitors
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- ─────────────────────────────────────────────────────────────
-- Heads up: nwg-displays writes hyprlang (monitors.conf), not Lua. If you run
-- it again it will regenerate the old .conf, which this Lua config ignores.
-- Either port its output back into this file by hand, or keep a
-- monitors.conf and stay on the hyprlang root.

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@120",
    position = "0x0",
    scale     = 1,
})

-- Catch-all for anything hotplugged (dock, projector, external panel).
-- Remove it if you'd rather unknown outputs stay dark.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
