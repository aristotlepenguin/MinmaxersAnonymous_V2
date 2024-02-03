local mod = MMAMod
local game = Game()

mod.directionToVector = {
    [Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1),
    [Direction.NO_DIRECTION] = Vector(0, 1)
}

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

function mod:isNil(value, replacement)
    if value == nil then
        return replacement
    else
        return value
    end
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
              return check:ToPlayer()   -- WarpZone:GetPtrHashEntity(check):ToPlayer()
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
    --print(grid.Desc.Variant)
    local gType = grid:GetType()
    --print(gType)
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