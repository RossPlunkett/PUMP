local Class = require("lib.Class")
local Vector2 = require("lib.Vector2")

local T = Class:derive("Transform")

function T:new(x, y, sx, sy, angle, vx, vy, yoffset)
    self.x = x or 0
    self.y = y or 0
    self.sx = sx or 1
    self.sy = sy or 1
    self.angle = angle or 0

    -- added some velocity
    self.vx = vx or 0
    self.vy = vy or 0

    self.enabled = true
    self.started = true

    self.y_draw_offset = yoffset or 0
end

function T:VectorPos() return Vector2(self.x, self.y) end

return T