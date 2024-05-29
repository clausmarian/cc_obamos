Vec2 = {}

function Vec2:new(x, y)
  local o = {
    x = x,
    y = y
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Vec2:zeros()
  return Vec2:new(0, 0)
end

function Vec2:ones()
  return Vec2:new(1, 1)
end

function Vec2:__len()
  return math.sqrt(self.x^2 + self.y^2)
end

function Vec2:__tostring()
  return "{ x = " .. tostring(self.x) .. ", y = " .. tostring(self.y) .. " }"
end

function Vec2:__mul(s)
  return Vec2:new(self.x * s, self.y * s)
end

function Vec2:__add(w)
  return Vec2:new(self.x + w.x, self.y + w.y)
end

function Vec2:__sub(w)
  return Vec2:new(self.x - w.x, self.y - w.y)
end

function Vec2:normalize()
  return self * (1/#self)
end

function Vec2:map(func)
  self.x = func(self.x)
  self.y = func(self.y)
end

function Vec2:apply(func)
  return Vec2:new(func(self.x), func(self.y))
end

function Vec2:equals(other)
  return self.x == other.x and self.y == other.y
end

return Vec2
