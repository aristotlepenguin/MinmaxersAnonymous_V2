local json = require("json")
local mod = MMAMod
local game = Game()
local sfx = SFXManager()

mod.GetLeftDiag = {
    [Direction.LEFT] = Vector(-120, 35):Normalized(),
    [Direction.UP] = Vector(-35, -120):Normalized(),
    [Direction.RIGHT] = Vector(120, -35):Normalized(),
    [Direction.DOWN] = Vector(35, 120):Normalized()
  }
  
  mod.GetRightDiag = {
    [Direction.LEFT] = Vector(-120, -35):Normalized(),
    [Direction.UP] = Vector(35, -120):Normalized(),
    [Direction.RIGHT] = Vector(120, 35):Normalized(),
    [Direction.DOWN] = Vector(-35, 120):Normalized()
  }
  
  mod.TearTierMultiplier = {
    [Direction.LEFT] = Vector(0.65, 0.95):Normalized(),
    [Direction.UP] = Vector(0.95, 0.65):Normalized(),
    [Direction.RIGHT] = Vector(0.65, 0.95):Normalized(),
    [Direction.DOWN] = Vector(0.95, 0.65):Normalized()
  }

  local nullVector = Vector.Zero

function mod:floatToInt(float)
    return math.floor(float * 10000) --4 digits is enough percision in my books
end

function mod:getTearDuplicateAmt(player)
    return 1 + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20) + (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE) * 2) + (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) * 3)
end

function mod:adjustAngle_OS(velocity, stream, totalstreams)
    local multiplicator = velocity:Length()
    local angleAdjustment = 10 * (stream-1) - 5 * (totalstreams-1)
    local correctAngle = velocity:GetAngleDegrees() + angleAdjustment
    return Vector.FromAngle(correctAngle) * multiplicator
end

function mod:spawnRocket(player, pos, delay, damage)
    local size = (player.Size * 2) + 65
    if (player.Position-pos):Length() > size then
        local rocket = Isaac.Spawn(1000, 31, 0, pos, nullVector, player):ToEffect()
        rocket:SetTimeout(delay or 10)
        if damage then rocket.DamageSource = mod:floatToInt(damage) end
        rocket:Update()
        return rocket
    end
end

function mod:useOverclock(collectible, rng, player, useflags, activeslot, customvardata)
    local tempSaveData = json.decode(mod:LoadData())
    if not tempSaveData.PlayerData then
        tempSaveData.PlayerData = {}
    end
    if not tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] then
        tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] = {}
    end
    tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())].MMA_firingOverclock = true
    local jsonString = json.encode(tempSaveData)
    mod:SaveData(jsonString)

    local data = mod:mmaGetPData(player)
    data.MMA_firingOverclock = true
    data.MMA_overclockFrame = game:GetFrameCount()

    sfx:Play(SoundEffect.SOUND_DERP, Options.SFXVolume)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        for i=1, 8, 1 do
            player:AddWisp(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, player.Position)
        end
    end

    if mod.DEBUG then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = true
        }
    else
        return {
            Discharge = false,
            Remove = true,
            ShowAnim = true
        }
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.useOverclock, mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)

function mod:tearModifiers(tear, player, isPrimaryTear, isTear, familiar)
    
    if isPrimaryTear then
        
        if not familiar then
            tear.Scale = tear.Scale * 3.5
        else
            tear.Scale = tear.Scale * 2
        end
        tear:ResetSpriteScale()
    end

    if player.TearRange >= 560 then
        --tear:AddTearFlags(TearFlags.TEAR_CONTINUUM)
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    end

    if isTear == true and (player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) then
        tear:AddTearFlags(TearFlags.TEAR_BONE)
    end
    return tear
end
--mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveData)

