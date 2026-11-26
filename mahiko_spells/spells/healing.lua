local COLORS = mahiko_spells.COLORS
local COLORIZE = core.colorize
local ELEMENT_INT = mahiko_spells.intFromCategory("healing")
local DEFAULT_SPELL_ICON = "mahiko_spells_element_healing.png"
local REPLENISHMENT_HP = 2 * 2
local REJUVENATE_RADIUS = 3
local REJUVENATE_HP = 2 * 2
local VAMPIRE_HP = 3
local LEECH_DMG_INTERVAL = 1
local LEECH_HP = 2
local HEALING_SLAB_INTERVAL = 1.0

mahiko_spells.registerSimpleSpell("replenishment", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.HEALING, "Replenishment"),
        "Left-click: heal 2 hearts.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 2,
    on_use = function(itemstack, user, pointed_thing)
        local newHP = user:get_hp() + REPLENISHMENT_HP
        if newHP > user:get_properties().hp_max then
            return false
        end
        user:set_hp(newHP)
        return true
    end,
})

mahiko_spells.registerSimpleSpell("rejuvenate", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.HEALING, "Rejuvenate"),
        "Left-click: heal the players in a three-block radius",
        "around you by 3 hearts.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 4,
    on_use = function(itemstack, user, pointed_thing)
        local pos = user:get_pos()
        local objects = core.get_objects_inside_radius(pos, REJUVENATE_RADIUS)
        for _, obj in pairs(objects) do
            if obj:is_player() then
                local newHP = obj:get_hp() + REJUVENATE_HP
                if newHP > obj:get_properties().hp_max then
                    newHP = obj:get_properties().hp_max
                end
                obj:set_hp(newHP)
            end
        end
        return true
    end,
})

mahiko_spells.registerSimpleSpell("vampire", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.HEALING, "Vampire"),
        "Left-click on an object: steal 3 HP for yourself.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 4,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "object" then
            return
        end

        local newHP = user:get_hp() + VAMPIRE_HP
        if newHP > user:get_properties().hp_max then
            return false
        end

        local ref = pointed_thing.ref
        mahiko_damage.punch(ref, user, 1, {
            damage_groups = {fleshy = VAMPIRE_HP}
        }, nil)

        user:set_hp(newHP)
        return true
    end,
})

mahiko_spells.registerFancySpell("leech", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.HEALING, "Leech"),
        "Left-click on a object: steal 2 HP from an object per",
        "second for 3 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 3,
    _cooldown = 8,
    on_use = function(itemstack, user, pointed_thing)
        if not pointed_thing.type == "object" then
            return
        end

        local ref = pointed_thing.ref
        if ref then
            local GUID = ref:get_guid()
            return true, {
                GUID = GUID,
                hitter = user:get_player_name(),
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
        params.interval = LEECH_DMG_INTERVAL

        local receiver = core.objects_by_guid[params.GUID]
        if not receiver then
            return params
        end
        local hitter = core.get_player_by_name(params.hitter)
        if not hitter then
            return params
        end

        mahiko_damage.punch(receiver, hitter, 1, {
            damage_groups = {fleshy = LEECH_HP},
            full_punch_interval = LEECH_DMG_INTERVAL,
        }, nil)

        local newHP = hitter:get_hp() + LEECH_HP
        local hpMax = hitter:get_properties().hp_max
        if newHP > hpMax then
            newHP = hpMax
        end
        hitter:set_hp(newHP)
        return params
    end,
})

local function removeTower(id, params)
    local pos = params.pos
    local node = core.get_node(pos)
    local meta = core.get_meta(pos)
    local placer = meta:get_string("mahiko_spells:placer")
    if node.name == "mahiko_spells:healing_slab" and placer == params.pname then
        core.remove_node(pos)
    end
end

mahiko_spells.registerFancySpell("mobile_medkit", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        COLORIZE(COLORS.HEALING, "Mobile Medkit"),
        "Left-click: place a healing slab for 15 seconds.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _use_duration = 15,
    _cooldown = 25,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local pos = pointed_thing.above
        core.place_node(pos, {name = "mahiko_spells:healing_slab"}, user)

        local meta = core.get_meta(pos)
        meta:set_string("mahiko_spells:placer", user:get_player_name())

        local timer = core.get_node_timer(pos)
        timer:start(HEALING_SLAB_INTERVAL)

        return true, {
            pos = pos,
        }
    end,
    _on_finish = removeTower,
    _on_cancel = removeTower,
})