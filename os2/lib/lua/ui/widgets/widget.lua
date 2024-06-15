require("/os2/lib/lua/std")
local Rect = import("ui/objects/rect")
local Event = import("ui/event/event")
local MouseButton = import("ui/event/mousebutton")
local EventListener = import("ui/event/eventlistener")
local Stack = import("collections/stack")

local Widget = class("Widget", Rect)
Widget.Visibility = strenum("Widget.Visibility", { "NONE", "NONE_EVENTS", "VISIBLE" })

function Widget:new(parent, pos, width, height)
  local o = self.super:new(pos, width, height)

  o.visibility = Widget.Visibility.VISIBLE
  o.parent = parent
  o.eventListener = EventListener:new()
  o.ignoreClicks = false

  setmetatable(o, self)
  return o
end

function Widget:localToRoot(p)
  local parent = self

  while parent ~= nil do
    p = parent:localToWorld(p)
    parent = parent.parent
  end

  return p
end

function Widget:rootToLocal(p)
  local path = Stack:new()
  local parent = self

  while parent ~= nil do
    path:push(parent)
    parent = parent.parent
  end

  while #path > 0 do
    p = path:pop():worldToLocal(p)
  end

  return p
end

function Widget:getRootPositions()
  if self.parent then
    return self.parent:localToRoot(self.topLeft), self.parent:localToRoot(self.bottomRight)
  end

  return self.topLeft, self.bottomRight
end

function Widget:setTag(tag)
  self.tag = tag
end

function Widget:getTag()
  return self.tag
end

function Widget:setVisibility(visibility)
  self.visibility = visibility
end

function Widget:getVisibility()
  return self.visibility
end

function Widget:isVisible()
  return self:getVisibility() == Widget.Visibility.VISIBLE
end

function Widget:ignoresClicks()
  return not self:handlesEvent(Event.CLICK) and self.ignoreClicks
end

function Widget:addEventHandler(event, handler)
  self.eventListener:addEventHandler(event, handler)
end

function Widget:handlesEvent(event)
  return self.eventListener:handlesEvent(event)
end

function Widget:callEvent(event, ...)
  local visibility = self:getVisibility()

  if visibility == Widget.Visibility.VISIBLE or visibility == Widget.Visibility.NONE_EVENTS then
    self.eventListener:callEvent(event, self, ...)
  end
end

function Widget:makeDraggable()
  if self.draggable then
    return
  end

  self:addEventHandler(Event.DRAG, function(self, btn, pos)
    -- pos in coordinate system of the containers parent
    local ppos = pos
    if self.parent.parent then
      ppos = self.parent.parent:rootToLocal(pos)
    end

    -- pos in coordinate system of the container
    pos = self.parent:worldToLocal(ppos)
    ppos = ppos - Vec2:ones()

    if btn == MouseButton.LEFT and self:containsPoint(pos)
        and self.parent:containsPoint(ppos) and self.parent:containsPoint(ppos + Vec2:new(self.width - 1, self.height - 1)) then -- parent contains new widget pos
      if self:handlesEvent(Event.DRAG_WIDGET) then
        self:callEvent(Event.DRAG_WIDGET, pos)
      end
    end
  end)

  self.draggable = true
end

return Widget
