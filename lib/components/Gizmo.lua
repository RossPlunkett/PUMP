local Class = require("lib.Class")
local Gizmo = Class:derive("Gizmo")

function Gizmo:new()


end

function Gizmo:on_start()
    self.tr = self.entity.Transform
end

function Gizmo:update(dt)

end

function Gizmo:draw()

    if not IsGizmoOn then return end
    local length = 10

    local x = self.tr.x
    local y = self.tr.y


    love.graphics.setColor(1, 0, 0, GizmoVisibility)
    love.graphics.line(x-length,y, x+length,y)
    love.graphics.line(x,y-length, x,y+length)
    love.graphics.setColor(1, 1, 1, 1)

end


return Gizmo