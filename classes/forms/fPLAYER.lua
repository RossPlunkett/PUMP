-- form class for player forms - includes some states
local Class = require('lib.Class')

local PLAYER = Class:derive('PLAYER')

PLAYER.control_scheme = "Gamepad"

function PLAYER:getLS()

    local LSXA, LSYA = 0, 0
    local horz, vert = true, true
    if self.entity.control_scheme == "Gamepad" then
        LSXA = GPM:l_stick(self.player_num)[1]
        LSYA = GPM:l_stick(self.player_num)[2]
    elseif self.entity.control_scheme == "Keyboard" then
        -- horizontal
        if Key:key('d') then LSXA = LSXA + 1 
        elseif Key:key('a') then LSXA = LSXA - 1
        else LSXA = 0; horz = false end
        -- vertical
        if Key:key('w') then LSYA = LSYA - 1 
        elseif Key:key('s') then LSYA = LSYA + 1
        else LSYA = 0; vert = false end
        local sum = math.abs(LSXA) + math.abs(LSYA)

        if sum ~= 0 then -- sum it
            LSXA = LSXA / sum
            LSYA = LSYA / sum
        end
        -- stops player from 'slowing down' when moving diagonally with the keyboard
        -- with a little speed boost
        -- local diagonal_speed = 1.35
        -- if horz and vert then
        --     LSXA = LSXA * diagonal_speed
        --     LSYA = LSYA * diagonal_speed
        -- end

    end


    return LSXA, LSYA

end


function PLAYER:idle_enter(dt)
    self.sprite:animate("idle")
end

function PLAYER:idle(dt)

    local LSXA, LSYA = self:getLS()


    if LSXA ~= 0 or LSYA ~= 0 then
        self.machine:change("walk")
    end

end


function PLAYER:walk_enter(dt)
    self.sprite:animate("walk")
end

function PLAYER:walk(dt)


    local LSXA, LSYA = self:getLS()

    -- horixontal flipping by stick
    if LSXA ~= 0 then
        if LSXA < 0 then self.sprite:flip_h(true)
        else self.sprite:flip_h(false)
        end
    end

    if LSXA ~= 0 or LSYA ~= 0 then
        self.transform.x = self.transform.x + ((LSXA * self.properties.base_walk_speed) * dt)
        self.transform.y = self.transform.y + ((LSYA * self.properties.base_walk_speed) * dt)
    else
        self.machine:change("idle")
    end


end

function PLAYER:KOed_enter(dt)
    self.death_timer = 0.05
end

function PLAYER:KOed(dt)
    dt = dt / Time.speed
    self.death_timer = self.death_timer - dt

    if self.death_timer <= 0 then
        self.entity.remove = true
    end
end

return PLAYER