Key = require("lib.Keyboard")
Tween = require("lib.Tween")


local gpm = require("lib.GamepadMgr")
GPM = gpm({"assets/gamecontrollerdb.txt"}, false)

Camera = require("lib/Camera")
Camera:init()

local time = require("lib.Time")
Time = time()
time = nil

local SM = require("lib.SceneMgr")
local Event = require("lib.Events")


--TODO before PUMP

-- move stuff out of the player





math.randomseed(os.time()) -- can be seeded

local sm = {}

function love.load()

    --Love2D game settings
    love.graphics.setDefaultFilter('nearest', 'nearest')
    local font = love.graphics.newFont("assets/SuperMario256.ttf", 20)
    --set the font to the one above
    love.graphics.setFont(font)

    _G.events = Event(false)

    Key:hook_love_events()

    --.whole game is spawned with this line:
    sm = SM("scenes", {"MainMenu", "Test", "TweenTest"})

    --these next ones activate the scene
    --sm:switch("MainMenu")
    -- sm:switch("TweenTest")
    sm:switch("Test")

end


function love.update(dt)
    if dt > 0.035 then return end

    Time:update(dt)
    dt = Time:getDt(dt)
    
    if Key:key_down("escape") then
        love.event.quit()
    end
    
    sm:update(dt)
    Key:update(dt)
    GPM:update(dt)
    Tween.update(dt)

    Camera:update(dt)



end

function love.draw()
    Camera:set()
    sm:draw()
    Camera:unset()
end




