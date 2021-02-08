local iUtils = require(".lib.invutils")
local pUtils = require(".lib.periphutils")

local args = {...}

local chests = iUtils.GetAllChests(false, true)

local cTurtle = peripheral.find("turtle")
local cTurtleAddr = peripheral.getName(cTurtle)

local modem = pUtils.GetWiredModem()
local modemAddr = peripheral.getName(modem)
modem.open(1)

local function RegisterRecipe()
    local recipe = {out=tonumber(args[3])}
    local recipeName = args[2]
    for i = 4, #args do
        local str = args[i]
        local index = tonumber(str:match("%d+"))
        local itemName = str:match("[^%d=].+")
        recipe[index] = itemName
    end
    local file = fs.open("/appdata/craft/recipes/" .. recipeName, "w")
    file.write(textutils.serialise(recipe))
    file.close()
end

local function PullFromTurtle(amount)
    local pulled = 0
    for i = 1, 16 do
        for index, chest in ipairs(chests) do
            pulled = pulled + chest.pullItems(cTurtleAddr, i, 64)
            if pulled >= amount then return end
        end
    end
end

local function Craft(recipeName, amount)
    amount = amount or 1

    local path = "/appdata/craft/recipes/" .. recipeName
    if not fs.exists(path) then print("No such recipe.") return end
    local file = fs.open(path, "r")
    local recipe = textutils.unserialise(file.readAll())
    local output = recipe.out
    for i = 1, math.ceil(amount / output) do 
        for tIndex, itemName in pairs(recipe) do
            if type(tIndex) ~= "number" then break end
            local addr, slot = iUtils.GetItemSlot(itemName, chests)
            if addr == nil then print("Out of materials.") return end
            peripheral.wrap(addr).pushItems(cTurtleAddr, slot, 1, tIndex)
        end
        modem.transmit(1, 1)
        local event, periph, _, _, message = os.pullEvent("modem_message")
        if message == "true" then 
            PullFromTurtle(output)
            print("Craft Successful")
        else print("Craft unsuccessful.") end
    end
end

fs.makeDir("/appdata/craft/recipes")

if #args ~= 0 then
    if args[1] == "register" then RegisterRecipe()
    else Craft(args[1], args[2]) end
end