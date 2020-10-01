local Class = require("lib.Class")


local Force = Class:derive("Force")

function Force:new(x_dir, y_dir, distance, time, ease_func)
    
--x_xir and y_dir are summed RSXA/RSYA style
--distance is in world-pixels
-- time is  in seconds
-- ease_func is the anymous easing function
self.x = x_dir
self.y = y_dir

-- to assign exactly how much to push this frame, it has to
-- keep track of how far it's traveled in the easingfunction
-- since the last frame and apply that to the entity's transform.
self.distance = distance

self.time = time
self.timer = time

-- these two 
self.tween_result = nil
self.prev_tween_result = nil

self.ease_func = ease_func

end

function Force:on_start()



end

function Force:update(dt)

self.timer = self.timer - dt
if self.timer <= 0 then
    self.entity:remove(self)
    return
end

if self.prev_tween_result == nil then
    self.prev_tween_result = 0
end

local ratio = self.timer / self.time

local tween = function(ratio) return math.pow(ratio -1, 3) + 1 end

self.tween_result = tween(ratio)

local move_amt = (self.tween_result - self.prev_tween_result) * self.distance

self.entity.Transform.x = self.entity.Transform.x + (move_amt * self.x)
self.entity.Transform.y = self.entity.Transform.y + (move_amt * self.y)




end


return Force