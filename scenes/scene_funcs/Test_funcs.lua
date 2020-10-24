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
        
        if the_entity.SEP ~= nil then
            enemies[#enemies + 1] = i
        elseif the_entity.SBP ~= nil then
            bullets[#bullets + 1] = i
        end

        if the_entity.Player ~= nil
        or the_entity.PlantZombie ~= nil
        or the_entity.MaskFox ~= nil
        then
            creatures[#creatures + 1] = i
        end


        if the_entity.PlantZombie
        or the_entity.MaskFox
        then
            mobs[#mobs + 1] = i
        end



        
       

        if the_entity.BasicBullet ~= nil then
        bbs[#bbs + 1] = i
        elseif the_entity.Missile ~= nil then
        missiles[#missiles + 1] = i
        elseif the_entity.Tree ~= nil then
        trees[#trees + 1] = i
        elseif the_entity.Player ~= nil then
        players[#players + 1] = i
        elseif the_entity.Gun ~= nil then
        guns[#guns + 1] = i
        elseif the_entity.PlantZombie ~= nil then
        plant_zombies[#plant_zombies + 1] = i
        else
        end

        ::skip:: -- [goto skip] to skip iteration

    end


    -- target missiles if they're untargeted
    for i = 1, #missiles do
        if not entities[missiles[i]].form.target_transform then
            -- only does 1 player atm -- BADMULTI
            entities[missiles[i]].form:target(entities[players[1]].Transform)
        end
    end



    for i = 1, #bbs do
        for q = 1, #mobs do

            local bullet = entities[bbs[i]].form
            local mob = entities[mobs[q]].form

            if bullet.entity.CircleCollider:CC(mob.transform) then  
                local msuv, amount = Sat.Collide(bullet.entity.PolygonCollider.world_vertices, mob.entity.PolygonCollider.world_vertices)
                if msuv ~= nil then

                    mob.hp = mob.hp - 20 -- need to implement bullet damage
                    -- and bullet knockback
                    mob.transform.x = mob.transform.x + (bullet.transform.vx * 20)
                    mob.transform.y = mob.transform.y + (bullet.transform.vy * 20)

                    if mob.hp <= 0 then
                        mob.machine:change("KOed")
                    end

                    bullet.entity.remove = true

                end

            end
        end
    end


    -- collides creatures with the trees
    -- should filter out surrounded trees eventually

    -- scene.alternate_frames.world_collision_counter = scene.alternate_frames.world_collision_counter - 1
    -- if scene.alternate_frames.world_collision_counter <= 0 then
        
    -- scene.alternate_frames.world_collision_counter = scene.alternate_frames.world_collision
    -- for i = 1, #creatures do
    --     local creature = entities[creatures[i]]
    --     for q = 1, #trees do
    --         local tree = entities[trees[q]]
    --         if creature.CircleCollider:CC(tree.Transform) then
    --             local msuv, amount = Sat.Collide(creature.PolygonCollider.world_vertices, tree.PolygonCollider.world_vertices)
    --             if msuv ~= nil then
    --                 -- this part pushes the creature away from the tree
    --                 local sepDir = Vector2(creature.Transform.x - tree.Transform.x, creature.Transform.y - tree.Transform.y)

    --                 if not U.same_sign(sepDir.x, msuv.x) then msuv.x = msuv.x * -1 end
    --                 if not U.same_sign(sepDir.y, msuv.y) then msuv.y = msuv.y * -1 end
            
    --                  creature.Transform.x = creature.Transform.x + msuv.x * amount
    --                  creature.Transform.y = creature.Transform.y + msuv.y * amount
                    
    --             end
    --         end
    --     end
    -- end
    -- end -- alternate frame processing conditional

    -- -- thie one checks each bullet against each missile
    -- local used_bullets = {} -- used_bullets
    -- for i = 1, #bbs do
    --     local bullet = entities[bbs[i]] -- bullet entity
    --     if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
    --         if #missiles == 0 then break end
    --         for q = 1, #missiles do
    --             local missile = entities[missiles[q]]
    --             -- right here - if the circle colliders collide, it does the poly
    --             if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit two things this frame... probably not needed
    --                 if bullet.CircleCollider:CC(missile.Transform) then
    --                     local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, missile.PolygonCollider.world_vertices)
    --                     if msuv ~= nil then
    --                         missile.remove = true
    --                         used_bullets[#used_bullets + 1] = i
    --                         bullet.remove = true
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    --new collision function for checking Bullets against mobs using [.form] and HP inheritance
    -- much slicker this way
    
 



    -- -- checks bullets against enemies, any entity with a SEP component
    -- used_bullets = {}
    -- for i = 1, #bullets do
    --     local bullet = entities[bullets[i]] -- bullet entity
    --     if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
    --         if #enemies == 0 then break end
    --         for q = 1, #enemies do
    --             local enemy = entities[enemies[q]]
    --             -- right here - if the circle colliders collide, it does the poly
    --             if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit two things this frame... probably not needed
    --                 if bullet.CircleCollider:CC(enemy.Transform) then
    --                     local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, enemy.PolygonCollider.world_vertices)
    --                     if msuv ~= nil
    --                     and enemy.SEP.hp > 0 then -- and enemy is still alive
    --                         enemy.Sprite:flash(0.05)
    --                         -- SEP = Standard Entity Properties
    --                         -- SPP = Standard Projectile Properties

    --                         -- enemy takes damage
    --                         enemy.SEP.hp = enemy.SEP.hp - bullet.SBP.damage
                            
    --                         -- enemy gets pushed back
    --                         enemy.Transform.x = enemy.Transform.x + (bullet.Transform.vx * bullet.SBP.knockback)
    --                         enemy.Transform.y = enemy.Transform.y + (bullet.Transform.vy * bullet.SBP.knockback)

    --                         if enemy.SEP.hp <= 0 then
    --                             enemy.Machine:change("KOed") -- this can easily be a universal state
    --                         end
    --                         used_bullets[#used_bullets + 1] = i
    --                         -- will later trigger an explosion state
    --                         bullet.remove = true
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- -- remove the hit bullets from [bbs] here? maybe not worth it
    -- for i = #bbs, 1, -1 do
    --     table.remove(bbs, bbs[i])
    -- end

    -- -- check each bullet against each tree
    -- used_bullets = {}
    -- for i = 1, #bbs do
    --     local bullet = entities[bbs[i]] -- bullet entity
    --     if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
    --         if #trees == 0 then break end
    --         for q = 1, #trees do
    --             local tree = entities[trees[q]]
    --             -- right here - if the circle colliders collide, it does the poly
    --             if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit to things this frame... probably not needed
    --                 if bullet.CircleCollider:CC(tree.Transform) then
    --                     local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, tree.PolygonCollider.world_vertices)
    --                     if msuv ~= nil then
    --                         used_bullets[#used_bullets + 1] = i
    --                         bullet.remove = true
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end

    -- see if the player is standing by a gun and record distances from guns
    local distances = {}
    for i = 1, #players do
        local player = entities[players[i]]
        for q = 1, #guns do
            local gun = entities[guns[q]]
            -- add them to the nearby guns if they collide,
            if player.CircleCollider:CC(gun.Transform)
            -- AND if they aren't currently being used
            and not gun.Gun.equipped
            and not gun.Gun.held then
                distances[#distances + 1] = {q, player.CircleCollider:get_d()} -- get_d grabs the last recorded distance from the CircleCollider component
            end
        end
    end

    --false out all guns as not in_reach
    if #guns ~= 0 then
        for i = 1, #guns do
            entities[guns[i]].Gun.in_reach = false
        end
    end
    
    for i = 1, #players do
        local player = entities[players[i]]
        if #distances == 0 then -- player not standing by any guns
            player.Player.closest_gun = nil --- DOTP
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
            entities[guns[closest]].Gun.in_reach = true -- in_reach seems fragile - perhaps this behavior can come from the 
            player.Player.closest_gun = entities[guns[closest]]

        end
    end
end





return do_collisions