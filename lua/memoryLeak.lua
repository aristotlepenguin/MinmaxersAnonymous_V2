local mod = MMAMod

local game = Game()

function mod:tearsup_ML(player, cache)
    if cache == CacheFlag.CACHE_FIREDELAY then
        local teartoadd = player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) * 0.3
        player.MaxFireDelay = mod:tearsUp(player.MaxFireDelay, teartoadd)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.tearsup_ML)


function mod:PostPickupInit_ML(pickup)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
        local level = Game():GetLevel():GetStage()
        local numPlayers = game:GetNumPlayers()
        local leaksHeld = 0
        local chosenPlayer
        local room = game:GetRoom()

        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            if player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) > 0 then
                leaksHeld = leaksHeld + player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)
                chosenPlayer = player
            end
        end
        if chosenPlayer then
            local rand_seed = chosenPlayer:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK)
            local benchmark = level * 4 * leaksHeld
            local selectednumber = rand_seed:RandomInt(100)+1
            local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
            if selectednumber < benchmark and (config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST) and (room:GetFrameCount() > -1 or room:IsFirstVisit()) then
                pickup:GetData().MMA_WillGlitch = true
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.PostPickupInit_ML)

function mod:PostPickupUpdate_ML(pickup)
    if pickup:GetData().MMA_WillGlitch then
        pickup:AddEntityFlags(EntityFlag.FLAG_GLITCH)
        pickup:GetData().MMA_WillGlitch = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.PostPickupUpdate_ML)

function mod:AlterTearColor(tear)
    local player = mod:GetPlayerFromTear(tear)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) and tear.FrameCount == 0 then
        tear:GetSprite().Color:SetColorize(0, 0, 0.8, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.AlterTearColor)


function mod:updateLasersPlayer_ML()
    local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
    for i=1, #lasers do
        local laser = lasers[i]
        local player = mod:getPlayerFromKnifeLaser(laser)
        if laser:GetData().LaserMadeBlue == nil and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) then
            laser:GetData().LaserMadeBlue = true
            laser:GetSprite().Color:SetTint(0.5, 0.5, 2, 1)
            laser:GetSprite().Color:SetOffset(0, 0, 1)
        end
    end

    local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL)
    for i=1, #brimballs do
        local brimball = brimballs[i]
        local player = mod:getPlayerFromKnifeLaser(laser)
        if brimball:GetData().LaserMadeBlue == nil and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) then
            brimball:GetData().LaserMadeBlue = true
            --brimball:GetSprite().Color:SetColorize(0, 0, 0.8, 1)
            brimball:GetSprite().Color:SetTint(0.5, 0.5, 2, 1)
            brimball:GetSprite().Color:SetOffset(0, 0, 1)
        end
    end

    local brimswirls = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_SWIRL)
    for i=1, #brimswirls do
        local brimswirl = brimswirls[i]
        local player = mod:getPlayerFromKnifeLaser(laser)
        if brimswirl:GetData().LaserMadeBlue == nil and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) then
            brimswirl:GetData().LaserMadeBlue = true
            brimswirl:GetSprite().Color:SetTint(0.5, 0.5, 2, 1)
            brimswirl:GetSprite().Color:SetOffset(0, 0, 1)
        end
    end

    local laserEndpoints = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)
	for i=1, #laserEndpoints do
		local laserEndpoint = laserEndpoints[i]
        local player
        if laserEndpoint.SpawnerEntity and laserEndpoint.SpawnerEntity.Type == EntityType.ENTITY_LASER then
            local laser = laserEndpoint.SpawnerEntity
            player = mod:getPlayerFromKnifeLaser(laser)
        end

        if laserEndpoint:GetData().LaserMadeBlue == nil and player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MEMORY_LEAK) then
            laserEndpoint:GetData().LaserMadeBlue = true
            laserEndpoint:GetSprite().Color:SetTint(0.5, 0.5, 2, 1)
            laserEndpoint:GetSprite().Color:SetOffset(0, 0, 1)
        end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.updateLasersPlayer_ML)