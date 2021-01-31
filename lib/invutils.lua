local tUtils = require(".lib.tableutils")
local pUtils = require(".lib.periphutils")

local invUtils = {}

local function FormatName(itemName)
    if itemName == nil then return end
    return (itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " "):lower()
end

-- Will return all currently connected chests
function invUtils.GetAllChests()
    return {peripheral.find("minecraft:chest", true)}
end

function invUtils.GetItemSlot(inventory, itemName)
    for slot, item in pairs(inventory.list()) do
        if item.name == itemName then return slot end
    end
end

-- Will detect a difference in size of an inventory
function invUtils.GetChestUpdate(sleepTime, addrs, ...)   
    sleepTime = sleepTime or 0
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
        os.sleep(sleepTime)
    end
end

-- Will detect a difference in size of an inventory and return the item slot that was changed
-- Example, player adds 1 dirt to slot 1 returns slot 1
-- Example, player removes
-- function invUtils.GetItemUpdate()

-- Will push all items from an inventory to another
function invUtils.PushAll(from, to)
    if from == nil or to == nil then return end

    amount = amount or 1
    local tempTo = to
    local tempFrom = from
    if type(from) == "string" then tempFrom = peripheral.wrap(from) end
    if type(to) == "table" then tempTo = peripheral.getName(to) end

    for slot, item in pairs(from.list()) do
        tempFrom.pushItems(tempTo, slot, 64)
    end
end

function invUtils.PushAllMulti(from, toInventories)
    if from == nil or toInventories == nil then return end

    amount = amount or 1

    for key, inventory in pairs(toInventories) do
        local invAddr = inventory
        if type(inventory) == "table" then invAddr = peripheral.getName(inventory) end
        local itemsLeft = invUtils.ItemCount(from)
        for slot, item in pairs(from.list()) do
            itemsLeft = itemsLeft - from.pushItems(invAddr, slot, 64)
            if itemsLeft <= 0 then return true end
        end
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
    local tempInventory = inventory
    if type(inventory) == "string" then tempInventory = peripheral.wrap(inventory) end

    local total = 0
    for slot, item in pairs(tempInventory.list()) do
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

function invUtils.FirstItem(inventory, startIndex, endIndex, position, asItem, detailed)
    if inventory == nil then return end
    if type(inventory) == "string" then inventory = peripheral.wrap(inventory) end

    startIndex = startIndex or 1
    endIndex = endIndex or inventory.size()
    position = position or 1
    asItem = asItem or false
    detailed = detailed or false

    local items = inventory.list()

    local pos = 1
    for slot = startIndex, endIndex do
        local item = items[slot]
        if item ~= nil then 
            if pos == position then
                if asItem then
                    if detailed then return inventory.getItemDetail(slot) 
                    else return item end 
                else return slot end
            end
            pos = pos + 1
        end
    end
end

function invUtils.FirstItemSlot(inventory, startIndex, endIndex, position)
    startIndex = startIndex or 1
    endIndex = endIndex or inventory.size()
    position = position or 1

    local firstSlot = nil
    for slot, item in pairs(inventory.list()) do
        if slot >= startIndex and slot <= endIndex then 
            if firstSlot == nil or slot < firstSlot then firstSlot = slot end
        end
    end
    return firstSlot
end

function invUtils.FirstEmpty(inventory, startIndex, endIndex)
    startIndex = startIndex or 1
    endIndex = endIndex or inventory.size()

    local items = inventory.list()
    for i = startIndex, endIndex do
        local item = items[i]
        if item == nil then return i end
    end
end

-- Converts an id with _ to space and and first letters to uppercase
function invUtils.ToDisplayName(itemName)
    if itemName == nil then return end
    return ((itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " ")):gsub("(%l)(%w+)", function(a,b) return string.upper(a)..b end)
end

-- Will return an amount of an item
function invUtils.CountItem(itemName, ...)
    local chests = invUtils.GetAllChests()
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
    local chests = invUtils.GetAllChests()
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
    local chests = invUtils.GetAllChests()
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
    local chests = invUtils.GetAllChests()
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