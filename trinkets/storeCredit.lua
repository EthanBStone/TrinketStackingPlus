--print("initialize store credit")

local game = Game()
local data = require("/playerData")

local storeCredit = {}

function storeCredit:trigger(player)
	if player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) < 2 then
		--print("Doesnt have store cred")
		return false
	end
	
	--Player has picked up an item
	if player:IsItemQueueEmpty() or not player:IsHoldingItem() then
		return false
	end
	
	print("Queued id: " .. player.QueuedItem.Item.ID)
	
	
	storeCredit:getData(player)
	local playerData = data[GetPtrHash(player)].storeCreditData
	local targetID = playerData.ShopTargetID
	print("Shop target: " .. targetID)
	
	if targetID ~= player.QueuedItem.Item.ID then
		return false
	end
	
	print("Bought item!")
	data[GetPtrHash(player)].storeCreditData.ShopTargetID = 0
	storeCredit:onPurchase(player)	
	
end

function storeCredit:setTarget(pickup, player)
	if not pickup:IsShopItem() then
		print("not shop item")
		return false
	end	
	if player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) < 2 then
		print("Doesnt have store cred")
		return false
	end
		
	storeCredit:getData(player)

	data[GetPtrHash(player)].storeCreditData.ShopTargetID = pickup.SubType
	print("Targetting " .. pickup.SubType)
end

function storeCredit:getData(player)
	--Retrieve and set up data
	local playerData = data[GetPtrHash(player)]
	if playerData == nil then
		data[GetPtrHash(player)] = {}
	end	
	playerData = data[GetPtrHash(player)]
	if playerData.storeCreditData == nil then
		data[GetPtrHash(player)].storeCreditData = { ShopTargetID = 0 }
	end
	playerData = data[GetPtrHash(player)].storeCreditData
	
end

function storeCredit:onPurchase(player)
	print("On purchase trigger")
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_STORE_CREDIT)
	local rngRoll = rng:RandomInt(100)
	local rngChance = math.min(35, 10 + 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) - 2))
	print("Store Credit Roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)), nil)
	--RNG Failed
	else
		print("Rng failed, spawning coins")
		local minCoins = (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) - 2) * 2 + 4
		rngRoll = minCoins + rng:RandomInt(5)	
		print("Min coins: " .. minCoins .. " Roll: " .. rngRoll)
		for i = 1, rngRoll do
			local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)), nil)
		end
	end	

end

return storeCredit