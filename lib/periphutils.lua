local periphutils = {}

local prevFind = peripheral.find

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

function peripheral.find(name)
    local found = prevFind(name)

    local uFound = {}
    local foundAddr = {}

    for index, periph in ipairs(found) do
        local addr = peripheral.getName(periph)
        if foundAddr[addr] == nil then
            table.insert(uFound, periph)
            foundAddr[addr] = true
        end
    end
    return uFound
end

return periphutils