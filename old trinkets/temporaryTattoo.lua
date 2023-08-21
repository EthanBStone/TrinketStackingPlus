--print("initialize temp tattoo")

local game = Game()

local temporaryTattoo = {}
function temporaryTattoo:trigger(rng, position, player)
	--print("temp tattoo trigger")
	local curRoomType = game:GetRoom():GetType() 
	if curRoomType ~= RoomType.ROOM_CHALLENGE or player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO) <= 1 then
		return false
	end
		
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_TEMPORARY_TATTOO)
	--Extra trinket multiplier grants more sacks
	for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO) - 1) do
		print("Sack spawned")
		print("i=" .. i .. " mult=" .. player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO))
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, position, Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20)), player)			
	end
	
end

return temporaryTattoo