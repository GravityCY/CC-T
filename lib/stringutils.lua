local stringutils = {}

function stringutils.Capitalize(word)
    return word:gsub("(%l)(%w+)", function(a,b) return string.upper(a)..b end)
end

function stringutils.TableToString(table, startIndex, endIndex, seperator)
    startIndex = startIndex or 1
    endIndex = endIndex or #table
    seperator = seperator or " "
    local final = nil
    for index, word in ipairs(table) do
        if index >= startIndex and index <= endIndex then
            if final == nil then final = word
            else final = final .. seperator .. word end
        end
    end
    return final
end

function stringutils.StringToTable(string, startIndex, endIndex)
    startIndex = startIndex or 1
    endIndex = endIndex or #string
    
    local final = {}
    for word in string:sub(startIndex,endIndex):gmatch("%S+") do
        table.insert(final, word)
    end
    return final
end

return stringutils