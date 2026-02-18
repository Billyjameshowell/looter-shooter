-- HQ Scene - The player's home base
local Shop = require("utils.shop")

HQScene = {
    player = nil,
    zones = {},
    npcs = {},
    -- Shop state
    shopOpen = false,
    shopMode = nil,  -- "main", "guns", or "upgrades"
    shopItems = {},
    shopSelection = 1,
    shopMessage = "",
    shopMessageTimer = 0
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

    -- Initialize currency if not set
    if not Game.currency then
        Game.currency = 0
    end
    
    -- Initialize collected guns if not set
    if not Game.collectedGuns then
        Game.collectedGuns = {}
    end

    -- Define interactive zones
    self.zones = {
        store = {x = 100, y = 150, w = 100, h = 80, label = "STORE", color = {100, 200, 100}},
        bar = {x = 600, y = 150, w = 120, h = 80, label = "BAR (Joe)", color = {200, 150, 100}},
        vault = {x = 350, y = 80, w = 140, h = 60, label = "GUN VAULT", color = {150, 100, 200}},
        mission = {x = 350, y = 500, w = 140, h = 60, label = "START MISSION", color = {200, 80, 80}}
    }

    -- NPCs
    self.npcs = {
        joe = {x = 660, y = 180, w = 30, h = 40, name = "Joe the Bartender", dialog = "Welcome back! The bar's always open. Need something to drink?"},
        shopkeeper = {x = 150, y = 170, w = 25, h = 35, name = "Shopkeeper", dialog = "Welcome to my store! Looking for some gear?"}
    }

    -- Reset shop state
    self.shopOpen = false
    self.shopMode = nil
    self.shopItems = {}
    self.shopSelection = 1
    self.shopMessage = ""
    self.shopMessageTimer = 0
end

function HQScene:update(dt)
    -- Update shop message timer
    if self.shopMessageTimer > 0 then
        self.shopMessageTimer = self.shopMessageTimer - dt
    end

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
    love.graphics.print("Currency: " .. Game.currency, 10, 75)
    love.graphics.print("Loot Collected: " .. #Game.collectedGuns, 10, 95)

    -- Draw collected guns preview
    if #Game.collectedGuns > 0 then
        love.graphics.print("Recent:", 10, 115)
        for i = 1, math.min(5, #Game.collectedGuns) do
            local gun = Game.collectedGuns[#Game.collectedGuns - i + 1]
            local rarityColor = Colors[gun.rarity] or Colors.common
            love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3])
            love.graphics.print("  " .. gun.name, 10, 130 + i * 15)
        end
    end

    -- Draw shop UI if open
    if self.shopOpen then
        self:drawShop()
    else
        -- Draw interaction hint
        love.graphics.setColor(200, 200, 200)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf("Press E near zone to interact", 0, 580, 800, "center")
    end
end

function HQScene:drawShop()
    local cfg = {
        width = 600,
        height = 400,
        x = (800 - 600) / 2,
        y = (600 - 400) / 2,
        padding = 20,
        buttonHeight = 35,
        buttonGap = 5
    }

    -- Dark overlay
    love.graphics.setColor(0, 0, 0, 180)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Shop box background
    love.graphics.setColor(30, 25, 20)
    love.graphics.rectangle("fill", cfg.x, cfg.y, cfg.width, cfg.height)

    -- Box border
    love.graphics.setColor(200, 160, 80)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", cfg.x, cfg.y, cfg.width, cfg.height)

    -- Title
    if self.shopMode == "main" then
        love.graphics.setColor(255, 200, 100)
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("STORE", cfg.x, cfg.y + cfg.padding, cfg.width, "center")
    elseif self.shopMode == "guns" then
        love.graphics.setColor(255, 200, 100)
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("GUNS FOR SALE", cfg.x, cfg.y + cfg.padding, cfg.width, "center")
    elseif self.shopMode == "upgrades" then
        love.graphics.setColor(255, 200, 100)
        love.graphics.setFont(love.graphics.newFont(18))
        love.graphics.printf("UPGRADES", cfg.x, cfg.y + cfg.padding, cfg.width, "center")
    end

    -- Display currency
    love.graphics.setColor(200, 200, 100)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.printf("Currency: " .. Game.currency, cfg.x, cfg.y + cfg.padding + 25, cfg.width, "center")

    -- Draw menu items or shop items
    local itemY = cfg.y + cfg.padding + 55
    local itemsToShow = {}

    if self.shopMode == "main" then
        itemsToShow = {
            {name = "Buy Gun", type = "action", action = "guns"},
            {name = "Buy Upgrade", type = "action", action = "upgrades"},
            {name = "Leave Store", type = "action", action = "leave"}
        }
    else
        itemsToShow = self.shopItems
    end

    -- Draw items
    for i, item in ipairs(itemsToShow) do
        local btnY = itemY + (i - 1) * (cfg.buttonHeight + cfg.buttonGap)
        local btnX = cfg.x + cfg.padding
        local btnW = cfg.width - cfg.padding * 2

        -- Highlight selected
        if i == self.shopSelection then
            love.graphics.setColor(100, 80, 40)
            love.graphics.rectangle("fill", btnX, btnY, btnW, cfg.buttonHeight)

            -- Selection indicator
            love.graphics.setColor(255, 200, 50)
            love.graphics.polygon("fill",
                btnX + 5, btnY + cfg.buttonHeight / 2 - 3,
                btnX + 10, btnY + cfg.buttonHeight / 2,
                btnX + 5, btnY + cfg.buttonHeight / 2 + 3
            )
        else
            love.graphics.setColor(50, 45, 40)
            love.graphics.rectangle("fill", btnX, btnY, btnW, cfg.buttonHeight)
        end

        -- Button border
        love.graphics.setColor(100, 80, 50)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", btnX, btnY, btnW, cfg.buttonHeight)

        -- Button text
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.printf(item.name, btnX + 15, btnY + 10, 250, "left")

        -- Show price (if not main menu)
        if item.price then
            love.graphics.setColor(200, 200, 100)
            love.graphics.printf("$" .. item.price, btnX + 300, btnY + 10, 250, "left")
        end

        -- Show description
        if item.description then
            love.graphics.setColor(150, 150, 150)
            love.graphics.setFont(love.graphics.newFont(9))
            love.graphics.printf(item.description, btnX + 15, btnY + 20, 350, "left")
        end
    end

    -- Draw feedback message
    if self.shopMessageTimer > 0 then
        love.graphics.setColor(100, 255, 100)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.printf(self.shopMessage, cfg.x, cfg.y + cfg.height - 30, cfg.width, "center")
    end

    -- Draw instructions
    love.graphics.setColor(180, 180, 180)
    love.graphics.setFont(love.graphics.newFont(9))
    love.graphics.printf("↑↓ Navigate | ENTER Buy | ESC Close", cfg.x, cfg.y + cfg.height - 12, cfg.width, "center")
end

function HQScene:openStore()
    self.shopOpen = true
    self.shopMode = "main"
    self.shopItems = {}
    self.shopSelection = 1
    self.shopMessage = ""
end

function HQScene:closeStore()
    self.shopOpen = false
    self.shopMode = nil
    self.shopItems = {}
    self.shopSelection = 1
end

function HQScene:showGuns()
    self.shopMode = "guns"
    self.shopItems = Shop.guns
    self.shopSelection = 1
end

function HQScene:showUpgrades()
    self.shopMode = "upgrades"
    self.shopItems = Shop.upgrades
    self.shopSelection = 1
end

function HQScene:buySelectedItem()
    if self.shopMode == "guns" then
        local gun = self.shopItems[self.shopSelection]
        if Game.currency >= gun.price then
            Game.currency = Game.currency - gun.price
            table.insert(Game.collectedGuns, gun)
            self.shopMessage = "Bought " .. gun.name .. "!"
            self.shopMessageTimer = 2
        else
            self.shopMessage = "Not enough currency!"
            self.shopMessageTimer = 2
        end
    elseif self.shopMode == "upgrades" then
        local upgrade = self.shopItems[self.shopSelection]
        if Game.currency >= upgrade.price then
            Game.currency = Game.currency - upgrade.price
            -- Apply upgrade effect
            self:applyUpgrade(upgrade)
            self.shopMessage = "Bought " .. upgrade.name .. "!"
            self.shopMessageTimer = 2
        else
            self.shopMessage = "Not enough currency!"
            self.shopMessageTimer = 2
        end
    elseif self.shopMode == "main" then
        local selection = self.shopSelection
        if selection == 1 then
            self:showGuns()
        elseif selection == 2 then
            self:showUpgrades()
        elseif selection == 3 then
            self:closeStore()
        end
    end
end

function HQScene:applyUpgrade(upgrade)
    -- Store upgrade in player data for use in missions
    if not Game.playerUpgrades then
        Game.playerUpgrades = {}
    end
    table.insert(Game.playerUpgrades, upgrade)
end

function HQScene:keypressed(key)
    -- Handle shop navigation
    if self.shopOpen then
        if key == "down" or key == "j" then
            if self.shopSelection < #self.shopItems then
                self.shopSelection = self.shopSelection + 1
            end
        elseif key == "up" or key == "k" then
            if self.shopSelection > 1 then
                self.shopSelection = self.shopSelection - 1
            end
        elseif key == "return" or key == "space" then
            self:buySelectedItem()
        elseif key == "escape" or key == "q" then
            if self.shopMode == "main" then
                self:closeStore()
            else
                self.shopMode = "main"
                self.shopSelection = 1
            end
        end
        return
    end

    -- Normal interaction
    if key == "e" then
        local px, py = self.player.x + self.player.w/2, self.player.y + self.player.h/2

        for name, zone in pairs(self.zones) do
            local cz, ct = zone.x + zone.w/2, zone.y + zone.h/2
            local dist = math.sqrt((px - cz)^2 + (py - ct)^2)
            if dist < 80 then
                if name == "mission" then
                    SceneManager.switch(GameScene)
                elseif name == "store" then
                    self:openStore()
                elseif name == "bar" then
                    print("Joe says: " .. self.npcs.joe.dialog)
                elseif name == "vault" then
                    SceneManager.switch(VaultScene)
                end
            end
        end
    end
end

function HQScene:mousepressed(x, y, button)
    if self.shopOpen then
        return
    end

    -- Check if clicking zones
    for name, zone in pairs(self.zones) do
        if x >= zone.x and x <= zone.x + zone.w and
           y >= zone.y and y <= zone.y + zone.h then
            if name == "mission" and button == 1 then
                SceneManager.switch(GameScene)
            elseif name == "store" and button == 1 then
                self:openStore()
            end
        end
    end
end

-- Register scene
SceneManager.add("hq", HQScene)
