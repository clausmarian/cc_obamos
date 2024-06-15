require("/os2/lib/lua/std")
local Widget = import("ui/widgets/widget")
local Vec2 = import("math/vec2")
local Event = import("ui/event/event")

local Container = class("Container", Widget)

function Container:_fromWindow(win, parent, pos, width, height, bgColor)
  local o = self.super:new(parent, pos, width, height)

  o.win = win
  o.bgColor = bgColor
  o.children = {}

  setmetatable(o, self)
  return o
end

function Container:new(parent, pos, width, height, ...)
  return self:_fromWindow(nil, parent, pos, width, height, ...)
end

function Container:frame(...)
  local win = term.current()
  local width, height = win.getSize()

  return self:_fromWindow(win, nil, Vec2:ones(), width, height, ...)
end

function Container:setPos(pos)
  self.super.setPos(self, pos)
end

function Container:setWidth(width)
  self.super.setWidth(self, width)
end

function Container:setHeight(height)
  self.super.setHeight(self, height)
end

function Container:isWorld()
  return self.win ~= nil
end

function Container:getWindow()
  return self.win
end

function Container:addWidget(widget)
  self.children[#self.children + 1] = widget
end

function Container:addWidgets(widgets)
  for _, widget in pairs(widgets) do
    self:addWidget(widget)
  end
end

function Container:getWidgets()
  return self.children
end

function Container:clearWidgets()
  self.children = {}
end

function Container:setVisibility(visibility)
  self.super.setVisibility(self, visibility)

  for _, widget in pairs(self.children) do
    widget:setVisibility(visibility)
  end
end

function Container:_allowScroll(dir, scrollY, _)
  return scrollY + dir > 0
end

function Container:makeScrollable(app, viewHeight)
  if self.scrollable then
    return
  end

  self.scrollY = 1
  self:addEventHandler(Event.SCROLL, function(self, dir, pos)
    if not self:_allowScroll(dir, self.scrollY, viewHeight) then
      return
    end

    self.scrollY = self.scrollY + dir
    for _, widget in ipairs(self:getWidgets()) do
      app:moveWidget(widget, widget.topLeft + Vec2:new(0, -dir))
    end
  end)

  self.scrollable = true
end

function Container:draw(win, topLeft, bottomRight)
  if self.bgColor then
    paintutils.drawFilledBox(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y, self.bgColor)
  end
end

return Container
