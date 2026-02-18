-- Shop System
-- Manages store inventory, item sales, currency, and purchasing

local Shop = {}

-- Shop inventory: guns and upgrades available for purchase
Shop.guns = {
    {
        name = "Basic Pistol",
        rarity = "common",
        damage = 15,
        fireRate = 0.4,
        magSize = 12,
        spread = 0.12,
        price = 50
    },
    {
        name = "Combat Rifle",
        rarity = "rare",
        damage = 35,
        fireRate = 0.3,
        magSize = 20,
        spread = 0.08,
        price = 150
    },
    {
        name = "Plasma Rifle",
        rarity = "epic",
        damage = 60,
        fireRate = 0.2,
        magSize = 30,
        spread = 0.05,
        price = 400
    },
    {
        name = "Legendary Cannon",
        rarity = "legendary",
        damage = 100,
        fireRate = 0.15,
        magSize = 50,
        spread = 0.03,
        price = 800
    },
    {
        name = "Grail Blaster",
        rarity = "grail",
        damage = 200,
        fireRate = 0.1,
        magSize = 100,
        spread = 0.01,
        price = 1500
    }
}

-- Upgrades: stat boosts for purchase
Shop.upgrades = {
    {
        name = "Health Boost",
        type = "health",
        value = 25,
        description = "+25 Max HP",
        price = 75
    },
    {
        name = "Damage Upgrade",
        type = "damage",
        value = 10,
        description = "+10% Damage",
        price = 100
    },
    {
        name = "Fire Rate Boost",
        type = "fireRate",
        value = 0.1,
        description = "10% Faster Fire",
        price = 100
    },
    {
        name = "Ammo Efficiency",
        type = "ammo",
        value = 1.2,
        description = "+20% Magazine Size",
        price = 150
    },
    {
        name = "Accuracy Upgrade",
        type = "accuracy",
        value = 0.85,
        description = "-15% Spread",
        price = 80
    }
}

-- Buy a gun from the shop
-- Returns: success (bool), message (string)
function Shop.buyGun(gunIndex, currency)
    if not gunIndex or gunIndex < 1 or gunIndex > #Shop.guns then
        return false, "Invalid gun selection"
    end
    
    local gun = Shop.guns[gunIndex]
    if not currency then currency = 0 end
    
    if currency < gun.price then
        return false, "Not enough currency. Need " .. gun.price .. ", have " .. currency
    end
    
    -- Return the gun and remaining currency
    local newCurrency = currency - gun.price
    return true, gun, newCurrency
end

-- Buy an upgrade from the shop
-- Returns: success (bool), message (string), newCurrency (int)
function Shop.buyUpgrade(upgradeIndex, currency)
    if not upgradeIndex or upgradeIndex < 1 or upgradeIndex > #Shop.upgrades then
        return false, "Invalid upgrade selection", currency
    end
    
    local upgrade = Shop.upgrades[upgradeIndex]
    if not currency then currency = 0 end
    
    if currency < upgrade.price then
        return false, "Not enough currency. Need " .. upgrade.price .. ", have " .. currency, currency
    end
    
    -- Return the upgrade and remaining currency
    local newCurrency = currency - upgrade.price
    return true, upgrade, newCurrency
end

-- Get all shop items (guns + upgrades) for display
function Shop.getAllItems()
    local items = {}
    
    -- Add guns with type identifier
    for i, gun in ipairs(Shop.guns) do
        items[i] = {
            type = "gun",
            index = i,
            name = gun.name,
            rarity = gun.rarity,
            description = "Dmg: " .. gun.damage .. " | Fire: " .. gun.fireRate .. " | Mag: " .. gun.magSize,
            price = gun.price
        }
    end
    
    -- Add upgrades
    local gunCount = #Shop.guns
    for i, upgrade in ipairs(Shop.upgrades) do
        items[gunCount + i] = {
            type = "upgrade",
            index = i,
            name = upgrade.name,
            rarity = "upgrade",
            description = upgrade.description,
            price = upgrade.price
        }
    end
    
    return items
end

-- Earn currency from kills
-- amount: gold/credits earned
-- Example: call Shop.earnCurrency(10) when enemy dies
function Shop.earnCurrency(amount)
    if amount and amount > 0 then
        return amount
    end
    return 0
end

return Shop
