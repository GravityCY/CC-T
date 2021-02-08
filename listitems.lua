local invUtils = require(".lib.invutils")
local stringUtils = require(".lib.stringutils")

local arg = stringUtils.TableToString({...})

local items = invUtils.ListItems(arg, invUtils.GetAllChests(false, true))

local sorted = {}

for k,v in pairs(items) do
    table.insert(sorted, {name=k, count=v})
end

table.sort(sorted, function(a,b) return a.count < b.count end)

for index, item in ipairs(sorted) do
    print(stringUtils.Capitalize(item.name) .. " = " .. item.count .. " ")
end