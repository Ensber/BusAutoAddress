# Description
This code is a protocol demonstation to find multiple devices efficiently on one wire with no addresses predefined.

It is using a binary search to find address part collissions, empty address spaces and fragments with just one address.

A slave address has always 32Bits out of 64Bits on. If now two slaves write their addresses on the bus at the same time, then the received addrress will have more than 32Bit active. If so, then the queried address is part of multiple slave addresses and we need to query the next bit. If no slave responds, then all bits will be zero. If the address received has exactly 32Bits active then we have found another slave address.

# Messages
==========

`id` is the type of a message. `mask` is a bitmask. In this case, it was completely transmitted, but it would be more efficient to only send a byte with the count of the mask bits. `addr` is a address field. `b64` means a 64Bit integer, represented as `B64` in the Programm.

## binary search
* id = "BS"
* mask: b64
* addr: b64

## register
* id = "REG"
* addr: b64


# TEST RESULTS
==============

## 1000 slaves (no reg)
* 2884 tries

## 1000 slaves (with reg)
* 3884 tries
==> sending a reg message is useless and wastes time, except if we need it