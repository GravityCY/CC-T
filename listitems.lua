local invUtils = require(".lib.invutils")
local stringUtils = require(".lib.stringutils")

local arg = stringUtils.TableToString({...})

for itemName, amount in pairs(invUtils.ListItems(arg)) do
    print(stringUtils.Capitalize(itemName) .. " = " .. amount .. " ")
end