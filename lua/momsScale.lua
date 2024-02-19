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

function mod:dropEnemy(enemy, player)
    local room = game:GetRoom()

    if mod:isBasegameSegmented(enemy) then
        enemy = enemy:GetLastParent() or enemy
    end

    local pos = enemy.Position
    if mod.canGeneratePit(enemy.Position, 0, nil, true, true) then
        local droppedEnemy = {}
        droppedEnemy.Type = enemy.Type
        droppedEnemy.Variant = enemy.Variant
        droppedEnemy.SubType = enemy.SubType
        if enemy:ToNPC():IsChampion() then
            droppedEnemy.ChampionColor = enemy:ToNPC():GetChampionColorIdx()
        end
        table.insert(mod.MMA_GlobalSaveData.droppedEnemies, droppedEnemy)
        for i=1, 3 do
            Isaac.Spawn(1000, 4, 0, room:GetGridPosition(room:GetGridIndex(pos)), RandomVector()*math.random()*5, enemy)
        end
        local index = room:GetGridIndex(pos)
        room:SpawnGridEntity(index, 7, 0, 0, 0)
        mod:UpdatePits(index)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, Options.SFXVolume*2)
        enemy:Remove()
    else
        enemy:AddSlowing(EntityRef(player), 150, 0.5, greyColor)
    end
end

function mod:MS_onFireTear(tear)
    local player = mod:GetPlayerFromTear(tear)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) then
        local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
        local chance = player.Luck * 5 + 10
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)

        if chance_num < chance or mod.DEBUG then
            tear:GetData().MMA_IsPortly = 1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.MS_onFireTear)

function mod:MS_onUpdateTear(tear)
    if tear:GetData().MMA_IsPortly == 1 then -- or tear:GetData().MMA_IsPortly == nil
        local sprite_tear = tear:GetSprite()
        sprite_tear.Color = greyColor
        tear:GetData().MMA_IsPortly = 2
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.MS_onUpdateTear)

function mod:hitEnemy(tear, collider, low)
    local data = tear:GetData()
    local player = mod:GetPlayerFromTear(tear)
    if player and data.MMA_IsPortly ~= nil and collider:IsVulnerableEnemy() and not collider:IsBoss() then
        mod:dropEnemy(collider, player)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.hitEnemy)

---------------------------------------------------------------------------
function mod:checkLaser_MS(laser)
    local player = mod:getPlayerFromKnifeLaser(laser)
    local pdata = player and mod:mmaGetPData(player)
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
            local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)

            if laser.Type == EntityType.ENTITY_EFFECT and laser.Variant == EffectVariant.BRIMSTONE_SWIRL then
                
            end

            local chance = player.Luck * 5 + 10
            if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
                chance = chance + 20
            end
            local chance_num = rng:RandomInt(100)
            if chance_num < chance then
                data.Laser_Heavy = true
                pdata.LaserHeavy = true
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, mod.checkLaser_MS)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.checkLaser_MS, EffectVariant.BRIMSTONE_BALL)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.checkLaser_MS, EffectVariant.BRIMSTONE_SWIRL)

function mod:updateLasersPlayer_MS(player)
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
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.updateLasersPlayer_MS)

function mod:LaserEnemyHit_MS(entity, amount, damageflags, source, countdownframes)
    if entity:IsVulnerableEnemy() and not entity:IsBoss() then
        local player
        local pdata
        if source and source.Entity then
            player = source.Entity:ToPlayer()
        end
        if player then
            pdata = mod:mmaGetPData(player)
        end
        if pdata and pdata.LaserHeavy == true then
            player:GetData().LaserHeavy = false
            mod:dropEnemy(entity, player)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.LaserEnemyHit_MS)


function mod:OnKnifeCollide_MS(knife, collider, low)
    local player = mod:getPlayerFromKnifeLaser(knife)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) and collider:IsVulnerableEnemy() and not collider:IsBoss() then
        local chance = player.Luck * 5 + 10
        local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
        if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
            chance = chance + 20
        end
        local chance_num = rng:RandomInt(100)
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

