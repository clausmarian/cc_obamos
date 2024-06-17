require("/os2/lib/lua/std")
import("ui/core/collecting")
local Event = import("ui/event/event")
local Timer = import("ui/event/timer/timer")
local MouseButton = import("ui/event/mousebutton")
local EventListener = import("ui/event/eventlistener")
local Widget = import("ui/widgets/widget")
local Container = import("ui/layout/container")
local TextInput = import("ui/widgets/textinput")
local Vec2 = import("math/vec2")
import("collections/generic")

local App = class("App")

function App:moveWidget(widget, pos)
  local z_index = self.widgetToZ[widget]
  if not z_index then
    error("Widget not in layout", 2)
  end

  local fromTopLeft, fromBottomRight = widget:getRootPositions()
  widget:setPos(pos)
  moveWidgetPixels(self.posToWidget, { ref = widget, z_index = z_index }, fromTopLeft, fromBottomRight,
    widget:getRootPositions())
end

function App:new()
  local o = {
    widgets = {},
    widgetToIndex = {},
    widgetToZ = {},
    timers = {},
    services = {},
    eventListener = EventListener:new(),
    running = false,
  }
  setmetatable(o, self)
  return o
end

function App:addEventHandler(event, handler)
  self.eventListener:addEventHandler(event, handler)
end

local function isDestroyed(widget)
  return widget._ui_remove == true
end

function App:removeWidget(widget, full)
  if full == nil or full then
    widget._ui_remove = true
  end

  if isinstanceof(widget, Container) then
    self:removeWidgets(widget:getWidgets(), full)
  end

  local i = self.widgetToIndex[widget]
  if i == nil then
    return
  end

  --table.remove(self.widgets, i)
  self.widgets[i] = nil
  self.widgetToIndex[widget] = nil
  self.widgetToZ[widget] = nil
end

function App:removeWidgets(widgets, full)
  for _, widget in pairs(widgets) do
    self:removeWidget(widget, full)
  end
end

function App:addWidget(widget, z_index)
  widget._z_index = z_index
  self.widgets[#self.widgets + 1] = {
    ref = widget,
    z_index = z_index
  }
  self.widgetToIndex[widget] = #self.widgets
  self.widgetToZ[widget] = z_index

  -- TODO: keep children in container and draw them using containers draw event? -> handle visibility in event catcher
  if isinstanceof(widget, Container) then
    self:addWidgets(widget:getWidgets(), z_index + 1)
  end
end

function App:addWidgets(widgets, z_index)
  for _, widget in pairs(widgets) do
    self:addWidget(widget, z_index)
  end
end

