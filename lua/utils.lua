local mod = MMAMod
local game = Game()

mod.directionToVector = {
    [Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1),
    [Direction.NO_DIRECTION] = Vector(0, 1)
}

local sF = function (int)
  return 1 << int
end

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

function mod:shuffleTable(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
  end

function mod:getPlayerIndex(player)
    return player:GetCollectibleRNG(1):GetSeed()
  end

function mod:tearsUp(firedelay, val)
	local currentTears = 30 / (firedelay + 1)
	local newTears = math.max(.001, currentTears + val)
	return math.max((30 / newTears) - 1, -0.99)
end

function mod:AnyPlayerDo(foo)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		foo(player)
	end
end

function mod:getPlayerFromKnifeLaser(entity)
	if entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer() then
		return entity.SpawnerEntity:ToPlayer()
	elseif entity.SpawnerEntity and entity.SpawnerEntity:ToFamiliar() and entity.SpawnerEntity:ToFamiliar().Player then
		local familiar = entity.SpawnerEntity:ToFamiliar()

		if familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.SPRINKLER or
		   familiar.Variant == FamiliarVariant.TWISTED_BABY or familiar.Variant == FamiliarVariant.BLOOD_BABY or
		   familiar.Variant == FamiliarVariant.UMBILICAL_BABY or familiar.Variant == FamiliarVariant.CAINS_OTHER_EYE
		then
			return familiar.Player
		else
			return nil
		end
	else
		return nil
	end
end

function mod:GetPlayerFromTear(tear)
  for i=1, 2 do
      local check = nil
      if i == 1 then
          check = tear.Parent
      elseif i == 2 then
          check = tear.SpawnerEntity
      end
      if check then
          if check.Type == EntityType.ENTITY_PLAYER then
              return check:ToPlayer()   
          elseif check.Type == EntityType.ENTITY_FAMILIAR and (check.Variant == FamiliarVariant.INCUBUS or check.Variant == FamiliarVariant.TWISTED_BABY) then
              local data = tear:GetData()
              data.IsIncubusTear = true
              return check:ToFamiliar().Player:ToPlayer()
          end
      end
  end
  return nil
end
local function isPathableGrid(grid)
  if not grid then return true end
  
  local gType = grid:GetType()
  if gType == 9 or (gType == 14 and grid.Desc.Variant == 1) or gType == 17 then return false end    --moving spikes/red poop/trapdoor
  
  return Game():GetRoom():GetGridPathFromPos(grid.Position) <= 900
  
  --local gType = grid:GetType()
  --local typeFlags = 1<<0 | 1<<1 | 1<<10 | 1<<20 -- | 1<<23
  --  --1<<0 null  --1<<1 decoration  --1<<10 spiderweb  --1<<20 pressureplate  --1<<23 teleporter
  --return (typeFlags & (1<<gType)) ~= 0
end

local function thatSuperSpecificCasePoopsAndBarrelsHasOnAllOfThisAlgorithmMadness(pos, g_adj)
  local room = Game():GetRoom()
  local adjBool
  for i=1, 4 do
    if g_adj[i][1] and (g_adj[i][1]:GetType() == 12 or g_adj[i][1]:GetType() == 14) and room:GetGridPathFromPos(g_adj[i][2]) > 900 then
      adjBool = true
      break
    end
  end
  if not adjBool then return false end
  
  --que lidie con ello el sbody del mañana
  return true  
end

--void recursiveGridPath(table gMap[][], GridEntity grid, Vector gridPos, int offsetInitX, int offsetInitY)
local function recursiveGridPath(gMap, pos, offsetInitX, offsetInitY)
  
  local room = Game():GetRoom()
  local posNorm = room:GetGridPosition(room:GetGridIndex(pos))
  local offsetX = math.floor(posNorm.X / 40)
  local offsetY = math.floor(posNorm.Y / 40 - 2)
  if gMap[offsetX][offsetY] then return end    
  
  local grid = room:GetGridEntityFromPos(pos)
  if not isPathableGrid(grid) then
    return
  else
    gMap[offsetX][offsetY] = true
    if gMap[offsetInitX][offsetInitY-1] and gMap[offsetInitX+1][offsetInitY] and gMap[offsetInitX][offsetInitY+1] and gMap[offsetInitX-1][offsetInitY] then return end
    
    recursiveGridPath(gMap, pos + Vector(0,-40), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(40,0), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(0,40), offsetInitX, offsetInitY)
    recursiveGridPath(gMap, pos + Vector(-40,0), offsetInitX, offsetInitY)
  end
end

--bool canGeneratePit(vector pos, int breakGrid, table gMap[][], bool checkPoopsOrBarrels, bool checkPlayer)
function mod.canGeneratePit(pos, breakGrid, gMap, checkPoopsOrBarrels, checkPlayer)
  local room = Game():GetRoom()
  
  if pos:Distance(room:GetClampedPosition(pos, 0)) ~= 0 then return false end
  local posNorm = room:GetGridPosition(room:GetGridIndex(pos))
  for i=0, 7 do
    if room:IsDoorSlotAllowed(i) and room:GetDoorSlotPosition(i):Distance(posNorm, 0) == 40 then return false end
  end
  
  if checkPlayer then
    local players = Isaac.FindByType(1, -1, -1, false, false)
    for _, p in ipairs(players) do
      p = p:ToPlayer()
      if (not p.CanFly) and p.Position.X >= posNorm.X-20 and p.Position.X <= posNorm.X+20 and p.Position.Y >= posNorm.Y-20 and p.Position.Y <= posNorm.Y+20 then
        return false
      end
    end
  end
  
  local grid = room:GetGridEntityFromPos(pos)
  --if not grid then return false end
  
  local gridPath = room:GetGridPathFromPos(pos)
  if grid then
    local gType = grid:GetType()
    local typesDeny = 1<<7 | 1<<8 | 1<<15 | 1<<16 | 1<<17 | 1<<18 | 1<<20 | 1<<23  --pit/wall/door/trapdoor/stairs/plate/teleporter
    if (typesDeny & (1<<gType)) ~= 0 then
      if not(gType == 7 and gridPath == 0) then return false end
    end
    if gridPath == 999 then return false end      --moving spikes (up)
    if gType == 21 and grid.Desc.Variant == 0 then return false end   --satan statue
    --if gridPath == 1000 then
    if gridPath > 900 then                                            --[breakGrid] 0:Ground; 1:Grids; 2:Strong grids
      local typesStrong = 1<<3 | 1<<11 | 1<<24    --block/lock/pillar
      if (typesStrong & (1<<gType)) ~= 0 and breakGrid < 2 then return false end
      local typesWeak = 1<<2 | 1<<4 | 1<<5 | 1<<6 | 1<<12 | 1<<14 | 1<<21 | 1<<22 | 1<<25 | 1<<26 | 1<<27   --a lot
      if (typesWeak & (1<<gType)) ~= 0 and breakGrid < 1 then return false end
    end
  elseif gridPath == 950 then
    return false
  end
  
  local g_adj = {}
    g_adj[1] = {room:GetGridEntityFromPos(pos + Vector(0,-40)), pos + Vector(0,-40)}
      if g_adj[1][1] and g_adj[1][1]:GetType() == 16 then return false end   -- type == door
    g_adj[2] = {room:GetGridEntityFromPos(pos + Vector(40,0)), pos + Vector(40,0)}
      if g_adj[2][1] and g_adj[2][1]:GetType() == 16 then return false end
    g_adj[3] = {room:GetGridEntityFromPos(pos + Vector(0,40)), pos + Vector(0,40)}
      if g_adj[3][1] and g_adj[3][1]:GetType() == 16 then return false end
    g_adj[4] = {room:GetGridEntityFromPos(pos + Vector(-40,0)), pos + Vector(-40,0)}
      if g_adj[4][1] and g_adj[4][1]:GetType() == 16 then return false end
  
  local cGrids = 0
  if not gMap then
    gMap = {}
    for i=0, room:GetGridWidth() do
      gMap[i] = {}
    end
  end
  
  local offsetX = math.floor(posNorm.X / 40)
  local offsetY = math.floor(posNorm.Y / 40 - 2)
  
  if checkPoopsOrBarrels and thatSuperSpecificCasePoopsAndBarrelsHasOnAllOfThisAlgorithmMadness(pos, g_adj) then return false end
  
  if not isPathableGrid(g_adj[1][1]) then cGrids=cGrids+1 gMap[offsetX][offsetY-1] = true end
  if not isPathableGrid(g_adj[2][1]) then cGrids=cGrids+1 gMap[offsetX+1][offsetY] = true end
  if not isPathableGrid(g_adj[3][1]) then cGrids=cGrids+1 gMap[offsetX][offsetY+1] = true end
  if not isPathableGrid(g_adj[4][1]) then cGrids=cGrids+1 gMap[offsetX-1][offsetY] = true end
  if cGrids >= 3 then
    --mod:UpdatePits()
    return true
  end
  
  local sPos -- start pos
  for i=1, 4 do
    if isPathableGrid(g_adj[i][1]) then sPos = g_adj[i][2] break end
  end
  
  gMap[offsetX][offsetY] = true
    
  recursiveGridPath(gMap, sPos, offsetX, offsetY)
  
  return (gMap[offsetX][offsetY-1] and gMap[offsetX+1][offsetY] and gMap[offsetX][offsetY+1] and gMap[offsetX-1][offsetY]) == true
end

function mod:GetAdjacentIndex(index, direction) --Gets a bordering index using directional input, the bread and butter of this entire system
  local room = game:GetRoom()
  if index then --Lots of safety measures to make sure you arent getting an index outside of the room boundries (one that doesn't exist lol)
      if index <= room:GetGridSize() - 1 then
          if direction == "Left" then
              if index % room:GetGridWidth() == 0 then
                  return index
              else
                  return index - 1
              end
          elseif direction == "Right" then
              if index % room:GetGridWidth() == room:GetGridWidth() - 1 then
                  return index
              else
                  return index + 1
              end
          elseif direction == "Up" then
              if index < room:GetGridWidth() then
                  return index
              else
                  return index - room:GetGridWidth()
              end
          elseif direction == "Down" then
              if index > room:GetGridSize() - room:GetGridWidth() then
                  return index
              else
                  return index + room:GetGridWidth()
              end
          else
              error("Invalid direction input in GetAdjacentIndex")
          end
      else
          return index --You fucked up i guess? lol?
      end
  end
end


local guwahDirections = {"Left", "Right", "Up", "Down"}
function mod:IsValidIndex(index)
	local room = game:GetRoom()
	return (index >= 0 and index <= room:GetGridSize() - 1)
end

function mod:IsPitAdjacent(index)
	local room = game:GetRoom()
	--Isaac.DebugString(index)
	if index and mod:IsValidIndex(index) then
		for _, dir in pairs(guwahDirections) do
			local adjindex = mod:GetAdjacentIndex(index, dir)
			local grid = room:GetGridEntity(adjindex)
			if grid and grid:GetType() == GridEntityType.GRID_PIT and room:GetGridCollision(adjindex) == GridCollisionClass.COLLISION_PIT then
				return true
			end
		end
	end
end

function mod:UpdatePits(newIndex)
	local room = game:GetRoom()
	local size = room:GetGridSize()
	for i=0, size do
		local gridEntity = room:GetGridEntity(i)
		if gridEntity then
			if gridEntity.Desc.Type == GridEntityType.GRID_PIT then
				if newIndex then --For when spawning pits while a room is under progress, this prevents visual oddness with standalone pits changing sprites
					if mod:IsPitAdjacent(i) or i == newIndex then
						gridEntity:PostInit()
					else
						gridEntity.CollisionClass = GridCollisionClass.COLLISION_PIT
					end
				else --Otherwise, just do it as normal
					gridEntity:PostInit()
				end
			end
		end
	end
end

local BasegameSegmentedEnemies = {
	[35 .. " " .. 0] = true, -- Mr. Maw (body)
	[35 .. " " .. 1] = true, -- Mr. Maw (head)
	[35 .. " " .. 2] = true, -- Mr. Red Maw (body)
	[35 .. " " .. 3] = true, -- Mr. Red Maw (head)
	[89] = true, -- Buttlicker
	[216 .. " " .. 0] = true, -- Swinger (body)
	[216 .. " " .. 1] = true, -- Swinger (head)
	[239] = true, -- Grub
	[244 .. " " .. 2] = true, -- Tainted Round Worm

	[19 .. " " .. 0] = true, -- Larry Jr.
	[19 .. " " .. 1] = true, -- The Hollow
	[19 .. " " .. 2] = true, -- Tuff Twins
	[19 .. " " .. 3] = true, -- The Shell
	[28 .. " " .. 0] = true, -- Chub
	[28 .. " " .. 1] = true, -- C.H.A.D.
	[28 .. " " .. 2] = true, -- The Carrion Queen
	[62 .. " " .. 0] = true, -- Pin
	[62 .. " " .. 1] = true, -- Scolex
	[62 .. " " .. 2] = true, -- The Frail
	[62 .. " " .. 3] = true, -- Wormwood
	[79 .. " " .. 0] = true, -- Gemini
	[79 .. " " .. 1] = true, -- Steven
	[79 .. " " .. 10] = true, -- Gemini (baby)
	[79 .. " " .. 11] = true, -- Steven (baby)
	[92 .. " " .. 0] = true, -- Heart
	[92 .. " " .. 1] = true, -- 1/2 Heart
	[93 .. " " .. 0] = true, -- Mask
	[93 .. " " .. 1] = true, -- Mask II
	[97] = true, -- Mask of Infamy
	[98] = true, -- Heart of Infamy
	[266] = true, -- Mama Gurdy
	[912 .. " " .. 0 .. " " .. 0] = true, -- Mother (phase one)
	[912 .. " " .. 0 .. " " .. 2] = true, -- Mother (left arm)
	[912 .. " " .. 0 .. " " .. 3] = true, -- Mother (right arm)
	[918 .. " " .. 0] = true, -- Turdlet
}

function mod:isBasegameSegmented(entity)
	return BasegameSegmentedEnemies[entity.Type] or
		   BasegameSegmentedEnemies[entity.Type .. " " .. entity.Variant] or
		   BasegameSegmentedEnemies[entity.Type .. " " .. entity.Variant .. " " .. entity.SubType]
end


function UpdateAllowedDoorR(room, TargetIndex, createdoor)
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

function mod:onRockBreak(rockType, position) --probably could make a callback but nah
  mod:scoreAssaultRockBreak(rockType)
  mod:rareItemSpawn_RB(rockType, position)
end

local function rockIsBroken(position)
  local room = game:GetRoom()
  local rock = room:GetGridEntity(position)
  if not rock then
    return true
  elseif rock:ToRock() and rock.State == 2 then
    return true
  elseif rock:ToPoop() and rock.State == 1000 then
    return true
  else
    return false
  end
end


function mod:CheckRocksBreak()
  local room = game:GetRoom()
  local level = game:GetLevel()
  local newRoom = false
  if mod.MMA_GlobalSaveData.scanRockRoom ~= level:GetCurrentRoomIndex() then
    newRoom = true
    mod.MMA_GlobalSaveData.scanRockRoom = level:GetCurrentRoomIndex()
  end
  if not mod.MMA_GlobalSaveData.scanRockMap then
    mod.MMA_GlobalSaveData.scanRockMap = {}
  end

  for i=1, room:GetGridSize(), 1 do
    local rock = room:GetGridEntity(i)
    if newRoom then
      if rock and not rockIsBroken(i) then
        mod.MMA_GlobalSaveData.scanRockMap[i] = rock:GetType()
      else
        mod.MMA_GlobalSaveData.scanRockMap[i] = nil
      end
    else
      if rock and mod.MMA_GlobalSaveData.scanRockMap[i] ~= nil and rockIsBroken(i) then
        mod:onRockBreak(mod.MMA_GlobalSaveData.scanRockMap[i], rock.Position)
        mod.MMA_GlobalSaveData.scanRockMap[i] = nil
      end
    end
  end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.CheckRocksBreak)


function mod:IsInDCDimension()
  local desc = game:GetLevel():GetCurrentRoomDesc()
  if desc.Data and (desc.Data.StageID == 35 and (desc.Data.Subtype == 33 or desc.Data.Subtype == 34)) then
      return true
  end
  return false
end