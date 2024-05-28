local function readNumber(text)
  write(text)
  return tonumber(read())
end

local function readVector3()
  local x = readNumber("x: ")
  if x == nil then
    return nil
  end

  local y = readNumber("y: ")
  if y == nil then
    return nil
  end

  local z = readNumber("z: ")
  if z == nil then
    return nil
  end

  return vector.new(x, y, z)
end

term.setCursorPos(1, 1)

-- gps
print("\nIf you want this machine to act as GPS server, enter its position: ")
local position = readVector3()
if position == nil then
  print("This machine will not act as a GPS server.")
else
  settings.set("os2.position", position)
  settings.set("os2.gps_server", true)
  print("This machine will act as GPS server.")
end

settings.set("motd.enable", false)
settings.set("os2.setup", true)
settings.save()

print("\nSetup complete, press any key to reboot..")
read()
os.reboot()
