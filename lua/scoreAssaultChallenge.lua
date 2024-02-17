local mod = MMAMod
local game = Game()


function mod:refreshTotalScore_SA()
    local data = mod.MMA_GlobalSaveData
    data.TotalAssaultScore = (data.TotalStatScore or 0) + --check total stats
    (data.TotalCollectibleScore or 0) + --checks held items
    (data.TotalBonusScore or 0) --other scoring mechanics that aren't adjusted after earning them

    if data.ScoreAssaultSprite then
        local score = data.TotalAssaultScore or 0
        local scorelength = math.max(string.len(tostring(data.TotalAssaultScore)), 9)
        for j=1, scorelength, 1 do
            local digit = score % 10
            data.ScoreAssaultSprite:SetLayerFrame(9-(j), digit)
            score = math.floor(score/10)
        end
    end
end

local function checkIfAchieved(key)
    if mod.MMA_GlobalSaveData.ScoreAssaultAchievements == nil then
        mod.MMA_GlobalSaveData.ScoreAssaultAchievements = {}
    end
    return mod.MMA_GlobalSaveData.ScoreAssaultAchievements[key] ~= nil
end

function mod:renderScore()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT and mod.MMA_GlobalSaveData.ScoreAssaultSprite then
        local data = mod.MMA_GlobalSaveData
        data.ScoreAssaultSprite:LoadGraphics()
        local renderpos = Vector(math.floor(Isaac.GetScreenWidth()/2), math.floor(Isaac.GetScreenHeight()/2))
        data.ScoreAssaultSprite:Render(renderpos)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.renderScore)


local qualTable = {
    [0] = 1000,
    [1] = 3000,
    [2] = 5000,
    [3] = 7000,
    [4] = 10000
}

function mod:refreshItems_SA()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then

        if not mod.MMA_GlobalSaveData.ScoreAssaultSprite then
            mod.MMA_GlobalSaveData.ScoreAssaultSprite = Sprite()
            mod.MMA_GlobalSaveData.ScoreAssaultSprite:Load("gfx/ui/score_indicator.anm2", true)
            mod.MMA_GlobalSaveData.ScoreAssaultSprite:Play("NumbersRed")
        end

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
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local statScore = 0
        mod:AnyPlayerDo(function(player)
            statScore = statScore + math.floor((player.TearRange-baseStats.Range) * rangeMultiplier)
            statScore = statScore + math.floor((player.Luck-baseStats.Luck) * luckMultiplier)
            statScore = statScore + math.floor((baseStats.FireDelay-player.MaxFireDelay) * tearMultiplier)
            statScore = statScore + math.floor((player.Damage-baseStats.Damage) * damageMultiplier)
            statScore = statScore + math.floor((player.MoveSpeed-baseStats.Speed) * speedMultiplier)
        end)
        mod.MMA_GlobalSaveData.TotalStatScore = statScore
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.refreshStats_SA)

local masterPickupScoreList = {}
masterPickupScoreList[PickupVariant.PICKUP_COIN] = {
    [CoinSubType.COIN_PENNY] = 5,
    [CoinSubType.COIN_NICKEL] = 5,
    [CoinSubType.COIN_DIME] = 5,
    [CoinSubType.COIN_DOUBLEPACK] = 5,
    [CoinSubType.COIN_LUCKYPENNY] = 5,
    [CoinSubType.COIN_STICKYNICKEL] = 5,
    [CoinSubType.COIN_GOLDEN] = 5
}
masterPickupScoreList[PickupVariant.PICKUP_KEY] = {
    [KeySubType.KEY_NORMAL] = 5,
    [KeySubType.KEY_DOUBLEPACK] = 5,
    [KeySubType.KEY_CHARGED] = 5,
    [KeySubType.KEY_GOLDEN] = 5
}
masterPickupScoreList[PickupVariant.PICKUP_BOMB] = {
    [BombSubType.BOMB_NORMAL] = 5,
    [BombSubType.BOMB_DOUBLEPACK] = 5,
    [BombSubType.BOMB_GOLDEN] = 5,
    [BombSubType.BOMB_SUPERTROLL] = 5,
    [BombSubType.BOMB_GOLDENTROLL] = 5,
    [BombSubType.BOMB_GIGA] = 5,
    [BombSubType.BOMB_TROLL] = 5
}
masterPickupScoreList[PickupVariant.PICKUP_HEART] = {
    [HeartSubType.HEART_FULL] = 5,
    [HeartSubType.HEART_HALF] = 5,
    [HeartSubType.HEART_SOUL] = 5,
    [HeartSubType.HEART_ROTTEN] = 5,
    [HeartSubType.HEART_BONE] = 5,
    [HeartSubType.HEART_DOUBLEPACK] = 5,
    [HeartSubType.HEART_GOLDEN] = 5,
    [HeartSubType.HEART_BLACK] = 5,
    [HeartSubType.HEART_HALF_SOUL] = 5,
    [HeartSubType.HEART_SCARED] = 5,
    [HeartSubType.HEART_BLENDED] = 5,
    [HeartSubType.HEART_ETERNAL] = 5
}
masterPickupScoreList[PickupVariant.PICKUP_POOP] = {
    [PoopPickupSubType.POOP_SMALL] = 5,
    [PoopPickupSubType.POOP_BIG] = 5
}
masterPickupScoreList[PickupVariant.PICKUP_LIL_BATTERY] = {
    [BatterySubType.BATTERY_NORMAL] = 5,
    [BatterySubType.BATTERY_MICRO] = 5,
    [BatterySubType.BATTERY_MEGA] = 5,
    [BatterySubType.BATTERY_GOLDEN] = 5
}

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
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
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
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.trackPickups_SA)

local errorRoomBonus = 50000

function mod:getRoomBonus()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local room = game:GetRoom()
        if room:GetType() == RoomType.ROOM_ERROR and checkIfAchieved("errorRoom") == false then
            mod.MMA_GlobalSaveData.ScoreAssaultAchievements["errorRoom"] = true
            mod.MMA_GlobalSaveData.TotalBonusScore = (mod.MMA_GlobalSaveData.TotalBonusScore or 0) + errorRoomBonus
        end
    end
    mod:refreshTotalScore_SA()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.getRoomBonus)