require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local RadioButton = class("RadioButton", Widget)

function RadioButton:new(parent, pos, text, width, height, bgColor, textColor, btnBgColor, selectedColor)
  local o = self.super:new(parent, pos, width or 1, height or 1)

  o.text = text
  o.bgColor = bgColor or colors.gray
  o.textColor = textColor or colors.black
  o.btnBgColor = btnBgColor or colors.white
  o.selectedColor = selectedColor or colors.black
  o.selected = false

  setmetatable(o, self)
  return o
end

function RadioButton:setText(text)
  self.text = text
end

function RadioButton:getText()
  return self.text
end

function RadioButton:isSelected()
  return self.selected
end

function RadioButton:draw(win, topLeft, bottomRight)
  paintutils.drawPixel(topLeft.x, topLeft.y, self.btnBgColor)
  if self:isSelected() then
    win.setTextColor(self.selectedColor)
    win.setCursorPos(topLeft.x, topLeft.y)
    win.write("o")
  end

  if self.text ~= nil then
    win.setBackgroundColor(self.bgColor)
    win.setTextColor(self.textColor)

    win.setCursorPos(topLeft.x + 2, topLeft.y)
    win.write(self.text)
  end
end

return RadioButton
