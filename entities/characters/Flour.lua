local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Sprite = require("lib.components.Sprite")
local StateMachine = require("lib.components.StateMachine")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")

local PLAYER = require('classes.forms.fPLAYER')
local Flour = PLAYER:derive("Flour")


function Flour:new(arg)

    assert(arg.player_num ~= nil, "Player number not given to player form")
    self.player_num = arg.player_num
    
    if arg.control_scheme then self.control_scheme = arg.control_scheme end

    self.properties = {}
    self.properties.base_walk_speed = 150 -- value to be multiplied by dt to get number of pixels to move

    -- state machine at bottom of new, gets entire self... and lasting self? ??? ????? ????? think so
    self.machine = StateMachine(self, "idle")
    self.ent_name = "Flour"
end

function Flour:spawn(arg)
    
    local ent = {
        {"Transform", arg.x, arg.y, 1, 1},
        {"Flour", arg},
        {"CC", 19, 32},
        {"PC", 15, 16, Vector2(0,2)},
        {"Shadow", 9}
    }

    
    ent.ent_class = "PLAYER"

    _G.events:invoke("EF", ent)

end
-- (xoffset, yoffset, w, h, frames, column_size, fps, loop)
function Flour.create_sprite(atlas)
    -- changed some sprite to squid
    local idle = Anim(0, 0, 20, 20, {1, 2, 3, 4, 5}, 18, {{0.15, 0.15, 0.15, 0.15, 0.15}, 2})
    local walk = Anim(0, 0, 20, 20,{6, 7, 8, 9, 10, 11, 12, 13, 14}, 18, {{0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15}, 2})

    --create a sprite component to return to enclosing function
    local sprite = Sprite(atlas, 20, 20, nil, true)
    sprite:add_animations({idle = idle, walk = walk})
    return sprite
end


function Flour:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.Machine = self.machine
    self.entity.form = self
    
    local arg = {
        hp=20
    }

    self.entity:PLAYER_init(arg)

end

function Flour:idle_enter(dt)
    self.sprite:animate("idle")
end

function Flour:update(dt)
    self.machine:update(dt)

end

-- function Flour:draw()
-- end

--This function responds to a collision event on any of the
-- given sides of the player's collision rect
-- top, bottom, left, right are all boolean values
function Flour:collided(top, bottom, left, right)
    if bottom then end
    if top then end
    if left then end
    if right then end
end

return Flour