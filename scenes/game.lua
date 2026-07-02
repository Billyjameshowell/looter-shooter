-- Game Scene - The main gameplay loop (waves, combat, loot)
local PlayerStats = require("utils.player_stats")
local Save = require("utils.save")
local Fonts = require("utils.fonts")
local Particles = require("utils.particles")

GameScene = {
    player = nil,
    enemies = {},
    projectiles = {},
    lootDrops = {},
    wave = 1,
    enemiesRemaining = 0,
    waveTimer = 0,
    bossSpawned = false,
    grenades = {},
    dead = false,
    waveClearTimer = 0,
    waveAnnouncement = "",
    floatingTexts = {},
    particles = {}
}

-- Gun generator
local gunNames = {
    common = {"Pistol", "Revolver", "Machine Pistol", "Shotgun"},
    rare = {"SMG", "Assault Rifle", "Combat Shotgun", "Sniper Rifle"},
    epic = {"Plasma Pistol", "Railgun", "Burst Rifle", "Flame Thrower"},
    legendary = {"Doomsday Device", "Vortex Cannon", "Quantum Rifle", "Nova Blaster"},
    grail = {"Grail Cannon", "Reality Breaker", "Infinity Gun", "Omega Destroyer"}
}

local elementNames = {"", "Frost", "Shock", "Corrosive", "Incendiary", "Explosive"}

function GameScene:load()
    Game.world = bump.newWorld(64)

    self.wave = Game.wave
    self.enemies = {}
    self.projectiles = {}
    self.lootDrops = {}
    self.grenades = {}
    self.bossSpawned = false
    self.dead = false
    self.waveClearTimer = 0
    self.waveAnnouncement = ""
    self.floatingTexts = {}
    self.particles = {}

    local maxHealth = PlayerStats.getMaxHealth(100)
    local startingHealth = Game.player and Game.player.health or maxHealth

    self.player = {
        x = 400,
        y = 300,
        w = 32,
        h = 32,
        speed = 200,
        health = math.min(startingHealth, maxHealth),
        maxHealth = maxHealth,
        angle = 0,
        weapon = nil,
        grenades = 3,
        xp = 0,
        level = 1,
        nextLevelXp = 100,
        shootCooldown = 0
    }

    if Game.equippedWeapon then
        self.player.weapon = PlayerStats.applyWeaponModifiers(Game.equippedWeapon)
    else
        self.player.weapon = PlayerStats.applyWeaponModifiers(self:generateStartingGun())
    end

    Game.world:add(self.player, self.player.x, self.player.y, self.player.w, self.player.h)
    self:startWave()
end

function GameScene:generateStartingGun()
    return {
        name = "Starter Pistol",
        rarity = "common",
        damage = 10,
        fireRate = 0.4,
        magSize = 12,
        ammo = 12,
        spread = 0.1,
        color = Colors.common,
        level = 1
    }
end

function GameScene:generateRandomGun()
    -- Determine rarity based on weights
    local rand = math.random()
    local rarity
    if rand < 0.5 then rarity = "common"
    elseif rand < 0.75 then rarity = "rare"
    elseif rand < 0.9 then rarity = "epic"
    elseif rand < 0.97 then rarity = "legendary"
    else rarity = "grail"
    end

    -- Generate stats based on rarity
    local baseDamage = 10 + (rarity == "common" and 0 or rarity == "rare" and 15 or rarity == "epic" and 35 or rarity == "legendary" and 70 or 150)
    local damage = baseDamage + math.random(0, 15) + (self.wave * 2)
    local fireRate = {common = 0.4, rare = 0.3, epic = 0.2, legendary = 0.15, grail = 0.1}[rarity]
    local magSize = {common = 12, rare = 20, epic = 30, legendary = 50, grail = 100}[rarity] + math.random(0, 10)
    local spread = {common = 0.15, rare = 0.1, epic = 0.08, legendary = 0.05, grail = 0.02}[rarity]

    -- Pick a name
    local gunType = table.random(gunNames[rarity] or gunNames.common)
    local element = math.random() < 0.3 and table.random(elementNames) or ""

    return {
        name = (element .. " " .. gunType):gsub("^ ", ""),
        rarity = rarity,
        damage = damage,
        fireRate = fireRate,
        magSize = magSize,
        ammo = magSize,
        spread = spread,
        color = Colors[rarity] or Colors.common,
        element = element,
        level = self.wave
    }
