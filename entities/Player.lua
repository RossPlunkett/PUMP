local Class = require("lib.Class")
local Anim = require("lib.Animation")
local Sprite = require("lib.components.Sprite")
local Transform = require("lib.components.Transform")
local Sat = require("lib.Sat")
local StateMachine = require("lib.components.StateMachine")

local Shadow = require("lib/components/Shadow")

local U = require("lib.Utils")

-- added these for bullet generation
local Vector2 = require("lib.Vector2")
local Entity = require("lib.Entity")
local CC = require("lib.components.physics.CircleCollider")
local PC = require("lib.components.physics.PolygonCollider")


local Gun = require("entities.Gun")
-- local Guns = {
-- Gun("pistol", "bb", 1, 0.1, 1, 0, false),
-- Gun("shotgun", "bb", 9, 0.4, 1, 0.9, false),
-- Gun("mega-blaster", "bb", 1, 0.04, 1.4, 0.3, true)
-- }

-- these here for dev spawning
local Missile = require("entities.Missile")
local PlantZombie = require("entities.PlantZombie")

--



local P = Class:derive("Player")

local hero_atlas
local snd

--Animation data
--xoffset, yoffset, w, h, frames, column_size, fps, loop

local colliderSize = Vector2(10,10)

-- used for damping in gun
local refVel = Vector2(0,0)
function P:new(player_num)

    assert(player_num ~= nil, "Player number not given to player module!")
    self.player_num = player_num
    
    if snd == nil then
        snd = love.audio.newSource("assets/sfx/hit01.wav", "static")
    end
    
    
    self.properties = {}
    self.properties.base_walk_speed = 150 -- value to be multiplied by dt to get number of pixels to move
    self.properties.base_dash_speed = 4000
    
    -- for automatic weapons
    self.r_trig_up = true
    
    -- equipped gun is added in on_start()
    self.holstered_gun = nil
    self.held_gun = nil
    self.closest_gun = nil

    -- state machine at bottom of new, gets entire self... and lasting self? ??? ????? ????? think so
    self.machine = StateMachine(self, "idle")
end

function P:spawn(player_num)
    local player_width = 8
    local player_height = 9
    
    --Player Entitiy
    local player = Entity(
        Transform(100, 100, 3, 3),
        P(player_num), -- calling the [new] method
        P.create_sprite(),
        CC(46,32),
        PC(4,2,Vector2(0,3))
        --,Shadow(73, 3.14)
    )
    _G.events:invoke("add to em", player)

    return player
end
-- (xoffset, yoffset, w, h, frames, column_size, fps, loop)
function P.create_sprite()
    -- changed some sprite to squid
    local idle = Anim(-1, 0, 20, 20, {1, 2, 3, 4, 5, 6}, 14, {{0.15, 0.15, 0.15, 0.15, 0.15, 0.15}, 2})
    local walk = Anim(0, 0, 20, 20,{7, 8, 9, 10, 11, 12, 13, 14}, 14, {{0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15, 0.15}, 2})
    if hero_atlas == nil then
        hero_atlas = love.graphics.newImage("assets/gfx/Characters/Squid.png")
    end
    
    --create a sprite component
    local sprite = Sprite(hero_atlas, 24, 16, nil, true)
    sprite:add_animations({idle = idle, walk = walk})
    --sprite:animate("idle") -- commented out - I think the state machine does this
    return sprite
end


function P:on_start()
    self.transform = self.entity.Transform
    self.sprite = self.entity.Sprite
    self.entity.Machine = self.machine

    self:equip_gun(Gun:spawn(1).Gun) -- hmm
    --self:holster_gun(Gun:spawn(1).Gun) -- hmm

end

function P:idle_enter(dt)
    self.sprite:animate("idle")
end

