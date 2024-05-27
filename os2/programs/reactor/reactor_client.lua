PROTOCOL = "reactor_stats"

CLIENT_ID = tonumber(arg[1])
if CLIENT_ID == nil then
  print("Invalid client id!")
  return
end

TRANSMISSIONS_PER_SECOND = tonumber(arg[2])
if TRANSMISSIONS_PER_SECOND == nil then
  TRANSMISSIONS_PER_SECOND = 0.1
else
  TRANSMISSIONS_PER_SECOND = 1 / TRANSMISSIONS_PER_SECOND
end

local reactor = peripheral.find("BigReactors-Reactor")
if reactor == nil then
  print("No reactor found!")
  return
end

print("Transmitting reactor stats to machine " .. tostring(CLIENT_ID))
while true do
  rednet.send(CLIENT_ID, reactor.getEnergyStats(), PROTOCOL)
  sleep(TRANSMISSIONS_PER_SECOND)
end
