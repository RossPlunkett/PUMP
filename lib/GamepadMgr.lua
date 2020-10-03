local Class = require("lib.Class")
local Events = require("lib.Events")
local Tween = require("lib.Tween")

local GPM = Class:derive("GamepadMgr")

local DEAD_ZONE = 0.15

local function hook_love_events(self)

    function love.joystickadded(joystick)
        local id = joystick:getID()
        assert(self.connected_sticks[id] == nil, "Joystick " .. id .. "already exists!")
        self.connected_sticks[id] = joystick
        self.is_connected[id] = true
        self.button_map[id] = {}
        self.event:invoke('controller_added', id)
    end

    function love.joystickremoved(joystick)
        local id = joystick:getID()
        self.is_connected[id] = false
        self.connected_sticks[id] = nil
        self.button_map[id] = {}
        self.event:invoke('controller_removed', id)
    end

    function love.gamepadpressed(joystick, button)
        local id = joystick:getID()
        self.button_map[id][button] = true
    end

    function love.gamepadreleased(joystick, button)
        local id = joystick:getID()
        self.button_map[id][button] = false
    end

    -- self.event = _G.Events

    -- self.event:hook('controller_added', self.on_controller_added)
    -- self.event:hook('controller_removed', self.on_controller_removed)
end

function GPM:new(db_files, ad_enabled)
    if db_files ~= nil then
        for i = 1, #db_files do
            love.joystick.loadGamepadMappings(db_files[i])
        end
    end

    self.event = Events()
    self.event:add('controller_added')
    self.event:add('controller_removed')

    hook_love_events(self)

    --if true, then the left analog joystick will be converted to
    --its corresponding dpad button output
    self.ad_enabled = ad_enabled

    --The currently-connected joysticks
    self.connected_sticks = {}
    self.is_connected = {}
    
    --Maps a joystick id to a table of key values 
    --where the key is a button and the value is either true = just_pressed 
    --false = just_release, nil = none
    self.button_map = {}


    self.base_vibe_strength = 0.7
    self.vibe_strength = nil
end

--Returns true if a joystick with the given id exists
--
function GPM:exists(joyId)
     return self.is_connected[joyId] == nil and self.is_connected[joyId]   
end

--returns the joystick with the given id
--
function GPM:get_stick(joyId)
    return self.connected_sticks[joyId]
end

--Returns true if the given button was just pressed  THIS frame!
function GPM:button_down(joyId, button)
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then 
        return false
    else 
        return self.button_map[joyId][button] == true
    end
end

--Returns true if the given button was just released THIS frame!
function GPM:button_up(joyId, button)
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then 
        return false
    else 
        return self.button_map[joyId][button] == false
    end
end

--return the instantaneous state of the requested button for the given joystick
function GPM:button(joyId, button)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return false end

    local is_down = stick:isGamepadDown(button)
    
    --do we want to convert the left analog stick to dpad buttons?
    if self.ad_enabled and not is_down then
        local xAxis = stick:getGamepadAxis("leftx")
        local yAxis = stick:getGamepadAxis("lefty")
        if button == 'dpright' then
            is_down = xAxis > DEAD_ZONE
        elseif button == 'dpleft' then
            is_down = xAxis < -DEAD_ZONE
        elseif button == 'dpup' then
            is_down = yAxis < -DEAD_ZONE
        elseif button == 'dpdown' then
            is_down = yAxis > DEAD_ZONE
        end
    end
    return is_down
end

function GPM:l_stick(joyId)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return {0,0} end
    local xAxis = stick:getGamepadAxis("leftx")
    local yAxis = stick:getGamepadAxis("lefty")
    if math.abs(xAxis) < DEAD_ZONE and math.abs(yAxis) < DEAD_ZONE then
        --if theyre both dead, nothing.
        xAxis = 0
        yAxis = 0
    else
        --turns it into a direction
        local sum = math.abs(xAxis) + math.abs(yAxis)
        if sum ~= 0 then
            xAxis = xAxis / sum
            yAxis = yAxis / sum
        end
    end
    return {xAxis, yAxis}
end

function GPM:r_stick(joyId, tune)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return {0,0} end

    local xAxis = stick:getGamepadAxis("rightx")
    local yAxis = stick:getGamepadAxis("righty")
    if math.abs(xAxis) < DEAD_ZONE and math.abs(yAxis) < DEAD_ZONE then
        xAxis = 0
        yAxis = 0
    end

    local tune = tune or true
    if tune then
        -- turns it into a direction
        local sum = math.abs(xAxis) + math.abs(yAxis)
        if sum ~= 0 then
            xAxis = xAxis / sum
            yAxis = yAxis / sum
        end
    end
    
    return {xAxis, yAxis}
end

function GPM:r_stick_raw(joyId)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return {0,0} end

    local xAxis = stick:getGamepadAxis("rightx")
    local yAxis = stick:getGamepadAxis("righty")
    --super raw
    if math.abs(xAxis) < DEAD_ZONE and math.abs(yAxis) < DEAD_ZONE then
        xAxis = 0
        yAxis = 0
    end
    return {xAxis, yAxis}
end

function GPM:r_stick_smooth(joyId)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return {0,0} end

    local xAxis = stick:getGamepadAxis("rightx")
    local yAxis = stick:getGamepadAxis("righty")
    --super raw

    return {xAxis, yAxis}
end

function GPM:l_trig(joyId)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return 0 end

    local yAxis = stick:getGamepadAxis("triggerleft")
    return yAxis
end

function GPM:r_trig(joyId)
    local stick = self.connected_sticks[joyId]
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return 0 end

    local yAxis = stick:getGamepadAxis("triggerright")
    return yAxis
end


function GPM:startVibe(time, strength)


    self.vibrating, self.vibe_time, self.vibe_timer = true, time, time
    self.vibe_strength = strength or nil
end

function GPM:vibrate(joyId, dt)
    if self.is_connected[joyId] == nil or self.is_connected[joyId] == false then return 0 end


    -- global speed speed cancel here
    dt = dt / Time.speed
    -- update timer
    self.vibe_timer = self.vibe_timer - dt
    -- get tweenable number

    -- kill the vibe if it's over
    if self.vibe_timer <= 0 then
        self.vibrating = false
        self.connected_sticks[joyId]:setVibration(0,0)
    end

    -- stage of tween
    local ratio = self.vibe_time / self.vibe_timer
    local tween_result

    -- I think this is cubic in/out?
    if ratio < 0.5 then
        tween_result = 4 * math.pow(ratio,3)
    else
         tween_result = 1 + 4 * math.pow((ratio -1), 3)
    end

    -- intensity
    local result
    if self.vibe_strength == nil then
        result = tween_result * self.base_vibe_strength
    else
        result = tween_result * self.vibe_strength
    end

    self.connected_sticks[joyId]:setVibration(result, result)

end



function GPM:on_controller_added(joyId)
    print("controller " .. joyId .. "added")
end

function GPM:on_controller_removed(joyId)
    print("controller " .. joyId .. "removed")
end




function GPM:update(dt)
    for i = 1, #self.is_connected do
        if self.button_map[i] then
            for k,_ in pairs(self.button_map[i]) do
                self.button_map[i][k] = nil
            end
        end
    end

    if self.vibrating then
        self:vibrate(1, dt)
    end

end

return GPM