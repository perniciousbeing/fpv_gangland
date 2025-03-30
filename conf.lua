-- conf.lua
-- Configures the LÖVE game window and modules

function love.conf(t)
    t.window.width = 1280
    t.window.height = 720
    t.window.title = "Chi-Town Clash"
    t.window.vsync = 1                -- Use vsync for smoother rendering

    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false        -- Disable joystick if not needed
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false       -- We'll handle our own simple physics/collisions
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false         -- Disable touch if not needed
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = false
end