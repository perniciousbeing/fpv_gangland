-- game/projectile.lua
-- Represents bullets, rockets, etc.

local GameObject = require("game.gameobject") -- Use the base class structure

local Projectile = GameObject:extend()

function Projectile:new(pos, angle, damage, speed, owner)
    Projectile.super.new(self, pos, angle, "projectile") -- Call base constructor
    self.damage = damage
    self.speed = speed
    self.owner = owner -- The entity that fired this (Player or Enemy)
    self.lifeTime = 3.0 -- Seconds before disappearing automatically
    self.radius = 0.1 -- Small collision radius

    -- Set initial velocity based on angle and speed
    self.velocity.x = math.cos(self.angle) * self.speed
    self.velocity.y = math.sin(self.angle) * self.speed
end

function Projectile:update(dt, world)
    -- Apply velocity (handled by base GameObject:update)
    Projectile.super.update(self, dt, world)

    -- Check lifetime
    self.lifeTime = self.lifeTime - dt
    if self.lifeTime <= 0 then
        self.active = false -- Mark for removal
        return
    end

    -- Check for collisions
    local hitObject = world:checkProjectileCollision(self)

    if hitObject then
        -- print("Projectile hit:", hitObject.type) -- Debug
        -- Check if it hit a damageable object (Enemy or Player)
        if hitObject.takeDamage then
            -- Avoid hitting the owner immediately after firing (optional)
            if hitObject ~= self.owner then -- or check time since fired
                hitObject:takeDamage(self.damage, "bullet") -- Pass damage type maybe
                self.active = false -- Projectile is consumed on hit
                -- TODO: Spawn impact effect (visual/sound) at self.pos
            end
        else
            -- Hit a wall or non-damageable object
            self.active = false -- Projectile is consumed
            -- TODO: Spawn wall impact effect
        end
    end
end

-- Projectiles don't typically need their own draw function
-- The Renderer will handle drawing active projectiles based on their type/state

return Projectile