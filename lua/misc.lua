local mod = MMAMod
local game = Game()
local itemPool = game:GetItemPool()
local rng  =RNG()

function mod:itemSwitch_MMA(pickup, variant, subtype)
    if not mod.MenuData or not mod.MenuData.ItemSwitch or (variant ~= PickupVariant.PICKUP_COLLECTIBLE and variant ~= PickupVariant.PICKUP_SHOPITEM) then
        return
    end
    
    if mod.MenuData.ItemSwitch[subtype] == 2 or (mod.MenuData.ItemSwitch[subtype] ~= 2 and subtype == mod.MMATypes.COLLECTIBLE_D_SQRT) then
        local room = game:GetRoom()
        local new_random_item
        local pool = itemPool:GetPoolForRoom (room:GetType(), rng:GetSeed())

        for i=0, 10000, 1 do
            new_random_item = itemPool:GetCollectible(pool, true, rng:RandomInt(100000)+1)
            if mod.MenuData.ItemSwitch[new_random_item] ~= 2 then
                break
            end
        end
        return {PickupVariant.PICKUP_COLLECTIBLE, new_random_item}
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, mod.itemSwitch_MMA)