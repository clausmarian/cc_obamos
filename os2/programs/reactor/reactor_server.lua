require("/os2/lib/lua/std")
local Server = import("net/lttp/server")
local EndpointHandler = import("net/lttp/endpointhandler")
require("/os2/programs/reactor/reactor_common")
local ArgParser = import("util/argparser/argparser")
local Struct = import("parser/struct")

local argparser = ArgParser:new("Display reactor info.")
argparser:addListArgument("client_ids", "int", nil,
  "id(s) of the reactor client(s) that are allowed to fetch data from this server")
argparser:addArgument("port", "int", SERVER_PORT, "port")
local args = argparser:parse_args()

local reactorPeripheral = Struct:new({
  mod = "string",
  peripheral_name = "string",
  energy_stats = Struct:new({
    energy_system = "string",
    energy_produced_last_tick_func = "string"
  }, true)
})

local suc, reactors = reactorPeripheral:fromFile("/os2/programs/reactor/reactors.json", true)
if not suc then
  printError("Couldn't read reactor definitions from reactors.json!")
  return
end

local function getEnergyStats(r)
  return r.getEnergyStats()
end

-- find connected reactor and setup energy stats function for reactor type
local reactor = nil
for _, reactorDef in ipairs(reactors) do
  reactor = peripheral.find(reactorDef.peripheral_name)

  if reactor then
    if reactorDef.energy_stats then
      getEnergyStats = function(r)
        local energyProducedLastTick = r[reactorDef.energy_stats.energy_produced_last_tick_func]

        -- function is not always available on mekanism ports
        if not energyProducedLastTick then
          return nil
        end

        return {
          energySystem = reactorDef.energy_stats.energy_system,
          energyProducedLastTick = energyProducedLastTick()
        }
      end
    end

    reactorDef.peripheral = reactor
    reactor = reactorDef
    break
  end
end

if reactor == nil then
  printError("No reactor found!")
  return
end
print("Reactor of type '" .. reactor.peripheral_name .. "' (" .. reactor.mod .. ") found!")

-- start server
local routes = EndpointHandler:new()
routes:get(ENERGY_STATS_ENDPOINT, function(client, payload)
  return getEnergyStats(reactor.peripheral)
end)

routes:get(INIT_ENDPOINT, function(client, payload)
  return {
    mod = reactor.mod,
    peripheralName = reactor.peripheral_name
  }
end)

print("Listening.. ")
local server = Server:new(PROTOCOL, args.port, args.client_ids)
server.on_request = routes:toRequestHandler()

handleTerminate(function()
  server:serve_forever()
end, function()
  server:close()
  print("Closed server")
end)
