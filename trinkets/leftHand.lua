--print("initialize left Hand")

local game = Game()

local leftHand = {}
function leftHand:trigger(pickup, player)

	if pickup:GetData().TSPLUS_LHAND_CHECK ~= nil then
		return false
	end
	pickup:GetData().TSPLUS_LHAND_CHECK = 1
	if player:GetTrinketMultiplier(TrinketType.TRINKET_LEFT_HAND) < 2 then
		return false
	end
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_LEFT_HAND)
	local rngRoll = rng:RandomInt(100)
	local rngChance = (15 + 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_LEFT_HAND) - 2) )
	--print("LH Roll: " .. rngRoll .. "|" .. rngChance)	
	if rngRoll <= rngChance then 
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)	
	end			

end

return leftHand