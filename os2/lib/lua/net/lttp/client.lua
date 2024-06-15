require("/os2/lib/lua/std")
local Request = import("net/lttp/request")
local Response = import("net/lttp/response")
local Socket = import("net/socket")

local Client = class("Client")

function Client:new(protocol, serverPort, serverAddr, timeout)
  local o = {
    socket = Socket:client(),
    protocol = protocol,
    serverPort = serverPort,
    serverAddr = serverAddr,
    timeout = timeout or 3
  }

  setmetatable(o, self)
  return o
end

function Client:get(payload, payload_checker)
  payload_checker = payload_checker or function(_)
    return true
  end

  self.socket:send(self.serverAddr, self.serverPort, Request.get(payload), self.protocol)

  -- catch server response
  local sender, packet, srcPort = nil, nil, nil
  while sender ~= self.serverAddr and srcPort ~= self.serverPort do
    sender, srcPort, packet, _ = self.socket:receive(self.protocol, self.timeout)
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
