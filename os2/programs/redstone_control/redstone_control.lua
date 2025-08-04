require("/os2/lib/lua/std")
local ArgParser = import("util/argparser/argparser")
local Struct = import("parser/struct")

local Vec2 = import("math/vec2")
local App = import("ui/app")
local GridContainer = import("ui/layout/grid")
local TextView = import("ui/widgets/textview")
local Button = import("ui/widgets/button")
local Event = import("ui/event/event")
local MouseButton = import("ui/event/mousebutton")

local function isValidSide(side)
	for _, s in ipairs(rs.getSides()) do
		if side == s then
			return true
		end
	end

	return false
end

local rsSide = Struct:new({
	name = "string",
	enabled = "boolean",
	relay = "string", -- empty string = no relay, uses computers sides
	side = "string",
})

local argparser = ArgParser:new("A control panel for enabling/disabling redstone signals.")
argparser:addArgument("config_path", "string", nil, "Path of the redstone connections config file")
local args = argparser:parse_args()

local suc, rsSides = rsSide:fromFile(args.config_path, true)
if not suc then
	printError("Couldn't parse config file '" .. tostring(args.config_path) .. "'!")
	return
end

local maxNameLen = 1
for _, rss in ipairs(rsSides) do
  -- check side and relay of config
	if not isValidSide(rss.side) then
		printError("Device '" .. rss.name .. "' is using invalid side '" .. tostring(rss.side) .. "'!")
		return
	end

	if rss.relay ~= "" and not peripheral.hasType(rss.relay, "redstone_relay") then
		printError("The relay '" .. tostring(rss.relay) .. "' of device '" .. rss.name .. "' couldn't be found!")
		return
	end

  -- add switch state function
  rss.getDevice = function(self)
    local p = rs

		if self.relay ~= "" then
			p = peripheral.wrap(self.relay)
		end

    return p
  end

	rss.switch = function(self)
		self.enabled = not self.enabled
		self:getDevice().setOutput(self.side, self.enabled)
	end

  rss:getDevice().setOutput(rss.side, rss.enabled)

  local nameLen = string.len(rss.name)
  if nameLen > maxNameLen then
    maxNameLen = nameLen
  end
end

local app = App:new()
local parent = GridContainer:frame(2, nil, colors.white)
parent:makeScrollable(app, parent.height)

local function addRsWidgets(rsDevices)
	for i, rss in ipairs(rsDevices) do
    local lbl = TextView:new(parent, Vec2:ones(), rss.name, colors.black)
    lbl:setWidth(maxNameLen + 1)
		parent:addWidget(lbl, 1, i)

		local switch = Button:new(
			parent,
			Vec2:ones(),
			rss.enabled and "on" or "off",
			5,
			1,
			rss.enabled and colors.green or colors.red,
			colors.black
		)
		switch:addEventHandler(Event.CLICK, function(self, btn, pos)
			if btn == MouseButton.LEFT then
				if rss.enabled then
					switch:setText("off")
					switch.bgColor = colors.red
				else
					switch:setText("on")
					switch.bgColor = colors.green
				end

        rss:switch()
			end
		end)
		parent:addWidget(switch, 2, i)
	end

	parent:buildLayout(GridContainer.Style:new():paddingLeft(1):paddingTop(1):overflowY(true))
	app:addWidget(parent, 1)
	parent.scrollY = 1
end

addRsWidgets(rsSides)
app:run()
