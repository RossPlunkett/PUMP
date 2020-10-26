local Class = require("lib.Class")
local Shadow = Class:derive("Shadow")

function Shadow:new(yoffset, angle)

    self.yoffset = yoffset
    self.angle = angle
    
end

function Shadow:on_start()
    self.sprite = self.entity.Sprite
    _G.events:hook("draw shadows", function() self:drawShadow() end)
end

function Shadow:update(dt)
end

function Shadow:drawShadow()
    print("shadow")
    love.graphics.draw(self.sprite.atlas, self.sprite.quad, self.sprite.tr.x, self.sprite.tr.y + self.sprite.h + (self.sprite.h/2) + 200 , self.sprite.tr.angle ,  self.sprite.flip.x, -self.sprite.flip.y, self.sprite.origin.x, self.sprite.origin.y)
end


return Shadow