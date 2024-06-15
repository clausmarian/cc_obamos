require("/os2/lib/lua/std")
local Event = import("ui/event/event")

local EventListener = class("EventListener")

function EventListener:new()
  local o = {
    handlers = {}
  }

  setmetatable(o, self)
  return o
end

function EventListener:addEventHandler(event, handler)
  local key = tostring(event)

  if not self.handlers[key] then
    self.handlers[key] = {}
  end

  self.handlers[key][#self.handlers[key] + 1] = handler
end

function EventListener:removeEventHandlers(event)
  self.handlers[tostring(event)] = nil
end

function EventListener:handlesEvent(event)
  local handlers = self.handlers[tostring(event)]
  return handlers ~= nil and #handlers > 0
end

function EventListener:callEvent(event, ...)
  for _, handler in ipairs(self.handlers[tostring(event)]) do
    handler(...)
  end
end

return EventListener
