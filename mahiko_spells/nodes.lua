local COLORS = mahiko_spells.COLORS
local HEALING_SLAB_RADIUS = 2
local HEALING_SLAB_HP = 2

local function resistantNode(name, def)
	name = "mahiko_spells:" .. name
	def.drawtype = "glasslike"
	def.paramtype = "light"
	def.drowning = 2
	def.walkable = false
	def.climbable = false
	def.drop = def.drop or ""
	def.on_timer = def.on_timer or function(pos)
		core.remove_node(pos)
	end

	core.register_node(name, def)
end

resistantNode("contaminated_dirt", {
	description = "Contaminated Dirt",
	tiles = {"default_dirt.png^[colorize:#00FF00:47"},
	post_effect_color = {r = 49, g = 65, b = 24, a = 245},
	groups = {crumbly = 3, oddly_breakable_by_hand = 2},
	damage_per_second = 2,
	move_resistance = 13,
})

resistantNode("powdered_snow", {
	description = "Powdered Snow",
	--tiles = {"default_snow.png^[colorize:#1C809F:47"},
	tiles = {"default_snow.png^(default_ice.png^[opacity:84)"},
	post_effect_color = {r = 226, g = 235, b = 240, a = 245},
	groups = {crumbly = 2, oddly_breakable_by_hand = 1},
	damage_per_second = 1,
	move_resistance = 30,
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