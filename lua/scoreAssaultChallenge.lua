local mod = MMAMod
local game = Game()


function mod:refreshTotalScore_SA()
    local data = mod.MMA_GlobalSaveData
    data.TotalAssaultScore = (data.TotalStatScore or 0) + --check total stats
    (data.TotalCollectibleScore or 0) + --checks held items
    (data.TotalBonusScore or 0) --other scoring mechanics that aren't adjusted after earning them
end

local qualTable = {
    [0] = 1000,
    [1] = 3000,
    [2] = 5000,
    [3] = 7000,
    [4] = 10000
}

function mod:refreshItems_SA()
    local itemScore = 0
    local recalc = false
    mod:AnyPlayerDo(function(player)
        local pdata = mod:mmaGetPData(player)
        if player:GetCollectibleCount() ~= pdata.LastCollectibleCount then
            recalc = true
        end
    end)
    if recalc then
        mod:AnyPlayerDo(function(player)
            local pdata = mod:mmaGetPData(player)
            pdata.LastCollectibleCount = player:GetCollectibleCount()
            local itemConfig = Isaac.GetItemConfig()
            for itemID=1, itemConfig:GetCollectibles().Size-1 do
                local item = itemConfig:GetCollectible(itemID)
                if item and item.Type ~= ItemType.ITEM_ACTIVE and player:HasCollectible(itemID, true) then
                    local qualityMult = qualTable[item.Quality]
                    itemScore = itemScore + (qualityMult * player:GetCollectibleNum(itemID))
                end
            end
        end)
    end

    if itemScore > 0 then
        mod.MMA_GlobalSaveData.TotalCollectibleScore = itemScore
        mod:refreshTotalScore_SA()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.refreshItems_SA)

local baseStats = {
    Range = 0,
    FireDelay = 0,
    Damage = 0,
    Speed = 0,
    Luck = 0
}

local tearMultiplier = 1
local damageMultiplier = 1
local speedMultiplier = 1
local luckMultiplier = 1
local rangeMultiplier = 1

function mod:refreshStats_SA(_player, cacheflag)
    local statScore = 0
    mod:AnyPlayerDo(function(player)
        statScore = statScore + ((player.TearRange-baseStats.Range) * rangeMultiplier)
        statScore = statScore + ((player.Luck-baseStats.Luck) * luckMultiplier)
        statScore = statScore + ((baseStats.FireDelay-player.MaxFireDelay) * tearMultiplier)
        statScore = statScore + ((player.Damage-baseStats.Damage) * damageMultiplier)
        statScore = statScore + ((player.MoveSpeed-baseStats.Speed) * speedMultiplier)
    end)
    mod.MMA_GlobalSaveData.TotalStatScore = statScore
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.refreshStats_SA)

local masterPickupScoreList = {}
masterPickupScoreList[PickupVariant.PICKUP_COIN] = {}
masterPickupScoreList[PickupVariant.PICKUP_KEY] = {}
masterPickupScoreList[PickupVariant.PICKUP_BOMB] = {}
masterPickupScoreList[PickupVariant.PICKUP_HEART] = {}
masterPickupScoreList[PickupVariant.PICKUP_POOP] = {}
masterPickupScoreList[PickupVariant.PICKUP_LIL_BATTERY] = {}

local backupPickups = {
    [PickupVariant.PICKUP_COIN] = 0,
    [PickupVariant.PICKUP_KEY] = 0,
    [PickupVariant.PICKUP_BOMB] = 0,
    [PickupVariant.PICKUP_POOP] = 0,
    [PickupVariant.PICKUP_HEART] = 0,
    [PickupVariant.PICKUP_POOP] = 0,
    [PickupVariant.PICKUP_LIL_BATTERY] = 0
}

function mod:trackPickups_SA(pickup, collider, low)
    if pickup:GetSprite():GetAnimation() == "Collect" and not pickup:GetData().MMA_ItemTouched then
        local scoreIt = 0
        if pickup.Variant == PickupVariant.PICKUP_COIN or
        pickup.Variant == PickupVariant.PICKUP_KEY or
        pickup.Variant == PickupVariant.PICKUP_BOMB or
        pickup.Variant == PickupVariant.PICKUP_HEART or
        pickup.Variant == PickupVariant.PICKUP_POOP or
        pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
            pickup:GetData().MMA_ItemTouched = true
            scoreIt = masterPickupScoreList[pickup.Variant][pickup.SubType] or backupPickups[pickup.Variant] or 50
        end
        mod.MMA_GlobalSaveData.TotalBonusScore = (mod.MMA_GlobalSaveData.TotalBonusScore or 0) + scoreIt
        mod:refreshTotalScore_SA()
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.trackPickups_SA)