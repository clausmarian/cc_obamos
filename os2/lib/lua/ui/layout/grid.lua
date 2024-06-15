require("/os2/lib/lua/std")
local Container = import("ui/layout/container")
local Widget = import("ui/widgets/widget")
local Vec2 = import("math/vec2")
local Matrix = import("math/matrix")

local GridContainer = class("GridContainer", Container)
GridContainer.Style = class("GridContainer.Style")

function GridContainer.Style:new()
  local o = {
    _paddingLeft = 0,
    _paddingRight = 0,
    _paddingTop = 0,
    _paddingBottom = 0,
    _centerX = false,
    _centerY = false,
    _overflowY = false,
  }

  setmetatable(o, self)
  return o
end

function GridContainer.Style:paddingLeft(padding)
  self._paddingLeft = padding
  return self
end

function GridContainer.Style:paddingRight(padding)
  self._paddingRight = padding
  return self
end

function GridContainer.Style:paddingX(padding)
  self._paddingLeft = padding
  self._paddingRight = padding
  return self
end

function GridContainer.Style:totalPaddingX()
  return self._paddingLeft + self._paddingRight
end

function GridContainer.Style:paddingTop(padding)
  self._paddingTop = padding
  return self
end

function GridContainer.Style:paddingBottom(padding)
  self._paddingBottom = padding
  return self
end

function GridContainer.Style:paddingY(padding)
  self._paddingTop = padding
  self._paddingBottom = padding
  return self
end

function GridContainer.Style:totalPaddingY()
  return self._paddingTop + self._paddingBottom
end

function GridContainer.Style:padding(padding)
  self:paddingX(padding)
  self:paddingY(padding)
  return self
end

function GridContainer.Style:centerX(c)
  self._centerX = c
  return self
end

function GridContainer.Style:centerY(c)
  self._centerY = c
  return self
end

function GridContainer.Style:center(c)
  self._centerX = c
  self._centerY = c
  return self
end

function GridContainer.Style:overflowY(show)
  self._overflowY = show
  return self
end

function GridContainer:_fromWindow(win, parent, pos, width, height, cols, rows, bgColor)
  local o = self.super:_fromWindow(win, parent, pos, width, height, bgColor)

  o.cols = cols
  o.rows = rows
  o.cellWidth = 0
  o.cellHeight = 0

  if cols ~= nil and rows ~= nil then
    o.grid = Matrix:new(cols, rows)
  end

  setmetatable(o, self)
  return o
end

function GridContainer:_updateCellSize(widget)
  if widget.width > self.cellWidth then
    self.cellWidth = widget.width
  end
  if widget.height > self.cellHeight then
    self.cellHeight = widget.height
  end
end

function GridContainer:addWidget(widget, col, row)
  self:_updateCellSize(widget)

  if self.grid then
    self.grid:set(col, row, widget)
  end

  self.children[#self.children + 1] = widget
end

function GridContainer:pushWidget(widget, i)
  self:_updateCellSize(widget)

  -- add widget
  if self.grid then
    self.grid:setRaw(i, widget)
  end

  self.children[#self.children + 1] = widget
end

function GridContainer:addWidgets(widgets)
  for _, widget in pairs(widgets) do
    self:addWidget(widget)
  end
end

function GridContainer:clearWidgets()
  self.children = {}

  if self.cols ~= nil and self.rows ~= nil then
    self.grid = Matrix:new(self.cols, self.rows)
  else
    self.grid = nil
  end
end

function GridContainer:_buildGrid(style)
  local cols = self.cols
  if not cols then
    cols = math.floor(self.width / (self.cellWidth + style:totalPaddingX()))
  end

  local rows = nil
  if style._overflowY == true then
    rows = math.ceil(#self:getWidgets() / cols)
  else
    rows = math.floor(self.height / (self.cellHeight + style:totalPaddingY()))
  end

  local grid = Matrix:new(cols, rows)
  for i, widget in pairs(self.children) do
    if i > #grid then
      break
    end

    grid:setRaw(i, widget)
  end

  return cols, rows, grid
end

function GridContainer:buildLayout(style)
  if not isinstanceof(style, GridContainer.Style) then
    error("Invalid style object", 2)
  end

  local cols = self.cols
  local rows = self.rows
  local grid = self.grid
  if not self.grid then
    cols, rows, grid = self:_buildGrid(style)
  end

  -- calc start pos
  local startX = style._paddingLeft
  if style._centerX then
    local visibleCols = cols
    if #self:getWidgets() < cols then
      visibleCols = #self:getWidgets()
    end

    startX = startX + math.ceil((self.width - visibleCols * (self.cellWidth + style:totalPaddingX())) / 2)
  end

  local startY = style._paddingTop
  if style._centerY then
    local visibleRows = math.ceil(#self:getWidgets() / cols)
    startY = startY + math.ceil((self.height - visibleRows * (self.cellHeight + style:totalPaddingY())) / 2)
  end

  local pos = Vec2:new(startX, startY)

  -- build layout
  for j = 1, grid.m do
    for i = 1, grid.n do
      local widget = grid:get(i, j)

      if widget ~= nil then
        widget:setPos(pos)
      end

      -- use new vec2 object in order to not override position of the widget
      pos = Vec2:new(pos.x + style:totalPaddingX() + self.cellWidth, pos.y)
    end

    pos.x = startX
    pos.y = pos.y + style:totalPaddingY() + self.cellHeight
  end

  -- hide widgets that didn't fit into the grid
  local widgets = self:getWidgets()
  if #widgets > #grid then
    for i = #grid + 1, #widgets do
      widgets[i]:setVisibility(Widget.Visibility.NONE)
    end
  end

  self.bottomY = pos.y - style:totalPaddingY() + startY
end

function GridContainer:_allowScroll(dir, scrollY, viewHeight)
  return self.super._allowScroll(self, dir, scrollY, viewHeight) and (scrollY + dir <= self.bottomY - viewHeight)
end

return GridContainer
