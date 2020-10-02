local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib.Vector2")
local Vector3 = require("lib.Vector3")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")
local SEP = require("lib.components.SEP")
local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")
local StateMachine = require("lib.components.StateMachine")

local Entity = require("lib.Entity")



local MF = Class:derive("MaskFox")

local mask_fox_atlas = love.graphics.newImage("assets/gfx/enchanted_forest.png")





function MF:new(atlas)
    
    if atlas ~= nil then
        self.atlas = atlas
    end

    self.hp = 30
    
    self.base_wander_speed = 200
    
    self.machine = StateMachine(self, "idle")
end



function MF.create_sprite(atlas)
    local idle_anim = Anim(256,32, 32, 32, {1, 2, 3, 4}, 4, {{0.1, 0.1, 0.15, 0.1}, 1})
    local walk_anim = Anim(384,32, 32, 32, {1, 2, 3, 4}, 4, {{0.15, 0.1, 0.1, 0.15}, 1})
    if atlas == nil then
        assert(false, "no atlas supplied to sprite! Also none in self.atlas, so basically no atlases to draw from here. Kapeche?")
    end
    local spr = Sprite(atlas, 32, 32)
    spr:add_animations({idle_anim = idle_anim, walk_anim = walk_anim})
    spr:animate("walk_anim") -- handled by state machine

    return spr
end


function MF:on_start()
    self.transform = self.entity.Transform -- seems to be standar for entities?
    self.sprite = self.entity.Sprite
    self.entity.tag = self
    self.entity.Machine = self.machine
end

function MF:spawn(x, y)

    -- if type(num) == "table" then
    --     -- takes a table of tables of x and y coordinates
    --     -- eg {{100, 234},{-68, 2045}}
 
    -- end

                   
            
        local MF_width = 5
        local MF_length = 7
        local MF_yoffset = 8
        local mask_fox = Entity(
            Transform(x, y, 4, 4, 0),
            self(mask_fox_atlas), 
            self.create_sprite(mask_fox_atlas),
            CC(70,10),
            PC({Vector2(-MF_width,-MF_length + MF_yoffset), Vector2(MF_width,-MF_length + MF_yoffset), Vector2(MF_width,MF_length + MF_yoffset), Vector2(-MF_width, MF_length + MF_yoffset)}),
            SEP(30)
        )
           
            
        _G.events:invoke("add to em", mask_fox)

end

function MF:idle_enter(dt)
    self.sprite:animate("idle_anim")
end

function MF:idle(dt)
    local roll = math.random(100)

    if roll == 54 then
        self.machine:change("wander")
    end
end

function MF:idle_exit(dt)

end

function MF:wander_enter(dt)
    self.sprite:animate("walk_anim")
    self.wander_timer = math.random() * 2
    self.transform.vx = (math.random() * 2) - 1
    self.transform.vy = (math.random() * 2) - 1
    if self.transform.vx >= 0 then
        self.sprite:flip_h(false)
    else
        self.sprite:flip_h(true)
    end
end

function MF:wander(dt)

    self.wander_timer = self.wander_timer - dt

    if self.wander_timer <= 0 then
        self.machine:change("idle")
        return
    end

    self.transform.x = self.transform.x + ((self.transform.vx  * dt) * self.base_wander_speed)
    self.transform.y = self.transform.y + ((self.transform.vy  * dt) * self.base_wander_speed)
end

function MF:wander_exit(dt)

end

function MF:KOed_enter(dt)
    self.entity.Sprite:flash(0.05)
    self.shrink_timer = self.transform.sx
end

function MF:KOed(dt)
    dt = dt / Time.speed
    self.shrink_timer = self.shrink_timer - (dt*20)
    self.transform.sx = self.shrink_timer
    self.transform.sy = self.shrink_timer

    if self.shrink_timer <= 0 then
        self.entity.remove = true
    end
end

function MF:KOed_exit()

end




function MF:update(dt)
    self.machine:update(dt)
end

return MF