 -- Keybindings.
--
-- Window-management actions are on ALT so the SUPER+key set stays free.

local vars    = require("modules.variables")
local mainMod = vars.mainMod

-- Applications --------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("/home/sabari/.local/bin/hyprdo dispatch global quickshell:bluetooth"))

-- Window management ---------------------------------------------------------

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + P",         hl.dsp.window.pseudo())
hl.bind("ALT + F",         hl.dsp.exec_cmd(vars.fileManager))
hl.bind("ALT + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Focus ---------------------------------------------------------------------

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces ----------------------------------------------------------------

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Cycle through existing workspaces with the mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media and hardware keys ---------------------------------------------------

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Quickshell wallpaper picker.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("/home/sabari/.local/bin/hyprdo dispatch global quickshell:wallpapers"))

-- Quickshell theme picker.
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("/home/sabari/.local/bin/hyprdo dispatch global quickshell:launcherCalc"))

require("modules.shell")
