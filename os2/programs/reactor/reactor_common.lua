require("/os2/lib/lua/std")
local Struct = import("parser/struct")

PROTOCOL = "reactor_stats"
SERVER_PORT = 100
ENERGY_STATS_ENDPOINT = "energy_stats"
INIT_ENDPOINT = "init"

energyStatsStruct = Struct:new({
  energyProducedLastTick = "number",
  energySystem = "string",
})

initStruct = Struct:new({
  mod = "string",
  peripheralName = "string",
})
