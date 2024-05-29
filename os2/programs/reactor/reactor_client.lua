Queue = require("/os2/lib/lua/collections/queue")
require("/os2/lib/lua/collections/generic")
Client = require("/os2/lib/lua/net/lttp/client")
require("/os2/programs/reactor/reactor_common")


SERVER_ID = tonumber(arg[1])
if SERVER_ID == nil then
  print("Invalid server id!")
  return
end

PORT = tonumber(arg[2])
if PORT == nil then
  PORT = SERVER_PORT
end

TRANSMISSIONS_PER_SECOND = tonumber(arg[3])
if TRANSMISSIONS_PER_SECOND == nil then
  TRANSMISSIONS_PER_SECOND = 0.1
else
  TRANSMISSIONS_PER_SECOND = 1 / TRANSMISSIONS_PER_SECOND
end

MAX_QUEUE_LENGTH = tonumber(arg[4])
if MAX_QUEUE_LENGTH == nil or MAX_QUEUE_LENGTH < 2 then
  MAX_QUEUE_LENGTH = 30
end

stats_queue = Queue.new(MAX_QUEUE_LENGTH)
min = nil
max = nil
energyUnit = ""

width, height = term.getSize()

function listen()
  local client = Client:new(PROTOCOL, PORT, SERVER_ID)

  while true do
    local response = client:get(nil, function(t)
      return struct:check(t)
    end)

    if response:isOk() then
      local payload = response.payload

      stats_queue:push(math.floor(payload.energyProducedLastTick))

      if energyUnit == "" then
        energyUnit = " " .. payload.energySystem
      end
    end

    sleep(TRANSMISSIONS_PER_SECOND)
  end
end

function draw()
  local inc_x = (width - 1) / (MAX_QUEUE_LENGTH - 1)

  while true do
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.clear()

    if stats_queue.length < MAX_QUEUE_LENGTH then
      -- loading screen
      local x = width / 3
      local y = height / 3
      term.setCursorPos(x, y)
      term.setBackgroundColor(colors.blue)
      term.write("RADIANT SMILE")
      term.setCursorPos(x, y + 3)
      term.setBackgroundColor(colors.white)
      term.write("Received " .. tostring(stats_queue.length) .. " of " .. tostring(MAX_QUEUE_LENGTH))

      x = width / 4
      endX = width * 3 / 4
      y = y + 2
      paintutils.drawLine(x, y, endX, y, colors.black)
      if stats_queue.length > 0 then
        paintutils.drawLine(x, y, x + (stats_queue.length / MAX_QUEUE_LENGTH) * (endX - x), y, colors.blue)
      end
    else
      -- graph
      local lmin = table.min(stats_queue.data)
      if min == nil or lmin < min then
        min = lmin
      end
      local lmax = table.max(stats_queue.data)
      if max == nil or lmax > max then
        max = lmax
      end

      local inc_y = (height - 1) / (max - min)

      -- put first value on y axis
      local iter = stats_queue:iter()
      local prev_value = iter()
      local prev_x = 1
      local prev_y = (max - prev_value) * inc_y + 1

      local x = 1

      for value in iter do
        x = x + inc_x
        local y = (max - value) * inc_y + 1

        paintutils.drawLine(prev_x, prev_y, x, y, colors.red)

        prev_x = x
        prev_y = y
      end

      -- graph labels
      term.setTextColor(colors.black)
      term.setBackgroundColor(colors.green)
      term.setCursorPos(1, 1)
      term.write(tostring(max) .. energyUnit)

      term.setBackgroundColor(colors.red)
      term.setCursorPos(1, height)
      term.write(tostring(min) .. energyUnit)
    end

    sleep(TRANSMISSIONS_PER_SECOND)
  end
end

parallel.waitForAny(listen, draw)
