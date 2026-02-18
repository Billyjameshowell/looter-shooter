-- Math utility helpers used by scenes.

local atan2 = math.atan2 or function(y, x)
    return math.atan(y, x)
end

-- Returns angle in radians from (x1, y1) to (x2, y2).
function math.angle(x1, y1, x2, y2)
    return atan2(y2 - y1, x2 - x1)
end
