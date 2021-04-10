-- SWA: stomach wall atlas
local SWA = love.graphics.newImage("assets/gfx/Tiles/stomach/WallTiles.png")

local wall_width = 16
local wall_height = 16
local wall_radius = wall_width / 2

-- need data to hold all of the tile attributes and whatnot

local wall_batch = love.graphics.newSpriteBatch(SWA)
--tile 1
local stomach_quads = {}
--offset/overhang will have to come into all four values in creating a new quad
stomach_quads[1] = love.graphics.newQuad(x,y,wall_width,wall_height, 1, 1)
wall_batch:addq(stomach_quads[1])

-- ST: Stomach Tile
-- local ST = require('lib/WallTile')





local Walls = {}

Walls.grid {}

local grid = Walls.grid

local i = 1;
local q = 1;

for i, 100 do
grid[grid + 1] = {}
    for q, 100 do
    grid[grid + 1] = {}
    end
end


-- center point of origin is given for all tiles, and they are thistly imported, along with the various overhangs
-- NOTE: overhangs have to be specific for each frame, as we don't want to 'overhang' into other tiles

-- need a naming convention for the tiles

--[[

TILE 1: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (39, 24);
DATA: {1, 1, 1, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: CENTER

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  1  |
___________________
|     |  1  |     |
___________________


--------------------------------------------------
--------------------------------------------------

TILE 2: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (15, 24);
DATA: {0, 1, 1, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: TOP-LEFT

GRID: 
___________________
|     |  0  |     |
___________________
|  0  |  1  |  1  |
___________________
|     |  1  |     |
___________________


--------------------------------------------------
--------------------------------------------------
TILE 3: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (15, 40);
DATA: {1, 1, 0, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: BOTTOM-LEFT

GRID: 
___________________
|     |  1  |     |
___________________
|  0  |  1  |  1  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 4: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (63, 16);
DATA: {0, 0, 1, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: TOP SOLO

GRID: 
___________________
|     |  0  |     |
___________________
|  0  |  1  |  0  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------

TILE 5: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (63, 32);
DATA: {1, 0, 0, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: BOTTOM SOLO

GRID: 
___________________
|     |  1  |     |
___________________
|  0  |  1  |  0  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------

TILE 6: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (87, 24);
DATA: {0, 0, 1, 1}
OVERHANG: (0, 0, 1, 1)

CASUAL: TOP RIGHT

GRID: 
___________________
|     |  0  |     |
___________________
|  1  |  1  |  0  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------

TILE 7: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (87, 40);
DATA: {1, 0, 0, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: BOTTOM RIGHT

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  0  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------

TILE 8: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (119, 32);
DATA: {1, 0, 1, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT RIGHT-FACING SIDE 1

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  0  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------

TILE 9: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (119, 48);
DATA: {1, 0, 1, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT RIGHT-FACING SIDE 2

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  0  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 10: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (151, 32);
DATA: {1, 1, 1, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT LEFT-FACING SIDE 1

GRID: 
___________________
|     |  1  |     |
___________________
|  0  |  1  |  1  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 11: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (151, 48);
DATA: {1, 1, 1, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT LEFT-FACING SIDE 2

GRID: 
___________________
|     |  1  |     |
___________________
|  0  |  1  |  1  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 12: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (176, 27);
DATA: {0, 1, 1, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT UP-FACING SIDE 1

GRID: 
___________________
|     |  0  |     |
___________________
|  1  |  1  |  1  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 13: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (192, 27);
DATA: {0, 1, 1, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT UP-FACING SIDE 2

GRID: 
___________________
|     |  0  |     |
___________________
|  1  |  1  |  1  |
___________________
|     |  1  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 14: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (176, 52);
DATA: {1, 1, 0, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT DOWN-FACING SIDE 1

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  1  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 15: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (192, 52);
DATA: {1, 1, 0, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: FLAT DOWN-FACING SIDE 2

GRID: 
___________________
|     |  1  |     |
___________________
|  1  |  1  |  1  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 16: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (217, 24);
DATA: {0, 0, 0, 1}
OVERHANG: {0, 0, 0, 0}

CASUAL: RIGHT-FACING SOLO

GRID: 
___________________
|     |  0  |     |
___________________
|  1  |  1  |  0  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------


TILE 17: 
-- overhang and data: {TOP, RIGHT, BOTTOM, LEFT}
ORIGIN: (221, 52);
DATA: {0, 1, 0, 0}
OVERHANG: {0, 0, 0, 0}

CASUAL: LEFT-FACING SOLO

GRID: 
___________________
|     |  0  |     |
___________________
|  0  |  1  |  1  |
___________________
|     |  0  |     |
___________________

--------------------------------------------------
--------------------------------------------------

]]



return Walls