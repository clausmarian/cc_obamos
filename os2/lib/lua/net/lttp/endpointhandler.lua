require("/os2/lib/lua/std")

local EndpointHandler = class("EndpointHandler")

function EndpointHandler:new()
  local o = {
    endpointToHandler = {}
  }

  setmetatable(o, self)
  return o
end

function EndpointHandler:get(endpoint, handler)
  self.endpointToHandler[endpoint] = { "get", handler }
end

function EndpointHandler:toRequestHandler()
  return function(client, endpoint, method, payload)
    local handler = self.endpointToHandler[endpoint]
    if handler and handler[1] == method then
      return handler[2](client, payload)
    end
  end
end

return EndpointHandler
