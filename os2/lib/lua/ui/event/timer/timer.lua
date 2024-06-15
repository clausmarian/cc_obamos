require("/os2/lib/lua/std")

local Timer = class("Timer")
Timer.Type = strenum("Timer.Type", {
  "ONCE",
  "REPEAT"
})

Timer.State = strenum("Timer.State", {
  "SUSPENDED",
  "STARTED",
  "RUNNING",
  "FINISHED"
})

function Timer:new(time, timerType, func)
  local o = {
    time = time,
    timerType = timerType,
    func = func,
    token = nil,
    state = Timer.State.SUSPENDED
  }

  setmetatable(o, self)
  return o
end

local function startTimer(time)
  return os.startTimer(time)
end

function Timer:start()
  if self.state == Timer.State.SUSPENDED then
    self.state = Timer.State.STARTED
  end
end

function Timer:run()
  if self.state ~= Timer.State.STARTED then
    return
  end

  self.token = startTimer(self.time)
  self.state = Timer.State.RUNNING
end

function Timer:fire()
  if self.state ~= Timer.State.RUNNING then
    return
  end

  self:func()

  if self.timerType == Timer.Type.REPEAT then
    self.token = startTimer(self.time)
  else
    self.token = nil
    self.running = false
    self.state = Timer.State.FINISHED
  end
end

function Timer:cancel()
  if self.token then
    os.cancelTimer(self.token)
  end

  self.state = Timer.State.FINISHED
end

return Timer
