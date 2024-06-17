require("/os2/lib/lua/std")

local function numberParserFactory(atype, parser)
  return function(minv, maxv)
    return {
      atype,
      function(a)
        local suc, value = parser(a)
        if not suc then
          return false
        end

        if minv ~= nil and value < minv then
          return false,
              "value is expected to be greater than " .. tostring(minv - 1) .. " but is '" .. tostring(value) .. "'"
        end

        if maxv ~= nil and value > maxv then
          return false,
              "value is expected to be less than " .. tostring(maxv + 1) .. " but is '" .. tostring(value) .. "'"
        end

        return true, value
      end
    }
  end
end

local Parser = enum("Parser", {
  NUMBER = numberParserFactory("number", parseNumber),
  INT = numberParserFactory("int", parseInt)
})

function Parser:from(...)
  return self:getValue()(...)
end

return Parser
