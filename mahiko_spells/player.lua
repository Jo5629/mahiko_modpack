core.register_on_leaveplayer(function(player)
    local cooldowns = mahiko_spells.cooldowns
    local inv = player:get_inventory()
    local listname = "main"
    for i, stack in pairs(inv:get_list(listname)) do
        if not stack:is_empty() then
            local id = stack:get_meta():get_int("mahiko_spells:id")
            local hasID = id > 0
            if hasID and stack:get_wear() > 0 then
                if cooldowns:exists(id) then
                    cooldowns:cancel(id)
                end
                stack:set_wear(0)
                inv:set_stack(listname, i, stack)
            end
        end
    end
end)

core.register_on_dieplayer(function(player, reason)
    local cooldowns = mahiko_spells.cooldowns
    local inv = player:get_inventory()
    local listname = "main"
    for i, stack in pairs(inv:get_list(listname)) do
        if not stack:is_empty() then
            local id = stack:get_meta():get_int("mahiko_spells:id")
            if id > 0 and cooldowns:exists(id) then
                cooldowns:cancel(id)
                stack:set_wear(0)
                inv:set_stack(listname, i, stack)
            end
        end
    end
end)

core.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if action ~= "take" then
        return
    end
    local stack = inventory_info.stack
    if stack then
        local isSpell = stack:get_meta():get_int("mahiko_spells:id") > 0
        if isSpell and stack:get_wear() > 0 then
            return 0
        end
    end
end)