-- Gun Vault Scene - Browse and equip collected guns
VaultScene = {
    player = nil,
    guns = {},
    selectedIndex = 1,
    sortBy = "rarity",  -- "rarity" or "acquisition"
    gridCols = 5,
    gridRows = 3,
    gridSpacing = 20,
    startX = 50,
    startY = 100,
    cellWidth = 120,
    cellHeight = 100,
    title = "Gun Vault Collection",
    message = "",
    messageTimer = 0
}

function VaultScene:load()
    -- Copy collected guns to display
    self.guns = {}
    for i, gun in ipairs(Game.collectedGuns) do
        table.insert(self.guns, gun)
    end
    
    -- Sort guns by rarity (descending)
    self:sortGuns()
    
    self.selectedIndex = 1
    self.sortBy = "rarity"
    self.message = ""
    self.messageTimer = 0
end

function VaultScene:sortGuns()
    local rarityOrder = {grail = 5, legendary = 4, epic = 3, rare = 2, common = 1}
    
    if self.sortBy == "rarity" then
        table.sort(self.guns, function(a, b)
            local aRarity = rarityOrder[a.rarity] or 0
            local bRarity = rarityOrder[b.rarity] or 0
            return aRarity > bRarity
        end)
    -- acquisition order (already in order from collection)
    end
end

function VaultScene:update(dt)
    -- Update message timer
    if self.messageTimer > 0 then
        self.messageTimer = self.messageTimer - dt
    end
end

function VaultScene:draw()
    -- Draw background
    love.graphics.setColor(30, 30, 40)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Draw title
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf(self.title, 0, 10, 800, "center")
    
    -- Draw sort info
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Total: " .. #self.guns .. " guns | Sort: " .. self.sortBy, 0, 40, 800, "center")
    
    -- Draw guns grid
    if #self.guns == 0 then
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.setColor(150, 150, 150)
        love.graphics.printf("No guns in vault yet. Go on a mission to collect some!", 0, 300, 800, "center")
    else
        self:drawGunGrid()
    end
    
    -- Draw selected gun details
    if #self.guns > 0 then
        self:drawGunDetails()
    end
    
    -- Draw controls
    love.graphics.setColor(150, 150, 150)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.printf("Arrow Keys: Navigate | E: Equip | L: Leave", 0, 560, 800, "center")
    
    -- Draw message
    if self.messageTimer > 0 then
        love.graphics.setColor(100, 255, 100)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf(self.message, 0, 530, 800, "center")
    end
end

function VaultScene:drawGunGrid()
    local cellW = self.cellWidth
    local cellH = self.cellHeight
    local cols = self.gridCols
    local startX = self.startX
    local startY = self.startY
    local spacing = self.gridSpacing
    
    for i, gun in ipairs(self.guns) do
        -- Calculate grid position
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = startX + col * (cellW + spacing)
        local y = startY + row * (cellH + spacing)
        
        -- Don't draw if off-screen
        if y > 450 then
            break
        end
        
        -- Draw cell background
        if i == self.selectedIndex then
            love.graphics.setColor(150, 150, 200)  -- Selected: lighter
        else
            love.graphics.setColor(60, 60, 80)     -- Normal: darker
        end
        love.graphics.rectangle("fill", x, y, cellW, cellH)
        
        -- Draw cell border
        love.graphics.setColor(100, 100, 120)
        love.graphics.rectangle("line", x, y, cellW, cellH)
        
        -- Draw gun color indicator (rarity)
        local rarityColor = Colors[gun.rarity] or Colors.common
        love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3])
        love.graphics.rectangle("fill", x + 2, y + 2, cellW - 4, 15)
        
        -- Draw rarity label
        love.graphics.setColor(50, 50, 50)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(gun.rarity:upper():sub(1, 3), x, y + 3, cellW, "center")
        
        -- Draw gun name
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(love.graphics.newFont(9))
        love.graphics.printf(gun.name, x + 3, y + 22, cellW - 6, "left")
        
        -- Draw damage indicator
        love.graphics.setColor(200, 100, 100)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.printf("DMG: " .. math.floor(gun.damage), x + 3, y + 60, cellW - 6, "left")
        
        -- Draw fire rate indicator
        love.graphics.setColor(100, 200, 100)
        love.graphics.printf("RPM: " .. math.floor(1/gun.fireRate), x + 3, y + 72, cellW - 6, "left")
    end
end

