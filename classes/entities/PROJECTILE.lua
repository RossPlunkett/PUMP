local ENTITY = require('classes.entities.ENTITY')

local PROJECTILE = ENTITY:derive('PROJECTILE')



function PROJECTILE:PROJECTILE_init(arg)
    -- so damage starts on entity core
    -- then is copied to the form here
    self.damage = self.form.damage
    self.piercing = false
    self.has_hit = false
    self.moving_age = 0.03 -- time before it begins to move
                            -- anticipation frames make the shot feel 'heavier',
                            -- plus fixes bullet/flash origin issue for different frame rates
end



-- hitting a an entity
function PROJECTILE:hit(other)

    
    -- don't hit if he's invincible
    if other.Invincibility.on then return end

    -- stuff for piercing here

    -- bail if it's a bullet that's already hit
    if not self.piercing and self.has_hit then return end
    self.has_hit = true

    -- if there's a hit() function on the entity form, use it instead
    if self.form.hit then self.form:hit(other) return end

    -- apply damage
    other:takeDamage(self.damage)



    --unrefined knockback
    other.Transform.x = other.Transform.x + (self.Transform.vx * 4)
    other.Transform.y = other.Transform.y + (self.Transform.vy * 4)

    --flash
    other.Sprite:flash(0.05)

    -- --trigger invincibility frames
    if other.Invincibility then
        other:invincible()
    end

    --remove bullet
    -- piercing stuff down here
    self.remove = true
end




return PROJECTILE