Object = require("classic")
require("bit")

-- DATA --
B64 = Object:extend()

function B64:clear()
  for i = 1, 4 do
    self[i] = 0
  end
end

function B64:new()
  self:clear()
end

function B64:add(other)
  for i = 1, 4 do
    self[i] = bit.bor(self[i], other[i])
  end
  return self
end
B64.__add = B64.add

function B64:random()
  for n = 1, 32 do
    local run = true
    while run do
      local i = math.random(1,4)
      local candidate = 2^math.random(0,15)
      if bit.band(self[i], candidate) == 0 then
        self[i] = bit.bor(self[i], candidate)
        run = false
      end
    end
  end
  return self
end

function B64:__eq(other)
  for i = 1, 4 do
    if self[i] ~= other[i] then
      return false
    end
  end
  return true
end

function B64:band(other)
  local res = B64()
  for i = 1, 4 do
    res[i] = bit.band(self[i], other[i])
  end
  return res
end

function B64:bxor(other)
  local res = B64()
  for i = 1, 4 do
    res[i] = bit.bxor(self[i], other[i])
  end
  return res
end

function B64:check()
  local c = 0
  for i = 1, 4 do
    local n = self[i]
    while n > 0 do
      if n % 2 == 1 then
        c = c + 1
      end
      n = math.floor(n/2)
    end
  end
  return c == 32, c
end

function B64:__tostring()
  local s = ""
  for i = 4, 1, -1 do
    local n = self[i]
    for i = 1, 16 do
      s = (n % 2) .. s
      n = math.floor(n / 2)
    end
  end
  return s
end

function B64:mask(n)
  n = n - 1
  for i = 0, n do
    local cell = math.floor(i / 16)
    local index = i % 16
    self[cell + 1] = bit.bor(self[cell + 1], 2^(15-index))
  end
  return self
end

function B64:copy()
  local out = B64()
  for i = 1, 4 do
    out[i] = self[i]
  end
  return out
end

function B64:setBit(i, state)
  local out = B64()
  local mask = B64()

  i = i - 1
  local cell = math.floor(i / 16)
  local index = i % 16
  mask[cell + 1] = 2^(15-index)

  if state == 1 then
    state = mask:copy() -- 1
  else
    state = B64()      -- 0
  end

  for i = 1, 4 do
    out[i] = bit.bor(bit.band(bit.bnot(mask[i]), self[i]), state[i])
  end
  return out
end

function B64:isEmpty()
  return self[1] + self[2] + self[3] + self[4] == 0
end

-- for i = 0, 64 do
--   local temp = B64()
--   temp:mask(i)
--   print(temp)
-- end

-- local temp = B64()
-- for i = 1, 64 do
--   temp = temp:setBit(i, 1)
--   print(temp)
-- end

-- function setAddr(d)
--   return d
--     :setBit(1, 1)
--     :setBit(3, 1)
--     :setBit(5, 1)
--     :setBit(7, 1)
--     :setBit(9, 1)
-- end

-- local self_address = setAddr(B64())
-- local net_mask     = B64():mask(5)
-- local net_addr     = setAddr(B64())

-- self_address = self_address:setBit(1,0)

-- local tmp1 = self_address:band(net_mask)
-- local tmp2 = net_addr:band(net_mask)
-- local ok  = tmp1 == tmp2
-- print(self_address)
-- print(net_mask)
-- print(net_addr)
-- print(tmp1)
-- print(tmp2)
-- print(ok)

-- BUS --
Bus = Object:extend()
function Bus:new()
  self.transferCount = 0
  self.toMaster = {
    addr = B64()
  }
  self.toSlave  = {
    id = "",
    addr = B64(),
    mask = B64()
  }
end

function Bus:addListener(f)
  table.insert(self, f)
end

function Bus:trigger()
  self.transferCount = self.transferCount + 1
  for i=1, #self do
    self[i](self)
  end
end

function Bus:reset()
  self.toMaster.data:clear()
  self.toSlave.id = ""
  self.toSlave.addr:clear()
  self.toSlave.mask:clear()
end