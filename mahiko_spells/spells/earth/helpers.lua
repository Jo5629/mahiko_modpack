local WIDTH = 5 -- Must be an odd integer.
local HEIGHT = 4
local EARTH_GROUPS = {"mahiko_earth", "sand", "soil", "stone"} --"gravel"}

local function GET_OFFSETS(w, h)
    w = w or WIDTH
    h = h or HEIGHT
    local offset = (w - 1) / 2
    return {
        X = {
            {x = offset, y = h - 1, z = 0},
            {x = offset, y = 0, z = 0}
        },
        Z = {
            {x = 0, y = h - 1, z = offset},
            {x = 0, y = 0, z = offset}
        },
    }
end

function mahiko_spells.earth.getCardinalDirection(player)
    local radians = player:get_look_horizontal()
    local degrees = math.deg(radians)
    local direction
    if degrees <= 45 or degrees >= 315 then
        direction = "N"
    elseif degrees >= 45 and degrees <= 135 then
        direction = "W"
    elseif degrees >= 135 and degrees <= 225 then
        direction = "S"
    elseif degrees >= 225 and degrees <= 315 then
        direction = "E"
    end
    return direction
end

function mahiko_spells.earth.getFacingNodes(user, pointed_thing, w, h)
    local wallOffsets = GET_OFFSETS(w, h)
    local offsets = {}
    local cdir = mahiko_spells.earth.getCardinalDirection(user)
    if cdir == "N" or cdir == "S" then
        offsets = wallOffsets.X
    elseif cdir == "E" or cdir == "W" then
        offsets = wallOffsets.Z
    end

    local pos = pointed_thing.under

    local positions = {}
    local pos1 = vector.subtract(pos, offsets[1])
    local pos2 = vector.add(pos, offsets[2])
    for x = pos1.x, pos2.x do
    for y = pos1.y, pos2.y do
    for z = pos1.z, pos2.z do
        local oldpos = {x = x, y = y, z = z}
        positions[oldpos] = core.get_node(oldpos)
        core.remove_node(oldpos)
    end
    end
    end
    return positions
end

local function isInGroup(name, group)
    return core.get_item_group(name, group) > 0
end

local cache = {}
function mahiko_spells.earth.isEarthNode(pos)
    local node = core.get_node_or_nil(pos)
    if not node then
        return false
    end

    local name = node.name
    local cid = core.get_content_id(name)
    if name == "air" or name == "ignore" then
        return false
    elseif cache[cid] then
        return cache[cid]
    end

    local isEarthNode = false
    if not (isInGroup(name, "immortal") or isInGroup(name, "not_in_mahiko_earth")) then
        for _, group in pairs(EARTH_GROUPS) do
            if isInGroup(name, group) then
                isEarthNode = true
                break
            end
        end
    end

    cache[cid] = isEarthNode
    return isEarthNode
end

core.register_on_mods_loaded(function()
    for _, def in pairs(core.registered_biomes) do
        local nodes = {
            def.node_dust, def.node_top, def.node_filler,
            def.node_stone, def.node_water_top, def.node_riverbed,
        }
        for _, name in pairs(nodes) do
            local cid = core.get_content_id(name)
            local isEarthNode = core.get_item_group(name, "not_in_mahiko_earth") == 0
                and core.get_item_group(name, "immortal") == 0
            if name ~= "air" and not cache[cid] and isEarthNode then
                cache[cid] = true
            end
        end
    end
end)