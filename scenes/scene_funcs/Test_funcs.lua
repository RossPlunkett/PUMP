local U = require("lib.Utils")
local Sat = require("lib.Sat")
local Vector2 = require("lib.Vector2")

local Force = require("lib/components/physics/Force")


its_done = false -- garbage


local do_collisions =  function(scene)

    -- grab entities
    local entities = scene.em.entities

    -- this loop marks which entities are what
    local bbs = {}
    local missiles = {}
    local trees = {}
    local players = {}
    local guns = {}
    local plant_zombies = {}
    local enemies = {}
    local bullets = {}
    local creatures = {}
    local mobs = {}

    --iterate through all entities one time and index what and where they all are
    for i = 1, #entities do

        local the_entity = entities[i]

        -- if there is no [.form] yet, skip indexing for this entity

        -- this is important to remember for other procedural uses of the
        -- [.entities] array in the entitymanager, so it doesn't
        -- crash looking for the .form and not finding it
        -- assert(the_entity.form, "entity has no form!")
        if not the_entity.form then
            goto skip -- ::skip:: is at the bottom of this loop
        end

        local ent_name = the_entity.form.ent_name or "no-ent-name"
        

        if the_entity:is('CREATURE') then
            creatures[#creatures + 1] = i
        end


        if the_entity.PlantZombie
        or the_entity.MaskFox
        or the_entity.Missile
        then
            mobs[#mobs + 1] = i
        end



        
       

        if the_entity:is('PROJECTILE') then
        bullets[#bullets + 1] = i
        elseif the_entity.Missile then
        missiles[#missiles + 1] = i
        elseif the_entity:is('PLAYER') then
        players[#players + 1] = i
        elseif the_entity:is('GUN') then
        guns[#guns + 1] = i
        else
        end

        ::skip:: -- [goto skip] to skip iteration

    end

    NUM_PLAYERS = #players

    -- target missiles if they're untargeted
    -- needs to find the nearest player
    for i = 1, #missiles do
        if not entities[missiles[i]].form.target_transform then
            -- only does 1 player atm -- BADMULTI
            -- also this will crash if there's no player
            entities[missiles[i]].form:target(entities[players[1]].Transform)
        end
    end




    for i = 1, #bullets do
        local bullet = entities[bullets[i]]
        for q = 1, #mobs do
            -- piercing projectiles will check their ents_hit list and make sure it doesn't
            -- match any mobs here - if it doesn't it'll [goto skip_ent]


            local mob = entities[mobs[q]]

            if bullet.CircleCollider:CC(mob.Transform) then  
                local msuv, amount = Sat.Collide(
                                            bullet.PolygonCollider.world_vertices, 
                                            mob.PolygonCollider.world_vertices)
                if msuv ~= nil then

                    bullet:hit(mob) -- damage, knockback, flash from inheritance system


                end
            end
            ::skip_ent::
        end
        ::skip::  
    end
    
    --false out all guns as not in_reach
    if #guns ~= 0 then
        for i = 1, #guns do
            entities[guns[i]].in_reach = false
        end
    end
    -- see if the player is standing by a gun and record distances from guns
    for i = 1, #players do
        local distances = {}
        local player = entities[players[i]]
        for q = 1, #guns do
            local gun = entities[guns[q]]
            -- add them to the nearby guns if they collide,
            if player.CircleCollider:CC(gun.Transform)
            -- AND if they aren't currently being used
            and not gun.equipped
            and not gun.holstered then
                distances[#distances + 1] = {q, player.CircleCollider:get_d()} -- get_d grabs the last recorded distance from the CircleCollider component
            end

        end

        if #distances == 0 then -- player not standing by any guns
            player.closest_gun = nil --- DOTP
        else -- player standing by at least one gun
            -- [closest] represents index in local table [guns]
            local closest = distances[1][1]
            local min_dist = distances[1][2]
            for i = 1, #distances do
                if distances[i][2] < min_dist then
                    min_dist = distances[i][2]
                    closest = distances[i][1]
                end
            end
            -- in_reach means it's the closest gun to a player
            entities[guns[closest]].in_reach = true
            player.closest_gun = entities[guns[closest]]
        end
    end

end






return do_collisions