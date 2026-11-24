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

local function register(name, recipe, essence)
    table.insert(recipe, 1, BLANK_SPELL)
    if essence then
        table.insert(recipe, 2, ESSENCE_ITEM .. " " .. tostring(essence))
    end
    return mahiko_crafting.registerCraft({
        output = "mahiko_spells:" .. name,
        recipe = recipe,
    })
end

register("hot_hands", {
    COAL_LUMP .. " 4",
}, 2)

register("hot_streak", {
    COAL_LUMP .. " 2",
    "default:furnace",
}, 2)

register("fireball", {
    COAL_LUMP .. " 5",
    "fire:flint_and_steel",
}, 4)

register("barracuda", {
    "default:sand_with_kelp",
}, 4)

register("whirlpool", {
    "default:coral_cyan",
}, 6)

register("breathability", {
    "default:coral_cyan",
    "default:coral_orange",
}, 4)

register("condenser", {
    "bucket:bucket_water",
}, 2)

register("hurler", {
    "default:dirt 4",
}, 4)

register("masonry", {
    "default:stone 3",
    "default:pick_steel",
}, 4)

register("excavator", {
    "default:dirt 3",
    "default:shovel_steel",
}, 4)

register("contaminator", {
    "default:dirt 4",
    "flowers:mushroom_red 4",
}, 5)

register("molerat", {
    "default:dirt 4",
    "default:stone 4",
}, 4)

register("weightlessness", {
    "fireflies:firefly_bottle 4",
}, 8)

register("propulsion", {
    "default:acacia_sapling 4",
}, 6)

register("whirlwind", {
    "default:junglesapling 4",
}, 6)

register("microburst", {
    "default:junglesapling 4",
    "default:sword_steel",
}, 6)

register("replenishment", {
    "default:apple 20",
}, 4)

register("rejuvenate", {
    "default:apple 20",
    "default:blueberries 20",
}, 4)

register("vampire", {
    "default:apple 20",
    "default:stonebrick 10",
}, 6)

register("leech", {
    "default:apple 20",
    "default:mossycobble 15",
}, 6)

register("mobile_medkit", {
    "default:apple 64",
    "default:stone_block 5",
}, 12)