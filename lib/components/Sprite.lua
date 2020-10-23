local Class = require("lib.Class")
local Vector2 = require("lib.Vector2")
local Anim = require("lib.Animation")
local Rect = require("lib.Rect")
local U = require("lib.Utils")
--local cron = require()

local Sprite = Class:derive("Sprite")
--where x,y is the center of the sprite
--
--Note: This component assumes the presence of a Transform component!
--
function Sprite:new(atlas, w, h, color, shadow)
    self.w = w
    self.h = h
    self.flip = Vector2(1,1)
    self.atlas = atlas
    self.animations = {}
    self.current_anim = ""
    self.quad = love.graphics.newQuad(0,0, w, h, atlas:getDimensions())
    self.tintColor = color or {1,1,1,1}
    self.origin = Vector2(w/2, h/2) -- defaults to center
    self.shadow = shadow or false -- no shadow by default

    if self.shadow then
        -- if we want to be able to unhook() this,
        -- we have to name the anonymous function, 
        -- then hook it by that name, so we can unhook() it with that same name.
        -- unhooking the exact same completely anonymouse function does not work
        -- when this makes sense you can delete this comment
        _G.events:hook("draw shadows", function() self:drawShadow() end)
    end

    self.flash_shader = love.graphics.newShader[[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
            vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
            number average = (pixel.r+pixel.b+pixel.g);
            pixel.r = average;
            pixel.g = average + 0.2; // slightly green rn
            pixel.b = average;
            return pixel;
          }
    ]]

    self.flashing = false
    self.flash_timer = nil
          
end

function Sprite:set_origin(origin, customx, customy)
    if origin == "bottom" then 
        self.origin.x = self.w * 0.5
        self.origin.y = self.h
    elseif origin == "top" then 
        self.origin.x = self.w * 0.5
        self.origin.y = 0
    elseif origin == "left" then
        self.origin.x = 0
        self.origin.y = self.h * 0.5
    elseif origin == "right" then
        self.origin.x = self.w
        self.origin.y = self.h * 0.5
    elseif origin == "center" then
        self.origin.x = self.w * 0.5
        self.origin.y = self.y * 0.5
    elseif origin == "custom" then
        -- custom values are from 0.0 to 1.0
        -- 0.0 -> 0.1 X: left to right
        -- 0.0 -> 0.1 Y: top to bottom
        self.origin.x = self.w * customx
        self.origin.y = self.h * customy
    end
    
end

function Sprite:on_start()
    assert(self.entity.Transform ~=nil, "Sprite component requires a Transform component to exist in the attached entity!")
    self.tr = self.entity.Transform
end

function Sprite:animate(anim_name)
    if self.current_anim ~= anim_name and self.animations[anim_name] ~= nil then
        self.current_anim = anim_name
        self.animations[anim_name]:reset()
        self.animations[anim_name]:set(self.quad)
    elseif self.animations[anim_name] == nil then
        -- I added checking if anim_name is not null
        if not anim_name then
            print("no animation name entered")
            return
        end
        assert(false, anim_name .. " animation not found!")
    end
end

function Sprite:flip_h(flip)
    if flip then
        self.flip.x = -1
    else
        self.flip.x = 1
    end
end

function Sprite:flip_v(flip)
    if flip then
        self.flip.y = -1
    else
        self.flip.y = 1
    end
end

function Sprite:tint(tint)
    self.tintColor = {tint[1] or 1, tint[2] or 1, tint[3] or 1, tint[4] or 1}
end

function Sprite:animation_finished()
    if self.animations[self.current_anim] ~= nil then
        return self.animations[self.current_anim].done
    end
    return true
end

function Sprite:add_animations(animations)
    assert(type(animations) == "table", "animations parameter must be a table!")
    for k,v in pairs(animations) do
        self.animations[k] = v
    end
end

function Sprite:update(dt)
    if self.animations[self.current_anim] ~= nil then
        self.animations[self.current_anim]:update(dt, self.quad)
    end
    
    -- FLASHING
    -- cancel global speed for this?
    if self.flashing then
        self.flash_timer = self.flash_timer - (dt / Time.speed)
        
        if self.flash_timer <= 0 then
            self.flashing = false
            self.flash_timer = nil
        end
    end
end

function Sprite:rect()
    return Rect.create_centered(self.tr.x , self.tr.y, self.w * self.tr.sx, self.h * self.tr.sy)
end

function Sprite:poly()
    local x = (self.w / 2 * self.tr.sx)
    local y = (self.h / 2 * self.tr.sy)
    
    local rx1,ry1 = U.rotate_point(-x, -y, self.tr.angle, self.tr.x, self.tr.y)
    local rx2,ry2 = U.rotate_point( x, -y, self.tr.angle, self.tr.x, self.tr.y)
    local rx3,ry3 = U.rotate_point( x,  y, self.tr.angle, self.tr.x, self.tr.y)
    local rx4,ry4 = U.rotate_point(-x,  y, self.tr.angle, self.tr.x, self.tr.y)
    local p ={ rx1, ry1, rx2, ry2, rx3, ry3, rx4, ry4 }
    
    return p
end

function Sprite:flash(time)
    love.graphics.setShader(self.flash_shader)
    self.flashing = true
    self.flash_timer = time
end

local function resetFlash()
    
end


function Sprite:draw()
    
    
    if self.flashing then
        love.graphics.setShader(self.flash_shader)
    end
    
    self:tint({1, 1, 1, 1})
    love.graphics.setColor(self.tintColor)
    love.graphics.draw(self.atlas, self.quad, self.tr.x, self.tr.y, self.tr.angle,self.flip.x, self.flip.y, self.origin.x, self.origin.y)
    

    love.graphics.setShader()
    if self.flashing then
        love.graphics.setShader()
    end
    
    
end

function Sprite:drawShadow() -- put this below draw() to make it intuitive - this happens after the draw()
    -- optimized: did the setColor before and after the shadow event to remove all of the coloring here
                                      --            offset to the height of the sprite and put it in the center      flip it over
    love.graphics.draw(self.atlas, self.quad, self.tr.x, self.tr.y + self.h + (self.h/2) , self.tr.angle ,  self.flip.x, -self.flip.y, self.origin.x, self.origin.y)
end



return Sprite