local function resetSpells(player, listname)
    local cooldowns = mahiko_spells.cooldowns
    local inv = player:get_inventory()
    for i, itemstack in pairs(inv:get_list(listname)) do
        local id = itemstack:get_meta():get_int("mahiko_spells:id")
        if id > 1 then
            if cooldowns:exists(id) then
                cooldowns:cancel(id)
            end
            itemstack:set_wear(0)
            inv:set_stack(listname, i, itemstack)
        end
    end
end

local cmd = chatcmdbuilder.register("resetspell", {
    privs = {rollback = true, server = true},
    description = "Resets the cooldown of all spells in your inventory. Recommended for use after server crashes.",
})

cmd:sub("", function(name)
    local player = core.get_player_by_name(name)
    if player then
        resetSpells(player, "main")
    end
end)

cmd:sub("all", function(name)
    for _, player in pairs(core.get_connected_players()) do
        resetSpells(player, "main")
    end
end)