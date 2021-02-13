local sUtils = require(".lib.stringutils")
local pUtils = require(".lib.periphutils")

local modem = pUtils.GetWifiModem()
rednet.open(peripheral.getName(modem))

local args = {...} -- file test yoloandshit.lua | exec -ow test arg ... | list -nbt diamond 1 16
if #args == 0 then print("Please add arguments.") return end
-- operator code < file exec > etc.
local op = args[1]

if op == "file" then
    if #args < 2 then print("Source file name argument missing.") return end
    if #args < 3 then print("Destination file name argument missing") return end

    local sFileN = args[#args-1]
    local dFileN = args[#args]
    local hops = args[2] or ""
    local path = shell.dir() .. "/" .. sFileN

    if not fs.exists(path) then print("No such file.") return end
    local file = fs.open(path, "r")
    msg = op .. " " .. hops .. " " .. dFileN .. "(_" .. file.readAll() .. "_) "
    file.close()
else
    msg = sUtils.TableToString(args)
end

local function ReceiveReply()
    local receive = false
    print("Reply Start: ")
    while true do
        local computerId, message
        if not receive then
            computerId, message = rednet.receive(_, 10)
            if computerId == nil or message == nil then break end
            receive = true 
        else
            computerId, message = rednet.receive(_, 10)
            if computerId == nil or message == nil then break end
        end
        print(" " .. message)
    end
    print(":Reply End")
end

term.clear()
term.setCursorPos(1,1)
print("Broadcasted message to all nearby rednet listeners.")
print("Awaiting reply...")
parallel.waitForAll(function() rednet.broadcast(msg) end, ReceiveReply)