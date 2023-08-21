--print("initialize blue key")

local game = Game()

local blueKey = {}

function blueKey:trigger(rng, position, player)
	--print("blue key trigger")
	--Code for blue key
	local curRoomType = game:GetRoom():GetType()

	if player:GetTrinketMultiplier(TrinketType.TRINKET_BLUE_KEY) <= 1 or curRoomType ~= RoomType.ROOM_BLUE then
		return false
	end	
		
	print("Blue key room cleared")
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLUE_KEY)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 25 * player:GetTrinketMultiplier(TrinketType.TRINKET_BLUE_KEY)
	--print("Blue key Roll: " .. rngRoll .. "|" .. rngChance )
	if rngRoll <= rngChance then
		--print("Blue key drop Triggered!")
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, pos, Vector(-2 + rng:RandomInt(4), -2 + rng:RandomInt(4)), nil)
	end			

end

return blueKey