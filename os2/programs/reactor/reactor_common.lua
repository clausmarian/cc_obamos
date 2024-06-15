require("/os2/lib/lua/std")
local Struct = import("parser/struct")

PROTOCOL = "reactor_stats"
SERVER_PORT = 100

struct = Struct:new({
  energyProducedLastTick = "number",
  energySystem = "string",
})
