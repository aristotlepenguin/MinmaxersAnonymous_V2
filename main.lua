local mod  = RegisterMod("MinmaxersAnonymous_V2", 1)

MMAMod = mod

local json = require("json")


mod.MMATypes = {}

mod.MMATypes.COLLECTIBLE_JUNGLE_GYM = Isaac.GetItemIdByName("Jungle Gym")
mod.MMATypes.COLLECTIBLE_RAIN_BUCKET = Isaac.GetItemIdByName("Rain Bucket")


mod.FloorSaves = {}
mod.MMA_GlobalSaveData = {}


local extrafiles = {
    "lua.jungleGym",
    "lua.rainBucket",
    "lua.saves",
    "lua.utils"
}
for i=1,#extrafiles do
    include(extrafiles[i])
end

