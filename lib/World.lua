-- I think this may be bad

local Class = require("lib.Class")

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



