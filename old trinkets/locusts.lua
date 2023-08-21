--print("initialize locusts")

local game = Game()

local locusts = {}

locusts.chance = 75 --chance per roll to gain another locust

function locusts:trigger()
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		--Code for all locust items
		for locustIndex = 1, 5 do
			if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) > 1 then
				for j = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) - 1) do
					local rng = player:GetTrinketRNG(TrinketType.TRINKET_PAY_TO_WIN + locustIndex)
					local rngRoll = rng:RandomInt(100)
					print("Locust[" .. locustIndex .. "] Roll: " .. rngRoll)
					if rngRoll <= locusts.chance then 
						Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locustIndex, player.Position, Vector(0,0), player)
						print("Extra locust")
					end				
				end	
			end
		end
	end	
end

return locusts