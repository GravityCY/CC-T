local arg = ...
local furnaces = {peripheral.find("minecraft:furnace")}
local chestIO = peripheral.find("minecraft:chest")
local chestAddr = peripheral.getName(chestIO)

-- Furnace
local totalFurnaces = #furnaces
-- Fuel
local fuelName = chestIO.list()[1].name
local totalFuel = 0
local splitFuel = 0
-- Ingredient
local totalIngredient = 0
local splitIngredient = 0

local tempIndex = 0
local function NextFuelSlot()
    for slot, item in pairs(chestIO.list()) do
        if item.name == fuelName then
            return slot
        end
    end
end

local function NextIngredientSlot()
    for slot, item in pairs(chestIO.list()) do
        if item.name ~= fuelName then
            return slot
        end
    end
end

local function TotalFuel()
    for slot, item in pairs(chestIO.list()) do
        if item.name == fuelName then
            totalFuel = totalFuel + item.count
        end
    end
end

local function SplitFuel()
    splitFuel = math.ceil(math.ceil(totalIngredient / 8) / totalFurnaces)
end

local function EfficientSplitFuel()
    splitFuel = math.floor(splitIngredient / 8)
    if splitFuel == 0 then splitFuel = 1 end
end

local function TotalIngredient()
    for slot, item in pairs(chestIO.list()) do
        if item.name ~= fuelName then
            totalIngredient = totalIngredient + item.count
        end
    end
end

local function SplitIngredient()
    splitIngredient = math.ceil(totalIngredient / totalFurnaces)
end

-- 65 Ingredient, 2 Furnace, 32 Per
-- 64 Ingredient, 3 Furnace, 
-- 64 Ingredient, 8 Furnace, 8 Per
-- 64 Ingredient, 10 Furnace, 8 Per
local function EfficientSplitIngredient()
    SplitIngredient()
    local mod = splitIngredient % 8
    -- if the mod of split is not 0 so like 33 % 8 == 1
    if mod ~= 0 then
        splitIngredient = splitIngredient + (8 - (splitIngredient % 8))
        if splitIngredient == 0 then splitIngredient = 8 end
    end
end

local function Compute()
    TotalIngredient()
    SplitIngredient()
    TotalFuel()
    SplitFuel()
end

local function EfficientCompute()
    TotalIngredient()
    EfficientSplitIngredient()
    TotalFuel()
    EfficientSplitFuel()
end

local function Output()
    for i = 1, splitIngredient do
        os.sleep(10)
        for i, furnace in pairs(furnaces) do
            furnace.pushItems(chestAddr, 3, 64)
        end
    end
    print("Finished smelting")
end

local function InsertFuel(furnace)
    local sentAmount = 0
    for slot, item in pairs(chestIO.list()) do
        if item.name == fuelName then
            sentAmount = sentAmount + furnace.pullItems(chestAddr, slot, splitFuel - sentAmount, 2)
            if sentAmount == splitFuel then return end
        end
    end
end

local function InsertIngredient(furnace)
    local sentAmount = 0
    for slot, item in pairs(chestIO.list()) do
        if item.name ~= fuelName then
            sentAmount = sentAmount + furnace.pullItems(chestAddr, slot, splitIngredient - sentAmount, 1)
            if sentAmount == splitIngredient then return end
        end
    end
end

local function EfficientStart()
    EfficientCompute()
    for i, furnace in pairs(furnaces) do
        if i == totalIngredient / splitIngredient then break end
        InsertFuel(furnace)
        InsertIngredient(furnace)
    end
    Output()
end

local function Start()
    Compute()
    for i, furnace in pairs(furnaces) do
        InsertFuel(furnace)
        InsertIngredient(furnace)
    end
    Output()
end

if arg ~= nil then
    EfficientStart()
else
    Start()
end





