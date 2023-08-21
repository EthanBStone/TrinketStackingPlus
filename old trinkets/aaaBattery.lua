print("initialize aaa battery")

local game = Game()

local aaaBattery = {}


function aaaBattery:trigger(rng, position, player)
	--print("aaa battery trigger")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) <= 1 then
		return false
	end
		
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_AAA_BATTERY)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 10 + 5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) - 2) --10% chance to get micro battery on room clear, extra 5% per multiplier
	print("Battery roll: " .. rngRoll .. "|" .. rngChance)
			
	if rngRoll <= rngChance then
		local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, position, Vector(0,0), player)
	end


end

return aaaBattery