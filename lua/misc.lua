local mod = MMAMod
local game = Game()
local itemPool = game:GetItemPool()
local rng  =RNG()

function mod:itemSwitch_MMA(pickup)
    if not mod.MenuData or not mod.MenuData.ItemSwitch or (pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE) then
        return
    end
    
    if mod.MenuData.ItemSwitch[pickup.SubType] == 2 or (mod.MenuData.ItemSwitch[pickup.SubType] ~= 2 and pickup.SubType == mod.MMATypes.COLLECTIBLE_D_SQRT) then
        local room = game:GetRoom()
        local new_random_item
        local pool = itemPool:GetPoolForRoom (room:GetType(), rng:GetSeed())

        for i=0, 10000, 1 do
            new_random_item = itemPool:GetCollectible(pool, true)
            if mod.MenuData.ItemSwitch[new_random_item] ~= 2 then
                break
            end
        end
        --return {PickupVariant.PICKUP_COLLECTIBLE, new_random_item}
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, new_random_item, true)
    end
end
--mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, mod.itemSwitch_MMA)
--MC_POST_PICKUP_UPDATE
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.itemSwitch_MMA)