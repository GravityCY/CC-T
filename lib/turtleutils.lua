local turtleutils = {}

function turtleutils.Refuel()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item ~= nil and item.name == "minecraft:coal" then
            turtle.select(i)
            turtle.refuel(64)
        end
    end
end

return turtleutils