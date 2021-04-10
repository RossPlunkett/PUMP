local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib/Vector2")
local Vector3 = require("lib/Vector3")
local Sprite = require("lib.components.Sprite")
local StateMachine = require("lib.components.StateMachine")


local Missile = Class:derive("Missile")

local missile_atlas
local target_object
local rotate_speed = 250
local missile_speed = 350

--Animation data

function Missile:new()
    self.vx = 0

    self.machine = StateMachine(self, "default")
    self.ent_name = "Missile"

end

function Missile.create_sprite()
    local idle = Anim(0,0, 124, 80, 2, 2, 6 )
    if missile_atlas == nil then
        missile_atlas = love.graphics.newImage("assets/gfx/missile.png")
    end
    local spr = Sprite(missile_atlas, 124, 80)
    spr:add_animations({idle = idle})
    spr:animate("idle")
    return spr
end

function Missile:on_start()
    self.transform = self.entity.Transform
    self.entity.Machine = self.machine
    self.entity.form = self

    local arg = {
        hp= 10
    }

    self.entity:HP_init(arg)

end

function Missile:spawn(arg)

    local missile_length = 62
    local missile_width = 30


    local missile = {
        {"Transform", arg.x or 0, arg.y or 0, 0.20, 0.20, arg.angle or 0}, 
        "Missile", 
        {"CC", 70, 40},
        {"PC", missile_length, missile_width},
        {"Shadow", 15}
    }

    missile.ent_class = "HP"
    
    --- missile needs to be targeted after it's sent

    -- maybe missiles can re-target every 10 frames or so based on the nearest player

    -- perhaps the player can re-route missiles for a lot of mana
    _G.events:invoke("EF", missile)


end

function Missile:target(object)
    self.target_transform = object
end

local V3 = Vector3(0, 0)
function Missile:update(dt)
    self.machine:update(dt)

    if self.target_transform ~= nil then
        local missile_to_target = Vector2.sub(self.target_transform:VectorPos(), self.transform:VectorPos())
        missile_to_target:unit()
        --print(missile_to_target.x .. " " .. missile_to_target.y )

        local missile_dir = Vector2( math.cos(self.transform.angle ), math.sin(self.transform.angle))
        missile_dir:unit()

        -- print("to target: " .. missile_to_target.x .. "," .. missile_to_target.y .. " missile dir: " .. missile_dir.x .. "," .. missile_dir.y )
        local cp = V3.cross(missile_dir, missile_to_target)
        if cp.z < 0.005 and ( missile_to_target.x == -missile_dir.x or missile_to_target.y == -missile_dir.y)  then cp.z = 10 end

        -- print(cp.x .. " " .. cp.y  .. " " .. cp.z)
        self.transform.angle = self.transform.angle + cp.z * rotate_speed * (math.pi / 180) * dt
        self.transform.x = self.transform.x + (missile_dir.x * missile_speed * dt)
        self.transform.y = self.transform.y + (missile_dir.y * missile_speed * dt)
    end
end



function Missile:default(dt)
end

function Missile:KOed_enter(dt)
    self.entity.remove = true
end

function Missile:KOed(dt) end

function Missile:KOed_exit(dt) end

return Missile