local Class = require("lib.Class") -- require Lua class module
local Vector2 = require("lib.Vector2") -- require Vec2 class
local Anim = require("lib.Animation")
local Sprite = require("lib.components.Sprite")
local StateMachine = require("lib.components.StateMachine") -- state machine class



local PZ = Class:derive("PlantZombie")



function PZ:new(atlas)
    
    if atlas then
        self.atlas = atlas
    end

    self.max_wander_time = 2 -- seconds


    self.base_wander_speed = 100
    
        
    -- self.base_wander_speed = 100
    
    self.machine = StateMachine(self, "idle")
    self.ent_name = "PlantZombie" -- maybe the name should go directly on the entity
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
        self.equipped_gun:holster()
    end
    self.equipped_gun = gun
    self.equipped_gun:equip(self.entity) -- gives self os gun knows who's holding it
end

function PZ:on_start()
    self.transform = self.entity.Transform -- seems to be standard for entities?
    self.sprite = self.entity.Sprite -- seems to be standard as well?
    self.entity.Machine = self.machine -- hmm
    self.entity.form = self

    local hp_args = {
        hp= 19
    }

    -- list classes and their arguments, if any, to add classes
    -- IM:runAlt(self.entity, "HP", hp_args)
    -- IM:runAlt(self.entity, "MOB") 
    -- IM:runAlt(self.entity, "WEAPON_SKILLS")


    self.im = self.entity.IM


end


function PZ:spawn(arg)

    local tbl = {
        {"Transform", arg.x, arg.y, 1.8, 1.8, 0},
        {"CC", 20},
        "PlantZombie",
        {"PC", 15, 19, Vector2(0,2)},
        {"Shadow", 15}
    }

    tbl.ent_class = "CREATURE" -- what to inherit onto the entity core

    _G.events:invoke("EF", tbl)

end
    
function PZ:idle_enter(dt)
    self.sprite:animate("idle_anim")
end

function PZ:idle(dt)

        -- we want the chance to go up linearly with dt

        local chance = dt * 1000 -- this number will be larger, when the dt is larger.
        -- how to make the chance proportional?

        -- -- if true then return end
        local roll = math.random(100)

        if roll == 1 then
            self.machine:change("wander")
        end
end

function PZ:idle_exit(dt)

end

function PZ:wander_enter(dt)

    self.sprite:animate("walk_anim")
    self.wander_timer = math.random() * self.max_wander_time
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

    self.transform.x = self.transform.x + ( (self.transform.vx * dt) * self.base_wander_speed)
    self.transform.y = self.transform.y + ( (self.transform.vy * dt) * self.base_wander_speed)
end

function PZ:wander_exit(dt)

end

function PZ:jump_enter()

end

function PZ:KOed_enter(dt)
    self.shrink_timer = self.transform.sx
end

function PZ:KOed(dt)
    
    -- self.equipped_gun.entity.remove = true

    dt = dt / Time.speed
    self.shrink_timer = self.shrink_timer - (dt * 20)
    self.transform.sx = self.shrink_timer
    self.transform.sy = self.shrink_timer

    if self.shrink_timer <= 0 then
        self.entity.remove = true
        -- self.transform.sx = 0 -- crappy band-aid for shadow issue
        -- self.transform.sy = 0
    end
end

-- no KOed exit function, done at end of KOed


function PZ:update(dt)
    self.machine:update(dt)
end

return PZ