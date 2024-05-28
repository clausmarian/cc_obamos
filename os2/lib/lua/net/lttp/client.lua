Request = require("/os2/lib/lua/net/lttp/request")
Response = require("/os2/lib/lua/net/lttp/response")

Client = {}

function Client.new(protocol, serverAddr, timeout)
  local client = {
    protocol = protocol,
    serverAddr = serverAddr,
    timeout = timeout or 3
  }

  function client:get(payload, payload_checker)
    payload_checker = payload_checker or function(_)
      return true
    end

    rednet.send(self.serverAddr, Request.get(payload), self.protocol)

    -- catch server response
    local sender, packet = nil, nil
    while sender ~= serverAddr do
      sender, packet, _ = rednet.receive(self.protocol, self.timeout)
    end

    local response = Response.parse(packet)
    if response == nil or not payload_checker(response.payload) then
      return Response.empty()
    end

    return response
  end

  return client
end

return Client
