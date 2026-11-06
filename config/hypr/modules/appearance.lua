-- General look and feel.
-- See https://wiki.hypr.land/configuring/core/config-options/

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 4,

        border_size = 0,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 5,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled    = true,
            size       = 8,
            passes     = 3,
            noise      = 0.0,
            contrast   = 1.0,
            brightness = 1.0,
            vibrancy   = 0.0,
        },
    },

    misc = {
        force_default_wallpaper = -1,    -- 0 or 1 disables the anime mascot wallpapers
        disable_hyprland_logo   = false,
    },

    layers = {
        allow_new_top_layers_over_existing_fullscreen = false,
    },
})
