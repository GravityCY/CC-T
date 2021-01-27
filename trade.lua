local iUtils = require(".lib.invutils")
local tUtils = require(".lib.tableutils")
local oUtils = require(".lib.osutils")
local pUtils = require(".lib.periphutils")
local sUtils = require(".lib.stringutils")
local termUtils = require(".lib.termutils")

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
rednet.open(modemAddr)

local commands = {add="add_product", register_terminal="register", list_unreg="list_unreg", edit_unreg="edit_unreg"}
local edit_input = {pid="pid", cid="cid", pamount="pamount", camount="camount"}
local regChest = peripheral.wrap("top")
local serverID = 5

local xSize, ySize = term.getSize()

local unregistered_products = {}
local function PrintHelp()
    print("-- Commands --")
    for _, command in pairs(commands) do
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
        write(" " .. item.displayName .. " ")
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
        print(" " .. item.displayName)
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
        write(product.count .. " " .. product.displayName  .. pEnchants)
        termUtils.Blit(" For ", colors.red)
        write(product.cost.count .. " "  .. product.cost.displayName .. cEnchants)
    end
    print()
end

local function ToProduct(productItem, costItem)
    productItem.cost = costItem
    return productItem 
end

local function List(unregistered, detail)
    unregistered = unregistered or true
    detail = detail or false
    if unregistered then
        print("Listing unregisted items...")
        for index, product in ipairs(unregistered_products) do
            termUtils.Blit("Product #" .. index, colors.black, colors.white)
            write(" ")
            PrintTransaction(product, detail)
        end
    end
end

local function EditProduct(unregistered, id, args)
    unregistered = unregistered or true
    if id == nil then return end

    if unregistered then
        if id >= 1 and id <= #unregistered_products then
            
        else termUtils.BlitLine("ID does not exist.", colors.red) end
    end
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

local function RegisterProduct(product)
    print("Registered Product.")
    local pString = textutils.serialise(product)
    rednet.send(serverID, "+ " .. os.getComputerID() .. " " .. pString, "ts")
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
            termUtils.Blit(sProduct.displayName, colors.white) 
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
    for index, product in pairs(products) do
        write("Added ")
        termUtils.Blit(product.displayName, colors.red)
        write(" to unregistered items.\n") 
    end
end

local function Interface()
    while true do
        PrintHelp()
        print()
        local input = sUtils.StringToTable(read())
        local command = input[1]
        if command == commands.add then
            AddProduct()
        elseif command == commands.register_terminal then
            RegisterTerminal()
        elseif command == commands.list_unreg then
            List(true, false)
        elseif command == commands.edit_unreg then
            local id = tonumber(input[2])
            local editArgs = tUtils.Range(input, 3)
            if id == nil then EditProductGUI(true, SelectProduct(true))
            elseif type(id) == "number" then EditProductGUI(true, id)
            else termUtils.BlitLine("ID needs to be a number") end
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
