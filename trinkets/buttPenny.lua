--print("initialize butt Penny")

local game = Game()

local data = require("/playerData")
local buttPenny = {}


function buttPenny:pickup(pickup, player)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY) < 2 then
		return false
	end
	
	--Retrieve and set up data
	local playerData = data[GetPtrHash(player)]
	if playerData == nil then
		--print("Nil data")
		data[GetPtrHash(player)] = {}
	end	
	playerData = data[GetPtrHash(player)]
	if playerData.buttPennyData == nil then
		--print("Nil data")
		data[GetPtrHash(player)].buttPennyData = { Time = 0, LastFrame = 0 }
	end
	playerData = data[GetPtrHash(player)].buttPennyData
	--
	
	--[[
	--print("Time " .. buttPenny.data[GetPtrHash(player)].Time)
	--print(" LF " .. buttPenny.data[GetPtrHash(player)].LastFrame)
	print("Time " .. playerData.Time)
	print(" LF " .. playerData.LastFrame)	
	]]--

	
	--The value of Gassy.Time is how many farts the player will do 
	--A better value coin will give more farts
	local coinMult = 1
	if pickup.SubType == CoinSubType.COIN_DOUBLEPACK or pickup.SubType == CoinSubType.COIN_LUCKYPENNY or pickup.SubType == CoinSubType.COIN_NICKEL then
		coinMult = 2	
	elseif pickup.SubType == CoinSubType.COIN_DIME then
		coinMult = 3
	end
	playerData.Time = playerData.Time + 2 + ( coinMult * (2 * (player:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY) - 1) ) )
	--The max cap of farts the player can store with butt penny
	if playerData.Time > 20 then
		playerData.Time = 20
	end
	
	--print("Time " .. playerData.Time)
	--print(" LF " .. playerData.LastFrame)	
end

function buttPenny:gasTrigger(player)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY) < 2 then
		return false
	end
	
	--Retrieve and set up data
	local playerData = data[GetPtrHash(player)]
	if playerData == nil then
		--print("Nil data")
		data[GetPtrHash(player)] = {}
	end	
	playerData = data[GetPtrHash(player)]
	if playerData.buttPennyData == nil then
		--print("Nil data")
		data[GetPtrHash(player)].buttPennyData = { Time = 0, LastFrame = 0 }
	end
	playerData = data[GetPtrHash(player)].buttPennyData
	--
	
	if playerData == nil or playerData.Time <= 0 then
		return false
	end
	
	local currFrame = game:GetFrameCount()
	--Conditions for a fart to trigger
	if currFrame ~= playerData.LastFrame then
		game:Fart(player.Position, 85, player, 1, 3)
		playerData.Time = playerData.Time - 1
		playerData.LastFrame = currFrame
		--print("gassy fart: " .. playerData.Time .. " farts left. Frame: " .. currFrame)
	end	
	
end

return buttPenny