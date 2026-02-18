-- HQ Scene - The player's home base
local Dialogue = require("utils.dialogue")

HQScene = {
    player = nil,
    zones = {},
    npcs = {},
    -- Dialogue state
    dialogueOpen = false,
    currentQuote = "",
    selectedOption = nil
}

function HQScene:load()
    -- Create player
    self.player = {
        x = 400,
        y = 300,
        w = 32,
        h = 32,
        speed = 200,
        health = 100,
        maxHealth = 100,
        angle = 0,
        weapon = nil,
        grenades = 3,
        xp = 0,
        level = 1
    }
    Game.world:add(self.player, self.player.x, self.player.y, self.player.w, self.player.h)

    -- Define interactive zones
    self.zones = {
        store = {x = 100, y = 150, w = 100, h = 80, label = "STORE", color = {100, 200, 100}},
        bar = {x = 600, y = 150, w = 120, h = 80, label = "BAR (Joe)", color = {200, 150, 100}},
        vault = {x = 350, y = 80, w = 140, h = 60, label = "GUN VAULT", color = {150, 100, 200}},
        mission = {x = 350, y = 500, w = 140, h = 60, label = "START MISSION", color = {200, 80, 80}}
    }

    -- NPCs
    self.npcs = {
        joe = {x = 660, y = 180, w = 30, h = 40, name = "Joe the Bartender", dialog = "Welcome back! The bar's always open. Need something to drink?"}
    }

    -- Dialogue state
    self.dialogueOpen = false
    self.currentQuote = Dialogue.getRandomQuote()
    self.selectedOption = nil
end

function HQScene:update(dt)
    -- Player movement
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end

    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len

        local newX = self.player.x + dx * self.player.speed * dt
        local newY = self.player.y + dy * self.player.speed * dt

        -- Simple bounds checking
        newX = math.max(0, math.min(800 - self.player.w, newX))
        newY = math.max(0, math.min(600 - self.player.h, newY))

        Game.world:update(self.player, newX, newY, self.player.w, self.player.h)
        self.player.x, self.player.y = newX, newY
    end

    -- Player rotation toward mouse
    self.player.angle = math.angle(
        self.player.x + self.player.w/2,
        self.player.y + self.player.h/2,
        love.mouse.getX(),
        love.mouse.getY()
    )
end

function HQScene:draw()
    -- Draw background
    love.graphics.setColor(40, 40, 50)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw floor pattern
    love.graphics.setColor(50, 50, 60)
    for x = 0, 800, 40 do
        for y = 0, 600, 40 do
            if (x + y) % 80 == 0 then
                love.graphics.rectangle("fill", x, y, 40, 40)
            end
        end
    end

    -- Draw zones
    for name, zone in pairs(self.zones) do
        love.graphics.setColor(zone.color[1], zone.color[2], zone.color[3], 100)
        love.graphics.rectangle("fill", zone.x, zone.y, zone.w, zone.h)

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.printf(zone.label, zone.x, zone.y + zone.h/2 - 7, zone.w, "center")
    end

    -- Draw NPCs
    for name, npc in pairs(self.npcs) do
        love.graphics.setColor(200, 150, 100)
        love.graphics.rectangle("fill", npc.x, npc.y, npc.w, npc.h)

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.printf(npc.name, npc.x - 20, npc.y - 15, 70, "center")
    end

    -- Draw player
    love.graphics.setColor(Colors.player[1], Colors.player[2], Colors.player[3])
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.w, self.player.h)

    -- Draw player direction indicator
    love.graphics.setColor(100, 200, 255)
    local cx, cy = self.player.x + self.player.w/2, self.player.y + self.player.h/2
    love.graphics.line(
        cx, cy,
        cx + math.cos(self.player.angle) * 25,
        cy + math.sin(self.player.angle) * 25
    )

    -- Draw HQ UI
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("💀 HQ - Safe Zone", 10, 50)

    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Loot Collected: " .. #Game.collectedGuns, 10, 75)

    -- Draw collected guns preview
    if #Game.collectedGuns > 0 then
        love.graphics.print("Recent:", 10, 95)
        for i = 1, math.min(5, #Game.collectedGuns) do
            local gun = Game.collectedGuns[#Game.collectedGuns - i + 1]
            local rarityColor = Colors[gun.rarity] or Colors.common
            love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3])
            love.graphics.print("  " .. gun.name, 10, 110 + i * 15)
        end
    end

    -- Draw Joe's dialogue box when open
    if self.dialogueOpen then
        self:drawDialogueBox()
    end
end

