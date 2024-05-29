M = {}

function M.extend(sub, super)
  setmetatable(sub, super)
  super.__index = super
  return sub
end

return M