local screenShaking = false
local lastFrame = nil
function mod:handleTearsOut_OS(player, firstFrame, familiar)
    local tearTier = math.floor(30 / (player.MaxFireDelay + 1))
    local sinusRng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)
    local tearSpeed = 25 * player.ShotSpeed
    local firePos = player.Position + Vector(0, 1)
    local hasLudo = false

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        local tears = Isaac.FindByType(EntityType.ENTITY_TEAR)
        hasLudo = true
        for i, tear in ipairs(tears) do
            if tear:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO) then
                firePos = tear.Position
                break
            end
        end
    end

    if familiar then
        firePos = familiar.Position + Vector(0, 1)
    end
    if firstFrame and not familiar then
        sfx:Play(SoundEffect.SOUND_BLACK_POOF, Options.SFXVolume*2)
    end

    local direction = mod.directionToVector[player:GetHeadDirection()] * tearSpeed
    local frame = game:GetFrameCount()

    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        if familiar then
            return
        end
        if sinusRng:RandomInt(100) <= player.Luck + 5 then
            mod:spawnRocket(player, Isaac.GetRandomPosition())
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        if frame % 4 == 0 then
            local bombTier = math.floor((30 / (player.MaxFireDelay + 1))*3)
            if bombTier >= 3 or frame % 8 == 0 then
                local multiples = mod:getTearDuplicateAmt(player)
                for y=1, multiples, 1 do
                    local new_dir = mod:adjustAngle_OS(direction, y, multiples)
                    local tear = player:FireBomb(firePos, new_dir, player)
                    tear = mod:tearModifiers(tear, player, false, false, familiar)
                end
                
            end
            
            if bombTier >= 4 then
                local slantDir
                if frame % 8 == 0 then
                    slantDir = mod.GetLeftDiag[player:GetHeadDirection()]
                else
                    slantDir = mod.GetRightDiag[player:GetHeadDirection()]
                end
                
                for x=4, bombTier, 1 do
                    local tear = player:FireBomb(firePos, slantDir * tearSpeed, player)
                    slantDir = (slantDir * mod.TearTierMultiplier[player:GetHeadDirection()]):Normalized()
                    tear = mod:tearModifiers(tear, player, false, false, familiar)
                end
            end

            if sinusRng:RandomInt(100) <= player.Luck + 5 then
                local luckDirection = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
                local lucktear = player:FireBomb(firePos, luckDirection, player)
                lucktear = mod:tearModifiers(lucktear, player, false, false, familiar)
            end
        end
    
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
        local tearSpread = 10 + (mod:getTearDuplicateAmt(player) * 5)

        if (tearTier > 3 and frame % 2 == 0) or frame % 4 == 0 or tearTier > 4 then
            local knife = player:FireKnife(player, 0, false, 2, 0)
            sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, Options.SFXVolume*2)
            local knifeSpread = sinusRng:RandomInt(tearSpread*2)-tearSpread
            local spreadDirection = Vector.FromAngle(direction:GetAngleDegrees()+knifeSpread) * (tearSpeed * 1.5)
            knife.Velocity = spreadDirection
            knife.Rotation = direction:GetAngleDegrees() - 90
            knife:GetSprite().Rotation = direction:GetAngleDegrees() - 90
            knife:GetData().MMA_Overclocked_Knife_Frame = game:GetFrameCount()
        end
        
        if sinusRng:RandomInt(100) <= player.Luck + 5 then
            local knife = player:FireKnife(player, 0, false, 2, 0)
            local knifeSpread = sinusRng:RandomInt(360)
            local spreadDirection = Vector.FromAngle(knifeSpread) * (tearSpeed * 1.5)
            knife.Velocity = spreadDirection
            knife.Rotation = direction:GetAngleDegrees() - 90
            knife:GetSprite().Rotation = direction:GetAngleDegrees() - 90
            knife:GetData().MMA_Overclocked_Knife_Frame = game:GetFrameCount()
        end

    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        local defaultRadius = 8 * player.Damage
        if tearTier >= 3 or frame % 2 == 0 then
            local multiples = mod:getTearDuplicateAmt(player)
            for y=1, multiples, 1 do
                local new_dir = mod:adjustAngle_OS(direction, y, multiples)
                player:FireTechXLaser(firePos, new_dir, defaultRadius, player, 1)
            end
        end

        if tearTier >= 4 then
            local slantDir
            if frame % 2 == 0 then
                slantDir = mod.GetLeftDiag[player:GetHeadDirection()]
            else
                slantDir = mod.GetRightDiag[player:GetHeadDirection()]
            end
            
            for x=4, tearTier, 1 do
                --local tear = player:FireTear(firePos, slantDir * tearSpeed, true, false, true, player, 1)
                local brimball = player:FireTechXLaser(firePos, slantDir * tearSpeed, defaultRadius, player, 1)
                slantDir = (slantDir * mod.TearTierMultiplier[player:GetHeadDirection()]):Normalized()
            end
        end

        if sinusRng:RandomInt(100) <= player.Luck + 5 then
            local luckDirection = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
            player:FireTechXLaser(firePos, luckDirection, defaultRadius, player, 1)
        end
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
        local subLaserType = 1
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            subLaserType = 2
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
            subLaserType = 9
        end
        if firstFrame then
            local multiples = mod:getTearDuplicateAmt(player)
            for y=1, multiples, 1 do
                local new_dir = mod:adjustAngle_OS(direction, y, multiples)
                local primeLaser = EntityLaser.ShootAngle(6, firePos, new_dir:GetAngleDegrees(), 500, Vector(0, 0), player)
                primeLaser:GetData().MMA_oSPrimeLaser = true
                primeLaser:GetData().MMA_AdjustAngle = new_dir:GetAngleDegrees() - direction:GetAngleDegrees()
                primeLaser:AddTearFlags(player.TearFlags)
                primeLaser.Color = player.LaserColor
            end

            local laserTier = math.floor((30 / (player.MaxFireDelay + 1))*4)

            for j=1, laserTier, 1 do
                local directionSub = 0 + j * math.floor(360/laserTier)
                local subLaser = EntityLaser.ShootAngle(subLaserType, firePos, directionSub, 500, Vector(0, 0), player)
                subLaser:GetData().MMA_oSSubLaser = true
                subLaser:AddTearFlags(player.TearFlags)
                subLaser.Color = player.LaserColor
            end

        end
        if sinusRng:RandomInt(100) <= player.Luck + 5 then
            local luckDirection = sinusRng:RandomInt(361)
            local laserluck = EntityLaser.ShootAngle(subLaserType, firePos, luckDirection, 9, Vector(0, 0), player)
            laserluck:AddTearFlags(player.TearFlags)
            laserluck.Color = player.LaserColor
        end
    else
        if tearTier >= 3 or frame % 2 == 0 then
            local multiples = mod:getTearDuplicateAmt(player)
            for y=1, multiples, 1 do
                local new_dir = mod:adjustAngle_OS(direction, y, multiples)
                if hasLudo then
                    new_dir = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
                end
                local tear = player:FireTear(firePos, new_dir, true, false, true, player, 1)
                tear = mod:tearModifiers(tear, player, true, true, familiar)
            end
            
        end
        
        if tearTier >= 4 then
            local slantDir
            if frame % 2 == 0 then
                slantDir = mod.GetLeftDiag[player:GetHeadDirection()]
            else
                slantDir = mod.GetRightDiag[player:GetHeadDirection()]
            end
            
            for x=4, tearTier, 1 do
                if hasLudo then
                    slantDir = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
                end
                local tear = player:FireTear(firePos, slantDir * tearSpeed, true, false, true, player, 1)
                slantDir = (slantDir * mod.TearTierMultiplier[player:GetHeadDirection()]):Normalized()
                tear = mod:tearModifiers(tear, player, false, true, familiar)
            end
        end

        if sinusRng:RandomInt(100) <= player.Luck + 5 then
            local luckDirection = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
            local lucktear = player:FireTear(firePos, luckDirection, true, false, true, player, 1)
            lucktear = mod:tearModifiers(lucktear, player, true, true, familiar)
        end
    end
