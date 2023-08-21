print("initialize hairpin")

local game = Game()

local hairpin = {}

hairpin.activated = 0

function hairpin:trigger(enemy)
	
	if not enemy:IsBoss() and hairpin.activated ~= 0 then
		return false
	end
	
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomType = room:GetType()
	if roomType == RoomType.ROOM_BOSS then
		return false
	end
	
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)		
		if player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_HAIRPIN)
			hairpin.activated = 1
			for spawns = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) - 1) do
				local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, player.Position, Vector(-10 + rng:RandomInt(10),rng:RandomInt(3) ), nil)
			end
		end
			
	end
	end
end

return hairpin