-- game/level.lua
-- Manages loading and storing level data (map geometry, enemy placement)

local Enemy = require("game.enemy")
local Gangs = require("game.gangs")

local Level = {}
Level.__index = Level

function Level:new(mapFilePath)
    local instance = setmetatable({}, Level)
    instance.mapFilePath = mapFilePath
    instance.width = 0
    instance.height = 0
    instance.mapData = {}    -- 2D array for tile data (e.g., 0=empty, 1=wall)
    instance.spawnPoints = {}-- List of {x, y, type, angle, gang} for enemies/pickups
    instance.playerStart = { x = 2, y = 2, angle = 0 } -- Default player start
    return instance
end

function Level:load()
    print("Loading level: " .. self.mapFilePath)
    -- TODO: Implement actual map file parsing (e.g., from a text file or Tiled map editor export)
    -- This is a placeholder for a simple text-based map

    -- Placeholder Map: W=Wall, P=PlayerStart, S=SerpentGrunt, K=KingLookout
    local mapString = {
        "WWWWWWWWWWWWWWWWWWWW",
        "W P      W         W",
        "W        W   S     W",
        "W   WWWWWW         W",
        "W        W    K    W",
        "W S      W         W",
        "WWWWWWWWWWWWWWWWWWWW",
    }

    self.height = #mapString
    self.width = string.len(mapString[1])
    self.mapData = {}

    for y = 1, self.height do
        self.mapData[y] = {}
        for x = 1, self.width do
            local char = string.sub(mapString[y], x, x)
            local tileValue = 0 -- Default: Empty space
            if char == "W" then
                tileValue = 1 -- Wall
            elseif char == "P" then
                self.playerStart = { x = x - 0.5, y = y - 0.5, angle = math.rad(90) } -- Center in tile
            elseif char == "S" then
                local enemyData = Gangs.getEnemyData("SerpentGrunt")
                if enemyData then
                    table.insert(self.spawnPoints, { x = x - 0.5, y = y - 0.5, type = "enemy", data = enemyData, angle = math.rad(270) })
                end
            elseif char == "K" then
                 local enemyData = Gangs.getEnemyData("KingLookout")
                 if enemyData then
                    table.insert(self.spawnPoints, { x = x - 0.5, y = y - 0.5, type = "enemy", data = enemyData, angle = math.rad(180) })
                 end
            -- TODO: Add other characters for different enemies, pickups (health, ammo)
            end
            self.mapData[y][x] = tileValue
        end
    end
    print("Level loaded.")
end

-- Function called by World to spawn entities defined in this level
function Level:spawnEntities(world)
    print("Spawning entities for level...")
    for _, spawnInfo in ipairs(self.spawnPoints) do
        if spawnInfo.type == "enemy" then
            local enemy = Enemy:new({ x = spawnInfo.x, y = spawnInfo.y }, spawnInfo.angle, spawnInfo.data)
            world:addGameObject(enemy)
        -- elseif spawnInfo.type == "pickup" then
            -- TODO: Create pickup objects
        end
    end
end

-- Helper function for collision detection/rendering
function Level:getTile(x, y)
    local mapX = math.floor(x) + 1 -- Convert world coords to map indices
    local mapY = math.floor(y) + 1
    if mapY >= 1 and mapY <= self.height and mapX >= 1 and mapX <= self.width then
        return self.mapData[mapY][mapX]
    end
    return 1 -- Treat out-of-bounds as a wall
end

function Level:isWall(x, y)
    return self:getTile(x, y) == 1 -- Assuming 1 represents a wall
end

return Level