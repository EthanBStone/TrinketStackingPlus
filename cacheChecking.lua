local game = Game()

local cacheChecking = {}

local data = require("playerData")



function cacheChecking:check(player, cacheTrinkets)

	
	local playerData = cacheChecking:getData(player)
	local updateCache = false
	for _, trinket in pairs(cacheTrinkets) do
		if playerData[trinket.ID] == nil then
			playerData[trinket.ID] = player:GetTrinketMultiplier(trinket.ID)
			updateCache = true
			player:AddCacheFlags(trinket.caches)
		end
		
		if playerData[trinket.ID] ~= player:GetTrinketMultiplier(trinket.ID) then
			playerData[trinket.ID] = player:GetTrinketMultiplier(trinket.ID)
			updateCache = true
			player:AddCacheFlags(trinket.caches)			
		end
		
		if updateCache then
			--print("cache updated")
			player:EvaluateItems()
		end
		playerData[trinket.ID] = player:GetTrinketMultiplier(trinket.ID)
		--print("trinket id " .. trinket.ID .. " mult " .. playerData[trinket.ID])
		
	end
		

end


function cacheChecking:getData(player)
	local playerData = data[GetPtrHash(player)]
	if playerData == nil then
		--print("Nil data")
		data[GetPtrHash(player)] = {}
		data[GetPtrHash(player)].cacheTrinkets = {}
	end	
	playerData = data[GetPtrHash(player)]
	
	if playerData.cacheTrinkets == nil then
		--print("Nil data")
		data[GetPtrHash(player)].cacheTrinkets = {}
	end
	playerData = data[GetPtrHash(player)].cacheTrinkets
	
	return playerData
end


return cacheChecking