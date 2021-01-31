local pUtils = require(".lib.periphutils")
local sUtils = require(".lib.stringutils")

local op_codes = {register_terminal="+rt", register_product="+rp", get_stores="gs", get_products="gp"}

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
rednet.open(modemAddr)

local function GetId(pseudo)
    return tonumber(settings.get(pseudo))
end

local function GetPseudo(id)
    return settings.get(tostring(id))
end

local function GetTerminalPath(stockholderID)
    return "/appdata/terminals/" .. GetPseudo(stockholderID)
end

local function GetAllStores()
    return fs.list("/appdata/terminals")
end

local function GetAllStoresID()
    local stores = {}
    for _, storePseudo in pairs(GetAllStoresID) do 
        table.insert(stores, GetId(storePseudo))
    end
end

local function GetAllProducts(stockholderID)
    local terminalPath = GetTerminalPath(stockholderID)
    local products = {}
    for index, productPath in pairs(fs.list(terminalPath)) do
        local prodFile = fs.open(terminalPath .. "/" .. productPath, "r")
        local prodData = prodFile.readAll()
        local product = textutils.unserialise(prodData)
        table.insert(products, product)
        prodFile.close()
    end
    return products
end

-- Remember to disallow sending items to the same id 
local function RegisterId(registreeID, pseudo)
    settings.set(tostring(registreeID), pseudo)
    settings.set(pseudo, tostring(registreeID))
    settings.save("/appdata/server/settings.gay")
end

-- Register a terminal on this server
local function RegisterTerminal(registreeID, pseudo)
    RegisterId(registreeID, pseudo)
    fs.makeDir("/appdata/terminals/" .. pseudo)
    print("Registering a terminal")
end

-- Register stock under a registered terminal on this server
local function RegisterProduct(stockholderID, product)
    local pseudo = GetPseudo(stockholderID)
    
    local file = fs.open("/appdata/terminals/" .. pseudo .. "/" .. tostring(#GetAllProducts(stockholderID)) .. ".prod", "w")
    file.write(textutils.serialise(product))
    file.close()
    print("Registered a product")
end 

-- Returns a list containing all the metadata stock of a stockholder excluding the actual stock data
-- Example 1 Diamond For 2 Iron Ingot, but does not return how much the stockholder actual has in stock of diamond
local function ListProductMeta(stockholderID)

end

-- Returns a list containing all stock data of a stockholder
-- Example 64 diamonds
-- Just practically returns all the stockholders items
local function SendProducts(to, stockholderID)
    local prodFiles = GetAllProducts(stockholderID)
    rednet.send(to, textutils.serialise(prodFiles), "gp")
    print("Sending all " .. stockholderID .. "'s products to " .. to)
end

local function SendStores(to)
    rednet.send(to, textutils.serialise(GetAllStores()), "gs")
    print("Sending all stores to " .. to)
end

-- The act of a trade starts with the requester asking the server for if the stockholder has enough stock for the amount requested
-- Then if so the server will then request the requester to the place the product cost * amount, of the cost in his ender chest
-- And then tell the stockholder to be ready to add the item from the ender chest it to his sales chest
local function Trade(requester, stockholder, product, amount)

end



local function ProcessMessage(id, message)
    local args = sUtils.StringToTable(message)
    local op = args[1]
    if op == op_codes.register_terminal then
        RegisterTerminal(id, args[2])
    elseif op == op_codes.register_product then
        RegisterProduct(id, textutils.unserialise(message:match("{.+}")))
    elseif op == op_codes.get_stores then
        SendStores(id)
    elseif op == op_codes.get_products then
        SendProducts(id, GetId(args[2]))
    end
end

local function AwaitMessage()
    while true do
        local computer, message = rednet.receive("ts")
        print("Received message...")
        ProcessMessage(computer, message)
    end
end

local function Setup()
    fs.makeDir("/appdata/server")
    fs.makeDir("/appdata/terminals")
end

Setup()
AwaitMessage()