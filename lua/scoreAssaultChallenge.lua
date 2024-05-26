local mod = MMAMod
local game = Game()
local hud = game:GetHUD()
local sfx = SFXManager()

local digitLayer = {
    [0] = 9,
    [1] = 8,
    [2] = 7,
    [3] = 6,
    [4] = 5,
    [5] = 0,
    [6] = 1,
    [7] = 2,
    [8] = 3

}

function mod:refreshTotalScore_SA()
    local data = mod.MMA_GlobalSaveData
    data.TotalAssaultScore = (data.TotalStatScore or 0) + --check total stats
    (data.TotalCollectibleScore or 0) + --checks held items
    (data.TotalBonusScore or 0) --other scoring mechanics that aren't adjusted after earning them
    
    if data.ScoreAssaultSprite then
        local score = data.TotalAssaultScore or 0
        local scorelength = math.max(string.len(tostring(data.TotalAssaultScore)), 9)
        for j=0, scorelength-1, 1 do
            local digit = score % 10
            data.ScoreAssaultSprite:SetLayerFrame(digitLayer[j], digit)
            score = math.floor(score/10)
        end
    end
end

function mod:checkIfAchieved(key)
    if mod.MMA_GlobalSaveData.ScoreAssaultAchievements == nil then
        mod.MMA_GlobalSaveData.ScoreAssaultAchievements = {}
    end
    return mod.MMA_GlobalSaveData.ScoreAssaultAchievements[key] ~= nil
end

function mod:renderScore()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT and mod.MMA_GlobalSaveData.ScoreAssaultSprite then
        local data = mod.MMA_GlobalSaveData
        data.ScoreAssaultSprite:LoadGraphics()
        local renderpos = Vector(math.floor(Isaac.GetScreenWidth()/2), 35)
        if game:GetHUD():IsVisible() then
            data.ScoreAssaultSprite:Render(renderpos)
            --print(data.TotalAssaultScore)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.renderScore)


local qualTable = {
    [0] = 5000,
    [1] = 7000,
    [2] = 15000,
    [3] = 25000,
    [4] = 50000
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
    Range = 200,
    FireDelay = 10,
    Damage = 3.5,
    Speed = 1.1,
    Luck = 0
}

local tearMultiplier = 10000
local damageMultiplier = 7690
local speedMultiplier = 55555
local luckMultiplier = 10000
local rangeMultiplier = 139

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
        mod:refreshTotalScore_SA()
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.refreshStats_SA)

local masterPickupScoreList = {}
local bps = 100 --base pickup score
masterPickupScoreList[PickupVariant.PICKUP_COIN] = {
    [CoinSubType.COIN_PENNY] = bps,
    [CoinSubType.COIN_NICKEL] = bps * 5,
    [CoinSubType.COIN_DIME] = bps * 10,
    [CoinSubType.COIN_DOUBLEPACK] = bps * 2,
    [CoinSubType.COIN_LUCKYPENNY] = bps,
    [CoinSubType.COIN_STICKYNICKEL] = bps * 5,
    [CoinSubType.COIN_GOLDEN] = bps * 2
}
masterPickupScoreList[PickupVariant.PICKUP_KEY] = {
    [KeySubType.KEY_NORMAL] = bps * 2,
    [KeySubType.KEY_DOUBLEPACK] = bps * 4,
    [KeySubType.KEY_CHARGED] = bps * 4,
    [KeySubType.KEY_GOLDEN] = bps * 35
}
masterPickupScoreList[PickupVariant.PICKUP_BOMB] = {
    [BombSubType.BOMB_NORMAL] = bps * 2,
    [BombSubType.BOMB_DOUBLEPACK] = bps * 4,
    [BombSubType.BOMB_GOLDEN] = bps * 35,
    [BombSubType.BOMB_SUPERTROLL] = 0,
    [BombSubType.BOMB_GOLDENTROLL] = 0,
    [BombSubType.BOMB_GIGA] = bps * 5,
    [BombSubType.BOMB_TROLL] = 0
}
masterPickupScoreList[PickupVariant.PICKUP_HEART] = {
    [HeartSubType.HEART_FULL] = bps * 2,
    [HeartSubType.HEART_HALF] = bps,
    [HeartSubType.HEART_SOUL] = bps * 2,
    [HeartSubType.HEART_ROTTEN] = bps,
    [HeartSubType.HEART_BONE] = bps * 5,
    [HeartSubType.HEART_DOUBLEPACK] = bps * 4,
    [HeartSubType.HEART_GOLDEN] = bps * 5,
    [HeartSubType.HEART_BLACK] = bps * 4,
    [HeartSubType.HEART_HALF_SOUL] = bps,
    [HeartSubType.HEART_SCARED] = bps * 2,
    [HeartSubType.HEART_BLENDED] = bps * 2,
    [HeartSubType.HEART_ETERNAL] = bps * 5
}
masterPickupScoreList[PickupVariant.PICKUP_POOP] = {
    [PoopPickupSubType.POOP_SMALL] = bps,
    [PoopPickupSubType.POOP_BIG] = bps * 4
}
masterPickupScoreList[PickupVariant.PICKUP_LIL_BATTERY] = {
    [BatterySubType.BATTERY_NORMAL] = bps * 3,
    [BatterySubType.BATTERY_MICRO] = bps,
    [BatterySubType.BATTERY_MEGA] = bps * 10,
    [BatterySubType.BATTERY_GOLDEN] = bps * 5
}

