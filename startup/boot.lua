Vec2 = require("/os2/lib/lua/math/vec2")
require("/os2/lib/lua/ui/animations")

local function clear()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()

  term.setCursorPos(1, 1)
end

SHOW_SPLASH = true

local function splash()
  clear()

  local width, height = term.getSize()
  term.setCursorPos(width / 2, height / 2 - 1)
  term.write("Os2")

  local drawCircle = loading_circle(Vec2:new(width / 2, height / 2 + 1), 1, colors.blue, colors.lightBlue)
  while SHOW_SPLASH do
    drawCircle()
    sleep(0.1)
  end

  clear()
end

local function boot()
  settings.define("os2.gps_server", {
    description = "Position of the machine",
    default = false,
    type = "boolean"
  })

  settings.define("os2.position", {
    description = "Position of the machine",
    default = nil,
    type = "table"
  })
  settings.load()

  -- open all modems
  peripheral.find("modem", rednet.open)

  -- setup path
  shell.setPath(shell.path() .. ":/os2/programs/reactor")

  if not settings.get("os2.setup", false) then
    SHOW_SPLASH = false
    sleep(0.2)
    shell.run("/os2/sys/setup")
  end

  -- gps
  local position = settings.get("os2.position")
  if settings.get("os2.gps_server") and position then
    SHOW_SPLASH = false
    sleep(0.2)
    shell.run("gps", "host " .. tostring(position.x) .. " " .. tostring(position.y) .. " " .. tostring(position.z))
  end

  SHOW_SPLASH = false
end

parallel.waitForAll(splash, boot)

-- autostart
if fs.exists("/autostart.lua") then
  require("/autostart")
end

require("/web_installer")