end

function mod:onOverclockFrame(player)
    local data = mod:mmaGetPData(player)
    local frame = game:GetFrameCount()
    local firstFrame = false
    if data.MMA_overclockFrame == -1 then
        data.MMA_firingOverclock = nil
        local tempSaveData = json.decode(mod:LoadData())
        if not tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] then
            tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] = {}
        end
        tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())].MMA_firingOverclock = nil
        local jsonString = json.encode(tempSaveData)
        mod:SaveData(jsonString)
        player:TryRemoveNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
        data.MMA_overclockFrame = nil
    elseif data.MMA_overclockFrame and data.MMA_overclockFrame + 20 <= frame and data.MMA_overclockFrame + 500 > frame then
        if data.MMA_overclockFrame + 20 == game:GetFrameCount() and data.MMA_overclockStarted == nil then
            player:AddNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
            data.MMA_overclockStarted = true
            data.MMA_overclockRoom = game:GetLevel():GetCurrentRoomIndex()
            firstFrame = true
        elseif data.MMA_overclockFrame + 21 == game:GetFrameCount() and data.MMA_overclockStarted == true then
            data.MMA_overclockStarted = nil
        end

        if data.MMA_overclockRoom ~= game:GetLevel():GetCurrentRoomIndex() then
            data.MMA_overclockFrame = -1
        end

        if not (player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)) and not screenShaking then
            screenShaking = true
            local framesRemaining = data.MMA_overclockFrame + 500 - frame
            game:ShakeScreen(framesRemaining)
        end

        mod:handleTearsOut_OS(player, firstFrame, nil)
        
    elseif data.MMA_firingOverclock == true and
    data.MMA_overclockFrame and data.MMA_overclockFrame + 500 <= game:GetFrameCount() then
        data.MMA_firingOverclock = nil
        local tempSaveData = json.decode(mod:LoadData())
        tempSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())].MMA_firingOverclock = nil
        local jsonString = json.encode(tempSaveData)
        mod:SaveData(jsonString)
        player:TryRemoveNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
        screenShaking = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onOverclockFrame)