local backupPickups = {
    [PickupVariant.PICKUP_COIN] = 1,
    [PickupVariant.PICKUP_KEY] = 2,
    [PickupVariant.PICKUP_BOMB] = 2,
    [PickupVariant.PICKUP_POOP] = 1,
    [PickupVariant.PICKUP_HEART] = 1,
    [PickupVariant.PICKUP_LIL_BATTERY] = 1
}

function mod:trackPickups_SA(pickup, collider, low)
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        if not pickup:GetData().MMA_ItemTouched then --pickup:GetSprite():GetAnimation() == "Collect" and
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

        if pickup.Variant == PickupVariant.PICKUP_TROPHY and (not mod.MMA_GlobalSaveData.TotalAssaultScore or mod.MMA_GlobalSaveData.TotalAssaultScore < 1000000) then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
            pickup:Remove()
            sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, Options.SFXVolume*2)
            hud:ShowItemText('MILLIONAIRES ONLY', 'Try again next time...', false)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.trackPickups_SA)


function mod:applyAchievement(key, score, name, description)
    if not mod.MMA_GlobalSaveData.ScoreAssaultAchievements then
        mod.MMA_GlobalSaveData.ScoreAssaultAchievements = {}
    end
    mod.MMA_GlobalSaveData.ScoreAssaultAchievements[key] = true
    mod.MMA_GlobalSaveData.TotalBonusScore = (mod.MMA_GlobalSaveData.TotalBonusScore or 0) + score
    local descString = description .. " +" .. tostring(score)
    mod:refreshTotalScore_SA()
    hud:ShowItemText(name, descString, false)
    sfx:Play(mod.MMATypes.SOUND_ACHIEVE_SA, Options.SFXVolume*2)
end


local ultraSecretBonus = 50000

local rockBreakKey = {
[GridEntityType.GRID_ROCK] = 1,
[GridEntityType.GRID_ROCKT] = 5000,
[GridEntityType.GRID_ROCK_BOMB] = 5,
[GridEntityType.GRID_ROCK_ALT] = 500,
[GridEntityType.GRID_POOP] = 5,
[GridEntityType.GRID_ROCK_SS] = 10000,
[GridEntityType.GRID_ROCK_SPIKED] = 1,
[GridEntityType.GRID_ROCK_ALT2] = 500,
[GridEntityType.GRID_ROCK_GOLD] = 500
}

function mod:getRoomBonus()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local room = game:GetRoom()
        if room:GetType() == RoomType.ROOM_ERROR and mod:checkIfAchieved("errorRoom") == false then
            mod:applyAchievement("errorRoom", 50000, "I am error", "Find an error room")
        elseif room:GetType() == RoomType.ROOM_ULTRASECRET and mod:checkIfAchieved("ultraSecret") == false then
            mod:applyAchievement("ultraSecret", 50000, "Ultra secret", "Find an Ultra Secret Room")
        end
        mod:refreshTotalScore_SA()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.getRoomBonus)

function mod:scoreAssaultRockBreak(rocktype)
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local score
        if rockBreakKey[rocktype] == nil then
            score = 1
        else
            score = rockBreakKey[rocktype]
        end
        mod.MMA_GlobalSaveData.TotalBonusScore = (mod.MMA_GlobalSaveData.TotalBonusScore or 0) + score
        mod:refreshTotalScore_SA()
    end
end


function mod:scoreAssaultPickupCalc()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local pickupList = Isaac.FindByType(5)

        local floorItems = 0
        mod:AnyPlayerDo(function(player)
            floorItems = floorItems + player:GetCollectibleCount()
        end)

        if #pickupList > 250 and mod:checkIfAchieved("maxedPickups") == false then
            mod:applyAchievement("maxedPickups", 70000, "Packed Room", "Fill a room with pickups")
        elseif floorItems - (mod.MMA_GlobalSaveData.SA_StartFloorItems or 0) > 50 and mod:checkIfAchieved("itemWindfall") == false then
            mod:applyAchievement("itemWindfall", 70000, "Item Windfall", "Get over 50 items on a floor")
        elseif math.floor(game.TimeCounter/30) - (mod.MMA_GlobalSaveData.SA_StartFloorTimestamp or 0) > 1800 and mod:checkIfAchieved("whilingAway") == false then
            mod:applyAchievement("whilingAway", 70000, "Whiling Away", "Spend 30 minutes on one floor")
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.scoreAssaultPickupCalc)


local explorationBonus = 500
function mod:refreshExplorationBonus_SA()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        local totalRooms = 0
        if game:GetLevel():GetCurrentRoomIndex() ~= 84 then
            for i=0, 168, 1 do
                local room = game:GetLevel():GetRoomByIdx(i)
                if room and room.VisitedCount >=1 and room.Clear then
                    totalRooms = totalRooms + 1
                end
            end
        end
        mod.MMA_GlobalSaveData.TotalExploreScore = totalRooms * explorationBonus
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.refreshExplorationBonus_SA)


function mod:onNewFloor_SA()
    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        mod.MMA_GlobalSaveData.TotalBonusScore = (mod.MMA_GlobalSaveData.TotalBonusScore or 0) + mod.MMA_GlobalSaveData.TotalExploreScore
        mod.MMA_GlobalSaveData.TotalExploreScore = 0
        local floorItems = 0

        mod:AnyPlayerDo(function(player)
            floorItems = floorItems + player:GetCollectibleCount()
        end)
        mod.MMA_GlobalSaveData.SA_StartFloorItems = floorItems
        mod.MMA_GlobalSaveData.SA_StartFloorTimestamp = math.floor(game.TimeCounter/30)

        mod:refreshTotalScore_SA()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor_SA)