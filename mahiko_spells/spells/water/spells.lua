local COLORS = mahiko_spells.COLORS
local ELEMENT_INT = 2
local DEFAULT_SPELL_ICON = "mahiko_spells_element_water.png"
local BARRACUDA_FLUIDITY_MULT = math.huge
local BARRACUDA_FLUIDITY_OLD = 1
local BARRACUDA_SINK_MULT = 0.5
local BARRACUDA_SINK_OLD = 1
local BARRACUDA_VEL_INTERVAL = 0.5
local BARRACUDA_VEL_MULT = 20
local WHIRLPOOL_VEL_INTERVAL = 1
local WHIRLPOOL_VEL_YMIN = -18
local WHIRLPOOL_VEL_YMAX = -25
local BREATHABILITY_INTERVAL = 1
local BREATHABILITY_OFFSET_Y = 0.75

local function inWater(pos)
    pos = {
        x = math.ceil(pos.x),
        y = math.ceil(pos.y),
        z = math.ceil(pos.z),
    }
    local name = core.get_node(pos).name
    return name:match("water")
end

local function endBarracuda(id, params)
    local player = core.get_player_by_name(params.pname)
    if player then
        player:set_physics_override({
            liquid_fluidity = BARRACUDA_FLUIDITY_OLD,
            liquid_sink = BARRACUDA_SINK_OLD,
        })
    end
end

mahiko_spells.registerFancySpell("barracuda", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.WATER, "Barracuda"),
        "Left-click: if on/under water, bolt towards where",
        "you are facing 0.5 seconds for 3 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 3,
    _cooldown = 8,
    on_use = function(itemstack, user, pointed_thing)
        if not inWater(user:get_pos()) then
            return
        end
        user:set_physics_override({
            liquid_fluidity = BARRACUDA_FLUIDITY_MULT,
            liquid_sink = BARRACUDA_SINK_MULT,
        })
        return true, {
            interval = 0,
        }
    end,
    _on_step = function(id, dtime, params)
        if params.mode ~= "down" then
            return
        end

        local player = core.get_player_by_name(params.pname)
        if not player then
            return
        end

        params.interval = params.interval - dtime
        if params.interval > 0 then
            return params
        end
        params.interval = BARRACUDA_VEL_INTERVAL

        if not inWater(player:get_pos()) then
            return params
        end

        local dir = player:get_look_dir()
        local velocity = vector.multiply(dir, BARRACUDA_VEL_MULT)
        player:add_velocity(velocity)
        return params
    end,
    _on_finish = endBarracuda,
    _on_cancel = endBarracuda,
})

mahiko_spells.registerFancySpell("whirlpool", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.WATER, "Whirlpool"),
        "Left-click on a object: sink the object downwards",
        "for 5 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 5,
    _cooldown = 10,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "object" then
            return
        end

        local ref = pointed_thing.ref
        return true, {
            interval = 0,
            GUID = ref:get_guid(),
        }
    end,
    _on_step = function(id, dtime, params)
        if params.mode ~= "down" then
            return
        end

        local player = core.get_player_by_name(params.pname)
        if not player then
            return
        end

        local object = core.objects_by_guid[params.GUID]
        if not object then
            return
        end

        params.interval = params.interval - dtime
        if params.interval > 0 then
            return params
        end
        params.interval = WHIRLPOOL_VEL_INTERVAL

        if inWater(object:get_pos()) then
            local y = math.random(WHIRLPOOL_VEL_YMIN, WHIRLPOOL_VEL_YMAX)
            object:add_velocity({x = 0, y = y, z = 0})
        end
        return params
    end,
})

mahiko_spells.registerFancySpell("breathability", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.WATER, "Breathability"),
        "Left-click: full breath underwater for 10 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 10,
    _cooldown = 8,
    on_use = function(itemstack, user, pointed_thing)
        return true, {interval = 0}
    end,
    _on_step = function(id, dtime, params)
        if params.mode ~= "down" then
            return
        end

        local player = core.get_player_by_name(params.pname)
        if not player then
            return
        end

        params.interval = params.interval - dtime
        if params.interval > 0 then
            return params
        end
        params.interval = BREATHABILITY_INTERVAL

        local pos = player:get_pos()
        pos.y = pos.y + BREATHABILITY_OFFSET_Y
        if not inWater(pos) then
            return params
        end

        local max = player:get_properties().breath_max
        player:set_breath(max)
        return params
    end,
})

mahiko_spells.registerSimpleSpell("condenser", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.WATER, "Condenser"),
        "Left-click on a node: place a block of water.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 8,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local pos = pointed_thing.above
        if core.get_node(pos).name == "air" then
            core.set_node(pos, {name = "default:water_source"})
        end
        return true
    end,
})