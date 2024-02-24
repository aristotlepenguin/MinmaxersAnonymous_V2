local mod = MMAMod
local game = Game()
local sfx = SFXManager()
local itemconfig = Isaac.GetItemConfig()
local isEph = mod.MMATypes.CHARACTER_EPAPHRAS ~= nil

function mod:findEmptyCharges(player)
    local emptycharges = 0
    if player:GetActiveItem() ~= 0 then
        local itemconfig = Isaac.GetItemConfig()
        local collectConfig = itemconfig:GetCollectible(player:GetActiveItem())
        local maxcharges = collectConfig.MaxCharges
        local activecharge = player:GetActiveCharge()
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
            maxcharges = maxcharges * 2
            activecharge = activecharge + player:GetBatteryCharge()
        end
        emptycharges = maxcharges - activecharge
    end
    return emptycharges
end

function mod:bucketIt(player, emptybones, keepercoin)
    --coins->keys/bombs->red hearts->soul hearts->batteries->stats
    local coinmax = 99
    local bombmax = 99
    local keymax = 99
    local poopMax = 9
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        poopMax = 29
    end
    local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET)

    if isEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            coinmax = 45
            bombmax = 45
            keymax = 45
        else
            coinmax = 65
            bombmax = 65
            keymax = 65
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
        coinmax = 999
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B and player:GetPoopMana() < poopMax then
        player:AddPoopMana(1)
    elseif player:GetNumCoins() < coinmax then
        player:AddCoins(1)
    elseif player:GetNumBombs() < bombmax or player:GetNumKeys() < keymax then
        if rng:RandomInt(100) > 50 then
            if player:GetNumBombs() < bombmax then
                player:AddBombs(1)
            else
                player:AddKeys(1)
            end
        else
            if player:GetNumKeys() < keymax then
                player:AddKeys(1)
            else
                player:AddBombs(1)
            end
        end
    elseif keepercoin ~= true and player:GetEffectiveMaxHearts() - player:GetHearts() > 0 then
        if player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER and player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER_B then
            player:AddHearts(1)
        else
            player:AddCoins(1)
        end
    elseif emptybones == nil and player:GetHeartLimit() - (player:GetEffectiveMaxHearts() + player:GetSoulHearts()) > 0 
    and player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER and player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER_B then
        player:AddSoulHearts(1)
    elseif emptybones ~= nil and 12 - (player:GetSoulHearts() + player:GetSubPlayer():GetSoulHearts()) > 0 then
        player:AddSoulHearts(1)
    elseif emptybones ~= nil and emptybones > 0 then
        player:AddBoneHearts(1)
    elseif mod:findEmptyCharges(player) > 0 then
        player:SetActiveCharge(player:GetActiveCharge()+1)
    elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and player:GetBloodCharge() < 99 then
        player:AddBloodCharge (1)
    elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY and player:GetSoulCharge() < 99 then
        player:AddSoulCharge (1)

    else
        local data = mod:mmaGetPData(player)
        local chosenStat = rng:RandomInt(5)
            if chosenStat == 0 then
                data.bonusRange = (data.bonusRange or 0) + 20
                player:AddCacheFlags(CacheFlag.CACHE_RANGE)
            elseif chosenStat == 1 then
                data.bonusDamage = (data.bonusDamage or 0) + .1
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            elseif chosenStat == 2 then
                data.bonusLuck = (data.bonusLuck or 0) + .1
                player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            elseif chosenStat == 3 then
                data.bonusSpeed = (data.bonusSpeed or 0) + .02
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            elseif chosenStat == 4 then
                data.bonusFireDelay = (data.bonusFireDelay or 0) + .1
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            end
        player:EvaluateItems()
    end
end

