require("/os2/lib/lua/std")
local Vec2 = import("math/vec2")

local Rect = class("Rect")

local function calcBottomRight(topLeft, width, height)
  return Vec2:new(topLeft.x + width - 1, topLeft.y + height - 1)
end

function Rect:new(pos, width, height)
  local o = {
    topLeft = pos,
    bottomRight = calcBottomRight(pos, width, height),
    width = width,
    height = height,
  }
  setmetatable(o, self)
  return o
end

function Rect:setPos(pos)
  self.topLeft = pos
  self.bottomRight = calcBottomRight(pos, self.width, self.height)
end

function Rect:setWidth(width)
  self.width = width
  self.bottomRight = calcBottomRight(self.topLeft, self.width, self.height)
end

function Rect:setHeight(height)
  self.height = height
  self.bottomRight = calcBottomRight(self.topLeft, self.width, self.height)
end

function Rect:containsPoint(p)
  return p.x >= self.topLeft.x and p.x <= self.bottomRight.x and p.y >= self.topLeft.y and p.y <= self.bottomRight.y
end

function Rect:localToWorld(p)
  return self.topLeft + p - Vec2:ones()
end

function Rect:worldToLocal(p)
  return p - self.topLeft + Vec2:ones()
end

function Rect:area()
  return self.width * self.height
end

return Rect
