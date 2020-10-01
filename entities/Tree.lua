local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Vector2 = require("lib.Vector2")
local Vector3 = require("lib.Vector3")

local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")
local StateMachine = require("lib.components.StateMachine")

local Entity = require("lib.Entity")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")


local Tree = Class:derive("Tree")

local tree_atlas



function Tree:new()
    self.machine = StateMachine(self, "idle")
end

function Tree.create_sprite()
    if tree_atlas == nil then
        tree_atlas = love.graphics.newImage("assets/gfx/trees-and-bushes-only.png")
    end
    local spr = Sprite(tree_atlas, 115, 151)
    local idle = Anim(0,0, 115, 151, 1, 1, 6)
    spr:add_animations({idle = idle})
    --spr:animate("idle") -- handled by state machine
    return spr
end

function Tree:on_start()
    self.transform = self.entity.Transform -- seems to be standar for entities?
    self.sprite = self.entity.Sprite
end

function Tree:spawn(x, y)
        local tree_length = 16
        local tree_width = 40
        local tree_y_offset = -4
        local tree = Entity(Transform(x, y, 2, 2, 0), Tree(),
         Tree.create_sprite(),
        CC(100,100),
        PC({Vector2(-tree_length,-tree_width + tree_y_offset), Vector2(tree_length,-tree_width + tree_y_offset), Vector2(tree_length,tree_width + tree_y_offset), Vector2(-tree_length, tree_width + tree_y_offset)}))

        _G.events:invoke("add to em", tree)
end

function Tree:idle_enter(dt)
    self.sprite:animate("idle")
end

function Tree:idle(dt)

end


function Tree:update(dt)
    self.machine:update(dt)
end

return Tree