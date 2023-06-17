--print("initialize vibrant bulb")

local game = Game()

local dimBulb = {}

--For cache updates
dimBulb.ID = TrinketType.TRINKET_DIM_BULB
dimBulb.caches = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK
--

function dimBulb:cacheTrigger(player, flag)
	--print("dimBulb check")
	local mult = player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB)
	if mult < 2 then
		return false
	end
	
	--Check to see if primary active slot needs a charge
	local hasCharged = true
	if player:GetActiveItem(0) ~= 0 then
		if player:NeedsCharge(0) and player:GetActiveCharge(0) == 0 then
			hasCharged = false
		end	
	end	
	
	if hasCharged then
		return false
	end
	
	--print("dimBulb added")	
	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.1 * (mult - 1)
	elseif flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.05 * (mult - 1)
	elseif flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 0.5 * (mult - 1)
	end	

	

end

return dimBulb