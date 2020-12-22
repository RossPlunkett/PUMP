-- CREATURE inherits from HP
local HP = require('classes.entities.HP')
-- CREATURE applies to both mobs and players -
-- seems to be used mostly for weapon skills
local CREATURE = HP:derive('CREATURE')

local Vector3 = require('lib.Vector3')
local refVel = Vector3(0,0)

-- creature hold weapons
CREATURE.equipped_gun = nil
CREATURE.holstered_gun = nil

function CREATURE:pick_up_gun(forced_gun) -- arg is for forcing a certain gun

    if not self.equipped_gun then -- if holding no weapons
        if not forced_gun then
            self:equip_gun(self.closest_gun)
        else
            self.equip_gun(forced_gun) 
        end

        return
    end
    

    if self.equipped_gun and not self.holstered_gun then -- if holding one weapon
        self:holster_gun(self.equipped_gun)
    else
        self:drop_gun(self.equipped_gun)
    end


    if forced_gun then
        self:equip_gun(forced_gun)
    else
        if self.closest_gun == nil then return end
        self:equip_gun(self.closest_gun)
    end
end

function CREATURE:equip_gun(gun)
    -- note that gun switching skips this function / doesn't use it
    if self.equipped_gun then
        self:holster_gun(self.equipped_gun)
    end
    self.equipped_gun = gun
    gun:equip(self) -- gives self so gun knows who's holding it
end

function CREATURE:holster_gun(gun)
    -- note that gun switching skips this function / doesn't use it
    self.holstered_gun = gun
    self.holstered_gun.Transform.angle =  1.2
    self.holstered_gun.Sprite.tintColor = {1, 1, 1, 0.6}
    gun:holster(self)
end

function CREATURE:switch_guns()
    if self.equipped_gun
    and self.holstered_gun then
        self.equipped_gun, self.holstered_gun = self.holstered_gun, self.equipped_gun -- easy
        -- couldn't use the self:equip() and self:holster()
        self.equipped_gun:equip(self)
        self.holstered_gun:holster(self)
    end
end

function CREATURE:drop_gun(gun) -- player can't drop explicitly, only when picking up/swapping
    gun:drop()
    self.equipped_gun = nil -- this fixed dropped guns not being re-pickupable???
end

function CREATURE:CREATURE_update(dt)
    if self.equipped_gun then
        
        -- some juice
        local gun_Holster_offset = 10
        local tempPos = Vector3.SmoothDamp(
            -- declaring two new Vector3's every frame could be slow
            Vector3(self.equipped_gun.Transform.x,self.equipped_gun.Transform.y,0),
            Vector3(self.Transform.x, self.Transform.y+gun_Holster_offset, 0),
            refVel,
            0.025, -- nice to see when attaching guns
            dt)
        self.equipped_gun.Transform.x = tempPos.x
        self.equipped_gun.Transform.y = tempPos.y
    end

    if self.holstered_gun then
        self.holstered_gun.Transform.x = self.Transform.x
        self.holstered_gun.Transform.y = self.Transform.y - 2 -- puts gun behind holder
    end
    
end
CREATURE.UF[#CREATURE.UF + 1] = 'CREATURE_update'





return CREATURE