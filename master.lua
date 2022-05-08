Object = require("classic")
require("bus")

Master = Object:extend()
function Master:new(bus)
  self.bus = bus
  self.addresses = {}
  self.sendREG = false
end

local function bSearch(master, bus, bitC, mask, searchAddr)
  -- if bitC >= 16 then
  --   print("Stop search at " .. bitC .. " bits!")
  --   return
  -- end

  bus.toMaster.addr:clear()
  bus.toSlave.id = "BS"
  bus.toSlave.mask = mask
  bus.toSlave.addr = searchAddr
  bus:trigger()

  if bus.toMaster.addr:isEmpty() then -- no response/client with such a address
    -- print("e     " .. tostring(mask))
    -- print("empty " .. tostring(searchAddr))
    return
  elseif bus.toMaster.addr:check() then -- single response
    print("found -- " .. tostring(bus.toMaster.addr))
    -- print("found sm " .. tostring(bus.toSlave.mask))
    -- print("found sa " .. tostring(bus.toSlave.addr))

    if master.sendREG then
      bus.toSlave.id = "REG"
      bus.toSlave.addr = bus.toMaster.addr
      bus:trigger()
    end

    table.insert(master.addresses, bus.toMaster.addr)
  else -- multiple results
    -- print("m     " .. tostring(mask))
    -- print("multi " .. tostring(searchAddr))
    bitC = bitC + 1
    mask = mask:setBit(bitC, 1) -- expand mask
    bSearch(master, bus, bitC, mask, searchAddr)
    bSearch(master, bus, bitC, mask, searchAddr:setBit(bitC, 1))
  end
end

function Master:search()
  local mask = B64():setBit(1, 1)
  local addr = B64()
  bSearch(self, self.bus, 1, mask, addr)
  bSearch(self, self.bus, 1, mask, addr:setBit(1, 1))
end