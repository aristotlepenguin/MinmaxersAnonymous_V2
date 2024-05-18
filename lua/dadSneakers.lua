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

    if hasIt and not (game:GetLevel():GetStageType() ~= StageType.STAGETYPE_REPENTANCE_B and game:GetLevel():GetStage() == 1) then
        local numOfNewRooms = mod.MMA_GlobalSaveData.UnexploredCount
        if hasBirthright and not REPENTOGON then
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
                for i, door in ipairs(doorTable) do
                    local useManualRedRoom = REPENTOGON and hasBirthright and rng:RandomInt(10) == 9 and not mod:isAdjacentDoor(roomIdToExpand, door)
                    if not useManualRedRoom then
                        if mod:findValidDoors_Edges(door, roomIdToExpand) and
                        triedCombos[tostring(roomIdToExpand) .. tostring(door)] == nil and 
                        game:GetLevel():MakeRedRoomDoor(roomIdToExpand, door) then
                            isOpened = true
                            mod:setMapping(roomDirectionTable[door] + roomIdToExpand)
                            triedCombos[tostring(roomIdToExpand) .. tostring(door)] = true
                            break
                        end
                    else
                        if mod:findValidDoors_Edges(door, roomIdToExpand) and
                        triedCombos[tostring(roomIdToExpand) .. tostring(door)] == nil and 
                        mod:openSpecialRedRoom_DS(roomIdToExpand, door, rng) then
                            isOpened = true
                            triedCombos[tostring(roomIdToExpand) .. tostring(door)] = true
                            break
                        end
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

local specTable = {
    [1]=RoomType.ROOM_SHOP,
    [2]=RoomType.ROOM_TREASURE,
    [3]=RoomType.ROOM_SECRET,
    [4]=RoomType.ROOM_ARCADE,
    [5]=RoomType.ROOM_CURSE,
    [6]=RoomType.ROOM_LIBRARY,
    [7]=RoomType.ROOM_SACRIFICE,
    [8]=RoomType.ROOM_DEVIL,
    [9]=RoomType.ROOM_ANGEL,
    [10]=RoomType.ROOM_CHEST,
    [11]=RoomType.ROOM_DICE,
    [12]=RoomType.ROOM_ISAACS,
    [13]=RoomType.ROOM_PLANETARIUM,
    [14]=RoomType.ROOM_MINIBOSS,
    [15]=RoomType.ROOM_SUPERSECRET,
    [16]=RoomType.ROOM_BARREN
}



local sF = function (int)
    return 1 << int
end
local alldoor = sF(DoorSlot.DOWN0) | sF(DoorSlot.LEFT0) | sF(DoorSlot.UP0) | sF(DoorSlot.RIGHT0)

local ShapeToNeighbors = {
    [RoomShape.ROOMSHAPE_1x1] = {-1,-13,1,13},
    [RoomShape.ROOMSHAPE_IH] = {-1,1},
    [RoomShape.ROOMSHAPE_IV] = {-13,13},
    [RoomShape.ROOMSHAPE_1x2] = {-1,-13,1,12,15,26},
    [RoomShape.ROOMSHAPE_IIV] = {-13,26},
    [RoomShape.ROOMSHAPE_2x1] = {-1,-13,-12,2,13,14},
    [RoomShape.ROOMSHAPE_IIH] = {-1,2},
    [RoomShape.ROOMSHAPE_2x2] = {-1,-13,-12,2,12,15,26,27},
    [RoomShape.ROOMSHAPE_LTL] = {0,-12,2,12,15,26,27},
    [RoomShape.ROOMSHAPE_LTR] = {-1,-13,1,12,15,26,27},
    [RoomShape.ROOMSHAPE_LBL] = {-1,-13,-12,2,13,15,27},
    [RoomShape.ROOMSHAPE_LBR] = {-1,-13,-12,2,12,14,26},
}
local ShapeToNeighborsDoor = {
    [RoomShape.ROOMSHAPE_1x1] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.RIGHT0,DoorSlot.DOWN0},
    [RoomShape.ROOMSHAPE_IH] = {DoorSlot.LEFT0, DoorSlot.RIGHT0},
    [RoomShape.ROOMSHAPE_IV] = {DoorSlot.UP0, DoorSlot.DOWN0},
    [RoomShape.ROOMSHAPE_1x2] = {DoorSlot.LEFT0, DoorSlot.UP0, DoorSlot.RIGHT0, DoorSlot.LEFT1, DoorSlot.RIGHT1, DoorSlot.DOWN0},
    [RoomShape.ROOMSHAPE_IIV] = {DoorSlot.UP0, DoorSlot.DOWN0},
    [RoomShape.ROOMSHAPE_2x1] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.DOWN0, DoorSlot.DOWN1},
    [RoomShape.ROOMSHAPE_IIH] = {DoorSlot.LEFT0, DoorSlot.RIGHT0},
    [RoomShape.ROOMSHAPE_2x2] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
    [RoomShape.ROOMSHAPE_LTL] = {{DoorSlot.LEFT0, DoorSlot.UP0},DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
    [RoomShape.ROOMSHAPE_LTR] = {DoorSlot.LEFT0,DoorSlot.UP0,{DoorSlot.RIGHT0,DoorSlot.UP1},DoorSlot.LEFT1,DoorSlot.RIGHT1,DoorSlot.DOWN0,DoorSlot.DOWN1},
    [RoomShape.ROOMSHAPE_LBL] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,{DoorSlot.DOWN0,DoorSlot.LEFT1},DoorSlot.RIGHT1,DoorSlot.DOWN1},
    [RoomShape.ROOMSHAPE_LBR] = {DoorSlot.LEFT0,DoorSlot.UP0,DoorSlot.UP1,DoorSlot.RIGHT0,DoorSlot.LEFT1,{DoorSlot.RIGHT1,DoorSlot.DOWN1},DoorSlot.DOWN0},
}

