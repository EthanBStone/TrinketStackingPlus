--print("initialize wooden cross")

local game = Game()

local woodenCross = {}
function woodenCross:trigger(rng, position, player)
	--print("wooden cross trigger")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) <= 1 then
		return false
	end	
		
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_WOODEN_CROSS)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) - 1) * 10
	print("Wood cross roll: " .. rngRoll .. "|" .. rngChance)
			
	if rngRoll <= rngChance then
		player:UseCard(Card.CARD_HOLY)
	end
	

end

return woodenCross