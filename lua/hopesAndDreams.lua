local mod = MMAMod
local game = Game()
local itemConfig = Isaac.GetItemConfig()
local sfx = SFXManager()
local itemPool = game:GetItemPool()

function mod:getHopeSpr(pickup_num)
    local hopeSpr = Sprite()
    hopeSpr:Load("gfx/collectible_star.anm2", true)
    hopeSpr:Play("PlayerPickup")
    hopeSpr:ReplaceSpritesheet(0, Isaac.GetItemConfig():GetCollectible(pickup_num).GfxFileName)
    hopeSpr:LoadGraphics()
    return hopeSpr
end

function mod:IsInDCDimension()
    local desc = game:GetLevel():GetCurrentRoomDesc()
    if desc.Data and (desc.Data.StageID == 35 and (desc.Data.Subtype == 33 or desc.Data.Subtype == 34)) then
        return true
    end
    print(desc.Data.StageID)
    print(desc.Data.Subtype)
    return false
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
    return starting_pos + game.ScreenShakeOffset + (Options.HUDOffset * Vector(-20, -12)) + Vector(14, 8.4)
end

function mod:hopesAward(player)
    --sfx:Play(SoundEffect.SOUND_MEGA_TRIPLE_QUESTION_MARK)
    sfx:Play(SoundEffect.SOUND_BEAST_ANGELIC_BLAST, Options.SFXVolume*4)
    local rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)
    local pool = ItemPoolType.POOL_ANGEL
    local data = mod:mmaGetPData(player)

    player:AnimateCollectible(mod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)

    data.bonusDamage = (data.bonusDamage or 0) + .5
    data.bonusLuck = (data.bonusLuck or 0) + 5
    data.bonusRange = (data.bonusRange or 0) + 100
    data.bonusFireDelay = (data.bonusFireDelay or 0) + .5
    data.bonusSpeed = (data.bonusSpeed or 0) + .2
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
                local alreadyhas = false
                mod:AnyPlayerDo(function(player)
                    if player:HasCollectible(pickup_num) then
                        alreadyhas = true
                    end
                end)
                if itemConfig:GetCollectible(pickup_num)and itemConfig:GetCollectible(pickup_num):IsAvailable()
                and not (pickup_num >= 550 and pickup_num <= 552) and pickup_num ~= 714 and pickup_num ~= 715 and
                ((mod.MenuData and mod.MenuData.HopesItemSelect == 2) or not alreadyhas) then
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
                if (player:HasCollectible(item.subType) or
                (player:GetOtherTwin() ~= nil and player:GetOtherTwin():HasCollectible(item.subType))) and not mod:IsInDCDimension() then
                    item.obtained = true
                    mod:hopesAward(player)
                end
            end)
            local pos = mod:findHopeRenderPos(sequence,  game:GetNumPlayers())
            if item.sprite == nil then
                item.sprite = mod:getHopeSpr(item.subType)
            end
            mod:AnyPlayerDo(function(player)
                if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
                    mod.MMA_GlobalSaveData.LastTimeTabbed = game:GetFrameCount()
                end
            end)

            if game:GetHUD():IsVisible() then
                if (mod.MMA_GlobalSaveData.LastTimeTabbed or 0) == game:GetFrameCount() or (mod.MMA_GlobalSaveData.LastTimePickedUp_HD or 0) + 150 > game:GetFrameCount() then
                    local opaqueColor = Color.Default
                    opaqueColor:SetTint(1, 1, 1, 1)
                    item.sprite.Color = opaqueColor
                    item.sprite:Render(pos)
                elseif (mod.MMA_GlobalSaveData.LastTimeTabbed or 0) + 60 > game:GetFrameCount() or (mod.MMA_GlobalSaveData.LastTimePickedUp_HD or 0) + 300 > game:GetFrameCount() then
                    local transparentColor = Color.Default
                    transparentColor:SetTint(1, 1, 1, 0.2)
                    item.sprite.Color = transparentColor
                    item.sprite:Render(pos)
                
                end
            end
            sequence = sequence + 1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.hopesRender)
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, mod.hopesRender)

mod.ItemGrabCallback:AddCallback(mod.ItemGrabCallback.InventoryCallback.POST_ADD_ITEM, function(player, item, count, touched, fromQueue)
    if not touched or not fromQueue then
        mod.MMA_GlobalSaveData.LastTimePickedUp_HD = game:GetFrameCount()
    end
end, MMAMod.MMATypes.COLLECTIBLE_HOPES_AND_DREAMS)

--rain bucket already calculates bonus stats, keep this in case items are published individually
function mod:bonusStatsCache_HAD(player, cache)
    local data = mod:mmaGetPData(player)
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (data.bonusDamage or 0)
    end
    if cache == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + (data.bonusRange or 0)
    end
    if cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (data.bonusLuck or 0)
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (data.bonusSpeed or 0)
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        local teartoadd = (data.bonusFireDelay or 0)
        player.MaxFireDelay = mod:tearsUp(player.MaxFireDelay, teartoadd)
    end
end
--mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.bonusStatsCache_HAD)


--star background for items to be attained