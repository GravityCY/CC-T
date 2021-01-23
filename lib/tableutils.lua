function table.SizeOf(tab)
    local s = 0
    for k,v in pairs(tab) do
        s = s + 1
    end
    return s
end

function table.AddKeyValue(tab, key, value)
    tab[key] = value
end

function table.ContainsKey(tab, key)
    return tab[key] ~= nil
end

function table.GetNotThis(tab, ...)
    local notThese = table.ToKeyTable({...})
    for k,v in pairs(tab) do
        if not table.ContainsKey(notThese, v) then return v end
    end
end

function table.ToKeyTable(tab, value)
    value = value or true
    local keyTab = {}
    for k,v in pairs(tab) do
        keyTab[v] = value
    end
    return keyTab
end