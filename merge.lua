-- Find all chests
-- Find all matching items, and try to input all into one chest

local id = ...
id = id or "minecraft:chest"

local chests = ({peripheral.find(id)})

local chestItems = {{}}

local function Map()
    for i,v in ipairs(chests) do
        chestItems[i] = {}
        for k,vv in pairs(v.list()) do
            chestItems[i][vv.name] = true
        end
    end
end

local function PrintMappedItems()
    for i,v in ipairs(chestItems) do
        for kk,vv in pairs(v) do
            print(kk)
        end
    end
end

local function ChestContains(index, item)
    return chestItems[index][item] ~= nil
end

local function GetDuplicateChest(self, item)
    for i,v in ipairs(chestItems) do
        if i ~= self and ChestContains(i, item) then return i end
    end
end


local function SortLocally()
    for chestIndex, chest in ipairs(chests) do
        for itemSlot, itemData in pairs(chest.list()) do
            chest.pushItems(peripheral.getName(chest), itemSlot, 64)
        end
    end
end 

local function Sort()
    for chestIndex, chest in ipairs(chests) do
        for itemSlot,itemData in pairs(chest.list()) do
            local dupe = GetDuplicateChest(chestIndex, itemData.name)
            if dupe ~= nil then 
                chest.pushItems(peripheral.getName(chests[dupe]), itemSlot, 64)
                chestItems[chestIndex][itemData.name] = nil
            end
        end
    end
end

local function Start()
    Map()
    Sort()
    SortLocally()
end

Start()