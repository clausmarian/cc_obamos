-- open all modems
peripheral.find("modem", rednet.open)

-- setup path
shell.setPath(shell.path() .. ":/os2/programs/reactor")
