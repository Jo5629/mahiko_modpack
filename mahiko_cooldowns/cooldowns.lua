local api = {}
local Builder = {}

function api.init()
    return Builder:new()
end

function Builder:new()
    local o = {
        cooldowns = {},
        params = {},
        timersRunning = 0,
        cachedRemovals = {},
    }

    setmetatable(o, self)
    self.__index = self
    return o
end

function Builder:start(name, num, params)
    if not self:exists(name) then
        params = params or {}
        self:set(name, num)
        self.params[name] = params
        self.timersRunning = self.timersRunning + 1
        return true
    end
    return false
end

function Builder:stop(name)
    if self:exists(name) then
        self.cooldowns[name] = nil
        self.params[name] = nil
        self.timersRunning = self.timersRunning - 1
        return true
    end
    return false
end

function Builder:cancel(name)
    local params = self.params[name]
    local cancel = params.cancel
    self:stop(name)
    if type(cancel) == "function" then
        cancel(name, params)
    end
end

function Builder:set(name, num)
    self.cooldowns[name] = num
end

function Builder:get(name)
    return self.cooldowns[name]
end

function Builder:exists(name)
    local timeLeft = self:get(name)
    if timeLeft == nil then
        return false
    end
    return true
end

function Builder:update(dtime, step)
    step = step or false
    if self.timersRunning < 1 then
        return
    end
    for name, time in pairs(self.cooldowns) do
        if step then
            local params = self.params[name]
            local newparams = params.step(name, dtime, params)
            if newparams then
                self.params[name] = newparams
            end
        end
        local newTime = time - dtime
        if newTime <= 0 then
            table.insert(self.cachedRemovals, name)
            newTime = 0
        end
        self:set(name, newTime)
    end
end

function Builder:clearCachedTimers()
    for _, name in pairs(self.cachedRemovals) do
        if self:exists(name) then
            local params = self.params[name]
            local finish = params.finish
            self:stop(name)
            if type(finish) == "function" then
                finish(name, params)
            end
        end
    end
    self.cachedRemovals = {}
end

function Builder:iterate(f)
    if self.timersRunning < 1 then
        return
    end
    for name, timeLeft in pairs(self.cooldowns) do
        f(name, timeLeft, self.params[name])
    end
end

return api