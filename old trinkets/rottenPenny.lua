--print("initialize rottenPenny")

local game = Game()

local rottenPenny = {}
function rottenPenny:trigger(pickup, player)
	
	if player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) < 2 then
		return false
	end
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_ROTTEN_PENNY)
	local rngRoll = rng:RandomInt(100)
	local rngChance = (40 + 20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) - 2) )
	print("Rotten penny roll: " .. rngRoll .. "|" .. rngChance)	
	if rngRoll <= rngChance then 
		player:AddBlueFlies(1, player.Position, player )
	end		
end

return rottenPenny