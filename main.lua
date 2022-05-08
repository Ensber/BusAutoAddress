require("bus")
require("master")
require("slave")

local bus = Bus()

local slaves = {}
for i = 1, 1000 do
  local s = Slave()
  slaves[i] = s
  bus:addListener(s:getTrigger())
end

master = Master(bus)
-- master.sendREG = true
master:search()
print("took " .. bus.transferCount .. " transfers to find " .. #master.addresses .. " slaves (generated " .. #slaves .. " slaves originally)")