function mod:onPickupCollide_RB(pickup, collider, low)
    local player = collider:ToPlayer()

    if player == nil then
        return nil
    else
        local playertype = player:GetPlayerType()
        if playertype == PlayerType.PLAYER_THESOUL_B then
            player = player:GetOtherTwin()
        end
        
        if (player:HasCollectible(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET) or (isEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS)) and pickup:GetData().MMA_HasTouchedRB ~= true then
            local coinmax = 99
            local bombmax = 99
            local keymax = 99
            local poopMax = 9
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                poopMax = 29
            end
            local emptyredhearts = player:GetEffectiveMaxHearts() - player:GetHearts()
            local emptysouls = player:GetHeartLimit() - (player:GetEffectiveMaxHearts() + player:GetSoulHearts())
            local emptybones = nil
            local keepercoin = nil

            if playertype == PlayerType.PLAYER_THELOST_B or playertype == PlayerType.PLAYER_THELOST then
                emptyredhearts = 0
                emptysouls = 0
            elseif playertype == PlayerType.PLAYER_BETHANY_B then
                emptyredhearts = 99 - player:GetBloodCharge()
            elseif playertype == PlayerType.PLAYER_BETHANY then
                emptysouls = 99 - player:GetSoulCharge()
            elseif playertype == PlayerType.PLAYER_THEFORGOTTEN or playertype == PlayerType.PLAYER_THESOUL then
                emptysouls = 12 - player:GetSoulHearts()
                emptybones = 6 - (player:GetBoneHearts() + player:GetSubPlayer():GetBoneHearts())
            end

            local collectThis = nil
            local bucketed = 0
            pickup:GetData().MMA_HasTouchedRB = true
            if pickup.Variant == PickupVariant.PICKUP_COIN then
                local value = 0
                if pickup.SubType == CoinSubType.COIN_PENNY or 
                pickup.SubType == CoinSubType.COIN_GOLDEN or
                pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
                    value = 1
                elseif pickup.SubType == CoinSubType.COIN_DOUBLEPACK then
                    value = 2
                elseif pickup.SubType == CoinSubType.COIN_NICKEL then
                    value = 5
                elseif pickup.SubType == CoinSubType.COIN_DIME then
                    value = 10
                end
                if playertype == PlayerType.PLAYER_KEEPER or playertype == PlayerType.PLAYER_KEEPER_B then
                    value = math.max(0, value-(emptyredhearts/2))
                    if value > 0 then
                        keepercoin = true
                    end
                end

                local isaacCoins = player:GetNumCoins()
                bucketed = math.max(0, (isaacCoins + value) - coinmax)
            elseif pickup.Variant == PickupVariant.PICKUP_BOMB then
                local value = 0
                if player:HasGoldenBomb() and pickup.SubType == BombSubType.BOMB_BOMB_GOLDEN then
                    bucketed = 1
                else
                    if pickup.SubType == BombSubType.BOMB_NORMAL or pickup.SubType == BombSubType.BOMB_GIGA then
                        value = 1
                    elseif pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
                        value = 2
                    end
                    local isaacBombs = player:GetNumBombs()
                    bucketed = math.max(0, (isaacBombs + value) - bombmax)
                end
            elseif pickup.Variant == PickupVariant.PICKUP_KEY then
                local value = 0
                if player:HasGoldenKey() and pickup.SubType == KeySubType.KEY_GOLDEN then
                    bucketed = 1
                else
                    if pickup.SubType == KeySubType.KEY_NORMAL or pickup.SubType == KeySubType.KEY_CHARGED then
                        value = 1
                    elseif pickup.SubType == BombSubType.KEY_DOUBLEPACK then
                        value = 2
                    end
                    local isaacKeys = player:GetNumKeys()
                    bucketed = math.max(0, (isaacKeys + value) - keymax)
                end
            elseif pickup.Variant == PickupVariant.PICKUP_HEART then
                local value = 0
                local heart_type = "red"
                if not player:CanPickGoldenHearts() and pickup.SubType == HeartSubType.HEART_GOLDEN then
                    bucketed = 2
                    collectThis = SoundEffect.SOUND_GOLD_HEART
                elseif not player:CanPickBoneHearts() and pickup.SubType == HeartSubType.HEART_BONE then
                    bucketed = 2
                    collectThis = SoundEffect.SOUND_BONE_DROP
                elseif (emptyredhearts == 1 or not player:CanPickRottenHearts()) and pickup.SubType == HeartSubType.HEART_ROTTEN then
                    bucketed = 1
                    if not player:CanPickRottenHearts() then
                        collectThis = SoundEffect.SOUND_ROTTEN_HEART
                    end
                elseif emptyredhearts == 0 and pickup.SubType == HeartSubType.HEART_ROTTEN and player:CanPickRottenHearts() then
                    bucketed = 2
                elseif pickup.SubType == HeartSubType.HEART_ETERNAL and player:GetEternalHearts () > 0 and emptysouls < 2 then
                    bucketed = math.max(0, 2-emptysouls)
                else
                    if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
                        value = 2
                    elseif pickup.SubType == HeartSubType.HEART_HALF then
                        value = 1
                    elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
                        value = 4
                    elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_BLACK then
                        value = 2
                        heart_type = "soul"
                    elseif pickup.SubType == HeartSubType.HEART_HALF_SOUL then
                        value = 1
                        heart_type = "soul"
                    elseif pickup.SubType == HeartSubType.HEART_BLENDED then
                        value = 2
                        heart_type = "blended"
                    end
                    
                    if heart_type == "red" then
                        if emptyredhearts == 0 then
                            collectThis = SoundEffect.SOUND_BOSS2_BUBBLES
                        end
                        bucketed = math.max(0, value - emptyredhearts)
                    elseif heart_type == "soul" then
                        if emptysouls == 0 then
                            collectThis = SoundEffect.SOUND_BOSS2_BUBBLES
                        end
                        bucketed = math.max(0, value - emptysouls)
                    elseif heart_type == "blended" then
                        if emptysouls + emptyredhearts == 0 then
                            collectThis = SoundEffect.SOUND_BOSS2_BUBBLES
                        end
                        bucketed = math.max(0, value - (emptyredhearts + emptysouls))
                    end

                end
            elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
                local emptycharges = mod:findEmptyCharges(player)
                local value = 0
                if pickup.SubType ==BatterySubType.BATTERY_NORMAL or
                pickup.SubType ==BatterySubType.BATTERY_GOLDEN then
                    value = 6
                elseif pickup.SubType ==BatterySubType.BATTERY_MICRO then
                    value = 2
                elseif pickup.SubType ==BatterySubType.BATTERY_MEGA then
                    value = 12
                end
                bucketed = math.max(math.ceil((value-emptycharges)/2), 0)
                if emptycharges <=0 then
                    collectThis = SoundEffect.SOUND_BATTERYCHARGE
                end
            elseif pickup.Variant == PickupVariant.PICKUP_POOP then
                local value = 0
                local isaacPoop = player:GetPoopMana()
                if pickup.SubType == PoopPickupSubType.POOP_SMALL then
                    value = 1
                else
                    value = 3
                end
                bucketed = math.max(0, (isaacPoop + value) - poopMax)
            end
            if bucketed > 0 then
                for i=1, bucketed, 1 do
                    mod:bucketIt(player, emptybones, keepercoin)
                end
            end
            if collectThis ~= nil then
                sfx:Play(collectThis, Options.SFXVolume*2)
                pickup:GetData().mma_DeletePickup = true
                pickup:GetSprite():Play("Collect")
                return true
            end
            return nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.onPickupCollide_RB)



