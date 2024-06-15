local function getDriveInfo(path)
  local totalStorage = fs.getCapacity(path)
  local storage = nil

  if totalStorage ~= nil then
    local freeStorage = fs.getFreeSpace(path)

    storage = {
      free = freeStorage,
      used = totalStorage - freeStorage,
      total = totalStorage
    }
  end

  return {
    storage = storage,
    readOnly = fs.attributes(path).isReadOnly,
    name = fs.getDrive(path),
    mount = path,
    id = os.getComputerID(),
    type = "local"
  }
end

local function getDiskInfo(side)
  local label = disk.getLabel(side)
  if label == nil then
    label = side
  end

  local path = disk.getMountPath(side)
  local info = {}
  if path ~= nil then
    info = getDriveInfo("/" .. path)
  end
  info.name = label
  info.address = side
  info.id = disk.getID(side)
  info.type = "disk"
  return info
end

local function getAudioDiskInfo(side)
  local label = disk.getAudioTitle(side)
  if label == nil then
    label = side
  end

  local info = getDiskInfo(side)
  info.name = label
  info.readOnly = true
  info.type = "disk_audio"
  return info
end

function getDrives()
  local drives = {
    [1] = getDriveInfo("/rom"),
    [2] = getDriveInfo("/")
  }

  for _, name in pairs(peripheral.getNames()) do
    if peripheral.getType(name) == "drive" and disk.isPresent(name) then
      if disk.hasAudio(name) then
        drives[#drives + 1] = getAudioDiskInfo(name)
      else
        drives[#drives + 1] = getDiskInfo(name)
      end
    end
  end

  return drives
end

function prettyBytes(bytes)
  local function pretty(unit, b)
    return tostring(b) .. unit
  end

  local units = { "B", "KB", "MB" }

  local b = bytes
  for _, unit in pairs(units) do
    if b < 1000 then
      return pretty(unit, b)
    end

    b = b / 1000
  end

  return pretty("GB", b)
end