function mod:onLaserUpdate(laser)
    if laser:GetData().MMA_oSPrimeLaser == true then
        local player = mod:getPlayerFromKnifeLaser(laser)
        local playerRotation = mod.directionToVector[player:GetHeadDirection()]:GetAngleDegrees()
        laser.AngleDegrees = playerRotation + (laser:GetData().MMA_AdjustAngle or 0)
    elseif laser:GetData().MMA_oSSubLaser == true then
        laser:SetActiveRotation(0, 25, 15, false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.onLaserUpdate)

function mod:crashBonus(player, cache)
    local data = mod:mmaGetPData(player)
    if cache == CacheFlag.CACHE_DAMAGE and data.crashBonus == true then
        player.Damage = player.Damage * 2
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.crashBonus)

function mod:reticleUpdate(eff)
    local player = mod:getPlayerFromKnifeLaser(eff)
    local data = mod:mmaGetPData(player)
    local frame = game:GetFrameCount()
    local bombTier = math.floor(30 / (player.MaxFireDelay + 1))
    if data.MMA_overclockFrame and data.MMA_overclockFrame + 20 <= frame and data.MMA_overclockFrame + 500 > frame then
        if frame % 4 == 0 and bombTier >= 4 then
            mod:spawnRocket(player, eff.Position)
        elseif frame % 8 == 0 then
            mod:spawnRocket(player, eff.Position)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.reticleUpdate, EffectVariant.TARGET)

function mod:overclockedWispUpdate(wisp)
    if wisp.SubType == mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES then
        local player = wisp.SpawnerEntity
        if player then
            if game:GetFrameCount() % 2 == 0 then
                local direction = (wisp.Position - player.Position):Normalized()
                wisp:FireProjectile(direction)
            end
            local data = mod:mmaGetPData(player)
            if data.MMA_firingOverclock == nil then
                wisp:TakeDamage(13, 0, EntityRef(player), 1)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.overclockedWispUpdate, FamiliarVariant.WISP)


function mod:secondaryTearOverclocked(familiar)
    local player = familiar.Player
    local firstFrame = false
    if player then
        local data = mod:mmaGetPData(player)
        local frame = game:GetFrameCount()
        if data.MMA_overclockFrame and data.MMA_overclockFrame + 20 == game:GetFrameCount() and data.MMA_overclockStarted == nil then
            firstFrame = true
        end
        if data.MMA_overclockFrame and data.MMA_overclockFrame + 20 <= frame and data.MMA_overclockFrame + 500 > frame then
            mod:handleTearsOut_OS(player, firstFrame, familiar)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.secondaryTearOverclocked, FamiliarVariant.INCUBUS)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.secondaryTearOverclocked, FamiliarVariant.TWISTED_BABY)


function mod:knifeUpdate_OS(knife)
    if knife:GetData().MMA_Overclocked_Knife_Frame then
        local player = mod:getPlayerFromKnifeLaser(knife)
        local speed = 37.5 * player.ShotSpeed
        knife.Velocity = knife.Velocity:Normalized() * speed
        knife.Rotation = knife.Velocity:GetAngleDegrees() - 90
        knife:GetSprite().Rotation = knife.Velocity:GetAngleDegrees() - 90
        if knife:GetData().MMA_Overclocked_Knife_Frame + 60 < game:GetFrameCount() then
            knife:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, mod.knifeUpdate_OS)


