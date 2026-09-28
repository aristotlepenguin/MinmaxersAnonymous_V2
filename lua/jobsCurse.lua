local mod = MMAMod
local game = Game()
--local hiddenItemManager = require("lib.hidden_item_manager")
local sfx = SFXManager()


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
        player:AddNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_1)
        player:AddNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_2)
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

--:GetSprite():GetAnimation()
function mod:checkDeath_JC()
    mod:AnyPlayerDo(function(player)
        local pdata = mod:mmaGetPData(player)
        local p2 = player
        local anim = player
        -- or player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_ESAU 
        if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B  or player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_ESAU then 
            p2 = player:GetOtherTwin() 
        end
        
        if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then 
            anim = player:GetOtherTwin() 
        end
        
        local p2data = mod:mmaGetPData(p2)

        
        if player:IsDead() and player:HasCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE) and pdata.MMA_JobIsDead ~= 1 and p2data.MMA_JobIsDead ~= 1 then
            if not p2:IsDead() and player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B then -- 
                p2data.JC_LastInOrder = 2
            else 
                pdata.JC_LastInOrder = 1
            end
            pdata.MMA_JobIsDead = 1
            player:UseCard(89, UseFlag.USE_NOANNOUNCER)
            player:RemoveCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)

        elseif pdata.MMA_JobIsDead == 1 and anim:IsExtraAnimationFinished() then
            
            pdata.MMA_JobIsDead = 0
            player:AnimateCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE)
            pdata.MMA_JobBlessLevel = (pdata.MMA_JobBlessLevel or 0) + (pdata.MMA_JobCurseLevel or 0)
            pdata.MMA_JobCurseLevel = 0
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
            if not player:HasCollectible(mod.MMATypes.COLLECTIBLE_JOBS_CURSE) then
                pdata.MMA_JobCurseStatus = false
                player:TryRemoveNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_1)
                player:TryRemoveNullCostume(mod.MMATypes.COSTUME_JOBSCURSE_2)
            end   
            
            if pdata.JC_LastInOrder == 1 then
                local player_type = player:GetPlayerType()
                pdata.JC_LastInOrder = nil
                if player_type == PlayerType.PLAYER_BLUEBABY or player_type == PlayerType.PLAYER_BLUEBABY_B  or player_type == PlayerType.PLAYER_BETHANY_B or player_type == PlayerType.PLAYER_THEFORGOTTEN_B then 
                    player:AddSoulHearts(5)
                elseif player_type == PlayerType.PLAYER_JUDAS_B then
                    player:AddBlackHearts(3)
                elseif player_type == PlayerType.PLAYER_THEFORGOTTEN then
                    player:AddBoneHearts(1)
                    player:SetFullHearts()
                elseif player_type == PlayerType.PLAYER_THESOUL then
                    player:AddSoulHearts(1)
                else 
                    player:SetFullHearts()
                end
            end
        elseif pdata.JC_LastInOrder == 2 and p2data.MMA_JobIsDead == 0 and p2:IsExtraAnimationFinished() then
            local player_type = player:GetPlayerType()
            if (player:GetPlayerType() == PlayerType.PLAYER_JACOB or player:GetPlayerType() == PlayerType.PLAYER_ESAU) then
                player:GetOtherTwin():SetFullHearts()
                pdata.JC_LastInOrder = nil
            else
                player:SetFullHearts()
                pdata.JC_LastInOrder = nil
            end
        end
    end
)
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.checkDeath_JC)
