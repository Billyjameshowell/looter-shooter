-- LooterShooter: A Love2D Looter-Shooter Game
-- By Botthew

local bump = require("lib.bump")

function love.load()
    -- Window setup
    love.window.setTitle("LooterShooter")
    love.window.setMode(1200, 800)
    
    -- Game state
    gameState = "hq" -- hq, mission, dead
    world = bump.newWorld(64)
    
    -- Player setup
    player = {
        x = 600,
        y = 400,
        w = 20,
        h = 20,
        speed = 300,
        maxHealth = 100,
        health = 100,
        color = {0.2, 0.5, 1},  -- Blue
        angle = 0
    }
    
    -- Collections
    enemies = {}
    projectiles = {}
    lootChests = {}
    inventory = {guns = {}}
    
    -- Wave system
    wave = 0
    waveEnemiesSpawned = 0
    waveEnemiesKilled = 0
    waveTimer = 0
    spawnInterval = 0.5
    spawnCounter = 0
    
    -- Loot rarities with colors
    rarities = {
        common = {r = 0.8, g = 0.8, b = 0.8, weight = 1},
        rare = {r = 0.2, g = 0.6, b = 1, weight = 0.5},
        epic = {r = 0.7, g = 0.2, b = 1, weight = 0.3},
        legendary = {r = 1, g = 0.8, b = 0, weight = 0.15},
        grail = {r = 1, g = 0.2, b = 0.2, weight = 0.05}
    }
    
    -- Default gun
    defaultGun = {
        name = "Peashooter",
        damage = 5,
        fireRate = 0.2,
        magSize = 10,
        spread = 0.05,
        rarity = "common"
    }
    
    -- HQ locations (text triggers)
    hq = {
        store = {x = 100, y = 100, w = 150, h = 100, label = "STORE"},
        bar = {x = 950, y = 100, w = 150, h = 100, label = "JOE'S BAR"},
        vault = {x = 525, y = 600, w = 150, h = 100, label = "GUN VAULT"},
        exit = {x = 525, y = 100, w = 150, h = 100, label = "TO MISSION"}
    }
    
    print("LooterShooter loaded! Press ESC to quit.")
    print("In HQ: Click 'TO MISSION' to start a run!")
end

function love.update(dt)
    if gameState == "hq" then
        updateHQ(dt)
    elseif gameState == "mission" then
        updateMission(dt)
    elseif gameState == "dead" then
        -- Dead screen - wait for R to restart
    end
end

function updateHQ(dt)
    -- Simple movement in HQ
    if love.keyboard.isDown('w') then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown('s') then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown('a') then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown('d') then player.x = player.x + player.speed * dt end
    
    -- Clamp player to screen
    player.x = math.max(10, math.min(1190, player.x))
    player.y = math.max(30, math.min(790, player.y))
end

