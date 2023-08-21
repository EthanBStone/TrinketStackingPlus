--print("initialize fragmentedCard")

local game = Game()

local fragmentedCard = {}
function fragmentedCard:trigger()
	--print("Secret room entered!")
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) > 1 then
			for i = 1, player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) - 1 do
				local rng = player:GetTrinketRNG(TrinketType.TRINKET_FRAGMENTED_CARD)
				local rngRoll = rng:RandomInt(100)
				local rngChance = 50
				--print("Frag Card Sack Roll: " .. rngRoll .. "|" .. rngChance)
				if rngRoll <= rngChance then
					local sack = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, player.Position, Vector(-15 + rng:RandomInt(30),-15 + rng:RandomInt(30)), nil)
				end	
			end
		end
	end
end

return fragmentedCard