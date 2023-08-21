--print("initialize counterfeit Penny")

local game = Game()

local counterfeitPenny = {}
function counterfeitPenny:trigger(pickup, player)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_COUNTERFEIT_PENNY)  < 2 then	
		return nil
	end
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_COUNTERFEIT_PENNY)
	local rngRoll = rng:RandomInt(100)	
	local rngChance = 10 + (10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_COUNTERFEIT_PENNY) - 2) ) 
	--print("Counterfeit penny roll: " .. rngRoll .. "|" .. rngChance) 
	if rngRoll <= rngChance then
		--print("Counter penny proc")
		player:AddCoins(1)
	end						

end

return counterfeitPenny