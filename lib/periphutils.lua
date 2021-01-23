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

function peripheral.find(name, notComputer)
    notComputer = notComputer or false
    
    local found = {prevFind(name)}
    
    local uFound = {}
    local foundAddr = {}

    for index, periph in ipairs(found) do
        local addr = peripheral.getName(periph)
        if not PeriphIsSide(addr) then
            if foundAddr[addr] == nil then
                table.insert(uFound, periph)
                foundAddr[addr] = true
            end
        end
    end
    return unpack(uFound)
end

return periphutils