function App:addTimer(timer)
  self.timers[#self.timers + 1] = timer
end

function App:addService(func)
  self.services[#self.services + 1] = func
end

local function buildLayout(widgets, focusManager)
  local posToWidget = {}
  local drawables = {}
  local rootContainer = nil

  for _, w in pairs(widgets) do
    local widget = w.ref

    if isinstanceof(widget, Container) and widget:isWorld() then
      if rootContainer then
        error("Only one root window is allowed to exist", 2)
      end

      rootContainer = widget
    end

    -- register textinput in focus manager
    if isinstanceof(widget, TextInput) then
      widget:addEventHandler(Event.CLICK, function(self, btnId, pos)
        if btnId == 1 then
          local old = focusManager.focused
          if old ~= nil then
            old:unfocus()
          end

          focusManager.focused = self
          self:focus()
        end
      end)
    end

    -- register click events
    addWidgetPixels(posToWidget, w, widget:getRootPositions())

    -- register drawable
    if widget.draw then
      drawables[#drawables + 1] = w
    end
  end

  -- sort drawables by z index
  table.sort(drawables, function(a, b)
    return a.z_index < b.z_index
  end)

  if not rootContainer then
    error("No root window found", 2)
  end

  return posToWidget, drawables, rootContainer
end

local function createFocusManager()
  local focusManager = { focused = nil }
  function focusManager:getFocusedWidget()
    if self.focused == nil or isDestroyed(self.focused) then
      self.focused = nil
      return nil
    end

    return self.focused
  end

  return focusManager
end

function App:rebuild()
  local posToWidget, drawables, rootContainer = buildLayout(self.widgets, self.focusManager)
  self.posToWidget = posToWidget
  self.newDrawables = drawables
end

local function handleLoopPcall(app, name, ...)
  app:stop()
  local arg = { ... }
  if not arg[1] then
    printError("Error in '" .. name .. "':" .. arg[2])
  end
end

function App:run()
  -- used to pass key inputs to focused widget
  self.focusManager = createFocusManager()

  local posToWidget, drawables, rootContainer = buildLayout(self.widgets, focusManager)
  self.rootWin = rootContainer.win
  self.posToWidget = posToWidget

  -- add pcall handler to services
  local pcallServices = {}
  for i, service in ipairs(self.services) do
    pcallServices[#pcallServices + 1] = function()
      handleLoopPcall(self, "Service " .. tostring(i), pcall(service))
    end
  end

  self.running = true
  parallel.waitForAny(function()
      handleLoopPcall(self, "eventLoop", pcall(self.eventLoop, self))
    end, function()
      handleLoopPcall(self, "drawLoop", pcall(self.drawLoop, self, drawables, rootContainer))
    end,
    table.unpack(pcallServices))

  if self.running then
    self:stop()
  end
end

function App:stop()
  self.running = false
  self:_resetWindows()
end

function App:_resetWindows()
end

function App:drawLoop(drawables, rootContainer)
  -- double buffering
  local root = rootContainer.win
  local front = window.create(root, 1, 1, rootContainer.width, rootContainer.height, true)
  local back = window.create(root, 1, 1, rootContainer.width, rootContainer.height, false)

  self._resetWindows = function(self)
    front.setVisible(false)
    back.setVisible(false)
    term.redirect(root)
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
  end

  while self.running do
    if self.newDrawables then
      drawables = self.newDrawables
      self.newDrawables = nil
    end

    front.setVisible(true)
    back.setVisible(false)
    rootContainer.win = back

    for i, w in ipairs(drawables) do
      local widget = w.ref

      if isDestroyed(widget) then
        drawables[i] = nil
      elseif widget:isVisible() then
        local topLeft = widget.topLeft
        local bottomRight = widget.bottomRight

        if widget.parent then
          topLeft = widget.parent:localToRoot(topLeft)
          bottomRight = widget.parent:localToRoot(bottomRight)
        end

        -- don't allow widget to manipulate window's bg & txt color
        local win = rootContainer.win
        local bgColor = win.getBackgroundColor()
        local txtColor = win.getTextColor()

        term.redirect(win)
        widget:draw(win, topLeft, bottomRight)

        win.setBackgroundColor(bgColor)
        win.setTextColor(txtColor)
      end
    end
    sleep(0.05)
    --coroutine.yield()

    -- move drawn buffer to front and empty buffer to back
    local tmp = back
    back = front
    front = tmp
  end
end

function App:eventLoop()
  while self.running do
    -- try running all timers
    for _, timer in ipairs(self.timers) do
      timer:run()
    end

    local osEvent, p1, p2, p3 = os.pullEventRaw()
    local event = Event:fromValue(osEvent)

    -- global event handlers
    if self.eventListener:handlesEvent(event) then
      self.eventListener:callEvent(event, p1, p2, p3)
    end

    -- widget event handlers
    if osEvent == "terminate" then
      self:stop()
    elseif osEvent == "timer" then
      -- find fired timer and remove finished timers
      local timer = table.findRemove(self.timers, function(timer)
        return timer.token == p1 and timer.state == Timer.State.RUNNING
      end, function(timer)
        return timer.state == Timer.State.FINISHED
      end)

      if timer ~= nil then
        timer:fire()
      end
    elseif event == Event.CLICK or event == Event.DRAG or event == Event.SCROLL then
      local btnId, mX, mY = p1, p2, p3
      local pos = Vec2:new(mX, mY)

      local zlist = self.posToWidget[tostring(pos)]
      if zlist ~= nil then
        -- find first visible widget that consumes click events
        local w = zlist:findRemove(function(w)
          if w.ref:getVisibility() == Widget.Visibility.NONE then
            return false
          end

          if event == Event.SCROLL then
            -- always bubble scroll events
            return w.ref:handlesEvent(Event.SCROLL)
          else
            return not w.ref:ignoresClicks()
          end
        end, function(widget)
          return isDestroyed(widget)
        end)

        if w ~= nil and w.ref:handlesEvent(event) then
          local m1 = btnId -- scroll dir

          if event ~= Event.SCROLL then
            m1 = MouseButton:fromValue(btnId)
          end

          w.ref:callEvent(event, m1, pos)
        end
      end
    elseif self.focusManager:getFocusedWidget() ~= nil and event == Event.CHAR then
      self.focusManager:getFocusedWidget():callEvent(Event.CHAR, p1)
    elseif self.focusManager:getFocusedWidget() ~= nil and event == Event.KEY then
      self.focusManager:getFocusedWidget():callEvent(Event.KEY, p1, p2)
    end
  end
end

return App
