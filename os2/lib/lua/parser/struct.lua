require("/os2/lib/lua/std")

local Struct = class("Struct")

function Struct:new(template, optional)
  local o = {
    template = template,
    optional = optional or false
  }
  setmetatable(o, self)
  return o
end

local function check(template, t)
  for key, vType in pairs(template) do
    local value = t[key]

    if isinstanceof(vType, Struct) then
      if not (value == nil and vType.optional) and not check(vType.template, value) then
        return false
      end
    else
      if (type(vType) == "table" and type(value) ~= "table") or (type(vType) ~= "table" and type(value) ~= vType) then
        return false
      end

      if type(vType) == "table" and not check(vType, value) then
        return false
      end
    end
  end

  return true
end

function Struct:check(t)
  if type(self.template) ~= type(t) then
    return false
  end

  if type(self.template) == "table" then
    if not check(self.template, t) then
      return false
    end
  end

  return true
end

local function fromFile(path)
  if not fs.exists(path) then
    return false
  end

  local file = fs.open(path, "r")
  local t = textutils.unserialiseJSON(file.readAll())
  file.close()

  if t == nil then
    return false
  end

  return true, t
end

local function toFile(path, t)
  fs.makeDir(fs.getDir(path))
  local file = fs.open(path, "w")
  file.write(textutils.serialiseJSON(t))
  file.close()
  return true
end

function Struct:fromFile(path, list)
  local suc, t = fromFile(path)

  if not suc then
    return false
  end

  if list then
    if type(t) ~= "table" then
      return false
    end

    for _, ti in ipairs(t) do
      if not self:check(ti) then
        return false
      end
    end
  elseif not self:check(t) then
    return false
  end

  return true, t
end

function Struct:toFile(path, t)
  if not self:check(t) then
    return false
  end

  return toFile(path, t)
end

return Struct
