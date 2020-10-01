local Class = require("lib.Class")

-- SEP -- Standard Entity Properties
local SEP = Class:derive("SEP")

function SEP:new(hp)

    self.hp = hp

end

function SEP:on_start()

end


return SEP