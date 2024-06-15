require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local TextView = class("TextView", Widget)

function TextView:new(parent, pos, text, textColor, multiline)
  local o = self.super:new(parent, pos, width or 5, height or 1)

  o.text = text
  o.textColor = textColor or colors.black
  o.multiline = multiline or false

  setmetatable(o, self)
  return o
end

function TextView:setText(text)
  if self.multiline and text ~= nil then
    self.text = text:split("\n")
  else
    self.text = text
  end
end

function TextView:getText()
  return self.text
end

function TextView:draw(win, topLeft, bottomRight)
  if self.text ~= nil then
    if self.parent ~= nil then
      win.setBackgroundColor(self.parent.bgColor)
    end
    win.setTextColor(self.textColor)

    if self.multiline and type(self.text) == "table" then
      for i, line in ipairs(self.text) do
        win.setCursorPos(topLeft.x, topLeft.y + i - 1)
        win.write(line)
      end
    else
      win.setCursorPos(topLeft.x, topLeft.y)
      win.write(self.text)
    end
  end
end

return TextView
