local DUMMY = function(...) end

local categories = {}
local cindex = 0
function mahiko_spells.registerCategory(name)
    cindex = cindex + 1
    mahiko_spells.registered_spells[cindex] = {}
    categories[cindex] = name
    return cindex
end

function mahiko_spells.getAllCategories()
    return categories
end

function mahiko_spells.getSpellsInCategory(i)
    return mahiko_spells.registered_spells[i]
end

function mahiko_spells.intFromCategory(name)
    for i, category in ipairs(categories) do
        if category == name then
            return i
        end
    end
    return -1
end

local function registerRawSpell(name, def)
    if not name:match(":") then
        name = "mahiko_spells:" .. name
    end

    assert(def.groups.mahiko_element, "[mahiko_spells] Element integer must be specified when registering!")

    local index = def.groups.mahiko_element
    table.insert(mahiko_spells.registered_spells[index], name)

    def.on_drop = function(itemstack, dropper, pos)
        if itemstack:get_wear() == 0 then
            return core.item_drop(itemstack, dropper, pos)
        end
        return nil
    end

    core.register_tool(":" .. name, def)
end

local function combine(t1, t2, overwrite)
    local o = {}
    for k, v in pairs(t1) do
        o[k] = v
    end
    for k, v in pairs(t2) do
        if not o[k] or overwrite then
            o[k] = v
        end
    end
    return o
end

function mahiko_spells.registerSimpleSpell(name, def)
    local lcooldown = def._cooldown
    local rcooldown = def._cooldown
    if type(def._cooldown) == "table" then
        lcooldown = def._cooldown[1]
        rcooldown = def._cooldown[2]
    end

    local on_use = def.on_use or DUMMY
    local on_rightclick = def._on_rightclick or DUMMY
    local finish = def._on_finish or DUMMY
    local cancel = def._on_cancel or DUMMY
    local step = def._on_step or DUMMY

    local function activate(stack, user, pointed_thing, func, cooldown)
        cooldown = cooldown or lcooldown
        local id, itemstack = mahiko_spells.update_wear.findOrAssignID(stack)
        local pname = user:get_player_name()
        local exists = mahiko_spells.cooldowns:exists(id)
        if not exists and itemstack:get_wear() == 0 then
            local success, params, newstack = func(itemstack, user, pointed_thing)
            if not success then
                return itemstack
            end

            itemstack = newstack or itemstack
            mahiko_spells.update_wear.startUpdate(pname, itemstack, cooldown, combine({
                mode = "up",
                finish = finish,
                cancel = cancel,
                step = step,
                totalTime = cooldown,
            }, params or {}))
        end
        return itemstack
    end

    def.on_use = function(stack, user, pointed_thing)
        return activate(stack, user, pointed_thing, on_use)
    end
    if on_rightclick then
        def.on_secondary_use = function(stack, user, pointed_thing)
            return activate(stack, user, pointed_thing, on_rightclick, rcooldown)
        end
        def.on_place = function(stack, user, pointed_thing)
			if pointed_thing and pointed_thing.under then
				local node = core.get_node(pointed_thing.under)
				local ndef = core.registered_nodes[node.name]
				if ndef and ndef.on_rightclick then
					return core.item_place(stack, user, pointed_thing)
				end
			end
            return activate(stack, user, pointed_thing, on_rightclick, rcooldown)
        end
    end

    registerRawSpell(name, def)
end

function mahiko_spells.registerFancySpell(name, def)
    local cooldown = def._cooldown
    local use_duration = def._use_duration or cooldown

    local on_use = def.on_use or DUMMY
    --local on_rightclick = def._on_rightclick or DUMMY
    local finish = def._on_finish or DUMMY
    local cancel = def._on_cancel or DUMMY
    local step = def._on_step or DUMMY

    local function activate(stack, user, pointed_thing, func)
        local id, itemstack = mahiko_spells.update_wear.findOrAssignID(stack)
        local pname = user:get_player_name()
        local exists = mahiko_spells.cooldowns:exists(id)
        if not exists and itemstack:get_wear() == 0 then
            local success, params, newstack = func(itemstack, user, pointed_thing)
            if not success then
                return itemstack
            end

            itemstack = newstack or itemstack
            local newparams = combine({
                mode = "down",
                finish = function(id, params)
                    finish(id, params)
                    mahiko_spells.update_wear.startUpdate(params.pname, itemstack, cooldown, combine({
                        mode = "up",
                        finish = finish,
                        cancel = cancel,
                        step = step,
                        totalTime = cooldown
                    }, params or {}))
                end,
                cancel = cancel,
                step = step,
                totalTime = use_duration,
            }, params or {})
            mahiko_spells.update_wear.startUpdate(pname, itemstack, use_duration, newparams)
        end
        return itemstack
    end

    def.on_use = function(stack, user, pointed_thing)
        return activate(stack, user, pointed_thing, on_use)
    end
    --[[ For now, limit fancy spells to only left-click to stop any conflicts.
    if on_rightclick then
        def.on_secondary_use = function(stack, user, pointed_thing)
            return activate(stack, user, pointed_thing, on_rightclick)
        end
        def.on_place = function(stack, user, pointed_thing)
            return activate(stack, user, pointed_thing, on_rightclick)
        end
    end
    ]]

    registerRawSpell(name, def)
end