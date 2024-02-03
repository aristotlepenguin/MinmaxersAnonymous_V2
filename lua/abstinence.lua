local mod = MMAMod
local sfx = SFXManager()
local game = Game()
local itemPool = game:GetItemPool()
local itemconfig = Isaac.GetItemConfig()
local hud = game:GetHUD()

local p2f = {[-1] = 0,
            [-2] = 1,
            [-3] = 2,
            [-4] = 3,
            [-5] = 0,
            [-6] = 4,
            [-7] = 5,
            [-8] = 6,
            [-9] = 7}


function mod:coinFadeRender(player, offset)
    local data = mod:mmaGetPData(player)
    local spritefade = data.spriteToFade
    if spritefade then
        local pos = Isaac.WorldToScreen(player.Position)
        pos.Y = pos.Y - spritefade.frame - 15
        spritefade.spr.Color = Color(1,1,1,1-spritefade.frame/60)
        --spritefade.spr:Render(pos)
        if math.floor(spritefade.price / 10) ~= 0 then
            spritefade.spr:RenderLayer(0, pos)
        end
        spritefade.spr:RenderLayer(1, pos)
        spritefade.spr:RenderLayer(2, pos)
        spritefade.frame = spritefade.frame + 1
        if spritefade.frame > 60 then
            data.spriteToFade = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.coinFadeRender)

function mod:collideItemPedestalAbs(pickup, collider, low)
    local player = collider:ToPlayer()
    if player and (player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B or player:GetPlayerType() == PlayerType.PLAYER_CAIN_B)
    and pickup.SubType == mod.MMATypes.COLLECTIBLE_ABSTINENCE
    and pickup:GetData().MMA_ABS_Touched ~= true then
        local item_obj = {}
        item_obj.price = 0
        local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_ABSTINENCE)
        local ranPool = rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
        item_obj.subtype = itemPool:GetCollectible(ranPool, true, rng:RandomInt(100000)+1)
        
        local collectConfig = itemconfig:GetCollectible(item_obj.subtype)
        item_obj.charges = mod:isNil(collectConfig.MaxCharges, 0)
        item_obj.touched = false
        
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, Options.SFXVolume*2)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, mod.MMATypes.CARD_CHASTITY, pickup.Position, Vector(0,0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
          
        local data = mod:mmaGetPData(player)
        if data.chastity_items == nil then
            data.chastity_items = {}
        end
        table.insert(data.chastity_items, 1, item_obj)
        local pickupindex = pickup.OptionsPickupIndex
        pickup:Remove()

        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for i, item in ipairs(items) do
            if item:ToPickup().OptionsPickupIndex == pickupindex and pickupindex ~= 0 then
                item:Remove()
            end
        end
        return true
    end

    if player == nil or not player:HasCollectible(mod.MMATypes.COLLECTIBLE_ABSTINENCE) or
    pickup:GetData().MMA_ABS_Touched == true or pickup.SubType == 0 or
    itemconfig:GetCollectible(pickup.SubType):HasTags(ItemConfig.TAG_QUEST) then
        return nil
    else
        pickup:GetData().MMA_ABS_Touched = true
        
        local item_tbl = {}
        item_tbl.subtype = pickup.SubType
        item_tbl.price = 0
        item_tbl.charges = pickup.Charge
        item_tbl.touched = pickup.Touched
        
        if pickup:IsShopItem() then
            item_tbl.price = pickup.Price
        end

        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, Options.SFXVolume*2)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, mod.MMATypes.CARD_CHASTITY, pickup.Position, Vector(0,0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0,0), nil)
                
        local data = mod:mmaGetPData(player)
        if data.chastity_items == nil then
            data.chastity_items = {}
        end
        table.insert(data.chastity_items, 1, item_tbl)

        local pickupindex = pickup.OptionsPickupIndex
        pickup:Remove()

        local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for i, item in ipairs(items) do
            if item:ToPickup().OptionsPickupIndex == pickupindex and pickupindex ~= 0 then
                item:Remove()
            end
        end
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.collideItemPedestalAbs, PickupVariant.PICKUP_COLLECTIBLE)


