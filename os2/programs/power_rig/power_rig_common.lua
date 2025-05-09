require("/os2/lib/lua/std")
local Struct = import("parser/struct")

PROTOCOL = "ie_power_rig"
SERVER_PORT = 101
ENERGY_STATS_ENDPOINT = "energy_stats"
INIT_ENDPOINT = "init"

energyStatsStruct = Struct:new({
  storage = Struct:new({
    energy = "number",
    energyMax = "number"
  }),
  avg_transferred = "number"
})

initStruct = Struct:new({
  has_accumulators = "boolean",
  accumulators_energy_max = "number"
})