end

function GameScene:startWave()
    local enemyCount = 5 + (self.wave * 3)
    self.enemiesRemaining = enemyCount
    self.waveTimer = 0

    print("=== WAVE " .. self.wave .. " ===")
    print("Enemies remaining: " .. enemyCount)

    -- Spawn enemies
    for i = 1, enemyCount do
        local isBoss = (i == enemyCount and self.wave % 5 == 0)
        self:spawnEnemy(isBoss)
    end
end

function GameScene:spawnEnemy(isBoss)
    local edge = math.random(4)
    local x, y
    if edge == 1 then x, y = math.random(800), -30
    elseif edge == 2 then x, y = 830, math.random(600)
    elseif edge == 3 then x, y = math.random(800), 630
    else x, y = -30, math.random(600)
    end

    local enemyType = isBoss and "boss" or (math.random() < 0.7 and "melee" or "ranged")

    local enemy = {
        x = x,
        y = y,
        w = isBoss and 64 or 32,
        h = isBoss and 64 or 32,
        type = enemyType,
        health = isBoss and 200 + (self.wave * 50) or 20 + (self.wave * 5),
        maxHealth = isBoss and 200 + (self.wave * 50) or 20 + (self.wave * 5),
        speed = isBoss and 80 or (enemyType == "melee" and 120 or 60),
        damage = isBoss and 30 or (enemyType == "melee" and 10 or 8),
        attackCooldown = 0,
        boss = isBoss,
        name = isBoss and self:generateBossName() or nil,
        modifiers = isBoss and self:generateBossModifiers() or {}
    }

    table.insert(self.enemies, enemy)
    Game.world:add(enemy, x, y, enemy.w, enemy.h)
end

function GameScene:generateBossName()
    local prefixes = {"Alpha", "Omega", "Prime", "Ultimate", "Supreme", "Dark", "Void", "Cyber", "Toxic", "Nuclear"}
    local types = {"Beast", "Hunter", "Soldier", "Mech", "Demon", "Robot", "Behemoth", "Titan", "Warlord", "Overlord"}
    return table.random(prefixes) .. " " .. table.random(types)
end

function GameScene:generateBossModifiers()
    local mods = {}
    local numMods = math.random(0, 3)

    local possibleMods = {
        {name = "Flame Bullets", color = {255, 100, 50}},
        {name = "Knockback", color = {100, 200, 255}},
        {name = "Regeneration", color = {100, 255, 100}},
        {name = "Speed Boost", color = {255, 255, 100}},
        {name = "Armor", color = {150, 150, 150}}
    }

    for i = 1, numMods do
        local mod = table.random(possibleMods)
        if not table.contains(mods, mod.name) then
            table.insert(mods, mod)
        end
    end

    return mods
end

function GameScene:enemyHasModifier(enemy, modifierName)
    if not enemy.modifiers then
        return false
    end

    for _, mod in ipairs(enemy.modifiers) do
        if mod.name == modifierName then
            return true
        end
    end

    return false
end

function GameScene:getEnemySpeed(enemy)
    local speed = enemy.speed
    if self:enemyHasModifier(enemy, "Speed Boost") then
        speed = speed * 1.5
    end
    return speed
end

function GameScene:getEnemyDamageTaken(enemy, damage)
    if self:enemyHasModifier(enemy, "Armor") then
        return damage * 0.5
    end
    return damage
end

function GameScene:spawnFloatingText(x, y, text, color)
    table.insert(self.floatingTexts, {
        x = x,
        y = y,
        text = text,
        life = 0.8,
        color = color or {255, 255, 120}
    })
end

function GameScene:updateFloatingTexts(dt)
    for index = #self.floatingTexts, 1, -1 do
        local floater = self.floatingTexts[index]
        floater.life = floater.life - dt
        floater.y = floater.y - 30 * dt

        if floater.life <= 0 then
            table.remove(self.floatingTexts, index)
        end
    end
