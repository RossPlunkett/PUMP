local Class = require("lib.Class")
local Shadow = Class:derive("Shadow")

function Shadow:new(yoffset, angle, flip)

    assert(yoffset, "Yoffset must be applied to Shadow:new()!")
    self.yoffset = yoffset
    self.OG_yoffset = yoffset -- for returning it after its snapped
    self.angle = angle
    self.flipped = flip or 1 -- turn to -1 to un-flip shadow
    
end

function Shadow:on_start()
    self.sprite = self.entity.Sprite
    -- _G.events:hook("draw shadows", function() self:drawShadow() end)
end

function Shadow:flip(flip)
    -- flip is 1 or -1, 1 is flipped by default
    if not flip then 
        self.flipped = -self.flipped
    else
        self.flipped = flip
    end
end

-- function Shadow:update(dt)
--     -- gotta move this somewhere
--     if self.entity.equipped then
--         self.yoffset = 3
--     else
--         self.yoffset = self.OG_yoffset
--     end
-- end

function Shadow:drawShadow()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.draw(self.sprite.atlas, self.sprite.quad, self.sprite.tr.x, self.sprite.tr.y + (self.sprite.h/2) + self.yoffset, self.sprite.tr.angle ,  self.sprite.flip.x * self.entity.Transform.sx, self.flipped * -self.sprite.flip.y * self.entity.Transform.sy, self.sprite.origin.x, self.sprite.origin.y)
    love.graphics.setColor(1, 1, 1, 1)
end


return Shadow