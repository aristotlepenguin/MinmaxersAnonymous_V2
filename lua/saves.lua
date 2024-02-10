local json = require("json")
local mod = MMAMod

local game = Game()
local hiddenItemManager = require("lib.hidden_item_manager")

function mod:saveData()
    --mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
    local numPlayers = game:GetNumPlayers()
    mod.MMA_GlobalSaveData.PlayerData = {}

    local hiddenItemData = hiddenItemManager:GetSaveData()
    mod.MMA_GlobalSaveData.HIDDEN_ITEM_DATA = hiddenItemData

    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)

        if not player:GetData().mmaSaveData then
            player:GetData().mmaSaveData = {}
        end
        player:GetData().mmaSaveData.MMA_firingOverclock = nil

        mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] = player:GetData().mmaSaveData
    end
    local jsonString = json.encode(mod.MMA_GlobalSaveData)
    mod:SaveData(jsonString)
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveData)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveData)

function mod:loadData(isSave)
    if mod:HasData() and isSave then
        local numPlayers = game:GetNumPlayers()
        mod.MMA_GlobalSaveData = json.decode(mod:LoadData())
        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            if mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] then
                player:GetData().mmaSaveData = mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())]
                player:GetData().mmaSaveData.MMA_overclockFrame = nil
                if player:GetData().mmaSaveData.MMA_firingOverclock == true then
                    player:GetData().mmaSaveData.crashBonus = true
                    player:GetData().mmaSaveData.MMA_firingOverclock = nil
                    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES then
                        player:RemoveCollectible(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, false, ActiveSlot.SLOT_PRIMARY)
                    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES then
                        player:RemoveCollectible(mod.MMATypes.COLLECTIBLE_OVERCLOCKED_SINUSES, false, ActiveSlot.SLOT_SECONDARY)
                    end
                end
            end
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
        hiddenItemManager:LoadData(mod.MMA_GlobalSaveData.HIDDEN_ITEM_DATA)
    else
        mod.MMA_GlobalSaveData = {}
        mod:AnyPlayerDo(function(player)
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
        end)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadData)

function mod:mmaGetPData(player)
    local data = player:GetData()
    if data.mmaSaveData == nil then
        data.mmaSaveData = {}
    end
    return data.mmaSaveData
end

