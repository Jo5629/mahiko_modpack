local COLORS = mahiko_spells.COLORS
local COLORIZE = core.colorize
local ELEMENT_INT = mahiko_spells.intFromCategory("wind")
local DEFAULT_SPELL_ICON = "mahiko_spells_element_wind.png"
local GRAVITY_WEIGHTLESSNESS = 0.2
local PROPULSION_MULT = 15
local PROPULSION_VELOCITY_Y = 5
local WHIRLWIND_MULT = 15
local WHIRLWIND_VELOCITY_Y = 4

local function setGravity(name, num)
    local player = core.get_player_by_name(name)
    if not player then
        return
    end
    player:set_physics_override({
        gravity = num,
    })
end

mahiko_spells.registerFancySpell("weightlessness", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.WIND, "Weightlessness"),
        "Left-click: zero gravity for 12 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 12,
    _cooldown = 20,
    on_use = function(itemstack, user, pointed_thing)
        user:set_velocity({x = 0, y = 0, z = 0})
        user:set_physics_override({
            gravity = GRAVITY_WEIGHTLESSNESS,
        })
        return true
    end,
    _on_finish = function(id, params)
        if params.mode == "down" then
            setGravity(params.pname, 1)
        end
    end,
    _on_cancel = function(id, params)
        setGravity(params.pname, 1)
    end,
})

mahiko_spells.registerSimpleSpell("propulsion", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.WIND, "Propulsion"),
        "Left-click: Dash",
        "Right-click: High Jump",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 5,
    on_use = function(itemstack, user, pointed_thing)
        local dir = user:get_look_dir()
        local velocity = vector.multiply(dir, PROPULSION_MULT)
        velocity.y = PROPULSION_VELOCITY_Y
        user:add_velocity(velocity)
        return true
    end,
    _on_rightclick = function(stack, user, pointed_thing)
        user:add_velocity({x = 0, y = PROPULSION_MULT, z = 0})
        return true
    end
})

mahiko_spells.registerSimpleSpell("whirlwind", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.WIND, "Whirlwind"),
        "Left-click on a entity: launch the entity away from you.",
        "Right-click on a entity: launch the entity up.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = {3, 6},
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "object" then
            return
        end

        local ref = pointed_thing.ref
        local ppos = user:get_pos()
        local refpos = ref:get_pos()
        local dir = vector.direction(ppos, refpos)

        local velocity = vector.multiply(dir, WHIRLWIND_MULT)
        velocity.y = WHIRLWIND_VELOCITY_Y

        mahiko_damage.punch(ref, user, 1, {
            damage_groups = {fleshy = 6, choppy = 10},
        }, dir)
        ref:add_velocity(velocity)
        return true
    end,
    _on_rightclick = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "object" then
            return
        end

        local velocity = {x = 0, y = WHIRLWIND_MULT, z = 0}
        local ref = pointed_thing.ref
        mahiko_damage.punch(ref, user, 1, {
            damage_groups = {fleshy = 8, choppy = 10},
        }, nil)
        ref:add_velocity(velocity)
        return true
    end,
    range = 2.5,
})

mahiko_spells.registerSimpleSpell("microburst", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.WIND, "Microburst"),
        "Left-click: launch a precise, high-damage gust of wind.",
        --"Right-click: launch a precise gust of wind that pushes away players.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 6,
    on_use = function(itemstack, user, _)
        mahiko_utils.raycastOnContact(user, function(ray)
            for pointed_thing in ray do
                if pointed_thing.type ~= "object" then
                    goto continue
                end
                local ref = pointed_thing.ref
                if ref ~= user then
                    mahiko_damage.punch(ref, user, 1, {
                        damage_groups = {fleshy = 20, choppy = 20,}
                    }, nil)
                    break
                end
                ::continue::
            end
        end)
        return true
    end,
})

mahiko_spells.registerSimpleSpell("waldgose", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.WIND, "Waldgose"),
        "Left-click: launch a tornado.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 6,
})