Server = require("/os2/lib/lua/net/lttp/server")
require("/os2/programs/reactornew/reactor_common")

CLIENT_ID = tonumber(arg[1])
if CLIENT_ID == nil then
  print("Invalid client id!")
  return
end

local reactor = peripheral.find("BigReactors-Reactor")
if reactor == nil then
  print("No reactor found!")
  return
end

print("Listening.. ")
local server = Server.new(PROTOCOL, { CLIENT_ID })
server.on_request = function (client, payload)
 return reactor.getEnergyStats()
end
server:serve_forever()
