-- HQ Scene - The player's home base
HQScene = {
    player = nil,
    zones = {},
    npcs = {}
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
end

function HQScene:keypressed(key)
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
                    print("Joe says: " .. self.npcs.joe.dialog)
                elseif name == "store" then
                    print("Store: Come back after a mission to buy upgrades!")
                elseif name == "vault" then
                    print("Vault: " .. #Game.collectedGuns .. " guns collected")
                end
            end
        end
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
