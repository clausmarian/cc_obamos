require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")

local TextView = class("TextView", Widget)

function TextView:new(parent, pos, text, textColor, bgColor, multiline, centerText)
  local o = self.super:new(parent, pos, width or 5, height or 1)

  o.text = text
  o.textColor = textColor or colors.black
  o.bgColor = bgColor
  o.multiline = multiline or false
  o.centerText = centerText or false

  setmetatable(o, self)
  o:_calcTextOffsets()
  return o
end

function TextView:setText(text)
  if self.multiline and text ~= nil then
    self.text = text:split("\n")
  else
    self.text = text
  end

  self:_calcTextOffsets()
end

function TextView:getText()
  return self.text
end

function TextView:setCenterText(center)
  self.centerText = center
  self:_calcTextOffsets()
end

function TextView:setWidth(width)
  Widget.setWidth(self, width)
  self:_calcTextOffsets()
end

function TextView:isTextMultiline()
  return self.multiline and type(self.text) == "table"
end

function TextView:_calcTextOffset(text)
  if self.centerText and #text < self.width then
    return (self.width - #self.text) / 2
  end

  return 0
end

function TextView:_calcTextOffsets()
  if not self.centerText or self.text == nil then
    self.textOffset = 0
    return
  end

  if self:isTextMultiline() then
    local offsets = {}

    for i, line in ipairs(self.text) do
      offsets[i] = self:_calcTextOffset(line)
    end

    self.textOffset = offsets
  else
    self.textOffset = self:_calcTextOffset(self.text)
  end
end

function TextView:draw(win, topLeft, bottomRight)
  if self.text ~= nil then
    if self.bgColor then
      win.setBackgroundColor(self.bgColor)
    elseif self.parent ~= nil then
      win.setBackgroundColor(self.parent.bgColor)
    end
    win.setTextColor(self.textColor)

    if self:isTextMultiline() then
      for i, line in ipairs(self.text) do
        local offset = self.textOffset
        if type(offset) == "table" then
          offset = offset[i]
        end

        win.setCursorPos(topLeft.x + offset, topLeft.y + i - 1)
        win.write(line)
      end
    else
      win.setCursorPos(topLeft.x + self.textOffset, topLeft.y)
      win.write(self.text)
    end
  end
end

return TextView
