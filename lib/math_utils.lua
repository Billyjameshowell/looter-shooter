-- Math utility helpers used by scenes.

local atan2 = math.atan2 or function(y, x)
    return math.atan(y, x)
end

-- Returns angle in radians from (x1, y1) to (x2, y2).
function math.angle(x1, y1, x2, y2)
    return atan2(y2 - y1, x2 - x1)
end

function table.random(t)
    if not t or #t == 0 then
        return nil
    end
    return t[math.random(#t)]
end

function table.contains(t, val)
    for _, v in ipairs(t) do
        if v == val then
            return true
        end
        if type(v) == "table" and type(val) == "string" and v.name == val then
            return true
        end
    end
    return false
end

function table.copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end
