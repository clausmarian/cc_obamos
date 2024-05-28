Vec2 = {}

function Vec2.new(x, y)
  local vec2 = {
    x = x,
    y = y
  }

  setmetatable(vec2, {
    __len = function(_) return 2 end,
    __tostring = function(t) return "{ x = " .. tostring(t.x) .. ", y = " .. tostring(t.y) .. " }" end
  })

  function vec2:mul(s)
    self.x = self.x * s
    self.y = self.y * s
  end

  function vec2:map(func)
    self.x = func(self.x)
    self.y = func(self.y)
  end

  function vec2:apply(func)
    return Vec2.new(func(self.x), func(self.y))
  end


  function vec2:equals(other)
    return self.x == other.x and self.y == other.y
  end

  return vec2
end

return Vec2
