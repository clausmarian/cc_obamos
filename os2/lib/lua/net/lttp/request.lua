Set = require("/os2/lib/lua/collections/set")

Request = {}

METHOD_GET = "get"
VALID_METHODS = Set.new({ METHOD_GET })

function Request.new(method, payload)
  return {
    payload = payload,
    method = method,
  }
end

function Request.get(payload)
  return Request.new(METHOD_GET, payload)
end

function Request.parse(t)
  if type(t) ~= "table" or not VALID_METHODS:contains(t.method) then
    return nil
  end

  return Request.new(t.method, t.payload)
end

return Request
