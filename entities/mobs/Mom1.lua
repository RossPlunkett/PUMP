local Class = require("lib.Class") -- require Lua class module
local Vector2 = require("lib.Vector2") -- require Vec2 class
local Anim = require("lib.Animation")
local Sprite = require("lib.components.Sprite")
local StateMachine = require("lib.components.StateMachine") -- state machine class



local Mom1 = Class:derive("Mom1")



function Mom1:new(atlas)
    
    if atlas then
        self.atlas = atlas
    end

    self.max_wander_time = 2 -- seconds


    self.base_wander_speed = 100
    
        
    -- self.base_wander_speed = 100
    
    self.machine = StateMachine(self, "idle")
    self.ent_name = "Mom1" -- maybe the name should go directly on the entity
end



function Mom1.create_sprite(atlas)
    local idle_anim = Anim(0,0, 32, 32, {1, 2}, 2, {{0.5, 0.5}, 1})
    local walk_anim = Anim(0,0, 32, 32, {1, 2}, 2, {{0.5, 0.5}, 2 + (math.random() * 0.15)})
    if atlas == nil then
        assert(false, "no atlas supplied to sprite! Also none in self.atlas, so basically no atlases to draw from here. Kapeche?")
    end
    local spr = Sprite(atlas, 32, 64)
    spr:add_animations({idle_anim = idle_anim, walk_anim = walk_anim})
    spr:animate("walk_anim") -- handled by state machine
    
    return spr
end

function Mom1:equip_gun(gun)
    if self.equipped_gun ~= nil then
        self.equipped_gun:holster()
    end
    self.equipped_gun = gun
    self.equipped_gun:equip(self.entity) -- gives self os gun knows who's holding it
end

function Mom1:on_start()
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

    self.OG_x = self.transform.x
    self.OG_y = self.transform.y

    self.move_range = 20


end


function Mom1:spawn(arg)

    local tbl = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        {"CC", 20},
        "Mom1",
        {"PC", 35, 24},
        {"Shadow", -34}
    }

    tbl.ent_class = "CREATURE" -- what to inherit onto the entity core

    _G.events:invoke("EF", tbl)

end
    


function Mom1:idle_enter(dt)

    self.idle_timer = math.random()

end

function Mom1:idle(dt) 
    self.idle_timer = self.idle_timer - dt

    if (self.idle_timer <= 0) then
        self.machine:change('wander')
    end

end

function Mom1:idle_exit(dt) end

--------------------------------------------------------

function Mom1:wander_enter(dt)

    self.wander_time = 1
    self.wander_timer = 1  + (math.random() * 0.15)
    self.wander_elapsed = 0
    self.wander_distance = 10

    self.my_rando_x = math.random() - 0.5;
    self.my_rando_y = math.random() - 0.5;
    self.my_rando_speed = math.random(5)

    if (math.abs(self.OG_x - self.transform.x) > self.move_range) then
        if(self.transform.x < self.OG_x) then
            self.my_rando_x = self.my_rando_x + 0.5
        end
        if(self.transform.x > self.OG_x) then
            self.my_rando_x = self.my_rando_x - 0.5
        end
    end
    if (math.abs(self.OG_y - self.transform.y) > self.move_range) then
        if(self.transform.y < self.OG_y) then
            self.my_rando_y = self.my_rando_y + 0.5
        end
        if(self.transform.y > self.OG_y) then
            self.my_rando_y = self.my_rando_y - 0.5
        end
    end
    

end
function Mom1:wander(dt) 

    self.wander_timer = self.wander_timer - dt
    self.wander_elapsed = self.wander_elapsed + dt

    if (self.wander_timer <= 0) then
        self.machine:change('idle')
    end

    self.transform.x = self.transform.x + (Tween.sine_inout(self.wander_elapsed) * (self.my_rando_x * self.my_rando_speed))



    self.transform.y = self.transform.y + (Tween.sine_inout(self.wander_elapsed) * (self.my_rando_y * self.my_rando_speed))

    -- self.transform.x = self.transform.x + (self.my_rando_x)
    -- self.transform.y = self.transform.y + (self.my_rando_y)

end
function Mom1:wander_exit(dt) end













function Mom1:KOed_enter(dt)
    self.shrink_timer = self.transform.sx
end

function Mom1:KOed(dt)
    
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


function Mom1:update(dt)
    self.machine:update(dt)
end

return Mom1