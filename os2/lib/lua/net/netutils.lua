Set = require("/os2/lib/lua/collections/set")

local M = {}

if not _G.net then
  _G.net = {
    ports = Set.new()
  }
end

local MIN_PORT = 1
local MAX_PORT = 65535

function M.requestPort(port)
  if _G.net.ports:contains(port) then
    error("The port " .. tostring(port) .. " is already in use!", 2)
  end

  _G.net.ports:insert(port)
end

function M.requestRandomPort()
  local port = math.random(MIN_PORT, MAX_PORT)

  if _G.net.ports:contains(port) then
    return M.requestRandomPort()
  else
    _G.net.ports:insert(port)
    return port
  end
end

function M.freePort(port)
  _G.net.ports:remove(port)
end

return M
