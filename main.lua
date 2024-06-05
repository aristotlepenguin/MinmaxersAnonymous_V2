local mod  = RegisterMod("MinmaxersAnonymous_v2", 1)

MMAMod = mod

mod.DEBUG = false
mod.SINGLE_ITEM = false

local hiddenItemManager = require("lib.hidden_item_manager")
mod.ItemGrabCallback = include("lua.inventory_callbacks")

hiddenItemManager:Init(mod)

local DSSInitializerFunction = include("lib.DSSMenu")
DSSInitializerFunction(mod)


mod.MMATypes = {}

mod.MMATypes.CHARACTER_EPAPHRAS = Isaac.GetPlayerTypeByName("Epaphras")
mod.MMATypes.CHARACTER_EPAPHRAS_B = Isaac.GetPlayerTypeByName("Tainted Epaphras", true)

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
mod.MMATypes.COLLECTIBLE_D_SQRT =  Isaac.GetItemIdByName("D-Sqrt(-1)")

mod.MMATypes.CARD_CHASTITY = Isaac.GetCardIdByName("ChastityCard")

mod.MMATypes.COSTUME_FIRE_OVERCLOCK = Isaac.GetCostumeIdByPath("gfx/characters/tantrum_face.anm2")
mod.MMATypes.COSTUME_HYPERFIXATION = Isaac.GetCostumeIdByPath("gfx/characters/hyperfixation_costume.anm2")
mod.MMATypes.COSTUME_JOBSCURSE_1 = Isaac.GetCostumeIdByPath("gfx/characters/job_curse_head.anm2")
mod.MMATypes.COSTUME_JOBSCURSE_2 = Isaac.GetCostumeIdByPath("gfx/characters/job_curse_foot.anm2")
mod.MMATypes.COSTUME_BUCKET_HEAD = Isaac.GetCostumeIdByPath("gfx/characters/bucket_head.anm2")
mod.MMATypes.COSTUME_MINNIE_HAIR = Isaac.GetCostumeIdByPath("gfx/characters/minnie_hair.anm2")

mod.MMATypes.CHALLENGE_SCORE_ASSAULT = Isaac.GetChallengeIdByName("Road to One Million")

mod.MMATypes.SOUND_ACHIEVE_SA = Isaac.GetSoundIdByName("AchieveSA")

mod.FloorSaves = {}
mod.MMA_GlobalSaveData = {}


local ItemTranslate = include("lib.translation.ItemTranslation")
ItemTranslate("MinmaxersAnonymous_V2")

local translations = {
    "ru",
}
for i=1,#translations do
    local module = include("lib.translation." .. translations[i])
    module(mod)
end

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
    "lua.dsqrroot",
    "lua.scoreAssaultChallenge",
    "lua.eid",
    "lua.misc"
}
for i=1,#extrafiles do
    include(extrafiles[i])
end

