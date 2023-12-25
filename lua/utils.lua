local mod = MMAMod
local game = Game()

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