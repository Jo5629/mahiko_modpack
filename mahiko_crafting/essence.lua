local ESSENCE_ITEMNAME = "mahiko_crafting:essence"
local ESSENCE_ORE = "mahiko_crafting:stone_with_essence"

core.register_craftitem(ESSENCE_ITEMNAME, {
    description = "Essence Fragment",
    inventory_image = "mahiko_crafting_essence.png",
    stack_max = 32,
})

core.register_node(ESSENCE_ORE, {
    description = "Essence Ore",
    tiles = {"default_stone.png^(mahiko_crafting_essence_overlay.png^[opacity:160)"},
    paramtype = "light",
    groups = {cracky = 2},
    drop = ESSENCE_ITEMNAME,
    light_source = 2,
})