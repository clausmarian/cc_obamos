function parseNumber(value)
  local n = tonumber(value)
  if n == nil then
    return false
  end

  return true, n
end

function parseInt(value)
  local n = tonumber(value)
  if n == nil then
    return false
  end

  local _, frac = math.modf(n)
  if frac == 0 then
    return true, n
  end

  return false
end

function parseString(value)
  local str = tostring(value)
  if str == nil then
    return false
  end

  return true, str
end

function parseBool(value)
  local str = tostring(value)
  if str == "true" then
    return true, true
  elseif str == "false" then
    return true, false
  else
    return false
  end
end

function parseList(value, parser)
  local t = textutils.unserialise(value)
  if type(t) ~= "table" then
    return false
  end

  for i, v in ipairs(t) do
    local suc, parsedValue = parser(v)
    if not suc then
      return false
    end

    t[i] = parsedValue
  end

  return true, t
end
