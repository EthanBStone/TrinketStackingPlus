--print("initialize bag lunch")

local game = Game()

helpers = require("../helpers/helpers")

local wishBone = {}


function wishBone:trigger(player, flags)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_WISH_BONE) < 2 then
		return false
	end	

	local rng = player:GetTrinketRNG(TrinketType.TRINKET_WISH_BONE)
	local rngRoll = rng:RandomInt(100)
	local rngChance = 2 + 1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_WISH_BONE) - 2 )
		
	--print("Wishbone roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		--print("Wishbone payout")
		local seed = game:GetSeeds():GetStartSeed()
		local roomType = game:GetRoom():GetType()	
		local pool = game:GetItemPool()
		local poolType = pool:GetPoolForRoom(roomType, seed)
		--print("room = " .. roomType .. " pool = " .. poolType)
		helpers:spawnItemFromPool( poolType, player.Position, 0, seed)
			
		end
	

end


return wishBone