-- game/gangs.lua
-- Define different enemy types based on gangs

local Gangs = {}

Gangs.Types = {
    -- Southside Serpents (Example Gang 1)
    SerpentGrunt = {
        name = "Serpent Grunt",
        gang = "Serpents",
        health = 60,
        speed = 3.5,
        damage = 12, -- If using simple hitscan
        fireRate = 0.8, -- If using simple hitscan
        weaponType = "Pistol", -- TODO: Link to actual weapon system later
        sprite = "graphics/enemies/serpent_grunt.png", -- Placeholder path
        -- AI variations? More aggressive? Less accurate?
    },
    SerpentEnforcer = {
        name = "Serpent Enforcer",
        gang = "Serpents",
        health = 100,
        speed = 2.8,
        damage = 20,
        fireRate = 1.2,
        weaponType = "Shotgun",
        sprite = "graphics/enemies/serpent_enforcer.png",
        -- Different AI? Prefers closer range?
    },

    -- Northside Kings (Example Gang 2)
    King Lookout = {
        name = "King Lookout",
        gang = "Kings",
        health = 50,
        speed = 4.0,
        damage = 10,
        fireRate = 0.6,
        weaponType = "Pistol",
        sprite = "graphics/enemies/king_lookout.png",
        viewDistance = 20, -- Better eyesight?
    },
    KingBruiser = {
        name = "King Bruiser",
        gang = "Kings",
        health = 150,
        speed = 2.5,
        damage = 0, -- Uses melee?
        weaponType = "Bat", -- Melee weapon type needed
        sprite = "graphics/enemies/king_bruiser.png",
        attackRange = 1.5, -- Melee range
        -- AI: Charges aggressively?
    },
    -- Add more gangs and member types
}

-- Function to get data for a specific enemy type
function Gangs.getEnemyData(typeName)
    return Gangs.Types[typeName]
end

return Gangs