--print("initialize storeKey")

local game = Game()

local storeKey = {}
function storeKey:trigger(room)
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_STORE_KEY)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 35 + 15 * (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) - 2)
			--print("Store key Roll: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				room:TrySpawnSecretShop(true)
			end			
		end
	end
end

return storeKey