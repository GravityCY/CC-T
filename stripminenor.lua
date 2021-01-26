local arg = ...

local dist = 0
local maxInv = 16

local function Refuel()
    for i = 1, maxInv do
        turtle.select(i)
        turtle.refuel(64)
    end
end

local function Dig(distance)
    for i = 1, distance do
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        turtle.digDown()
    end
end

local function Return(distance)
    for i = 1, distance do
        turtle.back()
    end
end

local function Miner()
    Refuel()
    Dig(dist)
end

local function ReadDistance()
    while true do
        write("Enter distance: ")
        dist = tonumber(read())
        if dist ~= 0 then break end
    end
end

local function ProcArgs()
    if arg == nil then ReadDistance()
    else dist = tonumber(arg) end
    Miner()
end

local function Init()
    ProcArgs()
end

Init()

