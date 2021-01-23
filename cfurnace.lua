local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local debug = require(".lib.debug")

debug.print = true

local unsortedChests = {peripheral.find("minecraft:chest")}
local unsortedAddrs = {}

-- Contains the addresses sequentally
local iChestAddr = nil
local oChestAddr = nil
local cChestAddr = nil
-- Contains the chests sequentally
local iChest = nil
local oChest = nil
local cChest = nil

local pullEvent = os.pullEvent

function os.pullEvent()
    local event, a, b, c, d = os.pullEventRaw()
    if event == "terminate" then print("Terminating.") os.pullEvent = pullEvent redstone.setOutput("bottom", false) error() end
    return event, a, b, c, d
end

local function Setup()
    for index, chest in ipairs(unsortedChests) do
        table.insert(unsortedAddrs, peripheral.getName(chest))
    end
    print("Add any item into the input chest and then into the output chest")
    iChestAddr = iUtils.GetChestUpdate(unsortedAddrs)
    print("Marked as input chest")
    oChestAddr = iUtils.GetChestUpdate(unsortedAddrs, iChestAddr)
    print("Marked as output chest")
    cChestAddr = table.GetNotThis(unsortedAddrs, iChestAddr, oChestAddr)
    print("Found chute chest")
    iChest = peripheral.wrap(iChestAddr)
    oChest = peripheral.wrap(oChestAddr)
    cChest = peripheral.wrap(cChestAddr)
end

local function Main()
    local totalItems = iUtils.ItemCount(iChest)
    local differentItems = iUtils.UniqueItems(iChest)
    iUtils.Merge(iChest, iChestAddr)

    local waitTime = ((totalItems / 16) * 0.3) + (table.SizeOf(iChest.list()) * 0.3) + 8

    print("Will finish smelting in " .. waitTime .. " seconds!")
    iUtils.PushAll(iChest, cChestAddr, 64)
    -- Will wait for the items to drop and also to smelt
    os.sleep(waitTime)
    print("Finished smelting, adding to chest...")
    redstone.setOutput("bottom", true)
    os.sleep(0.5)

    local hopper = peripheral.find("minecraft:hopper")
    local sentItems = 0
    local timeWaiting = 0
    local prevHopperSize = 0
    while true do
        if iUtils.IsFull(oChest) then
            print("Output chest is full, sleeping...") 
            os.sleep(5)
        end

        local hopperSize = table.SizeOf(hopper.list())
        iUtils.PushAll(hopper, oChest, 64)
        if prevHopperSize == hopperSize then timeWaiting = timeWaiting + 0.3 
        else timeWaiting = 0 end
        if timeWaiting >= 2 then break end
        if sentItems == totalItems then break end
        prevHopperSize = table.SizeOf(hopper.list())
        os.sleep(0.3)
    end

    redstone.setOutput("bottom", false)
    print("Finished.")
end

local function Init()
    if fs.exists("/appdata/furnace/addresses.txt") then
        settings.load("/appdata/furnace/addresses.txt")
        iChestAddr = settings.get("input")
        oChestAddr = settings.get("output")
        cChestAddr = settings.get("chute")
        iChest = peripheral.wrap(iChestAddr)
        oChest = peripheral.wrap(oChestAddr)
        cChest = peripheral.wrap(cChestAddr)
    else 
        Setup()
        settings.set("input", iChestAddr)
        settings.set("output", oChestAddr)
        settings.set("chute", cChestAddr)
        settings.save("/appdata/furnace/addresses.txt") 
    end

    Main()
end

Init()