require("/os2/lib/lua/std")
local Container = import("ui/layout/container")
local RadioButton = import("ui/widgets/radiobutton")
local Event = import("ui/event/event")
local MouseButton = import("ui/event/mousebutton")
local Vec2 = import("math/vec2")


local RadioGroup = class("RadioGroup", Container)

function RadioGroup:new(parent, pos, width, values, selectedValue, bgColor, textColor, btnBgColor,
                                selectedColor)
  local o = self.super:_fromWindow(nil, parent, pos, width, #values * 2 - 1, bgColor)

  o.bgColor = bgColor or colors.gray
  o.textColor = textColor or colors.black
  o.btnBgColor = btnBgColor or colors.white
  o.selectedColor = selectedColor or colors.black
  o.values = values
  o.selectedBtn = nil

  local function onSelectBtn(self, btn, pos)
    if btn == MouseButton.LEFT then
      if self.selected then
        return
      end

      if o.selectedBtn ~= nil then
        o.selectedBtn.selected = false
      end

      self.selected = true
      o.selectedBtn = self

      if o:handlesEvent(Event.SELECT) then
        o:callEvent(Event.SELECT)
      end
    end
  end

  --local btnPos = pos * 1 -- copy object
  local btnPos = Vec2:ones()
  for _, value in ipairs(values) do
    local radioBtn = RadioButton:new(o, btnPos, tostring(value), 1, 1, o.bgColor, o.textColor, o.btnBgColor,
      o.selectedColor)
    radioBtn:setTag(value)
    radioBtn:addEventHandler(Event.CLICK, onSelectBtn)

    if value == selectedValue then
      radioBtn.selected = true
      self.selectedBtn = radioBtn
    end
    o:addWidget(radioBtn)

    btnPos = btnPos + Vec2:new(0, 2)
  end

  setmetatable(o, self)
  return o
end

function RadioGroup:getSelectedValue()
  if self.selectedBtn == nil then
    return nil
  end

  return self.selectedBtn:getTag()
end

return RadioGroup