function P:idle(dt)

        local LSXA = GPM:l_stick(self.player_num)[1]
        local LSYA = GPM:l_stick(self.player_num)[2]

        -- self.transform.x = self.transform.x + LSXA -- why is moving in idle? to make movement more snappy?
        -- self.transform.y = self.transform.y + LSYA

        if LSXA ~= 0 or LSYA ~= 0 then
        self.machine:change("walk")
        end
end


function P:dash_enter(dt)
    --self.sprite:animate("dash") -- no dash anim yet
    self.dash_dir_x = GPM:l_stick(self.player_num)[1]
    self.dash_dir_y = GPM:l_stick(self.player_num)[2]

    self.dash_timer = 0.105
    if self.dash_dir_x ~= 0 then
        if self.dash_dir_x < 0 then self.sprite:flip_h(true)
        else self.sprite:flip_h(false)
        end
    end
    Time.speed_cancel = true
end

function P:dash(dt) 

    self.dash_timer = self.dash_timer - dt
    if self.dash_timer <= 0 then
        self.machine:change("idle")
        return
    end
    self.transform.x = self.transform.x + 
    ((self.dash_dir_x * self.properties.base_dash_speed) * dt)
    self.transform.y = self.transform.y + 
    ((self.dash_dir_y * self.properties.base_dash_speed) * dt)
end

function P:dash_exit(dt)
    Time.speed_cancel = false
end

function P:walk_enter(dt)
    self.sprite:animate("walk")
end

function P:walk(dt)

    local LSXA = GPM:l_stick(self.player_num)[1]
    local LSYA = GPM:l_stick(self.player_num)[2]

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

    if (GPM:button_down(self.player_num, "a")) then
        self.machine:change("dash")
    end

end

function P:KOed_enter(dt)
    self.entity.Sprite:flash(0.05)
    self.death_timer = 0.05
end

function P:KOed(dt)
    dt = dt / Time.speed
    self.death_timer = self.death_timer - dt

    if self.death_timer <= 0 then
        self.entity.remove = true
    end
end

function P:pick_up_gun()
    if self.closest_gun == nil then return end
    self:equip_gun(self.closest_gun.Gun)
end

function P:equip_gun(gun)
    if self.equipped_gun ~= nil then
        self.equipped_gun:unequip()
    end
    self.equipped_gun = gun
    self.equipped_gun:equip(self.entity) -- gives self os gun knows who's holding it
end

function P:holster_gun(gun)
    gun.held = true
    self.holstered_gun = gun
    self.holstered_gun:holster(self)
end


