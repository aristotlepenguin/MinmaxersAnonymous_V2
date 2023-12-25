local mod = MMAMod

local game = Game()

function mod:tearsup_ML(player, cache)
    if cache == CacheFlag.CACHE_FIREDELAY then
        local teartoadd = player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) * 0.3
        player.MaxFireDelay = mod:tearsUp(player.MaxFireDelay, teartoadd)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.tearsup_ML)



function mod:PostPickupInit_ML(pickup, itempool, decrease, seed)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
        local level = Game():GetLevel():GetStage()
        local numPlayers = game:GetNumPlayers()
        local leaksHeld = 0

        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            leaksHeld = leaksHeld + player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)
        end

        local rand_seed = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_MEMORYLEAK)
        local benchmark = level * 4 * leaksHeld
        local selectednumber = rand_seed:RandomInt(100)+1

        local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)

        if selectednumber < benchmark and (config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST) then
            pickup:GetData().WillGlitch = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PostPickupInit_ML)