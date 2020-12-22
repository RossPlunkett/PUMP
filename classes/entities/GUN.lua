local ENTITY = require('classes.entities.ENTITY')

-- needs basic entity stuff

local GUN = ENTITY:derive('GUN')

-- called GUN_init to not collide init() function names
function GUN:GUN_init(arg)

    self.gun_name = arg.gun_name or "no gun name!" 
    self.damage = arg.damage
    self.proj_type = arg.proj_type
    self.num_shots = arg.num_shots
    self.cooldown = arg.cooldown
    self.cooldown_timer = 0 -- zero for first shot
    self.cooling = false
    self.inaccuracy = arg.inaccuracy or 0
    self.base_proj_speed = arg.base_proj_speed
    self.automatic = arg.automatic or false
    self.kickback = arg.kickback or 0
    self.recoil = arg.recoil or 0
    self.magnitude = arg.magnitude or 20
    -- this one... will it be on the arg like this?
    if sprite_atlas then default_atlas = sprite_atlas end
    -- should only update certain stuff if it's equipped?
    self.equipped = false
    -- holstered is for inactive weapon
    self.holstered = false

    self.cron_table = {}

end

function GUN:cron(arg)
-- for guns like the M16 and shotgun that need to shoot over time
-- arg is in indexed array of shots to take
self.cron_table = {1000, 500}


end

function GUN:shoot(x, y, r_trig) -- these are directionally summed
    -- if the entity form has it's own shoot function, do that instead
    if self.form.shoot then GUN.form:shoot(x, y, r_trig) return end
    if self.cooldown_timer <= 0 then
        local i = 1
        while i <= self.num_shots do

            local RSXA = x
            local RSYA = y

            -- quick fix for nonstick
            if RSXA == 0 and RSYA == 0 then
                RSXA = self.RSXA
                RSYA = self.RSYA
            end

            if (not RSXA) and (not RSYA) then
                -- need to translate gun angle into a bullet heading
            end
    
            -- this seems to put shots more on the outside of the area than inside
            -- maybe an easing function here
            local x_inaccuracy = (math.random() * self.inaccuracy) - (self.inaccuracy * 0.5)
            x_inaccuracy = x_inaccuracy + x_inaccuracy
            local y_inaccuracy = (math.random() * self.inaccuracy) - (self.inaccuracy * 0.5)
            y_inaccuracy = y_inaccuracy + y_inaccuracy
    
            -- add in/implement the inaccuracy
            -- just do this in radians based on the gun angle?
            RSXA = RSXA + x_inaccuracy
            RSYA = RSYA + y_inaccuracy

            -- re-sum after inaccuracy to keep bullet speed consistent
            local sum = math.abs(RSXA) + math.abs(RSYA) 
            RSXA = RSXA / sum
            RSYA = RSYA / sum

            -- apply kickback to the holding entity
            self.holder.Transform.x = self.holder.Transform.x - (RSXA * self.kickback)
            self.holder.Transform.y = self.holder.Transform.y - (RSYA * self.kickback)

            -- apply recoil to gun itself
            self.Transform.x = self.Transform.x - (RSXA * self.recoil)
            self.Transform.y = self.Transform.y - (RSYA * self.recoil)

            
            
            -- add projectile velocity from self
            RSXA = RSXA * self.base_proj_speed
            RSYA = RSYA * self.base_proj_speed

            -- this stores it on the ent
            self.RSXA, self.RSYA = RSXA, RSYA
    
            
            -- shooting here
            self.form:makeProjectile()
            -- end
            
            -- shake the camera
            Camera:startShake(RSXA, RSYA, 1, 0.2, 0.05)

            -- end stuff
            self.cooling = true
            self.cooldown_timer = self.cooldown - self.cooldown_timer -- last part adds in extra time used before frame 
                                                        --- to help keep firing speed consistent with lower frame rates
            

            i = i + 1
        end
    end
end


function GUN:GUN_update(dt)



    if self.equipped and self.cooling then
        self.cooldown_timer = self.cooldown_timer - dt
        if self.cooldown_timer <= 0 then
            self.cooling = false
        end
    end

    if #self.cron_table > 0 then
        for i = #cron_table, 1, -1 do
            local cron = self.cron_table[i]
            cron = cron - dt
            if cron <= 0 then
                table.remove(self.cron_table) -- pops off last number
                self:shoot()
            end
        end
    end
end
GUN.UF[#GUN.UF + 1] = 'GUN_update'

function GUN:drawName()
    if self.in_reach then -- gun name drawing
        love.graphics.printf(self.gun_name, self.Transform.x-#self.gun_name*2, self.Transform.y-16,120, 'left')
    end
end

-- shadow-altering code for guns is here

function GUN:equip(holder)
    self.holder = holder
    self.equipped = true
    self.holstered  = false
    -- 'equipped' shadow offset
    self.Shadow.yoffset = 3
end

function GUN:holster(holder)
    self.holder = holder
    self.holstered = true
    self.equipped = false
    -- 'holstered' shadow offset
    self.Shadow.yoffset = self.Shadow.OG_yoffset
end

function GUN:drop() -- happens when it's dropped
    self.equipped = false
    self.holstered = false
    self.holder = nil
    -- shadow offset when sitting on the ground
    self.Shadow.yoffset = self.Shadow.OG_yoffset
end


return GUN