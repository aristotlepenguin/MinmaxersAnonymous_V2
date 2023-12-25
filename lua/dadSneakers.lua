local mod = MMAMod
local game = Game()

local doorTable = {
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
    [7] = 6,
    [8] = 7
}

--mod.MMA_GlobalSaveData.UnexploredCount = mod:checkFloorRooms_DS(false, -1)

function mod:checkFloorRooms_DS(countAllRooms, returnInt)
    local totalRooms = 0
    for i=0, 168, 1 do
        local roomid = game:GetLevel():GetRoomByIdx(i)
        if roomid and (not roomid.Clear or countAllRooms) then
            totalRooms = totalRooms + 1
            if totalRooms == returnInt then
                return i
            end
        end
    end
    return totalRooms
end

function mod:refreshRooms_DS()
    if game:GetLevel():GetCurrentRoomIndex() ~=84 then
        mod.MMA_GlobalSaveData.UnexploredCount = mod:checkFloorRooms_DS(false, -1)
    end 
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.refreshRooms_DS)

function mod:refreshRooms_DS_W(rng, spawnpos)
    mod:refreshRooms_DS()
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.refreshRooms_DS_W)

function mod:onNewLevelStart_DS()
    local hasIt = false
    local rng = nil
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS) then
            hasIt = true
            rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)
        end
    end)

    if hasIt and not (game:GetLevel().GetStageType() ~= StageType.STAGETYPE_REPENTANCE_B and game:GetLevel().GetStage() == 1) then
        local numOfNewRooms = mod.MMA_GlobalSaveData.UnexploredCount
        for i=1, numOfNewRooms, 1 do
            local numOfOldRooms = mod:checkFloorRooms_DS(true, -1)
            local isOpened = false 
            for j=1, 10000, 1 do
                local roomIdToExpand = mod:checkFloorRooms_DS(true, rng:RandomInt(numOfOldRooms)+1)
                local roomCheckOrder = mod:shuffleTable(doorTable)
                
                for i, door in ipairs(roomCheckOrder) do
                    if game:GetLevel():MakeRedRoomDoor(roomIdToExpand) then
                        isOpened = true
                        break
                    end
                end
                if isOpened == true then
                    break
                end
            end
        end
    end
    mod.MMA_GlobalSaveData.UnexploredCount = mod:checkFloorRooms_DS(false, -1)
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.onNewLevelStart_DS)