function VaultScene:drawGunDetails()
    -- Draw selected gun details panel
    local gun = self.guns[self.selectedIndex]
    if not gun then return end
    
    local detailX = self.startX
    local detailY = 380
    local detailW = 700
    local detailH = 120
    
    -- Draw panel background
    love.graphics.setColor(60, 60, 80)
    love.graphics.rectangle("fill", detailX, detailY, detailW, detailH)
    
    -- Draw panel border
    love.graphics.setColor(100, 100, 120)
    love.graphics.rectangle("line", detailX, detailY, detailW, detailH)
    
    -- Draw selected gun details
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(love.graphics.newFont(12))
    
    local textX = detailX + 10
    local textY = detailY + 5
    
    -- Gun name
    love.graphics.printf("Selected: " .. gun.name, textX, textY, detailW - 20, "left")
    textY = textY + 20
    
    -- Stats grid
    love.graphics.setFont(love.graphics.newFont(10))
    
    -- Left column
    love.graphics.setColor(200, 100, 100)
    love.graphics.printf("Damage: " .. math.floor(gun.damage), textX, textY, 150, "left")
    love.graphics.setColor(100, 200, 100)
    love.graphics.printf("Ammo: " .. gun.magSize, textX, textY + 20, 150, "left")
    love.graphics.setColor(100, 150, 255)
    love.graphics.printf("Spread: " .. string.format("%.3f", gun.spread), textX, textY + 40, 150, "left")
    
    -- Right column
    love.graphics.setColor(255, 200, 100)
    love.graphics.printf("Fire Rate: " .. string.format("%.2f", gun.fireRate), textX + 160, textY, 150, "left")
    love.graphics.setColor(200, 100, 200)
    love.graphics.printf("Rarity: " .. gun.rarity:upper(), textX + 160, textY + 20, 150, "left")
    love.graphics.setColor(200, 200, 100)
    love.graphics.printf("Level: " .. (gun.level or 1), textX + 160, textY + 40, 150, "left")
end

function VaultScene:keypressed(key)
    if key == "escape" or key == "l" then
        -- Return to HQ
        SceneManager.switch(HQScene)
    
    elseif key == "right" then
        -- Navigate right
        local maxPerRow = self.gridCols
        local newIndex = self.selectedIndex + 1
        if newIndex <= #self.guns then
            self.selectedIndex = newIndex
        end
    
    elseif key == "left" then
        -- Navigate left
        local newIndex = self.selectedIndex - 1
        if newIndex >= 1 then
            self.selectedIndex = newIndex
        end
    
    elseif key == "down" then
        -- Navigate down
        local newIndex = self.selectedIndex + self.gridCols
        if newIndex <= #self.guns then
            self.selectedIndex = newIndex
        end
    
    elseif key == "up" then
        -- Navigate up
        local newIndex = self.selectedIndex - self.gridCols
        if newIndex >= 1 then
            self.selectedIndex = newIndex
        end
    
    elseif key == "e" or key == "return" then
        -- Equip selected gun
        if #self.guns > 0 then
            self:equipGun(self.selectedIndex)
        end
    
    elseif key == "s" then
        -- Toggle sort
        self.sortBy = self.sortBy == "rarity" and "acquisition" or "rarity"
        self:sortGuns()
        self.selectedIndex = 1
        self.message = "Sorted by: " .. self.sortBy
        self.messageTimer = 2
    end
end

function VaultScene:equipGun(index)
    if index < 1 or index > #self.guns then
        self.message = "Invalid gun selection"
        self.messageTimer = 1
        return
    end
    
    local gun = self.guns[index]
    
    -- Set as current weapon
    if Game.player then
        Game.player.weapon = gun
    end
    
    self.message = "Equipped: " .. gun.name
    self.messageTimer = 2
end

function VaultScene:mousepressed(x, y, button)
    -- Handle clicking on guns
    local cellW = self.cellWidth
    local cellH = self.cellHeight
    local cols = self.gridCols
    local startX = self.startX
    local startY = self.startY
    local spacing = self.gridSpacing
    
    for i, gun in ipairs(self.guns) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local gunX = startX + col * (cellW + spacing)
        local gunY = startY + row * (cellH + spacing)
        
        if x >= gunX and x <= gunX + cellW and
           y >= gunY and y <= gunY + cellH then
            self.selectedIndex = i
            if button == 1 then
                self:equipGun(i)
            end
            return
        end
    end
end

-- Register scene
SceneManager.add("vault", VaultScene)
