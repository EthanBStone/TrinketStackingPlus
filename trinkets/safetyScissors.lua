print("initialize safety scissors")

local game = Game()

local safetyScissors = {}

function safetyScissors:trigger(player, flags)
	if (flags & DamageFlag.DAMAGE_EXPLOSION) == 0 or player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) <= 1 then
		return true
	end

	local rng = player:GetTrinketRNG(TrinketType.TRINKET_SAFETY_SCISSORS)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 55 + (15 * (player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) - 2))
	print("Resist expl: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		return false
	end

	return true

end

return safetyScissors