Set = require("/os2/lib/lua/collections/set")

Response = {}

STATUS_OK = 200
STATUS_BAD_REQUEST = 400
STATUS_NO_ACCESS = 401
STATUS_TO_DESCRIPTION = {
  [STATUS_OK] = "ok",
  [STATUS_BAD_REQUEST] = "bad request",
  [STATUS_NO_ACCESS] = "access denied"
}
VALID_STATUS = Set.new({ STATUS_OK, STATUS_BAD_REQUEST, STATUS_NO_ACCESS })

function Response.new(status, payload)
  local response = {
    payload = payload,
    status = status
  }

  function response:isOk()
    return self.status == STATUS_OK
  end

  function response:getStatusDescription()
    return STATUS_TO_DESCRIPTION[self.status]
  end

  return response
end

function Response.ok(payload)
  return Response.new(STATUS_OK, payload)
end

function Response.errorNoAccess()
  return Response.new(STATUS_NO_ACCESS, nil)
end

function Response.badRequest()
  return Response.new(STATUS_NO_ACCESS, nil)
end

function Response.empty()
  return Response.new(-1, nil)
end

function Response.parse(t)
  if type(t) ~= "table" or not VALID_STATUS:contains(t.status) or type(t.endpoint) ~= "string" then
    return nil
  end

  return Response.new(t.status, t.payload)
end

return Response
