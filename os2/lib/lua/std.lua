function dump_table(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump_table(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function import(path)
  return require("/os2/lib/lua/" .. path)
end

function match(o, t, default)
  local v = t[o]

  if v == nil then
    v = default
  end

  if type(v) == "function" then
    v = v()
  end

  return v
end

-- string
function string.split(inputstr, sep)
  local t = {}

  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end

  return t
end

-- oop
local function search(k, superClasses)
  for _, superClass in ipairs(superClasses) do
    local v = superClass[k]

    if v then
      return v
    end
  end
end

local function makeType(prefix, name)
  local t = {
    _ptype_name = prefix .. ":" .. name,
    _type_name = name
  }

  return t
end

function itype(o)
  local t = o._type_name
  if t then
    return t
  end

  return type(o)
end

function isinstanceof(o, t)
  return itype(o) == itype(t)
end

function class(name, ...)
  local class = makeType("class", name)
  local arg = { ... }

  -- class will search for each method in the list of its parents
  if #arg > 1 then
    error("Class can only have 1 superclass!")
  elseif #arg == 1 then
    setmetatable(class, {
      __index = function(t, k) return search(k, arg) end
    })
    class.super = arg[1]
  end

  class.__index = class

  return class
end

function enum(name, keyToValue)
  local e = makeType("enum", name)
  e.__index = e

  function e:getValue()
    return keyToValue[self.key]
  end

  function e:__tostring()
    return self.key
  end

  -- build enum
  for k, _ in pairs(keyToValue) do
    local o = { key = k }
    setmetatable(o, e)
    e[k] = o
  end

  -- value to key
  local valueToKey = {}
  for k, v in pairs(keyToValue) do
    valueToKey[v] = e[k]
  end

  function e:fromValue(value)
    return match(value, valueToKey, nil)
  end

  return e
end

function strenum(name, keys)
  local keyToValue = {}

  for _, k in ipairs(keys) do
    keyToValue[k] = k
  end

  return enum(name, keyToValue)
end
