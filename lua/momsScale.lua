local mod = MMAMod
local game = Game()
local sfx = SFXManager()

local rng = RNG()
rng:SetSeed(rng:GetSeed(), 35)

local greyColor = Color(1, 1, 1, 1, 0, 0, 0)
greyColor:SetColorize(1, 1, 1, 1)
greyColor:SetTint(5, 5, 5, 2)

if mod.MMA_GlobalSaveData.droppedEnemies == nil then
    mod.MMA_GlobalSaveData.droppedEnemies = {}
end
if mod.MMA_GlobalSaveData.droppedEnemiesDest == nil then
    mod.MMA_GlobalSaveData.droppedEnemiesDest = {}
end

function mod:isBottomFloor()
    local currentFloor = game:GetLevel():GetStage()
    local currentFloorType = game:GetLevel():GetStageType()
    local hasPolaroid = false
    local hasNegative = false

    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_POLAROID) then
            hasPolaroid = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_NEGATIVE) then
            hasNegative = true
        end
        
        if game:IsGreedMode() and currentFloor >= 6 then
            return true
        end

        if not game:IsGreedMode() and ((currentFloor == LevelStage.STAGE4_2 and currentFloorType >=4) or
        (not hasPolaroid and currentFloor == LevelStage.STAGE5 and currentFloorType == StageType.STAGETYPE_WOTL) or
        (not hasNegative and currentFloor == LevelStage.STAGE5 and currentFloorType == StageType.STAGETYPE_ORIGINAL) or
        currentFloor >= 11)
        then
            return true
        end
        return false
    end)
end
local normalSlow = Color(1,1,1,1,0,0,0)
function mod:dropEnemy(enemy, player)
    local room = game:GetRoom()

    if mod:isBasegameSegmented(enemy) then
        enemy = enemy:GetLastParent() or enemy
    end

    local pos = enemy.Position
    if mod.canGeneratePit(enemy.Position, 0, nil, true, true) and not mod:isBottomFloor() and not enemy:IsBoss() then
        local droppedEnemy = {}
        droppedEnemy.Type = enemy.Type
        droppedEnemy.Variant = enemy.Variant
        droppedEnemy.SubType = enemy.SubType
        if enemy:ToNPC():IsChampion() then
            droppedEnemy.ChampionColor = enemy:ToNPC():GetChampionColorIdx()
        end
        if not mod.MMA_GlobalSaveData.droppedEnemies then
            mod.MMA_GlobalSaveData.droppedEnemies = {}
        end
        local dropRNG = enemy:GetDropRNG()
        if dropRNG:RandomInt(100) < 50 then
            table.insert(mod.MMA_GlobalSaveData.droppedEnemies, droppedEnemy)
        end
        for i=1, 3 do
            Isaac.Spawn(1000, 4, 0, room:GetGridPosition(room:GetGridIndex(pos)), RandomVector()*math.random()*5, enemy)
        end
        local index = room:GetGridIndex(pos)
        room:SpawnGridEntity(index, 7, 0, 0, 0)
        mod:UpdatePits(index)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, Options.SFXVolume*2)
        enemy:Remove()
    else
        enemy:AddSlowing(EntityRef(player), 150, 0.5, normalSlow)
    end
end

function mod:MS_onFireTear(tear)
    local player = mod:GetPlayerFromTear(tear)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) then
        local fireRNG = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
        local chance = player.Luck * 3 + 10
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = fireRNG:RandomInt(100)

        if chance_num < chance or mod.DEBUG then
            tear:GetData().MMA_IsPortly = 1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.MS_onFireTear)

function mod:MS_onUpdateTear(tear)
    if tear:GetData().MMA_IsPortly == 1 then -- or tear:GetData().MMA_IsPortly == nil
        local sprite_tear = tear:GetSprite()
        --sprite_tear.Color = greyColor

        tear:GetData().MMA_IsPortly = 2
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.MS_onUpdateTear)

function mod:hitEnemy(tear, collider, low)
    local data = tear:GetData()
    local player = mod:GetPlayerFromTear(tear)
    if player and data.MMA_IsPortly ~= nil and collider:IsVulnerableEnemy() then
        mod:dropEnemy(collider, player)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.hitEnemy)

---------------------------------------------------------------------------
function mod:checkLaser_MS(laser)
    local player = mod:getPlayerFromKnifeLaser(laser)
    local data = laser:GetData()
    local var = laser.Variant
    local subt = laser.SubType
    local ignoreLaserVar = ((var == 1 and subt == 3) or var == 5 or var == 12)
    if laser.Type == EntityType.ENTITY_EFFECT then
        ignoreLaserVar = false
    end
    data.WZ_Player = player

    if player and not ignoreLaserVar then
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) then
            data.Laser_Heavy = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.checkLaser_MS)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.checkLaser_MS, EffectVariant.BRIMSTONE_BALL)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.checkLaser_MS, EffectVariant.BRIMSTONE_SWIRL)

