Set = require("/os2/lib/lua/collections/set")
Request = require("/os2/lib/lua/net/lttp/request")
Response = require("/os2/lib/lua/net/lttp/response")

Server = {}

function Server.new(protocol, allowed_clients, logging)
  local server = {
    protocol = protocol,
    allowed_clients = allowed_clients,
    logging = logging or true
  }

  if allowed_clients ~= nil then
    server.allowed_clients = Set.new(allowed_clients)
  end

  function server:host(hostname)
    rednet.host(self.protocol, hostname)
  end

  function server:client_is_allowed(client)
    if self.allowed_clients == nil then
      return true
    else
      return self.allowed_clients:contains(client)
    end
  end

  function server:serve_forever()
    if server.on_request == nil then
      error("Method 'on_request(client, payload)' must be attached to server object!", 2)
    end

    while true do
      local sender, packet, _ = rednet.receive(PROTOCOL)
      self:handle_request(sender, packet)
    end
  end

  function server:serve_forever_and_host(hostname)
    parallel.waitForAll(function()
      self:host(hostname)
    end, function()
      self:serve_forever()
    end)
  end

  function server:handle_request(client, request)
    local function respond(packet)
      rednet.send(client, packet, self.protocol)

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

  return server
end

return Server
