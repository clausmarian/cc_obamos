local Iter = {}

function Iter.new(iter)
  local holder = {
    iter = iter
  }

  function holder:map(transform)
    return Iter.new(function()
      local value = self.iter()

      if value ~= nil then
        return transform(value)
      end
    end)
  end

  function holder:filter(predicate)
    return Iter.new(function()
      local value = self.iter()

      if value ~= nil and predicate(value) then
        return value
      elseif value ~= nil then
        return self:filter(predicate).iter()
      end
    end)
  end

  return holder
end

function Iter.fromList(t)
  local i = 0
  local n = #t
  return Iter.new(function()
    i = i + 1
    if i <= n then return t[i] end
  end)
end

return Iter
