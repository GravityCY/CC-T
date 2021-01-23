local iUtils = require(".lib.invutils")

iUtils.PushAllMulti(peripheral.find("enderstorage:ender_chest"), iUtils.GetAllChests(), 64)

print("Stored all items into storage")