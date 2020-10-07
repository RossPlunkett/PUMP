local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib.Vector2")
local Vector3 = require("lib.Vector3")

local Entity = require("lib.Entity")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")
local SBP = require("lib.components.SBP")

local fast_bullet = love.graphics.newImage("assets/gfx/Weapons/Guns/MediumBullet.png")


local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")

local BB = Class:derive("BasicBullet")

-- i think we should pass the speed for the bullet from the gun
-- and the damage and life
function BB:new()
    
    --self.life = 2
    self.speed = 300
    self.size = Vector2(10, 20)
    self.drag = (self.speed/2); -- some effect on the bullet
    self.damage = 10
    
end

function BB.create_sprite(atlas)
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
 

function BB:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.tag = self


end

-- a lot of info is needed
--starting position
-- angle
-- vx and vy
function BB:spawn(x_pos, y_pos, x, y, r_trig)



    -- should use the bullet's spawn function
    
    
    local RSXA, RSYA = x, y
    -- bullet sprite angle calculation
    local newangle = math.atan2(RSYA, RSXA)

    -- conditional for projectile type here?
            
    local bullet_length = 16
    local bullet_width = 9
    local bullet = Entity(
        Transform(x_pos, y_pos, 1.9, 1.9, newangle, RSXA or 0, RSYA or 0),
        BB(),
        BB.create_sprite(fast_bullet),
        CC(20,40),
        PC(12,8),
        SBP(10, 10))         

    _G.events:invoke("add to em", bullet) -- passes entity through
end

function BB:update(dt)

    -- self.life = self.life - dt

    -- if self.life <= 0 then
    --     self.entity.remove = true
    -- end

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

function BB:draw()

end

return BB
