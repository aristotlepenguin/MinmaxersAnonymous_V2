local mod = MMAMod
local game = Game()
local sfx = SFXManager()

local greyColor = Color(1, 1, 1, 1, 0, 0, 0)
greyColor:SetColorize(1, 1, 1, 1)
greyColor:SetTint(5, 5, 5, 2)

function mod:dropEnemy(enemy, player)
    local room = game:GetRoom()
    local pos = enemy.Position
    if mod.canGeneratePit(enemy.Position, 0, nil, true, true) then
        for i=1, 3 do
            Isaac.Spawn(1000, 4, 0, room:GetGridPosition(room:GetGridIndex(pos)), RandomVector()*math.random()*5, enemy)
        end
        local index = room:GetGridIndex(pos)
        room:SpawnGridEntity(index, 7, 0, 0, 0)
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
        enemy:Remove()
    else
        enemy:AddSlowing(nil, 150, 0.5, greyColor)
    end
end

function mod:MS_onFireTear(tear)
    local player = mod:GetPlayerFromTear(tear)
    if player and player:HasCollectible(mod.MMATypes.COLLECTIBLE_MOMS_SCALE) or true then
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
        print("ding!")
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