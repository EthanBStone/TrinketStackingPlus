--print("initialize stemCell")

local game = Game()

local stemCell = {}
function stemCell:trigger(player)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_STEM_CELL) < 2 then
		return false
	end
	local rng = RNG()
	for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_STEM_CELL) - 1) do		
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, Vector(320,270), Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
	end	
end

return stemCell