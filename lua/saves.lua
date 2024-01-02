local json = require("json")
local mod = MMAMod

local game = Game()

function mod:saveData()
    mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
    local numPlayers = game:GetNumPlayers()
    mod.MMA_GlobalSaveData.PlayerData = {}
    for i=0, numPlayers-1, 1 do
        local player = Isaac.GetPlayer(i)
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
        if mod.MMA_GlobalSaveData.MMA_firingOverclock == true then
            mod.MMA_GlobalSaveData.crashBonus = true
            mod.MMA_GlobalSaveData.MMA_firingOverclock = nil
        end
        for i=0, numPlayers-1, 1 do
            local player = Isaac.GetPlayer(i)
            local data = player:GetData()
            if mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())] then
                data.mmaSaveData = mod.MMA_GlobalSaveData.PlayerData[tostring(player:GetCollectibleRNG(1):GetSeed())]
                data.mmaSaveData.MMA_overclockFrame = nil
            end
            player:AddCacheFlags(CacheFlag.CACHE_ALL)
            player:EvaluateItems()
        end
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

