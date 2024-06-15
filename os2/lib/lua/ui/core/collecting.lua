require("/os2/lib/lua/std")
local SortedList = import("collections/sortedlist")

local widgetComparator = function(a, b)
  if a.z_index == b.z_index then
    if a.ref == b.ref then
      return 0
    else
      return 1
    end
  elseif a.z_index < b.z_index then
    return -1
  else
    return 1
  end
end

local function collectPixels(from, to)
  local res = {}

  for x = from.x, to.x do
    for y = from.y, to.y do
      res[#res + 1] = Vec2:new(x, y)
    end
  end

  return res
end

local function collectPixelsSkip(from, to, skipFrom, skipTo)
  local res = {}

  for x = from.x, to.x do
    for y = from.y, to.y do
      if x < skipFrom.x or x > skipTo.x or y < skipFrom.y or y > skipTo.y then
        res[#res + 1] = Vec2:new(x, y)
      end
    end
  end

  return res
end

function addWidgetPixels(posToWidget, w, topLeft, bottomRight, skipTopLeft, skipBottomRight)
  if not topLeft or not bottomRight then
    topLeft = w.ref.topLeft
    bottomRight = w.ref.bottomRight
  end

  local pixels = nil
  if skipTopLeft and skipBottomRight then
    pixels = collectPixelsSkip(topLeft, bottomRight, skipTopLeft, skipBottomRight)
  else
    pixels = collectPixels(topLeft, bottomRight)
  end

  for _, pixel in ipairs(pixels) do
    local posKey = tostring(pixel)

    if not posToWidget[posKey] then
      posToWidget[posKey] = SortedList:new(true, nil, widgetComparator)
    end

    posToWidget[posKey]:insert(w)
  end
end

function moveWidgetPixels(posToWidget, w, fromTopLeft, fromBottomRight, toTopLeft, toBottomRight)
  if not fromTopLeft or not fromBottomRight then
    fromTopLeft = w.ref.topLeft
    fromBottomRight = w.ref.bottomRight
  end

  -- remove old pixel coords
  for _, pixel in ipairs(collectPixelsSkip(fromTopLeft, fromBottomRight, toTopLeft, toBottomRight)) do
    local posKey = tostring(pixel)

    local zlist = posToWidget[posKey]
    if zlist then
      zlist:remove(w)
    end
  end

  -- add new pixel coords
  addWidgetPixels(posToWidget, w, toTopLeft, toBottomRight, fromTopLeft, fromBottomRight)
end
