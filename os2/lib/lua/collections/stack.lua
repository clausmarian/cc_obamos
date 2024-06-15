require("/os2/lib/lua/std")

local Stack = class("Stack")

function Stack:new(max_length)
  local o = {
    data = {},
    first = 1,
    last = 0,
    length = 0,
    max_length = max_length,
  }

  setmetatable(o, self)
  return o
end

function Stack:__len()
  return self.length
end

function Stack:push(value)
  if self.max_length ~= nil and self.length + 1 > self.max_length then
    self:pop()
  end

  self.last = self.last + 1
  self.data[self.last] = value
  self.length = self.length + 1
end

function Stack:pop()
  if self.first > self.last then
    return nil
  end

  local tmp = self.data[self.last]
  self.data[self.last] = nil
  self.last = self.last - 1
  self.length = self.length - 1

  return tmp
end

function Stack:peek()
  if (self.first > self.last) then
    return nil
  end

  return self.data[self.last]
end

return Stack
