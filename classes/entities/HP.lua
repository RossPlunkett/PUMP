local ENTITY = require('classes.entities.ENTITY')
local HP = ENTITY:derive('HP')

    -- Properties
    -- base HP
    HP.hp = 50
    -- Invincibility frames table
    HP.Invincibility = {on = false, inv_frames = 6, inv_frame = 0}

    -- Methods

    function HP:HP_init(arg)
        self.hp = arg.hp
    end

    -- TEMP: getting hp
    function HP:getHP()
        return self.hp
    end
    -- taking damage
    function HP:takeDamage(damage)

        if not self.Invincibility.on then
            -- damage multipliers here and in projectile
            self.hp = self.hp - damage
        end

        if self.hp <= 0 then
            self.Machine:change("KOed")
        end

    end

    -- healing damage
    function HP:healDamage(hp)
        -- healing multipliers here
        self.hp = self.hp + hp
    end

    -- start invincibility frames
    function HP:invincible(frames)
        self.Invincibility.inv_frame = frames or self.Invincibility.inv_frames
    end

    function HP:HP_update(dt)
        -- Invincibility frames
        if self.Invincibility then
            if self.Invincibility.inv_frame > 0 then
                self.Invincibility.on = true
                -- makes invincibility frames last longer when time is slowed
                self.Invincibility.inv_frame = self.Invincibility.inv_frame - Time.speed
                
            else
                self.Invincibility.on = false
            end
        end
    end
    HP.UF[#HP.UF + 1] = 'HP_update'


-- Example bird:can("dodge"), worm:can("idle"), bro:can({"defend", "deflect"})




return HP