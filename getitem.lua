local iUtils = require(".lib.invutils")
local sUtils = require(".lib.stringutils")

local arg = {...}
local inputNum = tonumber(arg[#arg])
local inputAddr = iUtils.
local itemName = ""
local itemCount = 2304

-- if the last is a number
if inputNum ~= nil then 
    itemCount = inputNum 
    itemName = sUtils.TableToString(arg, 1, #arg-1) 
else itemName = sUtils.TableToString(arg) end

if itemName == nil then print("Please enter an Item Name.") return end
local foundCount = iUtils.GetItem(inputAddr,itemName,itemCount)

print("Put " .. foundCount .. " " .. itemName .. " inside of " .. inputAddr)