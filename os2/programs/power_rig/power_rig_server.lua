require("/os2/lib/lua/std")
local Server = import("net/lttp/server")
local EndpointHandler = import("net/lttp/endpointhandler")
require("/os2/programs/power_rig/power_rig_common")
local ArgParser = import("util/argparser/argparser")
local Struct = import("parser/struct")

local argparser = ArgParser:new("Display power rig info.")
argparser:addListArgument("client_ids", "int", nil,
  "id(s) of the power rig client(s) that are allowed to fetch data from this server")
argparser:addArgument("port", "int", SERVER_PORT, "port")
local args = argparser:parse_args()

local accumulatorPeripheral = Struct:new({ peripheral_name = "string" })

local suc, accumulatorPeripherals = accumulatorPeripheral:fromFile("/os2/programs/power_rig/accumulators.json", true)
if not suc then
  printError("Couldn't read accumulator definitions from accumulators.json!")
  return
end

local function getAccumulatorStats(accs)
  local energy = 0
  local energyMax = 0

  for _, acc in ipairs(accs) do
    energy = energy + acc.getEnergyStored()
    energyMax = energyMax + acc.getMaxEnergyStored()
  end

  return {
    energy = energy,
    energyMax = energyMax
  }
end

-- find connected accumulators
local accumulators = {}
for _, accumulatorDef in ipairs(accumulatorPeripherals) do
  local accs = {peripheral.find(accumulatorDef.peripheral_name)}

  if next(accs) ~= nil then
    for _, acc in ipairs(accs) do
      table.insert(accumulators, acc)
    end
  end
end

local has_accumulators = next(accumulators) ~= nil
if not has_accumulators then
  print("No accumulators found!")
end

local current_transformer = peripheral.find("current_transformer")
if current_transformer == nil then
  printError("No current transformer found!")
  return
end

-- start server
local routes = EndpointHandler:new()
routes:get(ENERGY_STATS_ENDPOINT, function(client, payload)
  return {
    storage = getAccumulatorStats(accumulators),
    avg_transferred = current_transformer.getAveragePower()
  }
end)

routes:get(INIT_ENDPOINT, function(client, payload)
  return {
    has_accumulators = has_accumulators,
    accumulators_energy_max = getAccumulatorStats(accumulators).energyMax
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
