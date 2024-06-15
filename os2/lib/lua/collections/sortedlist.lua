require("/os2/lib/lua/std")

local SortedList = class("SortedList")

function SortedList:new(rev, key, comparator)
  local o = {
    data = {},
    rev = rev,
    comparator = comparator or function(a, b)
      if key then
        a = a[key]
        b = b[key]
      end

      if a == b then
        return 0
      elseif a < b then
        return -1
      else
        return 1
      end
    end
  }

  setmetatable(o, self)
  return o
end

function SortedList:__len()
  return #self.data
end

local function bsearch(value, data, comparator, rev)
  local head = 1
  local tail = #data
  local i = 1

  while head <= tail do
    i = math.floor((head + tail) / 2)

    local cmp = comparator(value, data[i])
    if cmp == 0 then
      -- found
      return true, i
    elseif cmp == -1 then
      if rev then
        head = i + 1
      else
        tail = i - 1
      end
    else
      if rev then
        tail = i - 1
      else
        head = i + 1
      end
    end
  end

  -- not found
  return false, math.max(i, head, tail)
end


function SortedList:insert(value)
  if #self == 0 then
    self.data[1] = value
  else
    table.insert(self.data, ({ bsearch(value, self.data, self.comparator, self.rev) })[2], value)
  end
end

function SortedList:removeAt(index)
  if self.data[index] then
    return table.remove(self.data, index)
  end

  return nil
end

function SortedList:remove(value)
  local suc, i = bsearch(value, self.data, self.comparator, self.rev)
  if suc then
    return self:removeAt(i)
  end

  return nil
end

function SortedList:get(index)
  return self.data[index]
end

function SortedList:find(predicate)
  for _, v in ipairs(self.data) do
    if predicate(v) then
      return v
    end
  end

  return nil
end

function SortedList:findRemove(findPredicate, removePredicate)
  for i, v in ipairs(self.data) do
    if removePredicate(v) then
      self:removeAt(i)
    elseif findPredicate(v) then
      return v
    end
  end

  return nil
end

return SortedList
