local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local oUtils = require(".lib.osutils")
local debug = require(".lib.debug")
local pUtils = require(".lib.periphutils")

debug.print = true

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
print(modemAddr)
rednet.open(modemAddr)

local commands = {add="addproduct", add_already="-addproduct", register_terminal="register"}

local regChest = peripheral.wrap("top")
local serverID = 5

local leftShift = false
local leftCtrl = false
local leftAlt = false

local xSize, ySize = term.getSize()

local function Difference(inv_a, inv_b)    
    local found = false
    local diff = nil
    for ka,va in pairs(inv_b) do
        for kb, vb in pairs(inv_a) do
            if ka == kb then found = true end
        end
        if not found then diff = ka break
        else found = false end
    end
    return diff
end

local function PrintHelp()
    print("\n-- Commands --")
    for _, command in pairs(commands) do
        print(command)
    end
end

local function ItemToString(item)
    local nItem = {}
    nItem["name"] = item.name
    nItem["displayName"] = item.displayName
    nItem["count"] = item.count
    nItem["enchants"] = item.enchantments
    nItem["maxDamage"] = item.maxDamage
    nItem["damage"] = item.damage
    return textutils.serialise(nItem)
end

local function Blit(text, textColor, backColor)
    local maxX, maxY = term.getSize()
    local termX, termY = term.getCursorPos()
    if termX >= maxX then term.setCursorPos(1, termY+1) end
    term.blit(text,textColor,backColor)
end

local function PrintItem(item, compact)
    compact = compact or false
    if compact then 
        -- Blit("ID:", "eee", "fff")
        -- write(" " .. item.name.. " ")
        Blit("Name:", "eeeee","fffff")
        write(" " .. item.displayName .. " ")
        Blit("Amount:", "eeeeeee", "fffffff")
        print(" " .. item.count)
        if item.enchantments ~= nil then
            Blit("Enchants:", "eeeeeeeee", "fffffffff")
            write(" { " .. item.enchantments[1].displayName)
            for i = 2, #item.enchantments do
                write(", " .. item.enchantments[i].displayName)
            end
            write("} ")
        end
        if item.damage ~= nil then
            Blit("Durability:", "eeeeeeeeeee", "fffffffffff")
            write(" " .. item.maxDamage - item.damage)
        end
        print()
    else
        -- Blit("ID:", "eee", "fff")
        -- print(" " .. item.name)
        Blit("Name:", "eeeee","fffff")
        print(" " .. item.displayName)
        Blit("Amount:", "eeeeeee", "fffffff")
        print(" " .. item.count)
        if item.enchantments ~= nil then
            Blit("Enchants:", "eeeeeeeee", "fffffffff")
            write(" { " .. item.enchantments[1].displayName)
            for i = 2, #item.enchantments do
                write(", " .. item.enchantments[i].displayName)
            end
            print("} ")
        end
        if item.damage ~= nil then
            Blit("Durability:", "eeeeeeeeeee", "fffffffffff")
            print(" " .. item.maxDamage - item.damage)
        end
    end
end

-- prints the product and the cost
local function PrintExchange(product, cost, detail)
    if detail then 
        term.clear()
        term.setCursorPos(1,1)
        Blit("Product: ", "bbbbbbbbb", "fffffffff")
        PrintItem(product)
        Blit("Cost: ", "bbbbbb", "ffffff")
        PrintItem(cost)
        print()
    else
        local pEnchants = ""
        local cEnchants = ""

        if product.enchantments ~= nil then
            pEnchants = " (With Enchants)"
        end
        if cost.enchantments ~= nil then
            cEnchants = " (With Enchants)"
        end
        
        Blit("Give ", "eeeee", "fffff")
        write(product.count .. " " .. product.displayName  .. pEnchants)
        Blit(" For ", "eeeee", "fffff")
        write(cost.count .. " "  .. cost.displayName .. cEnchants)
    end
end

-- Detects whether a chest stored items changed in size positively
local function DetectAddedItem(chest, detail)
    detail = detail or false

    -- detects a change in a chest
    local pItems = chest.list()
    local pSize = table.SizeOf(pItems)

    while true do
        os.sleep(0.5)
        local nItems = chest.list()
        if pSize < table.SizeOf(nItems) then
            local difSlot = Difference(pItems, nItems)
            if detail then return chest.getItemDetail(difSlot)
            else return nItems[difSlot] end
        end
    end
end

local function RegisterTerminal()
    
end

local function RegisterStock(product, cost)
    print("Registered Stock.")
    local pString = ItemToString(product)
    local cString = ItemToString(cost)
    oUtils.EnableTerminate()
    rednet.send(serverID, "+ " .. os.getComputerID() .. " " .. pString .. " " .. cString, "ts")
    oUtils.DisableTerminate()
end

local function AddItem(ready)
    ready = ready or false

    -- make it find the first item
    local product = iUtils.FirstItem(regChest, _, _, _, true)
    local pCount = 1
    -- make it find the next item after the first item
    local cost = iUtils.FirstItem(regChest, _, _, 2, true)
    local cCount = 1

    if ready then
        print("Next, enter an amount of your product to sell.")
        product.count = tonumber(read())
        print("Next, enter an amount of the item to receive for your product.")
        cost.count = tonumber(read())
    else
        print("Please enter a specific item in the register chest to add to your list of products.")
        product = DetectAddedItem(regChest, true)
        print("Next, enter an amount (number) of your product to sell")
        pCount = tonumber(read())
        print("Next, please enter a specific item to set as your product's payment")
        cost = DetectAddedItem(regChest, true)
        print("Next, enter an amount of the item to receive for your product")
        cCount = tonumber(read())
    end

    while true do
        PrintExchange(product,cost)
        Blit(" Add product and cost to system? y/n", "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", "ffffffffffffffffffffffffffffffffffff")
        print()
        local input = read():lower()
        if input == "y" then
            RegisterStock(product, cost)
            return true
        elseif input == "n" then
            -- dont do stuff
            return false
        end
    end
end

local function Interface()
    while true do
        PrintHelp()
        local input = read()
        if input == commands.add then
            AddItem()
        elseif input == commands.add_already then
            AddItem(true)
        elseif input == commands.register_terminal then
            RegisterTerminal()
        end
    end
end

local function AwaitRequest()
    while true do
        local event, message = rednet.receive()
        print(event, message)
    end
end


parallel.waitForAll(Interface, AwaitRequest)
