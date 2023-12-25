local mod  = RegisterMod("MinmaxersAnonymous_V2", 1)

MMAMod = mod

mod.MMATypes = {}

mod.MMATypes.COLLECTIBLE_JUNGLE_GYM = Isaac.GetItemIdByName("Jungle Gym")
mod.MMATypes.COLLECTIBLE_RAIN_BUCKET = Isaac.GetItemIdByName("Rain Bucket")
mod.MMATypes.COLLECTIBLE_ABSTINENCE = Isaac.GetItemIdByName("Abstinence")
mod.MMATypes.COLLECTIBLE_MEMORY_LEAK = Isaac.GetItemIdByName("Memory Leak")

mod.MMATypes.CARD_CHASTITY = Isaac.GetCardIdByName("ChastityCard")

mod.FloorSaves = {}
mod.MMA_GlobalSaveData = {}


local extrafiles = {
    "lua.jungleGym",
    "lua.rainBucket",
    "lua.saves",
    "lua.utils",
    "lua.abstinence"
}
for i=1,#extrafiles do
    include(extrafiles[i])
end