end

function GameScene:beginWaveClear()
    Game.bestWave = math.max(Game.bestWave or 1, self.wave)
    self.waveClearTimer = 2.0
    self.waveAnnouncement = "WAVE " .. self.wave .. " CLEAR!"
    Particles.spawnBurst(self.particles, self.player.x + self.player.w/2, self.player.y + self.player.h/2, {
        count = 20,
        speed = 90,
        life = 0.6,
        radius = 3,
        color = {120, 220, 255}
    })
end

function GameScene:advanceWave()
    self.wave = self.wave + 1
    Game.wave = self.wave
    Game.bestWave = math.max(Game.bestWave or 1, self.wave)
    print("Wave complete! Starting wave " .. self.wave)
    self.waveAnnouncement = "WAVE " .. self.wave
    self:startWave()
end

function GameScene:update(dt)
    if self.dead then
        return
    end

    if self.waveClearTimer > 0 then
        self.waveClearTimer = self.waveClearTimer - dt
        self:updateFloatingTexts(dt)
        Particles.update(self.particles, dt)

        if self.waveClearTimer <= 0 then
            self:advanceWave()
        end
        return
    end

    self:updatePlayer(dt)
    self:updateEnemies(dt)
    self:updateProjectiles(dt)
    self:updateLootDrops(dt)
    self:updateGrenades(dt)
    self:updateFloatingTexts(dt)
    Particles.update(self.particles, dt)

    if #self.enemies == 0 and self.waveClearTimer <= 0 then
        self:beginWaveClear()
    end

    if self.player.health <= 0 then
        self.dead = true
        print("You died! Press R to return to HQ.")
    end
end

function GameScene:updatePlayer(dt)
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
        newX = math.max(0, math.min(800 - self.player.w, newX))
        newY = math.max(0, math.min(600 - self.player.h, newY))

        Game.world:update(self.player, newX, newY, self.player.w, self.player.h)
        self.player.x, self.player.y = newX, newY
    end

    -- Player rotation
    self.player.angle = math.angle(
        self.player.x + self.player.w/2,
        self.player.y + self.player.h/2,
        love.mouse.getX(),
        love.mouse.getY()
    )

    if self.player.shootCooldown > 0 then
        self.player.shootCooldown = self.player.shootCooldown - dt
    end
end

function GameScene:updateEnemies(dt)
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]

        -- Move toward player
        local px, py = self.player.x + self.player.w/2, self.player.y + self.player.h/2
        local ex, ey = enemy.x + enemy.w/2, enemy.y + enemy.h/2
        local angle = math.angle(ex, ey, px, py)

        if enemy.type == "melee" or enemy.type == "boss" then
            local speed = self:getEnemySpeed(enemy) * dt
            local newX = enemy.x + math.cos(angle) * speed
            local newY = enemy.y + math.sin(angle) * speed

            -- Simple collision avoidance between enemies
            local blocked = false
            for j, other in ipairs(self.enemies) do
                if other ~= enemy then
                    local dist = math.sqrt((newX - other.x)^2 + (newY - other.y)^2)
                    if dist < 40 then blocked = true end
                end
            end

            if not blocked then
                Game.world:update(enemy, newX, newY, enemy.w, enemy.h)
                enemy.x, enemy.y = newX, newY
            end

            -- Attack player if close
            if enemy.attackCooldown > 0 then
                enemy.attackCooldown = enemy.attackCooldown - dt
            else
                local dist = math.sqrt((px - ex)^2 + (py - ey)^2)
                if dist < 50 then
                    self.player.health = self.player.health - enemy.damage
                    enemy.attackCooldown = 1
                    print("Player hit! HP: " .. math.floor(self.player.health))
                end
            end
        elseif enemy.type == "ranged" then
            -- Shoot at player from distance
            if enemy.attackCooldown > 0 then
                enemy.attackCooldown = enemy.attackCooldown - dt
            else
                local dist = math.sqrt((px - ex)^2 + (py - ey)^2)
                if dist > 100 and dist < 400 then
                    local projColor = Colors.enemyRanged
                    local projDamage = enemy.damage
                    if self:enemyHasModifier(enemy, "Flame Bullets") then
                        projColor = {255, 100, 50}
                        projDamage = projDamage * 1.5
                    end

                    local proj = {
                        x = ex,
                        y = ey,
                        vx = math.cos(angle) * 200,
                        vy = math.sin(angle) * 200,
                        damage = projDamage,
                        color = projColor,
                        isEnemy = true
                    }
                    table.insert(self.projectiles, proj)
                    enemy.attackCooldown = 2
                elseif dist <= 100 then
                    -- Retreat
                    local newX = enemy.x - math.cos(angle) * 30 * dt
                    local newY = enemy.y - math.sin(angle) * 30 * dt
                    Game.world:update(enemy, newX, newY, enemy.w, enemy.h)
                    enemy.x, enemy.y = newX, newY
                else
                    -- Move closer
                    local speed = self:getEnemySpeed(enemy) * dt
                    local newX = enemy.x + math.cos(angle) * speed
                    local newY = enemy.y + math.sin(angle) * speed
                    Game.world:update(enemy, newX, newY, enemy.w, enemy.h)
                    enemy.x, enemy.y = newX, newY
                end
            end
        end

        if self:enemyHasModifier(enemy, "Regeneration") and enemy.health < enemy.maxHealth then
            enemy.health = math.min(enemy.maxHealth, enemy.health + 8 * dt)
        end
    end
