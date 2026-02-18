local bump = {
  _VERSION     = 'bump v3.1.7',
  _URL         = 'https://github.com/kikito/bump.lua',
  _DESCRIPTION = 'A collision detection library for Lua',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2014 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

------------------------------------------
-- Auxiliary functions
------------------------------------------
local DELTA = 1e-10 -- floating-point margin of error

local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max

local function sign(x)
  if x > 0 then return 1 end
  if x == 0 then return 0 end
  return -1
end

local function nearest(x, a, b)
  if abs(a - x) < abs(b - x) then return a else return b end
end

local function assertType(desiredType, value, name)
  if type(value) ~= desiredType then
    error(name .. ' must be a ' .. desiredType .. ', but was ' .. tostring(value) .. '(a ' .. type(value) .. ')')
  end
end

local function assertIsPositiveNumber(value, name)
  if type(value) ~= 'number' or value <= 0 then
    error(name .. ' must be a positive integer, but was ' .. tostring(value) .. '(' .. type(value) .. ')')
  end
end

local function assertIsRect(x,y,w,h)
  assertType('number', x, 'x')
  assertType('number', y, 'y')
  assertIsPositiveNumber(w, 'w')
  assertIsPositiveNumber(h, 'h')
end

local defaultFilter = function()
  return 'slide'
end

------------------------------------------
-- Rectangle functions
------------------------------------------

local function rect_getNearestCorner(x,y,w,h, px, py)
  return nearest(px, x, x+w), nearest(py, y, y+h)
end

-- This is a generalized implementation of the liang-barsky algorithm, which also returns
-- the normals of the sides where the segment intersects.
-- Returns nil if the segment never touches the rect
-- Notice that normals are only guaranteed to be accurate when initially ti1, ti2 == -math.huge, math.huge
local function rect_getSegmentIntersectionIndices(x,y,w,h, x1,y1,x2,y2, ti1,ti2)
  ti1, ti2 = ti1 or 0, ti2 or 1
  local dx, dy = x2-x1, y2-y1
  local nx, ny
  local nx1, ny1, nx2, ny2 = 0,0,0,0
  local p, q, r

  for side = 1,4 do
    if     side == 1 then nx,ny,p,q = -1,  0, -dx, x1 - x     -- left
    elseif side == 2 then nx,ny,p,q =  1,  0,  dx, x + w - x1 -- right
    elseif side == 3 then nx,ny,p,q =  0, -1, -dy, y1 - y     -- top
    else                  nx,ny,p,q =  0,  1,  dy, y + h - y1 -- bottom
    end

    if p == 0 then
      if q <= 0 then return nil end
    else
      r = q / p
      if p < 0 then
        if     r > ti2 then return nil
        elseif r > ti1 then ti1,nx1,ny1 = r,nx,ny
        end
      else -- p > 0
        if     r < ti1 then return nil
        elseif r < ti2 then ti2,nx2,ny2 = r,nx,ny
        end
      end
    end
  end

  return ti1,ti2, nx1,ny1, nx2,ny2
end

-- Calculates the minkowsky difference between 2 rects, which is another rect
local function rect_getDiff(x1,y1,w1,h1, x2,y2,w2,h2)
  return x2 - x1 - w1,
         y2 - y1 - h1,
         w1 + w2,
         h1 + h2
end

local function rect_containsPoint(x,y,w,h, px,py)
  return px - x > DELTA      and py - y > DELTA and
         x + w - px > DELTA  and y + h - py > DELTA
end

local function rect_isIntersecting(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and x2 < x1+w1 and
         y1 < y2+h2 and y2 < y1+h1
end

local function rect_getSquareDistance(x1,y1,w1,h1, x2,y2,w2,h2)
  local dx = x1 - x2 + (w1 - w2)/2
  local dy = y1 - y2 + (h1 - h2)/2
  return dx*dx + dy*dy
end

local function rect_detectCollision(x1,y1,w1,h1, x2,y2,w2,h2, goalX, goalY)
  goalX = goalX or x1
  goalY = goalY or y1

  local dx, dy      = goalX - x1, goalY - y1
  local x,y,w,h     = rect_getDiff(x1,y1,w1,h1, x2,y2,w2,h2)

  local overlaps, ti, nx, ny

  if rect_containsPoint(x,y,w,h, 0,0) then -- item was intersecting other
    local px, py    = rect_getNearestCorner(x,y,w,h, 0, 0)
    local wi, hi    = min(w1, abs(px)), min(h1, abs(py)) -- area of intersection
    ti              = -wi * hi -- ti is the negative area of intersection
    overlaps = true
  else
    local ti1,ti2,nx1,ny1 = rect_getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, math.huge)

    -- item tunnels into other
    if ti1
    and ti1 < 1
    and (abs(ti1 - ti2) >= DELTA) -- special case for rect going through another rect's corner
    and (0 < ti1 + DELTA
      or 0 == ti1 and ti2 > 0)
    then
      ti, nx, ny = ti1, nx1, ny1
      overlaps   = false
    end
  end

  if not ti then return end

  local tx, ty

  if overlaps then
    if dx == 0 and dy == 0 then
      -- intersecting and not moving - use minimum displacement vector
      local px, py = rect_getNearestCorner(x,y,w,h, 0,0)
      if abs(px) < abs(py) then py = 0 else px = 0 end
      nx, ny = sign(px), sign(py)
      tx, ty = x1 + px, y1 + py
    else
      -- intersecting and moving - move in the opposite direction
      local ti1, _
      ti1,_,nx,ny = rect_getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, 1)
      if not ti1 then return end
      tx, ty = x1 + dx * ti1, y1 + dy * ti1
    end
  else -- tunnel
    tx, ty = x1 + dx * ti, y1 + dy * ti
  end

  return {
    overlaps  = overlaps,
    ti        = ti,
    move      = {x = dx, y = dy},
    normal    = {x = nx, y = ny},
    touch     = {x = tx, y = ty},
    itemRect  = {x = x1, y = y1, w = w1, h = h1},
    otherRect = {x = x2, y = y2, w = w2, h = h2}
  }
end

bump.rect = {
  getNearestCorner              = rect_getNearestCorner,
  getSegmentIntersectionIndices = rect_getSegmentIntersectionIndices,
  getDiff                       = rect_getDiff,
  containsPoint                 = rect_containsPoint,
  isIntersecting                = rect_isIntersecting,
  getSquareDistance             = rect_getSquareDistance,
  detectCollision               = rect_detectCollision
}

return bump
