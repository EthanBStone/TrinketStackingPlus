--print("initialize vibrant bulb")

local game = Game()

local vibrantBulb = {}

--For cache updates
vibrantBulb.ID = TrinketType.TRINKET_VIBRANT_BULB
vibrantBulb.caches = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK
--

function vibrantBulb:cacheTrigger(player, flag)
	--print("vibrantBulb check")
	local mult = player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB)
	if mult < 2 then
		return false
	end
	
	--Check to see if primary active slot needs a charge
	local hasUncharged = false
	if player:GetActiveItem(0) ~= 0 then
		if player:NeedsCharge(0) then
			hasUncharged = true
		end	
	else
		hasUncharged = true
	end	
	
	if hasUncharged then
		return false
	end
	
	--print("vibrantBulb added")	
	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + 0.15 * (mult - 1)
	elseif flag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + 0.1 * (mult - 1)
	elseif flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + 0.5 * (mult - 1)
	end	

	

end

return vibrantBulb