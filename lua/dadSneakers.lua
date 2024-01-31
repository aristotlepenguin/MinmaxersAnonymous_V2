local mod = MMAMod
local game = Game()


local tEph = mod.MMATypes.CHARACTER_EPAPHRAS_B ~ nil

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

function mod:findValidDoors_Edges(door, room)
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
    elseif (door == 2 or door == 6) and room % 13 == 12 then
        return false
    elseif (door == 1 or door == 5) and room < 13 then
        return false
    elseif (door == 3 or door == 7) and room > 155 then
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

function mod:onNewLevelStart_DS()
    local hasIt = false
    local rng = nil
    mod:AnyPlayerDo(function(player)
        if player:HasCollectible(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS) or (tEph and player:GetPlayerType() == mod.MMATypes.CHARACTER_EPAPHRAS_B) then
            hasIt = true
            rng = player:GetCollectibleRNG(mod.MMATypes.COLLECTIBLE_DAD_SNEAKERS)
        end
    end)

    if hasIt and not (game:GetLevel():GetStageType() ~= StageType.STAGETYPE_REPENTANCE_B and game:GetLevel():GetStage() == 1) then
        local numOfNewRooms = mod.MMA_GlobalSaveData.UnexploredCount
        local triedCombos = {}
        for i=1, numOfNewRooms, 1 do
            local numOfOldRooms = mod:checkFloorRooms_DS(true, -1)
            local isOpened = false 
            for j=1, 10000, 1 do
                local roomIdToExpand = mod:checkFloorRooms_DS(true, rng:RandomInt(numOfOldRooms)+1)
                local doorTable = mod:findValidDoors_DS(roomIdToExpand)
                local roomdesc = Game():GetLevel():GetRoomByIdx(roomIdToExpand)
                for i, door in ipairs(doorTable) do
                    if mod:findValidDoors_Edges(door, roomIdToExpand) and
                    triedCombos[tostring(roomIdToExpand) .. tostring(door)] == nil and 
                    game:GetLevel():MakeRedRoomDoor(roomIdToExpand, door) then
                        isOpened = true
                        triedCombos[tostring(roomIdToExpand) .. tostring(door)] = true
                        print("opened " .. tostring(roomIdToExpand) .. "on door" .. tostring(door))
                        --print("opened "..tostring(roomIdToExpand))
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

--setup for tainted epaphras