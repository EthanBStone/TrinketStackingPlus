--print("initialize extension cord")

local game = Game()

local extensionCord = {}

function extensionCord:trigger(player, tear)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) < 2 then
		return false
	end
	
	tear:AddTearFlags(TearFlags.TEAR_LASER)	
	
	if player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) <= 2 then
		return false
	end
	
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_EXTENSION_CORD)
	local rngRoll = rng:RandomInt(100)	
	if rngRoll <= 25 * (player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) - 2) then
		tear:AddTearFlags(TearFlags.TEAR_JACOBS)	
	end				
	
end

return extensionCord