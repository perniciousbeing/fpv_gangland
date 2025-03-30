-- engine/camera.lua
-- Manages the first-person view

local Camera = {}
Camera.__index = Camera

function Camera:new(position, angle)
    local instance = setmetatable({}, Camera)
    instance.pos = { x = position.x, y = position.y } -- In 2D map space
    instance.z = 0.5 -- Player height off the ground (0 to 1 typically)
    instance.angle = angle -- Radians
    instance.pitch = 0 -- Looking up/down (radians) - for vertical look
    instance.fov = math.rad(75) -- Field of View
    instance.target = nil -- GameObject to follow (the player)
    instance.sensitivity = 0.003 -- Mouse sensitivity
    instance.maxPitch = math.rad(85)
    instance.minPitch = math.rad(-85)
    return instance
end

function Camera:setTarget(gameObject)
    self.target = gameObject
end

function Camera:update(dt, inputState)
    if self.target then
        -- Update position and angle based on the target (player)
        self.pos.x = self.target.pos.x
        self.pos.y = self.target.pos.y
        self.angle = self.target.angle
    end

    -- Update angle based on mouse movement
    local lookSpeed = self.sensitivity -- No dt multiplier for direct mouse input
    self.angle = self.angle + inputState.mouse_dx * lookSpeed
    -- Normalize angle
    self.angle = self.angle % (2 * math.pi)

    -- Update pitch based on mouse movement
    self.pitch = self.pitch - inputState.mouse_dy * lookSpeed -- Inverted Y-axis is common
    -- Clamp pitch
    self.pitch = math.max(self.minPitch, math.min(self.maxPitch, self.pitch))

    -- Optional: Keyboard turning (less common with mouse look)
    if inputState.turn_left.down then
        self.angle = self.angle - 2.0 * dt -- Adjust turning speed
    end
    if inputState.turn_right.down then
        self.angle = self.angle + 2.0 * dt -- Adjust turning speed
    end
end

-- These methods provide data for the renderer
function Camera:getPosition()
    return self.pos
end

function Camera:getHeight()
    return self.z -- Used for rendering height off floor
end

function Camera:getAngle()
    return self.angle
end

function Camera:getPitch()
    return self.pitch
end

function Camera:getFOV()
    return self.fov
end

function Camera:getForwardVector()
    return { x = math.cos(self.angle), y = math.sin(self.angle) }
end

function Camera:getRightVector()
    -- Rotated 90 degrees clockwise from forward
    return { x = math.cos(self.angle + math.pi/2), y = math.sin(self.angle + math.pi/2) }
    -- Alternative: return { x = math.sin(self.angle), y = -math.cos(self.angle) }
end


return Camera