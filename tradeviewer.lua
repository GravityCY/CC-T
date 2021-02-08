local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local sUtils = require(".lib.stringutils")
local pUtils = require(".lib.periphutils")
local termUtils = require(".lib.termutils")

local modem = pUtils.GetWifiModem()
rednet.open(peripheral.getName(modem))

local commands = {list_stores="list_stores", list_prod="list_prod"}

local serverID = 5

local function PrintItem(item, compact)
    compact = compact or false
    if compact then 
        -- Blit("ID:", "eee", "fff")
        -- write(" " .. item.name.. " ")
        termUtils.Blit("Name:", colors.red)
        write(" " .. iUtils.ToDisplayName(item.name) .. " ")
        termUtils.Blit("Amount:", colors.red)
        print(" " .. item.count)
        if item.enchantments ~= nil then
            termUtils.Blit("Enchants:", colors.red)
            write(" { " .. item.enchantments[1].displayName)
            for i = 2, #item.enchantments do
                write(", " .. item.enchantments[i].displayName)
            end
            write("} ")
        end
        if item.damage ~= nil then
            termUtils.Blit("Durability:", colors.red)
            write(" " .. item.maxDamage - item.damage)
        end
        write("\n")
    else
        -- Blit("ID:", "eee", "fff")
        -- print(" " .. item.name)
        termUtils.Blit("Name:", colors.red)
        print(" " .. iUtils.ToDisplayName(item.name))
        termUtils.Blit("Amount:", colors.red)
        print(" " .. item.count)
        if item.enchantments ~= nil then
            termUtils.Blit("Enchants:", colors.red)
            write(" { " .. item.enchantments[1].displayName)
            for i = 2, #item.enchantments do
                write(", " .. item.enchantments[i].displayName)
            end
            print("} ")
        end
        if item.damage ~= nil then
            termUtils.Blit("Durability:", colors.red)
            print(" " .. item.maxDamage - item.damage)
        end
    end
end

-- prints the product and the cost
local function PrintTransaction(product, detail, reverse)
    local prod = nil
    local cost = nil
    if reverse then
        prod = product.cost
        cost = product
    else
        prod = product
        cost = product.cost
    end

    if detail then 
        term.clear()
        term.setCursorPos(1,1)
        termUtils.Blit("Product: ", colors.blue)
        PrintItem(prod)
        termUtils.Blit("Cost: ", colors.blue)
        PrintItem(cost)
    else
        local pEnchants = ""
        local cEnchants = ""

        if product.enchantments ~= nil then
            pEnchants = " (With Enchants)"
        end
        if product.cost.enchantments ~= nil then
            cEnchants = " (With Enchants)"
        end
        
        termUtils.Blit("Give ", colors.red)
        write(prod.count .. " " .. iUtils.ToDisplayName(prod.name)  .. pEnchants)
        termUtils.Blit(" For ", colors.red)
        write(cost.count .. " "  .. iUtils.ToDisplayName(cost.name) .. cEnchants)
    end
    write("\n")
end

local function PrintProducts(products, detail, reverse)
    term.clear()
    term.setCursorPos(1,1)
    for index, product in ipairs(products) do
        termUtils.Blit("Prod #" .. index, colors.black, colors.white)
        write(" ")
        PrintTransaction(product, detail, reverse)
    end
    write("\n")
end

local function PrintStores(stores)
    term.clear()
    term.setCursorPos(1,1)
    for index, storeName in ipairs(stores) do
        termUtils.Blit("Store #" .. index, colors.black, colors.white)
        write(": ")
        termUtils.Blit(storeName, colors.green)
        write("\n")
    end
    write("\n")
end

local function ListProducts(pseudo)
    rednet.send(serverID, "gp " .. pseudo, "ts")
    local id, products = rednet.receive("gp")
    PrintProducts(textutils.unserialise(products), false, true)
end

local function ListStores()
    rednet.send(serverID, "gs", "ts")
    local id, stores = rednet.receive("gs")
    PrintStores(textutils.unserialise(stores))
end

local function PrintHelp()
    print("-- Commands --")
    for _, command in pairs(commands) do
        print(command)
    end
end

local function Interface()
    termUtils.BlitLine("Welcome to TTSOS", colors.green)

    while true do
        PrintHelp()
        local input = sUtils.StringToTable(read())
        local command = input[1]
        if command == commands.list_stores then
            ListStores()
        elseif command == commands.list_prod then
            ListProducts(input[2])
        end
    end
end

Interface()
