-- item name, item count, ... address of the chests to ignore
local arg = {...}

-- Converts the values of a table to keys in another table
local function ToKeyTable(tab)
    local keyTable = {}
    for k,v in pairs(tab) do 
        table.insert(keyTable, k, true)
    end
    return keyTable
end

-- Checks if a key exists
local function Contains(table, value)
    return table[value] ~= nil
end

local function RemoveChestDupes(tab)
    local prevChests = {}
    for index, curChest in ipairs(tab) do
        local addr = peripheral.getName(curChest)
        if prevChests[addr] == nil then
            prevChests[addr] = true
        end
    end
    local prevChestsK = {}
    for index, v in pairs(prevChests) do
        table.insert(prevChestsK, peripheral.wrap(index))
    end
    return prevChestsK
end

local chests = {}

local itemName = ""
local itemAmount = 2304

local exclChests = ToKeyTable(arg)
local unnamedChests = RemoveChestDupes(table.pack(peripheral.find("minecraft:chest")))

local validChests = {}

local function ProcValidChests()
    for k,chest in ipairs(unnamedChests) do
        local addr = peripheral.getName(chest)
        if not Contains(exclChests, addr) then 
            table.insert(validChests, chest) 
        end
    end
end

local function FindItem()
    local foundCount = 0
    local foundInfo = {}
    for index, curChest in ipairs(validChests) do
        for iindex, curItem in pairs(curChest.list()) do
            if curItem.name == itemName then
                foundCount = foundCount + curItem.count
                local tempInfo = {addr=peripheral.getName(curChest), slot=iindex, count=curItem.count}
                table.insert(foundInfo,tempInfo)
                if foundCount >= itemAmount then return foundCount, foundInfo end 
            end
        end
    end
    return foundCount, foundInfo
end

local function ProcArgs()
    itemName = arg[1]
    if #arg >= 2 then
        itemAmount = tonumber(arg[2])
    end
end

local function Main()
    ProcArgs()
    ProcValidChests()
    local foundCount, info = FindItem()
    for index,chest in pairs(info) do
        print("\nChest Address: " .. chest.addr)
        print("Slot Index: " .. chest.slot)
        print("Slot Count: " .. chest.count)
    end
    print("\nFound a total of " .. foundCount .. " of " .. itemName)
end

Main()