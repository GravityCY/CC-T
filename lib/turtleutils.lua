local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local sides = require(".lib.sides")

local turtleutils = {}

local fuels =   {   
                    ["minecraft:coal"] = true, 
                    ["minecraft:charcoal"] = true,
                    ["minecraft:coal_block"] = true
                }

local blankTurtle = "4d1eb2f00be8854cd02b4ae0ca1c04b2" 

local size = 16

local startPath = "/disk/startup.lua"
local startOperations = ""

local function IsFuel(itemName)
    return fuels[itemName] ~= nil
end

local function List(detailed)
    detailed = detailed or false
    
    local items = {}
    for i = 1, size do
        items[i] = turtle.getItemDetail(i, detailed)
    end
    return items
end

function turtleutils.Refuel()
    local startSlot = turtle.getSelectedSlot()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item ~= nil and turtle.getFuelLevel() ~= turtle.getFuelLimit() and IsFuel(item.name) then
            turtle.select(i)
            turtle.refuel(64)
        end
    end
    turtle.select(startSlot)
end

function turtleutils.FindItem(itemName)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item ~= nil and item.name == itemName then return i end
    end
end

function turtleutils.IsBlank(nbt)
    return nbt == blankTurtle
end

local function Break(side)
    if side == sides.up then return turtle.digUp()
    elseif side == sides.down then return turtle.digDown()
    elseif side == sides.forward then return turtle.dig() end
end

function turtleutils.Go(side, repeats)
    repeats = repeats or 1

    if repeats == 1 then
        if side == sides.forward then return turtle.forward()
        elseif side == sides.right then turtle.turnRight() return turtle.forward()
        elseif side == sides.back then return turtle.back()
        elseif side == sides.left then turtle.turnLeft() return turtle.forward()
        elseif side == sides.up then return turtle.up() 
        elseif side == sides.down then return turtle.down() end
    else
        local success = {}
        for i = 1, repeats do
            success[i] = {turtleutils.Go(side, 1)}
        end
        return success
    end
end

function turtleutils.GoPause(side, repeats)
    repeats = repeats or 1
    
    if repeats == 1 then
        while true do
            local success, info = turtleutils.Go(side)
            if not success then os.sleep(0.5)
            else return success, info end 
        end
    else
        local success = {}
        for i = 1, repeats do
            success[i] = {turtleutils.GoPause(side, 1)}
        end
        return success
    end
end

function turtleutils.GoBreak(side, repeats)
    repeats = repeats or 1

    if repeats == 1 then
        while true do
            local success, info = turtleutils.Go(side)
            if not success then Break(side) success, info = turtleutils.Go(side) end
            if success then return success, info end
            os.sleep(0.5)
        end
    else
        local success = {}
        for i = 1, repeats do
            success[i] = {turtleutils.GoBreak(side, 1)}
        end
        return success
    end
end

-- Will detect a difference in size of an inventory
function turtleutils.GetInvUpdate(sleepTime)
    sleepTime = sleepTime or 0
    local prevSize = tUtils.SizeOf(List(false))

    -- Will keep trying to detect a change in size of any of the given chests
    while true do
        if prevSize ~= tUtils.SizeOf(List(false)) then
            return
        end
        os.sleep(sleepTime)
    end
end

function turtleutils.SetupTurtle(tSlot, startupCode, startupProgram, libraries)

    local startSlot = turtle.getSelectedSlot()

    local handler = {}

    function handler.PlaceTurtle()
        turtle.select(tSlot)
        turtle.place()
    end

    function handler.EnableTurtle()
        local child = peripheral.find("turtle")
        if child.isOn() then
            child.reboot()
        else child.turnOn() end
    end

    function handler.PlaceDrive()
        local drive = turtleutils.FindItem("computercraft:disk_drive")
        local disk = turtleutils.FindItem("computercraft:disk")
        turtle.select(drive)
        turtle.place()
        turtle.select(disk)
        turtle.drop()
        local startup = fs.open(startPath, "w")
        startup.write(startOperations)
        startup.close()
    end 

    function handler.RemoveDrive()
        turtle.suck()
        turtle.dig()
        turtle.select(startSlot)
    end

    function handler.WriteStartCode()
        if startupCode ~= nil then
            local startup = fs.open(startPath, "a")
            startup.write(startupCode .. "\n")
            startup.close()
        end
    end

    function handler.WriteStartup()
        if startupProgram ~= nil then
            local programFile = fs.open(startupProgram, "r")
            local programCode = programFile.readAll()
            local codeEscape = programCode:gsub("\"", "\\\""):gsub("\n", "\\n")
            local metaCode = "local file = fs.open(\"/startup.lua\", \"w\")\nfile.write(\"" .. codeEscape .. "\")\nfile.close()"
            programFile.close()
            local startup = fs.open(startPath, "a")
            startup.write(metaCode)
            startup.close()
        end
    end

    return handler
end

function turtleutils.PullItem(side, srcSlot, amount)
    srcSlot = srcSlot or 1
    if srcSlot == 1 then
        return turtle.suckUp(amount)
    else
        local top = peripheral.wrap(side)
        local empty = iUtils.FirstEmpty(top)
        top.pullItems(side, 1, 64, empty)
        top.pullItems(side, srcSlot, 64, 1)
        local info = turtle.suckUp(amount)
        top.pullItems(side, empty, 64, 1)
        return info
    end
end

function turtleutils.SuckItem(itemName, amount)
    return turtleutils.SuckUp(amount, turtleutils.FindItem(itemName))
end

function turtleutils.Size()
    return size
end

function turtleutils.List(detailed)
    return List(detailed)
end

return turtleutils