local COLORS = mahiko_spells.COLORS
local ELEMENT_INT = 3
local DEFAULT_SPELL_ICON = "mahiko_spells_element_earth.png"
local POISONED_DIRT = "mahiko_spells:contaminated_dirt"
local HURLER_PPOS_OFFSET_Y = 1.15
local HURLER_PPOS_MULT = 1.5
local HURLER_VELOCITY_MULT = 30
local HURLER_NODE_DESPAWN = 3
local MASONRY_HEIGHT = 4
local EXCAVATOR_HEIGHT = 3
local EXCAVATOR_WIDTH = 5
local CONTAMINATOR_OFFSET = 1
local CONTAMINATOR_TRAP_MIN = 60
local CONTAMINATOR_TRAP_MAX = 100
local CONTAMINATOR_PLACE_MIN = 300
local CONTAMINATOR_PLACE_MAX = 600
local MOLERAT_HORIZ_DIST = 4
local MOLERAT_VERTI_DIST = 4
local MOLERAT_DIRECTIONS = {
    N = vector.new(0, 0, -1),
    S = vector.new(0, 0, 1),
    E = vector.new(-1, 0, 0),
    W = vector.new(1, 0, 0),
}

local posCache = {}
mahiko_spells.registerSimpleSpell("hurler", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.EARTH, "Hurler"),
        "Left-click: throw a fast-moving, explosive",
        "block in the direction you are facing.",
        "Right-click: select the block to throw."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 5,
    on_use = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        local pos = posCache[name]
        if not pos then
            return
        end

        local ppos = user:get_pos()
        local dir = user:get_look_dir()

        local node = core.get_node(pos)
        core.remove_node(pos)

        ppos.y = ppos.y + HURLER_PPOS_OFFSET_Y
        ppos = ppos + vector.multiply(dir, HURLER_PPOS_MULT)
        local velocity = vector.multiply(dir, HURLER_VELOCITY_MULT)

        local entity = core.add_entity(ppos, "mahiko_spells:node_explosive")
        if not entity then
            return
        end
        local luaentity = entity:get_luaentity()
        luaentity:activate(node, velocity, HURLER_NODE_DESPAWN)

        posCache[name] = nil
        return true
    end,
    _on_rightclick = function(itemstack, user, pointed_thing)
        local name = user:get_player_name()
        if pointed_thing.type ~= "node" then
            return
        end

        local isEarthNode = mahiko_spells.earth.isEarthNode(pointed_thing.under)
        if isEarthNode then
            core.chat_send_player(name, "Selected node to throw.")
            posCache[name] = pointed_thing.under
        else
            core.chat_send_player(name, "Node selected is not a ground node.")
        end
    end,
})

mahiko_spells.registerSimpleSpell("masonry", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.EARTH, "Masonry"),
        "Left-click: build a four-block tall pillar.",
        "Right-click: build a five by four wall."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = {3, 6},
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local top = pointed_thing.under
        local offset = MASONRY_HEIGHT
        for i = 1, MASONRY_HEIGHT do
            local test = vector.new(top.x, top.y + i, top.z)
            if core.get_node(test).name ~= "air" then
                offset = i - 1
                break
            end
        end

        if offset < 2 then
            return
        end

        for i = 0, offset - 1 do
            local old = {x = top.x, y = top.y - i, z = top.z}
            local new = {x = top.x, y = old.y + offset, z = top.z}
            core.set_node(new, core.get_node(old))
            core.remove_node(old)
        end
        return true
    end,
    _on_rightclick = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        for oldpos, node in pairs(mahiko_spells.earth.getFacingNodes(user, pointed_thing)) do
            oldpos.y = oldpos.y + MASONRY_HEIGHT
            core.set_node(oldpos, node)
        end
        return true
    end,
})

