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
        else table.insert(lineMin, 1) end
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
        return posX % maxX
    end

    local function Y()
        return posY % maxX
    end

    local function SetCursorPos(x, y)
        x = x or posX
        y = y or posY
        posX, posY = x - scrollX, y - scrollY
        term.setCursorPos(posX, posY)
    end

    local function Up()
        local rawY = RawY()
        local rawX = RawX()

        if rawY <= 1 then return end
        local upLineLength = #lines[rawY - 1]
        local upLineMin = lineMin[rawY - 1]
        if rawX < upLineMin then
            SetCursorPos(upLineMin, rawY - 1)
        elseif rawX > upLineLength then
            if rawX > maxX then SetScroll(upLineLength - scrollX) end
            SetCursorPos(upLineLength + 1, rawY - 1)
        else SetCursorPos(_, rawY - 1) end
    end

    local function Down()
        local rawY = RawY()
        local rawX = RawX()

        if rawY >= #lines then return end
        local downLineLength = #lines[rawY + 1]
        local downLineMin = lineMin[rawY + 1]
        if rawX < downLineMin then
            SetCursorPos(downLineMin, rawY + 1)
        end
        if rawX > downLineLength then
            if rawX > maxX then SetScroll(downLineLength - scrollX) end
            SetCursorPos(downLineLength + 1, posY + 1)
        else SetCursorPos(_, rawY + 1) end
    end

    local function Right()
        local rawY = RawY()
        local rawX = RawX()

        if rawX > #lines[rawY] then return end
        if posX == maxX then Scroll(1) 
        else
            term.setCursorPos(posX + 1, posY)
            posX = posX + 1
        end
    end

    local function Left()
        local rawY = RawY()
        local rawX = RawX()

        local thisLineMin = lineMin[rawY]
        if rawX <= thisLineMin then return end
        if posX == 1 then Scroll(-1)
        else
            term.setCursorPos(posX - 1, posY)
            posX = posX - 1
        end
    end

    local function Backspace()
        local rawY = RawY()
        local rawX = RawX()

        local line = lines[rawY]
        local minLine = lineMin[rawY]
        if rawX <= minLine then return end
        if rawX == #line + 1 then line = line:sub(1, #line-1)
        elseif rawX == minLine + 1 then line = line:sub(2)
        else line = line:sub(1, rawX - 2) .. line:sub(rawX) end
        lines[rawY] = line
        term.clearLine()
        term.setCursorPos(1, posY)
        Write(line)
        Left()
    end

    local function Delete()
        local rawY = RawY()
        local rawX = RawX()

        local line = lines[rawY]
        if rawX == #line+1 then return end
        if rawX == 1 then line = line:sub(2)
        elseif rawX == #line then line = line:sub(1, #line-1)
        else line = line:sub(1, rawX - 1) .. line:sub(rawX + 1) end
        lines[rawY] = line
        term.clearLine()
        term.setCursorPos(1, posY)
        Write(line)
        term.setCursorPos(posX, posY)
    end

    local function Type(char)
        local rawY = RawY()
        local rawX = RawX()

        local line = lines[rawY]
        if rawX == 1 then line = char .. line
        elseif rawX == #line + 1 then line = line .. char
        else line = line:sub(1, rawX - 1) .. char .. line:sub(rawX, #line) end
        lines[rawY] = line
        term.clearLine()
        term.setCursorPos(1, posY)
        Write(line)
        term.setCursorPos(posX, posY)
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