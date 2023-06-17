print("initialize holy wicked crown")

local game = Game()

local holyWickedCrown = {}

function holyWickedCrown:createChests(crownTrinketID, crownChestType)
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(crownTrinketID) > 1 then
			local rng = RNG()
			for i = 1, (player:GetTrinketMultiplier(crownTrinketID) - 1) do		
				Isaac.Spawn(EntityType.ENTITY_PICKUP, crownChestType, ChestSubType.CHEST_CLOSED, Vector(320,270), Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20) ), player)
			end
							
		end
	
	end
	

end


function holyWickedCrown:trigger(stageID)
	if stageID ~= 16 and stageID ~= 17 then 
		return false
	end
	
	--Wicked/Holy Crown
	local crownTrinketID = nil
	local crownChestType = nil
	if stageID == 16 then --Dark room 
		crownTrinketID = TrinketType.TRINKET_WICKED_CROWN
		crownChestType = PickupVariant.PICKUP_REDCHEST
	else --The chest 
		crownTrinketID = TrinketType.TRINKET_HOLY_CROWN
		crownChestType = PickupVariant.PICKUP_LOCKEDCHEST
	end
		
	if crownChestType ~= nil then
		holyWickedCrown:createChests(crownTrinketID, crownChestType)
	end
end


return holyWickedCrown