require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local TextInput = class("TextInput", Widget)

function TextInput:new(parent, pos, text, width, height, bgColor, textColor)
  local o = self.super:new(parent, pos, width or 5, height or 1)

  o.text = text or ""
  o.bgColor = bgColor or colors.gray
  o.textColor = textColor or colors.black
  o.focused = false

  setmetatable(o, self)
  return o
end

function TextInput:setText(text)
  self.text = text
end

function TextInput:getText()
  return self.text
end

function TextInput:clearText()
  self.text = ""
end

function TextInput:onChar(char)
  if self.text == nil then
    self.text = char
  else
    self.text = self.text .. char
  end
end

function TextInput:onKey(key, isHeld)
  if self.text ~= nil and #self.text > 0 and key == keys.backspace then
    self.text = self.text:sub(1, -2)
  elseif self.onKeyDown then
    self:onKeyDown(key, isHeld)
  end
end

function TextInput:focus()
  self.focused = true
end

function TextInput:unfocus()
  self.focused = false
end

function TextInput:draw(win, topLeft, bottomRight)
  paintutils.drawFilledBox(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y, self.bgColor)

  if self.text ~= nil then
    win.setBackgroundColor(self.bgColor)
    win.setTextColor(self.textColor)

    win.setCursorPos(topLeft.x + 1, topLeft.y + (math.abs(topLeft.y - bottomRight.y)) / 2)

    if self.focused then
      win.setCursorBlink(true)
    end

    win.write(self.text)
  end
end

return TextInput
