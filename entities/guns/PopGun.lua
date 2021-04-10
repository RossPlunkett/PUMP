local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine = require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")


local PopGun = Class:derive("PopGun") -- needs to change for each gun


function PopGun:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "PopGun"
end

function PopGun:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
 
    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Pop Gun",
        proj_type= "bb",
        num_shots= 1,
        cooldown= 0.15,
        base_proj_speed= 2,
        inaccuracy= 0.4,
        automatic= true,
        kickback= 0.75,
        recoil = 6,
        magnitude= 8,
        damage= 2000
    }
    
    self.entity:GUN_init(arg_tbl)


end

function PopGun:makeProjectile()

    local RSXA, RSYA = self.entity.RSXA, self.entity.RSYA
    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    local x = self.transform.x + (RSXA  * self.entity.magnitude)
    local y = self.transform.y + (RSYA  * self.entity.magnitude)

    -- create component list to send to EntityFactory          
    local bullet = {
        {"Transform", x, y, 1, 1, newangle, RSXA or 0, RSYA or 0},
        {"MediumBullet", arg},
        {"CC", 20, 40},
        {"PC", 30, 9, Vector2(-6, 0)},
        {"Shadow", 2}
    }
    

    bullet.ent_class = "PROJECTILE"

    _G.events:invoke("EF", bullet) -- sends entity table to EntityFactory

end
-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function PopGun.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    

    
    local still_anim = Anim(0, 0, 20, 10, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end

    local spr = Sprite(atlas, 20, 10, nil, true)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function PopGun:spawn(arg) 

    local gun_entity = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        -- name, proj_type, num_shots, cooldown, 
        -- base_proj_speed, inaccuracy, automatic, kickback, magnitude
        "PopGun",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        {"Shadow", -4, 0, -1}
    }



    gun_entity.ent_class = 'GUN'

    _G.events:invoke("EF", gun_entity)
    
end


function PopGun:still_enter(dt)
    self.sprite:animate("still")
end

function PopGun:still(dt)

end

function PopGun:still_exit(dt)

end

function PopGun:draw()
    self.entity:drawName()
end

-- the update() and draw() functions are added in the IM/Composer class "GUN" to avoid code duplication

-- updatePost() runs after Composer "GUN" update func,
-- used for behaviour specific to this gun
-- function PopGun:updatePost(dt) end


return PopGun