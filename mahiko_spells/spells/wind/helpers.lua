function mahiko_spells.wind.raycastOnContact(user, func)
    local pos = user:get_pos()
    local props = user:get_properties()
    local dir = user:get_look_dir()
    local yaw = user:get_look_horizontal()
    pos.y = pos.y + props.eye_height*0.9
    pos.x = pos.x + math.cos(yaw)/4
    pos.z = pos.z + math.sin(yaw)/4

    local range, density = 25, 5
    for i=1, range * density do
        core.add_particle({
            pos = {x = pos.x + dir.x * i/density, y = pos.y + dir.y * i/density, z = pos.z + dir.z * i/density},
            expirationtime = 0.35+i/5000,
            size = 0.8,
            vertical = false,
            texture = "mahiko_spells_particle_microburst.png",
            glow = 14,
            jitter = {min = {x = -2, y = -2, z = -2}, max = {x = 2, y = 2, z = 2}}
        })
    end

    local rayend = vector.add(pos, vector.multiply(dir, range))
    local ray = Raycast(pos, rayend, true, false)
    func(ray)
end