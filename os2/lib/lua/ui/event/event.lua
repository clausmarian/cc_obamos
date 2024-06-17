require("/os2/lib/lua/std")

local Event = enum("Event", {
  -- cc os events
  CLICK = "mouse_click",
  DRAG = "mouse_drag",
  SCROLL = "mouse_scroll",
  CHAR = "char",
  KEY = "key",
  DISK_REMOVED = "disk_eject",
  DISK_INSERTED = "disk",

  -- ui
  DRAG_WIDGET = "drag_widget",
  SELECT = "select"
})

return Event
