local Class = require("lib.Class")
local Shadow = Class:derive("Shadow")

local sprite_shadow
function Shadow:new(xo, yo)

    self.enabled = true
    self.priority = 0

    self.xoffset = xo
    self.yoffset = yo
end

function Shadow:on_start()
    sprite_shadow = self.entity.Sprite
end

function Shadow:update(dt)
end

function Shadow:draw()
    -- love.graphics.setColor(0, 0, 0, 0.5)
    -- love.graphics.circle("fill",self.entity.Transform.x + self.xoffset,self.entity.Transform.y + self.yoffset,20)

end


return Shadow