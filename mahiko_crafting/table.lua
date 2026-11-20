local INPUT_LISTNAME = "input"
local OUTPUT_LISTNAME = "output"

local formspec = {
	"formspec_version[6]",
	"size[11,11]",
	"label[4.6,0.5;Spell Table]",
	"list[context;output;8,2.75;1,1;0]",
	"list[context;input;2,1.5;3,3;0]",
	"list[current_player;main;0.65,5.85;8,4;0]",
	"listring[]",
}

local function updateTableOutput(pos)
	local inv = core.get_meta(pos):get_inventory()

	local count = 0
	for _, item in pairs(inv:get_list(INPUT_LISTNAME)) do
		if not item:is_empty() then
			count = count + 1
		end
	end

	local results = {}
	for result, recipe in pairs(mahiko_crafting.registered_crafts) do
		if count == #recipe and mahiko_crafting.hasNeededItems(result, inv, INPUT_LISTNAME) then
			table.insert(results, result)
		end
	end
	inv:set_stack(OUTPUT_LISTNAME, 1, ItemStack(results[1]))
end

core.register_node("mahiko_crafting:table", {
    description = "Spell Table",
    drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	},
	walkable = true,
	tiles = {
		{
            name = "mahiko_crafting_table_top.png",
			align_style = "world",
			scale = 1,
		},
		{name = "default_stone_block.png"},
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 2},
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", table.concat(formspec, ""))
        local inv = meta:get_inventory()
        inv:set_size(INPUT_LISTNAME, 3 * 3)
        inv:set_size(OUTPUT_LISTNAME, 1)
    end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if player and listname == OUTPUT_LISTNAME then
			return 0
		end
		return stack:get_count()
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if not player then
			return
		end
		if listname == INPUT_LISTNAME then
			return stack:get_count()
		end
		if listname == OUTPUT_LISTNAME then
			local inv = core.get_meta(pos):get_inventory()
			if not mahiko_crafting.hasNeededItems(stack:get_name(), inv, INPUT_LISTNAME) then
				return 0
			end
			local recipe = mahiko_crafting.getRecipe(stack:get_name())
			for _, item in pairs(recipe) do
				inv:remove_item(INPUT_LISTNAME, ItemStack(item))
			end
			return stack:get_count()
		end
		return 0
	end,
	on_metadata_inventory_put = updateTableOutput,
	on_metadata_inventory_take = updateTableOutput,
	on_metadata_inventory_move = updateTableOutput,
	can_dig = function(pos, player)
		local inv = core.get_meta(pos):get_inventory()
		return inv:is_empty(INPUT_LISTNAME)
	end
})