end

function GameScene:updateProjectiles(dt)
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        proj.x = proj.x + proj.vx * dt
        proj.y = proj.y + proj.vy * dt

        -- Check bounds
        if proj.x < -20 or proj.x > 820 or proj.y < -20 or proj.y > 620 then
            table.remove(self.projectiles, i)
        -- Check enemy hits
        elseif proj.isEnemy then
            local px, py = self.player.x, self.player.y
            if proj.x > px and proj.x < px + self.player.w and
               proj.y > py and proj.y < py + self.player.h then
                self.player.health = self.player.health - proj.damage
                table.remove(self.projectiles, i)
            end
        -- Check player hits
        else
            for j = #self.enemies, 1, -1 do
                local enemy = self.enemies[j]
                if proj.x > enemy.x and proj.x < enemy.x + enemy.w and
                   proj.y > enemy.y and proj.y < enemy.y + enemy.h then
                    local damage = self:getEnemyDamageTaken(enemy, proj.damage)
                    enemy.health = enemy.health - damage
                    self:spawnFloatingText(enemy.x + enemy.w/2, enemy.y, "-" .. math.floor(damage), {255, 220, 120})
                    Particles.spawnBurst(self.particles, proj.x, proj.y, {
                        count = 4,
                        speed = 60,
                        life = 0.25,
                        radius = 2,
                        color = {255, 220, 120}
                    })
                    table.remove(self.projectiles, i)

                    if enemy.health <= 0 then
                        self:enemyKilled(enemy, j)
                    end
                    break
                end
            end
        end
    end
end

function GameScene:enemyKilled(enemy, index)
    Game.world:remove(enemy)
    table.remove(self.enemies, index)

    Particles.spawnBurst(self.particles, enemy.x + enemy.w/2, enemy.y + enemy.h/2, {
        count = enemy.boss and 24 or 10,
        speed = enemy.boss and 140 or 80,
        life = 0.45,
        radius = enemy.boss and 5 or 3,
        color = enemy.boss and Colors.boss or Colors.enemyMelee
    })

    -- Drop loot
    local lootChance = 0.3 + (enemy.type == "boss" and 0.7 or 0)
    if math.random() < lootChance or enemy.boss then
        self:dropLoot(enemy.x + enemy.w/2, enemy.y + enemy.h/2, enemy.boss)
    end

    -- Award currency based on enemy type
    local currencyGain = 0
    if enemy.boss then
        currencyGain = 100 + (self.wave * 10)  -- Boss gives lots of currency
    elseif enemy.type == "ranged" then
        currencyGain = 25 + (self.wave * 2)    -- Ranged enemies worth more
    else
        currencyGain = 10 + (self.wave * 1)    -- Melee enemies give standard currency
    end
    
    Game.currency = (Game.currency or 0) + currencyGain
    print("Gold earned: +" .. currencyGain .. " (Total: " .. Game.currency .. ")")

    -- XP
    local xpGain = enemy.boss and 100 or 20
    self.player.xp = self.player.xp + xpGain
    if self.player.xp >= self.player.nextLevelXp then
        self.player.level = self.player.level + 1
        self.player.xp = self.player.xp - self.player.nextLevelXp
        self.player.nextLevelXp = math.floor(self.player.nextLevelXp * 1.5)
        self.player.maxHealth = self.player.maxHealth + 20
        self.player.health = self.player.maxHealth
        print("LEVEL UP! Level " .. self.player.level)
    end

    print("Enemy killed! XP: " .. self.player.xp .. "/" .. self.player.nextLevelXp)
