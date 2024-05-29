local Struct = require("/os2/lib/lua/parser/struct")
local netutils = require("/os2/lib/lua/net/netutils")

Socket = {}

local messageTemplate = Struct.new({
  srcPort = "number",
  dstPort = "number"
})

local function newSocket(self, port)
  local o = {
    port = port
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Socket:server(port)
  netutils.requestPort(port)
  return newSocket(self, port)
end

function Socket:client()
  return newSocket(self, netutils.requestRandomPort())
end

function Socket:send(recipient, port, message, protocol)
  return rednet.send(recipient, {
    srcPort = self.port,
    dstPort = port,
    payload = message,
  }, protocol)
end

function Socket:receive(protocol_filter, timeout)
  while true do
    local sender, message, protocol = rednet.receive(protocol_filter, timeout)

    -- timeout
    if sender == nil and message == nil and protocol == nil then
      return nil
    end

    if messageTemplate:check(message) and message.dstPort == self.port then
      return sender, message.srcPort, message.payload, protocol
    end
  end
end

function Socket:close()
  netutils.freePort(self.port)
end

return Socket
