local Set = {}

function Set.new(collection)
  local set = {
    data = {},
    length = 0,
  }

  -- convert collection to set
  if collection ~= nil then
    for _, value in ipairs(collection) do
      set.data[value] = 1
      set.length = set.length + 1
    end
  end

  function set:insert(value)
    if not self:contains(value) then
      self.data[value] = 1
      self.length = self.length + 1
    end
  end

  function set:remove(value)
    if self:contains(value) then
      self.data[value] = nil
      self.length = self.length - 1
    end
  end

  function set:contains(value)
    return self.data[value] ~= nil
  end

  return set
end

return Set
