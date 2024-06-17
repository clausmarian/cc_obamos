require("/os2/lib/lua/std")

local Queue = class("Queue")

function Queue:new(max_length)
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

function Queue:__len()
  return self.length
end

function Queue:push(value)
  local res = nil
  if self.max_length ~= nil and self.length + 1 > self.max_length then
    res = self:pop()
  end

  self.last = self.last + 1
  self.data[self.last] = value
  self.length = self.length + 1

  return res
end

function Queue:pop()
  if self.first > self.last then
    return nil
  end

  local tmp = self.data[self.first]
  self.data[self.first] = nil
  self.first = self.first + 1
  self.length = self.length - 1

  return tmp
end

function Queue:peek()
  if (self.first > self.last) then
    return nil
  end

  return self.data[self.first]
end

function Queue:iter()
  local i = self.first - 1
  return function()
    i = i + 1
    if i <= self.last then return self.data[i] end
  end
end

function Queue:enumerate()
  local i = self.first - 1
  return function()
    i = i + 1
    if i <= self.last then return i - self.first + 1, self.data[i] end
  end
end

function Queue:map(transform)
  for i = self.first, self.last do
    self.data[i] = transform(self.data[i])
  end
end

return Queue