function updateMission(dt)
    -- Player movement
    if love.keyboard.isDown('w') then player.y = player.y - player.speed * dt end
    if love.keyboard.isDown('s') then player.y = player.y + player.speed * dt end
    if love.keyboard.isDown('a') then player.x = player.x - player.speed * dt end
    if love.keyboard.isDown('d') then player.x = player.x + player.speed * dt end
    
    -- Clamp player to screen
    player.x = math.max(10, math.min(1190, player.x))
    player.y = math.max(30, math.min(790, player.y))
    
    -- Player aiming (toward mouse)
    local mx, my = love.mouse.getPosition()
    player.angle = math.atan2(my - player.y, mx - player.x)
    
    -- Update projectiles
    for i = #projectiles, 1, -1 do
        local proj = projectiles[i]
        proj.x = proj.x + math.cos(proj.angle) * proj.speed * dt
        proj.y = proj.y + math.sin(proj.angle) * proj.speed * dt
        
        -- Remove if off-screen
        if proj.x < 0 or proj.x > 1200 or proj.y < 0 or proj.y > 800 then
            table.remove(projectiles, i)
        end
    end
    
    -- Spawn enemies
    spawnCounter = spawnCounter + dt
    if spawnCounter >= spawnInterval then
        spawnCounter = 0
        spawnEnemy()
        waveEnemiesSpawned = waveEnemiesSpawned + 1
    end
    
    -- Update enemies
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.health = enemy.health - 0
        
        -- Simple AI: move toward player
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            enemy.x = enemy.x + (dx / dist) * enemy.speed * dt
            enemy.y = enemy.y + (dy / dist) * enemy.speed * dt
        end
        
        -- Ranged enemies shoot back occasionally
        if enemy.type == "ranged" then
            enemy.shootTimer = (enemy.shootTimer or 0) + dt
            if enemy.shootTimer > 2 then
                enemy.shootTimer = 0
                shootProjectile(enemy.x, enemy.y, player.x, player.y, 4, 0)
            end
        end
        
        -- Check collision with projectiles
        for j = #projectiles, 1, -1 do
            local proj = projectiles[j]
            local dist = math.sqrt((proj.x - enemy.x)^2 + (proj.y - enemy.y)^2)
            if dist < 15 then
                enemy.health = enemy.health - 10
                table.remove(projectiles, j)
                
                if enemy.health <= 0 then
                    dropLoot(enemy.x, enemy.y)
                    table.remove(enemies, i)
                    waveEnemiesKilled = waveEnemiesKilled + 1
                end
                break
            end
        end
        
        -- Remove if off-screen
        if enemy.x < -50 or enemy.x > 1250 or enemy.y < -50 or enemy.y > 850 then
            table.remove(enemies, i)
        end
    end
    
    -- Check collision between player and enemies
    for i, enemy in ipairs(enemies) do
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < 30 then
            player.health = player.health - 10 * dt
            if player.health <= 0 then
                gameState = "dead"
            end
        end
    end
    
    -- Update loot chests
    for i = #lootChests, 1, -1 do
        local chest = lootChests[i]
        
        -- Auto-pickup or E to collect
        local dx = player.x - chest.x
        local dy = player.y - chest.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist < 30 then
            table.insert(inventory.guns, chest.gun)
            table.remove(lootChests, i)
        end
    end
    
    -- Wave complete check
    if waveEnemiesSpawned > 0 and waveEnemiesKilled >= wave * 5 and #enemies == 0 then
        nextWave()
    end
end

function spawnEnemy()
    -- Random edge
    local edge = math.random(1, 4)
    local x, y
    
    if edge == 1 then x = math.random(0, 1200) y = -20
    elseif edge == 2 then x = 1220 y = math.random(0, 800)
    elseif edge == 3 then x = math.random(0, 1200) y = 820
    else x = -20 y = math.random(0, 800) end
    
    local enemyType = math.random() < 0.6 and "melee" or "ranged"
    local enemy = {
        x = x, y = y,
        w = 18, h = 18,
        speed = enemyType == "melee" and 120 or 80,
        health = 20,
        type = enemyType,
        color = enemyType == "melee" and {1, 0, 0} or {0.7, 0, 0.7}  -- Red or Purple
    }
    table.insert(enemies, enemy)
end

function shootProjectile(fromX, fromY, toX, toY, speed, spread)
    local angle = math.atan2(toY - fromY, toX - fromX)
    if spread > 0 then
        angle = angle + (math.random() - 0.5) * spread
    end
    
    local proj = {
        x = fromX,
        y = fromY,
        angle = angle,
        speed = speed or 500,
        radius = 3,
        color = {1, 1, 0}  -- Yellow
    }
    table.insert(projectiles, proj)
end

function dropLoot(x, y)
    -- Weighted random rarity
    local rand = math.random()
    local rarity = "common"
    
    if rand < 0.05 then rarity = "grail"
    elseif rand < 0.15 then rarity = "legendary"
    elseif rand < 0.3 then rarity = "epic"
    elseif rand < 0.5 then rarity = "rare"
    end
    
    -- Generate random gun
    local gun = {
        name = rarity .. " Gun " .. math.random(1000, 9999),
        damage = math.random(5, 50),
        fireRate = math.random(1, 10) * 0.1,
        magSize = math.random(5, 30),
        spread = math.random(1, 20) * 0.01,
        rarity = rarity
    }
    
    local chest = {
        x = x, y = y,
        w = 12, h = 12,
        gun = gun,
        rarity = rarity,
        color = rarities[rarity]
    }
    table.insert(lootChests, chest)