function mod:updateLasers_MS()
    local laserEndpoints = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LASER_IMPACT)
	for i=1, #laserEndpoints do
		local laserEndpoint = laserEndpoints[i]
        if laserEndpoint.SpawnerEntity and laserEndpoint.SpawnerEntity.Type == EntityType.ENTITY_LASER then
            local laser = laserEndpoint.SpawnerEntity
            if laser:GetData().Laser_Heavy == true then
                laserEndpoint.Color = greyColor
            end
        end
	end

    local lasers = Isaac.FindByType(EntityType.ENTITY_LASER)
    for i=1, #lasers do
        local laser = lasers[i]
        if laser:GetData().Laser_Heavy == true then
            laser:GetData().Laser_Heavy = false
            laser.Color = greyColor
        end
    end

    local brimballs = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_BALL)
    for i=1, #brimballs do
        local brimball = brimballs[i]
        if brimball:GetData().Laser_Heavy == true then
            brimball:GetData().Laser_Heavy = false
            brimball.Color = greyColor
        end
    end
    
    local brimswirls = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BRIMSTONE_SWIRL)
    for i=1, #brimswirls do
        local brimswirl = brimswirls[i]
        if brimswirl:GetData().Laser_Heavy == true then
            brimswirl:GetData().Laser_Heavy = false
            brimswirl.Color = greyColor
        end
    end

end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.updateLasers_MS)

function mod:LaserEnemyHit_MS(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() then
        local player
        if source and source.Entity then
            player = source.Entity:ToPlayer()
        end

        if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) and damageflags == damageflags | DamageFlag.DAMAGE_LASER then
            local momRNG = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
            local chance_num = momRNG:RandomInt(100)
            --local chance = player.Luck * 5 + 20
            local chance = player.Luck * 3 + 10
            if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
                chance = chance + 20
            end
            if chance_num < chance then
                mod:dropEnemy(entity, player)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.LaserEnemyHit_MS)


function mod:OnKnifeCollide_MS(knife, collider, low)
    local player = mod:getPlayerFromKnifeLaser(knife)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) and collider:IsVulnerableEnemy() then
        local chance = player.Luck * 3 + 10
        local momRNG = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = momRNG:RandomInt(100)
        if chance_num < chance then
            mod:dropEnemy(collider, player)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, mod.OnKnifeCollide_MS)


---------------------------------------------------------------------------
local ReturnFlag = {}
ReturnFlag.RF_RANDOM_EMPTY = 0
ReturnFlag.RF_BOSS = 1

function mod:checkFloorRooms_MS()
    local roomcount = 0
    for i=0, 168, 1 do
        local room = game:GetLevel():GetRoomByIdx(i) 
        if room.Data and room.Data.Type == RoomType.ROOM_DEFAULT then
            roomcount = roomcount + 1
        end
    end
    return roomcount
end

function mod:onNewFloor_MS()
    if mod.MMA_GlobalSaveData.droppedEnemies and #mod.MMA_GlobalSaveData.droppedEnemies > 0 then
        if not mod.MMA_GlobalSaveData.droppedEnemiesDest then
            mod.MMA_GlobalSaveData.droppedEnemiesDest = {}
        end
        for i=1, #mod.MMA_GlobalSaveData.droppedEnemies, 1 do
            local oldTab = mod.MMA_GlobalSaveData.droppedEnemies[i]
            local newTab = {}
            newTab.Type = oldTab.Type
            newTab.Variant = oldTab.Variant
            newTab.SubType = oldTab.SubType
            newTab.ChampionColor = oldTab.ChampionColor

            table.insert(mod.MMA_GlobalSaveData.droppedEnemiesDest, newTab)
        end
        mod.MMA_GlobalSaveData.droppedEnemies = {}
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor_MS)

