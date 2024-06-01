local json = require("json")
local mod = MMAMod

local game = Game()
local hiddenItemManager = require("lib.hidden_item_manager")

function mod:savePersistentData()
    local loadedData = json.decode(mod:LoadData())
    loadedData.MenuData = mod.MenuData
    local jsonString = json.encode(loadedData)
    mod:SaveData(jsonString)
end

function mod:saveData()
    --mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
    local numPlayers = game:GetNumPlayers()
    mod.MMA_GlobalSaveData.PlayerData = {}

    local hiddenItemData = hiddenItemManager:GetSaveData()
    mod.MMA_GlobalSaveData.HIDDEN_ITEM_DATA = hiddenItemData

    if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
        mod.MMA_GlobalSaveData.crashWarning = nil
    end

    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)

        if not player:GetData().mmaSaveData then
            player:GetData().mmaSaveData = {}
        end
        player:GetData().mmaSaveData.MMA_firingOverclock = nil

        mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] = player:GetData().mmaSaveData
    end

    mod.MMA_GlobalSaveData.MenuData = mod.MenuData

    local jsonString = json.encode(mod.MMA_GlobalSaveData)
    mod:SaveData(jsonString)
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveData)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveData)

function mod:loadData_MMA(isSave)
    if mod:HasData() and isSave then
        local numPlayers = game:GetNumPlayers()
        mod.MMA_GlobalSaveData = json.decode(mod:LoadData())
        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            if mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] then
                player:GetData().mmaSaveData = mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())]
                player:GetData().mmaSaveData.MMA_overclockFrame = -1
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
        mod.MenuData = mod.MMA_GlobalSaveData.MenuData
        if Isaac.GetChallenge() == mod.MMATypes.CHALLENGE_SCORE_ASSAULT then
            if mod.MMA_GlobalSaveData.crashWarning ~= nil and not mod:checkIfAchieved("crashGame") then
                mod:applyAchievement("crashGame", 70000, "Game break for real", "Crash the game")
            end
            mod.MMA_GlobalSaveData.crashWarning = true
        end
    else
        local loadedData = json.decode(mod:LoadData())
        mod.MMA_GlobalSaveData = {}
        mod.MMA_GlobalSaveData.MenuData = loadedData.MenuData
        mod:AnyPlayerDo(function(player)
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
        end)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadData_MMA)

function mod.GetMenuSaveData()
    if not mod.MenuData then
        if mod:HasData() then
            mod.MenuData = json.decode(mod:LoadData()).MenuData or {}
        else
            mod.MenuData = {}
        end
    end
    return mod.MenuData
end

function mod.StoreSaveData()
    mod.MMA_GlobalSaveData.MenuData = mod.MenuData
end

function mod:mmaGetPData(player)
    local data = player:GetData()
    if data.mmaSaveData == nil then
        data.mmaSaveData = {}
    end
    return data.mmaSaveData
end

