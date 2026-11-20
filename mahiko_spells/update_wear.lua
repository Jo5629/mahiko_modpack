mahiko_spells.update_wear = {}

local cache = {}
local function generateID()
    local num
    repeat
        num = math.random(1, 9999999)
    until not cache[num]
    cache[num] = -1
    return num
end

function mahiko_spells.update_wear.findOrAssignID(itemstack)
    local meta = itemstack:get_meta()
    local id = meta:get_int("mahiko_spells:id")
    if id < 1 then
        id = generateID()
        meta:set_int("mahiko_spells:id", id)
    else
        cache[id] = -1
    end
    return id, itemstack
end

local function findItem(id, inv, listname)
    if not cache[id] then
        return nil, nil
    end

    if cache[id] > 0 then
        local stack = inv:get_stack(listname, cache[id])
        local meta = stack:get_meta()
        if meta:get_int("mahiko_spells:id") == id then
            return stack, cache[id]
        end
    end

    for i, stack in pairs(inv:get_list(listname)) do
        local meta = stack:get_meta()
        if meta:get_int("mahiko_spells:id") == id then
            cache[id] = i
            return stack, i
        end
    end
    return nil, nil
end

local function updateWear(player, id, timeLeft, totalTime, listname, mode)
    local inv = player:get_inventory()
    local stack, index = findItem(id, inv, listname)
    if stack == nil then
        cache[id] = nil
        return
    end
    if stack:is_empty() then
        return
    end

    --local def = core.registered_tools[stack:get_name()]
    --local cooldown = def._cooldown
    --local use_duration = def._use_duration or cooldown

    local newWear = 0
    local percent = timeLeft / totalTime
    if mode == "up" then
        --percent = timeLeft / cooldown
        newWear = math.floor(65535 * percent)
    elseif mode == "down" then
        --percent = timeLeft / use_duration
        newWear = math.floor(65535 * (1 - percent))
    end

    stack:set_wear(newWear)
    inv:set_stack(listname, index, stack)
end

function mahiko_spells.update_wear.startUpdate(pname, stack, time, params)
    local id = stack:get_meta():get_int("mahiko_spells:id")
    params.pname = pname
    mahiko_spells.cooldowns:start(id, time, params)
end

-- Updating the cooldowns every ~0.01s creates unnecessary
-- CPU load, so the cooldowns have a timer.
local UPDATE_INTERVAL = 0.25
local elapsed = 0
core.register_globalstep(function(dtime)
    elapsed = elapsed + dtime
    if elapsed < UPDATE_INTERVAL then
        return
    end

    local cooldowns = mahiko_spells.cooldowns
    cooldowns:update(elapsed, true)
    cooldowns:iterate(function(id, timeLeft, params)
        local player = core.get_player_by_name(params.pname)
        if player then
            updateWear(player, id, timeLeft, params.totalTime, "main", params.mode)
            --params.step(id, timeLeft, params, elapsed, player)
        end
    end)
    cooldowns:clearCachedTimers()

    elapsed = 0
end)