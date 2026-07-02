-- Persists player progress between sessions.

local Save = {
    FILENAME = "save.dat",
    VERSION = 1
}

local function serializeValue(value)
    local valueType = type(value)

    if valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end

    if valueType == "string" then
        return string.format("%q", value)
    end

    if valueType == "table" then
        return Save.serializeTable(value)
    end

    return "nil"
end

function Save.serializeTable(tbl)
    local parts = {}

    for index, value in ipairs(tbl) do
        parts[#parts + 1] = serializeValue(value)
    end

    for key, value in pairs(tbl) do
        if type(key) == "string" then
            parts[#parts + 1] = string.format("%q", key) .. "=" .. serializeValue(value)
        end
    end

    return "{" .. table.concat(parts, ",") .. "}"
end

function Save.captureState()
    return {
        version = Save.VERSION,
        currency = Game.currency or 0,
        wave = Game.wave or 1,
        bestWave = Game.bestWave or 1,
        collectedGuns = Game.collectedGuns or {},
        equippedWeapon = Game.equippedWeapon,
        playerUpgrades = Game.playerUpgrades or {},
        player = Game.player
    }
end

function Save.applyState(data)
    if type(data) ~= "table" then
        return false
    end

    Game.currency = data.currency or 0
    Game.wave = data.wave or 1
    Game.bestWave = data.bestWave or Game.wave or 1
    Game.collectedGuns = data.collectedGuns or {}
    Game.equippedWeapon = data.equippedWeapon
    Game.playerUpgrades = data.playerUpgrades or {}
    Game.player = data.player

    return true
end

function Save.save()
    local payload = "return " .. Save.serializeTable(Save.captureState())

    if love and love.filesystem then
        love.filesystem.write(Save.FILENAME, payload)
        return true
    end

    return false
end

function Save.load()
    if not love or not love.filesystem then
        return false
    end

    if not love.filesystem.getInfo(Save.FILENAME) then
        return false
    end

    local contents = love.filesystem.read(Save.FILENAME)
    if not contents or contents == "" then
        return false
    end

    local fn, err = load(contents, Save.FILENAME)
    if not fn then
        print("Save load failed: " .. tostring(err))
        return false
    end

    local ok, data = pcall(fn)
    if not ok or not Save.applyState(data) then
        print("Save data was invalid.")
        return false
    end

    print("Loaded save data.")
    return true
end

function Save.delete()
    if love and love.filesystem and love.filesystem.getInfo(Save.FILENAME) then
        love.filesystem.remove(Save.FILENAME)
    end
end

return Save
