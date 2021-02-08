local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local oUtils = require(".lib.osutils")
local pUtils = require(".lib.periphutils")
local sUtils = require(".lib.stringutils")
local termUtils = require(".lib.termutils")

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
rednet.open(modemAddr)

local cmds = {"add", "trade", "reg_prod", "edit_unreg", "count_stock", "list_unreg", "list_stores", "list_prod"}

local cmdEx = {add_product=1, trade= 2, register_product= 3, edit_unregistered= 4, count_stock= 5, list_unregistered= 6, list_stores= 7, list_products= 8}

local edit_input = {prod_id="pid", cost_id="cid", prod_amount="pamount", cost_amount="camount"}
local regChest = peripheral.wrap("top")
local serverID = 5

local registered = false
local storeName = nil

local xSize, ySize = term.getSize()

local unregistered_products = {}

local function AwaitRequest()
    while true do
        local event, message = rednet.receive("tr")
        print(event, message)
    end
end

local function SaveSettings()
    settings.save("/appdata/trade/data.gay")
end

local function Register(stockholder)
    rednet.send(serverID, "+rt " .. stockholder, "ts")
    registered = true
    settings.set("registered", true)
    SaveSettings()
end

local function RegisterInterface()
    termUtils.BlitLine("Welcome to TTOS, please register your terminal.", colors.blue)
    while true do
        termUtils.Blit("Type an name for your store:", colors.black, colors.white)
        write(" ")
        local input = read()
        while true do
            termUtils.BlitLine("Are you sure you want to register " .. input .. " as your store name / alias. Y/N", colors.red)
            local sure = read():lower()
            if sure == "y" then 
                storeName = input
                Register(input) 
                term.clear()
                term.setCursorPos(1,1)
                settings.set("store_name", input)
                settings.save("/appdata/terminal/settings.gay")
                return
            elseif sure == "n" then break end
        end
    end

end

local function PrintHelp()
    print("-- Commands --")
    for index, command in pairs(cmds) do
        print(command)
    end
end

local function StringifyProduct(product)
    local str = ""

    str = str .. "Product: \\READONLY\n" 
    str = str .. "  ID = \\READONLY" .. product.name .. "\n"
    str = str .. "  Amount = \\READONLY" .. product.count .. "\n"

    str = str .. "Cost: \\READONLY\n" 
    str = str .. "  ID = \\READONLY" .. product.cost.name .. "\n"
    str = str .. "  Amount = \\READONLY" .. product.cost.count .. "\n"
    return str
end

local function UnstringifyProduct(product, str)
    local lines = {}
    for strng in str:gmatch("[^\n]+") do
        table.insert(lines, strng)
    end
    product.name = lines[2]:sub(8)
    product.count = tonumber(lines[3]:sub(12))
    product.cost.name = lines[5]:sub(8)
    product.cost.count = tonumber(lines[6]:sub(12))

    return product
end

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

local function Trade(stockholder, productID, amount)
    amount = amount or 1

    term.clear()
    term.setCursorPos(1,1)
    
    if stockholder == nil then termUtils.BlitLine("Please enter the name of the store.\n", colors.red) return
    elseif productID == nil then termUtils.BlitLine("Please enter the id of the product.\n", colors.red) return end
end

local function GetProducts(stockholder)
    rednet.send(serverID, "gp " .. stockholder, "ts")
    local id, products = rednet.receive("gp", 1)
    if id == nil then return "error" end
    if products == "nil" then return "nil" end
    if products == "{}" then return "empty" end
    return textutils.unserialise(products)
end

local function ProductToItem(product)
    local item = {}
    for key, value in pairs(product) do
        if key ~= "cost" then item[key] = value end
    end
    return item
end

local function GetStock(productID)
    local products = GetProducts(storeName)
    if productID > #products then return "invalid" end
    return iUtils.CountItem(ProductToItem(products[productID]), true, iUtils.GetAllChests(false, true))
end

local function PrintStock(productID)
    term.clear()
    term.setCursorPos(1,1)
    if productID == nil then return end
    if type(productID) ~= "number" then productID = tonumber(productID) end
    if productID == nil then termUtils.BlitLine("Product ID has to be a number.\n", colors.red) return end
    if productID < 1 then termUtils.BlitLine("No such product ID.\n", colors.red) return end
    local stock = GetStock(productID)
    if stock == "invalid" then termUtils.BlitLine("No such product ID.\n", colors.red) return end
    termUtils.BlitLine("Your store has " .. stock .. " of product ID #" .. productID .. ".\n", colors.green)
end

