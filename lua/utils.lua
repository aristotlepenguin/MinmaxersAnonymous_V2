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