mahiko_spells = {
    cooldowns = mahiko_cooldowns.init(),
    COLORS = {
        FIRE = "#FC6108",
        WATER = "#0173FF",
        EARTH = "#C24802",
        WIND = "#BFBFBF",
        HEALING = "#15E8CF",
        OTHER = "#D100D1",
        --ELECTRIC = "#E3C609",
    },
    ELEMENTS = {"fire", "water", "earth", "wind", "healing", "other"},
    registered_spells = {},
}

function math.clamp(n, min, max)
    if n < min then
        n = min
    end
    if n > max then
        n = max
    end
    return n
end

local MP = core.get_modpath(core.get_current_modname())

dofile(MP .. "/update_wear.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/nodes.lua")
dofile(MP .. "/entities.lua")

for _, spell in ipairs(mahiko_spells.ELEMENTS) do
    mahiko_spells.registerCategory(spell)
    dofile(MP .. "/spells/" .. spell .. ".lua")
end

dofile(MP .. "/player.lua")
dofile(MP .. "/commands.lua")