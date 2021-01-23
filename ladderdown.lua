local tUtils = require(".lib.turtleutils")

io.write("Enter the turtles current Y level: ")
local yLevel = tonumber(read())

local totalLadders = 0
local totalBlocks = 0

local ladderSlots = {}
local blockSlots = {}

local function HasBlocks()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item ~= nil then
            if item.name == "minecraft:ladder" then
                table.insert(ladderSlots, i)
                totalLadders = totalLadders + item.count
            else
                table.insert(blockSlots, i)
                totalBlocks = totalBlocks + item.count
            end
        end
    end
    return totalLadders >= yLevel and totalBlocks >= yLevel
end

local function Dig()
    local digCount = 0
    while true do
        local success, info = turtle.digDown()
        if not success and info == "Unbreakable block detected" then return digCount end
        turtle.down()
        turtle.dig()
        digCount = digCount + 1
    end 
end

local function Return(upTimes)
    local blockIndex = 1
    local ladderIndex = 1
    for i = 1, upTimes do
        turtle.dig()
        turtle.select(blockSlots[blockIndex])
        local block = turtle.getItemDetail()
        if block == nil or block.count == 0 then 
            blockIndex = blockIndex + 1
            turtle.select(blockSlots[blockIndex])
        end
        turtle.place()
        turtle.up()
        turtle.select(ladderSlots[ladderIndex])
        local ladder = turtle.getItemDetail()
        if ladder == nil or ladder.count == 0 then 
            ladderIndex = ladderIndex + 1
            turtle.select(ladderSlots[ladderIndex])
        end
        turtle.placeDown()
    end
end

local function Main()
    if not HasBlocks() then 
        print("You need " .. yLevel - totalLadders .. " more ladders and " .. yLevel - totalBlocks .." more blocks.")  
        error() 
    end
    tUtils.Refuel()
    local digCount = Dig()
    Return(digCount)
end

Main()