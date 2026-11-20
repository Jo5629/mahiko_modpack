local ESSENCE_ORE = "mahiko_crafting:stone_with_essence"
local ESSENCE_ITEM = "mahiko_crafting:essence"
local BLANK_SPELL = "mahiko_crafting:blank_spell"
local FLINT = "default:flint"
local COAL_LUMP = "default:coal_lump"
local SLAB_STONEBLOCK = "stairs:slab_stone_block"

core.register_ore({
    ore_type = "scatter",
    ore = ESSENCE_ORE,
    wherein = "default:stone",
    clust_scarcity = 120 * 120 * 120,
    clust_num_ores = 9,
    clust_size = 3,
    y_max = 256,
    y_min = -1024,
})

core.register_craft({
    output = BLANK_SPELL .. " 4",
    recipe = {
        {FLINT},
        {SLAB_STONEBLOCK},
    }
})

core.register_craft({
    output = "mahiko_crafting:table",
    recipe = {
        {"", ESSENCE_ITEM, ""},
        {ESSENCE_ITEM, SLAB_STONEBLOCK, ESSENCE_ITEM},
        {"", ESSENCE_ITEM, ""},
    }
})

core.register_craft({
    type = "shapeless",
    output = "mahiko_crafting:guide",
    recipe = {"default:book", BLANK_SPELL}
})

local function register(name, recipe)
    table.insert(recipe, 1, BLANK_SPELL)
    return mahiko_crafting.registerCraft({
        output = "mahiko_spells:" .. name,
        recipe = recipe,
    })
end

register("hot_hands", {
    ESSENCE_ITEM .. " 2",
    COAL_LUMP .. " 4",
})

register("hot_streak", {
    ESSENCE_ITEM .. " 2",
    COAL_LUMP .. " 2",
    "default:furnace",
})

register("fireball", {
    ESSENCE_ITEM .. " 4",
    COAL_LUMP .. " 5",
    "fire:flint_and_steel",
})

register("barracuda", {
    ESSENCE_ITEM .. " 4",
    "default:sand_with_kelp",
})

register("whirlpool", {
    ESSENCE_ITEM .. " 6",
    "default:coral_cyan",
})

register("breathability", {
    ESSENCE_ITEM .. " 4",
    "default:coral_cyan",
    "default:coral_orange",
})

register("condenser", {
    ESSENCE_ITEM .. " 2",
    "bucket:bucket_water",
})

register("hurler", {
    ESSENCE_ITEM .. " 4",
    "default:dirt 4",
})

register("masonry", {
    ESSENCE_ITEM .. " 4",
    "default:stone 3",
    "default:pick_steel",
})

register("excavator", {
    ESSENCE_ITEM .. " 4",
    "default:dirt 3",
    "default:shovel_steel",
})

register("contaminator", {
    ESSENCE_ITEM .. " 5",
    "default:dirt 4",
    "flowers:mushroom_red 4",
})

register("molerat", {
    ESSENCE_ITEM .. " 4",
    "default:dirt 4",
    "default:stone 4",
})

register("weightlessness", {
    ESSENCE_ITEM .. " 8",
    "fireflies:firefly_bottle 4",
})

register("propulsion", {
    ESSENCE_ITEM .. " 6",
    "default:acacia_sapling 4",
})

register("whirlwind", {
    ESSENCE_ITEM .. " 6",
    "default:junglesapling 4",
})

register("microburst", {
    ESSENCE_ITEM .. " 6",
    "default:junglesapling 4",
    "default:sword_steel",
})