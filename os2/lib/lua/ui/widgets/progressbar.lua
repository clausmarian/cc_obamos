require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local ProgressBar = class("ProgressBar", Widget)

function ProgressBar:new(parent, pos, min, max, width, height, bgColor, fgColor)
  local o = self.super:new(parent, pos, width or 10, height or 1)

  o.min = min or 0
  o.max = max or 100
  o.value = min or 0
  o.valueRel = 0
  o.bgColor = bgColor or colors.white
  o.fgColor = fgColor or colors.blue

  o.diff = o.max - o.min

  setmetatable(o, self)
  return o
end

function ProgressBar:setValue(value)
  if value < self.min then
    value = self.min
  end

  if value > self.max then
    value = self.max
  end

  self.value = value
  self.valueRel = (value - self.min) / self.diff
end

function ProgressBar:getValue()
  return self.value
end

function ProgressBar:getRelativeValue()
  return self.valueRel
end

function ProgressBar:draw(win, topLeft, bottomRight)
  paintutils.drawLine(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y, self.bgColor)

  local x = math.floor(self.valueRel * (self.width - 1))
  if math.floor(self.valueRel * self.width) > 0 then
    paintutils.drawLine(topLeft.x, topLeft.y, topLeft.x + x, bottomRight.y, self.fgColor)
  end
end

return ProgressBar
