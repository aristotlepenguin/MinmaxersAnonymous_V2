local mod = MMAMod
local sfx = SFXManager()
local game = Game()

function mod:FixationUseCard(card, player, flags)
    if mod.MMA_GlobalSaveData.fixationVariant == nil and player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_HYPERFIXATION) > 0 then
        mod.MMA_GlobalSaveData.fixationType = card
        mod.MMA_GlobalSaveData.fixationVariant = PickupVariant.PICKUP_TAROTCARD
        sfx:Play(SoundEffect.SOUND_GOLDENKEY)

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.FixationUseCard)

function mod:FixationUsePill(pill, player, flags)
    if mod.MMA_GlobalSaveData.fixationVariant == nil and player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_HYPERFIXATION) > 0 then
        mod.MMA_GlobalSaveData.fixationType = pill
        mod.MMA_GlobalSaveData.fixationVariant = PickupVariant.PICKUP_PILL
        sfx:Play(SoundEffect.SOUND_GOLDENKEY)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, mod.FixationUsePill)


function mod:FixationPostPickupInit(pickup, itempool, decrease, seed)
    if mod.MMA_GlobalSaveData.fixationVariant ~= nil and
    (pickup.Variant == PickupVariant.PICKUP_PILL or pickup.Variant == PickupVariant.PICKUP_TAROTCARD) and
    pickup.SubType ~= mod.MMA_GlobalSaveData.fixationType then
        local hasIt = false
        mod:AnyPlayerDo(function(player)
            if player:HasCollectible(mod.MMATypes.COLLECTIBLE_HYPERFIXATION) then
                hasIt = true
            end
        end)
        if hasIt then
            pickup:ToPickup():Morph(EntityType.ENTITY_PICKUP, mod.MMA_GlobalSaveData.fixationVariant, mod.MMA_GlobalSaveData.fixationType, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.FixationPostPickupInit)

