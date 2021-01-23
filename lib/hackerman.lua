local hackerManUtils = {}

function hackerManUtils.ReadSource(path)
    local tempPath = nil

    if not path:find(".lua") then tempPath = path..".lua"
    else tempPath = path end

    if fs.exists(tempPath) then
        local readFile = fs.open(tempPath, "r")
        local source = readFile.readAll()
        readFile.close()
        return source
    end
end

-- Injects code into the start of a file
function hackerManUtils.InjectCode(path, code)
    local tempPath = nil
    
    if not path:find(".lua") then tempPath = path..".lua"
    else tempPath = path end

    if fs.exists(tempPath) then
        local readFile = fs.open(tempPath, "r")
        local source = readFile.readAll()
        readFile.close()
        local writeFile = fs.open(tempPath, "w")
        if writeFile == nil then return false end
        writeFile.write(code..source)
        writeFile.close()
        return true
    end
    return false
end

function hackerManUtils.RevertToSource(path, source)
    local tempPath = nil
    
    if not path:find(".lua") then tempPath = path..".lua"
    else tempPath = path end
    
    if fs.exists(tempPath) then
        local writeFile = fs.open(tempPath, "w")
        if writeFile == nil then return false end
        writeFile.write(source)
        writeFile.close()
        return true
    end
    return false
end

return hackerManUtils