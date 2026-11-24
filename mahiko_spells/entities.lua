local NODE_BOX_DEFAULT = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}

core.register_entity("mahiko_spells:node_explosive", {
    visual = "node",
    node = {name = "air"},
    physical = true,
    pointable = true,
    static_save = false,
    collisionbox = NODE_BOX_DEFAULT,
    selectionbox = NODE_BOX_DEFAULT,
    visual_size = {x = 1, y = 1},
    activate = function(self, node, velocity, timer)
        self:setNode(node)
        self._timer = timer
        self.object:set_velocity(velocity)
        self.object:set_acceleration(vector.new(0, -5, 0))
    end,
    setNode = function(self, node)
        local def = core.registered_nodes[node.name]
        self.object:set_properties({
            node = node,
            glow = def.light_source,
        })
    end,
    on_step = function(self, dtime, moveresult)
        local object = self.object
        if not self._timer then
            object:remove()
            return
        end
        local pos = object:get_pos()
        if moveresult then
            for _, collision in pairs(moveresult.collisions) do
                local ctype = collision.type
                if ctype == "node" or ctype == "object" then
                    self:explode(pos)
                    return
                end
            end
        end
        --object:set_velocity(self._velocity)
        self._timer = self._timer - dtime
        if self._timer <= 0 then
            self:explode(self.object:get_pos())
            return
        end
    end,
    explode = function(self, pos)
        self.object:remove()
        mahiko_damage.explode(pos, {
            radius = 4,
        })
    end,
})

core.register_entity("mahiko_spells:fired_up", {
    --physical = true,
    --collide_with_objects = false,
    visual = "sprite",
    textures = {"mahiko_spells_element_fire.png"},
    is_visible = false,
    static_save = false,
    collisionbox = {-0.3, -0.2, -0.3, 0.3, 0, 0.3},
    on_activate = function(self, staticdata, dtime_s)
        self.timer = 0
    end,
    on_step = function(self, dtime, moveresult)
        self.timer = self.timer + dtime
        if self.timer < 0.1 then
            return
        end
        self.timer = 0

        local object = self.object
        local attached = self.attached
        if not attached then
            object:remove()
            return
        end

        local player = core.get_player_by_name(attached)
        if not player then
            object:remove()
            return
        end

        local dir = player:get_look_dir()
        local ppos = player:get_pos()

        local offset = vector.multiply(dir, 3)
        offset.x = math.clamp(offset.x, -1, 1)
        offset.y = math.clamp(offset.y, -1, 1)
        offset.z = math.clamp(offset.z, -1, 1)

        local newpos = ppos - offset
        newpos.y = ppos.y + 0.15
        if core.get_node(newpos).name == "air" then
            core.place_node(newpos, {name = "fire:basic_flame"})
        end
    end
})

core.register_entity("mahiko_spells:fireball", {
    visual = "sprite",
    textures = {"mahiko_spells_fireball.png"},
    physical = true,
    pointable = true,
    static_save = false,
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
    --selectionbox = NODE_BOX_DEFAULT,
    visual_size = {x = 1, y = 1},
    activate = function(self, velocity, timer)
        self.object:set_velocity(velocity)
        self._timer = timer
    end,
    on_step = function(self, dtime, moveresult)
        local object = self.object
        if not self._timer then
            object:remove()
            return
        end
        local pos = object:get_pos()
        if moveresult then
            for _, collision in pairs(moveresult.collisions) do
                local ctype = collision.type
                if ctype == "node" or ctype == "object" then
                    self:explode(pos)
                    return
                end
            end
        end
        self._timer = self._timer - dtime
        if self._timer <= 0 then
            self:explode(self.object:get_pos())
            return
        end
    end,
    explode = function(self, pos)
        local sender = self.sender
        self.object:remove()
        mahiko_damage.explode(pos, {
            radius = 3,
            sender = sender or nil,
        })
    end,
})

--[[
core.register_entity("mahiko_spells:node", {
    visual = "node",
    node = {name = "air"},
    physical = true,
    pointable = true,
    static_save = false,
    collisionbox = NODE_BOX_DEFAULT,
    selectionbox = NODE_BOX_DEFAULT,
    visual_size = {x = 1, y = 1},
    activate = function(self, node, velocity, timer, step)
        self:setNode(node)
        self._velocity = velocity
        self._timer = timer
        self._step = step
    end,
    setNode = function(self, node)
        local def = core.registered_nodes[node.name]
        self.object:set_properties({
            node = node,
            glow = def.light_source,
        })
    end,
    on_step = function(self, dtime, moveresult)
        if not self._velocity or not self._timer then
            self.object:remove()
            return
        end
        self.object:set_velocity(self._velocity)
        self._timer = self._timer - dtime
        if self._timer <= 0 then
            self.object:remove()
        end
        if self._step then
            self._step(self, dtime, moveresult)
        end
    end,
})
]]