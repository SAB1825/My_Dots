-- Shell shortcuts only. Existing window and workspace bindings remain in binds.lua.
local function shell(key, action)
    hl.bind(key, hl.dsp.global("quickshell:" .. action))
end
shell("SUPER + D", "launcher")
shell("SUPER + N", "wifi")
shell("SUPER + V", "clipboard")
shell("SUPER + A", "media")
shell("SUPER + P", "powerMenu")
shell("SUPER + T", "timer")
shell("SUPER + SHIFT + D", "calendar")
shell("SUPER + SHIFT + M", "audioPanel")
shell("SUPER + SHIFT + N", "notifCenter")
shell("SUPER + E", "files")
shell("SUPER + CTRL + P", "procs")
shell("SUPER + CTRL + E", "eq")

local mod = require("modules.variables").mainMod
shell(mod .. " + SHIFT + B", "barToggle")