function mod:onNewRoom_MS(isGreedWave)
    local room = game:GetRoom()
    local cleared = room:IsClear()
    local scaleRNG = nil
    local player_source
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) then
            scaleRNG = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
            player_source = player
        end
    end)

    if not mod.MMA_GlobalSaveData.RecycledEnemies then
        mod.MMA_GlobalSaveData.RecycledEnemies = {}
    end

    if #mod.MMA_GlobalSaveData.RecycledEnemies > 0 and not game:IsGreedMode() then
        for i=1, #mod.MMA_GlobalSaveData.RecycledEnemies, 1 do
            local oldTab = table.remove(mod.MMA_GlobalSaveData.RecycledEnemies, 1)
            table.insert(mod.MMA_GlobalSaveData.droppedEnemiesDest, oldTab)
        end
    end

    if scaleRNG and mod.MMA_GlobalSaveData.droppedEnemiesDest and #mod.MMA_GlobalSaveData.droppedEnemiesDest > 0 and not cleared then
        local chance = scaleRNG:RandomInt(99)+1
        local avgrooms = mod:checkFloorRooms_MS()
        local probability = math.floor(100 * (#mod.MMA_GlobalSaveData.droppedEnemiesDest/avgrooms))
        if chance <= probability then
            local upperbound = math.ceil(probability/100) + 2
            local enemiesToSpawn = math.min(scaleRNG:RandomInt(upperbound), #mod.MMA_GlobalSaveData.droppedEnemiesDest)
            for i=0, enemiesToSpawn, 1 do
                local profile = table.remove(mod.MMA_GlobalSaveData.droppedEnemiesDest, scaleRNG:RandomInt(#mod.MMA_GlobalSaveData.droppedEnemiesDest)+1)
                local position = room:GetRandomPosition(40)
                local enemy = Isaac.Spawn(profile.Type, profile.Variant, profile.SubType, position, Vector(0, 0), nil)
                enemy:AddConfusion(EntityRef(player_source), 60, true)
                if mod.DEBUG then
                    sfx:Play(SoundEffect.SOUND_COIN_INSERT)
                    enemy:AddFear(EntityRef(enemy), 60)
                end
                if profile.ChampionColor ~= nil then
                    enemy:ToNPC():MakeChampion(rng:RandomInt(100000)+1, profile.ChampionColor)
                end
                table.insert(mod.MMA_GlobalSaveData.RecycledEnemies, profile)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom_MS)

--todo: set up leftover table for if the player leaves the room without clearing it

function mod:OnRoomClear_MS(xrng, spawnposition)
    if mod.MMA_GlobalSaveData.RecycledEnemies then
        mod.MMA_GlobalSaveData.RecycledEnemies = {}
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear_MS)

function mod:onGreedUpdate_MS()
    if game:IsGreedMode() and mod.MMA_GlobalSaveData.MMA_GreedWave ~= game:GetLevel().GreedModeWave then
        mod:onNewRoom_MS(true)
        mod.MMA_GlobalSaveData.MMA_GreedWave = game:GetLevel().GreedModeWave
    end
end
if mod.SINGLE_ITEM then
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onGreedUpdate_MS)
end

--if it gets bad, account for spawning enemies randomly on top of the player
--we'll also need to make sure segmented enemy spawns are accounted for


local function getTearScale13(tear)
	local sprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags
	
	if scale > 2.55 then
        return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
	elseif flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
		if scale <= 0.3 then
			return Vector((scale * sizeMulti.X) / 0.25, (scale * sizeMulti.Y) / 0.25)
		elseif scale <= 0.55 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 1.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.125) * 0.125 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 2.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		else
			return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
		end
    else
        return sizeMulti
	end
end

function mod:scaleTearRender(tear, offset)
	local data = tear:GetData()
    if data.MMA_IsPortly == nil then
        return
    end

	local sprite = mod.MMA_GlobalSaveData.ScaleSprite
	if not mod.MMA_GlobalSaveData.ScaleSprite then
		sprite = Sprite()
		sprite:Load("gfx/tear_scale.anm2", true)
		sprite:LoadGraphics()
		mod.MMA_GlobalSaveData.ScaleSprite = sprite
	end

	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags

	local anim
	if scale <= 0.3 then
		anim = "RegularTear1"
	elseif scale <= 0.55 then
		anim = "RegularTear2"
	elseif scale <= 0.675 then
		anim = "RegularTear3"
	elseif scale <= 0.8 then
		anim = "RegularTear4"
	elseif scale <= 0.925 then
		anim = "RegularTear5"
	elseif scale <= 1.05 then
		anim = "RegularTear6"
	elseif scale <= 1.175 then
		anim = "RegularTear7"
	elseif scale <= 1.425 then
		anim = "RegularTear8"
	elseif scale <= 1.675 then
		anim = "RegularTear9"
	elseif scale <= 1.925 then
		anim = "RegularTear10"
	elseif scale <= 2.175 then
		anim = "RegularTear11"
	elseif scale <= 2.55 then
		anim = "RegularTear12"
	else
		anim = "RegularTear13"
	end

	sprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not sprite:IsPlaying(anim) then
		local frame = sprite:GetFrame()
		sprite:Play(anim, true)
		sprite:SetFrame(frame)
	elseif not game:IsPaused() and Isaac.GetFrameCount() % 2 == 0 and data.MMA_LastRenderFrame ~= Isaac.GetFrameCount() then
		sprite:Update()
	end

	local spritescale = getTearScale13(tear)
	sprite.Scale = spritescale
	sprite.Color = tearsprite.Color
---@diagnostic disable-next-line: param-type-mismatch
	sprite:Render(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset, Vector.Zero, Vector.Zero)
	data.MMA_LastRenderFrame = Isaac.GetFrameCount()
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, mod.scaleTearRender)
