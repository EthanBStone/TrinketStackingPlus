--print("initialize broken Remote")

local game = Game()

local brokenRemote = {}

function brokenRemote:trigger(player, flags)
	if UseFlag.USE_OWNED & flags ~= 0 then
		return false
	end
	
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BROKEN_REMOTE) < 2 then
		return false
	end

	local rng = player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_REMOTE)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 50 + 20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_BROKEN_REMOTE) - 2)
	--print("B remote roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT_2)
		--print("B remote payout")
	end		
end

return brokenRemote