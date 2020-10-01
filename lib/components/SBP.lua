local Class = require("lib.Class")

-- SBP: Standard Bullet Properties
local SBP = Class:derive("SBP")

function SBP:new(dmg, knockback)

    self.damage = dmg

    self.knockback = knockback or 5

end




return SBP