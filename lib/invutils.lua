local tUtils = require(".lib.tableutils")
local pUtils = require(".lib.periphutils")

local invUtils = {}

local function FormatName(itemName)
    if itemName == nil then return end
    return (itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " "):lower()
end

-- Will return all currently connected chests
function invUtils.GetAllChests(asAddrs, notSide)
    asAddrs = asAddrs or false
    notSide = notSide or true
    return {pUtils.Find("minecraft:chest", asAddrs, notSide)}
end

function invUtils.GetItemSlot(itemName, inventories)
    for index, inventory in pairs(inventories) do
        for slot, item in pairs(inventory.list()) do
            if item.name == itemName then return peripheral.getName(inventory), slot end
        end
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

-- Will get total of all items combined in an inventory
function invUtils.ItemCount(inventory)
    local count = 0
    for slot, item in pairs(inventory.list()) do
        count = count + item.count
    end
    return count
end

-- Will try to push all items from a single inventory to multiple inventories
function invUtils.PushAllMulti(from, toInventories)
    if from == nil or toInventories == nil then return end

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
function invUtils.Merge(inventory)
    if inventory == nil then return end
    inventoryAddr = inventoryAddr or peripheral.getName(inventory)

    for slot, item in pairs(inventory.list()) do
        inventory.pushItems(inventoryAddr, slot, 64)
    end
end

local function GetInventory(inventory, asAddr)
    asAddr = asAddr or false
    
    if inventory == nil then return end
    local ty = type(inventory)
    if ty == "string" then 
        if asAddr then return inventory 
        else return peripheral.wrap(inventory) end
    elseif ty == "table" then 
        if not asAddr then return inventory 
        else return peripheral.getName(inventory) end 
    end
end

function invUtils.FirstItem(inventory, startIndex, endIndex, position, asItem, detailed)
    local tempInventory = GetInventory(inventory)
    if tempInventory == nil then return end

    startIndex = startIndex or 1
    endIndex = endIndex or inventory.size()
    position = position or 1
    asItem = asItem or false
    detailed = detailed or false

    local items = tempInventory.list()

    local pos = 1
    for slot = startIndex, endIndex do
        local item = items[slot]
        if item ~= nil then 
            if pos == position then
                if asItem then
                    if detailed then return tempInventory.getItemDetail(slot) 
                    else return item end 
                else return slot end
            end
            pos = pos + 1
        end
    end
end

function invUtils.FirstEmpty(inventory, startIndex, endIndex, position, asItem, detailed)
    startIndex = startIndex or 1
    endIndex = endIndex or inventory.size()
    position = position or 1
    asItem = asItem or false
    detailed = detailed or false
    local tempInventory = GetInventory(inventory)
    if tempInventory == nil then return end

    local items = tempInventory.list()
    local pos = 1
    for i = startIndex, endIndex do
        local item = items[i]
        if item == nil then 
            if pos == position then return i 
            else pos = pos + 1 end
        end
    end
end

-- Converts an id with _ to space and and first letters to uppercase
function invUtils.ToDisplayName(itemName)
    if itemName == nil then return end
    return ((itemName:sub(itemName:find(":")+1,#itemName)):gsub("_", " ")):gsub("(%l)(%w+)", function(a,b) return string.upper(a)..b end)
end

-- Will return an amount of an item
function invUtils.CountItemName(itemName, inventories)
    local count = 0
    itemName = itemName:lower()
    for i, chest in ipairs(inventories) do
        for slot, item in pairs(chest.list()) do
            local formatName = FormatName(item.name)
            if formatName ~= nil and formatName == itemName then
                count = count + item.count 
            end
        end
    end
    return count
end

-- Will return an amount of an item
function invUtils.CountItem(item, detailed, inventories)
    detailed = detailed or false
    
    local count = 0
    for i, chest in ipairs(inventories) do
        local items = chest.list()
        if detailed then
            for slot = 1, chest.size() do
                if items[slot] ~= nil then
                    local cItem = chest.getItemDetail(slot)
                    local same = false
                    for key, value in pairs(item) do
                        if key ~= "count" then 
                            same = cItem[key] == value 
                        end
                    end
                    if same then count = count + cItem.count end
                end
            end
        else
            for slot, cItem in pairs(chest.list()) do
                local same = false
                for key, value in pairs(item) do
                    if key ~= "count" then 
                        same = cItem[key] == value 
                    end
                end
                if same then count = count + cItem.count end
            end
        end
    end
    return count
end

-- Will get an item based on registed id
-- Possible way to improve is to estimate similarity of id to provided item name and work with that
function invUtils.GetItem(inputAddr, inventories, itemName, itemCount)
    itemName = itemName:lower()
    local foundCount = 0
    for index, chest in ipairs(inventories) do
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
function invUtils.GetItemSlow(inputAddr, inventories, itemName, itemCount)
    itemName = itemName:lower()

    local foundCount = 0
    for index,chest in ipairs(inventories) do
        local chestAddr = peripheral.getName(chest)
        if chestAddr ~= inputAddr then
            local items = chest.list()
            for slot = 1, chest.size() do
                if items[slot] ~= nil then
                    local item = chest.getItemDetail(slot)
                    if item.displayName:lower() == itemName then
                        local sentCount = chest.pushItems(inputAddr, slot, itemCount - foundCount)
                        foundCount = foundCount + sentCount
                        if foundCount == itemCount then return foundCount end
                    end
                end
            end
        end
    end
    return foundCount
end

function invUtils.ListItems(filter, inventories)
    if filter ~= nil then filter = filter:lower() end
    local items = {}
    for i, chest in ipairs(inventories) do
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