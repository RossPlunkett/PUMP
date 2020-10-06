Key = require("lib.Keyboard")
Tween = require("lib.Tween")
-- low rez thing
local maid64 = require ("lib.maid64")

local gpm = require("lib.GamepadMgr")
GPM = gpm({"assets/gamecontrollerdb.txt"}, false)

-- do not change else where
-- maybe use a table so it cant be changed somewhere?
Pixel_Window_X = 320
Pixel_Window_Y = 240

Camera = require("lib/Camera")
Camera:init()

local time = require("lib.Time")
Time = time()
time = nil

local SM = require("lib.SceneMgr")
local Event = require("lib.Events")
-- local world = require("lib.World")
-- World = world(200, 200, 10, 10, 20, 20)

--for debugging colliders and other related stuff
IsGizmoOn = true

--TODO before PUMP

-- move stuff out of the player





math.randomseed(os.time()) -- can be seeded

local sm = {}

function love.load()

    --maid settings
    --love.window.setMode(640, 480, {resizable=false, vsync=true, minwidth=200, minheight=200})
    love.window.setFullscreen(true)
    maid64.setup(Pixel_Window_X,Pixel_Window_Y,true)

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
    -- i moved the camera here because it has conflicts with the slowmotion effect
    Camera:update(dt)
    Time:update(dt)
    dt = Time:getDt(dt)
    
    if Key:key_down("escape") then
        love.event.quit()
    end
    
    sm:update(dt)
    Key:update(dt)
    GPM:update(dt)
    Tween.update(dt)




end

function love.draw()
    maid64.start()--starts the maid64 process
    Camera:set()
    sm:draw()
    Camera:unset()
    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end




