require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local Button = class("Button", Widget)

function Button:new(parent, pos, text, width, height, bgColor, textColor)
  local o = self.super:new(parent, pos, width or 5, height or 1)

  o.text = text
  o.bgColor = bgColor or colors.gray
  o.textColor = textColor or colors.black

  setmetatable(o, self)
  return o
end

function Button:setText(text)
  self.text = text
end

function Button:getText()
  return self.text
end

function Button:draw(win, topLeft, bottomRight)
  paintutils.drawFilledBox(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y, self.bgColor)

  if self.text ~= nil then
    win.setBackgroundColor(self.bgColor)
    win.setTextColor(self.textColor)

    win.setCursorPos(topLeft.x + (math.abs(topLeft.x - bottomRight.x) / 4),
      topLeft.y + (math.abs(topLeft.y - bottomRight.y)) / 4)
    win.write(self.text)
  end
end

return Button
