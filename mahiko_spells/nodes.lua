local COLORS = mahiko_spells.COLORS
local HEALING_SLAB_RADIUS = 2
local HEALING_SLAB_HP = 2

core.register_node("mahiko_spells:contaminated_dirt", {
	description = "Contaminated Dirt",
	tiles = {"default_dirt.png^[colorize:#00FF00:47"},
	drawtype = "glasslike",
	paramtype = "light",
	drowning = 2,
	walkable = false,
	climbable = false,
	post_effect_color = {r = 49, g = 65, b = 24, a = 245},
	groups = {crumbly = 3, oddly_breakable_by_hand = 2},
	--sounds = default.node_sound_sand_defaults(),
	damage_per_second = 2,
    move_resistance = 13,
	on_timer = function(pos, elapsed, node, timeout)
		core.remove_node(pos)
	end,
	drop = "",
})

core.register_node("mahiko_spells:healing_slab", {
    description = core.colorize(COLORS.HEALING, "Healing Slab"),
    drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	},
	walkable = true,
	tiles = {
		{name = "default_stone_block.png^mahiko_spells_element_healing.png"},
		{name = "default_stone_block.png"},
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1},
	on_timer = function(pos, elapsed, node, timeout)
		local objects = core.get_objects_inside_radius(pos, HEALING_SLAB_RADIUS)
		for _, object in pairs(objects) do
			if not object:is_player() then
				goto continue
			end
			local newHP = object:get_hp() + HEALING_SLAB_HP
			local hpMax = object:get_properties().hp_max
			if newHP > hpMax then
				newHP = hpMax
			end
			object:set_hp(newHP)
		    ::continue::
		end
		return true
	end,
	drop = "",
})