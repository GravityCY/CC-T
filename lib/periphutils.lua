local periphutils = {}

local prevFind = peripheral.find

local function PeriphIsSide(addr)
    return addr == "top" or addr == "left" or addr == "right" or addr == "bottom" or addr == "back" or addr == "front"
end

-- Will find all peripherals of the type peripheralName and call a method given
function periphutils.Call(peripheralName, method, ...)
    local periph = {peripheral.find(peripheralName)}
    for k,v in pairs(periph) do
        v[method](...)
    end
end

function periphutils.GetAnyModem()
    for _,side in ipairs({"top", "bottom", "front", "left", "right", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
        end
    end
end

function periphutils.GetWiredModem()
    for _,side in ipairs({"top", "bottom", "front", "left", "right", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
            if modem["getTypeRemote"] ~= nil then return modem end
        end
    end
end

function periphutils.GetWifiModem()
    for _,side in ipairs({"top", "bottom", "front", "left", "right", "back"}) do
        if peripheral.isPresent(side) and peripheral.getType(side) == "modem" then
            local modem = peripheral.wrap(side)
            if modem["getTypeRemote"] == nil then return modem end
        end
    end
end

function periphutils.ToAddrs(periphs)
    local addrs = {}
    for key, periph in pairs(periphs) do 
        table.insert(addrs, peripheral.getName(periph))
    end
    return addrs
end

function periphutils.Find(name, asAddr, notSide)
    if name == nil then return end
    asAddr = asAddr or false
    notSide = notSide or false
    
    local periphsAddr = peripheral.getNames()
    local found = {}

    for index, periphAddr in ipairs(periphsAddr) do
        local type = peripheral.getType(periphAddr)
        local toAdd = false
        if type == name then
            if notSide then 
                if not PeriphIsSide(periphAddr) then toAdd = true end
            else toAdd = true end
            if toAdd then
                if asAddr then table.insert(found, periphAddr)
                else table.insert(found, peripheral.wrap(periphAddr)) end
            end
        end
    end
    return unpack(found)
end

-- function periphutils.Find(name, notSide)
--     notSide = notSide or false
    
--     local found = {peripheral.find(name)}
    
--     local uFound = {}
--     local foundAddr = {}

--     for index, periph in ipairs(found) do
--         local addr = peripheral.getName(periph)
--         if foundAddr[addr] == nil then
--             if notSide then 
--                 if not PeriphIsSide(addr) then
--                     table.insert(uFound, periph)
--                     foundAddr[addr] = true
--                 end
--             else
--                 table.insert(uFound,periph)
--                 foundAddr[addr] = true
--             end
--         end
--     end
--     return unpack(uFound)
-- end

return periphutils