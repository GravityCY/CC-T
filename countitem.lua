local invUtils = require(".lib.invutils")
local stringUtils = require(".lib.stringutils")

local itemName = stringUtils.TableToString({...})

print("You currently have " .. invUtils.CountItem(itemName) .. " " .. itemName .. "(s)")
