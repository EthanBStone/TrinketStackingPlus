--print("initialize callus")

local game = Game()

local callus = {}

--For cache updates
callus.ID = TrinketType.TRINKET_CALLUS
callus.caches = CacheFlag.CACHE_SPEED
--

function callus:cacheTrigger(player, flag)
	--print("callus check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_CALLUS) < 2 then
		return false
	end
	
	--print("callus added")
	player.MoveSpeed = player.MoveSpeed + 0.1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CALLUS) - 1)

end

return callus