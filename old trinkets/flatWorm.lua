--print("initialize pulse Worm")

local game = Game()

local flatWorm = {}

--For cache updates
flatWorm.ID = TrinketType.TRINKET_FLAT_WORM
flatWorm.caches = CacheFlag.CACHE_DAMAGE
--

function flatWorm:cacheTrigger(player, flag)
	--print("flat check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_WORM) < 2 then
		return false
	end
	
	--print("flat added")
	player.Damage = player.Damage + 0.25 * (player:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_WORM) - 1)

end

return flatWorm