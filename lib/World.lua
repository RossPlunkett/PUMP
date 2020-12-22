
local Class = require("lib.Class")
local World = Class:derive("World")

local mouth_atlas = love.graphics.newImage("assets/gfx/Tiles/Teeth/TEETH_FOREST.png")
local stomach_atlas = love.graphics.newImage("assets/gfx/Tiles/stomach/StomachTiles.png")
-- need to manually make some quads?



local Vector2 = require("lib.Vector2")


function World:new(cell_width, cell_height, rows, columns)
    self.cell_width = cell_width
    self.cell_height = cell_height
    self.rows = rows
    self.columns = columns
    self.width = cell_width * columns
    self.height = cell_height * rows

    -- tiles attach directly as the 'ipairs' numerically indexed part of [World]
    -- World[4][35] ::: tile at fourth column, thirty-fifth row
    -- World[X][Y]

    -- initiate numerically indexed tables
    for x = 1, self.rows do
        self[x] = {}
        for y = 1, self.columns do
            self[x][y] = {}
            local tile = self[x][y]
                -- store the position locally in the table
                -- .pos seems dumb, but a transform is overkill
            tile.grid_pos = Vector2(x, y)
            tile.world_pos = Vector2((x - 1) * self.cell_width, (y - 1) * self.cell_height)

            tile.rotation = 1.5708 * ((math.ceil(math.random()*4)));
            
        end
    end

    -- need quite a few more quads
    self.first_quad = love.graphics.newQuad(0, 32, 96, 96, stomach_atlas:getDimensions())
    self.second_quad = love.graphics.newQuad(0, 32, 32, 32, stomach_atlas:getDimensions())

end

function World:create()

end

function World:drawGrid()

    for x = 1, self.rows + 1 do -- + 1's to complete grid
        for y = 1, self.columns + 1 do
            --vertical lines
            love.graphics.line((x-1) * self.cell_width,0,(x-1) * self.cell_width,self.height)
            -- horizontal lines
            love.graphics.line(0, (y-1) * self.cell_height,self.width,(y-1) * self.cell_height)

        end
    end

end

function World:print()

    -- these are options for what gets printed
    local tile_marker = true
    local grid_pos = true
    local world_pos = true

    for x = 1, self.rows do
        for y = 1, self.columns do
            if tile_marker then
                print("***\n***\nIN TILE: ", x, y, "\n***\n***")
            end
            if grid_pos then
                print("printing grid position...\n", self[x][y].grid_pos.x, self[x][y].grid_pos.y) 
            end
            if world_pos then
                print("printing world position (origin top left)...\n", self[x][y].world_pos.x, self[x][y].world_pos.y) 
            end
        end
    end

end

-- 0.793 w/out, 
-- 0.661 w/out
-- 0.343 , 41 calls
function World:draw()
    love.graphics.setShader() -- band-aid, don't know why world is picking up flash shader
    -- love.graphics.draw(stomach_atlas, self.first_quad,-50,-50,0,1,1)
    local draw = love.graphics.draw
    for x = 1, self.rows do
        for y = 1, self.columns do
            draw(stomach_atlas, self.first_quad, self[x][y].world_pos.x,self[x][y].world_pos.y,self[x][y].rotation,1,1)
        end
    end
end

return World



