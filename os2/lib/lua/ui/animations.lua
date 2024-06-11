Vec2 = require("/os2/lib/lua/math/vec2")
Queue = require("/os2/lib/lua/collections/queue")
Set = require("/os2/lib/lua/collections/set")
Iter = require("/os2/lib/lua/util/iter")

local expect = require("cc.expect").expect

function circle(center, radius)
  local res = {}

  local function calcCirclePoint(theta)
    return Vec2:new(center.x + math.cos(theta) * radius, center.y + math.sin(theta) * radius)
  end

  for angle = 0, 360 do
    res[#res + 1] = calcCirclePoint(math.rad(angle))
  end

  return res
end

function loading_circle(center, radius, headColor, tailColor)
  expect(1, center, "table")
  expect(2, radius, "number")
  expect(3, headColor, "number")
  expect(4, tailColor, "number")

  -- round circle coordinates to integers since #drawPixel can only draw on integer coordinates
  local dupl = Set.new()
  local circ = Queue:new()

  for pos in Iter.fromList(circle(center, radius)):map(function(pos) return pos:apply(math.ceil) end).iter do
    local posStr = tostring(pos)

    if not dupl:contains(posStr) then
      dupl:insert(posStr)
      circ:push(pos)
    end
  end

  -- draw
  local function draw()
    for i, pos in circ:enumerate() do
      local color = headColor
      if i < #circ / 2 then
        color = tailColor
      end

      paintutils.drawPixel(pos.x, pos.y, color)
    end
  end

  return function()
    circ:push(circ:pop())
    draw()
  end
end
