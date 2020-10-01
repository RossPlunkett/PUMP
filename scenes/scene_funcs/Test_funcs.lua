local U = require("lib.Utils")
local Sat = require("lib.Sat")
local Vector2 = require("lib.Vector2")

local Force = require("lib/components/physics/Force")





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
    for i = 1, #entities do

        if entities[i].SEP ~= nil then
            enemies[#enemies + 1] = i
        elseif entities[i].SBP ~= nil then
            bullets[#bullets + 1] = i
        end

        if entities[i].Player ~= nil
        or entities[i].PlantZombie ~= nil
        or entities[i].MaskFox ~= nil
        then
            creatures[#creatures + 1] = i
        end
        
       

        if entities[i].BasicBullet ~= nil then
        bbs[#bbs + 1] = i
        elseif entities[i].Missile ~= nil then
        missiles[#missiles + 1] = i
        elseif entities[i].Tree ~= nil then
        trees[#trees + 1] = i
        elseif entities[i].Player ~= nil then
        players[#players + 1] = i
        elseif entities[i].Gun ~= nil then
        guns[#guns + 1] = i
        elseif entities[i].PlantZombie ~= nil then
        plant_zombies[#plant_zombies + 1] = i
        else
        end
    end

    for k,v in ipairs(creatures) do
        if math.random() <= 0.05 then
            --entities[v]:add(Force(0.5, 0.5, 100, 1))
        end
    end

    -- target missiles if they're untargeted
    for i = 1, #missiles do
        if not entities[missiles[i]].Missile.target_transform then
            -- only does 1 player atm
            entities[missiles[i]].Missile:target(entities[players[1]].Transform)
        end
    end



    -- collides creatures with the trees
    -- should filter out surrounded trees eventually
    scene.alternate_frames.world_collision_counter = scene.alternate_frames.world_collision_counter - 1
    if scene.alternate_frames.world_collision_counter <= 0 then
        
    scene.alternate_frames.world_collision_counter = scene.alternate_frames.world_collision
    for i = 1, #creatures do
        local creature = entities[creatures[i]]
        for q = 1, #trees do
            local tree = entities[trees[q]]
            if creature.CircleCollider:CC(tree.Transform) then
                local msuv, amount = Sat.Collide(creature.PolygonCollider.world_vertices, tree.PolygonCollider.world_vertices)
                if msuv ~= nil then
                    -- this part pushes the creature away from the tree
                    local sepDir = Vector2(creature.Transform.x - tree.Transform.x, creature.Transform.y - tree.Transform.y)

                    if not U.same_sign(sepDir.x, msuv.x) then msuv.x = msuv.x * -1 end
                    if not U.same_sign(sepDir.y, msuv.y) then msuv.y = msuv.y * -1 end
            
                     creature.Transform.x = creature.Transform.x + msuv.x * amount
                     creature.Transform.y = creature.Transform.y + msuv.y * amount
                    
                end
            end
        end
    end
    end -- alternate frame processing conditional

    -- thie one checks each bullet against each missile
    local used_bullets = {} -- used_bullets
    for i = 1, #bbs do
        local bullet = entities[bbs[i]] -- bullet entity
        if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
            if #missiles == 0 then break end
            for q = 1, #missiles do
                local missile = entities[missiles[q]]
                -- right here - if the circle colliders collide, it does the poly
                if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit two things this frame... probably not needed
                    if bullet.CircleCollider:CC(missile.Transform) then
                        local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, missile.PolygonCollider.world_vertices)
                        if msuv ~= nil then
                            missile.remove = true
                            used_bullets[#used_bullets + 1] = i
                            bullet.remove = true
                        end
                    end
                end
            end
        end
    end

    -- checks bullets against enemies, any entity with a SEP component
    used_bullets = {}
    for i = 1, #bullets do
        local bullet = entities[bullets[i]] -- bullet entity
        if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
            if #enemies == 0 then break end
            for q = 1, #enemies do
                local enemy = entities[enemies[q]]
                -- right here - if the circle colliders collide, it does the poly
                if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit two things this frame... probably not needed
                    if bullet.CircleCollider:CC(enemy.Transform) then
                        local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, enemy.PolygonCollider.world_vertices)
                        if msuv ~= nil
                        and enemy.SEP.hp > 0 then -- and enemy is still alive
                            enemy.Sprite:flash(0.05)
                            -- SEP = Standard Entity Properties
                            -- SPP = Standard Projectile Properties

                            -- enemy takes damage
                            enemy.SEP.hp = enemy.SEP.hp - bullet.SBP.damage
                            
                            -- enemy gets pushed back
                            enemy.Transform.x = enemy.Transform.x + (bullet.Transform.vx * bullet.SBP.knockback)
                            enemy.Transform.y = enemy.Transform.y + (bullet.Transform.vy * bullet.SBP.knockback)

                            if enemy.SEP.hp <= 0 then
                                enemy.Machine:change("KOed") -- this can easily be a universal state
                            end
                            used_bullets[#used_bullets + 1] = i
                            -- will later trigger an explosion state
                            bullet.remove = true
                        end
                    end
                end
            end
        end
    end

    -- remove the hit bullets from [bbs] here? maybe not worth it
    for i = #bbs, 1, -1 do
        table.remove(bbs, bbs[i])
    end

    -- check each bullet against each tree
    used_bullets = {}
    for i = 1, #bbs do
        local bullet = entities[bbs[i]] -- bullet entity
        if not U.contains(used_bullets, i) then -- if this bullet hasn't already hit something
            if #trees == 0 then break end
            for q = 1, #trees do
                local tree = entities[trees[q]]
                -- right here - if the circle colliders collide, it does the poly
                if not U.contains(used_bullets, i) then -- make sure this bullet doesn't hit to things this frame... probably not needed
                    if bullet.CircleCollider:CC(tree.Transform) then
                        local msuv, amount = Sat.Collide(bullet.PolygonCollider.world_vertices, tree.PolygonCollider.world_vertices)
                        if msuv ~= nil then
                            used_bullets[#used_bullets + 1] = i
                            bullet.remove = true
                        end
                    end
                end
            end
        end
    end

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