Struct = require("/os2/lib/lua/parser/struct")

PROTOCOL = "reactor_stats"

struct = Struct.new({
  energyProducedLastTick = "number",
  energySystem = "string",
})
