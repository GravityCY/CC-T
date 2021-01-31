local iUtils = require(".lib.invutils")

local turtleutils = {}

local fuels =   {   
                    ["minecraft:coal"] = true, 
                    ["minecraft:charcoal"] = true,
                    ["minecraft:coal_block"] = true
                }

local blankTurtle = "4d1eb2f00be8854cd02b4ae0ca1c04b2" 

local items = {}

local size = 16

local function IsFuel(itemName)
    return fuels[itemName] ~= nil
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

function turtleutils.SetupTurtle(turtle, startupProgram)
    local drive = turtleutils.FindItem("computercraft:disk_drive")
    local disk = turtleutils.FindItem("computercraft:disk")
    
    if startupProgram ~= nil then
        print("test")
    end
    local startSlot = turtle.getSelectedSlot()
    turtle.select(drive)
    turtle.placeUp()
    turtle.select(disk)
    turtle.dropUp()
    turtle.back()
    turtle.select(turtle)
    turtle.place()
    peripheral.call("front", "turnOn")
    turtle.select(startSlot)
end

function turtleutils.PullItem(side, srcSlot, amount)
    srcSlot = srcSlot or 1

    local info = nil
    if srcSlot == 1 then
        info = turtle.suckUp(amount)
    else
        local top = peripheral.wrap(side)
        local empty = iUtils.FirstEmpty(top)
        top.pullItems(side, 1, 64, empty)
        top.pullItems(side, srcSlot, 64, 1)
        info = turtle.suckUp(amount)
        top.pullItems(side, empty, 64, 1)
    end
    return info
end

function turtleutils.SuckUp(amount, srcSlot)
    
end

function turtleutils.SuckItem(itemName, amount)
    return turtleutils.SuckUp(amount, turtleutils.FindItem(itemName))
end

function turtleutils.List()
    if items == nil then
        for i = 1, size do 
            local item = turtle.getItemDetail(i, true)
            items[i] = item
        end
    end
    return items
end

return turtleutils