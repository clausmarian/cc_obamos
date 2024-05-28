Struct = {}

function Struct.new(template)
  local struct = {
    template = template,
  }

  function struct:check(t)
    if type(template) ~= type(t) then
      return false
    end

    if type(template) == "table" then
      for key, vType in pairs(self.template) do
        if type(t[key]) ~= vType then
          return false
        end
      end
    end

    return true
  end

  return struct
end

return Struct
