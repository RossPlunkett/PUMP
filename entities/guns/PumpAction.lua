local Class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local StateMachine = require("lib.components.StateMachine")
local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")


local PumpAction = Class:derive("PumpAction") -- needs to change for each gun


function PumpAction:new()
    self.machine = StateMachine(self, "still")
    self.ent_name = "PumpAction"
end

function PumpAction:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self
 
    -- gun's qualities here
    local arg_tbl = {
        gun_name= "Pump Action",
        num_shots= 8,
        cooldown= 0.5,
        base_proj_speed= 2,
        inaccuracy= 0.21,
        automatic= false,
        kickback= 0.85,
        recoil = 4,
        cam_shake = {amount=20, in_time=0.05, out_time=0.05},
        magnitude= 8,
        damage= 20
    }
    
    self.entity:GUN_init(arg_tbl)


end

function PumpAction:makeProjectile()

    local RSXA, RSYA = self.entity.RSXA, self.entity.RSYA
    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    local x = self.transform.x + (RSXA  * self.entity.magnitude)
    local y = self.transform.y + (RSYA  * self.entity.magnitude)

    -- create component list to send to EntityFactory          
    local bullet = {
        {"Transform", x, y, 1, 1, newangle, RSXA or 0, RSYA or 0},
        {"MediumBullet", {damage = self.entity.damage}},
        {"CC", 20, 40},
        {"PC", 30, 9, Vector2(-6, 0)},
        {"Shadow", 3}
    }
    

    bullet.ent_class = "PROJECTILE"

    _G.events:invoke("EF", bullet) -- sends entity table to EntityFactory

end
-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function PumpAction.create_sprite(atlas)
    -- we make this like sprite.height/2 on the sprite height
    

    
    local still_anim = Anim(0, 0, 26, 10, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end

    local spr = Sprite(atlas, 26, 10, nil, true)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function PumpAction:spawn(arg) 

    local gun_entity = {
        {"Transform", arg.x, arg.y, 1,1, 0},
        "PumpAction",
        {"CC", 16, 40},
        {"PC", 6, 4, Vector2(1, 1)},
        {"Shadow", -4, 0, -1}
    }



    gun_entity.ent_class = 'GUN'

    _G.events:invoke("EF", gun_entity)
    
end




function PumpAction:still_enter(dt)
    self.sprite:animate("still")
end

function PumpAction:still(dt)

end

function PumpAction:still_exit(dt)

end

function PumpAction:draw()
    self.entity:drawName()
end

-- the update() and draw() functions are added in the IM/Composer class "GUN" to avoid code duplication

-- updatePost() runs after Composer "GUN" update func,
-- used for behaviour specific to this gun
-- function PumpAction:updatePost(dt) end


return PumpAction