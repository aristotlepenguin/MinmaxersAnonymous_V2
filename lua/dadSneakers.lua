local mod = MMAMod
local game = Game()


local tEph = mod.MMATypes.CHARACTER_EPAPHRAS_B ~= nil

--god this function sucks
function mod:findValidDoors_DS(roomid)
    local roomdesc = Game():GetLevel():GetRoomByIdx(roomid)
    local shape = roomdesc.Data.Shape
    local doorTable = {}

    if shape >= 8 then
        if shape ~= 9 then
            table.insert(doorTable, 0)
            table.insert(doorTable, 1)
        end
        if shape ~= 10 then
            table.insert(doorTable, 2)
            table.insert(doorTable, 5)
        end
        if shape ~= 11 then
            table.insert(doorTable, 3)
            table.insert(doorTable, 4)
        end
        if shape ~= 12 then
            table.insert(doorTable, 6)
            table.insert(doorTable, 7)
        end
    elseif shape <=3 then
        if shape ~= 3 then
            table.insert(doorTable, 0)
            table.insert(doorTable, 2)
        end
        if shape ~= 2 then
            table.insert(doorTable, 1)
            table.insert(doorTable, 3)
        end
    elseif shape == 4 then
        table.insert(doorTable, 0)
        table.insert(doorTable, 1)
        table.insert(doorTable, 2)
        table.insert(doorTable, 3)
        table.insert(doorTable, 4)
        table.insert(doorTable, 6)
    elseif shape == 5 then
        table.insert(doorTable, 1)
        table.insert(doorTable, 3)
    elseif shape == 6 then
        table.insert(doorTable, 0)
        table.insert(doorTable, 1)
        table.insert(doorTable, 2)
        table.insert(doorTable, 3)
        table.insert(doorTable, 5)
        table.insert(doorTable, 7)
    elseif shape == 7 then
        table.insert(doorTable, 0)
        table.insert(doorTable, 2)
    end

    return  mod:shuffleTable(doorTable)
end

local expandedRoomDown = {
    [4] = true,
    [5] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true
}

local expandedRoomRight = {
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true
}
function mod:findValidDoors_Edges(door, room)
    local roomdesc = Game():GetLevel():GetRoomByIdx(room)
    local upRoomId = room - 13
    local downRoomId = room - 13
    local leftRoomId = room - 1
    local rightRoomId = room + 1

    local doors = Game():GetLevel():GetRoomByIdx(room).Data.Doors
    local val = 1 << door
    if doors & val ~= val then
        return false
    end

    if upRoomId >= 0 then
        local upRoomData = game:GetLevel():GetRoomByIdx(upRoomId)
        if upRoomData.Shape == 2 or upRoomData.Shape == 7 then
            return false
        end
    elseif downRoomId <= 168 then
        local downRoomData = game:GetLevel():GetRoomByIdx(downRoomId)
        if downRoomData.Shape == 2 or downRoomData.Shape == 7 then
            return false
        end
    elseif leftRoomId % 13 ~= 12 then
        local leftRoomData = game:GetLevel():GetRoomByIdx(leftRoomId)
        if leftRoomData.Shape == 3 or leftRoomData.Shape == 5 then
            return false
        end
    elseif rightRoomId % 13 ~= 0 then
        local rightRoomData = game:GetLevel():GetRoomByIdx(rightRoomId)
        if rightRoomData.Shape == 3 or rightRoomData.Shape == 5 then
            return false
        end
    end
    
    if (door == 0 or door == 4) and room % 13 == 0 then
        return false
    elseif (door == 2 or door == 6) and (room % 13 == 12 or (expandedRoomRight[roomdesc.Data.Shape] == true and room % 13 >= 11)) then
        return false
    elseif (door == 1 or door == 5) and room < 13 then
        return false
    elseif (door == 3 or door == 7) and (room > 155 or (expandedRoomDown[roomdesc.Data.Shape] == true and room > 142)) then
        return false
    else
        return true
    end
end



--mod.MMA_GlobalSaveData.UnexploredCount = mod:checkFloorRooms_DS(false, -1)

function mod:checkFloorRooms_DS(countAllRooms, returnInt)
    local totalRooms = 0
    for i=0, 168, 1 do
        local roomid = game:GetLevel():GetRoomByIdx(i)
        if roomid and roomid.Data and 
        (not roomid.Clear or countAllRooms) and 
        roomid.Data.Type ~= RoomType.ROOM_ULTRASECRET and 
        roomid.SafeGridIndex == i and not
        (roomid.Data.Type >=7 and roomid.Data.Type <=8 and roomid.DisplayFlags == 0) then
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