end

function nextWave()
    wave = wave + 1
    waveEnemiesSpawned = 0
    waveEnemiesKilled = 0
    spawnInterval = math.max(0.2, 0.5 - wave * 0.05)  -- Increase difficulty
    print("Wave " .. wave .. " started!")
end

function love.draw()
    love.graphics.clear(0.1, 0.1, 0.15)  -- Dark bg
    
    if gameState == "hq" then
        drawHQ()
    elseif gameState == "mission" then
        drawMission()
    elseif gameState == "dead" then
        drawDead()
    end
end

function drawHQ()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("LooterShooter - HQ", 0, 20, 1200, "center")
    love.graphics.printf("Guns in Vault: " .. #inventory.guns, 0, 50, 1200, "center")
    
    -- Draw locations
    drawButton(hq.store)
    drawButton(hq.bar)
    drawButton(hq.vault)
    drawButton(hq.exit)
    
    -- Draw player
    love.graphics.setColor(unpack(player.color))
    love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("WASD to move", 0, 750, 1200, "center")
end

function drawButton(btn)
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(btn.label, btn.x, btn.y + 35, btn.w, "center")
end

function drawMission()
    -- Draw wave info
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Wave: " .. wave, 10, 10, 100, "left")
    love.graphics.printf("Enemies: " .. #enemies, 10, 30, 100, "left")
    love.graphics.printf("Health: " .. math.floor(player.health) .. " / " .. player.maxHealth, 10, 50, 100, "left")
    
    -- Draw player
    love.graphics.setColor(unpack(player.color))
    love.graphics.rectangle("fill", player.x - player.w/2, player.y - player.h/2, player.w, player.h)
    
    -- Draw aiming line
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.line(player.x, player.y, 
                      player.x + math.cos(player.angle) * 50,
                      player.y + math.sin(player.angle) * 50)
    
    -- Draw enemies
    for _, enemy in ipairs(enemies) do
        love.graphics.setColor(unpack(enemy.color))
        love.graphics.rectangle("fill", enemy.x - enemy.w/2, enemy.y - enemy.h/2, enemy.w, enemy.h)
    end
    
    -- Draw projectiles
    for _, proj in ipairs(projectiles) do
        love.graphics.setColor(unpack(proj.color))
        love.graphics.circle("fill", proj.x, proj.y, proj.radius)
    end
    
    -- Draw loot chests
    for _, chest in ipairs(lootChests) do
        love.graphics.setColor(chest.color.r, chest.color.g, chest.color.b)
        love.graphics.rectangle("fill", chest.x - chest.w/2, chest.y - chest.h/2, chest.w, chest.h)
    end
    
    -- Draw health bar
    love.graphics.setColor(0.3, 0, 0)
    love.graphics.rectangle("fill", 10, 70, 200, 20)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, 70, 200 * (player.health / player.maxHealth), 20)
end

function drawDead()
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("YOU DIED!", 0, 300, 1200, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Wave: " .. wave, 0, 350, 1200, "center")
    love.graphics.printf("Guns collected: " .. #inventory.guns, 0, 380, 1200, "center")
    love.graphics.printf("Press R to return to HQ", 0, 450, 1200, "center")
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == "mission" then
        shootProjectile(player.x, player.y, x, y, 500, 0.1)
    elseif button == 1 and gameState == "hq" then
        -- Check button clicks
        if pointInRect(x, y, hq.exit) then
            startMission()
        end
    end
end

function pointInRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.w and
           y >= rect.y and y <= rect.y + rect.h
end

function startMission()
    gameState = "mission"
    wave = 0
    waveEnemiesSpawned = 0
    waveEnemiesKilled = 0
    enemies = {}
    projectiles = {}
    lootChests = {}
    player.x = 600
    player.y = 400
    player.health = player.maxHealth
    nextWave()
    print("Mission started!")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" and gameState == "dead" then
        gameState = "hq"
        player.x = 600
        player.y = 400
        wave = 0
    elseif key == "r" and gameState == "mission" then
        -- Grenade placeholder
        print("Grenade placeholder!")
    end
end
