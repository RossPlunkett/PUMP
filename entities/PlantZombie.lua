local Class = require("lib.Class") -- require Lua class module
local Anim = require("lib.Animation") -- require the animation class
local Vector2 = require("lib.Vector2") -- require Vec2 class
local Vector3 = require("lib.Vector3") -- require Vec3 class

local CC = require("lib.components.physics.CircleCollider") -- circle collider
local PC = require("lib.components.physics.PolygonCollider") -- polygon collider

local SEP = require("lib.components.SEP") -- standard entity properties that all entities share

local Sprite = require("lib.components.Sprite") -- sprite class
local Transform = require("lib.components.Transform") -- transform contains position/angle/speed
local StateMachine = require("lib.components.StateMachine") -- state machine class

local Entity = require("lib.Entity") -- entity class

local Gun = require("entities.Gun") -- gun class, for spawning




local PZ = Class:derive("PlantZombie")

local plant_zombie_atlas = love.graphics.newImage("assets/gfx/grfxkid/dungeon_set/plant_zombie_sheet.png")





function PZ:new(atlas)
    
    if atlas then
        self.atlas = atlas
    end

    self.hp = 30
    
    self.base_wander_speed = 100
    
    self.machine = StateMachine(self, "idle")
end



function PZ.create_sprite(atlas)
    local idle_anim = Anim(0,0, 32, 64, {1, 2, 3, 4}, 4, {{0.1, 0.1, 0.15, 0.1}, 1})
    local walk_anim = Anim(128,0, 32, 64, {1, 2, 3, 4}, 4, {{0.15, 0.1, 0.1, 0.15}, 1})
    if atlas == nil then
        assert(false, "no atlas supplied to sprite! Also none in self.atlas, so basically no atlases to draw from here. Kapeche?")
    end
    local spr = Sprite(atlas, 32, 64)
    spr:add_animations({idle_anim = idle_anim, walk_anim = walk_anim})
    spr:animate("walk_anim") -- handled by state machine

    return spr
end

function PZ:equip_gun(gun)
    if self.equipped_gun ~= nil then
        self.equipped_gun:unequip()
    end
    self.equipped_gun = gun
    self.equipped_gun:equip(self.entity) -- gives self os gun knows who's holding it
end

function PZ:on_start()
    self.transform = self.entity.Transform -- seems to be standard for entities?
    self.sprite = self.entity.Sprite -- seems to be standard as well?
    self.entity.tag = self -- don't think this works
    self.entity.Machine = self.machine -- hmm







end


function PZ:spawn(x, y)

    -- if type(num) == "table" then
    --     -- takes a table of tables of x and y coordinates
    --     -- eg {{100, 234},{-68, 2045}}
 
    -- end

                   
            
        local zombie_length = 9
        local zombie_width = 9
        local zombie = Entity(
            Transform(x, y, 4, 4, 0),
            PZ(plant_zombie_atlas), 
            self.create_sprite(plant_zombie_atlas),
            CC(70,40),
            PC({Vector2(-zombie_length,-zombie_width), Vector2(zombie_length,-zombie_width), Vector2(zombie_length,zombie_width), Vector2(-zombie_length, zombie_width)}),
            SEP(30)
        )
           
            
        _G.events:invoke("add to em", zombie)

end

function PZ:idle_enter(dt)
    self.sprite:animate("idle_anim")
end

function PZ:idle(dt)
    local roll = math.random(100) -- should incorporate dt

    if roll == 54 then
        self.machine:change("wander")
    end
end

function PZ:idle_exit(dt)

end

function PZ:wander_enter(dt)

    if not self.equipped_gun then
        self:equip_gun(Gun:spawn(1).Gun);
    end


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

function PZ:wander(dt)

    self.wander_timer = self.wander_timer - dt

    if self.wander_timer <= 0 then
        self.machine:change("idle")
        return
    end

    self.transform.x = self.transform.x + ((self.transform.vx  * dt) * self.base_wander_speed)
    self.transform.y = self.transform.y + ((self.transform.vy  * dt) * self.base_wander_speed)
end

function PZ:wander_exit(dt)

end

function PZ:KOed_enter(dt)
    self.entity.Sprite:flash(0.05)
    self.shrink_timer = self.transform.sx
end

function PZ:KOed(dt)
    
    self.equipped_gun.entity.remove = true

    dt = dt / Time.speed
    self.shrink_timer = self.shrink_timer - (dt * 20)
    self.transform.sx = self.shrink_timer
    self.transform.sy = self.shrink_timer

    if self.shrink_timer <= 0 then
        self.entity.remove = true
    end
end

-- no KOed exit function, done at end of KOed


function PZ:update(dt)
    self.machine:update(dt)


    if self.equipped_gun then
        self.equipped_gun.entity.Transform.x = self.entity.Transform.x + 1
        self.equipped_gun.entity.Transform.y = self.entity.Transform.y + 1
    end
end

return PZ