



local camera = {}
camera.x = 0 -- position
camera.y = 0
camera.xOffset = 0 -- offset
camera.yOffset = 0
camera.scaleX = 1 -- scale
camera.scaleY = 1
camera.rotation = 0 -- rotation around origin


function camera:init()
self.shaking = false
self.shake_time = 0.1 -- just a default, gets set w/every shake
self.shake_amount = 20 -- world-px, just a default as well
self.xShakeOffset = 0
self.yShakeOffset = 0

self.shakes = {}
end

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end


function camera:scale(sx, sy)
  self.scaleX = sx or 1
  self.scaleY = sy or 1
end
 
function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function camera:center(x, y, offset)
self.offset = offset or nil -- offset is optional table
local width, height = love.graphics.getDimensions()-- could be done in a coroutine
    
self.x = x - ((width * 0.5) * self.scaleX)
self.y = y - ((height * 0.5) * self.scaleY) -- changed this to Y recently

self.x = self.x + self.xOffset + self.xShakeOffset
self.y = self.y + self.yOffset + self.yShakeOffset

end

function camera:center_on_transform(transform)
    local width, height = love.graphics.getDimensions() -- could be done in a coroutine
        
    self.x = transform.x - ((width * 0.5) * self.scaleX)
    self.y = transform.y - ((height * 0.5) * self.scaleX)

    self.x = self.x + self.xOffset + self.xShakeOffset
    self.y = self.y + self.yOffset + self.yShakeOffset

end

function camera:setOffset(xoffset, yoffset)
  self.xOffset = xoffset
  self.yOffset = yoffset
end

function camera:startShake(x_dir, y_dir, amount, out_time, in_time) -- rotation?

  -- x_dir and y_dir are stick coordinates
  --amount is pixels to shake
  local shake = {
    x_dir=x_dir,
    y_dir=y_dir, 
    amount=amount,
    out_time=out_time, 
    in_time=in_time,
    timer=out_time+in_time
  }

  table.insert(self.shakes, shake)

end

function camera:shake(dt)
  self.xShakeOffset, self.yShakeOffset = 0, 0 -- reset offsets
  for i = #self.shakes, 1, -1 do
    self.shakes[i].timer = self.shakes[i].timer - dt
    local shake = self.shakes[i]
    if not (shake.timer <= 0) then
      --shaking here
      local time, ratio, tween_result, scaled_tween, xOffset, yOffset
      if shake.timer > shake.in_time then
        --out-shaking
        time = shake.out_time - (shake.timer - shake.in_time)
        ratio = time / shake.out_time 
        tween_result = math.pow(ratio, 5)
        scaled_tween = tween_result * shake.out_time
      else
        --in-shaking
        time = shake.timer
        ratio = time / shake.in_time 
        tween_result = ratio * (2 - ratio * ratio)
        scaled_tween = tween_result * shake.in_time
      end

      xOffset = shake.x_dir * (scaled_tween * shake.amount)
      yOffset = shake.y_dir * (scaled_tween * shake.amount)

      self.xShakeOffset = self.xShakeOffset + xOffset
      self.yShakeOffset = self.yShakeOffset + yOffset

    else
      -- if it's timed out, just remove it
      table.remove(self.shakes, i)
      if #self.shakes == 0 then
        self.xShakeOffset, self.yShakeOffset = 0, 0 -- reset offsets
      end
    end
  end
end



function camera:update(dt)

  dt = dt / Time.speed -- global speed cancel (?)

  if #self.shakes > 0 then
    self:shake(dt)
  end

  -- rotates around map origin (0, 0)
  -- self.rotation = self.rotation + 0.01
end

-- needs a dynamic scaling system where there can be many simultaneous zooms happening.
function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or sx or self.scaleY --allows for one arg
end

return camera