local ttn = function (num)
    if type(num) == "table" then
        local a = 0
        for i=1, #num do
            a = a | sF(num[i])
        end
        return a
    else
        return num
    end
end

function mod:GetNeighbors(room)
    local level = game:GetLevel()
    local tab = {}
    local neighs = ShapeToNeighbors[room.Data.Shape]
    for j = 1, #neighs do
        local neind = room.GridIndex + neighs[j]
        local nroom = level:GetRoomByIdx(neind, 0)
        if (neind > 0 and neind < (13*13)) and nroom.ListIndex ~= -1 then
            tab[#tab+1] = neind
        end
    end
    return tab
end

function mod:UpdateAllowedDoorR(room, TargetIndex, createdoor)
    local level = game:GetLevel()
    local doorslot = 0
    local shape = room.Data.Shape
    local neighs = ShapeToNeighbors[room.Data.Shape]
    
    for j = 1, #neighs do
        local neind = room.GridIndex + neighs[j]
        
        if (neind > 0 and neind < (13*13)) 
        and (not TargetIndex or TargetIndex == neind) then
            local nroom = level:GetRoomByIdx(neind, 0)
            
            if nroom.ListIndex ~= -1 then
                
                doorslot = doorslot | sF(ttn(ShapeToNeighborsDoor[shape][j]))
                local slots = ShapeToNeighborsDoor[shape][j]
                
                --if WarpZone.CELESTROOMS_indexs[room.SafeGridIndex] then
                    if type(slots) == "table" then
                        for i=1, #slots do
                            room.Doors[slots[i]] = neind
                        end
                    else
                        room.Doors[slots] = neind
                    end
                --end
            end
        end
    end
    room.AllowedDoors = room.AllowedDoors | doorslot
  end


function mod:UpdateAllowedDoor(room, TargetIndex, createdoor)
    local level = game:GetLevel()
    local doorslot = 0
    local shape = room.Data.Shape
    local neighs = ShapeToNeighbors[room.Data.Shape]
   
    for j = 1, #neighs do
        local neind = room.GridIndex + neighs[j]
       
        if (neind > 0 and neind < (13*13)) 
        and (not TargetIndex or TargetIndex == neind) then
            local nroom = level:GetRoomByIdx(neind, 0)
            
            if nroom.ListIndex ~= -1 then
               
                doorslot = doorslot | sF(ttn(ShapeToNeighborsDoor[shape][j]))
                local slots = ShapeToNeighborsDoor[shape][j]
                
                --if WarpZone.CELESTROOMS_indexs[room.SafeGridIndex] then
                    if type(slots) == "table" then
                        for i=1, #slots do
                            room.Doors[slots[i]] = neind
                        end
                    else
                        room.Doors[slots] = neind
                    end
                --end
            end
        end
    end
    room.AllowedDoors = room.AllowedDoors | doorslot
end

function mod:openSpecialRedRoom_DS(roomIdToExpand, door, rng)
    if not REPENTOGON then
        return nil
    else
        local specialRoomType = specTable[rng:RandomInt(16)+1]
        local rConf = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), true, StbType.SPECIAL_ROOMS, specialRoomType, RoomShape.ROOMSHAPE_1x1, -1,-1,nil,nil,15)
        local moddedID = roomDirectionTable[door] + roomIdToExpand
        local entry = Isaac.LevelGeneratorEntry()
        entry:SetAllowedDoors(alldoor)
        entry:SetColIdx((moddedID-1) % 13 + 1)
        entry:SetLineIdx(math.floor(moddedID/13))
        local valid = game:GetLevel():PlaceRoom(entry, rConf, rng:GetSeed())
        if valid then
            
            local roomState = Game():GetLevel():GetRoomByIdx(moddedID)
            roomState.AllowedDoors = 0
            --roomState.DisplayFlags = 5
            roomState.Flags = roomState.Flags | RoomDescriptor.FLAG_RED_ROOM
            game:GetLevel():Update()
            game:GetHUD():Update()
            game:GetHUD():PostUpdate()

            mod:UpdateAllowedDoorR(roomState, nil, true)
            
            for i, k in pairs(mod:GetNeighbors(roomState)) do
                local nroom = game:GetLevel():GetRoomByIdx(k)
                mod:UpdateAllowedDoor(nroom, moddedID)
            end

        end
        return valid
    end
end


--birthright effect for minnie, make rooms more likely to be special


