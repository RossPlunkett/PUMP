-- PLAYER derives from CREATURE
local CREATURE = require("classes.entities.CREATURE")

local PLAYER = CREATURE:derive('PLAYER')

local Vector2 = require('lib.Vector2')


function PLAYER:PLAYER_init(arg)

    self.hp = arg.hp
    self.player_num = self.form.player_num -- sloppy?
    self.control_scheme = self.form.control_scheme -- hope not

    self.r_trig_up = true
end

function PLAYER:PLAYER_update(dt)

    local RSXA, RSYA, r_trig
    if self.control_scheme == "Gamepad" then
        RSXA = GPM:stick2(self.player_num, true)[1]
        RSYA = GPM:stick2(self.player_num, true)[2]
        r_trig = GPM:r_trig(self.player_num)
    elseif self.control_scheme == "Keyboard" then

        -- this aims from the center of the screen
        

        width, height = love.graphics.getDimensions()
        RSXA = -((width * 0.5) - Mouse.x)
        RSYA = -((height * 0.5) - Mouse.y)

        local sum = math.abs(RSXA) + math.abs(RSYA)
        if sum ~= 0 then
            RSXA = RSXA / sum
            RSYA = RSYA / sum
        end

        -- first mouse button shoots
        if Mouse[1] then r_trig = 1 else r_trig = 0 end
    else
        assert(false, "control scheme not found!")
    end

    -- 

    if r_trig > 0 then


        -- if RSXA ~= 0 or RSYA ~= 0 then
        --     self.equipped_gun.RSXA = 
        -- end

        if self.equipped_gun
        and self.equipped_gun.cooling == false
        and (self.equipped_gun.automatic == true or self.r_trig_up == true)
        then     
            self.equipped_gun:shoot(RSXA ,RSYA, r_trig)
            -- i moved the shake into gun
            -- i think it should be unique to every gun
            if self.control_scheme == "Gamepad" then
                GPM:startVibe(0.08, 0.2) -- vibe needs stick number
            end


        end
        self.r_trig_up = false
    else
        self.r_trig_up = true
    end

    if (self.control_scheme == "Gamepad" and GPM:button_down(self.player_num, "b"))
    or (self.control_scheme == "Keyboard" and Key:key_down('q'))
    then
        self:switch_guns()
    end
    

    if (self.control_scheme == "Gamepad" and GPM:button_down(self.player_num, "x"))
    or (self.control_scheme == "Keyboard" and Key:key_down('f'))
    then
        if self.closest_gun then
            self:pick_up_gun()
        end

        if PROFILING then
            print('Position,Function name,Number of calls,Time,Source,')
            for k,t in ipairs(love.profiler.query(60)) do
                print(table.concat(t, ",")..",")
            end
        end

    end

    if GPM:button_down(self.player_num, "rightshoulder") then

    end

    if GPM:button(self.player_num, "leftshoulder") then
        for i = 1, 2 do
            _G.events:invoke("EF_spawn", "PlantZombie", {x = 100, y = 100})
             local xcoord = math.floor(math.random() * 100)
             local ycoord = math.floor(math.random() * 100)
             local angle = math.random() * 3.14
            -- _G.events:invoke("EF_spawn", "Missile", {x = xcoord, y = ycoord, angle = angle})
        end
    end

    if GPM:button_down(self.player_num, "dpup") then
    end

    if (GPM:button_down(self.player_num, "y")) then
        print("y")
    end

    local gun_angle = 0
    if (RSXA ~= 0 or RSYA ~= 0)  and self.equipped_gun ~= nil then
        gun_angle = math.atan2(RSYA, RSXA)
        self.equipped_gun.Transform.angle = gun_angle
        if math.abs(math.deg(gun_angle))  >= 90 and math.abs(math.deg(gun_angle)) <= 180 then
            self.equipped_gun.Sprite:flip_v(true)
        else
            self.equipped_gun.Sprite:flip_v(false)
        end
    end

    local RSXAR = GPM:r_stick_smooth(self.player_num)[1]
    local RSYAR = GPM:r_stick_smooth(self.player_num)[2]
    local look_range = 26
    local initPos = Vector2(self.Transform.x, self.Transform.y)
    if RSXAR ~= 0 or RSYAR ~= 0 then
        local xcamoffset = RSXAR * look_range
        local ycamoffset = RSYAR * look_range
        initPos = initPos.add(initPos,Vector2(xcamoffset,ycamoffset))
    end
    
    if self.player_num == 1 then
        Camera:setTargetPos(initPos.x,initPos.y)
    end
end

PLAYER.UF[#PLAYER.UF + 1] = 'PLAYER_update'




return PLAYER