end

function GameScene:dropLoot(x, y, isBoss)
    local gun = self:generateRandomGun()

    -- Boost for boss
    if isBoss then
        gun.damage = gun.damage * 2
        gun.level = self.wave + 2
        print("BOSS LOOT: " .. gun.name .. " (" .. gun.rarity .. ")")
    end

    local drop = {
        x = x,
        y = y,
        gun = gun,
        bobOffset = 0,
        bobSpeed = 3
    }
    table.insert(self.lootDrops, drop)
end

function GameScene:updateLootDrops(dt)
    for i = #self.lootDrops, 1, -1 do
        local drop = self.lootDrops[i]
        drop.bobOffset = drop.bobOffset + drop.bobSpeed * dt

        -- Auto-pickup when close
        local dist = math.sqrt(
            (drop.x - self.player.x - self.player.w/2)^2 +
            (drop.y - self.player.y - self.player.h/2)^2
        )

        if dist < 50 then
            table.insert(Game.collectedGuns, drop.gun)
            print("Acquired: " .. drop.gun.name .. " (" .. drop.gun.rarity .. ")")

            Particles.spawnBurst(self.particles, drop.x, drop.y, {
                count = 8,
                speed = 50,
                life = 0.35,
                radius = 2,
                color = drop.gun.color
            })
            self:spawnFloatingText(drop.x, drop.y - 10, drop.gun.name, drop.gun.color)

            -- Equip if better than current
            if not self.player.weapon or drop.gun.damage > self.player.weapon.damage then
                self.player.weapon = PlayerStats.applyWeaponModifiers(drop.gun)
                print("Equipped: " .. drop.gun.name)
            end

            table.remove(self.lootDrops, i)
        end
    end
end

function GameScene:throwGrenade()
    if self.player.grenades <= 0 then return end

    self.player.grenades = self.player.grenades - 1

    local mx, my = love.mouse.getPosition()
    local px, py = self.player.x + self.player.w/2, self.player.y + self.player.h/2
    local angle = math.angle(px, py, mx, my)

    local grenade = {
        x = px,
        y = py,
        vx = math.cos(angle) * 300,
        vy = math.sin(angle) * 300,
        timer = 1,
        radius = 100,
        damage = 50
    }
    table.insert(self.grenades, grenade)
end

function GameScene:reloadWeapon()
    if self.player.weapon then
        self.player.weapon.ammo = self.player.weapon.magSize
    end
end

function GameScene:shoot()
    if self.dead or self.waveClearTimer > 0 then
        return
    end

    if self.player.shootCooldown > 0 then
        return
    end

    if not self.player.weapon or self.player.weapon.ammo <= 0 then
        return
    end

    self.player.weapon.ammo = self.player.weapon.ammo - 1
    self.player.shootCooldown = self.player.weapon.fireRate

    local cx, cy = self.player.x + self.player.w/2, self.player.y + self.player.h/2
    local angle = self.player.angle + (math.random() - 0.5) * self.player.weapon.spread

    local proj = {
        x = cx,
        y = cy,
        vx = math.cos(angle) * 500,
        vy = math.sin(angle) * 500,
        damage = self.player.weapon.damage,
        color = {255, 255, 100},
        isEnemy = false
    }
    table.insert(self.projectiles, proj)
end

