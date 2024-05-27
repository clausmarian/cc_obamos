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
