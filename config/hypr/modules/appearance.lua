-- General look and feel.
-- See https://wiki.hypr.land/configuring/core/config-options/

-- Quickshell saves its window radius here whenever the corner setting changes.
-- Read it again on reload so the shell remains the source of the window shape.
local window_rounding = 23
local shape_path = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config"))
	.. "/hypr/config/shape.conf"
local shape_file = io.open(shape_path, "r")
if shape_file then
	local saved_rounding = shape_file:read("*a"):match("%$winRounding%s*=%s*(%d+)")
	shape_file:close()
	window_rounding = tonumber(saved_rounding) or window_rounding
end

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 6,

		border_size = 0,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = window_rounding,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 18,
			render_power = 3,
			color = 0x55000000,
		},

		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			noise = 0.0,
			contrast = 1.0,
			brightness = 1.0,
			vibrancy = 0.0,
		},
	},

	misc = {
		force_default_wallpaper = -1, -- 0 or 1 disables the anime mascot wallpapers
		disable_hyprland_logo = false,
	},

	layers = {
		allow_new_top_layers_over_existing_fullscreen = false,
	},
})
