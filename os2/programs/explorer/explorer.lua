require("/os2/lib/lua/std")
require("/os2/programs/explorer/explorer_funcs")
local Vec2 = import("math/vec2")
local App = import("ui/app")
local Container = import("ui/layout/container")
local GridContainer = import("ui/layout/grid")
local Button = import("ui/widgets/button")
local TextView = import("ui/widgets/textview")
local ProgressBar = import("ui/widgets/progressbar")
local Widget = import("ui/widgets/widget")
local Event = import("ui/event/event")
local MouseButton = import("ui/event/mousebutton")

local app = App:new()
local parent = GridContainer:frame(nil, nil, colors.lightGray)
parent:makeScrollable(app, parent.height)

-- details popup
local detailsPopup = Container:new(parent, Vec2:new(4, 3), parent.width - 8, parent.height - 4, colors.gray)
local closePopupBtn = Button:new(detailsPopup, Vec2:new(detailsPopup.width, 1), "x", 1, 1, colors.red, colors.white)
closePopupBtn:addEventHandler(Event.CLICK, function(self, btn, pos)
  if btn == MouseButton.LEFT then
    detailsPopup:setVisibility(Widget.Visibility.NONE)
  end
end)
local detailsTextView = TextView:new(detailsPopup, Vec2:new(2, 2))
detailsTextView.multiline = true

detailsPopup:addWidgets({ closePopupBtn, detailsTextView })
detailsPopup:setVisibility(Widget.Visibility.NONE)
app:addWidget(detailsPopup, 4)

local function addDriveUi(container, drive)
  container:addEventHandler(Event.CLICK, function(self, btn, pos)
    if btn == MouseButton.LEFT then
      local text = "Name: " .. drive.name .. "\n"
          .. "Type: " .. drive.type .. "\n"

      if drive.mount then
        text = text .. "Mount: " .. drive.mount .. "\n"
      end

      if drive.address then
        text = text .. "Address: " .. drive.address .. "\n"
      end

      if drive.id then
        text = text .. "Id: " .. tostring(drive.id)
      end

      detailsTextView:setText(text)
      detailsPopup:setVisibility(Widget.Visibility.VISIBLE)
    end
  end)

  local lbl = drive.name
  if drive.mount ~= nil then
    lbl = lbl .. " (" .. drive.mount .. ")"
  end
  container:addWidget(TextView:new(container, Vec2:new(2, 2), lbl, colors.black))

  local y = 3
  if drive.storage then
    -- display storage usage in progress bar
    local progress = ProgressBar:new(container, Vec2:new(2, 3), 0, drive.storage.total, 20, 1, colors.white,
      colors.lightBlue)
    progress:setValue(drive.storage.used)
    if progress:getRelativeValue() > 0.9 then
      progress.fgColor = colors.red
    end

    local progressLabel = TextView:new(container, Vec2:new(2, 4),
      prettyBytes(drive.storage.free) .. " free of " .. prettyBytes(drive.storage.total), colors.black)

    y = y + 2
    container:addWidgets({ [1] = progress, [2] = progressLabel })
  end

  if drive.readOnly then
    container:addWidget(TextView:new(container, Vec2:new(2, y), "read-only", colors.red))
  end

  -- bubble click events to container
  for _, widget in pairs(container:getWidgets()) do
    widget.ignoreClicks = true
  end
end

local function addDriveWidgets(containerWidth, containerHeight, drives)
  for i, drive in ipairs(drives) do
    local container = Container:new(parent, Vec2:ones(), containerWidth, containerHeight, colors.lightGray)
    addDriveUi(container, drive)
    parent:pushWidget(container, i)
  end

  parent:buildLayout(GridContainer.Style:new():paddingLeft(2):paddingTop(2):centerX(true):overflowY(true))
  app:addWidget(parent, 1)
  parent.scrollY = 1
end

CONTAINER_WIDTH = 23
CONTAINER_HEIGHT = 5
addDriveWidgets(CONTAINER_WIDTH, CONTAINER_HEIGHT, getDrives())

local function onDiskChange()
  app:removeWidget(parent, false)
  parent:clearWidgets()
  addDriveWidgets(CONTAINER_WIDTH, CONTAINER_HEIGHT, getDrives())
  app:rebuild()
end
app:addEventHandler(Event.DISK_REMOVED, onDiskChange)
app:addEventHandler(Event.DISK_INSERTED, onDiskChange)

app:run()
