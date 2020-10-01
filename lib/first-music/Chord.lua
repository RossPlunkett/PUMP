local class = require("lib.Class")

local Chord = class:derive("Chord")

local first_string = love.audio.newSource("assets/notes/polyphase/A01.wav", "static")
first_string:setVolume(0.19)

first_string:play()

-- how are these chords returned?

function Chord:new()
    self:reset()
end

function Chord:reset() -- for changing shords
    self.root_pos = nil -- 0 is "A, 440 Hz (tunable)"
    self.root_name = nil
    self.root_frequency = nil
end

-- generates a table of chromatic scale degrees 
function Chord:generate_chord_arp(root_name, scale_type)

    --self:reset()

    self.root_name = root_name

    if root_name == "A" then self.root_pos = 0
    elseif root_name == "A#" or root_name == "Bb" then self.root_pos = 1
    elseif root_name == "B" then self.root_pos = 2
    elseif root_name == "C" then self.root_pos = 3
    elseif root_name == "C#" or root_name == "Db" then self.root_pos = 4
    elseif root_name == "D" then self.root_pos = 5
    elseif root_name == "D#" or root_name == "Eb" then self.root_pos = 6
    elseif root_name == "E" then self.root_pos = 7
    elseif root_name == "F"then self.root_pos = 8
    elseif root_name == "F#" or root_name == "Gb" then self.root_pos = 9
    elseif root_name == "G" then self.root_pos = 10
    elseif root_name == "G#" or root_name == "Ab" then self.root_pos = 11
    end
    
    self.root_frequency = 440 * math.pow(2.718281828, (0.057762265 * self.root_pos))

    local degrees = {}

    if scale_type == "maj" then
        degrees = {0, 0, 2, 4, 7, 11, 12, 12, 16, 19, 24, 24}
    elseif scale_type == "min" then
        degrees = {-12,-5, 0, 0, 2, 3, 7, 10, 12, 12}
    elseif scale_type == "dom" then
        degrees = {0, 0, 2, 4, 7, 10, 12, 12}
    elseif scale_type == "dim1" then
        degrees = {0, 0, 2, 3, 5, 6, 8, 9, 10, 12, 12}
    elseif scale_type == "dim2" then
        degrees = {0, 0, 1, 3, 4, 6, 7, 9, 11, 12, 12}
    end

    -- should be a crossover between chords that finds the closest frequency for the next chord from the last played note- smooth chordal transitions

    local ratios_from_root = {}

    for i = 1, #degrees do
        ratios_from_root[#ratios_from_root + 1] = math.pow(2.718281828, (0.057762265 * degrees[i]))
    end



    local sample_pitch = 440

    if first_string:isPlaying() then
        first_string:stop()
    end

    --first_string:setLooping(true) -- can use looping for synthy stuff
    local roll = math.random(#ratios_from_root)
    first_string:setPitch((self.root_frequency * ratios_from_root[roll]) / sample_pitch)
    first_string:play()


end









return Chord