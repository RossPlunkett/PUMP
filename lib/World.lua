-- I think this may be bad

local Class = require("lib.Class")

local World = Class:derive("world")

local Tree = require("entities.Tree")
local PlantZombie = require("entities.PlantZombie")
local MaskFox = require("entities.MaskFox")

function World:new(x_start, y_start, width, height)

    self.x_start = x_start
    self.y_start = y_start
    self.width = width
    self.height = height

    self.grid = {}

    self:makeGrid(100)

    self.diggers = {}
    self.total_digs = 0


end

function World:makeGrid(cell_size)

    self.cell_size = cell_size

    if self.width % cell_size ~= 0 or self.height % cell_size ~=0 then
        assert(false, "cells don't fit snugly into the world size!")
    end

    
    self.cell_rows = self.width / self.cell_size
    self.cell_columns = self.height / self.cell_size
    
    self.grid = {}
    for i = 1, self.cell_rows do
        self.grid[#self.grid + 1] = {}
        for q = 1, self.cell_columns do
            self.grid[i][#self.grid[i] + 1] = 0 -- 0 for empty
        end
    end
end

function World:makeDigger()

    local digger = {}
    digger.x = math.random(self.cell_rows - 2) + 1
    digger.y = math.random(self.cell_columns - 2) + 1
    digger.direction = {0, 0}
    if math.random(4) == 1 then
        digger.direction = {1, 0}
    elseif math.random(4) == 1 then
        digger.direction = {-1, 0}
    elseif math.random(4) == 1 then
        digger.direction = {0, 1}
    elseif math.random(4) == 1 then
        digger.direction = {0, -1}
    end
    
    digger.remove = false -- removal flag
    digger.death_chance = 0.01 -- percent
    digger.turn_chance = 0.7

    table.insert(self.diggers, digger)

end

-- function World:dig()

--     self.total_digs = 0

--     -- for i = 1, 10 do
--     --     self:makeDigger()
--     -- end





--     -- if it turns out to be easier to dig after moving, do one initial dig with each digger here

--     while (#self.diggers > 0) do
--         for i = #self.diggers, 1, -1 do
--             local digger = self.diggers[i]

--             if (math.random() <= digger.death_chance)
--             then
--                 table.remove(self.diggers, i)
--                 break
--             end

--             if (digger.x <= 1 or digger.x >= self.cell_rows)
--             or (digger.y <= 1 or digger.y >= self.cell_columns)
--             then
--                 table.remove(self.diggers, i)
--                 break
--             end
            
--             if (math.random() <= digger.turn_chance) then
--                 if digger.direction[1] ~= 0 then
--                     digger.direction[1] = 0
--                     local dir = math.random()
--                     if dir >= 0.5 then
--                         digger.direction[2] = -1
--                     else
--                         digger.direction[2] = 1
--                     end
--                 elseif digger.direction[2] ~= 0 then
--                     digger.direction[2] = 0
--                     local dir = math.random()
--                     if dir >= 0.5 then
--                         digger.direction[1] = -1
--                     else
--                         digger.direction[1] = 1
--                     end
--                 end
--             end

--             self.grid[digger.x][digger.y] = 0 -- dig
--             self.total_digs = self.total_digs + 1

--             if digger.direction[1] ~= 0 then
--                 digger.x = digger.x + digger.direction[1]
--             elseif digger.direction[2] ~= 0 then
--                 digger.y = digger.y + digger.direction[2]
--             end
--         end
--     end
-- end

function World:treeOutline()

    for i = 1, self.cell_columns do
        self.grid[1][i] = 1
        self.grid[self.cell_rows][i] = 1
    end

    for i = 1, self.cell_rows do
        self.grid[i][1] = 1
        self.grid[i][self.cell_columns] = 1
    end

end

function World:plantSomeTrees(plant_chance)

    for i = 1, self.cell_rows do
        for q = 1, self.cell_columns do
            if self.grid[i][q] == 0 then
                if math.random() <= plant_chance then
                    self.grid[i][q] = 1
                end
            end
        end
    end


end

--TODO: work with tree collider
--TODO: clean up level generation
--TODO: only do collisions on exposed trees

function World:spawn_trees()
    local i, q
    for i = 1, self.cell_rows do
        for q = 1, self.cell_columns do
            if self.grid[i][q] == 1 then
                local random_x_offset = math.random() * 30 - 15
                local random_y_offset = math.random() * 30 - 15
                local x_pos, y_pos
                local row_offset

                row_offset = self.cell_size*0.5

                x_pos = self.x_start + ((i - 1) * self.cell_size) + row_offset + random_x_offset
                y_pos = self.y_start + ((q - 1) * self.cell_size) + row_offset + random_y_offset
                Tree:spawn(x_pos, y_pos)
            end
        end
    end

end

function World:make_zombies(num)
    local open_spots = {}

    for i = 1, self.cell_rows do
        for q = 1, self.cell_columns do
            if self.grid[i][q] == 0 then
                local random_x_offset = math.random() * 30 - 15
                local random_y_offset = math.random() * 30 - 15
                local x_pos, y_pos
                x_pos = self.x_start + ((i - 1) * self.cell_size) + (self.cell_size*0.5) + random_x_offset
                y_pos = self.y_start + ((q - 1) * self.cell_size) + (self.cell_size*0.5) + random_y_offset
                table.insert(open_spots, {x_pos, y_pos})
            end
        end
    end

    for x = 1, num do

        local spot = open_spots[math.random(#open_spots)]
        PlantZombie:spawn(spot[1], spot[2])
        MaskFox:spawn(spot[1], spot[2])

    end
    


end


local fill_blocks = true -- fills in wall area
function World:drawGrid()

    love.graphics.setColor(0, 0, 0, 1)
    if #self.grid > 0 then
        for i = 1, self.cell_rows + 1 do
            love.graphics.line(self.x_start,self.y_start + ((i - 1) * self.cell_size),self.x_start + self.width, self.y_start + ((i - 1) * self.cell_size))
        end
        for i = 1, self.cell_columns + 1 do
            love.graphics.line(self.x_start + ((i - 1) * self.cell_size),self.y_start,self.x_start + ((i - 1) * self.cell_size), self.y_start + self.height)
        end
    end

    if fill_blocks then
    love.graphics.setColor(0, 0, 0, 0.75)
    for i = 1, self.cell_rows do
        for q = 1, self.cell_columns do
            if self.grid[i][q] == 1 then
                love.graphics.rectangle("fill",self.x_start + ((i - 1) * self.cell_size),self.y_start + ((q - 1) * self.cell_size),self.cell_size,self.cell_size)
            end
        end
    end
    end

end


return World