local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local oUtils = require(".lib.osutils")
local pUtils = require(".lib.periphutils")

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
print(modemAddr)
rednet.open(modemAddr)

local commands = {add="addproduct", register_terminal="register"}

local regChest = peripheral.wrap("top")
local serverID = 5

local xSize, ySize = term.getSize()

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
    local colorText = ""
    local backText = ""
    for i = 1, #text do
        colorText = colorText .. colors.toBlit(textColor)
        backColor = backText .. colors.toBlit(backColor)
    end
    term.blit(text, colorText, backText)
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

local function RegisterTerminal()
    
end

local function RegisterStock(product, cost)
    print("Registered Stock.")
    local pString = ItemToString(product)
    local cString = ItemToString(cost)
    rednet.send(serverID, "+ " .. os.getComputerID() .. " " .. pString .. " " .. cString, "ts")
end

-- Will try to find items in the registry chest
local function FindRegItems()
    local stockItems = {}

    local index = 1
    while true do
        local sProduct = iUtils.FirstItem(regChest, _, _, index, true, true)

        if sProduct == nil then 
            if index == 1 then 
                print("Insert a product item and a cost item") 
            end
            return
        end

        local sCost = iUtils.FirstItem(regChest, _, _, index + 1, true, true)
        if sCost == nil then print("Product " .. sProduct.displayName .. " is missing a cost item.") return end
        
        if sCost ~= nil then
            table.insert(stockItems, {product=sProduct,cost=sCost}) 
            index = index + 2
        end
    end

    return stockItems
end

-- *Stock meaning the idea of a product and a cost together

-- Add Item will check inside of the register chest in a 1 and 2, item and price fashion
-- Example Will find the first item inside of the register chest and mark that as the item to sell
-- And then will find the second item after the first item to mark as the cost of that product
-- With every finished whole stock* move to the next occupied slot and mark as a product and cost


-- Add any products into a product list thats numerically indexed and any of the product
-- costs into a symmetrically indexed product cost list
-- Will then ask which stock that were found to actually register
-- And then ask to specify amounts of these items being traded,
-- Example, if player added 1 diamond pickaxe and then 3 iron ingot in the register chest the amounts of that item are voided
-- and asked for specifically how much of each to avoid actually requiring the whole cost in order to register
local function AddItem()
    local stockItems = FindRegItems()
    if stockItems == nil then return end
    for key, stockItem in pairs(stockItems) do
        PrintExchange(stockItem.product, stockItem.cost)
        print()
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
