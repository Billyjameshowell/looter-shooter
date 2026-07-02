-- Applies persistent upgrades and weapon stat modifiers.

local PlayerStats = {}

function PlayerStats.getMaxHealth(base)
    base = base or 100

    if Game.playerUpgrades then
        for _, upgrade in ipairs(Game.playerUpgrades) do
            if upgrade.type == "health" then
                base = base + upgrade.value
            end
        end
    end

    return base
end

function PlayerStats.normalizeWeapon(weapon)
    local normalized = table.copy(weapon)
    normalized.ammo = normalized.ammo or normalized.magSize or 12
    normalized.magSize = normalized.magSize or normalized.ammo
    normalized.color = normalized.color or Colors[normalized.rarity] or Colors.common
    return normalized
end

function PlayerStats.applyWeaponModifiers(weapon)
    local modified = PlayerStats.normalizeWeapon(weapon)

    if Game.playerUpgrades then
        for _, upgrade in ipairs(Game.playerUpgrades) do
            if upgrade.type == "damage" then
                modified.damage = modified.damage * (1 + upgrade.value / 100)
            elseif upgrade.type == "fireRate" then
                modified.fireRate = modified.fireRate * (1 - upgrade.value)
            elseif upgrade.type == "ammo" then
                modified.magSize = math.floor(modified.magSize * upgrade.value)
                modified.ammo = math.min(modified.ammo, modified.magSize)
            elseif upgrade.type == "accuracy" then
                modified.spread = modified.spread * upgrade.value
            end
        end
    end

    return modified
end

return PlayerStats
