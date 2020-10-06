local Class = require("lib.Class")
local Vector2 = require("lib.Vector2")

local PC = Class:derive("PolygonCollider")

--expects an array of Vector2D objects
--These vertices should be centered around the origin

-- var 1 can be used as tables for vertices
-- but you can also use var1 and var 2 for creating a box with a center in the middle
-- offset - is a vector2
function PC:new(var1,var2,offset)
    local ofst = offset or Vector2(0,0)
    if(type(var1) ~= "number") then
        if(type(var1) ~= "table") then
                assert(true, "Polygon Collider vertices not set")
                return 
            end
        end
    if(type(var1) == "number") and (type(var2) == "number") then
        self.vertices = {
                    Vector2(-1 * (var1/2)+ofst.x,- 1 * (var2/2)+ofst.y),
                    Vector2(1 * (var1/2)+ofst.x, -1 * (var2/2)+ofst.y),
                    Vector2(1 * (var1/2)+ofst.x, 1 * (var2/2)+ofst.y),
                    Vector2(-1 * (var1/2)+ofst.x, 1 * (var2/2)+ofst.y)
                }
    end
    if (type(var1) == "table") then
        self.vertices = var1
    end
    
    --Scaled and translated vertices (we use these for collision detection)
    self.world_vertices = {}
    self.draw_points = {}

    for i = 1, #self.vertices do
        self.world_vertices[#self.world_vertices + 1] = Vector2()
        --there are 2 draw points for every vertex (x,y)
        self.draw_points[#self.draw_points + 1] = 0
        self.draw_points[#self.draw_points + 1] = 0
    end
end
-- i thought LUA supports overloading haha

-- function PC:new(width, height)
--     local h = height or 1
--     local w = width or 1
--     self.vertices = {
--         Vector2(-1 * (h/2),- 1 * (w/2)),
--         Vector2(1 * (h/2), -1 * (w/2)),
--         Vector2(1 * (h/2), 1 * (w/2)),
--         Vector2(-1 * (h/2), 1 * (w/2))
--     }
--     --Scaled and translated vertices (we use these for collision detection)
--     self.world_vertices = {}
--     self.draw_points = {}

--     for i = 1, #self.vertices do
--         self.world_vertices[#self.world_vertices + 1] = Vector2()
--         --there are 2 draw points for every vertex (x,y)
--         self.draw_points[#self.draw_points + 1] = 0
--         self.draw_points[#self.draw_points + 1] = 0
--     end
-- end

function PC:on_start()
    assert(self.entity.Transform ~=nil, "PolygonCollider component requires a Transform component to exist in the attached entity!")
    self.tr = self.entity.Transform
    self:scale_translate()
end

function PC:scale_translate()
    --update the polygon's rotation/scale
    for i = 1, #self.vertices do
        self.world_vertices[i].x = self.vertices[i].x * self.tr.sx
        self.world_vertices[i].y = self.vertices[i].y * self.tr.sy
        self.world_vertices[i]:rotate(self.tr.angle, self.tr.x, self.tr.y)
        
        self.draw_points[1 + 2*(i - 1)] = self.world_vertices[i].x
        self.draw_points[1 + 2*(i - 1) + 1] = self.world_vertices[i].y
    end
end

function PC:update(dt)
    self:scale_translate()
end

function PC:draw()
    if not IsGizmoOn then return end
    love.graphics.setColor(1, 1, 0, 0.6)
    love.graphics.polygon("line", self.draw_points)
end

return PC