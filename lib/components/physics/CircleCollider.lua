local Class = require("lib.Class")

local CC = Class:derive("CircleCollider")

function CC:new(radius)
    self.r = radius
    self.last_d = nil -- to call for closeness if there was a recent collision detected
end

function CC:on_start()
    assert(self.entity.Transform ~=nil, "CircleCollider component requires a Transform component to exist in the attached entity!")
    self.tr = self.entity.Transform
end

-- function CC:update(dt)
-- end
local sqrt = math.sqrt
local pow = math.pow
function CC:CC(transform) -- transform passed in is OTHER transform
    self.tr = self.entity.Transform
    local d = sqrt( pow (self.tr.x - transform.x, 2 ) + pow( self.tr.y - transform.y, 2))
    self.last_d = d
    return d < self.r + transform.entity.CircleCollider.r
end

function CC:get_d()
    return self.last_d
end

function CC:draw()
    -- love.graphics.setColor(1, 1, 1, 1);
    -- love.graphics.circle("line", self.tr.x, self.tr.y, self.r)
end

return CC