local roomDirectionTable = {
    [DoorSlot.LEFT0] = -1,
    [DoorSlot.LEFT1] = -1,
    [DoorSlot.RIGHT0] = 1,
    [DoorSlot.RIGHT1] = 1,
    [DoorSlot.UP0] = -13,
    [DoorSlot.UP1] = -13,
    [DoorSlot.DOWN0] = 13,
    [DoorSlot.DOWN1] = 13

}

function mod:isAdjacentDoor(room, door)
    local spawningRoom = roomDirectionTable[door] + room
    return spawningRoom == 83 or spawningRoom == 85 or spawningRoom == 71 or spawningRoom == 97
end

function mod:setMapping(roomid)
local hasMap = false
local hasCompass = false
local displayFlag = 0
    local roomdesc = game:GetLevel():GetRoomByIdx(roomid)
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TREASURE_MAP) then
            hasMap = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPASS) then
            hasCompass = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MIND) then
            hasCompass = true
            hasMap = true
        end
    end)
    if hasMap then
        displayFlag = displayFlag + 1
    end
    if hasCompass then
        displayFlag = displayFlag + 4
    end
    if hasMap or hasCompass then
        roomdesc.DisplayFlags = displayFlag
    end
    game:GetLevel():Update()
    game:GetLevel():UpdateVisibility()
end

function mod:onNewLevelStart_DS()
    local hasIt = false
    local rng = RNG()
    local hasBirthright = false
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS) or (tEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS_B and not game:IsGreedMode()) then
            hasIt = true
            if tEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS_B and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                hasBirthright = true
            end
            rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)
        end
    end)

    if hasIt and not (game:GetLevel():GetStageType() < StageType.STAGETYPE_REPENTANCE and game:GetLevel():GetStage() == 1 and mod.MMA_GlobalSaveData.RKeyOverride ~= true) then
        mod.MMA_GlobalSaveData.RKeyOverride = nil
        local numOfNewRooms = (mod.MMA_GlobalSaveData.UnexploredCount or 0)
        if hasBirthright then
            numOfNewRooms = numOfNewRooms + 3
        end
        local triedCombos = {}
        for i=1, numOfNewRooms, 1 do
            local numOfOldRooms = mod:checkFloorRooms_DS(true, -1)
            local isOpened = false
            for j=1, 10000, 1 do
                local roomIdToExpand = mod:checkFloorRooms_DS(true, rng:RandomInt(numOfOldRooms)+1)
                local doorTable = mod:findValidDoors_DS(roomIdToExpand)
                --local roomdesc = Game():GetLevel():GetRoomByIdx(roomIdToExpand)
                for k, door in ipairs(doorTable) do
                    if mod:findValidDoors_Edges(door, roomIdToExpand) and
                    triedCombos[tostring(roomIdToExpand) .. tostring(door)] == nil and 
                    game:GetLevel():MakeRedRoomDoor(roomIdToExpand, door) then
                        isOpened = true
                        mod:setMapping(roomDirectionTable[door] + roomIdToExpand)
                        triedCombos[tostring(roomIdToExpand) .. tostring(door)] = true
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

function mod:onRKey_DS(collectible, rng, player, useflags, activeslot, customvardata)
    if player:HasCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS) or player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS_B then
        mod.MMA_GlobalSaveData.RKeyOverride = true
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.onRKey_DS, CollectibleType.COLLECTIBLE_R_KEY)


------------------------------------
--T. EPAPHRAS STARTS HERE
------------------------------------

function mod:initMinnie(player)
    if player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS_B then --mod.MMATypes.CHARACTER_EPAPHRAS_B
        local dadSneakersConfig = Isaac.GetItemConfig():GetCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)
        player:AddCostume(dadSneakersConfig)
        player:AddNullCostume(mod.MMATypes.COSTUME_MINNIE_HAIR)
        --player:AddNullCostume(mod.MMATypes.COSTUME_BUCKET_HEAD)
    end
end
if tEph then
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.initMinnie)
end

function mod:tEphStatsHandling(player, cache)
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.2
    end
end
if tEph then
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.tEphStatsHandling)
end
