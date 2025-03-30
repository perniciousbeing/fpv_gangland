-- game/world.lua
-- Manages all active game objects (player, enemies, projectiles)
-- Handles basic collision detection and interaction logic

local World = {}
World.gameObjects = {} -- List of all active objects
World.level = nil      -- Reference to the current level data

function World.initialize()
    World.gameObjects = {}
end

function World.setLevel(level)
    World.level = level
    -- Spawn entities defined in the level
    level:spawnEntities(World)
end

function World.addGameObject(obj)
    table.insert(World.gameObjects, obj)
end

function World.update(dt, player)
    -- Update all game objects
    local objectsToRemove = {}
    for i, obj in ipairs(World.gameObjects) do
        if obj.active then
            if obj.update then
                -- Pass relevant context (world, player for targeting)
                if obj.type == "enemy" then
                    obj:update(dt, World, player)
                elseif obj.type == "projectile" then
                    obj:update(dt, World)
                -- Player is updated separately in main.lua
                -- else
                --    obj:update(dt, World) -- Generic update
                end
            end
        else
            table.insert(objectsToRemove, i) -- Mark inactive objects for removal
        end
    end

    -- Remove inactive objects (iterate backwards to avoid index issues)
    for i = #objectsToRemove, 1, -1 do
        local index = objectsToRemove[i]
        table.remove(World.gameObjects, index)
    end
end

-- Simple collision check against level geometry (walls)
-- Returns true if the position (x, y) is inside a wall
function World.isPositionWall(x, y)
    if not World.level then return true end -- No level loaded, assume solid
    return World.level:isWall(x, y)
end

-- Simple Circle vs Level Grid Collision Check
-- Checks if moving from oldPos to newPos with radius results in collision with walls
-- Returns { collided = boolean, position = final_allowed_position } (simplified)
function World.checkCollision(oldPos, newPos, radius, selfObject)
    -- Very basic check: Is the target point itself inside a wall?
    if World.isPositionWall(newPos.x, newPos.y) then
        return { collided = true, position = oldPos } -- Just stop for now
    end

    -- TODO: More robust collision detection
    -- 1. Check corners of the bounding box defined by radius against walls
    -- 2. Raycast along the movement vector to find the exact collision point
    -- 3. Implement sliding response along the wall normal

    -- Placeholder: Allows movement if the direct target tile is not a wall
    return { collided = false, position = newPos }
end


-- Collision check specifically for projectiles
-- Checks against walls and damageable actors (enemies, player)
-- Returns the first object hit, or nil
function World.checkProjectileCollision(projectile)
    -- 1. Check against level geometry (walls)
    if World.isPositionWall(projectile.pos.x, projectile.pos.y) then
        -- Create a simple dummy wall object representation if needed for effects
        return { type = "wall" } -- Return a generic wall indicator
    end

    -- 2. Check against other game objects (enemies, player)
    for _, obj in ipairs(World.gameObjects) do
        if obj.active and obj ~= projectile and obj ~= projectile.owner then
            -- Check distance between projectile and object centers
            local dx = obj.pos.x - projectile.pos.x
            local dy = obj.pos.y - projectile.pos.y
            local distSq = dx*dx + dy*dy
            local radiiSum = (obj.radius or 0.5) + projectile.radius
            local radiiSumSq = radiiSum * radiiSum

            if distSq < radiiSumSq then
                -- Collision detected!
                if obj.type == "enemy" or obj.type == "player" then
                    return obj -- Return the damageable object hit
                else
                    -- Hit some other object type? (e.g., destructible prop)
                    -- Return obj if it should block projectiles
                end
            end
        end
    end

    return nil -- No collision detected
end

-- Raycasting/Line Tracing function (Essential for AI LOS and maybe hitscan weapons)
-- Casts a line from startPos to endPos
-- Returns the first object hit (wall or actor), or nil/true if clear
-- `ignoredObject` is usually the entity casting the ray (e.g., the enemy checking LOS)
function World.traceLine(startPos, endPos, ignoredObject)
    -- TODO: Implement Bresenham's line algorithm or similar grid traversal
    -- Check each grid cell along the line for walls (using level:isWall)
    -- Optionally, check each cell for actors (enemies/player) that are not ignoredObject
    -- This is complex to implement correctly and efficiently.

    -- Placeholder: Very naive check - just checks the end point for simplicity
    -- This is NOT a real line trace!
    if World.isPositionWall(endPos.x, endPos.y) then
        return { type = "wall" } -- Hit a wall
    end

    -- Placeholder: Check actors near the end point (also very inaccurate)
    for _, obj in ipairs(World.gameObjects) do
        if obj.active and obj ~= ignoredObject and (obj.type == 'enemy' or obj.type == 'player') then
             local dx = obj.pos.x - endPos.x
             local dy = obj.pos.y - endPos.y
             local distSq = dx*dx + dy*dy
             if distSq < (obj.radius * obj.radius) then
                 return obj -- Hit an actor near the end point
             end
        end
    end


    -- If checks pass (in a real implementation), the line is clear
    return nil -- Or maybe return 'true' for clear LOS
end


-- Get objects potentially visible to the camera (for rendering optimization)
function World.getVisibleObjects(camera)
    -- TODO: Implement visibility check (e.g., basic distance culling, frustum culling if using 3D)
    -- For now, just return all active non-player, non-projectile objects
    local visible = {}
    for _, obj in ipairs(World.gameObjects) do
        if obj.active and obj.type ~= "player" and obj.type ~= "projectile" then
             -- Add distance check maybe?
            -- local distSq = (obj.pos.x - camera.pos.x)^2 + (obj.pos.y - camera.pos.y)^2
            -- if distSq < 100*100 then -- Example: only objects within 100 units
                 table.insert(visible, obj)
            -- end
        end
    end
    return visible
end

return World