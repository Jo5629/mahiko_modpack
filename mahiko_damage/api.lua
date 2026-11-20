local multipliers = {}

function mahiko_damage.getMultiplier(name)
    return multipliers[name]
end

function mahiko_damage.setMultiplier(name, num)
    multipliers[name] = num
end

function mahiko_damage.clearMultiplier(name)
    multipliers[name] = nil
end

function mahiko_damage.punch(receiver, puncher, time_from_last_punch, tool_capabilities, dir)
    --[[
    if not receiver or not puncher then
        return
    end
    ]]

    local mult = mahiko_damage.getMultiplier(puncher:get_player_name()) or 1
    local damageGroups = tool_capabilities.damage_groups
    for gname, num in pairs(damageGroups) do
        local new = num * mult
        tool_capabilities.damage_groups[gname] = new
    end
    receiver:punch(puncher, time_from_last_punch, tool_capabilities, dir)
end

local function particle_texture(name)
	local ret = {name = name}
	if minetest.features.particle_blend_clip then
		ret.blend = "clip"
	end
	return ret
end

local function add_effects(pos, radius)
	minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.4,
		size = radius * 6,
		collisiondetection = false,
		vertical = false,
		texture = particle_texture("tnt_boom.png"),
		glow = 15,
	})
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 4),
		maxpos = vector.add(pos, radius / 4),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius / 2,
		maxsize = radius,
		texture = particle_texture("tnt_smoke.png"),
	})
end

function mahiko_damage.explode(pos, def)
    def = def or {}
    def.radius = def.radius or 1
    --def.damage_groups = def.damage_groups or {}

    local sound = def.sound or "tnt_explode"
	core.sound_play(sound, {pos = pos, gain = 2.5,
		max_hear_distance = math.min(def.radius * 20, 128)}, true)

    add_effects(pos, def.radius)

    local senderObj
    if def.sender then
        senderObj = core.get_player_by_name(def.sender)
    end

    local objects = core.get_objects_inside_radius(pos, def.radius)
    for _, object in pairs(objects) do
        local luaentity = object:get_luaentity()
        if luaentity and luaentity.name:match("__builtin:") then
            goto continue
        end

        local objpos = object:get_pos()
        local dist = math.max(1, vector.distance(pos, objpos))
        local damage = (4 / dist) * def.radius
        if senderObj then
            mahiko_damage.punch(object, senderObj, 1, {
                damage_groups = {fleshy = damage},
            }, nil)
        else
            object:set_hp(object:get_hp() - damage)
        end

        ::continue::
    end
end