local mod  = RegisterMod("MinmaxersAnonymous_v2", 1)

MMAMod = mod

local hiddenItemManager = require("lib.hidden_item_manager")
mod.ItemGrabCallback = include("lua.inventory_callbacks")

hiddenItemManager:Init(mod)

mod.MMATypes = {}

mod.MMATypes.CHARACTER_EPAPHRAS = Isaac.GetPlayerTypeByName("Epaphras")
mod.MMATypes.CHARACTER_EPAPHRAS_B = Isaac.GetPlayerTypeByName("Tainted Epaphras")

mod.MMATypes.COLLECTIBLE_JUNGLE_GYM = Isaac.GetItemIdByName("Jungle Gym")
mod.MMATypes.COLLECTIBLE_RAIN_BUCKET = Isaac.GetItemIdByName("Rain Bucket")
mod.MMATypes.COLLECTIBLE_ABSTINENCE = Isaac.GetItemIdByName("Abstinence")
mod.MMATypes.COLLECTIBLE_MEMORY_LEAK = Isaac.GetItemIdByName("Memory Leak")
mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS = Isaac.GetItemIdByName("Isaac's Hopes and Dreams")
mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS = Isaac.GetItemIdByName("Dad's Sneakers")
mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES = Isaac.GetItemIdByName("Overclocked Sinuses")
mod.MMATypes.COLLECTIBLE_HYPERFIXATION =  Isaac.GetItemIdByName("Hyperfixation")
mod.MMATypes.COLLECTIBLE_MOMS_SCALE =  Isaac.GetItemIdByName("Mom's Scale")
mod.MMATypes.COLLECTIBLE_JOBS_CURSE =  Isaac.GetItemIdByName("Job's Curse")

mod.MMATypes.CARD_CHASTITY = Isaac.GetCardIdByName("ChastityCard")

mod.MMATypes.COSTUME_FIRE_OVERCLOCK = Isaac.GetCostumeIdByPath("gfx/characters/tantrum_face.anm2")

mod.FloorSaves = {}
mod.MMA_GlobalSaveData = {}


local extrafiles = {
    "lua.jungleGym",
    "lua.rainBucket",
    "lua.saves",
    "lua.utils",
    "lua.abstinence",
    "lua.hopesAndDreams",
    "lua.dadSneakers",
    "lua.overclockedSinuses",
    "lua.hyperfixation",
    "lua.momsScale",
    "lua.jobsCurse",
    "lua.memoryLeak",
    "lua.scoreAssaultChallenge",
    "lua.eid"
}
for i=1,#extrafiles do
    include(extrafiles[i])
end

