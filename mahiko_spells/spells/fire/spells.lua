local COLORS = mahiko_spells.COLORS
local ELEMENT_INT = 1
local DEFAULT_SPELL_ICON = "mahiko_spells_element_fire.png"
local HOTHANDS_DMG_INTERVAL = 1
local HOTSTREAK_SPEED_MULT = 2.5
local FIREBALL_VELOCITY_MULT = 30
local FIREBALL_OFFSET_Y = 1.25
local FIREBALL_LIFETIME = 3

mahiko_spells.registerFancySpell("hot_hands", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.FIRE, "Hot Hands"),
        "Left-click on a object: object takes fire damage",
        "for 6 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 6,
    _cooldown = 12,
    on_use = function(itemstack, user, pointed_thing)
        if not pointed_thing.type == "object" then
            return
        end

        local ref = pointed_thing.ref
        if ref then
            local GUID = ref:get_guid()
            return true, {
                GUID = GUID,
                interval = 0,
            }
        end
    end,
    _on_step = function(id, dtime, params)
        if params.mode ~= "down" then
            return
        end

        params.interval = params.interval - dtime
        if params.interval > 0 then
            return params
        end
        params.interval = HOTHANDS_DMG_INTERVAL

        local receiver = core.objects_by_guid[params.GUID]
        if not receiver then
            return params
        end
        local hitter = core.get_player_by_name(params.pname)
        if not hitter then
            return params
        end

        mahiko_damage.punch(receiver, hitter, HOTHANDS_DMG_INTERVAL, {
            damage_groups = {fleshy = 2, choppy = 2},
            full_punch_interval = HOTHANDS_DMG_INTERVAL,
        }, nil)

        return params
    end,
})

local function endHotStreak(id, params)
    local player = core.get_player_by_name(params.pname)
    if player then
        player:set_physics_override({
            speed = params.old
        })
    end
    local object = core.objects_by_guid[params.GUID]
    if object then
        object:set_detach()
        object:remove()
    end
end

mahiko_spells.registerFancySpell("hot_streak", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.FIRE, "Hot Streak"),
        "Left-click: increase your speed and leave a trail",
        "of fire behind as you run for 6 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 6,
    _cooldown = 15,
    on_use = function(itemstack, user, pointed_thing)
        local object = core.add_entity(user:get_pos(), "mahiko_spells:fired_up")
        if not object then
            return
        end

        object:get_luaentity().attached = user:get_player_name()
        object:set_attach(user)

        local physics = user:get_physics_override()
        local old = physics.speed
        user:set_physics_override({
            speed = HOTSTREAK_SPEED_MULT,
        })

        return true, {
            old = old,
            GUID = object:get_guid(),
        }
    end,
    _on_finish = endHotStreak,
    _on_cancel = endHotStreak,
})

mahiko_spells.registerSimpleSpell("fireball", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.FIRE, "Fireball"),
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 6,
    on_use = function(itemstack, user, pointed_thing)
        local dir = user:get_look_dir()
        local velocity = vector.multiply(dir, FIREBALL_VELOCITY_MULT)

        local pos = user:get_pos()
        pos.y = pos.y + FIREBALL_OFFSET_Y
        local entity = core.add_entity(pos, "mahiko_spells:fireball")
        if entity then
            local luaentity = entity:get_luaentity()
            luaentity:activate(velocity, FIREBALL_LIFETIME)
            luaentity.sender = user:get_player_name()
            return true
        end
    end
})