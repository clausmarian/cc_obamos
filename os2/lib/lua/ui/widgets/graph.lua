require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local Graph = class("Graph", Widget)

function Graph:new(parent, pos, width, height, queue, bgColor, lineColor, minColor, maxColor, textColor)
  local o = self.super:new(parent, pos, width, height)

  o.queue = queue
  o.bgColor = bgColor or colors.white
  o.lineColor = lineColor or colors.red
  o.minColor = minColor or colors.red
  o.maxColor = maxColor or colors.green
  o.textColor = textColor or colors.black
  o._showLabels = true
  o.unit = ""

  o.min = nil
  o.max = nil

  setmetatable(o, self)
  return o
end

function Graph:showLabels(show)
  self._showLabels = show
end

function Graph:setUnit(unit)
  self.unit = " " .. tostring(unit)
end

function Graph:_updateStats()
  local lmin = table.min(self.queue.data)
  if self.min == nil or lmin < self.min then
    self.min = lmin
  end

  local lmax = table.max(self.queue.data)
  if self.max == nil or lmax > self.max then
    self.max = lmax
  end
end

function Graph:draw(win, topLeft, bottomRight)
  paintutils.drawFilledBox(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y, self.bgColor)

  local inc_x = (self.width - 1) / (self.queue.max_length - 1)

  self:_updateStats()

  local min = self.min
  local max = self.max

  -- don't draw if the queue is empty
  if not min or not max then
    return
  end

  local inc_y = (self.height - 1) / (max - min)

  -- put first value on y axis
  local iter = self.queue:iter()
  local prev_value = iter()
  local prev_x = topLeft.x -- 1
  local prev_y = topLeft.y + (max - prev_value) * inc_y + 1 - 1

  local x = topLeft.x --

  for value in iter do
    x = x + inc_x
    local y = topLeft.y + (max - value) * inc_y + 1 - 1

    paintutils.drawLine(prev_x, prev_y, x, y, self.lineColor)

    prev_x = x
    prev_y = y
  end

  -- draw labels
  if self._showLabels then
    win.setCursorPos(topLeft.x, topLeft.y)
    win.setBackgroundColor(self.maxColor)
    win.setTextColor(self.textColor)
    win.write(ftostring(self.max) .. self.unit)

    win.setCursorPos(topLeft.x, bottomRight.y)
    win.setBackgroundColor(self.minColor)
    win.write(ftostring(self.min) .. self.unit)
  end
end

return Graph