function mod:useChastityCard(card, player, useflags)
    local data = mod:mmaGetPData(player)
    local item_obj
    
    if data.chastity_items == nil then
        data.chastity_items = {}
    end
    if #data.chastity_items == 0 then
        item_obj = {}
        item_obj.price = 0
        local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_ABSTINENCE)
        local ranPool = rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
        item_obj.subtype = itemPool:GetCollectible(ranPool, true, rng:RandomInt(100000)+1)
        
        local collectConfig = itemconfig:GetCollectible(item_obj.subtype)
        item_obj.charges = mod:isNil(collectConfig.MaxCharges, 0)
        item_obj.touched = false
    else
        item_obj = table.remove(data.chastity_items, 1)
    end
    local canGet = true
    if item_obj.price > 0 then
        if player:GetNumCoins() < item_obj.price then
            canGet = false
            if data.spriteToFade == nil then
                local spriteCost = Sprite()
                spriteCost:Load("gfx/005.150_shop item.anm2", true)
                spriteCost:Play("NumbersRed")
                spriteCost:SetLayerFrame(0, math.floor(item_obj.price / 10))
                spriteCost:SetLayerFrame(1, item_obj.price % 10)
                spriteCost:SetLayerFrame(2, 10)
                spriteCost:LoadGraphics()
                data.spriteToFade = {spr=spriteCost, frame=0, price = item_obj.price}
            end
        else
            player:AddCoins(-item_obj.price)
        end
    elseif item_obj.price < 0 then
        if not mod:removeDevilPrice(player, item_obj.price) then
            canGet = false
            local spriteCost = Sprite()
            spriteCost:Load("gfx/005.150_shop item.anm2", true)
            spriteCost:Play("Hearts")
            spriteCost:SetFrame(p2f[item_obj.price])
            spriteCost:LoadGraphics()
            data.spriteToFade = {spr=spriteCost, frame=0, price = item_obj.price}
        end
    end

    if canGet == false then
        sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, Options.SFXVolume*2)
        if useflags & 2208 == 0 then
            player:AddCard(mod.MMATypes.CARD_CHASTITY)
        end
        table.insert(data.chastity_items, 1, item_obj)
    else
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 and itemconfig:GetCollectible(item_obj.subtype).Type == ItemType.ITEM_ACTIVE then
            local charges = player:GetActiveCharge()
            local activetype = player:GetActiveItem()
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= 0 then
                player:RemoveCollectible(activetype)
                local actitemgen =  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, activetype, Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vector(0,-40)), Vector(0,0), nil)
                actitemgen:ToPickup().Charge = charges
                actitemgen:ToPickup().Touched = true
            end
        end
        player:AddCollectible(item_obj.subtype, item_obj.charges, not item_obj.touched)
        player:AnimateCollectible(item_obj.subtype)
        hud:ShowItemText(player, itemconfig:GetCollectible(item_obj.subtype))
        sfx:Play(SoundEffect.SOUND_POWERUP1, Options.SFXVolume*2)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.useChastityCard, MMAMod.MMATypes.CARD_CHASTITY)



function mod:removeDevilPrice(player, price)
    if price == PickupPrice.PRICE_ONE_SOUL_HEART and player:GetSoulHearts() >= 2 then
        player:AddSoulHearts(-2)
        return true
    elseif price == PickupPrice.PRICE_TWO_SOUL_HEARTS and player:GetSoulHearts() >= 4 then
        player:AddSoulHearts(-4)
        return true
    elseif price == PickupPrice.PRICE_THREE_SOULHEARTS and player:GetSoulHearts() >= 6 then
        player:AddSoulHearts(-6)
        return true
    elseif price == PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART and player:GetSoulHearts() >= 2 and player:GetMaxHearts() >= 2 then
        player:AddMaxHearts(-2)
        player:AddSoulHearts(-2)
        return true
    elseif price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS and player:GetSoulHearts() >= 4 and player:GetMaxHearts() >= 2 then
        player:AddMaxHearts(-2)
        player:AddSoulHearts(-4)
        return true
    elseif price == PickupPrice.PRICE_ONE_HEART and player:GetMaxHearts() >= 2 then
        player:AddMaxHearts(-2)
        return true
    elseif price == PickupPrice.PRICE_TWO_HEARTS and player:GetMaxHearts() >= 4 then
        player:AddMaxHearts(-4)
        return true
    elseif price == PickupPrice.PRICE_SOUL and player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL) then
        player:RemoveTrinket(TrinketType.TRINKET_YOUR_SOUL)
        return true
    else
        return false
    end
end

--set up conditons for book of virtues
--consider a UI for the next available item when holding tab when you have a chastity card