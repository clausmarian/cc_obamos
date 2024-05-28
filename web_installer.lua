function download_file(path)
  local res = http.get(path)
  if res == nil then
    return nil
  end

  return res.readAll()
end

local res = download_file("https://raw.githubusercontent.com/clausmarian/cc_obamos/main/versions.json")
if res == nil then
  print("Error requesting versions file!")
  return
end

print("Reading versions file")
local versions, err = textutils.unserialiseJSON(res)
if versions == nil then
  print("Invalid versions file: " .. tostring(err))
  return
end

-- load files into memory
local contents = {}
for _, file in ipairs(versions.files) do
  print("Downloading " .. file.path .. "..")

  local content = download_file(file.url)
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
