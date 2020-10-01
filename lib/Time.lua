local Class = require("lib.Class")

local Time = Class:derive("Time")

function Time:new()
    self.speed = 1
    self.speed_cancel = false

    self.freeze_frames = 0

end

function Time:getDt(dt)
    -- could update music below?
    local the_dt
    if not self.speed_cancel then
        the_dt = dt * self.speed
    else
        the_dt = dt
    end
    self.dt = the_dt
    return the_dt
end

function Time:update(dt)


end

function Time:setSpeed(val)

    self.speed = val

end

return Time