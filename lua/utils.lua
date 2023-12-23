local mod = MMAMod

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