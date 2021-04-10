local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Sprite = require("lib.components.Sprite")
local StateMachine = require("lib.components.StateMachine")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")

local Cursor = Class:derive("Cursor")


function Cursor:new()

    
    
    self.properties = {}

    -- state machine at bottom of new, gets entire self... and lasting self? ??? ????? ????? think so
    self.ent_name = "Cursor"
end

function Cursor:spawn(arg)    

    local ent = {
        {"Cursor", arg},
        {"Transform", arg.x, arg.y, 1, 1}
    }
    _G.events:invoke("EF", ent)

end
-- (xoffset, yoffset, w, h, frames, column_size, fps, loop)
function Cursor.create_sprite(atlas)
    -- changed some sprite to squid

    local sprite = Sprite(atlas, 16, 16, nil, true)
    return sprite
end


function Cursor:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
end


function Cursor:update(dt)
    self.machine:update(dt)
    self.pos.x , self.pos.y = love.mouse.getPosition()
end

-- function Cookie:draw()
-- end

--This function responds to a collision event on any of the
-- given sides of the player's collision rect
-- top, bottom, left, right are all boolean values
function Cursor:collided(top, bottom, left, right)
    if bottom then end
    if top then end
    if left then end
    if right then end
end

return Cursor