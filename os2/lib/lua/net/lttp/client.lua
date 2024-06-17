require("/os2/lib/lua/std")
local Request = import("net/lttp/request")
local Response = import("net/lttp/response")
local Socket = import("net/socket")

local Client = class("Client")

function Client:new(protocol, serverPort, serverAddr, timeout, tries)
  local o = {
    socket = Socket:client(),
    protocol = protocol,
    serverPort = serverPort,
    serverAddr = serverAddr,
    timeout = timeout or 3,
    tries = tries or 5
  }
  o.timeout = o.timeout / o.tries

  setmetatable(o, self)
  return o
end

function Client:get(endpoint, payload, payload_checker)
  payload_checker = payload_checker or function(_)
    return true
  end

  self.socket:send(self.serverAddr, self.serverPort, Request.get(endpoint, payload), self.protocol)

  -- catch server response
  local tries = 0
  local sender, packet, srcPort = nil, nil, nil
  while tries < self.tries and (sender ~= self.serverAddr or srcPort ~= self.serverPort or packet == nil or packet.endpoint ~= endpoint) do
    sender, srcPort, packet, _ = self.socket:receive(self.protocol, self.timeout)
    tries = tries + 1
  end

  local response = Response.parse(packet)
  if response == nil or not payload_checker(response.payload) then
    return Response.empty()
  end

  return response
end

function Client:close()
  self.socket:close()
end

return Client