function GameScene:updateGrenades(dt)
    for i = #self.grenades, 1, -1 do
        local grenade = self.grenades[i]
        grenade.timer = grenade.timer - dt
        grenade.x = grenade.x + grenade.vx * dt
        grenade.y = grenade.y + grenade.vy * dt
        grenade.vx = grenade.vx * 0.9

        if grenade.timer <= 0 then
            Particles.spawnBurst(self.particles, grenade.x, grenade.y, {
                count = 18,
                speed = 160,
                life = 0.5,
                radius = 4,
                color = {255, 140, 60}
            })

            for j = #self.enemies, 1, -1 do
                local enemy = self.enemies[j]
                local dist = math.sqrt((grenade.x - (enemy.x + enemy.w/2))^2 + (grenade.y - (enemy.y + enemy.h/2))^2)
                if dist < grenade.radius then
                    enemy.health = enemy.health - self:getEnemyDamageTaken(enemy, grenade.damage)
                    if enemy.health <= 0 then
                        self:enemyKilled(enemy, j)
                    end
                end
            end
            table.remove(self.grenades, i)
        end
    end
end

function GameScene:draw()
    -- Draw background
    love.graphics.setColor(30, 30, 40)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw grid pattern
    love.graphics.setColor(40, 40, 50)
    for x = 0, 800, 50 do
        love.graphics.line(x, 0, x, 600)
    end
    for y = 0, 600, 50 do
        love.graphics.line(0, y, 800, y)
    end

    -- Draw loot drops
    for _, drop in ipairs(self.lootDrops) do
        local bobY = drop.y + math.sin(drop.bobOffset) * 5
        love.graphics.setColor(drop.gun.color[1], drop.gun.color[2], drop.gun.color[3])
        love.graphics.rectangle("fill", drop.x - 12, bobY - 12, 24, 24)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(Fonts.get(10))
        love.graphics.printf(drop.gun.rarity:sub(1, 1), drop.x - 10, bobY - 8, 20, "center")
    end

    -- Draw enemies
    for _, enemy in ipairs(self.enemies) do
        local color = enemy.boss and Colors.boss or (enemy.type == "melee" and Colors.enemyMelee or Colors.enemyRanged)
        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.w, enemy.h)

        -- Health bar
        local healthPercent = enemy.health / enemy.maxHealth
        love.graphics.setColor(100, 0, 0)
        love.graphics.rectangle("fill", enemy.x, enemy.y - 8, enemy.w, 5)
        love.graphics.setColor(0, 200, 0)
        love.graphics.rectangle("fill", enemy.x, enemy.y - 8, enemy.w * healthPercent, 5)

        -- Boss name
        if enemy.boss then
            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(Fonts.get(10))
            love.graphics.printf(enemy.name or "BOSS", enemy.x - 20, enemy.y - 20, enemy.w + 40, "center")

            if enemy.modifiers then
                for i, mod in ipairs(enemy.modifiers) do
                    love.graphics.setColor(mod.color[1], mod.color[2], mod.color[3])
                    love.graphics.setFont(Fonts.get(8))
                    love.graphics.printf(mod.name, enemy.x - 20, enemy.y - 10 + i * 10, enemy.w + 40, "center")
                end
            end
        end
    end

    -- Draw player
    love.graphics.setColor(Colors.player[1], Colors.player[2], Colors.player[3])
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.w, self.player.h)

    -- Draw player direction
    love.graphics.setColor(100, 200, 255)
    local cx, cy = self.player.x + self.player.w/2, self.player.y + self.player.h/2
    love.graphics.line(cx, cy, cx + math.cos(self.player.angle) * 25, cy + math.sin(self.player.angle) * 25)

    -- Draw projectiles
    for _, proj in ipairs(self.projectiles) do
        love.graphics.setColor(proj.color[1], proj.color[2], proj.color[3])
        love.graphics.circle("fill", proj.x, proj.y, 4)
    end

    -- Draw grenades
    for _, grenade in ipairs(self.grenades) do
        love.graphics.setColor(255, 150, 50)
        love.graphics.circle("fill", grenade.x, grenade.y, 8)
    end

    Particles.draw(self.particles)

    for _, floater in ipairs(self.floatingTexts) do
        local alpha = math.max(0.2, floater.life / 0.8)
        love.graphics.setColor(floater.color[1], floater.color[2], floater.color[3], alpha)
        love.graphics.setFont(Fonts.get(10))
        love.graphics.printf(floater.text, floater.x - 30, floater.y, 60, "center")
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.get(16))
    love.graphics.print("Wave: " .. self.wave, 10, 50)
    love.graphics.print("Enemies: " .. #self.enemies, 10, 70)
    love.graphics.print("Gold: " .. (Game.currency or 0), 10, 90)

    -- Health bar
    love.graphics.setColor(100, 0, 0)
    love.graphics.rectangle("fill", 10, 115, 200, 15)
    love.graphics.setColor(0, 200, 0)
    love.graphics.rectangle("fill", 10, 115, 200 * (self.player.health / self.player.maxHealth), 15)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.get(12))
    love.graphics.print("HP: " .. math.floor(self.player.health) .. "/" .. self.player.maxHealth, 15, 116)

    if self.player.weapon then
        love.graphics.print("Weapon: " .. self.player.weapon.name, 10, 135)
        love.graphics.print("Damage: " .. math.floor(self.player.weapon.damage), 10, 155)
        love.graphics.print("Ammo: " .. self.player.weapon.ammo .. "/" .. self.player.weapon.magSize, 10, 175)
    end

    love.graphics.print("Grenades: " .. self.player.grenades .. " (G)", 10, 195)
    love.graphics.print("R: Reload", 10, 215)

    love.graphics.setColor(100, 0, 100)
    love.graphics.rectangle("fill", 10, 240, 200, 10)
    love.graphics.setColor(200, 50, 200)
    love.graphics.rectangle("fill", 10, 240, 200 * (self.player.xp / self.player.nextLevelXp), 10)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(Fonts.get(10))
    love.graphics.print("Level " .. self.player.level .. "  XP: " .. math.floor(self.player.xp) .. "/" .. self.player.nextLevelXp, 10, 241)

    if self.waveClearTimer > 0 then
        love.graphics.setColor(0, 0, 0, 120)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        love.graphics.setColor(120, 220, 255)
        love.graphics.setFont(Fonts.get(24))
        love.graphics.printf(self.waveAnnouncement, 0, 250, 800, "center")

        love.graphics.setColor(220, 220, 220)
        love.graphics.setFont(Fonts.get(12))
        love.graphics.printf("Next wave incoming...", 0, 290, 800, "center")
    end

    if self.dead then
        love.graphics.setColor(0, 0, 0, 180)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        love.graphics.setColor(255, 80, 80)
        love.graphics.setFont(Fonts.get(28))
        love.graphics.printf("YOU DIED", 0, 220, 800, "center")

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(Fonts.get(14))
        love.graphics.printf("Wave reached: " .. self.wave, 0, 270, 800, "center")
        love.graphics.printf("Best wave: " .. (Game.bestWave or self.wave), 0, 295, 800, "center")
        love.graphics.printf("Loot collected: " .. #Game.collectedGuns, 0, 320, 800, "center")
        love.graphics.printf("Press R to return to HQ", 0, 360, 800, "center")
    end
end

function GameScene:keypressed(key)
    if self.dead then
        if key == "r" then
            self:returnToHQ(true)
        end
        return
    end

    if key == "r" then
        self:reloadWeapon()
    elseif key == "g" then
        self:throwGrenade()
    elseif key == "escape" then
        self:returnToHQ(false)
    end
end

function GameScene:mousepressed(x, y, button)
    if button == 1 then
        self:shoot()
    end
end

function GameScene:returnToHQ(wasDeath)
    if wasDeath then
        Game.wave = 1
    else
        Game.bestWave = math.max(Game.bestWave or 1, self.wave)
    end

    Game.player = {
        health = wasDeath and self.player.maxHealth or math.max(1, self.player.health),
        maxHealth = self.player.maxHealth,
        weapon = self.player.weapon
    }
    Game.equippedWeapon = table.copy(self.player.weapon)

    Save.save()
    Game.world = bump.newWorld(64)
    SceneManager.switch(HQScene)
end

-- Register scene
SceneManager.add("game", GameScene)
