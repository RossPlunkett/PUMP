local Force = {}

--[[
1. Entities each have specific weights, and forces are of specific power
2. the total distance a force moves and entity is power / weight
3. each force takes place over a specified amount of time

4. to determine the distance for the current frame,
we take the current amount of time elapsed so far in the exertion,
and see exactly how far it moves between that time,
and that time plus the current dt.
and then of course add the current dt onto that elapsed time



]]

function Force:new()

    self.forces = {}

end

function Force:add(power, time, tween, vx, vy)

    local force = {
        power = power,
        time = time,
        tween = tween,
        vx = vx,
        vy = vy
    }

    table.add(self.forces, force)


-- power, time, tween type, direction (summed)

end

function Force:on_start()

end

function Force:update()
    -- bail if no forces
    if #self.forces < 1 then return end

end


return Force