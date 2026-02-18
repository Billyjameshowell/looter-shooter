
-- main.lua

function love.load()
    print("LooterShooter loading...")
    -- Initialize game state here
    -- For now, just a placeholder to make it runnable
    player = { x = 400, y = 300, speed = 200, size = 32, color = {0, 0, 1} } -- Blue square player
    enemies = {}
    projectiles = {}
    wave = 1
    gameState = "hq" -- hq or mission

    -- Load libraries later
    -- anim8 = require("anim8")
    -- bump = require("bump")

    print("Game loaded. Current state: " .. gameState)
end

function love.update(dt)
    if gameState == "mission" then
        -- Player movement, shooting, enemy AI, etc. will go here
        -- Placeholder for now
        if love.keyboard.isDown('w') then player.y = player.y - player.speed * dt end
        if love.keyboard.isDown('s') then player.y = player.y + player.speed * dt end
        if love.keyboard.isDown('a') then player.x = player.x - player.speed * dt end
        if love.keyboard.isDown('d') then player.x = player.x + player.speed * dt end

        -- Update projectiles, enemies, check collisions, etc.
    elseif gameState == "hq" then
        -- Logic for HQ scene
    end
end

function love.draw()
    if gameState == "mission" then
        -- Draw player
        love.graphics.setColor(player.color[1], player.color[2], player.color[3])
        love.graphics.rectangle('fill', player.x - player.size/2, player.y - player.size/2, player.size, player.size)

        -- Draw enemies
        love.graphics.setColor(1, 0, 0) -- Red for melee
        for _, enemy in ipairs(enemies) do
            love.graphics.rectangle('fill', enemy.x - enemy.size/2, enemy.y - enemy.size/2, enemy.size, enemy.size)
        end
        love.graphics.setColor(0.7, 0, 0.7) -- Purple for ranged
        for _, enemy in ipairs(enemies) do
             if enemy.type == "ranged" then
                love.graphics.rectangle('fill', enemy.x - enemy.size/2, enemy.y - enemy.size/2, enemy.size, enemy.size)
             end
        end


        -- Draw projectiles
        love.graphics.setColor(1, 1, 0) -- Yellow
        for _, proj in ipairs(projectiles) do
            love.graphics.circle('fill', proj.x, proj.y, proj.radius)
        end

        -- Draw UI (wave counter)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Wave: " .. wave, 10, 10)

    elseif gameState == "hq" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Welcome to the HQ!", 10, 10)
        love.graphics.print("Press 'M' to start Mission", 10, 30)
        love.graphics.print("Press 'S' to enter Store", 10, 50)
        -- Draw player in HQ
        love.graphics.setColor(player.color[1], player.color[2], player.color[3])
        love.graphics.rectangle('fill', player.x - player.size/2, player.y - player.size/2, player.size, player.size)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if gameState == "hq" then
        if key == 'm' then
            print("Starting mission...")
            gameState = "mission"
            -- Initialize mission state
            player.x = love.graphics.getWidth() / 2
            player.y = love.graphics.getHeight() / 2
            enemies = {}
            projectiles = {}
            wave = 1
            -- Add initial enemies for testing
            table.insert(enemies, {x=100, y=100, speed=100, size=20, color={1,0,0}, type="melee"})
            table.insert(enemies, {x=700, y=500, speed=80, size=25, color={0.7,0,0.7}, type="ranged"})
        elseif key == 's' then
            print("Entering Store (text trigger for now)")
            -- Placeholder for store logic
        end
    elseif gameState == "mission" then
        if key == 'r' then
            print("Dropping grenade (placeholder)")
            -- Placeholder for grenade
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and gameState == "mission" then
        print("Player shoots!")
        -- Spawn projectile
        local projectile = {
            x = player.x,
            y = player.y,
            speed = 600,
            radius = 3,
            color = {1, 1, 0},
            direction = {x = x - player.x, y = y - player.y}
        }
        local dir_len = math.sqrt(projectile.direction.x^2 + projectile.direction.y^2)
        if dir_len > 0 then
            projectile.direction.x = projectile.direction.x / dir_len
            projectile.direction.y = projectile.direction.y / dir_len
        end
        table.insert(projectiles, projectile)
    end
end
