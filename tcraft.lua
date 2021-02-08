local modem = peripheral.find("modem")
local modemAddr = peripheral.getName(modem)
modem.open(1)

while true do
    local event, periph, _, _, message = os.pullEvent("modem_message")
    if periph == modemAddr then
        local success = turtle.craft()
        modem.transmit(1, 1, tostring(success))
    end
end