-- prints the product and the cost
local function PrintTransaction(product, detail)
    if detail then 
        term.clear()
        term.setCursorPos(1,1)
        termUtils.Blit("Product: ", colors.blue)
        PrintItem(product)
        termUtils.Blit("Cost: ", colors.blue)
        PrintItem(product.cost)
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
        write(product.count .. " " .. iUtils.ToDisplayName(product.name)  .. pEnchants)
        termUtils.Blit(" For ", colors.red)
        write(product.cost.count .. " "  .. iUtils.ToDisplayName(product.cost.name) .. cEnchants)
    end
    print()
end

local function ToProduct(productItem, costItem)
    productItem.cost = costItem
    return productItem 
end

local function PrintProducts(products, detail, reverse)
    for index, product in ipairs(products) do
        termUtils.Blit("Prod #" .. index, colors.black, colors.white)
        write(" ")
        PrintTransaction(product, detail, reverse)
    end
    write("\n")
end

local function PrintStores(stores)
    for index, storeName in ipairs(stores) do
        termUtils.Blit("Store #" .. index, colors.black, colors.white)
        write(": ")
        termUtils.Blit(storeName, colors.green)
        write("\n")
    end
    write("\n")
end

local function ListProducts(stockholder)
    if stockholder == nil then stockholder = storeName end
    local products = GetProducts(stockholder)
    term.clear()
    term.setCursorPos(1,1)
    if products == "error" then termUtils.BlitLine("Conversation with server unreached.", colors.red) return end
    if products == "nil" then termUtils.BlitLine(stockholder .. " does not exist.\n", colors.red) return end
    if products == "empty" then termUtils.BlitLine(stockholder .. " does not have any registered products.\n", colors.red) return end
    termUtils.BlitLine("Listing products of " .. stockholder .. "...", colors.orange)
    PrintProducts(products, false, true)
end

local function ListStores()
    rednet.send(serverID, "gs", "ts")
    local id, stores = rednet.receive("gs", 1)
    term.clear()
    term.setCursorPos(1,1)
    if id == nil then termUtils.BlitLine("Conversation with server unreached.", colors.red) return end
    termUtils.BlitLine("Listing stores...", colors.orange)
    PrintStores(textutils.unserialise(stores))
end

local function EditProduct(unregistered, id, args)
    unregistered = unregistered or true

    term.clear()
    term.setCursorPos(1,1)

    if id == nil then termUtils.BlitLine("You need to enter an ID.\n", colors.red) return
    elseif type(id) ~= "number" then termUtils.BlitLine("ID needs to be a number.\n", colors.red)return end

    if unregistered then
        if id >= 1 and id <= #unregistered_products then
            local product = unregistered_products[id]
            if args[1] == nil then termUtils.BlitLine("No arguments present\n", colors.red) return end
            local command = args[1]:lower()
            if command == edit_input.prod_id then
                if args[2] == nil then termUtils.BlitLine("Please input an id to change the product to.", colors.red) return end
                local prevName = product.name
                product.name = args[2]
                termUtils.BlitLine("Changed product id from " .. prevName .. " to " .. product.name, colors.green)
            elseif command == edit_input.cost_id then
                if args[2] == nil then termUtils.BlitLine("Please input an id to change the product to.", colors.red) return end
                local prevName = product.cost.name
                product.cost.name = args[2]
                termUtils.BlitLine("Changed cost id from " .. prevName .. " to " .. product.cost.name, colors.green)
            elseif command == edit_input.prod_amount then
                if args[2] == nil then termUtils.BlitLine("Please input an amount to change the product to.", colors.red) return end
                local prevAmount = product.count
                product.count = tonumber(args[2])
                termUtils.BlitLine("Changed product (" .. iUtils.ToDisplayName(product.name) .. ") amount from " .. prevAmount .. " to " .. product.count, colors.green)
            elseif command == edit_input.cost_amount then
                if args[2] == nil then termUtils.BlitLine("Please input an amount to change the product to.", colors.red) return end
                local prevAmount = product.cost.count
                product.cost.count = tonumber(args[2])
                termUtils.BlitLine("Changed cost (" .. iUtils.ToDisplayName(product.cost.name) .. ") amount from " .. prevAmount .. " to " .. product.cost.count, colors.green)
            else
                termUtils.BlitLine("No such command", colors.red)
            end
        else termUtils.BlitLine("ID does not exist.", colors.red) end
    end
    write("\n")
end

local function EditProductGUI(unregistered, id)
    unregistered = unregistered or true
    if id == nil then return end

    if unregistered then
        if id >= 1 and id <= #unregistered_products then
            local product = unregistered_products[id]
            product = UnstringifyProduct(product, termUtils.Edit(StringifyProduct(product)))
        else termUtils.BlitLine("ID does not exist.", colors.red) end
    end
