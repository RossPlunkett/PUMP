Key = require("lib.Keyboard")
Tween = require("lib.Tween")

<<<<<<< Updated upstream
=======



Key = require 'lib.Keyboard'
Mouse = require 'lib.Mouse'
Tween = require 'lib.Tween'

Physics = require 'lib.Physics'

LANGUAGE = "ENGLISH"

NUM_PLAYERS = 1;

-- gamepad support
>>>>>>> Stashed changes
local gpm = require("lib.GamepadMgr")
GPM = gpm({"assets/gamecontrollerdb.txt"}, false)


-- low rez thing
local maid64 = require ("lib.maid64")
gscreen = require('lib.sysl.pixel') --The mouse cursor thing -- and can also be used as shader changer
gscreen.load(1) -- Draw at x Size.
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


<<<<<<< Updated upstream
IsGizmoOn = true --for debugging colliders and other related stuff
GizmoVisibility = 0.2 -- alpha/ the opacity of the gizmo
FullScreenToggle = not true
=======
-- Gizmo lowers FPS significantly, so if you have low frame rates that is part of it
-- now Gizmo is automatically attached to each entity if IsGizmoOn is true
IsGizmoOn = false --for debugging colliders and other related stuff
GizmoVisibility = 0.4 -- alpha/ the opacity of the gizmo
FullScreenToggle = true
>>>>>>> Stashed changes
--TODO before PUMP

-- move stuff out of the player



math.randomseed(os.time()) -- can be seeded

local sm = {}

<<<<<<< Updated upstream
function love.load()
=======
-- comment the line above and uncomment these two to activate console
-- sm = {}
-- require('extlib.lovedebug')


function love.load(arg)

    if PROFILING then
        love.profiler = require('extlib/profile') 
        love.profiler.start()
    end

  -- this line enables debugging in ZeroBrane
    if arg and arg[#arg] == "-debug" then 
      require("mobdebug").start()
      require("mobdebug").off() --<-- turn the debugger off
      
    end

    love.mouse.setRelativeMode( false ) -- seems good right?
    cursor = love.mouse.newCursor("assets/gfx/cursor.png", 0, 0)
    love.mouse.setCursor(cursor)
>>>>>>> Stashed changes
    
    --maid settings
    --love.window.setMode(Pixel_Window_X*2,Pixel_Window_Y*2, {resizable=false, vsync=true, minwidth=200, minheight=200})
    love.window.setFullscreen(FullScreenToggle)
    maid64.setup(Pixel_Window_X,Pixel_Window_Y,false)

    --Love2D game settings
    love.graphics.setLineStyle('rough')-- sets the line to be rough 
    love.graphics.setDefaultFilter('nearest', 'nearest', 1)

    --local font = love.graphics.newFont("assets/fonts/ARCADECLASSIC.TTF", 20)
    --set the font to the one above
    -- using an image font is more crisp than TTF I dont know why it gets blurry tho the default filter is set
    -- anyway, I think it's nice ; so I can make a font just for the game :)
    local font = love.graphics.newImageFont("assets/fonts/Imagefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
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
<<<<<<< Updated upstream
    Tween.update(dt)
    -- Update Pixel
    gscreen.update(dt)




=======
    Tween:update(dt)
    
>>>>>>> Stashed changes
end

function love.draw()
    
    gscreen.start()
    maid64.start()--starts the maid64 process
    Camera:set()
    sm:draw()
    Camera:unset()
    gscreen.stop()
    -- Things drawn here will *not* scale.
    maid64.finish()--finishes the maid64 process
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end




