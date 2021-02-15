local tUtils = require(".lib.turtleutils")
local iUtils = require(".lib.invutils")

local args = {...}

local dimX = tonumber(args[1])
local dimZ = tonumber(args[2])

local totalTurtles = dimZ - 1

tUtils.Refuel()

local items = {}

local function GetTurtles()
    local gotTurtle = 0
    for i = 1, tUtils.Size() do
        local toSuck = totalTurtles-gotTurtle
        if toSuck > 64 then toSuck = 64 end
        turtle.select(i)
        turtle.suckUp(toSuck)
        items[i] = turtle.getItemDetail(_,true)
        if items[i] ~= nil then gotTurtle = gotTurtle + items[i].count end
        if gotTurtle >= totalTurtles then print("Got enough turtles") break end
    end
    turtle.select(1)
ends

local function SetupTurtles()
    for i = 1, tUtils.Size() do
        local item = items[i]
        if tUtils.IsBlank(item.nbt) then
            for ii=1, item.count do
                tUtils.SetupTurtle(i, "turtle.turnLeft()")
            end
        end
    end 
end

local function PutTurtles()
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropUp()
    end
end

local function Setup()
    local _,blockAbove = turtle.inspectUp()
    local enderSlot = tUtils.FindItem("enderstorage:ender_chest")
    if blockAbove ~= nil and blockAbove.name == "enderstorage:ender_chest" then
        GetTurtles()
    elseif enderSlot ~= nil then 
        turtle.digUp()
        turtle.select(enderSlot)
        turtle.placeUp()
        turtle.select(1)
        GetTurtles()
    end
    SetupTurtles()    
end

Setup()