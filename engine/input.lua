-- engine/input.lua
-- Basic input manager

local Input = {}
Input.bindings = {
    forward = "w",
    back = "s",
    strafe_left = "a",
    strafe_right = "d",
    turn_left = "left",   -- Optional keyboard turning
    turn_right = "right", -- Optional keyboard turning
    fire = "mouse1",
    alt_fire = "mouse2",
    jump = "space",
    crouch = "ctrl", -- Note: LÖVE uses "lctrl" or "rctrl"
    reload = "r",
    use = "e",
    weapon1 = "1",
    weapon2 = "2",
    weapon3 = "3",
    -- Add more as needed
}

Input.state = {} -- Stores current input state
Input.mouseDelta = { dx = 0, dy = 0 }

function Input.setup()
    -- Initialize state table
    for action, key in pairs(Input.bindings) do
        Input.state[action] = { down = false, pressed = false, released = false }
    end
    Input.state.mouse_dx = 0
    Input.state.mouse_dy = 0
end

-- Call this at the beginning of love.update
function Input.getState(dt)
    -- Reset pressed/released flags
    for action, s in pairs(Input.state) do
        if type(s) == "table" then
            s.pressed = false
            s.released = false
        end
    end

    -- Update keyboard state
    for action, key in pairs(Input.bindings) do
        if string.sub(key, 1, 5) ~= "mouse" then -- Check keyboard keys
            local currentlyDown = love.keyboard.isDown(key)
            if currentlyDown and not Input.state[action].down then
                Input.state[action].pressed = true
            elseif not currentlyDown and Input.state[action].down then
                 Input.state[action].released = true
            end
            Input.state[action].down = currentlyDown
        end
    end

     -- Update mouse button state (simplified - add pressed/released logic)
     Input.state.fire.down = love.mouse.isDown(1)
     Input.state.alt_fire.down = love.mouse.isDown(2)
     -- TODO: Add proper pressed/released logic for mouse buttons if needed

    -- Store and reset mouse delta
    Input.state.mouse_dx = Input.mouseDelta.dx
    Input.state.mouse_dy = Input.mouseDelta.dy
    Input.mouseDelta = { dx = 0, dy = 0 } -- Reset for next frame

    return Input.state
end

-- Callbacks from main.lua
function Input.keyPressed(key, scancode, isrepeat)
    -- Can be used for single-press actions (like UI interaction) if needed
end

function Input.keyReleased(key, scancode)
    -- Can be used if needed
end

function Input.mouseMoved(dx, dy)
    Input.mouseDelta.dx = Input.mouseDelta.dx + dx
    Input.mouseDelta.dy = Input.mouseDelta.dy + dy
end

function Input.mousePressed(button)
    -- Update pressed state immediately if needed for specific actions
    if button == 1 and Input.bindings.fire == "mouse1" then Input.state.fire.pressed = true end
    if button == 2 and Input.bindings.alt_fire == "mouse2" then Input.state.alt_fire.pressed = true end
end

function Input.mouseReleased(button)
     -- Update released state immediately if needed
    if button == 1 and Input.bindings.fire == "mouse1" then Input.state.fire.released = true end
    if button == 2 and Input.bindings.alt_fire == "mouse2" then Input.state.alt_fire.released = true end
end


return Input