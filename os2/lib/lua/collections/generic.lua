function table:min()
  local min = nil

  for _, v in pairs(self) do
    if min == nil or v < min then
      min = v
    end
  end

  return min
end

function table:max()
  local max = nil

  for _, v in pairs(self) do
    if max == nil or v > max then
      max = v
    end
  end

  return max
end

function table:find(predicate)
  for _, v in ipairs(self) do
    if predicate(v) then
      return v
    end
  end

  return nil
end

function table:findRemove(findPredicate, removePredicate)
  for i, v in ipairs(self) do
    if removePredicate(v) then
      table.remove(self, i)
    elseif findPredicate(v) then
      return v
    end
  end

  return nil
end

