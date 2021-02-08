
local sides = {forward=0,right=1,back=2,left=3,up=4,down=5}
local strSides = {"forward", "right", "back","left", "up", "down"}

function sides.ToString(side)
    return strSides[side + 1]
end

return sides