local mod = MMAMod
local game = Game()
local itemConfig = Isaac.GetItemConfig()
local sfx = SFXManager()
local itemPool = game:GetItemPool()

function mod:getHopeSpr(pickup_num)
    local hopeSpr = Sprite()
    hopeSpr:Load("gfx/005.100_collectible.anm2", true)
    hopeSpr:Play("PlayerPickup")
    hopeSpr:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(pickup_num).GfxFileName)
    hopeSpr:LoadGraphics()
    return hopeSpr
end

function mod:findHopeRenderPos(sequence, numPlayers, current_player_num)
    local starting_pos = Vector(-32, -32)
    if sequence > 6 then
        return starting_pos
    end
    local xoffset = (math.floor((sequence-1)/3)) * 32
    local yoffset = ((sequence-1) % 3) * 32
    local player = Isaac.GetPlayer(current_player_num)

    if Options.ExtraHUDStyle == 1 then
        xoffset = xoffset+72
        yoffset = yoffset+28
    elseif numPlayers == 4 or Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_JACOB then
        xoffset = xoffset + 4
        yoffset = yoffset + 47
    end
    
    starting_pos = Vector(Isaac.GetScreenWidth()-(26+xoffset), Isaac.GetScreenHeight()-(45+yoffset))
    return starting_pos
end

function mod:hopesAward(player)
    --sfx:Play(SoundEffect.SOUND_MEGA_TRIPLE_QUESTION_MARK)
    sfx:Play(SoundEffect.SOUND_BEAST_ANGELIC_BLAST)
    local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)
    local pool = ItemPoolType.POOL_ANGEL
    local data = mod:mmaGetPData(player)

    player:AnimateCollectible(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)

    data.bonusDamage = mod:isNil(data.bonusDamage, 0) + .5
    data.bonusLuck = mod:isNil(data.bonusLuck, 0) + 5
    data.bonusRange = mod:isNil(data.bonusRange, 0) + 100
    data.bonusFireDelay = mod:isNil(data.bonusFireDelay, 0) + .5
    data.bonusSpeed = mod:isNil(data.bonusSpeed, 0) + .2
    player:AddMaxHearts(2)
    player:AddHearts(2)
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
    
    if game:IsGreedMode() then
        pool = ItemPoolType.POOL_GREED_ANGEL
    end
    for i=1, 4, 1 do
        local itemType = itemPool:GetCollectible(pool, true, rng:RandomInt(100000)+1)
        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemType, spawnPos, Vector(0,0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, spawnPos, Vector(0,0), nil)
    end
    player:UseCard(Card.CARD_SOUL_KEEPER, 257)
    player:UseCard(Card.CARD_SOUL_KEEPER, 257)
end

function mod:hopesRender()
    local data = mod.MMA_GlobalSaveData
    if data.hopesItems == nil then
        data.hopesItems = {}
    end
    local totalHopeItems = 0
    local rng
    mod:AnyPlayerDo(function(player)
        totalHopeItems = totalHopeItems + player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)
        if player:GetCollectibleNum(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS) > 0 then
            rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)
        end
        end)
    if #data.hopesItems < totalHopeItems then
        for i=1, totalHopeItems - #data.hopesItems, 1 do
            local tableIn = {}
            local pickup_num
            for j = 1, 10000 do
                pickup_num = rng:RandomInt(itemConfig:GetCollectibles().Size-1)
                if itemConfig:GetCollectible(pickup_num)and itemConfig:GetCollectible(pickup_num):IsAvailable()
                and not (pickup_num >= 550 and pickup_num <= 552) and pickup_num ~= 714 and pickup_num ~= 715 then
                    break
                end
            end
            tableIn.subType = pickup_num
            tableIn.obtained = false

            tableIn.sprite = mod:getHopeSpr(pickup_num)
            table.insert(data.hopesItems, tableIn)
        end
    end
    local sequence = 1
    for i, item in ipairs(data.hopesItems) do
        if not item.obtained then
            mod:AnyPlayerDo(function(player)
                if player:HasCollectible(item.subType) or
                (player:GetOtherTwin() ~= nil and player:GetOtherTwin():HasCollectible(item.subType)) then
                    item.obtained = true
                    mod:hopesAward(player)
                end
            end)
            local pos = mod:findHopeRenderPos(sequence,  game:GetNumPlayers())
            if item.sprite == nil then
                item.sprite = mod:getHopeSpr(item.subType)
            end
            item.sprite:Render(pos)
            sequence = sequence + 1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.hopesRender)
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.hopesRender)

--rain bucket already calculates bonus stats, keep this in case items are published individually
function mod:bonusStatsCache_HAD(player, cache)
    local data = mod:mmaGetPData(player)
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + mod:isNil(data.bonusDamage, 0)
    end
    if cache == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + mod:isNil(data.bonusRange, 0)
    end
    if cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + mod:isNil(data.bonusLuck, 0)
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + mod:isNil(data.bonusSpeed, 0)
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        local teartoadd = mod:isNil(data.bonusFireDelay, 0)
        player.MaxFireDelay = mod:tearsUp(player.MaxFireDelay, teartoadd)
    end
end
--mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bonusStatsCache_HAD)


--star background for items to be attained