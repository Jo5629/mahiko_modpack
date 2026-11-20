local ITEM_SIZE = 1.2

local gui = flow.widgets
local formspec = flow.make_gui(function(player, ctx)
    local vbox = gui.VBox{
        name = "vbox1", w = 8, h = 8, spacing = 0.3,
    }
    ctx.form.category = ctx.form.category or 1

    local i = math.random(1, 5)
    local spells = mahiko_spells.getSpellsInCategory(ctx.form.category)
    for _, spell in ipairs(spells) do
        local itemstack = ItemStack(spell)
        local hbox = gui.HBox{}
        table.insert_all(hbox, {gui.ItemImage{
            w = ITEM_SIZE, h = ITEM_SIZE,
            item_name = spell,
            tooltip = itemstack:get_description()
        }, gui.Spacer{}})

        local recipe = mahiko_crafting.getRecipe(spell)
        if not recipe then
            goto continue
        end

        for _, item in ipairs(recipe) do
            table.insert(hbox, gui.ItemImage{
                w = ITEM_SIZE, h = ITEM_SIZE,
                item_name = item,
                tooltip = ItemStack(item):get_short_description()
            })
        end

        ::continue::
        table.insert(vbox, hbox)
    end

    local topVBox = gui.HBox{
        gui.ItemImage{
            w = 1.5, h = 1.5,
            item_name = "mahiko_crafting:table",
        },
        --align_h = "center",
        gui.Dropdown{
            name = "category",
            items = mahiko_spells.getAllCategories(),
            index_event = true,
            expand = true,
        },
    }

    return gui.VBox{
        gui.Label{label = "SPELL CRAFTGUIDE", align_h = "center"},
        topVBox,
        gui.ScrollableVBox(vbox),
    }
end)

core.register_craftitem("mahiko_crafting:guide", {
    description = "Craft Guide",
    inventory_image = "mahiko_crafting_craftguide.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        formspec:show(user)
    end
})