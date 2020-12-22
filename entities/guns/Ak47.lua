local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine= require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")


local Ak47 = Class:derive("Ak47") -- needs to change for each gun


function Ak47:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "Ak47"
end

function Ak47:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
 
    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Ak47",
        proj_type= "bb",
        num_shots= 1,
        cooldown= 0.14,
        base_proj_speed= 4,
        inaccuracy= 0.12,
        automatic= true,
        kickback= 0.75,
        recoil = 6,
        magnitude= 5,
        damage= 2000
    }
    
    self.entity:GUN_init(arg_tbl)


end

function Ak47:makeProjectile()

    -- entity is the GUN class entity, not the PLAYER class entity
    -- basically these are polar velocities(?)
    local RSXA, RSYA = self.entity.RSXA, self.entity.RSYA

    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)
    -- grabs angle from gun -- works but matches angle b/c RSXA
    -- local newangle = self.transform.angle

    -- PRINTING
    print("shooting, bullet final angle is: ", newangle)


    -- print('---')
    -- print('RSXA, RSYA, angle: ', RSXA, RSYA, newangle)
    -- print('---')

    -- qualities to supply to MediumBullet:new() in the compoment table below
    local arg = {
        -- starting position
        x = self.transform.x + (RSXA  * self.entity.magnitude), 
        y = self.transform.y + (RSYA  * self.entity.magnitude),
        -- velocity
        vx = RSXA,
        vy = RSYA,
        -- get damage from gun entity, this one g ets passed through to the MediumBullet:new()
        damage = self.entity.damage
    }


    -- create component list to send to EntityFactory          
    local bullet = {
        {"Transform", arg.x, arg.y, 1, 1, newangle, arg.vx or 0, arg.vy or 0},
        {"MediumBullet", arg},
        {"CC", 20, 40},
        {"PC", 30, 9, Vector2(-6, 0)},
        {"Shadow", 2}
    }
    
    -- add class template to load for entity core
    bullet.ent_class = "PROJECTILE"
    -- sends entity 'order' to EntityFactory
    _G.events:invoke("EF", bullet) 

end
-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function Ak47.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    

    
    local still_anim = Anim(0, 0, 30, 20, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end

    local spr = Sprite(atlas, 30, 20, nil, true)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function Ak47:spawn(arg) 

    local gun_entity = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        -- name, proj_type, num_shots, cooldown, 
        -- base_proj_speed, inaccuracy, automatic, kickback, magnitude
        "Ak47",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        "Gizmo",
        {"Shadow", -8, 0, -1}
    }
    gun_entity.ent_class = 'GUN'

    _G.events:invoke("EF", gun_entity)
    
end


function Ak47:still_enter(dt)
    self.sprite:animate("still")
end

function Ak47:still(dt)

end

function Ak47:still_exit(dt)

end

function Ak47:draw()
    self.entity:drawName()
end

function Ak47:update(dt)
    if self.entity.equipped then
        -- PRINTING
--                                         :)
        if GPM:button_down(self.entity.holder.player_num, 'y') then
            local angle = self.transform.angle
            print("AK angle is ", angle)
            print("angle to deg is ", math.deg(angle))
            print("RSXA, RSYA: ", self.entity.RSXA, self.entity.RSYA)
        end

    end
end


return Ak47