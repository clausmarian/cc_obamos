print("Enter installer directory:")
local wd = read()

print("Enter destination:")
local dest = read()

print("Copying files..")

fs.copy(wd .. "/os2", dest .. "/os2")
fs.copy(wd .. "/boot.lua", dest .. "/startup/boot.lua")
