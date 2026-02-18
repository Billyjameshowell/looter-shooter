-- Global constants and color definitions
Colors = {
    -- Rarity colors
    common = {200, 200, 200},      -- Gray
    rare = {50, 150, 255},          -- Blue
    epic = {180, 50, 255},          -- Purple
    legendary = {255, 200, 50},     -- Gold
    grail = {255, 50, 50},          -- Red
    
    -- Entity colors
    player = {100, 200, 255},       -- Light blue
    enemyMelee = {255, 50, 50},     -- Red
    enemyRanged = {180, 50, 180},   -- Purple
    boss = {255, 200, 50},          -- Gold
    
    -- UI colors
    textLight = {255, 255, 255},    -- White
    textDark = {50, 50, 50},        -- Dark gray
    buttonBg = {100, 100, 120},     -- Dark blue-gray
    buttonHover = {150, 150, 180},  -- Light blue-gray
    buttonActive = {200, 100, 100}, -- Red-ish
}

-- Rarity weights for loot generation
RARITY_WEIGHTS = {
    common = 0.5,
    rare = 0.25,
    epic = 0.15,
    legendary = 0.08,
    grail = 0.02
}

return Colors
