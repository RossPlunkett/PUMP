local class = require("lib/Class")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local Entity = require("lib.Entity")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")
local StateMachine = require("lib.components.StateMachine")


local Anim = require("lib/Animation")
local Sprite = require("lib/components/Sprite")

local GPM = require("lib.GamepadMgr")
local BasicBullet = require("entities.BasicBullet")
local SBP = require("lib.components.SBP")

local Transform = require("lib.components.Transform")

local fast_bullet = love.graphics.newImage("assets/gfx/fast_bullet_border.png")
-- the default sprite when it i notset
local default_atlas = love.graphics.newImage("assets/gfx/Weapon/Guns/revolver.png")

local Gun = class:derive("Gun")

local weapons = {}
    weapons.type = {}
        weapons.type.range = {
            {"Revolver", "bb", 1, 0.25, 1.4, 0.3, true, 8, 15,
            }
        }
        weapons.type.melee = {
            {"mega-blaster", "bb", 1, 0.04, 1.4, 0.3, true, 8, 15,
            love.graphics.newImage("assets/gfx/Weapon/Guns/revolver.png")}
        }




function Gun:new(name, proj_type, num_shots, cooldown, 
                base_proj_speed, inaccuracy, automatic, kickback, magnitude, sprite_atlas)
    
    self.name = name
    self.proj_type = proj_type
    self.num_shots = num_shots
    self.cooldown = cooldown
    self.cooldown_timer = 0 -- zero for first shot
    self.cooling = false
    self.inaccuracy = inaccuracy
    self.base_proj_speed = base_proj_speed
    self.automatic = automatic or false
    self.kickback = kickback or 0
    self.magnitude = magnitude or 20
    default_atlas = sprite_atlas or default_atlas
    -- should only update certain stuff if it's equipped?
    self.equipped = false
    -- held is for inactive weapon
    self.held = false
    
    
    self.machine = StateMachine(self, "still")
end

-- Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
function Gun.create_sprite(atlas)
    local still_anim = Anim(0, 0, 32, 32, 1, 1, 8, false)
    if atlas == nil then
        assert(false, "no atlas supplied to sprite!")
    end
    -- we make this like sprite.height/2 on the sprite height
    local spr = Sprite(atlas, 8, 5)
    spr:add_animations({still = still_anim})
    spr:animate("still") -- this should be in the state machine
    
    return spr
end

function Gun:spawn(num)

    -- if num is 1, it returns the gun to the function

    local gun_entity

    for i = 1, num do

        -- these four lines are garbage after we do the world module
        local world_width = 100
        local world_height = 100
        local start_x = (math.random(world_width) * 2) - world_width
        local start_y = (math.random(world_height) * 2) - world_width

        gun_entity = Entity(
            Transform(start_x, start_y, 3, 3, 0), 
            -- name, proj_type, num_shots, cooldown, 
            -- base_proj_speed, inaccuracy, automatic, kickback, magnitude
            Gun("mega-blaster", "bb", 1, 0.04, 1.4, 0.3, true, 8, 15), -- ive changed it because i think we should make a table or something
            Gun.create_sprite(default_atlas), -- I think its redundant to the gun constructor method -- hmm
            CC(16,40),
            PC(6, 4, Vector2(1, 1)))

        _G.events:invoke("add to em", gun_entity)
    end


    
    if num == nil or num < 2 then -- this seems dumb
        return gun_entity
    end

end

function Gun:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
end

function Gun:equip(holder)
    self.equipped = true
    self.holder = holder
end

function Gun:holster(holder)
    self.holstered = true
    self.holder = holder
end

function Gun:unequip()
    self.equipped = false
end

function Gun:drop()

end

function Gun:shoot(x, y, r_trig) -- these are directionally summed
    if self.cooldown_timer <= 0 then

        local i = 1
        while i <= self.num_shots do
            

            local RSXA = x
            local RSYA = y

            -- quick fix for non-moving bullets
            if RSXA == 0 and RSYA == 0 then return end
    
            -- this seems to put shots more on the outside of the area than inside
            -- maybe an easing function here
            local x_inaccuracy = math.random() * self.inaccuracy
            x_inaccuracy = x_inaccuracy - (x_inaccuracy * 0.5)
            local y_inaccuracy = math.random() * self.inaccuracy
            y_inaccuracy = y_inaccuracy - (y_inaccuracy * 0.5)
    
            RSXA = RSXA + x_inaccuracy
            RSYA = RSYA + y_inaccuracy

            -- re-sum after inaccuracy to keep bullet speed consistent
            local sum = math.abs(RSXA) + math.abs(RSYA) 
            RSXA = RSXA / sum
            RSYA = RSYA / sum

            -- apply kickback to the holding entity
            self.holder.Transform.x = self.holder.Transform.x - (RSXA * self.kickback)
            self.holder.Transform.y = self.holder.Transform.y - (RSYA * self.kickback)
    
    
            -- add projectile velocity from self
            RSXA = RSXA * self.base_proj_speed
            RSYA = RSYA * self.base_proj_speed
    
            -- spawn in the bullet at the right speed, angle and heading
            -- need to add magnitude, which should be inherent to the gun in the end
            -- so replace that 35 with 
            BasicBullet:spawn(self.transform.x + (RSXA  * self.magnitude), 
                            self.transform.y + (RSYA  * self.magnitude), 
                            RSXA, RSYA, r_trig)
    


            self.cooldown_timer = self.cooldown
            self.cooling = true

            i = i + 1
        end
    end
end


function Gun:still_enter(dt)
    self.sprite:animate("still")
end

function Gun:still(dt)

end

function Gun:still_exit(dt)

end

function Gun:update(dt)
    if self.equipped and self.cooling then
        self.cooldown_timer = self.cooldown_timer - dt
        if self.cooldown_timer <= 0 then
            self.cooling = false
        end
    end
end

function Gun:draw(dt)
    if self.in_reach then
        -- maybe offset this with the length of the string ? but i dont know how to do it
        -- love.graphics.print(self.name,self.transform.x,self.transform.y)
        love.graphics.printf(self.name, self.transform.x, self.transform.y,120, 'center')
    end
end

return Gun