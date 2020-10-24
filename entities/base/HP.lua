local Class = require("lib.Class")

local HP = Class:derive("HP")



function HP:new()
    self.hp = 115
end

function HP:takeDamage(damage)
    self.hp = self.hp - damage
end





return HP