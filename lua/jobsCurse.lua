local mod = MMAMod
local game = Game()
local hiddenItemManager = require("lib.hidden_item_manager")

function mod:recacheFamiliars_JC(player, cache)
    if cache == CacheFlag.CACHE_FAMILIARS then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ONE_UP)
        local itemconfig = Isaac.GetItemConfig()
        local oneUps = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ONE_UP) - hiddenItemManager:CountStack(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
        --print("recharge" .. tostring(oneUps))
        player:CheckFamiliar(FamiliarVariant.ONE_UP, oneUps, rng, itemconfig:GetCollectible(CollectibleType.COLLECTIBLE_ONE_UP), -1)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.recacheFamiliars_JC)

function mod:checkDeath_JC(player)
    local pdata = mod:mmaGetPData(player)
    if player:IsDead() then
        pdata.MMA_Died = true
    elseif pdata.MMA_Died == true and hiddenItemManager:CountStack(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup) >= 1 then
        hiddenItemManager:Remove(player, CollectibleType.COLLECTIBLE_ONE_UP, hiddenItemManager.kDefaultGroup)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.checkDeath_JC)



mod.ItemGrabCallback:AddCallback(mod.ItemGrabCallback.InventoryCallback.POST_ADD_ITEM, function(player, item, count, touched, fromQueue)
    print(player)
    print(item)
    print(count)
    print(touched)
    print(fromQueue)
    if not touched or not fromQueue then
        hiddenItemManager:Add(player, CollectibleType.COLLECTIBLE_ONE_UP)
        print("goob")
    end

end, MMAMod.MMATypes.COLLECTIBLE_JOBS_CURSE)