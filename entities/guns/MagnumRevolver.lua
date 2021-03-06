local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine = require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")


local MR = Class:derive("MagnumRevolver") -- needs to change for each gun


function MR:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "MagnumRevolver"
end

function MR:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
 
    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Magnum Revolver",
        num_shots= 1,
        cooldown= 0.15,
        base_proj_speed= 2,
        inaccuracy= 0.15,
        automatic= false,
        kickback= 0.75,
        recoil = 8,
        cam_shake = {amount=150, in_time=0.2, out_time=0.25},
        magnitude= 10,
        damage= 2000
    }
    
    self.entity:GUN_init(arg_tbl)


end

function MR:makeProjectile()

    local RSXA, RSYA = self.entity.RSXA, self.entity.RSYA

    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    local x = self.transform.x + (RSXA  * self.entity.magnitude)
    local y = self.transform.y + (RSYA  * self.entity.magnitude)

    -- create component list to send to EntityFactory          
    local bullet = {
        {"Transform", x, y, 2, 2, newangle, RSXA or 0, RSYA or 0},
        {"MediumBullet", {damage = self.entity.damage}},
        {"CC", 20, 40},
        {"PC", 30, 9, Vector2(-6, 0)},
        {"Shadow", 2}
    }
    

    bullet.ent_class = "PROJECTILE"

    _G.events:invoke("EF", bullet) -- sends entity table to EntityFactory

end

-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function MR.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    

    
    local still_anim = Anim(0, 0, 24, 12, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end

    local spr = Sprite(atlas, 24, 12, nil, true)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

-- each gun should have it's own table for ordering a projectile

function MR:spawn(arg) 

    local gun_entity = {
        {"Transform", arg.x, arg.y, 1, 1, 0},
        "MagnumRevolver",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        {"Shadow", -4.5, 0, -1}
    }



    gun_entity.ent_class = 'GUN'

    _G.events:invoke("EF", gun_entity)
    
end


function MR:still_enter(dt)
    self.sprite:animate("still")
end

function MR:still(dt)

end

function MR:still_exit(dt)

end

function MR:draw()
    self.entity:drawName()
end

-- the update() and draw() functions are added in the IM/Composer class "GUN" to avoid code duplication

-- updatePost() runs after Composer "GUN" update func,
-- used for behaviour specific to this gun
-- function MR:updatePost(dt) end


return MR