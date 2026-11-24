-- Sprite loading and drawing helpers for approved art assets.

local Sprites = {
    loaded = false,
    images = {},
    explosionFrames = {},
    chests = {}
}

local DIRECTIONS = {
    "right",
    "down_right",
    "down",
    "down_left",
    "left",
    "up_left",
    "up",
    "up_right"
}

local function loadImage(path)
    if love.filesystem.getInfo(path) then
        return love.graphics.newImage(path)
    end

    print("Missing sprite: " .. path)
    return nil
end

function Sprites.load()
    if Sprites.loaded then
        return
    end

    Sprites.images.hero = {}
    for _, direction in ipairs(DIRECTIONS) do
        Sprites.images.hero[direction] = loadImage("assets/sprites/hero/" .. direction .. ".png")
    end
    Sprites.images.hero.default = loadImage("assets/sprites/hero/default.png")

    Sprites.images.enemies = {
        melee = loadImage("assets/sprites/enemies/enemy_melee.png"),
        ranged = loadImage("assets/sprites/enemies/enemy_ranged.png"),
        boss = loadImage("assets/sprites/enemies/enemy_boss.png")
    }

    Sprites.images.npcs = {
        joe = loadImage("assets/sprites/npcs/joe.png"),
        dealer = loadImage("assets/sprites/npcs/dealer.png")
    }

    Sprites.images.fx = {
        bullet = loadImage("assets/sprites/fx/bullet.png"),
        spark = loadImage("assets/sprites/fx/spark.png"),
        splatter_green = loadImage("assets/sprites/fx/splatter_green.png"),
        splatter_red = loadImage("assets/sprites/fx/splatter_red.png"),
        grenade = loadImage("assets/sprites/fx/grenade.png")
    }

    Sprites.explosionFrames = {
        loadImage("assets/sprites/fx/explosion_1.png"),
        loadImage("assets/sprites/fx/explosion_2.png"),
        loadImage("assets/sprites/fx/explosion_3.png"),
        loadImage("assets/sprites/fx/explosion_4.png")
    }

    Sprites.chests = {
        common = loadImage("assets/sprites/fx/chest_common.png"),
        rare = loadImage("assets/sprites/fx/chest_rare.png"),
        epic = loadImage("assets/sprites/fx/chest_epic.png"),
        legendary = loadImage("assets/sprites/fx/chest_legendary.png"),
        grail = loadImage("assets/sprites/fx/chest_grail.png")
    }

    for _, image in pairs(Sprites.images.fx) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    for _, image in pairs(Sprites.images.hero) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    for _, image in pairs(Sprites.images.enemies) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    for _, image in pairs(Sprites.images.npcs) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    for _, image in ipairs(Sprites.explosionFrames) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    for _, image in pairs(Sprites.chests) do
        if image then
            image:setFilter("nearest", "nearest")
        end
    end

    Sprites.loaded = true
end

function Sprites.angleToDirection(angle)
    local index = math.floor((angle + math.pi / 8) / (math.pi / 4)) % 8
    return DIRECTIONS[index + 1]
end

function Sprites.getHeroFrame(angle)
    local direction = Sprites.angleToDirection(angle)
    return Sprites.images.hero[direction] or Sprites.images.hero.default
end

function Sprites.getEnemyImage(enemy)
    if enemy.boss then
        return Sprites.images.enemies.boss
    end

    if enemy.type == "ranged" then
        return Sprites.images.enemies.ranged
    end

    return Sprites.images.enemies.melee
end

function Sprites.getChestImage(rarity)
    return Sprites.chests[rarity] or Sprites.chests.common
end

function Sprites.getExplosionFrame(timer, duration)
    if #Sprites.explosionFrames == 0 then
        return nil
    end

    local progress = 1 - (timer / duration)
    local index = math.min(#Sprites.explosionFrames, math.max(1, math.ceil(progress * #Sprites.explosionFrames)))
    return Sprites.explosionFrames[index]
end

function Sprites.drawCentered(image, x, y, targetW, targetH)
    if not image then
        return false
    end

    local iw, ih = image:getDimensions()
    local scale = math.min(targetW / iw, targetH / ih)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(image, x, y, 0, scale, scale, iw / 2, ih / 2)
    return true
end

function Sprites.drawActor(image, x, y, w, h, fallbackColor)
    fallbackColor = fallbackColor or Colors.player
    if not Sprites.drawCentered(image, x + w / 2, y + h / 2, w * 1.4, h * 1.6) then
        love.graphics.setColor(fallbackColor[1] / 255, fallbackColor[2] / 255, fallbackColor[3] / 255)
        love.graphics.rectangle("fill", x, y, w, h)
    end
end

function Sprites.drawHero(x, y, w, h, angle)
    Sprites.drawActor(Sprites.getHeroFrame(angle), x, y, w, h)
end

function Sprites.drawEnemy(enemy)
    local color = enemy.boss and Colors.boss or (enemy.type == "melee" and Colors.enemyMelee or Colors.enemyRanged)
    Sprites.drawActor(Sprites.getEnemyImage(enemy), enemy.x, enemy.y, enemy.w, enemy.h, color)
end

function Sprites.drawNpc(name, x, y, w, h)
    local image = Sprites.images.npcs[name]
    Sprites.drawActor(image, x, y, w, h)
end

function Sprites.drawProjectile(x, y)
    local image = Sprites.images.fx.bullet
    if not Sprites.drawCentered(image, x, y, 12, 12) then
        love.graphics.setColor(1, 1, 0.4)
        love.graphics.circle("fill", x, y, 4)
    end
end

function Sprites.drawGrenade(x, y)
    local image = Sprites.images.fx.grenade
    if not Sprites.drawCentered(image, x, y, 16, 16) then
        love.graphics.setColor(1, 0.6, 0.2)
        love.graphics.circle("fill", x, y, 8)
    end
end

function Sprites.drawExplosion(x, y, timer, duration, radius)
    local image = Sprites.getExplosionFrame(timer, duration)
    if Sprites.drawCentered(image, x, y, radius * 1.2, radius * 1.2) then
        return
    end

    love.graphics.setColor(1, 0.5, 0.2, timer / duration)
    love.graphics.circle("fill", x, y, radius * 0.6)
end

function Sprites.drawLootChest(x, y, rarity, bobY)
    local image = Sprites.getChestImage(rarity)
    if not Sprites.drawCentered(image, x, bobY or y, 28, 28) then
        local color = Colors[rarity] or Colors.common
        love.graphics.setColor(color[1] / 255, color[2] / 255, color[3] / 255)
        love.graphics.rectangle("fill", x - 12, (bobY or y) - 12, 24, 24)
    end
end

return Sprites
