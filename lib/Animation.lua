local Class = require("lib.Class")
local Vector2 = require("lib.Vector2")

local Anim = Class:derive("Animation")

function Anim:new(xoffset, yoffset, w, h, frames, column_size, fps, loop)
    self.fps = fps
    if type(frames) == "table" then
        self.frames = frames
    else
        self.frames = {}
        for i = 1, frames do
            self.frames[i] = i
        end
    end
    self.column_size = column_size
    self.start_offset = Vector2(xoffset, yoffset)
    self.offset = Vector2()
    self.size = Vector2(w, h)
    --loop = false, playthrough once, otherwise, loop forever
    self.loop = loop == nil or loop

    if type(self.fps) == "table" then
        assert(#self.frames == #self.fps[1], "frames table and first table in fps must be the same length!")
        assert(#self.fps == 2 and type(self.fps[2] == "number"), "Second and last element of table self.fps must be a number!")
        self.variable_frames = true
        self.variable_frame_speed = self.fps[2] -- in case it's modified globally
    else
        self.variable_frames = false
    end
    self:reset()
end

function Anim:reset()

    self.index = 1
    self.done = false

    if self.variable_frames then
        self.timer = self.fps[1][self.index] / self.fps[2] -- calculates time for next frame
    else
        self.timer = 1 / self.fps
    end

    self.offset.x = self.start_offset.x + (self.size.x * ((self.frames[self.index] - 1) % (self.column_size)))
    self.offset.y = self.start_offset.y + (self.size.y * math.floor((self.frames[self.index] - 1) / self.column_size))
end

function Anim:set(quad)
    quad:setViewport(self.offset.x, self.offset.y, self.size.x, self.size.y)
end

function Anim:update(dt, quad)
    if #self.frames <= 1 then 
        self.done = true
        return

    elseif self.timer > 0 then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            self.index = self.index + 1

            if self.index > #self.frames then 
                if self.loop then
                    self.index = 1
                else
                    self.index = #self.frames
                    self.timer = 0
                    self.done = true
                end
            end

            if self.variable_frames then
                self.timer = self.fps[1][self.index] / self.fps[2] -- calculates time for next frame
            else
                self.timer = 1 / self.fps
            end

            self.offset.x = self.start_offset.x + (self.size.x * ((self.frames[self.index] - 1) % (self.column_size)))
            self.offset.y = self.start_offset.y + (self.size.y * math.floor((self.frames[self.index] - 1) / self.column_size))
            -- print( self.index .. " " .. self.offset.x .. " " .. self.offset.y)
            self:set(quad)
        end
    end
end

function Anim:calc_frame_time()
    if self.variable_frames then
        self.timer = self.fps[1][self.index] / self.fps[2] -- calculates time for next frame
    else
        self.timer = 1 / self.fps
    end
end 

-- variable frames

-- so. each frame has to have a variance, and the speed of the whole thing must be editable, probably drawing from fps.

return Anim