--print("initialize missing Poster")

local game = Game()

local missingPoster = {}


function missingPoster:trigger(player, flags, dmgSource)
	--print("Dmg source = " .. dmgSource.Type)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_POSTER) < 2 then
		return false
	end	
	--Only in sac room
	if game:GetRoom():GetType() ~= RoomType.ROOM_SACRIFICE then 
		return false
	end
	
	--Only damaged by the spikes
	if dmgSource == nil or dmgSource.Variant ~= 0 or dmgSource.Type ~= 0 or dmgSource.Variant ~= 0 then
		return false
	end

	--print("sac damage!")
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_MISSING_POSTER)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 15 + 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_POSTER) - 2 )
	--print("m poster roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, player.Position, Vector(-2 + rng:RandomInt(4),-2 + rng:RandomInt(4) ), nil)
		--print("M Poster payout")
	end	
	

end


return missingPoster