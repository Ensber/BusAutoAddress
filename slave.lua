Object = require("classic")
require("bus")

Slave = Object:extend()
function Slave:new()
  self.address = B64():random()
  print(self.address)
  self.registered = false
end

function Slave:getTrigger()
  return function (bus)
    self:run(bus)
  end
end

function Slave:run(bus)
  local id = bus.toSlave.id
  if not self.registered then
    if id == "BS" then
      -- print("BS")
      local mask = bus.toSlave.mask
      local addr = bus.toSlave.addr
      if mask:band(self.address) == addr then
        -- print("BS SELF  ADDR", mask:band(self.address))
        -- print("BS OTHER ADDR", addr)
        bus.toMaster.addr = bus.toMaster.addr + self.address
      end
    elseif id == "REG" then
      -- print("REG")
      if bus.toSlave.addr == self.address then
        self.registered = true
        -- print(tostring(self.address) .. " was registered")
      end
    end
  else
    -- check for messages, when registered
  end
end