function mod:bonusStatsCache_RB(player, cache)
    local data = mod:mmaGetPData(player)
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (data.bonusDamage or 0)
    end
    if cache == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (data.bonusRange or 0)
    end
    if cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (data.bonusLuck or 0)
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (data.bonusSpeed or 0)
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        local teartoadd = (data.bonusFireDelay or 0)
        player.MaxFireDelay = mod:tearsUp(player.MaxFireDelay, teartoadd)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bonusStatsCache_RB)


function mod:OnUpdate_RB()
    local picks = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    for _, pick in pairs(picks) do
        if pick:GetData().mma_DeletePickup and
        pick:GetSprite():GetFrame() >= 4 and
        pick:GetSprite():GetAnimation() == "Collect" then
            pick:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnUpdate_RB)


function mod:RBOnPlayerUpdate(player)
    local pdata = mod:mmaGetPData(player)
    if pdata.RB_JustReceived ~= nil and (player:HasCollectible(mod.MMATypes.COLLECTIBLE_RAIN_BUCKET) or (isEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS)) then
        local config = itemconfig:GetCollectible(pdata.RB_JustReceived)
        local bombs = config.AddBombs
        local keys = config.AddKeys
        local coins = config.AddCoins

        local coinLimit = 99
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
            coinLimit = 999
        end
        
        local totalbucket = 0
        totalbucket = totalbucket + math.max((pdata.bombsRec3 + bombs) - 99, 0)
        totalbucket = totalbucket + math.max((pdata.coinsRec3 + coins) - coinLimit, 0)
        totalbucket = totalbucket + math.max((pdata.keysRec3 + keys) - 99, 0)

        local keepercoin = nil
        local emptybones = nil
        if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            if math.max(0, totalbucket-(player:GetEffectiveMaxHearts() - player:GetHearts()/2)) > 0 then
                keepercoin = true
            end
        elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
            emptybones = 6 - (player:GetBoneHearts() + player:GetSubPlayer():GetBoneHearts())
        end

        for i=1, totalbucket, 1 do
            mod:bucketIt(player, emptybones, keepercoin)
        end

        pdata.RB_JustReceived = nil
    end
    
    --i really hate this solution but it's the easiest one. the frame i want to track is two frames before this callback
    pdata.coinsRec3 = pdata.coinsRec2
    pdata.bombsRec3 = pdata.bombsRec2
    pdata.keysRec3 = pdata.keysRec2
    
    pdata.coinsRec2 = pdata.coinsRec1
    pdata.bombsRec2 = pdata.bombsRec1
    pdata.keysRec2 = pdata.keysRec1
    
    pdata.coinsRec1 = player:GetNumCoins()
    pdata.bombsRec1 = player:GetNumBombs()
    pdata.keysRec1 = player:GetNumKeys()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.RBOnPlayerUpdate)

