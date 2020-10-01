local Class = require("lib.Class")
local Shadow = Class:derive("Shadow")

function Shadow:new(w, h, xo, yo)

    self.enabled = true
    self.priority = 0

    self.xoffset = xo
    self.yoffset = yo
end

function Shadow:on_start()


end

function Shadow:update(dt)

end

function Shadow:draw()
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.circle("fill",self.entity.Transform.x + self.xoffset,self.entity.Transform.y + self.yoffset,20)

end


return Shadow