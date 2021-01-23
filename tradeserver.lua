local pUtils = require(".lib.periphutils")

local modem = pUtils.GetWifiModem()
local modemAddr = peripheral.getName(modem)
print(modemAddr)
rednet.open(modemAddr)

-- Remember to disallow sending items to the same id 

-- Register a terminal on this server
local function RegisterTerminal(id, pseudo)

end

-- Register stock under a registered terminal on this server
local function RegisterStock(stockholder, product, cost)
    
end 

-- Returns a list containing all the metadata stock of a stockholder excluding the actual stock data
-- Example 1 Diamond For 2 Iron Ingot, but does not return how much the stockholder actual has in stock of diamond
local function ListStockMeta(stockholder)

end

-- Returns a list containing all stock data of a stockholder
-- Example 64 diamonds
-- Just practically returns all the stockholders items
local function ListStock(stockholder)

end

local function StockAmount(product)

end

-- The act of a trade starts with the requester asking the server for if the stockholder has enough stock for the amount requested
-- Then if so the server will then request the requester to the place the product cost * amount, of the cost in his ender chest
-- And then tell the stockholder to be ready to add the item from the ender chest it to his sales chest
local function Trade(requester, stockholder, product, amount)

end

local function ProcessMessage(message)
    local op = message:sub(1,1)
    print(op)
end

local function AwaitMessage()
    while true do
        local computer, message = rednet.receive("ts")
        ProcessMessage(message)
    end
end

AwaitMessage()