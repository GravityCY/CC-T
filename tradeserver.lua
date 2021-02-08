local pUtils = require(".lib.periphutils")
local sUtils = require(".lib.stringutils")

local op_codes = {get_pseudo="gps", is_registered="rg?", register_terminal="+rt", register_product="+rp", get_stores="gs", get_products="gp"}

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
rednet.open(modemAddr)

local function GetID(pseudo)
    if pseudo == nil then return end
    return tonumber(settings.get(pseudo))
end

local function GetPseudo(id)
    if id == nil then return end
    if type(id) == "number" then id = tostring(id) end
    return settings.get(tostring(id))
end

local function IsRegistered(id)
    return GetPseudo(id) ~= nil
end

local function GetTerminalPath(stockholderID)
    local pseudo = GetPseudo(stockholderID)
    if pseudo == nil then return end
    return "/appdata/terminals/" .. pseudo
end

local function GetAllStores(asIds)
    asIds = asIds or false
    
    if asIds then
        local stores = {}
        for _, storePseudo in pairs(GetAllStoresID) do 
            table.insert(stores, GetID(storePseudo))
        end
        return stores
    else return fs.list("/appdata/terminals") end
end

local function GetAllProducts(stockholderID)
    if GetPseudo(stockholderID) == nil then return end
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

local function CountProducts(stockholderID)
    if GetPseudo(stockholderID) == nil then return end
    return #fs.list(GetTerminalPath(stockholderID))
end

local function RegisterID(stockholderID, pseudo)
    if stockholderID == nil or pseudo == nil then return end
    settings.set(tostring(stockholderID), pseudo)
    settings.set(pseudo, tostring(stockholderID))
    settings.save("/appdata/server/settings.gay")
end

-- Register a terminal on this server
local function RegisterTerminal(stockholderID, pseudo)
    if stockholderID == nil or pseudo == nil then return end
    RegisterID(stockholderID, pseudo)
    fs.makeDir("/appdata/terminals/" .. pseudo)
    print("Registering a terminal.")
end

-- Register stock under a registered terminal on this server
local function RegisterProduct(stockholderID, product)
    local pseudo = GetPseudo(stockholderID)
    if pseudo == nil or product == nil then return end
    local file = fs.open("/appdata/terminals/" .. pseudo .. "/" .. tostring(CountProducts(stockholderID)) .. ".prod", "w")
    file.write(textutils.serialise(product))
    file.close()
    print(stockholderID .. " (" .. pseudo .. ") registered a product.")
end 

-- Returns a list containing all the metadata stock of a stockholder excluding the actual stock data
-- Example 1 Diamond For 2 Iron Ingot, but does not return how much the stockholder actual has in stock of diamond
local function ListProductMeta(stockholderID)

end

-- Returns a list containing all stock data of a stockholder
-- Example 64 diamonds
-- Just practically returns all the stockholders items
local function SendProducts(requester, pseudoHolder)
    local idHolder = GetID(pseudoHolder)
    if requester == nil then return
    elseif idHolder == nil then rednet.send(requester, "nil", "gp") return end
    local prodFiles = GetAllProducts(idHolder)
    rednet.send(requester, textutils.serialise(prodFiles), "gp")
    print("Sending all " .. idHolder .. "'s (" .. pseudoHolder .. ") products to " .. requester)
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
        SendProducts(id, args[2])
    elseif op == op_codes.is_registered then
        rednet.send(id, tostring(IsRegistered(id)), "rg?")
    elseif op == op_codes.get_pseudo then
        rednet.send(id, GetPseudo(id), "gps")
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
    settings.clear()
    settings.load("/appdata/server/settings.gay")
end

Setup()
AwaitMessage()