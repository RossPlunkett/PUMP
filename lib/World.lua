-- I think this may be bad

local Class = require("lib.Class")
<<<<<<< Updated upstream
=======
local World = Class:derive("World")

local mouth_atlas = love.graphics.newImage("assets/gfx/Tiles/Teeth/TEETH_FOREST.png")
local stomach_atlas = love.graphics.newImage("assets/gfx/Tiles/stomach/StomachTiles.png")
local stomach_walls = love.graphics.newImage("assets/gfx/Tiles/stomach/WallTiles.png")




>>>>>>> Stashed changes

local Vector2 = require("lib.Vector2")

local Tree = require("entities.Tree")

local World = Class:derive("World")


function World:new(w, h, cell_width, cell_height, rows, columns)
self.
self.width = w
self.height = h
self.cell_width = cell_width
self.cell_height = cell_height
self.rows = rows
self.columns = columns

self.tiles = {}

for x = 1, self.rows do
    for y = 1, self.columns do
        self.tiles[x][y] = {
            "pos": Vector2(x, y)
        }
    end
end


end

function World:makeWorld()



end

function drawGrid()


end

return World



