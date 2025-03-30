-- game/player.lua
-- Player state and actions

local GameObject = require("game.gameobject") -- Assuming a base class exists (see below)
local Weapon = require("game.weapon") -- Base weapon class

local Player = GameObject:extend() -- Inherit from a base GameObject

function Player:new(pos, angle, health)
    -- Call parent constructor (if GameObject has one)
    Player.super.new(self, pos, angle, "player") -- Pass type

    self.health = health or 100
    self.maxHealth = 100
    self.armor = 0
    self.maxArmor = 100

    self.moveSpeed = 5.0 -- Units per second
    self.strafeSpeed = 4.5
    self.turnSpeed = math.rad(120) -- Degrees per second (for keyboard turning)

    self.weapons = {} -- Table to hold weapon instances
    self.currentWeaponIndex = 1
    self:giveWeapon("Pistol") -- Start with a basic weapon
    self:giveWeapon("Shotgun") -- Example

    self.ammo = {
        bullets = 50,
        shells = 10,
        rockets = 0,
        plasma = 0
    }
    self.maxAmmo = {
        bullets = 200,
        shells = 50,
        rockets = 50,
        plasma = 300
    }

    self.radius = 0.3 -- Collision radius

    -- Player state flags
    self.isMoving = false
    self.isFiring = false
end

function Player:giveWeapon(weaponType)
    -- TODO: Check if player already has this weapon type
    local newWeapon = Weapon.createWeapon(weaponType, self) -- Pass player for ammo access etc.
    if newWeapon then
        table.insert(self.weapons, newWeapon)
        print("Picked up "..weaponType)
        -- Optionally switch to the new weapon
        -- self:switchToWeapon(#self.weapons)
    end
end

function Player:switchToWeapon(index)
    if index >= 1 and index <= #self.weapons then
        self.currentWeaponIndex = index
        print("Switched to ".. self:getCurrentWeapon().name)
    end
end

function Player:getCurrentWeapon()
    return self.weapons[self.currentWeaponIndex]
end

function Player:update(dt, inputState, world)
    -- Handle weapon switching input
    if inputState.weapon1.pressed and #self.weapons >= 1 then self:switchToWeapon(1) end
    if inputState.weapon2.pressed and #self.weapons >= 2 then self:switchToWeapon(2) end
    if inputState.weapon3.pressed and #self.weapons >= 3 then self:switchToWeapon(3) end
    -- TODO: Add mouse wheel weapon switching

    -- Handle firing input
    local currentWeapon = self:getCurrentWeapon()
    if currentWeapon then
        if inputState.fire.down then
            currentWeapon:tryFire(world) -- Pass world to spawn projectiles
            self.isFiring = true -- For animation/sound triggers
        else
             currentWeapon:releaseTrigger()
             self.isFiring = false
        end
        currentWeapon:update(dt) -- Update weapon cooldown, etc.
    end

    -- Handle movement input
    local moveVec = { x = 0, y = 0 }
    local moved = false

    -- Forward/Backward
    if inputState.forward.down then
        moveVec.x = moveVec.x + math.cos(self.angle) * self.moveSpeed * dt
        moveVec.y = moveVec.y + math.sin(self.angle) * self.moveSpeed * dt
        moved = true
    end
    if inputState.back.down then
        moveVec.x = moveVec.x - math.cos(self.angle) * self.moveSpeed * dt * 0.8 -- Slower backpedal
        moveVec.y = moveVec.y - math.sin(self.angle) * self.moveSpeed * dt * 0.8
        moved = true
    end

    -- Strafing
    if inputState.strafe_left.down then
        local rightAngle = self.angle + math.pi / 2
        moveVec.x = moveVec.x - math.cos(rightAngle) * self.strafeSpeed * dt
        moveVec.y = moveVec.y - math.sin(rightAngle) * self.strafeSpeed * dt
        moved = true
    end
    if inputState.strafe_right.down then
        local rightAngle = self.angle + math.pi / 2
        moveVec.x = moveVec.x + math.cos(rightAngle) * self.strafeSpeed * dt
        moveVec.y = moveVec.y + math.sin(rightAngle) * self.strafeSpeed * dt
        moved = true
    end

    self.isMoving = moved

    -- Apply movement with collision detection
    if moved then
       local newPos = { x = self.pos.x + moveVec.x, y = self.pos.y + moveVec.y }
       -- TODO: Implement proper collision detection against world geometry and other objects
       -- Example placeholder:
       local collisionResult = world:checkCollision(self.pos, newPos, self.radius)
       if not collisionResult.collided then
            self.pos.x = newPos.x
            self.pos.y = newPos.y
       else
            -- TODO: Implement slide collision response
            -- For now, just stop
            print("Collision detected!") -- Placeholder
       end
    end

    -- Note: Turning is handled by the Camera using mouse input
    -- We update the player's angle based on the camera in the Camera:update or here
    -- self.angle = camera:getAngle() -- Assuming global or passed camera reference

end

function Player:takeDamage(amount, type)
    -- TODO: Apply armor absorption
    self.health = math.max(0, self.health - amount)
    print("Player took "..amount.." damage. Health: "..self.health)
    if self.health <= 0 then
        self:die()
    end
    -- TODO: Play pain sound, screen flash effect
end

function Player:addHealth(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
    print("Player gained "..amount.." health. Health: "..self.health)
end

function Player:addAmmo(ammoType, amount)
    if self.ammo[ammoType] then
        self.ammo[ammoType] = math.min(self.maxAmmo[ammoType], self.ammo[ammoType] + amount)
        print("Picked up "..amount.." "..ammoType..". Total: "..self.ammo[ammoType])
    end
end

function Player:useAmmo(ammoType, amount)
    if self.ammo[ammoType] and self.ammo[ammoType] >= amount then
        self.ammo[ammoType] = self.ammo[ammoType] - amount
        return true -- Successfully used ammo
    end
    return false -- Not enough ammo
end

function Player:die()
    print("Player has died!")
    -- TODO: Implement game over screen, respawn logic, etc.
    -- love.event.quit() -- Simple exit for now
end

-- Need a simple base class or use a library like middleclass
-- Simple inheritance structure:
local GameObject = {}
GameObject.__index = GameObject
function GameObject:extend()
    local cls = {}
    for k, v in pairs(self) do
        cls[k] = v
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end
function GameObject:new(pos, angle, type)
    local instance = setmetatable({}, self)
    instance.pos = { x = pos.x, y = pos.y }
    instance.angle = angle or 0
    instance.type = type or "generic"
    instance.id = math.random(1, 1000000) -- Simple unique ID
    instance.velocity = {x = 0, y = 0}
    instance.radius = 0.5 -- Default collision radius
    instance.active = true -- Flag for removal
    return instance
end
function GameObject:update(dt, world)
    -- Base update (e.g., apply velocity) - can be overridden
    self.pos.x = self.pos.x + self.velocity.x * dt
    self.pos.y = self.pos.y + self.velocity.y * dt
end
function GameObject:draw()
    -- Base draw - likely handled by Renderer based on type/state
end

return Player