mahiko_spells.registerSimpleSpell("excavator", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.EARTH, "Excavator"),
        "Left-click: dig a 5 by 3 hole.",
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 12,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local middle = pointed_thing.under
        local offset = (EXCAVATOR_WIDTH - 1) / 2
        local pos1 = middle - vector.new(offset, EXCAVATOR_HEIGHT - 1, offset)
        local pos2 = middle + vector.new(offset, 0, offset)
        for z = pos2.z, pos1.z, -1 do
        for y = pos2.y, pos1.y, -1 do
        for x = pos2.x, pos1.x, -1 do
            local pos = vector.new(x, y, z)
            if mahiko_spells.earth.isEarthNode(pos) then
                core.dig_node(pos)
            end
        end
        end
        end
        return true
    end,
})

mahiko_spells.registerSimpleSpell("contaminator", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.EARTH, "Contaminator"),
        "Left-click on an entity: trap the entity in Poisoned Dirt.",
        "Right-click on a node: place a block of Poisoned Dirt."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = {8, 12},
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "object" then
            return
        end

        local ref = pointed_thing.ref
        local pos = ref:get_pos()
        --pos.y = pos.y + 1
        local pos1 = vector.subtract(pos, CONTAMINATOR_OFFSET)
        local pos2 = vector.add(pos, CONTAMINATOR_OFFSET)
        for x = pos1.x, pos2.x do
        for y = pos1.y, pos2.y do
        for z = pos1.z, pos2.z do
            local npos = {x = x, y = y, z = z}
            local node = core.get_node(npos)
            if node.name ~= "air" and not mahiko_spells.earth.isEarthNode(npos) then
                goto continue
            end
            core.dig_node(npos)
            core.set_node(npos, {name = POISONED_DIRT})
            local timer = core.get_node_timer(npos)
            local timeout = math.random(CONTAMINATOR_TRAP_MIN, CONTAMINATOR_TRAP_MAX) / 10
            timer:start(timeout)
            ::continue::
        end
        end
        end
        return true
    end,
    _on_rightclick = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local pos = pointed_thing.above
        core.set_node(pos, {name = POISONED_DIRT})
        local timer = core.get_node_timer(pos)
        local timeout = math.random(CONTAMINATOR_PLACE_MIN, CONTAMINATOR_PLACE_MAX) / 10
        timer:start(timeout)
        return true
    end,
})

mahiko_spells.registerSimpleSpell("molerat", {
    groups = {mahiko_element = ELEMENT_INT},
    description = table.concat({
        core.colorize(COLORS.EARTH, "Mole Rat"),
        "Left-click on an node: dig four blocks forwards.",
        "Right-click on a node: dig four blocks deep."
    }, "\n"),
    inventory_image = DEFAULT_SPELL_ICON,
    _cooldown = 10,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local start = pointed_thing.under
        local cDir = mahiko_spells.earth.getCardinalDirection(user)
        if not cDir then
            return
        end
        local nodeDir = MOLERAT_DIRECTIONS[cDir]
        for i = 0, MOLERAT_HORIZ_DIST - 1 do
            local pos = start - nodeDir * i
            if mahiko_spells.earth.isEarthNode(pos) then
                core.dig_node(pos)
            else
                break
            end
        end
        return true
    end,
    _on_rightclick = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then
            return
        end

        local start = pointed_thing.under
        for i = 0, MOLERAT_VERTI_DIST - 1 do
            local pos = start - vector.new(0, i, 0)
            if mahiko_spells.earth.isEarthNode(pos) then
                core.dig_node(pos)
            else
                break
            end
        end
        return true
    end,
})

--[[ USE THIS IN THE FUTURE?
local function propel(pos, node, velocity)
    core.remove_node(pos)
    local entity = core.add_entity(pos, "mahiko_spells:node")
    if entity then
        entity:get_luaentity():activate(node, velocity, 3)
    end
end

on_use = function(itemstack, user, pointed_thing)
    if pointed_thing.type ~= "node" then
        return
    end

    local dir = vector.direction(user:get_pos(), pointed_thing.under)
    dir.y = 0
    for oldpos, node in pairs(mahiko_spells.earth.getFacingNodes(user, pointed_thing)) do
        oldpos.y = oldpos.y + 4
        core.set_node(oldpos, node)
        local speed = math.random(15, 20)
        propel(oldpos, node, vector.multiply(dir, speed))
    end
    return true
end,
]]