local sUtils = require(".lib.stringutils")

local termutils = {}

function termutils.Blit(text, textColor, backColor)
    textColor = textColor or colors.white
    backColor = backColor or colors.black
    
    local maxX, maxY = term.getSize()
    local termX, termY = term.getCursorPos()
    if termX >= maxX or termX + #text >= maxX then term.setCursorPos(1, termY+1) end
    local colorText = ""
    local backText = ""
    for i = 1, #text do
        colorText = colorText .. colors.toBlit(textColor)
        backText = backText .. colors.toBlit(backColor)
    end
    term.blit(text, colorText, backText)
end

function termutils.BlitLine(text, textColor, backColor)
    termutils.Blit(text,textColor,backColor)
    write("\n")
end

function termutils.Edit(text)
    term.clear()
    term.setCursorPos(1,1)

    write(text:gsub("\\READONLY", ""))

    local lines = {}                                                                                                                        
    local min = {}
    for str in text:gmatch("[^\n]+") do
        local readOnly = str:find("\\READONLY")
        if readOnly ~= nil then
            table.insert(min, readOnly)
            str=str:gsub("\\READONLY", "")
        end
        table.insert(lines, str)
    end

    local x, y = term.getCursorPos()
    local maxX, maxY = term.getSize()

    local function GetMinX(index)
        local min = min[index]
        if min == nil then return 1 end
        return min
    end

    local function GetMinY()
        return 1
    end

    local function GetMaxX()
        return maxX
    end

    local function GetMaxY()
        return maxY
    end

    local function Up()
        if y - 1 < GetMinY() then return end
        local upLineLength = #lines[y - 1]
        if x > upLineLength then
            term.setCursorPos(upLineLength + 1, y - 1) 
            x = upLineLength + 1
        elseif x < GetMinX(y - 1) then
            local pos = GetMinX(y - 1)
            term.setCursorPos(pos, y - 1)
            x = pos
        else term.setCursorPos(x, y - 1) end
        y = y - 1
    end

    local function Down()
        if y + 1 > GetMaxY() or y + 1 > #lines then return end
        local downLineLength = #lines[y + 1]
        if x > downLineLength then
            term.setCursorPos(downLineLength + 1, y + 1) 
            x = downLineLength + 1
        elseif x < GetMinX(y + 1) then
            local pos = GetMinX(y + 1)
            term.setCursorPos(pos, y + 1)
            x = pos
        else term.setCursorPos(x, y + 1) end
        y = y + 1
    end

    local function Right()
        if x + 1 > GetMaxX() or x + 1 > #lines[y] + 1 then return end
        term.setCursorPos(x + 1,y)
        x = x + 1
    end

    local function Left()
        if x - 1 < GetMinX(y) then return end
        term.setCursorPos(x - 1,y)
        x = x - 1
    end

    local function Backspace()
        local line = lines[y]
        local minLine = GetMinX(y)
        if line == nil or line == "" or x == minLine then return end
        if x == #line+1 then line = line:sub(1, #line-1)
        else line = line:sub(1, x - 2) .. line:sub(x, #line) end
        lines[y] = line
        term.clearLine()
        term.setCursorPos(1,y)
        write(line)
        Left()
    end

    local function Delete()
        local line = lines[y]
        if line == nil or line == "" or x == #line+1 then return end
        if x == 1 then line = line:sub(2)
        elseif x == #line then line = line:sub(1, #line-1)
        else line = line:sub(1, x - 1) .. line:sub(x + 1, #line) end
        lines[y] = line
        term.clearLine()
        term.setCursorPos(1,y)
        write(line)
        term.setCursorPos(x,y)
    end

    local function Type(char)
        local line = lines[y]
        if x == GetMinX() then line = char .. line
        elseif x == #line+1 then line = line .. char
        else line = line:sub(1, x - 1) .. char .. line:sub(x, #line) end
        lines[y] = line
        term.clearLine()
        term.setCursorPos(1,y)
        write(line)
        term.setCursorPos(x,y)
        Right()
    end

    while true do
        term.setCursorBlink(true)
        local event, arg1, arg2 = os.pullEvent()
        if event == "char" then
            Type(arg1)
        elseif event == "key" then
            if arg1 == keys.up then Up() end
            if arg1 == keys.right then Right() end
            if arg1 == keys.down then Down() end
            if arg1 == keys.left then Left() end
            if arg1 == keys.enter then break end
            if arg1 == keys.backspace then Backspace() end
            if arg1 == keys.delete then Delete() end
        end
    end

    term.clear()
    term.setCursorPos(1,1)
    return sUtils.TableToString(lines, _, _, true)
end

return termutils