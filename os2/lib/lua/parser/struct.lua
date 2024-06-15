require("/os2/lib/lua/std")

local Struct = class("Struct")

function Struct:new(template)
  local o = {
    template = template,
  }
  setmetatable(o, self)
  return o
end

function Struct:check(t)
  if type(self.template) ~= type(t) then
    return false
  end

  if type(self.template) == "table" then
    for key, vType in pairs(self.template) do
      if type(t[key]) ~= vType then
        return false
      end
    end
  end

  return true
end

return Struct
