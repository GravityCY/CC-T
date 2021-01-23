local debug = {}
debug.print = false

local function PrintTable(table)
    for k,v in pairs(table) do
        local vType = type(v)
        if vType == "function" then print("K: " .. k .. " Function")
        elseif vType == "table" then print("K: " .. k .. " Table")
        elseif(vType == "boolean") then print("K: " .. k .. " V: " .. tostring(v))
        else print("K: " .. k .. " V: " .. v) end
    end
end

function print(...)
    if not print then return end
    local args = {...}
    if args == nil or #args == 0 then return end

    local bit1 = args[1]
    local message = nil
    if type(bit1) == "boolean" then bit1 = tostring(bit1) end
    if type(bit1) ~= "table" then message = bit1 addedToMessage = 1
    else PrintTable(bit1) end
    for i = 2, #args do
        local bit = args[i]
        if type(bit) ~= "table" then
            if type(bit) == "boolean" then bit = tostring(bit) end
            if message ~= nil then message = message .. " " .. bit
            else message = bit end
        else PrintTable(bit) end
    end
    if message ~= nil then write(message .. "\n") end
end

return debug