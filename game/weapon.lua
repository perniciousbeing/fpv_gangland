-- game/weapon.lua
-- Base weapon class and specific weapon implementations

local Projectile = require("game.projectile") -- For spawning projectiles

local Weapon = {}
Weapon.__index = Weapon

-- Factory function to create specific weapons
function Weapon.createWeapon(weaponType, owner)
    if weaponType == "Pistol" then
        return Pistol:new(owner)
    elseif weaponType == "Shotgun" then
        return Shotgun:new(owner)
    -- Add more weapon types here (e.g., SMG, Bat, Rifle)
    else
        print("Error: Unknown weapon type '"..weaponType.."'")
        return nil
    end
end

-- Base weapon constructor (not usually called directly)
function Weapon:new(owner)
    local instance = setmetatable({}, self)
    instance.owner = owner -- Reference to the player/enemy holding the weapon
    instance.name = "Base Weapon"
    instance.ammoType = "bullets" -- e.g., 'bullets', 'shells', 'rockets', 'melee'
    instance.ammoPerShot = 1
    instance.damage = 10
    instance.fireRate = 0.5 -- Seconds between shots
    instance.cooldown = 0 -- Time left until next shot possible
    instance.kickback = 0.1 -- Visual feedback amount
    instance.spread = 0.05 -- Accuracy cone (radians)
    instance.projectileSpeed = 50
    instance.projectileClass = Projectile -- Default projectile type
    instance.isAutomatic = false
    instance.canFire = true -- For semi-auto logic
    return instance
end

function Weapon:update(dt)
    if self.cooldown > 0 then
        self.cooldown = math.max(0, self.cooldown - dt)
    end
end

function Weapon:tryFire(world)
    if self.cooldown <= 0 then
        if self.isAutomatic or self.canFire then -- Allow first shot for semi-auto
            if self.owner:useAmmo(self.ammoType, self.ammoPerShot) then
                self:fire(world)
                self.cooldown = self.fireRate
                self.canFire = false -- Prevent holding fire for semi-auto
                -- TODO: Trigger weapon animation, sound, screen kick
            else
                -- TODO: Play 'empty clip' sound
                print(self.name .. " - Out of ammo!")
            end
        end
    end
end

-- Called when the fire button is released (for semi-auto reset)
function Weapon:releaseTrigger()
    self.canFire = true
end

-- Actual firing logic (called by tryFire)
function Weapon:fire(world)
    print(self.name .. " fired!")
    -- Calculate firing direction with spread
    local angle = self.owner.angle + (math.random() * 2 - 1) * self.spread

    -- Create projectile(s)
    local proj = self.projectileClass:new(
        { x = self.owner.pos.x, y = self.owner.pos.y }, -- Start position (adjust for muzzle)
        angle,                                       -- Firing angle
        self.damage,                                 -- Damage
        self.projectileSpeed,                        -- Speed
        self.owner                                   -- Who fired it (to avoid self-collision)
    )
    world:addGameObject(proj) -- Add projectile to the world to be updated/drawn
end

---------------------------------------------
-- Specific Weapon: Pistol
---------------------------------------------
local Pistol = setmetatable({}, Weapon)
Pistol.__index = Pistol
Pistol.super = Weapon

function Pistol:new(owner)
    local instance = Pistol.super.new(self, owner) -- Call base constructor
    instance.name = "9mm Pistol"
    instance.ammoType = "bullets"
    instance.ammoPerShot = 1
    instance.damage = 15
    instance.fireRate = 0.3
    instance.kickback = 0.05
    instance.spread = 0.03
    instance.projectileSpeed = 60
    instance.isAutomatic = false -- Semi-auto
    return instance
end

---------------------------------------------
-- Specific Weapon: Shotgun
---------------------------------------------
local Shotgun = setmetatable({}, Weapon)
Shotgun.__index = Shotgun
Shotgun.super = Weapon

function Shotgun:new(owner)
    local instance = Shotgun.super.new(self, owner)
    instance.name = "Combat Shotgun"
    instance.ammoType = "shells"
    instance.ammoPerShot = 1 -- Consumes 1 shell
    instance.damage = 8      -- Per pellet
    instance.numPellets = 7  -- Number of pellets fired per shot
    instance.fireRate = 0.9
    instance.kickback = 0.3
    instance.spread = 0.25   -- Wide spread
    instance.projectileSpeed = 45
    instance.isAutomatic = false
    return instance
end

-- Override the fire method for multi-pellet logic
function Shotgun:fire(world)
    print(self.name .. " fired!")
    for i = 1, self.numPellets do
        local angle = self.owner.angle + (math.random() * 2 - 1) * self.spread
        local proj = self.projectileClass:new(
            { x = self.owner.pos.x, y = self.owner.pos.y },
            angle,
            self.damage, -- Damage per pellet
            self.projectileSpeed,
            self.owner
        )
        world:addGameObject(proj)
    end
end


return Weapon