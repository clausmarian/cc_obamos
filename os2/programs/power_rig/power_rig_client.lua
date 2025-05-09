require("/os2/lib/lua/std")
local Queue = import("collections/queue")
import("collections/generic")
local Client = import("net/lttp/client")
require("/os2/programs/power_rig/power_rig_common")
local AccumulatorBar = require("/os2/programs/power_rig/widgets/accumulatorbar")
local EnergyUnit = import("energy/energyunit")
local ArgParser = import("util/argparser/argparser")
local Parser = import("util/argparser/parser")

local Vec2 = import("math/vec2")
local App = import("ui/app")
local Container = import("ui/layout/container")
local GridContainer = import("ui/layout/grid")
local TextView = import("ui/widgets/textview")
local Widget = import("ui/widgets/widget")
local EventListener = import("ui/event/eventlistener")
local Graph = import("ui/widgets/graph")

local argparser = ArgParser:new("Display power rig info.")
argparser:addArgument("server_id", "int", nil, "id of the power rig server to fetch info from")
argparser:addArgument("server_port", "int", SERVER_PORT, "port of the power rig server to fetch info from")
argparser:addArgument("transmissions_per_second", Parser.NUMBER:from(1), 10, "inverse sleep timer for client").transformer = function(
	value
)
	return 1 / value
end
argparser:addArgument("max_queue_length", Parser.INT:from(2), 30, "max amounts of values to display in graph")
local args = argparser:parse_args()

avg_transferred_queue = Queue:new(args.max_queue_length)
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
	local hasAccumulators = init.payload.has_accumulators
  listener:callEvent("init_accumulator", init.payload)

	while true do
		local response = client:get(ENERGY_STATS_ENDPOINT, nil, function(t)
			return energyStatsStruct:check(t)
		end)

		if response:isOk() then
			if hasAccumulators then
        listener:callEvent("storage", response.payload.storage)
			end
      listener:callEvent("avg_transferred", response.payload.avg_transferred)
		end

		sleep(args.transmissions_per_second)
	end
end)

-- loading screen
local loadingScreen = GridContainer:new(frame, Vec2:ones(), frame.width, frame.height, 1, 3, colors.white)
local titleTv = TextView:new(loadingScreen, Vec2:ones(), "POWER", colors.black, colors.lightBlue)
titleTv.centerText = true
titleTv:setWidth(loadingScreen.width / 2)
local recvTv = TextView:new(loadingScreen, Vec2:ones(), "Waiting", colors.black)
recvTv.centerText = true
recvTv:setWidth(titleTv.width)

loadingScreen:addWidget(titleTv, 1, 1)
loadingScreen:addWidget(recvTv, 1, 2)
loadingScreen:buildLayout(GridContainer.Style:new():centerX(true):centerY(true))

-- accumulators
local accContainer = Container:new(frame, Vec2:ones(), 10, frame.height, colors.blue)
accContainer:setTag(false)
local accBar = AccumulatorBar:new(accContainer, Vec2:new(2, 2), 0, 100, 7, accContainer.height - 3)
local accTitleTv = TextView:new(accContainer, Vec2:new(accBar.topLeft.x, 1), "storage", colors.black, colors.blue)
accTitleTv.centerText = true
accTitleTv:setWidth(accBar.width)
local accStatsTv = TextView:new(accContainer, Vec2:new(2, accBar.topLeft.y + accBar.height), "", colors.black, colors.blue)
accStatsTv.centerText = true
accStatsTv:setWidth(accBar.width)

-- graph
local graphContainer = Container:new(frame, Vec2:new(accContainer.width + 1, 1), frame.width - accContainer.width, frame.height, colors.blue)
local graph = Graph:new(
	graphContainer,
	Vec2:new(2, 2),
	graphContainer.width - 2,
	graphContainer.height - 2,
	avg_transferred_queue
)
graph:setUnit(EnergyUnit.FE)
graphTitleTv = TextView:new(graphContainer, Vec2:new(graph.topLeft.x + 1, 1), "avg transferred", colors.black, colors.blue)
graphTitleTv.centerText = true
graphTitleTv:setWidth(graph.width)


listener:addEventHandler("init_accumulator", function(value)
  if value.has_accumulators then
    accBar.max = value.accumulators_energy_max
    accBar.diff = value.accumulators_energy_max
    accContainer:setTag(true)
  else
    graphContainer:setPos(Vec2:ones())
    graphContainer:setWidth(frame.width)
    graph:setWidth(graphContainer.width - 2)
    graphTitleTv:setWidth(graph.width)
  end
end)

listener:addEventHandler("storage", function(value)
  accBar:setValue(value.energy)
  accStatsTv:setText(ftostring(accBar:getRelativeValue() * 100) .. "%")
end)

listener:addEventHandler("avg_transferred", function(value)
	avg_transferred_queue:push(value)

	if loadingScreen:getVisibility() == Widget.Visibility.VISIBLE then
		loadingScreen:setVisibility(Widget.Visibility.NONE)
    if accContainer:getTag() then
      accContainer:setVisibility(Widget.Visibility.VISIBLE)
    end
		graphContainer:setVisibility(Widget.Visibility.VISIBLE)
	end
end)

-- control
accContainer:addWidgets({ accBar, accTitleTv, accStatsTv })
accContainer:setVisibility(Widget.Visibility.NONE)

graphContainer:addWidgets({ graph, graphTitleTv })
graphContainer:setVisibility(Widget.Visibility.NONE)

frame:addWidgets({ loadingScreen, accContainer, graphContainer })
app:addWidget(frame, 1)

app:run()
