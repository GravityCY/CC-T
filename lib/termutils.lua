local sUtils = require(".lib.stringutils")

local termutils = {}

local maxX, maxY = term.getSize()


function termutils.Blit(text, textColor, backColor)
    textColor = textColor or colors.white
    backColor = backColor or colors.black
    local prevTextColor = term.getTextColor()
    local prevBackColor = term.getBackgroundColor()
    term.setTextColor(textColor)
    term.setBackgroundColor(backColor)
    write(text)
    term.setTextColor(prevTextColor)
    term.setBackgroundColor(prevBackColor)
end

function termutils.BlitLine(text, textColor, backColor)
    termutils.Blit(text,textColor,backColor)
    write("\n")
end

function termutils.Edit(text)
    term.clear()
    term.setCursorPos(1,1)

    local lines = {}                                                                                                                        
    local lineMin = {}
    local posX, posY = term.getCursorPos()
    local maxX, maxY = term.getSize()
    local scrollX, scrollY = 0, 0
    for str in text:gmatch("[^\n]+") do
        local minX = str:find("\\READONLY")
        if minX ~= nil then
            table.insert(lineMin, minX)
            str=str:gsub("\\READONLY", "")
        end
        table.insert(lines, str)
    end

    local function Write(str)
        write(str:sub(scrollX + 1, maxX + scrollX))
    end

    local function WriteLine(str)
        write(str:sub(scrollX + 1, maxX + scrollX) .. "\n")
    end

    local function UpdateLines()
        term.clear()
        term.setCursorPos(1,1)
        for index, line in ipairs(lines) do
            if index >= scrollY and index <= maxY then
                WriteLine(line)
            end
        end
        term.setCursorPos(posX, posY)
    end

    local function SetScroll(x,y)
        x = x or scrollX
        y = y or scrollY

        if x < 0 then x = 0 end
        if y < 0 then y = 0 end

        scrollX, scrollY = x, y

        UpdateLines()
    end

    local function Scroll(x,y)
        x = x or 0
        y = y or 0

        SetScroll(scrollX + x, scrollY + y)        
        UpdateLines()
    end

    local function RawX()
        return posX + scrollX
    end

    local function RawY()
        return posY + scrollY
    end 

    local function X()
        return posX
    end

    local function Y()
        return posY
    end

    local function SetCursorPos(x,y)
        x = x or X()
        y = y or Y()
        SetScroll(X() - maxX, Y() - maxY)
        posX, posY = x - scrollX, y - scrollY
        term.setCursorPos(X(), Y())
    end

    local function Up()
        if RawY() - 1 < 1 then return end
        local upLineLength = #lines[RawY() - 1]
        local upLineMin = lineMin[RawY() - 1]
        if upLineMin ~= nil and RawX() < upLineMin then
            SetCursorPos(upLineMin, Y() - 1)
        end
        if RawX() > upLineLength then
            SetCursorPos(upLineLength + 1, Y() - 1)
        else SetCursorPos(_, Y() - 1) end
    end

    local function Down()
        if RawY() + 1 > #lines then return end
        local downLineLength = #lines[RawY() + 1]
        local downLineMin = lineMin[RawY() + 1]
        if downLineMin ~= nil and RawX() < downLineMin then
            SetCursorPos(downLineMin, RawY() + 1)
        end
        if RawX() > downLineLength then
            SetCursorPos(downLineLength + 1, posY + 1)
        else SetCursorPos(_, RawY() + 1) end
    end

    local function Right()
        if RawX() > #lines[RawY()] then return end
        if X() == maxX then Scroll(1) 
        else
            term.setCursorPos(X() + 1, Y())
            posX = X() + 1
        end
    end

    local function Left()
        local lineMin = lineMin[RawY()]
        if RawX() - 1 < 1 or (lineMin ~= nil and RawX() == lineMin) then return end
        if posX == 1 then Scroll(-1)
        else
            term.setCursorPos(posX - 1, posY)
            posX = posX - 1
        end
    end

    local function Backspace()
        local line = lines[RawY()]
        local minLine = lineMin[RawY()]
        if line == "" or (minLine ~= nil and RawX() == minLine) then return end
        if RawX() == #line + 1 then line = line:sub(1, #line-1)
        else line = line:sub(1, RawX() - 2) .. line:sub(RawX(), #line) end
        lines[RawY()] = line
        term.clearLine()
        term.setCursorPos(1, posY)
        Write(line)
        Left()
    end

    local function Delete()
        local line = lines[RawY()]
        if line == "" or RawX() == #line+1 then return end
        if RawX() == 1 then line = line:sub(2)
        elseif RawX() == #line then line = line:sub(1, #line-1)
        else line = line:sub(1, RawX() - 1) .. line:sub(RawX() + 1, #line) end
        lines[RawY()] = line
        term.clearLine()
        term.setCursorPos(1, RawY())
        Write(line)
        term.setCursorPos(RawX(), RawY())
    end

    local function Type(char)
        local line = lines[RawY()]
        if RawX() == 1 then line = char .. line
        elseif RawX() == #line + 1 then line = line .. char
        else line = line:sub(1, RawX() - 1) .. char .. line:sub(RawX(), #line) end
        lines[RawY()] = line
        term.clearLine()
        term.setCursorPos(1, Y())
        Write(line)
        term.setCursorPos(X(), Y())
        Right()
    end

    posX = lineMin[1]
    UpdateLines()

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