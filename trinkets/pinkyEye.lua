--print("initialize pinky eye")

local game = Game()

local pinkyEye = {}

--For cache updates
pinkyEye.ID = TrinketType.TRINKET_PINKY_EYE
pinkyEye.caches = CacheFlag.CACHE_LUCK
--

function pinkyEye:cacheTrigger(player, flag)
	--print("flat check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_PINKY_EYE) < 2 then
		return false
	end
	
	--print("flat added")
	player.Luck = player.Luck + 1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_PINKY_EYE) - 1)

end

return pinkyEye