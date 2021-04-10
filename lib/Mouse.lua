local Mouse = {}

function Mouse:update(dt)
    local one = love.mouse.isDown(1)
    local two = love.mouse.isDown(2)
    local three = love.mouse.isDown(3)
    self[1], self[2], self[3] = one, two, three
    self.x, self.y = love.mouse.getPosition() -- get the position of the mouse
    -- print("mouse pos: ", self.x, self.y)
end

return Mouse