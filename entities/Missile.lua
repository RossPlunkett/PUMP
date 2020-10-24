local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib.Vector2")
local Vector3 = require("lib.Vector3")
local Entity = require("lib.Entity")
local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")
local StateMachine = require("lib.components.StateMachine")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")

local HP = require('entities.base.HP'); HP:new();
local M = HP:derive("Missile")

local missile_atlas
local target_object
local rotate_speed = 250
local missile_speed = 850

--Animation data

function M:new()
    self.vx = 0

    self.machine = StateMachine(self, "idle")
    self.ent_name = "Missile"

end

function M.create_sprite()
    local idle = Anim(0,0, 124, 80, 2, 2, 6 )
    if missile_atlas == nil then
        missile_atlas = love.graphics.newImage("assets/gfx/missile.png")
    end
    local spr = Sprite(missile_atlas, 124, 80)
    spr:add_animations({idle = idle})
    spr:animate("idle")
    return spr
end

function M:on_start()
    self.transform = self.entity.Transform
    self.entity.Machine = self.machine
    self.entity.form = self
end

function M:spawn(num)

    for i = 1, num do

        local world_width = 2000
        local world_height = 2000
        local start_x = (math.random(world_width) * 2) - world_width
        local start_y = (math.random(world_height) * 2) - world_width

        local missile_length = 62
        local missile_width = 30
        local missile = Entity(Transform(start_x, start_y, 0.5, 0.5, 0), M(), M.create_sprite(),CC(70,40),
        PC({Vector2(-missile_length,-missile_width), Vector2(missile_length,-missile_width), Vector2(missile_length,missile_width), Vector2(-missile_length, missile_width)}))
        
        --- missile needs to be targeted after it's sent

        -- maybe missiles can re-target every 10 frames or so based on the nearest player

        -- perhaps the player can re-route missiles for a lot of mana
        _G.events:invoke("add to em", missile)
    end

end

function M:target(object)
    self.target_transform = object
end

function M:update(dt)

    if self.target_transform ~= nil then
        local missile_to_target = Vector2.sub(self.target_transform:VectorPos(), self.transform:VectorPos())
        missile_to_target:unit()
        --print(missile_to_target.x .. " " .. missile_to_target.y )

        local missile_dir = Vector2( math.cos(self.transform.angle ), math.sin(self.transform.angle))
        missile_dir:unit()

        -- print("to target: " .. missile_to_target.x .. "," .. missile_to_target.y .. " missile dir: " .. missile_dir.x .. "," .. missile_dir.y )
        local cp = Vector3.cross(missile_dir, missile_to_target)
        if cp.z < 0.005 and ( missile_to_target.x == -missile_dir.x or missile_to_target.y == -missile_dir.y)  then cp.z = 10 end

        -- print(cp.x .. " " .. cp.y  .. " " .. cp.z)
        self.transform.angle = self.transform.angle + cp.z * rotate_speed * (math.pi / 180) * dt
        self.transform.x = self.transform.x + (missile_dir.x * missile_speed * dt)
        self.transform.y = self.transform.y + (missile_dir.y * missile_speed * dt)
    end
end

return M