Set = require("/os2/lib/lua/collections/set")

Request = {}

METHOD_GET = "get"
VALID_METHODS = Set.new({ METHOD_GET })

function Request.new(endpoint, method, payload)
  return {
    payload = payload,
    method = method,
    endpoint = endpoint
  }
end

function Request.get(endpoint, payload)
  return Request.new(endpoint, METHOD_GET, payload)
end

function Request.parse(t)
  if type(t) ~= "table" or not VALID_METHODS:contains(t.method) or type(t.endpoint) ~= "string" then
    return nil
  end

  return Request.new(t.endpoint, t.method, t.payload)
end

return Request
