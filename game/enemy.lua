-- game/enemy.lua
-- Base class for enemies and specific gang member types

local GameObject = require("game.gameobject")
local Gangs = require("game.gangs") -- Gang definitions

local Enemy = GameObject:extend()

function Enemy:new(pos, angle, enemyTypeData)
    Enemy.super.new(self, pos, angle, "enemy") -- Type is 'enemy'

    self.data = enemyTypeData -- Contains health, speed, weapon, gang, etc.
    self.health = self.data.health or 50
    self.speed = self.data.speed or 3.0
    self.state = "idle" -- e.g., 'idle', 'wandering', 'chasing', 'attacking', 'dead'
    self.radius = 0.4
    self.viewDistance = 15
    self.attackRange = 10
    self.target = nil -- Reference to the player when seen

    -- AI timers and state
    self.stateTimer = 0
    self.attackCooldown = 0
    self.reactionTime = 0.2 -- Delay before reacting/firing

    -- TODO: Equip weapon based on self.data.weaponType
    self.weapon = nil -- Placeholder for equipped weapon instance
end

function Enemy:update(dt, world, player)
    if self.state == "dead" then return end -- Don't update dead enemies

    -- Basic AI State Machine
    local distanceToPlayer = math.sqrt((player.pos.x - self.pos.x)^2 + (player.pos.y - self.pos.y)^2)
    local canSeePlayer = self:checkLineOfSight(world, player.pos) -- TODO: Implement LOS check

    -- State Transitions
    if canSeePlayer and distanceToPlayer <= self.viewDistance then
        self.target = player
        if distanceToPlayer <= self.attackRange then
            self.state = "attacking"
        else
            self.state = "chasing"
        end
    else
        self.target = nil
        -- TODO: Add wandering behavior or return to patrol path
        self.state = "idle" -- Simple fallback
    end

    -- State Actions
    self.stateTimer = self.stateTimer - dt

    if self.state == "idle" then
        -- Stand still, maybe look around occasionally
        self.velocity = { x = 0, y = 0 }
        if self.stateTimer <= 0 then
             -- Turn to a random direction?
             self.angle = math.random() * 2 * math.pi
             self.stateTimer = math.random(2, 5) -- Wait for a few seconds
        end

    elseif self.state == "chasing" then
        -- Move towards the player
        local targetAngle = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
        self.angle = targetAngle -- Face the player while chasing
        self.velocity.x = math.cos(self.angle) * self.speed
        self.velocity.y = math.sin(self.angle) * self.speed

    elseif self.state == "attacking" then
        -- Stop moving (or strafe?), face player, and attack
        self.velocity = { x = 0, y = 0 }
        local targetAngle = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
        self.angle = targetAngle -- Keep facing player

        self.attackCooldown = self.attackCooldown - dt
        if self.attackCooldown <= 0 then
            -- TODO: Use equipped weapon to fire at player
            self:attack(world)
            self.attackCooldown = (self.data.fireRate or 1.0) + math.random() * 0.5 -- Add some randomness
        end
    end

    -- Apply velocity (base class update) and handle collision
    local oldPos = { x = self.pos.x, y = self.pos.y }
    Enemy.super.update(self, dt, world) -- Apply velocity

    local newPos = self.pos
    local collisionResult = world:checkCollision(oldPos, newPos, self.radius, self) -- Pass self to ignore self-collision
    if collisionResult.collided then
       -- TODO: Implement basic collision response (e.g., stop, try to slide)
       self.pos = oldPos -- Simple stop
       self.velocity = {x = 0, y = 0} -- Stop movement
       -- Maybe change state if stuck?
       -- print("Enemy collision!")
    end
end

function Enemy:attack(world)
    print(self.data.name.." attacking!")
    -- TODO: Implement actual weapon firing logic similar to player
    -- Needs a reference to its own weapon instance and ammo logic if applicable
    -- For simplicity now, maybe just trace a line and damage player if hit

    -- Simple instant hitscan example:
    local didHit = world:checkLineOfSight(self, self.target.pos, true) -- Check LOS again, ignore actors=true means check against player
    if didHit and didHit == self.target then -- Check if the thing hit *was* the target
         print("Enemy hit player!")
         self.target:takeDamage(self.data.damage or 10, "enemy_bullet")
    else
         print("Enemy missed!")
    end

end

function Enemy:takeDamage(amount, type)
    if self.state == "dead" then return end

    self.health = math.max(0, self.health - amount)
    print(self.data.name.." took "..amount.." damage. Health: "..self.health)
    -- TODO: Play pain sound, maybe briefly interrupt action (stun)

    if self.health <= 0 then
        self:die()
    else
        -- Make enemy react to being hit if they didn't see the player
        -- self.state = "chasing" -- Or alert nearby enemies?
    end
end

function Enemy:checkLineOfSight(world, targetPos, ignoreActors)
    -- TODO: Implement raycast from self.pos to targetPos
    -- Check against world geometry (walls)
    -- If ignoreActors is false, also check against other actors (enemies, player)
    -- Return true if clear path, false otherwise (or return the object hit)
    return world:traceLine(self.pos, targetPos, self) -- Placeholder
end

function Enemy:die()
    print(self.data.name.." has died!")
    self.state = "dead"
    self.velocity = { x = 0, y = 0 }
    -- TODO: Change appearance (death sprite/model), disable collision, maybe drop loot/weapon
    -- Could set self.active = false after a delay for corpse removal
end

return Enemy