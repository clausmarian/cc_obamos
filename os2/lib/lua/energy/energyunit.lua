require("/os2/lib/lua/std")

local EnergyUnit = enum("EnergyUnit", {
  -- list is the conversion multiplicator from the unit to FE, J, EU
  FE = { FE = 1, J = 2.5, EU = 0.25 },
  J = { FE = 0.4, J = 1, EU = 0.1 },
  EU = { FE = 4, J = 10, EU = 1 }
})

function EnergyUnit:convertTo(unit, value)
  return self:getValue()[tostring(unit)] * value
end

return EnergyUnit
