local Queue = {}

function Queue.new(max_length)
  local queue = {
    data = {},
    first = 1,
    last = 0,
    length = 0,
    max_length = max_length,
  }

  setmetatable(queue, {
    __len = function(t) return t.length end,
  })

  function queue:push(value)
    if self.max_length ~= nil and self.length + 1 > self.max_length then
      self:pop()
    end

    self.last = self.last + 1
    self.data[self.last] = value
    self.length = self.length + 1
  end

  function queue:pop()
    if self.first > self.last then
      return nil
    end

    local tmp = self.data[self.first]
    self.data[self.first] = nil
    self.first = self.first + 1
    self.length = self.length - 1

    return tmp
  end

  function queue:peek()
    if (self.first > self.last) then
      return nil
    end

    return self.data[self.first]
  end

  function queue:iter()
    local i = self.first - 1
    return function()
      i = i + 1
      if i <= self.last then return self.data[i] end
    end
  end

  function queue:enumerate()
    local i = self.first - 1
    return function()
      i = i + 1
      if i <= self.last then return i - self.first + 1, self.data[i] end
    end
  end

  return queue
end

return Queue
