local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine = require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")
 



local Revolver = Class:derive("Revolver") -- needs to change for each gun


function Revolver:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "Revolver"
    
end

function Revolver:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self

    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Revolver",
        proj_type= "bb",
        num_shots= 1,
        cooldown= 0.15,
        base_proj_speed= 2,
        inaccuracy= 0.05,
        automatic= false,
        kickback= 0,
        recoil = 5,
        magnitude= 5,
        damage= 20
        -- knockback in the gun?
    }
    self.entity:GUN_init(arg_tbl)


    -- IM:runAlt(self.entity, "GUN", arg_tbl )


end

function Revolver:makeProjectile()


    local RSXA, RSYA = self.entity.RSXA, self.entity.RSYA
    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    -- qualities to supply to MediumBullet:new()
    local arg = {
        -- starting position
        x = self.transform.x + (RSXA  * self.entity.magnitude), 
        y = self.transform.y + (RSYA  * self.entity.magnitude),
        -- velocity
        vx = RSXA,
        vy = RSYA,
        -- get damage from gun entity, this one gets passed through to the MediumBullet:new()
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
    

    bullet.ent_class = "PROJECTILE"

    _G.events:invoke("EF", bullet) -- sends entity table to EntityFactory

end
-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function Revolver.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    
    
    local still_anim = Anim(0, 0, 16, 10, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end
    local spr = Sprite(atlas, 16, 10)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function Revolver:spawn(arg)
    
    local gun_entity

    

    gun_entity = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        "Revolver",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        "Gizmo",
        {"Shadow", -4, 0, -1}
    }
    gun_entity.ent_class = "GUN"


    _G.events:invoke("EF", gun_entity)

    
end




function Revolver:still_enter(dt)
    self.sprite:animate("still")
end

function Revolver:still(dt)

end

function Revolver:still_exit(dt)

end

function Revolver:update(dt)

end

-- the update() and draw() functions are added in the IM/Composer class "GUN" to avoid code duplication

-- updatePost() runs after Composer "GUN" update func,
-- used for behaviour specific to this gun
function Revolver:updatePost(dt)
    -- print("gun updating")
end

function Revolver:draw()
    self.entity:drawName()
end

return Revolver