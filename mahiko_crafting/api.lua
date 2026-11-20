function mahiko_crafting.registerCraft(def)
    assert(def.output)
    assert(def.recipe)
    mahiko_crafting.registered_crafts[def.output] = def.recipe
end

function mahiko_crafting.getRecipe(name)
    return mahiko_crafting.registered_crafts[name]
end

function mahiko_crafting.hasNeededItems(name, inv, listname)
    local recipe = mahiko_crafting.getRecipe(name)
    if not recipe then
        return false
    end

    local hasItems = true
    for _, item in pairs(recipe) do
        if not inv:contains_item(listname, ItemStack(item)) then
            hasItems = false
            break
        end
    end
    return hasItems
end