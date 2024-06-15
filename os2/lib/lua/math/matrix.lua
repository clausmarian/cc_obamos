require("/os2/lib/lua/std")

local Matrix = class("Matrix")

function Matrix:new(n, m)
  local o = {
    data = {},
    n = n,
    m = m
  }

  setmetatable(o, self)
  return o
end

function Matrix:__len()
  return self.n * self.m
end

function Matrix:__tostring()
  return "n = " .. tostring(self.n) .. ", m = " .. tostring(self.m) .. "\n" .. dump_table(self.data)
end

function Matrix:_calcMatrixIndex(i, j)
  if i < 0 or i > self.n or j < 0 or j > self.m then
    error("Matrix index out of bounds", 2)
  end

  return self.n * (j - 1) + i
end

function Matrix:get(i, j)
  return self.data[self:_calcMatrixIndex(i, j)]
end

function Matrix:set(i, j, value)
  self.data[self:_calcMatrixIndex(i, j)] = value
end

function Matrix:setRaw(i, value)
  if i > #self then
    error("Index out of bounds", 2)
  end

  self.data[i] = value
end

function Matrix:remove(i, j)
  self:set(i, j, nil)
end

return Matrix
