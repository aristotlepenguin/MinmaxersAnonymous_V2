local mod = MMAMod
local sfx = SFXManager()
local game = Game()
local itemPool = game:GetItemPool()
local itemconfig = Isaac.GetItemConfig()


function mod:useDSqrt(collectible, rng, player, useflags, activeslot, customvardata)
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
    local bombs = player:GetNumBombs()
    local coins = player:GetNumCoins()
    local secondsOnTimer = math.floor(game.TimeCounter/30) % 60
    local totalItems = itemconfig:GetCollectibles().Size-1
    
    for i, entity in ipairs(entities) do
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, entity.Position, entity.Velocity, player)
        local oldItem = entity.SubType
        local newItem = (((bombs * oldItem * oldItem) + (coins * oldItem) + secondsOnTimer)/9) % totalItems
        if newItem % 1 ~= 0 or oldItem == CollectibleType.COLLECTIBLE_POOP then
            newItem = CollectibleType.COLLECTIBLE_POOP
        end
        entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true)
    end
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useDSqrt, mod.MMATypes.COLLECTIBLE_D_SQRT)