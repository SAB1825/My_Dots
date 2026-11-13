-- Window rules.
-- See https://wiki.hypr.land/configuring/core/rules/

-- Ignore maximize requests from all applications.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix dragging issues with XWayland windows.
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

-- Open Dolphin in a compact, centered floating window.
hl.window_rule({
    name  = "dolphin-floating",
    match = { class = "^(org\\.kde\\.dolphin|dolphin)$" },

    float  = true,
    size   = "900 600",
    center = true,
})

-- Hyprland-run.
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
