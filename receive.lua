local pUtils = require(".lib.periphutils")
local hUtils = require(".lib.hackerman")

local modem = pUtils.GetWifiModem()
rednet.open(peripheral.getName(modem))

-- message == -ow test.lua (_do print("gay") end_)
local function WriteFile(message)
    print("Writing received file...")
    local ow = false 
    local sFlStr = message:find("%(%_")+2
    local eFlStr = message:find("%_%)")-1
    local flStr = message:sub(sFlStr,eFlStr)
    local words = {}
    for word in message:sub(1,sFlStr-4):gmatch("%S+") do
        table.insert(words, word)
    end
    local programName = words[2]

    if words[1] == "-ow" then ow = true end
    if not ow and fs.exists(programName) then print("File already exists.") return end

    local file = fs.open(programName, "w")
    file.write(flStr)
    file.close()
    print("Wrote file " .. programName .. ".")
end

local function Execute(message, computerId)
local printCode = 
[[local prevPrint = print
function print(...) 
    rednet.send(]] .. computerId .. [[, ...) 
    prevPrint(...) 
end
]]
    local path = message:match("%S+")
    local args = message:sub(#path+2)
    local absPath = shell.dir() .. "/" .. path
    local possiblePath = shell.resolveProgram(path)
    if possiblePath ~= nil then absPath = possiblePath end
    local source = hUtils.ReadSource(absPath)
    hUtils.InjectCode(absPath, printCode)
    shell.run(path, args)
    hUtils.RevertToSource(absPath, source)
end

local function Terminate()
    print("Terminating receiver...")
    error()
end

local function ProcessMessage(message, computerId)
    if message == nil then return end

    local op = message:match("%S+"):lower()
    local justMessage = message:sub(#op+2)

    if op == "term" then
        Terminate()
    end

    if justMessage == nil or #justMessage == 0 then return end
    -- file test.lua (file text)
    if op == "file" then
        WriteFile(justMessage)
    end
    -- exec test.lua arg arg ...
    if op == "exec" then
        Execute(justMessage, computerId)
    end
end

local function AwaitMessage()
    print("\nAwaiting Message...")
    local id, msg, protocol = rednet.receive()
    computerId = id
    print("Received Message..")
    ProcessMessage(msg, computerId)
end

while true do
    AwaitMessage()
end