end

local function RegisterProduct(id)
    term.clear()
    term.setCursorPos(1,1)

    if id == nil then termUtils.BlitLine("You need to enter a product ID.\n", colors.red) return
    elseif type(id) ~= "number" then termUtils.BlitLine("ID needs to be a number.\n", colors.red) return end
    if id < 1 or id > #unregistered_products then termUtils.BlitLine("No such ID.\n", colors.red) return end

    local product = unregistered_products[id]
    local pString = textutils.serialise(product)
    rednet.send(serverID, "+rp " .. " " .. pString, "ts")
    unregistered_products[id] = nil

    termUtils.BlitLine("Registered product with id " .. id .. ".\n", colors.green)
end

-- Will try to find items in series in the registry chest
local function FindRegItems()
    local productItems = {}

    local index = 1
    while true do
        local sProduct = iUtils.FirstItem(regChest, _, _, index, true, true)

        if sProduct == nil then 
            if index == 1 then return 
            else break end
        end

        local sCost = iUtils.FirstItem(regChest, _, _, index + 1, true, true)
        if sCost == nil then 
            termUtils.Blit("Product ", colors.red)
            termUtils.Blit(iUtils.ToDisplayName(sProduct.name), colors.white) 
            termUtils.BlitLine(" is missing a cost item.", colors.red) 
            return 
        end
        
        if sCost ~= nil then
            table.insert(productItems, ToProduct(sProduct, sCost)) 
            index = index + 2
        end
    end

    return productItems
end

-- Method
    -- *Product meaning the idea of a product and a cost together

    -- Add Item will check inside of the register chest in a 1 and 2, item and price fashion
    -- Example Will find the first item inside of the register chest and mark that as the product to sell
    -- And then will find the second item after the first item to mark as the cost of that product
    -- With every finished whole stock* move to the next occupied slot and mark as a product and cost

    -- Add any products into a product list thats numerically indexed and any of the product
    -- costs into a symmetrically indexed product cost list
    -- Will then ask which stock that were found to actually register
    -- And then ask to specify amounts of these items being traded,
    -- Example, if player added 1 diamond pickaxe and then 3 iron ingot in the register chest the amounts of that item are voided
    -- and asked for specifically how much of each to avoid actually requiring the whole cost in order to register
--
local function AddProduct()
    local products = FindRegItems()
    if products == nil then 
        termUtils.BlitLine("Insert a product item and a cost item", colors.red)
        return 
    end

    unregistered_products = products
    
    term.clear()
    term.setCursorPos(1,1)

    termUtils.BlitLine("Adding products...", colors.orange)

    for index, product in pairs(products) do
        write("Added ")
        termUtils.Blit(iUtils.ToDisplayName(product.name), colors.red)
        write(" to unregistered items.\n") 
    end
    write("\n")
end

local function Interface()
    termUtils.BlitLine("Welcome aboard TTOS :)", colors.green)
    while true do
        PrintHelp()
        local input = sUtils.StringToTable(read())
        local command = input[1]
        if command == cmds[cmdEx.add_product] then
            AddProduct()
        elseif command == cmds[cmdEx.register_product ]then
            local numInput = tonumber(input[2])
            RegisterProduct(numInput)
        elseif command == cmds[cmdEx.list_unregistered] then
            term.clear()
            term.setCursorPos(1,1)
            termUtils.BlitLine("Listing unregistered products...", colors.orange)
            PrintProducts(unregistered_products, false, false)
        elseif command == cmds[cmdEx.edit_unregistered] then
            local id = tonumber(input[2])
            local editArgs = tUtils.Range(input, 3)
            EditProduct(true, id, editArgs)
        elseif command == cmds[cmdEx.list_stores] then
            ListStores()
        elseif command == cmds[cmdEx.list_products] then
            ListProducts(input[2])
        elseif command == cmds[cmdEx.trade] then
            Trade(input[2], input[3], input[4])
        elseif command == cmds[cmdEx.count_stock] then
            PrintStock(input[2])
        else
            term.clear()
            term.setCursorPos(1,1)
            termUtils.BlitLine("No such command.\n", colors.red)
        end
    end
end

local function Setup()
    settings.clear()
    settings.load("/appdata/terminal/settings.gay")
    rednet.send(serverID, "rg?", "ts")
    registered = ({rednet.receive("rg?")})[2] == "true"
    if not registered then RegisterInterface() 
    else storeName = settings.get("store_name") end
    if storeName == nil then rednet.send(serverID, "gps", "ts") _,storeName = rednet.receive("gps") end
    Interface()
end

term.clear()
term.setCursorPos(1,1)

parallel.waitForAll(Setup, AwaitRequest)
