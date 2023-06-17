--print("initialize bloody crown & silver dollar")

local game = Game()

local helpers = require("../helpers/helpers.lua")
local bloodyCrownSD = {}
function bloodyCrownSD:trigger(position, player)
	--print("Bloody crown check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BLOODY_CROWN) < 2 and player:GetTrinketMultiplier(TrinketType.TRINKET_SILVER_DOLLAR) < 2  then
		--print("No crown")
		return false
	end

	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomType = room:GetType()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomConfigR = roomDesc.Data
	local stageID = roomConfigR.StageID
	
	local level = game:GetLevel()
	local stage = level:GetStage()
	
	--Make sure it is a boss room clear on a womb stage
	if roomType ~= RoomType.ROOM_BOSS or stage ~= LevelStage.STAGE4_2 then	
		--print("Non boss room or wrong stage")
		return false
	end 
	
	--ID 25 = it lives ID 8 = moms heart
	if room:GetBossID() ~= 25 and room:GetBossID() ~= 8 then
		--print("Wrong bossID")
		return false
	end
	
	print("Moms heart kill!")
	local seed = game:GetSeeds():GetStartSeed()
	for i = 1, game:GetNumPlayers() do
		--Iterate for Bloody Crown and Silver Dollar
		local player = game:GetPlayer(i)
		for j = 1, 2 do
			local price = 0
			local pool = ItemPoolType.POOL_BOSS
			local crownTrinketID = nil
			if j == 1 then
				crownTrinketID = TrinketType.TRINKET_BLOODY_CROWN
				pool = ItemPoolType.POOL_BOSS
				price = 0	
			else
				crownTrinketID = TrinketType.TRINKET_SILVER_DOLLAR
				pool = ItemPoolType.POOL_SHOP
				price = 15
			end
					
			if player:GetTrinketMultiplier(crownTrinketID) > 1 then
				local rng = player:GetTrinketRNG(crownTrinketID)
				local spawnItem
				for i = 1, (player:GetTrinketMultiplier(crownTrinketID) - 1) do
					--Spawn item
					if i == 1 then
						spawnItem = helpers:spawnItemFromPool(pool, Vector(10 + rng:RandomInt(190), 10 + rng:RandomInt(370)), price, seed)
						--Spawn sacks
					else
						spawnItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
					end							
				end
			end			
			
		end
	end
end

return bloodyCrownSD