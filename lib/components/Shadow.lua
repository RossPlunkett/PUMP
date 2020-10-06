local Class = require("lib.Class")
local Shadow = Class:derive("Shadow")

function Shadow:new(yoffset, angle)

    self.yoffset = yoffset
    self.angle = angle

end

function Shadow:on_start()
    sprite_shadow = self.entity.Sprite
end

function Shadow:update(dt)
end

function Shadow:draw()
-- shadow is drawn in draw() in lib -> components -> Sprite
end


return Shadow