local tableutils = {}

function tableutils.SizeOf(tab)
    local s = 0
    for k,v in pairs(tab) do
        s = s + 1
    end
    return s
end

function tableutils.AddKeyValue(tab, key, value)
    tab[key] = value
end

function tableutils.ContainsKey(tab, key)
    return tab[key] ~= nil
end

function tableutils.GetNotThis(tab, ...)
    local notThese = table.ToKeyTable({...})
    for k,v in pairs(tab) do
        if not table.ContainsKey(notThese, v) then return v end
    end
end

function tableutils.ToKeyTable(tab, value)
    value = value or true
    local keyTab = {}
    for k,v in pairs(tab) do
        keyTab[v] = value
    end
    return keyTab
end

function tableutils.Range(tab, from, to)
    from = from or 1
    to = to or #tab

    local newTab = {}
    for index, value in ipairs(tab) do
        if index >= from and index <= to then table.insert(newTab, value) end
    end
    return newTab
end

return tableutils