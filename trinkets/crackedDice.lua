print("initialize cracked dice")

local game = Game()

local crackedDice = {}

function crackedDice:trigger(player, flags)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_DICE) <= 1 then
		return false
	end 
	
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_CRACKED_DICE)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 7 + (3 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_DICE) - 2))
		
	print("cracked dice roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD, player.Position, Vector(2,2), nil)
		--print("Dice payout")
	end
	

end

return crackedDice