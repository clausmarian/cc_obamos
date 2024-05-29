Server = require("/os2/lib/lua/net/lttp/server")
require("/os2/programs/reactor/reactor_common")

CLIENT_IDS = arg[1]
if CLIENT_IDS == nil then
  print("Invalid client ids!")
  return
else
  CLIENT_IDS = textutils.unserialise(CLIENT_IDS)
  local tp = type(CLIENT_IDS)
  if tp == "number" then
    CLIENT_IDS = { CLIENT_IDS }
  elseif tp ~= "table" then
    print("Unsupported type for client ids!")
    return
  end
end

PORT = tonumber(arg[2])
if PORT == nil then
  PORT = SERVER_PORT
end

local reactor = peripheral.find("BigReactors-Reactor")
if reactor == nil then
  print("No reactor found!")
  return
end

print("Listening.. ")
local server = Server:new(PROTOCOL, PORT, CLIENT_IDS)
server.on_request = function(client, payload)
  return reactor.getEnergyStats()
end
server:serve_forever()
