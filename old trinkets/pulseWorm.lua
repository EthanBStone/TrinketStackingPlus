--print("initialize pulse Worm")

local game = Game()

local pulseWorm = {}

--For cache updates
pulseWorm.ID = TrinketType.TRINKET_PULSE_WORM
pulseWorm.caches = CacheFlag.CACHE_DAMAGE
--

function pulseWorm:cacheTrigger(player, flag)
	--print("pulse check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_PULSE_WORM) < 2 then
		return false
	end
	
	--print("pulse added")
	player.Damage = player.Damage + 0.25 * (player:GetTrinketMultiplier(TrinketType.TRINKET_PULSE_WORM) - 1)

end

return pulseWorm