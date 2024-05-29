local Set = require("/os2/lib/lua/collections/set")
local Request = require("/os2/lib/lua/net/lttp/request")
local Response = require("/os2/lib/lua/net/lttp/response")
local Socket = require("/os2/lib/lua/net/socket")

Server = {}

function Server:new(protocol, port, allowed_clients, logging)
  local o = {
    protocol = protocol,
    port = port,
    allowed_clients = allowed_clients,
    logging = logging or true
  }

  if allowed_clients ~= nil then
    o.allowed_clients = Set.new(allowed_clients)
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

function Server:host(hostname)
  rednet.host(self.protocol, hostname)
end

function Server:client_is_allowed(client)
  if self.allowed_clients == nil then
    return true
  else
    return self.allowed_clients:contains(client)
  end
end

function Server:serve_forever()
  if self.on_request == nil then
    error("Method 'on_request(client, payload)' must be attached to Server object!", 2)
  end

  local socket = Socket:server(self.port)
  self.running = true
  while self.running do
    local sender, srcPort, packet, _ = socket:receive(self.protocol)
    self:handle_request(sender, srcPort, packet, socket)
  end
end

function Server:serve_forever_and_host(hostname)
  parallel.waitForAll(function()
    self:host(hostname)
  end, function()
    self:serve_forever()
  end)
end

function Server:handle_request(client, clientPort, request, socket)
  local function respond(packet)
    socket:send(client, clientPort, packet, self.protocol)

    if self.logging then
      print("Responded to request from '" .. tostring(client) .. "' with " .. tostring(packet.status))
    end
  end

  if not self:client_is_allowed(client) then
    respond(Response.errorNoAccess())
    return
  end

  request = Request.parse(request)
  if request == nil then
    respond(Response.badRequest())
  else
    respond(Response.ok(self.on_request(client, request.payload)))
  end
end

function Server:close()
  self.running = false
  self.socket:close()
end

return Server
