local json = require("json")
local mod = MMAMod
local game = Game()

function mod:useOverclock(collectible, rng, player, useflags, activeslot, customvardata)
    local tempSaveData = json.decode(mod:LoadData())
    tempSaveData.MMA_firingOverclock = true
    mod.MMA_GlobalSaveData.MMA_firingOverclock = true
    local data = mod:mmaGetPData(player)
    data.MMA_overclockFrame = game:GetFrameCount()
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useOverclock, mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)

function mod:tearModifiers(tear)
    tear.Scale = tear.Scale * 3.5
    tear:ResetSpriteScale()
    return tear
end
--mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveData)

function mod:onOverclockFrame(player)
    local data = mod:mmaGetPData(player)
    if data.MMA_overclockFrame and data.MMA_overclockFrame + 20 <= game:GetFrameCount() and data.MMA_overclockFrame + 500 > game:GetFrameCount() then
        if data.MMA_overclockFrame + 20 == game:GetFrameCount() then
            player:AddNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
        end
        local sinusRng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)
        local tearSpeed = 25 * player.ShotSpeed
        local firePos = player.Position + Vector(0, 1)
        local direction = mod.directionToVector[player:GetHeadDirection()] * tearSpeed
        local tear = player:FireTear(firePos, direction, true, false, true, player, 1)
        tear = mod:tearModifiers(tear)
        
        if sinusRng:RandomInt(100) <= player.Luck + 5 then
           local luckDirection = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
           local lucktear = player:FireTear(firePos, luckDirection, true, false, true, player, 1)
           lucktear = mod:tearModifiers(lucktear)
        end
    elseif mod.MMA_GlobalSaveData.MMA_firingOverclock == true and
    data.MMA_overclockFrame and data.MMA_overclockFrame + 500 <= game:GetFrameCount() then
        mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
        player:TryRemoveNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
        print("remove")
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onOverclockFrame)

function mod:crashBonus(player, cache)
    if cache == CacheFlag.CACHE_DAMAGE and mod.MMA_GlobalSaveData.crashBonus == true then
        player.Damage = player.Damage + 3
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.crashBonus)