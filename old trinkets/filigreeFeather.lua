print("initialize filigreeFeather")

local game = Game()

local filigreeFeather = {}
function filigreeFeather:trigger(npc)
	--Make sure the room is either angel or sac room so it doesnt trigger for the mega satan fight
	local curType = game:GetRoom():GetType()
	if  curType ~= RoomType.ROOM_ANGEL  and curType ~= RoomType.ROOM_SACRIFICE then
		return false
	end
		
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_FILIGREE_FEATHERS) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_FILIGREE_FEATHERS)
			for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_FILIGREE_FEATHERS) - 1) do
				print("Triggered filigree soul heart!")
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, npc.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
			end
		end
	end

	
end

return filigreeFeather