local tUtils = require(".lib.tableutils")
local pUtils = require(".lib.periphutils")

local invUtils = {}

local function FormatName(itemName)
    if itemName == nil then return end
    return (itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " "):lower()
end

-- Will return all currently connected chests
function invUtils.GetAllChests()
    return peripheral.find("minecraft:chest")
end

-- Will detect a difference in size of an inventory
function invUtils.GetChestUpdate(addrs, ...)   
    local chests = {}
    local prevSizes = {}
    local notThese = table.ToKeyTable({...})
    for index, address in ipairs(addrs) do
        -- Add addreses of these chests
        table.insert(chests, peripheral.wrap(address))
        -- Add the current sizes of the chests
        table.insert(prevSizes, table.SizeOf(chests[index].list()) )
    end

    -- Will keep trying to detect a change in size of any of the given chests
    while true do
        for index, chest in ipairs(chests) do
            local currentAddr = addrs[index]
            if not table.ContainsKey(notThese, currentAddr) then
                local prevSize = prevSizes[index]
                local size = table.SizeOf(chest.list())
                if size ~= prevSize then return currentAddr end 
            end
        end
        os.sleep(0.5)
    end
end

-- Will push all items from an inventory to another
function invUtils.PushAll(from, to, amount)
    if from == nil or to == nil then return end
    local tempTo = nil
    if type(from) == "string" then from = peripheral.wrap(from) end
    if type(to) == "table" then tempTo = peripheral.getName(to)
    else tempTo = to end
    amount = amount or 1

    for slot, item in pairs(from.list()) do
        from.pushItems(tempTo, slot, amount)
    end
end

-- Will return whether all slots are occupied
function invUtils.IsFull(inventory)
    if inventory == nil then return end

    return chestSize == table.SizeOf(inventory.list())
end

-- Will return how many items an inventory has
function invUtils.ItemCount(inventory)
    if inventory == nil then return end

    local total = 0
    for slot, item in pairs(inventory.list()) do
        total = total + item.count 
    end
    return total
end

-- Will return a number signifying how many unique items an inventory has
function invUtils.UniqueItems(inventory)
    if inventory == nil then return end
    
    local totalUnique = 0
    local prevItems = {}
    for slot, item in pairs(inventory.list()) do
        if prevItems[item.name] == nil then totalUnique = totalUnique + 1 prevItems[item.name] = true end
    end
    return totalUnique
end

-- Literally just re-adds every single item in a inventory in hopes that if there is the same item
-- at different slots it'll just stack them
function invUtils.Merge(inventory, inventoryAddr)
    if inventory == nil then return end
    inventoryAddr = inventoryAddr or peripheral.getName(inventory)

    for slot, item in pairs(inventory.list()) do
        inventory.pushItems(inventoryAddr, slot, 64)
    end
end

-- Converts an id with _ to space and and first letters to uppercase
function invUtils.ToDisplayName(itemName)
    if itemName == nil then return end
    return ((itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " ")):gsub("(%l)(%w+)", function(a,b) return string.upper(a)..b end)
end

-- Will return an amount of an item
function invUtils.CountItem(itemName, ...)
    local chests = GetAllChests()
    local count = 0
    itemName = itemName:lower()
    for i, chest in ipairs(chests) do
        for slot, item in pairs(chest.list()) do
            local formatName = FormatName(item.name)
            if formatName ~= nil and formatName == itemName then
                count = count + item.count 
            end
        end
    end
    return count
end

-- Will get an item based on registed id
-- Possible way to improve is to estimate similarity of id to provided item name and work with that
function invUtils.GetItem(inputAddr, itemName, itemCount)
    local chests = GetAllChests()
    itemName = itemName:lower()
    local foundCount = 0
    for index,chest in ipairs(chests) do
        local chestAddr = peripheral.getName(chest)
        if chestAddr ~= inputAddr then
            for slot, item in pairs(chest.list()) do
                local formatName = FormatName(item.name)
                if formatName == itemName then
                    local sentCount = chest.pushItems(inputAddr, slot, itemCount - foundCount)
                    foundCount = foundCount + sentCount
                    if foundCount == itemCount then return foundCount end
                end
            end
        end
    end
    return foundCount
end

-- Will get an item based on display name but is WAY slower
function invUtils.GetItemSlow(inputAddr, itemName, itemCount)
    local chests = GetAllChests()
    itemName = itemName:lower()

    local foundCount = 0
    for index,chest in ipairs(chests) do
        local chestAddr = peripheral.getName(chest)
        if chestAddr ~= inputAddr then
            for slot = 1, chest.size() do
                local item = chest.getItemDetail(slot)
                if item ~= nil and item.displayName:lower() == itemName then
                    local sentCount = chest.pushItems(inputAddr, slot, itemCount - foundCount)
                    foundCount = foundCount + sentCount
                    if foundCount == itemCount then return foundCount end
                end
            end
        end
    end
    return foundCount
end

function invUtils.ListItems(filter)
    if filter ~= nil then filter = filter:lower() end
    local items = {}
    local chests = GetAllChests()
    for i, chest in ipairs(chests) do
        for slot, item in pairs(chest.list()) do
            local formName = FormatName(item.name)
            if filter ~= nil then
                if formName:find(filter) ~= nil then
                    if items[formName] == nil then items[formName] = item.count 
                    else items[formName] = items[formName] + item.count end
                end
            else
                if items[formName] == nil then items[formName] = item.count 
                else items[formName] = items[formName] + item.count end
            end
        end
    end
    return items
end

return invUtils