local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine = require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")


local Uzi = Class:derive("Uzi") -- needs to change for each gun


function Uzi:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "Uzi"
end

function Uzi:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
 
    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Uzi",
        proj_type= "bb",
        num_shots= 1,
        cooldown= 0.05,
        base_proj_speed= 2,
        inaccuracy= 0.2,
        automatic= true,
        kickback= 1.5,
        recoil = 6,
        magnitude= 9,
        damage= 20
    }
    
    self.entity:GUN_init(arg_tbl)


end

function Uzi:makeProjectile()

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
function Uzi.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    
    local spr = Sprite(atlas, 22, 20)
    
    local still_anim = Anim(0, 0, 32, 32, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function Uzi:spawn(arg) 

    local gun_entity = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        "Uzi",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        "Gizmo",
        {"Shadow", -9, 0, -1}
    }

    gun_entity.ent_class = 'GUN'

    _G.events:invoke("EF", gun_entity)
    
end




function Uzi:still_enter(dt)
    self.sprite:animate("still")
end

function Uzi:still(dt)

end

function Uzi:still_exit(dt)

end

function Uzi:draw()
    self.entity:drawName()
end

-- the update() and draw() functions are added in the IM/Composer class "GUN" to avoid code duplication

-- updatePost() runs after Composer "GUN" update func,
-- used for behaviour specific to this gun
-- function Uzi:updatePost(dt) end


return Uzi