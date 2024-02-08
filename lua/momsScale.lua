local mod = MMAMod
local game = Game()
local sfx = SFXManager()

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

        if chance_num < chance or true then
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
            local newRoom = mod:checkFloorRooms_MS(ReturnFlag.RF_RANDOM_EMPTY)
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
            print(newRoom)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor_MS)

function mod:onNewRoom_MS()
    local currentroomindex = game:GetLevel():GetCurrentRoomIndex()
    local bossroomindex = mod:checkFloorRooms_MS(ReturnFlag.RF_BOSS)
    if mod.MMA_GlobalSaveData.droppedEnemiesDest and mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex] == nil then
        mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex] = {}
    end
    local room = game:GetRoom()
    local cleared = room:IsClear()
    if mod.MMA_GlobalSaveData.droppedEnemiesDest and mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] ~= nil then
        for u=1, #mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] do
            local profile = mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex][u]
            if cleared then
                table.insert(mod.MMA_GlobalSaveData.droppedEnemiesDest[bossroomindex], profile)
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
    if mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] ~= nil then
        for u=1, #mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex] do
            table.remove(mod.MMA_GlobalSaveData.droppedEnemiesDest[currentroomindex])
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.OnRoomClear_MS)

--if it gets bad, account for spawning enemies randomly on top of the player
--we'll also need to make sure segmented enemy spawns are accounted for