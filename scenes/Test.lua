local Scene = require("lib.Scene")
local U = require("lib.Utils")
-- local some_guns = {Gun("pistol", "bb", 1, 0.1, 1, 0, false),Gun("shotgun", "bb", 9, 0.4, 1, 0.9, false),Gun("mega-blaster", "bb", 1, 0.04, 1.4, 0.3, true),}

local T = Scene:derive("Test")
T.do_collisions = require("scenes/scene_funcs/Test_funcs")

local world = require("lib.World")
local World = world(32, 32, 90, 40)
-- World:print()

function T:new(scene_mgr) 
    T.super.new(self, scene_mgr)

    self.event_funcs = {}
    
    self.event_funcs.add_to_em = function(ent) self.em:add(ent) end
    _G.events:add("add to em")
    _G.events:hook("add to em", self.event_funcs.add_to_em)

  

    --spawn players
    _G.events:invoke("EF_spawn", "Cookie", {player_num = 1, x = 350, y = 380, control_scheme = "Gamepad"})
    _G.events:invoke("EF_spawn", "Candy", {player_num = 2, x = 350, y = 340, control_scheme = "Keyboard"})
    _G.events:invoke("EF_spawn", "cc2f7b", {player_num = 3, x = 320, y = 360})
    _G.events:invoke("EF_spawn", "Flour", {player_num = 2, x = 390, y = 360})
    _G.events:invoke("EF_spawn", "Vase", {player_num = 5, x = 490, y = 290})


    self.alternate_frames = {
        world_collision=2, -- meaning world collisions happen every x frames
        world_collision_counter=0
    }

    -- EF is for Entity Factory          x    y
    _G.events:invoke("EF_spawn", "Uzi", {x = 420, y = 400})
    _G.events:invoke("EF_spawn", "Revolver", {x = 400, y = 420})
    _G.events:invoke("EF_spawn", "PumpAction", {x = 400, y = 440})
    _G.events:invoke("EF_spawn", "Ak47", {x = 400, y = 460})
    _G.events:invoke("EF_spawn", "Ak47", {x = 400, y = 490})
    _G.events:invoke("EF_spawn", "M16", {x = 440, y = 420})
    _G.events:invoke("EF_spawn", "MagnumRevolver", {x = 440, y = 450})
    _G.events:invoke("EF_spawn", "PopGun", {x = 360, y = 450})
    _G.events:invoke("EF_spawn", "RustyPeacekeeper", {x = 460, y = 350})
end



function T:update(dt)
    self.super.update(self,dt)


    T.do_collisions(self)

end

function T:draw()
    love.graphics.clear(0.2588,0.5647,0.34509) -- stomach bg color
    World:draw();
    self.super.draw(self)
    -- World:drawGrid()
    love.graphics.print("entities: " .. #self.em.entities,Camera.x + 5,Camera.y + 25)
end


return T
