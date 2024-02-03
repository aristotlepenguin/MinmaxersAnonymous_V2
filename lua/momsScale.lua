local mod = MMAMod
local game = Game()
local sfx = SFXManager()

local greyColor = Color(1, 1, 1, 1, 0, 0, 0)
greyColor:SetColorize(1, 1, 1, 1)
greyColor:SetTint(5, 5, 5, 2)

if mod.MMA_GlobalSaveData.droppedEnemies == nil then
    mod.MMA_GlobalSaveData.droppedEnemies = {}
end

function mod:dropEnemy(enemy, player)
    local room = game:GetRoom()
    local pos = enemy.Position
    if mod.canGeneratePit(enemy.Position, 0, nil, true, true) then
        local droppedEnemy = {}
        droppedEnemy.Type = enemy.Type
        droppedEnemy.Variant = enemy.Variant
        droppedEnemy.SubType = enemy.SubType
        if enemy:IsChampion() then
            droppedEnemy.ChampionColor = enemy:GetChampionColorIdx()
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
        enemy:AddSlowing(nil, 150, 0.5, greyColor)
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

        if chance_num < chance then
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


function mod:checkFloorRooms_MS(countAllRooms, returnInt)
    for i=0, 168, 1 do
        local roomid = game:GetLevel():GetRoomByIdx(i)
        if roomid and roomid.Data and 
        (not roomid.Clear or countAllRooms) and 
        roomid.Data.Type ~= RoomType.ROOM_ULTRASECRET and 
        roomid.SafeGridIndex == i and not
        (roomid.Data.Type >=7 and roomid.Data.Type <=8 and roomid.DisplayFlags == 0) then
            local jn = 1
        end
    end
end

function mod:onNewFloor()
    if #mod.MMA_GlobalSaveData.droppedEnemies > 0 then
        local s = 1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewFloor)