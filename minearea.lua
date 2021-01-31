local tUtils = require(".lib.turtleutils")

local args = {...}

local dimX = tonumber(args[1])
local dimZ = tonumber(args[2])

local totalTurtles = dimZ - 1

tUtils.Refuel()

local function SetupTurtle(turtle)
    turtle.forward()
    tUtils.SetupTurtle(turtle)
end

local function GetTurtles()
    local gotTurtle = 0
    while true do
        local toSuck = totalTurtles-gotTurtle
        if toSuck > 64 then toSuck = 64 end
        tUtils.SuckItem("computercraft:turtle_advanced")
        if tUtils.IsBlank(items[i].nbt) then SetupTurtle(i) end
        if items[i] ~= nil then gotTurtle = gotTurtle + items[i].count end
        if gotTurtle >= totalTurtles then print("Got enough turtles") break end
    end
end
    turtle.select(1)
end

local function PutTurtles()
    for i =1, 16 do
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
end

Setup()