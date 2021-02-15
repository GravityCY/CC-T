local dumpInvSize = 9

while true do
    local stockInventories = {peripheral.find("minecraft:chest")}
    local dumpInventories = {peripheral.find("minecraft:dispenser")}
    local totalStock = 0
    for key, stockInventory in pairs(stockInventories) do
        for slot, item in pairs(stockInventory.list()) do
            totalStock = totalStock + item.count
        end
    end
    
    if totalStock >= #dumpInventories * dumpInvSize then
        print("Splitting.")
        local split = totalStock / #dumpInventories
        for _, inventory in pairs(dumpInventories) do
            local sent = 0
            local localSplit = math.floor(split / inventory.size())   
            for i = 1, inventory.size() do
                local localSent = 0
                while true do
                    entered = false
                    for _, stockInventory in pairs(stockInventories) do
                        local stockAddr = peripheral.getName(stockInventory)
                        for slot in pairs(stockInventory.list()) do
                            entered = true
                            localSent = localSent + inventory.pullItems(stockAddr, slot, localSplit-localSent, i)
                        end
                    end
                    if not entered or localSent >= localSplit then break end
                end
                sent = sent + localSent
                if sent >= split then break end
            end
        end
    end
    print("Sleeping...") 
    os.sleep(5)
end