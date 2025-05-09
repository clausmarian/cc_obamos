require("/os2/lib/lua/std")
local ProgressBar = import("ui/widgets/progressbar")

local AccumulatorBar = class("AccumulatorBar", ProgressBar)

function AccumulatorBar:new(parent, pos, min, max, width, height, bgColor, fgColor)
  local o = self.super:new(parent, pos, min, max, width or 5, height or 4, bgColor or colors.lightGray, fgColor or colors.green)

  setmetatable(o, self)
  return o
end

function AccumulatorBar:draw(win, topLeft, bottomRight)
  paintutils.drawPixel(topLeft.x + (self.width - 1)/2, topLeft.y, colors.gray)
  paintutils.drawBox(topLeft.x, topLeft.y + 1, bottomRight.x, bottomRight.y, colors.gray)
  paintutils.drawFilledBox(topLeft.x + 1, topLeft.y + 2, bottomRight.x - 1, bottomRight.y - 1, self.bgColor)

  local y = math.floor(self.valueRel * (self.height - 3))
  if math.floor(self.valueRel * self.width) > 0 then
    paintutils.drawFilledBox(bottomRight.x - 1, bottomRight.y - 1, topLeft.x + 1, bottomRight.y - y, self.fgColor)
  end
end

return AccumulatorBar
