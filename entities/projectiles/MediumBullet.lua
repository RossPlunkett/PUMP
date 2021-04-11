local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib.Vector2")
local Vector3 = require("lib.Vector3")

local Entity = require("lib.Entity")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")





local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")

local MediumBullet = Class:derive("MediumBullet")

-- this is called by the gun, which supplies the arg
function MediumBullet:new(arg)
    
    self.damage = arg.damage
    self.speed = 300
    self.size = Vector2(10, 20)
    self.drag = (self.speed/2); -- some effect on the bullet
    
    self.ent_name = "MediumBullet"
    
end

-- this gets run automatically
function MediumBullet.create_sprite(atlas)
    --(xoffset, yoffset, w, h, frames, column_size, fps, loop)
    local spin_anim = Anim(0,0,32, 32, 2, 2, 24, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end
    local spr = Sprite(atlas, 16,32)
    spr:add_animations({spin_anim = spin_anim})
    --spr:animate("rock") -- handled by state machine

    spr:animate("spin_anim")


    return spr
end
 

-- called automatically
function MediumBullet:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.form = self


    self.entity:PROJECTILE_init()


end

-- called by entity factory
function MediumBullet:spawn(arg)


    -- r_trig?
    -- should use the bullet's spawn function
    
    
    local RSXA, RSYA = arg.vx, arg.vy
    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    -- got damage in the [arg]
           
    -- order form table gets sent to EntityFactory.Lua
    local bullet = {
        {"Transform", arg.x, arg.y, 1, 1, newangle, RSXA or 0, RSYA or 0},
        {"MediumBullet", arg},
        {"CC", 24, 40},
        {"PC", 30, 9, Vector2(-6, 0)},
        {"Shadow", 2}
    }

    -- this tells the EntityFactory
    bullet.ent_class = "PROJECTILE"

    _G.events:invoke("EF", bullet) -- sends entity table to EntityFactory
end

function MediumBullet:update(dt)

    if self.entity.age <= self.entity.moving_age then return end -- this conditional starts the bullet at the gun,
                                        -- it keeps the bullet at the muzzle at low frame rates
                                        -- this should be put on all projectile entity forms

    -- the speed of the bullet before destroying
    local threshold = 0.5
    if(self.speed <= threshold) then 
        self.entity.remove = true    
    end
    self.transform.x = self.transform.x + ((self.speed * self.transform.vx) * dt)
    self.transform.y = self.transform.y + ((self.speed * self.transform.vy) * dt)

    -- slow down the bullet
    self.speed = self.speed - (self.drag * dt)
    -- make it slow down faster through time
    self.drag = self.drag + dt * self.speed * 10

  
end

function MediumBullet:draw()

end

return MediumBullet
