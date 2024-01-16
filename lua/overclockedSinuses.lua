local json = require("json")
local mod = MMAMod
local game = Game()

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

function mod:tearModifiers(tear, player, isPrimaryTear)
    
    if isPrimaryTear then
        tear.Scale = tear.Scale * 3.5
        tear:ResetSpriteScale()
    end

    if player.TearRange >= 560 then
        --tear:AddTearFlags(TearFlags.TEAR_CONTINUUM)
        tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    end

    return tear
end
--mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveData)

function mod:onOverclockFrame(player)
    local data = mod:mmaGetPData(player)
    local frame = game:GetFrameCount()
    if data.MMA_overclockFrame and data.MMA_overclockFrame + 20 <= frame and data.MMA_overclockFrame + 500 > frame then
        local tearTier = math.floor(30 / (player.MaxFireDelay + 1))
        local sinusRng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES)
        local tearSpeed = 25 * player.ShotSpeed
        local firePos = player.Position + Vector(0, 1)
        local direction = mod.directionToVector[player:GetHeadDirection()] * tearSpeed
        local firstFrame = false
        if data.MMA_overclockFrame + 20 == game:GetFrameCount() and data.MMA_overclockStarted == nil then
            player:AddNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
            data.MMA_overclockStarted = true
            firstFrame = true
        elseif data.MMA_overclockFrame + 21 == game:GetFrameCount() and data.MMA_overclockStarted == true then
            data.MMA_overclockStarted = nil
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            if firstFrame then
                local primeLaser = EntityLaser.ShootAngle(6, player.Position, direction:GetAngleDegrees(), 500, Vector(0, 0), player)
                primeLaser:GetData().MMA_oSPrimeLaser = true
                primeLaser:AddTearFlags(player.TearFlags)
                primeLaser.Color = player.LaserColor
                local laserTier = math.floor((30 / (player.MaxFireDelay + 1))*4)
                for j=1, laserTier, 1 do
                    local directionSub = 0 + j * math.floor(360/laserTier)
                    local subLaser = EntityLaser.ShootAngle(1, player.Position, directionSub, 500, Vector(0, 0), player)
                    subLaser:GetData().MMA_oSSubLaser = true
                    subLaser:AddTearFlags(player.TearFlags)
                    subLaser.Color = player.LaserColor
                end

            end
            if sinusRng:RandomInt(100) <= player.Luck + 5 then
                local luckDirection = sinusRng:RandomInt(361)
                local laserluck = EntityLaser.ShootAngle(1, player.Position, luckDirection, 9, Vector(0, 0), player)
                laserluck:AddTearFlags(player.TearFlags)
                laserluck.Color = player.LaserColor
            end
        else
            if tearTier >= 3 or frame % 2 == 0 then
                local tear = player:FireTear(firePos, direction, true, false, true, player, 1)
                tear = mod:tearModifiers(tear, player, true)
            end
            
            if tearTier >= 4 then
                local slantDir
                if frame % 2 == 0 then
                    slantDir = mod.GetLeftDiag[player:GetHeadDirection()]
                else
                    slantDir = mod.GetRightDiag[player:GetHeadDirection()]
                end
                
                for x=4, tearTier, 1 do
                    local tear = player:FireTear(firePos, slantDir * tearSpeed, true, false, true, player, 1)
                    slantDir = (slantDir * mod.TearTierMultiplier[player:GetHeadDirection()]):Normalized()
                    tear = mod:tearModifiers(tear, player, false)
                end
            end

            if sinusRng:RandomInt(100) <= player.Luck + 5 then
                local luckDirection = Vector(sinusRng:RandomInt(100)-50, sinusRng:RandomInt(100)-50):Normalized() * tearSpeed
                local lucktear = player:FireTear(firePos, luckDirection, true, false, true, player, 1)
                lucktear = mod:tearModifiers(lucktear, player, true)
            end
        end
    elseif mod.MMA_GlobalSaveData.MMA_firingOverclock == true and
    data.MMA_overclockFrame and data.MMA_overclockFrame + 500 <= game:GetFrameCount() then
        mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
        player:TryRemoveNullCostume(mod.MMATypes.COSTUME_FIRE_OVERCLOCK)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.onOverclockFrame)

function mod:onLaserUpdate(laser)
    if laser:GetData().MMA_oSPrimeLaser == true then
        local player = mod:getPlayerFromKnifeLaser(laser)
        local playerRotation = mod.directionToVector[player:GetHeadDirection()]:GetAngleDegrees()
        laser.AngleDegrees = playerRotation
    elseif laser:GetData().MMA_oSSubLaser == true then
        laser:SetActiveRotation(0, 25, 15, false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, mod.onLaserUpdate)

function mod:crashBonus(player, cache)
    if cache == CacheFlag.CACHE_DAMAGE and mod.MMA_GlobalSaveData.crashBonus == true then
        player.Damage = player.Damage + 3
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.crashBonus)