local WIDTH = 3
local HEIGHT = 3

local function GET_OFFSETS(w, h)
    w = w or WIDTH
    h = h or HEIGHT
    local offset = (w - 1) / 2
    return {
        X = {
            {x = offset, y = 0, z = 0},
            {x = offset, y = h - 1, z = 0},
        },
        Z = {
            {x = 0, y = 0, z = offset},
            {x = 0, y = h - 1, z = offset},
        },
    }
end

function mahiko_spells.water.getNodes(player, pos, w, h, offsetFunc)
    local wallOffsets = GET_OFFSETS(w, h)
    if type(offsetFunc) == "function" then
        wallOffsets = offsetFunc(w, h)
    end

    local offsets = {}
    local cdir = mahiko_spells.earth.getCardinalDirection(player)
    if cdir == "N" or cdir == "S" then
        offsets = wallOffsets.X
    elseif cdir == "E" or cdir == "W" then
        offsets = wallOffsets.Z
    end

    local positions = {}
    local pos1 = vector.subtract(pos, offsets[1])
    local pos2 = vector.add(pos, offsets[2])
    for x = pos1.x, pos2.x do
    for y = pos1.y, pos2.y do
    for z = pos1.z, pos2.z do
        local npos = vector.new(x, y, z)
        table.insert(positions, npos)
    end
    end
    end

    return positions
end

function mahiko_spells.water.inWater(pos)
    pos = {
        x = math.ceil(pos.x),
        y = math.ceil(pos.y),
        z = math.ceil(pos.z),
    }
    local name = core.get_node(pos).name
    return name:match("water")
end