local tUtils = require(".lib.turtleutils")

-- if nil then it will not mine forward else mine forward
local mineForward = ...

local function Dig()
    local digCount = 0
    while true do
        local success, info = turtle.digDown()
        if not success and info == "Unbreakable block detected" then break end
        turtle.down()
        if mineForward ~= nil then turtle.dig() end
        digCount = digCount + 1
    end
    return digCount
end

local function Return(upTimes)
    for i = 1, upTimes do
        turtle.up()
    end
end

local function Main()
    tUtils.Refuel()
    local digCount = Dig() 
    Return(digCount)
end

Main()