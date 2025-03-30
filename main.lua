-- main.lua
-- Main entry point and game loop

-- Require necessary modules (adjust paths as needed)
local Input = require("engine.input")
local Assets = require("engine.assets")
local Renderer = require("engine.renderer")
local World = require("game.world")
local Player = require("game.player")
local UI = require("game.ui")
local Level = require("game.level")
local Camera = require("engine.camera")

local player
local currentLevel
local camera

function love.load()
    print("Loading Chi-Town Clash...")
    love.mouse.setRelativeMode(true) -- Lock mouse to window for FPS controls

    Assets.load() -- Load game assets (conceptually)
    Input.setup()  -- Setup input bindings

    -- Initialize camera (position will be tied to player)
    camera = Camera:new({ x = 0, y = 0 }, 0) -- Position, initial angle

    -- Initialize world (manages entities)
    World.initialize()

    -- Create the player instance
    -- Starting position, angle, health, etc. from level data ideally
    player = Player:new({ x = 5, y = 5 }, 0, 100)
    World.addGameObject(player)
    camera:setTarget(player) -- Make camera follow player

    -- Load the first level
    currentLevel = Level:new("maps/level1.txt") -- Assuming a simple map format
    currentLevel:load()
    World.setLevel(currentLevel) -- Provide level geometry/data to the world

    -- Initialize UI
    UI.initialize(player)

    -- Initialize the renderer (passing necessary components)
    Renderer.initialize(camera, currentLevel) -- Renderer needs camera and level data

    print("Game Loaded.")
end

function love.update(dt)
    -- Get input state
    local inputState = Input.getState(dt)

    -- Update player based on input
    player:update(dt, inputState, World) -- Pass world for collision checks

    -- Update camera based on player movement and mouse look
    camera:update(dt, inputState)

    -- Update game world (enemies, projectiles, etc.)
    World.update(dt, player) -- Pass player for AI targeting

    -- Update UI elements if needed (e.g., animations)
    UI.update(dt)
end

function love.draw()
    -- 1. Render the 3D world (using the conceptual renderer)
    Renderer.drawWorld(player) -- Pass player for context (e.g., weapon model)

    -- 2. Draw game objects (sprites/billboards in a raycaster/pseudo-3D)
    Renderer.drawGameObjects(World.getVisibleObjects(camera)) -- Pass only potentially visible objects

    -- 3. Draw the player's weapon
    Renderer.drawWeaponViewModel(player:getCurrentWeapon())

    -- 4. Draw the UI / HUD overlay
    love.graphics.push("all") -- Isolate UI drawing state
    love.graphics.origin()     -- Reset coordinate system for UI
    UI.draw()
    love.graphics.pop()        -- Restore previous drawing state
end

function love.keypressed(key, scancode, isrepeat)
    Input.keyPressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key, scancode)
    Input.keyReleased(key, scancode)
end

function love.mousemoved(x, y, dx, dy)
    Input.mouseMoved(dx, dy) -- Pass relative movement
end

function love.mousepressed(x, y, button, istouch, presses)
    Input.mousePressed(button)
end

function love.mousereleased(x, y, button, istouch, presses)
    Input.mouseReleased(button)
end

function love.quit()
    print("Exiting Chi-Town Clash.")
    -- Perform any cleanup here
end