-- Cached Love2D fonts to avoid creating new font objects every frame.

local Fonts = {
    cache = {}
}

function Fonts.get(size)
    if not Fonts.cache[size] then
        Fonts.cache[size] = love.graphics.newFont(size)
    end

    return Fonts.cache[size]
end

function Fonts.clear()
    Fonts.cache = {}
end

return Fonts