function P:update(dt)
    self.machine:update(dt)

    local RSXA = GPM:r_stick(self.player_num, true)[1]
    local RSYA = GPM:r_stick(self.player_num, true)[2]


    local l_trig = GPM:l_trig(self.player_num)
    --directly updating Music while GPM is stuck here in the player
    _G.events:invoke("l_trig_pull", l_trig)
    local tween_result = nil

    -- this really shouldn't be in the player probably

    -- the l_trig should send out a message from the gamepad manager, and have it be dependent on scene?
          -- but how could the gamepadmanager know what the current scene is? would it have to query through an event?

    -- I guess this message gets sent both to the camera and to the speed module?

    -- need self.prev_l_trig to see when it's getting a fresh pull?
    if not Time.speed_cancel
    and self.player_num == 1 then -- just player one for now until I figure out where to move this to
        if l_trig > 0 then
            local ratio =1 - l_trig
            tween_result = nil
            --cubic in/out tween for speed and camera
            if ratio < 0.5 then tween_result = 2 * math.pow(ratio,2)
            else tween_result = 1 - 2 * math.pow(ratio - 1, 2) end
            local speed_tween_result = math.pow(ratio, 4)
            local min_global_speed = 0.1
            Time.speed = ( 1 - ((1 - speed_tween_result) * (1 - min_global_speed)) )
            local cam_scale = (tween_result * 0.07) + 0.93
            if GPM:button(self.player_num, "y") then
                cam_scale = 2.5 + (1 - tween_result)
            end
            Camera:scale(cam_scale, cam_scale)
        else
            -- all of this kinda ignores if there are other zooming things happening
            -- camera needs dynamic zoom that integrates multiple zooms
            Time.speed = (1)
            Camera:scale(1, 1)
        end
    end
    

    local r_trig = GPM:r_trig(self.player_num)
    if r_trig > 0 then
        if self.equipped_gun.cooling == false
        and (self.equipped_gun.automatic == true or self.r_trig_up == true)
        and (RSXA ~= 0 or RSYA ~= 0)
        then
            self.equipped_gun:shoot(RSXA ,RSYA, r_trig)
            Camera:startShake(RSXA, RSYA, 1000, 0.05, 0.05)
            GPM:startVibe(0.08, 0.2) -- vibe needs stick number


        end
        self.r_trig_up = false
    else
        self.r_trig_up = true
    end
    
    if GPM:button_down(self.player_num, "b") then
    end
    if GPM:button_down(self.player_num, "rightshoulder") then
        self:pick_up_gun()
    end
    if GPM:button_down(self.player_num, "leftshoulder") then
        PlantZombie:spawn(12)
        Missile:spawn(2)
    end
    if GPM:button_down(self.player_num, "dpup") then
    end

    if (GPM:button_down(self.player_num, "y")) then
    end

    local gun_angle = 0
    if RSXA ~= 0 or RSYA ~= 0 then
        gun_angle = math.atan2(RSYA, RSXA)
        self.equipped_gun.transform.angle = gun_angle
    end
    -- this is coming up nan with no stick input -should be else?
    if math.abs(math.deg(gun_angle))  >= 90 and math.abs(math.deg(gun_angle)) <= 180 then
        self.equipped_gun.sprite:flip_v(true)
    else
        self.equipped_gun.sprite:flip_v(false)
    end
    -- player moves gun, gun doesn't follow player
    self.equipped_gun.transform.x = self.transform.x
    self.equipped_gun.transform.y = self.transform.y

    -- local tempPos = Vector3.SmoothDamp(
    --    self.equip_gun.transform.x,self.equip_gun.transform.y,
    --     Vector3(self.targetPosX, self.targetPosY),
    --     refVel,
    --     0.05,
    --     dt)
    -- self.equipped_gun.transform.x = tempPos.x
    -- self.equipped_gun.transform.y = tempPos.y
    if self.holstered_gun then
        self.holstered_gun.transform.x = self.transform.x
        self.holstered_gun.transform.y = self.transform.y + 35 -- offset to lower it
        -- this should just happen once right when it's holstered
        self.holstered_gun.transform.angle =  1.2
        self.holstered_gun.sprite.tintColor = {1, 1, 1, 0.6}
    end

    

    local RSXAR = GPM:r_stick_smooth(self.player_num)[1]
    local RSYAR = GPM:r_stick_smooth(self.player_num)[2]
    local look_range = 26
    local initPos = Vector2(0,0)
    initPos = Vector2(self.transform.x, self.transform.y)
    if RSXAR ~= 0 or RSYAR ~= 0 then
        local xcamoffset = RSXAR * look_range
        local ycamoffset = RSYAR * look_range
        initPos = initPos.add(initPos,Vector2(xcamoffset,ycamoffset))
    end
    
    Camera:setTargetPos(initPos.x,initPos.y)
    --Camera:center_on_transform(self.transform)

    -- instead of positioning the camera to a specific location by using offsets,
    -- make the camera move or lerp between the old position to target position

    

    -- I feel like I'll need this for multiplayer time-slowing
    self.prev_l_trig = l_trig
    
end

function P:draw()



end

--This function responds to a collision event on any of the
-- given sides of the player's collision rect
-- top, bottom, left, right are all boolean values
function P:collided(top, bottom, left, right)
    if bottom then end
    if top then end
    if left then end
    if right then end
end

return P