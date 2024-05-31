local function downloadFile(path)
  local res = http.get(path)
  if res == nil then
    return nil
  end

  return res.readAll()
end

local function parseVersionsFile(data)
  local versions, err = textutils.unserialiseJSON(data)
  if versions == nil then
    print("Invalid versions file: " .. tostring(err))
    return nil
  end

  return versions
end

-- load online versions file from git repo
local function getOnlineVersions()
  local res = downloadFile("https://raw.githubusercontent.com/clausmarian/cc_obamos/main/versions.json")
  if res == nil then
    return nil
  end

  return parseVersionsFile(res)
end

-- load local versions file
local function getLocalVersion()
  if not fs.exists("/versions.json") then
    return nil
  end

  local linesIter = io.lines("/versions.json")
  if linesIter == nil then
    return nil
  end

  local lines = ""
  for line in linesIter do
    lines = lines .. line .. "\n"
  end

  return parseVersionsFile(lines)
end

local function installVersion(versions)
  -- load files into memory
  local contents = {}
  for _, file in ipairs(versions.files) do
    print("Downloading " .. file.path .. "..")

    local content = downloadFile(file.url)
    if content == nil then
      print("Installation failed, error requesting file: " .. file.path)
      return
    else
      contents[file.path] = content
    end
  end

  -- write files
  for path, content in pairs(contents) do
    print("Writing " .. path .. "..")

    local file, err = io.output(path):write(content)
    if file == nil then
      print("Installation failed, error writing file: " .. path)
      print(err)
      return
    end

    file:close()
  end

  print("Installation finished, rebooting.")
  sleep(2)
  os.reboot()
end

local function install()
  local localVersion = getLocalVersion()
  local onlineVersions = getOnlineVersions()
  if onlineVersions == nil then
    print("Error accessing online versions!")
    return
  end

  if localVersion == nil then
    write("No local version found, do you want to install the latest version (" .. onlineVersions.version .. ") ? (y/N) ")
    if read() == "y" then
      installVersion(onlineVersions)
    else
      print("Installation cancelled")
    end
  elseif localVersion.version ~= onlineVersions.version then
    write("Old local version (" ..
      localVersion.version ..
      ") found, do you want to install the latest version (" .. onlineVersions.version .. ") ? (y/N) ")
    if read() == "y" then
      installVersion(onlineVersions)
    else
      print("Update cancelled")
    end
  else
    print("No updates found")
  end
end

install()
