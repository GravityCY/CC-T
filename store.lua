local iUtils = require(".lib.invutils")

iUtils.PushAllMulti(peripheral.find("enderstorage:ender_chest"), unpack(iUtils.GetAllChests()))

print("Stored all items into storage")