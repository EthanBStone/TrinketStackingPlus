--print("initialize bag lunch")

local game = Game()

local bagLunch = {}

function bagLunch:trigger(player, flags)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BAG_LUNCH) < 2 then
		return false
	end	

	local rng = player:GetTrinketRNG(TrinketType.TRINKET_BAG_LUNCH)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 2 + 1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_BAG_LUNCH) - 2 )
		
	--print("Bag lunch roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_LUNCH, player.Position, Vector(0,0), nil)
		--print("Baglunch payout")
	end
	

end


return bagLunch