-- Draw Joe's dialogue box UI
function HQScene:drawDialogueBox()
    local cfg = Dialogue.getBoxConfig()
    local x, y = cfg.x, cfg.y
    local w, h = cfg.width, cfg.height
    local padding = cfg.padding

    -- Dark semi-transparent overlay background
    love.graphics.setColor(0, 0, 0, 150)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Dialogue box background
    love.graphics.setColor(30, 20, 15)  -- Dark brown wood color
    love.graphics.rectangle("fill", x, y, w, h)

    -- Box border
    love.graphics.setColor(180, 140, 80)  -- Gold/brown border
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x, y, w, h)

    -- Joe's name
    love.graphics.setColor(255, 200, 100)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Joe the Bartender", x + padding, y + padding, w - padding * 2, "center")

    -- Joe's quote
    love.graphics.setColor(255, 255, 220)  -- Light cream text
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("\"" .. self.currentQuote .. "\"", x + padding, y + padding + 30, w - padding * 2, "center")

    -- Draw menu options
    local menu = Dialogue.getDrinkMenu()
    local buttonY = y + h - padding - (#menu * (cfg.buttonHeight + cfg.buttonGap))
    local buttonX = x + padding
    local buttonW = w - padding * 2

    for i, item in ipairs(menu) do
        local btnY = buttonY + (i - 1) * (cfg.buttonHeight + cfg.buttonGap)

        -- Highlight selected option
        if i == self.selectedOption then
            love.graphics.setColor(100, 60, 20)  -- Dark orange highlight
            love.graphics.rectangle("fill", buttonX, btnY, buttonW, cfg.buttonHeight)

            -- Selection indicator
            love.graphics.setColor(255, 200, 50)
            love.graphics.polygon("fill",
                buttonX + 5, btnY + cfg.buttonHeight / 2 - 3,
                buttonX + 10, btnY + cfg.buttonHeight / 2,
                buttonX + 5, btnY + cfg.buttonHeight / 2 + 3
            )
        else
            love.graphics.setColor(50, 40, 30)  -- Dark button
            love.graphics.rectangle("fill", buttonX, btnY, buttonW, cfg.buttonHeight)
        end

        -- Button border
        love.graphics.setColor(100, 80, 50)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", buttonX, btnY, buttonW, cfg.buttonHeight)

        -- Button text
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(love.graphics.newFont(11))

        local textX = buttonX + 15
        love.graphics.printf(item.name, textX, btnY + 8, 120, "left")

        -- HP restore info for drinks
        if item.hpRestore > 0 then
            love.graphics.setColor(150, 255, 150)
            love.graphics.printf("+" .. item.hpRestore .. " HP", textX + 130, btnY + 8, 80, "left")
        end
    end

    -- Instructions
    love.graphics.setColor(180, 180, 180)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.printf("↑↓ Navigate | ENTER Select | ESC Close", x, y + h - 12, w, "center")
end

function HQScene:keypressed(key)
    -- Handle dialogue menu navigation with arrow keys
    if self.dialogueOpen then
        if key == "down" or key == "j" then
            -- Move selection down (cycle through options)
            local menu = Dialogue.getDrinkMenu()
            if not self.selectedOption or self.selectedOption < #menu then
                self.selectedOption = (self.selectedOption or 0) + 1
            end
        elseif key == "up" or key == "k" then
            -- Move selection up
            local menu = Dialogue.getDrinkMenu()
            if self.selectedOption and self.selectedOption > 1 then
                self.selectedOption = self.selectedOption - 1
            end
        elseif key == "return" or key == "space" then
            -- Select option
            if self.selectedOption then
                self:handleMenuSelection(self.selectedOption)
            end
        elseif key == "escape" or key == "q" then
            -- Close dialogue
            self.dialogueOpen = false
            self.selectedOption = nil
        end
        return
    end

    -- Normal interaction when dialogue is closed
    if key == "e" then
        -- Check for nearby interactables
        local px, py = self.player.x + self.player.w/2, self.player.y + self.player.h/2

        for name, zone in pairs(self.zones) do
            local cz, ct = zone.x + zone.w/2, zone.y + zone.h/2
            local dist = math.sqrt((px - cz)^2 + (py - ct)^2)
            if dist < 80 then
                if name == "mission" then
                    -- Start mission
                    SceneManager.switch(GameScene)
                elseif name == "bar" then
                    -- Open Joe's dialogue
                    self.dialogueOpen = true
                    self.currentQuote = Dialogue.getRandomQuote()
                    self.selectedOption = 1  -- Default to first option
                    print("Opened Joe's dialogue menu")
                elseif name == "store" then
                    print("Store: Come back after a mission to buy upgrades!")
                elseif name == "vault" then
                    print("Vault: " .. #Game.collectedGuns .. " guns collected")
                end
            end
        end
    end
end

-- Handle menu selection in Joe's dialogue
function HQScene:handleMenuSelection(option)
    local menu = Dialogue.getDrinkMenu()
    local selection = menu[option]

    if selection.name == "Leave" then
        -- Close dialogue
        self.dialogueOpen = false
        self.selectedOption = nil
        print("Closed Joe's dialogue")
    elseif selection.hpRestore > 0 then
        -- Buy drink - restore HP
        local hpToRestore = selection.hpRestore
        local oldHealth = self.player.health
        self.player.health = math.min(self.player.maxHealth, self.player.health + hpToRestore)
        local actualRestore = self.player.health - oldHealth
        print("Bought " .. selection.name .. ": Restored " .. actualRestore .. " HP (now " .. math.floor(self.player.health) .. "/" .. self.player.maxHealth .. ")")
        -- Refresh quote after purchase
        self.currentQuote = Dialogue.getRandomQuote()
        self.selectedOption = 1
    elseif selection.name == "Just Chatting" then
        -- Just get new dialogue
        self.currentQuote = Dialogue.getRandomQuote()
        print("Joe: " .. self.currentQuote)
        self.selectedOption = 1
    end
end

function HQScene:mousepressed(x, y, button)
    -- Check if clicking zones
    for name, zone in pairs(self.zones) do
        if x >= zone.x and x <= zone.x + zone.w and
           y >= zone.y and y <= zone.y + zone.h then
            if name == "mission" and button == 1 then
                SceneManager.switch(GameScene)
            end
        end
    end
end

-- Register scene
SceneManager.add("hq", HQScene)
