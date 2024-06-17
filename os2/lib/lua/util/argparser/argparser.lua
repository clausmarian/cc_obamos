require("/os2/lib/lua/std")
import("util/argparser/parsers")

local function getParser(atype)
  return match(atype, {
    number = parseNumber,
    int = parseInt,
    string = parseString,
    bool = parseBool
  }, nil, true)
end

local Argument = class("ArgParser.Argument")
local function id(x)
  return x
end

function Argument:new(name, atype, isList, default, help)
  local parser = nil
  if type(atype) == "table" and type(atype[1]) == "string" and type(atype[2]) == "function" then
    parser = atype[2]
    atype = atype[1]
  else
    parser = getParser(atype)
    if parser == nil then
      error("No parser for type '" .. tostring(atype) .. "'", 2)
    end
  end

  local o = {
    name = name,
    atype = atype,
    parser = parser,
    _isList = isList or false,
    default = default,
    help = help or "",
    transformer = id
  }

  setmetatable(o, self)
  return o
end

function Argument:hasDefault()
  return self.default ~= nil
end

function Argument:isList()
  return self._isList
end

function Argument:getTypeName()
  if self:isList() then
    return "{ " .. self.atype .. ", ... }"
  end

  return self.atype
end

function Argument:_parse(value)
  if value == nil then
    if self:hasDefault() then
      return true, self.default
    else
      return false
    end
  end

  if self:isList() then
    return parseList(value, self.parser)
  else
    return self.parser(value)
  end
end

function Argument:parse(value)
  local suc, v = self:_parse(value)
  if suc then
    return true, self.transformer(v)
  end

  return false, v
end

local ArgParser = class("ArgParser")

function ArgParser:new(help)
  local o = {
    arguments = {},
    _help = help
  }

  setmetatable(o, self)
  return o
end

function ArgParser:_addArgument(argument)
  self.arguments[#self.arguments + 1] = argument
  return argument
end

function ArgParser:addArgument(name, atype, default, help)
  return self:_addArgument(Argument:new(name, atype, false, default, help))
end

function ArgParser:addListArgument(name, atype, default, help)
  return self:_addArgument(Argument:new(name, atype, true, default, help))
end

function ArgParser:usage(sname)
  local res = "usage: " .. sname

  for _, argument in ipairs(self.arguments) do
    if argument:hasDefault() then
      res = res .. " [" .. argument.name .. "]"
    else
      res = res .. " " .. argument.name
    end
  end

  return res
end

function ArgParser:help(sname)
  local res = self:usage(sname) .. "\n\n"

  if self._help then
    res = res .. self._help .. "\n\n"
  end

  res = res .. "arguments:\n"

  for _, argument in ipairs(self.arguments) do
    res = res .. " " .. argument.name .. " - " .. argument.help

    if argument:hasDefault() then
      res = res .. " (default=" .. tostring(argument.default) .. ")"
    end
    res = res .. "\n"
  end

  return res
end

function ArgParser:parse(args)
  local t = {}

  for i, argument in ipairs(self.arguments) do
    local a = args[i]
    local suc, value = argument:parse(a)
    if suc then
      t[argument.name] = value
    else
      local err = value
      if err == nil then
        err = "expected a value of type '" .. argument:getTypeName() .. "', got '"
            .. tostring(a) .. "' (a '" .. type(a) .. "' value)"
      end
      printError("Error parsing '" .. argument.name .. "', " .. err)
      print("\n" .. self:help(args[0]))
      error()
    end
  end

  return t
end

function ArgParser:parse_args()
  return self:parse(arg)
end

return ArgParser
