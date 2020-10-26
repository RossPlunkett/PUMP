
-- IM = Inheritance Module
local IM = {}

function IM:on_start()

end

-- use this in the class if it's a first class for any entity,
-- it sets up the data sctructure on the entity for the IM
function IM:init(ent)
    if not ent.IM then ent.IM = {} end
    if not ent.IM.classes then ent.IM.classes = {} end
    if not ent.IM.UF then ent.IM.UF = {} end
end


-- takes entity object and a value
function IM:HP(ent, val)

    self:init(ent) -- include this if it's the first class for an entity

    table.insert(ent.IM.classes, "HP")
   

    -- some values will go on the entity directly
    ent.hp = val

    --Invincibility frames module
    ent.Invincibility = {}
    ent.Invincibility.on = false
    ent.Invincibility.inv_frames = 6 -- default inv_frames
    ent.Invincibility.inv_frame = 0


    -- taking damage
    function ent:takeDamage(damage)

        if not self.Invincibility.on then
            -- damage multipliers here
            self.hp = self.hp - damage
        end
    end

    -- healing damage
    function ent:healDamage(hp)
        -- healing multipliers here
        self.hp = self.hp + hp
    end

    -- start invincibility frames
    function ent:invincible(frames)
        ent.Invincibility.inv_frame = frames or ent.Invincibility.inv_frames
    end


end

-- attaches proper functions for holding/carrying/dropping/firing(?) guns
function IM:HOLD_WEAPONS(ent)

    -- add class to class list
    table.insert(ent.IM.classes, "HOLD_WEAPONS")

    --include this line before, when adding to ent.IM
    self:init(ent)

    -- if the entity uses weapons:
    -- notice how [self] is replaced with the entity - we are attaching
    -- this to the entity, not to the IM, so no [self] keyword
    function ent:equip_gun(gun) -- right now, this points to the [.Gun]. Shit!

        if self.equipped_gun then  
            self.equipped_gun:unequip()
        end
        self.equipped_gun = gun
        self.equipped_gun:equip(self.entity) -- gives self so gun knows who's holding it
    end

    function ent:switch_gun() end

    function ent:drop_gun() end -- drops equipped gun

end

function IM:PLAYER(ent) 
    table.insert(ent.IM.classes, "PLAYER")
    --requires hp class



end

function IM:MOB(ent, type, ...)
    table.insert(ent.IM.classes, "MOB")

    -- requires hp class

end

function IM:PROJECTILE(ent, damage)

    IM:init(ent)

    table.insert(ent.IM.classes, "PROJECTILE")

    assert(damage, "damage must be supplied to PROJECTILE class!")
    ent.damage = damage


    -- hitting a mob
    function ent:hit(other)

        -- don't hit if he's invincible
        if other.Invincibility.on then return end

        -- if there's a hit function on the entity form, use it instead
        if self.form.hit then self.form:hit(other) return end

        -- apply damage
        other:takeDamage(self.damage)

        --unrefined knockback
        other.Transform.x = other.Transform.x + (self.Transform.vx * 4)
        other.Transform.y = other.Transform.y + (self.Transform.vy * 4)

        --flash
        other.Sprite:flash(0.05)

        --trigger invincibility frames
        if other.Invincibility then
            other.invincible() -- added in IM/Composer HP class
        end

        -- kill if it's dead
        if other.hp <= 0 then
            other.Machine:change("KOed")
        end

        --remove bullet
        -- self.remove = true
    end

end

-- combine classes?

-- to implement:

-- local IM = require("lib.InheritanceModule")

-- P = Class:derive("Player")


return IM