function mod:checkFloorRooms_MS(returnFlag)
    local player = Isaac.GetPlayer(0)
    local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_MOMS_SCALE)
    for i=0, 90000, 1 do
        local randomroom = rng:RandomInt(169)
        local roomid = game:GetLevel():GetRoomByIdx(randomroom)
        if roomid and roomid.Data and
        not roomid.Clear and
        randomroom ~= 84 and
        (returnFlag ~= ReturnFlag.RF_BOSS or roomid.Data.Type == RoomType.ROOM_BOSS) and
        (returnFlag ~= ReturnFlag.RF_RANDOM_EMPTY or roomid.Data.Type == RoomType.ROOM_DEFAULT)
        then
            return randomroom
        end
    end
    return -1
end

function mod:onNewFloor_MS()
    if mod.MMA_GlobalSaveData.droppedEnemies and #mod.MMA_GlobalSaveData.droppedEnemies > 0 then
        for i=1, #mod.MMA_GlobalSaveData.droppedEnemies, 1 do
            local newRoom
            if game:IsGreedMode() then
                local totalWaves = 11
                if game.Difficulty == Difficulty.DIFFICULTY_GREEDIER then
                    totalWaves = 12
                end
                newRoom = rng:RandomInt(totalWaves) + 1
            else
                newRoom = mod:checkFloorRooms_MS(ReturnFlag.RF_RANDOM_EMPTY)
            end
            
            if mod.MMA_GlobalSaveData.droppedEnemiesDest[newRoom] == nil then
                mod.MMA_GlobalSaveData.droppedEnemiesDest[newRoom] = {}
            end
            local oldTab = mod.MMA_GlobalSaveData.droppedEnemies[i]
            local newTab ={}
            newTab.Type = oldTab.Type
            newTab.Variant = oldTab.Variant
            newTab.SubType = oldTab.SubType
            newTab.ChampionColor = oldTab.ChampionColor

            table.insert(mod.MMA_GlobalSaveData.droppedEnemiesDest[newRoom], newTab)
            --print(newRoom)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor_MS)

function mod:onNewRoom_MS(isGreedWave)
    local currentroomindex = game:GetLevel():GetCurrentRoomIndex()
    if game:IsGreedMode() then
        if not isGreedWave then
            return
        end
        currentroomindex = mod.MMA_GlobalSaveData.MMA_GreedWave
    end
    local bossroomindex = mod:checkFloorRooms_MS(ReturnFlag.RF_BOSS)
    if mod.MMA_GlobalSaveData.droppedEnemiesDest and mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex] == nil then
        mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex] = {}
    end
    local room = game:GetRoom()
    local cleared = room:IsClear() and not isGreedWave
    if mod.MMA_GlobalSaveData.droppedEnemiesDest and mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] ~= nil then
        for u=1, #mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] do
            local profile = mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex][u]
            if cleared then
                table.insert(mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex], profile)
                mod:OnRoomClear_MS(nil, nil)
            elseif game:IsGreedMode() then
                mod:OnRoomClear_MS(nil, nil)
            else
                local position = room:GetRandomPosition(40)
                local enemy = Isaac.Spawn(profile.Type, profile.Variant, profile.SubType, position, Vector(0, 0), nil)
                if profile.ChampionColor ~= nil then
                    enemy:MakeChampion(profile.ChampionColor)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.onNewRoom_MS)

function mod:OnRoomClear_MS(rng, spawnposition)
    local currentroomindex = game:GetLevel():GetCurrentRoomIndex()
    if game:IsGreedMode() then
        currentroomindex = mod.MMA_GlobalSaveData.MMA_GreedWave
    end
    if mod.MMA_GlobalSaveData.droppedEnemiesDest and mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] ~= nil then
        for u=1, #mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] do
            table.remove(mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex])
        end
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