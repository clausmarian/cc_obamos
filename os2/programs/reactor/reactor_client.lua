require("/os2/lib/lua/std")
local Queue = import("collections/queue")
import("collections/generic")
local Client = import("net/lttp/client")
require("/os2/programs/reactor/reactor_common")
local EnergyUnit = import("energy/energyunit")
local ArgParser = import("util/argparser/argparser")
local Parser = import("util/argparser/parser")

local Vec2 = import("math/vec2")
local App = import("ui/app")
local Container = import("ui/layout/container")
local GridContainer = import("ui/layout/grid")
local TextView = import("ui/widgets/textview")
local ProgressBar = import("ui/widgets/progressbar")
local Widget = import("ui/widgets/widget")
local Event = import("ui/event/event")
local EventListener = import("ui/event/eventlistener")
local RadioGroup = import("ui/widgets/radiogroup")
local Graph = import("ui/widgets/graph")

local argparser = ArgParser:new("Display reactor info.")
argparser:addArgument("server_id", "int", nil, "id of the reactor server to fetch info from")
argparser:addArgument("name", "string", "", "name that is displayed in the ui")
argparser:addArgument("server_port", "int", SERVER_PORT, "port of the reactor server to fetch info from")
argparser:addArgument("transmissions_per_second", Parser.NUMBER:from(1), 10, "inverse sleep timer for client").transformer = function(
    value)
  return 1 / value
end
argparser:addArgument("max_queue_length", Parser.INT:from(2), 30, "max amounts of values to display in graph")
local args = argparser:parse_args()

stats_queue = Queue:new(args.max_queue_length)
stats = {
  sum_all = 0,
  sum_mq = 0
}
recv_value_count = 0
recvEnergyUnit = EnergyUnit.FE
energyUnit = EnergyUnit.FE
reactorMod = nil
reactorPeripheral = nil

local app = App:new()
local frame = Container:frame()
local listener = EventListener:new()

app:addService(function()
  local client = Client:new(PROTOCOL, args.server_port, args.server_id)

  local init = client:get(INIT_ENDPOINT, nil, function(t)
    return initStruct:check(t)
  end)

  if not init:isOk() then
    printError("Invalid init data!")
    return
  end
  reactorMod = init.payload.mod
  reactorPeripheral = init.payload.peripheralName

  if #args.name == 0 then
    graphTitleTv:setText(reactorPeripheral .. " (" .. reactorMod .. ")")
  end

  while true do
    local response = client:get(ENERGY_STATS_ENDPOINT, nil, function(t)
      return energyStatsStruct:check(t)
    end)

    if response:isOk() then
      local payload = response.payload

      listener:callEvent("value", math.floor(payload.energyProducedLastTick))

      if recvEnergyUnit == nil then
        local unit = EnergyUnit:fromKey(payload.energyUnit)
        if unit ~= nil then
          recvEnergyUnit = unit
        end
      end
    end

    sleep(args.transmissions_per_second)
  end
end)

-- loading screen
local loadingScreen = GridContainer:new(frame, Vec2:ones(), frame.width, frame.height, 1, 3, colors.white)
local progressBar = ProgressBar:new(loadingScreen, Vec2:ones(), 0, args.max_queue_length, loadingScreen.width / 2, 1, colors.black, colors.blue)
local titleTv = TextView:new(loadingScreen, Vec2:ones(), "RADIANT SMILE", colors.black, colors.lightBlue)
titleTv.centerText = true
titleTv:setWidth(progressBar.width)
local recvTv = TextView:new(loadingScreen, Vec2:ones(), "", colors.black)
recvTv.centerText = true
recvTv:setWidth(progressBar.width)

loadingScreen:addWidget(titleTv, 1, 1)
loadingScreen:addWidget(progressBar, 1, 2)
loadingScreen:addWidget(recvTv, 1, 3)
loadingScreen:buildLayout(GridContainer.Style:new():centerX(true):centerY(true))

-- graph
local rightColWidth = 12 + #tostring(args.max_queue_length)

local graphContainer = Container:new(frame, Vec2:ones(), frame.width, frame.height, colors.blue)
local graph = Graph:new(graphContainer, Vec2:new(2, 2), graphContainer.width - 3 - rightColWidth, graphContainer.height - 2, stats_queue)
graph:setUnit(energyUnit)
graphTitleTv = TextView:new(graphContainer, Vec2:new(graph.topLeft.x + 1, 1), args.name, colors.black, colors.blue)
graphTitleTv.centerText = true
graphTitleTv:setWidth(graph.width)

listener:addEventHandler("value", function(value)
  value = recvEnergyUnit:convertTo(energyUnit, value)

  local oldestVal = stats_queue:push(value)
  if oldestVal == nil then
    oldestVal = 0
  end

  stats.sum_all = stats.sum_all + value
  stats.sum_mq = stats.sum_mq + value - oldestVal
  recv_value_count = recv_value_count + 1

  local ec = " " .. tostring(energyUnit)
  statsTv:setText("Avg (all): \n" .. ftostring(stats.sum_all / recv_value_count) .. ec
    .. "\nAvg (last " ..
    tostring(args.max_queue_length) .. "): \n" .. ftostring(stats.sum_mq / args.max_queue_length) .. ec)

  if stats_queue.length < args.max_queue_length then
    progressBar:setValue(stats_queue.length)
    recvTv:setText("Received " .. tostring(stats_queue.length) .. " of " .. tostring(args.max_queue_length))
  elseif graphContainer:getVisibility() ~= Widget.Visibility.VISIBLE then
    loadingScreen:setVisibility(Widget.Visibility.NONE)
    graphContainer:setVisibility(Widget.Visibility.VISIBLE)
  end
end)

-- control
local radioGroup = RadioGroup:new(graphContainer, Vec2:new(graph.bottomRight.x + 2, 2), 5,
  { EnergyUnit.FE, EnergyUnit.J, EnergyUnit.EU }, EnergyUnit.FE, graphContainer.bgColor)
radioGroup:addEventHandler(Event.SELECT, function()
  local prevEnergyUnit = energyUnit
  energyUnit = radioGroup:getSelectedValue()

  local function conv(value)
    return prevEnergyUnit:convertTo(energyUnit, value)
  end

  stats_queue:map(conv)
  for k, v in pairs(stats) do
    stats[k] = conv(v)
  end
  graph.min = conv(graph.min)
  graph.max = conv(graph.max)

  graph:setUnit(energyUnit)
end)
statsTv = TextView:new(graphContainer, Vec2:new(graph.bottomRight.x + 2, radioGroup.bottomRight.y + 2), "", colors.black,
  graphContainer.bgColor, true)
statsTv:setWidth(rightColWidth)

graphContainer:addWidgets({ graph, graphTitleTv, radioGroup, statsTv })
graphContainer:setVisibility(Widget.Visibility.NONE)

frame:addWidgets({ loadingScreen, graphContainer })
app:addWidget(frame, 1)

app:run()

