--print("initialize crow heart")

local game = Game()

local crowHeart = {}

function crowHeart:trigger(player, flags)
	-- Only trigger on non fake damage
	if (flags & DamageFlag.DAMAGE_FAKE) == 0 or player:GetTrinketMultiplier(TrinketType.TRINKET_CROW_HEART) <= 1 then
		return true
	end
	
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_CROW_HEART)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 25 + (5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CROW_HEART) - 2))
	print("Fake dmg: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		player:TakeDamage(0, DamageFlag.DAMAGE_FAKE, EntityRef(player), 9999)
		return false
	end
			
	
	
	return true

end

return crowHeart