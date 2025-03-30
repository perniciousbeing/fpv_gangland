-- game/ui.lua
-- Handles drawing the Heads-Up Display (HUD)

local UI = {}
UI.player = nil
UI.font = nil

function UI.initialize(player)
    UI.player = player
    -- TODO: Load specific HUD font and graphics from Assets module
    UI.font = love.graphics.newFont(24) -- Use default font for now
    print("UI Initialized.")
end

function UI.update(dt)
    -- Update any animated UI elements if needed
end

function UI.draw()
    if not UI.player then return end

    local screenW, screenH = love.graphics.getDimensions()
    local currentWeapon = UI.player:getCurrentWeapon()

    love.graphics.setFont(UI.font)
    love.graphics.setColor(1, 0, 0, 0.8) -- Red, slightly transparent

    -- Health
    local healthText = string.format("HEALTH: %d%%", UI.player.health)
    love.graphics.print(healthText, 50, screenH - 80)

    -- Armor (if applicable)
    -- local armorText = string.format("ARMOR: %d%%", UI.player.armor)
    -- love.graphics.print(armorText, 50, screenH - 50)

    love.graphics.setColor(0.8, 0.8, 0.8, 0.8) -- Greyish

    -- Ammo
    if currentWeapon and currentWeapon.ammoType ~= "melee" then
        local ammoCount = UI.player.ammo[currentWeapon.ammoType] or 0
        local ammoText = string.format("AMMO: %d", ammoCount)
         -- Right align ammo text
        local textWidth = UI.font:getWidth(ammoText)
        love.graphics.print(ammoText, screenW - textWidth - 50, screenH - 80)

        -- Optionally show total ammo for the type
        -- local totalAmmo = UI.player.ammo[currentWeapon.ammoType] or 0
        -- local totalText = string.format("/ %d", totalAmmo)
        -- love.graphics.print(totalText, screenW - 50 - UI.font:getWidth(totalText) , screenH - 50)
    end

    -- Current Weapon Name (redundant if view model is clear, useful for debug)
    if currentWeapon then
        love.graphics.setColor(1,1,0, 0.8) -- Yellow
        local weaponNameText = currentWeapon.name
        local textWidth = UI.font:getWidth(weaponNameText)
        love.graphics.print(weaponNameText, screenW - textWidth - 50, screenH - 50)
    end


    -- Crosshair (simple dot or cross)
    love.graphics.setColor(1, 1, 1, 0.7) -- White, slightly transparent
    local centerX, centerY = screenW / 2, screenH / 2
    -- love.graphics.setPointSize(3)
    -- love.graphics.points(centerX, centerY) -- Simple dot
    love.graphics.setLineWidth(1)
    love.graphics.line(centerX - 5, centerY, centerX + 5, centerY)
    love.graphics.line(centerX, centerY - 5, centerX, centerY + 5)


    -- TODO: Add other HUD elements:
    --  - Weapon selection icons
    --  - Key indicators
    --  - Minimap (if desired)
    --  - Score / Objective display
end

return UI