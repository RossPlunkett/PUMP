local Scene = require("lib.Scene")
local U = require("lib.Utils")
local Player = require("entities.Player")
local Gun = require("entities.Gun")
local some_guns = {Gun("pistol", "bb", 1, 0.1, 1, 0, false),Gun("shotgun", "bb", 9, 0.4, 1, 0.9, false),Gun("mega-blaster", "bb", 1, 0.04, 1.4, 0.3, true),}

local T = Scene:derive("Test")
T.do_collisions = require("scenes/scene_funcs/Test_funcs")

function T:new(scene_mgr) 
    T.super.new(self, scene_mgr)

    self.event_funcs = {}
    
    self.event_funcs.add_to_em = function(ent) self.em:add(ent) end
    _G.events:add("add to em")
    _G.events:hook("add to em", self.event_funcs.add_to_em)

    _G.events:add("draw shadows") -- hooked and invoked in Sprite

    
    Player:spawn(1)

    self.alternate_frames = {
        world_collision=2, -- meaning world collisions happen every x frames
        world_collision_counter=0
    }

    Gun:spawn(10)
end



function T:update(dt)
    self.super.update(self,dt)

    T.do_collisions(self)

end


function T:draw()
    love.graphics.clear(0.06,0.2,0)
    self.super.draw(self)
    -- sets color for shadow here
    -- if you want to do a shadow shader, here's where you activate it, before and after the invoke()
    love.graphics.setColor(0, 0, 0, 0.5)
    _G.events:invoke("draw shadows")
    love.graphics.setColor(1, 1, 1, 1)

end


return T
