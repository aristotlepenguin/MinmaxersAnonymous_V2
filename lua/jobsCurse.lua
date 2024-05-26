local mod = MMAMod
local game = Game()
local hiddenItemManager = require("lib.hidden_item_manager")
local sfx = SFXManager()

function mod:recacheFamiliars_JC(player, cache)
    if cache == CacheFlag.CACHE_FAMILIARS then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ONE_UP)
        local itemconfig = Isaac.GetItemConfig()
        local oneUps = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ONE_UP) - hiddenItemManager:CountStack(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
        player:CheckFamiliar(FamiliarVariant.ONE_UP, oneUps, rng, itemconfig:GetCollectible(CollectibleType.COLLECTIBLE_ONE_UP), -1)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.recacheFamiliars_JC)

function mod:checkDeath_JC(player)
    local pdata = mod:mmaGetPData(player)
    local oneUpCount = hiddenItemManager:CountStack(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
    if player:IsDead() then
        pdata.MMA_Died = true
    elseif oneUpCount > 0 and not player:HasCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE) then
        hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
    elseif pdata.MMA_Died == true  and not player:IsDead() and oneUpCount >= 1 then
        pdata.AnimOverride_JC = true
        pdata.MMA_Died = false
        hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
        pdata.MMA_JobBlessLevel = (pdata.MMA_JobBlessLevel or 0) + (pdata.MMA_JobCurseLevel or 0)
        pdata.MMA_JobCurseLevel = 0
        if oneUpCount == 1 then
            pdata.MMA_JobCurseStatus = false
            player:TryRemoveNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_1)
            player:TryRemoveNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_2)
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end

    if string.sub(player:GetSprite():GetAnimation(), 1, 6) == "Pickup" and pdata.AnimOverride_JC == true then
        pdata.AnimOverride_JC = false
        player:AnimateCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.checkDeath_JC)

function mod:onGreedUpdate_JC()
    if game:IsGreedMode() and mod.MMA_GlobalSaveData.MMA_GreedWave ~= game:GetLevel().GreedModeWave then
        mod:ClearRoom_JC(nil, nil)
        if not mod.SINGLE_ITEM then
            mod:onNewRoom_MS(true)
        end
        mod.MMA_GlobalSaveData.MMA_GreedWave = game:GetLevel().GreedModeWave
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onGreedUpdate_JC)

mod.ItemGrabCallback:AddCallback(mod.ItemGrabCallback.InventoryCallback.POST_ADD_ITEM, function(player, item, count, touched, fromQueue)
    if not touched or not fromQueue then
        hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_ONE_UP)
        player:AddNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_1)
        player:AddNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_2)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
        local pdata = mod:mmaGetPData(player)
        pdata.MMA_JobCurseStatus = true
        if game:IsGreedMode() then
            mod.MMA_GlobalSaveData.MMA_GreedWave = game:GetLevel().GreedModeWave
        end
    end
end, MMAMod.MMATypes.COLLECTIBLE_JOBS_CURSE)

function mod:ClearRoom_JC(rng, spawnPosition)
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE) then
            local pdata = mod:mmaGetPData(player)
            local isActive = pdata.MMA_JobCurseStatus
            if isActive then
                pdata.MMA_JobCurseLevel = (pdata.MMA_JobCurseLevel or 0) + 1
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
            end
        end
    end
    )
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.ClearRoom_JC)

function mod:Cache_JC(player, cache)
    local sign = 0.125
    local pdata = mod:mmaGetPData(player)
    if not player:HasCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE) then
        pdata.MMA_JobCurseLevel = 0
    end
    local jobMultiplier = ((pdata.MMA_JobBlessLevel or 0) - (pdata.MMA_JobCurseLevel or 0)) * sign

    if jobMultiplier > 0 then
        if mod.MenuData and mod.MenuData.JobStatPayout and mod.MenuData.JobStatPayout == 3 then
            jobMultiplier = jobMultiplier
        elseif mod.MenuData and mod.MenuData.JobStatPayout and mod.MenuData.JobStatPayout == 2 then
            jobMultiplier = jobMultiplier * 0.5
        else
            jobMultiplier = jobMultiplier * 0.25
        end
    end


    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = math.max(player.Damage + jobMultiplier, 0.5)
    elseif cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = math.max(mod:tearsUp(player.MaxFireDelay, jobMultiplier * 0.2), 0.5)
    elseif cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = math.max(player.MoveSpeed + (jobMultiplier * .2), 0.45)
    elseif cache == CacheFlag.CACHE_RANGE then
        player.TearRange = math.max(player.TearRange + (jobMultiplier * 20), 0.5)
    elseif cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + jobMultiplier
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Cache_JC)