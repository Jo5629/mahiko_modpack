mahiko_crafting = {
    registered_crafts = {},
}

local MP = core.get_modpath(core.get_current_modname())

dofile(MP .. "/api.lua")
dofile(MP .. "/essence.lua")
dofile(MP .. "/table.lua")
dofile(MP .. "/blank_spell.lua")
dofile(MP .. "/craftguide.lua")

if core.get_modpath("default") then
    dofile(MP .. "/crafts/default.lua")
end