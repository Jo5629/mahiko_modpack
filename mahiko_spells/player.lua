local function cancelAllSpells(inv, listname)
    local cooldowns = mahiko_spells.cooldowns
    for i, stack in pairs(inv:get_list(listname)) do
        if not stack:is_empty() then
            local meta = stack:get_meta()
            local id = meta:get_int("mahiko_spells:id")
            if id > 0 and cooldowns:exists(id) then
                cooldowns:cancel(id)
                meta:set_string("color", "")
                stack:set_wear(0)
                inv:set_stack(listname, i, stack)
            end
        end
    end
end

core.register_on_leaveplayer(function(player)
    local inv = player:get_inventory()
    cancelAllSpells(inv, "main")
end)

core.register_on_dieplayer(function(player)
    local inv = player:get_inventory()
    cancelAllSpells(inv, "main")
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