local bucketNineNine = function(player, item, count, touched, fromQueue)
    if not fromQueue or not touched then
        local pdata = mod:mmaGetPData(player)
        pdata.RB_JustReceived = item
    end
end

for itemID=1, itemconfig:GetCollectibles().Size-1 do
    local item = itemconfig:GetCollectible(itemID)
    if item and item.AddCoins + item.AddBombs + item.AddKeys > 0 then
        mod.ItemGrabCallback:AddCallback(mod.ItemGrabCallback.InventoryCallback.POST_ADD_ITEM, bucketNineNine, itemID)
    end
end
------------------------------------
--EPAPHRAS STARTS HERE
------------------------------------

function mod:ephStatsHandling(player, cache)
    if cache == CacheFlag.CACHE_SPEED and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS then
        player.MoveSpeed = player.MoveSpeed - 0.1
    end
end
if isEph then
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.ephStatsHandling)
end

function mod:onUpdateEpaphras(player)
    if player:GetPlayerType() ~= mod.MMATypes.CHARACTER_EPAPHRAS then
        return
    end
    local totalToBucket = 0

    local pocketLimits = 65
    local coinLimits = 65
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        pocketLimits = 45
        coinLimits = 45
    end

    if mod.MenuData.MaxiePocketLimits and mod.MenuData.MaxiePocketLimits == 2 then
        pocketLimits = 99
        coinLimits = 99
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            pocketLimits = 65
            coinLimits = 65
        end
    end


    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
        coinLimits = 999
    end

    if player:GetNumCoins() > coinLimits then
        totalToBucket = totalToBucket + (player:GetNumCoins() - coinLimits)
        player:AddCoins(coinLimits - player:GetNumCoins())
    end
    if player:GetNumBombs() > pocketLimits then
        totalToBucket = totalToBucket + (player:GetNumBombs() - pocketLimits)
        player:AddBombs(pocketLimits - player:GetNumBombs())
    end
    if player:GetNumKeys() > pocketLimits then
        totalToBucket = totalToBucket + (player:GetNumKeys() - pocketLimits)
        player:AddKeys(pocketLimits - player:GetNumKeys())
    end
    if totalToBucket > 0 then
        for i=1, totalToBucket, 1 do
            mod:bucketIt(player, nil, nil)
        end
    end
end
if isEph then
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onUpdateEpaphras)
end
--account for skeleton key, pyro, and dollar

function mod:BossRushImmunity_RB(rng, spawnPosition)
    local room = Game():GetRoom()
    local isMaxie = false

    mod:AnyPlayerDo(function(player)
    if isEph and player:GetPlayerType() ~= mod.MMATypes.CHARACTER_EPAPHRAS then
        isMaxie = true
    end
    end)

    if room:GetType() == RoomType.ROOM_BOSS and (room:IsClear() or rng ~= nil) and isMaxie and not game:IsGreedMode() and MMAMod.MenuData.MaxieBossRush ~= 2 then
        if game:GetLevel():GetStage() == LevelStage.STAGE3_2 then
            room:TrySpawnBossRushDoor()
        elseif game:GetLevel():GetStage() == LevelStage.STAGE4_2 and game:GetLevel():GetStageType() < 3 then
            room:TrySpawnBlueWombDoor()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.BossRushImmunity_RB)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.BossRushImmunity_RB)