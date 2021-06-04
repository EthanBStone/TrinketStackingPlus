--local TrinketStacking = RegisterMod("TrinketStackingMod", 1)
local game = Game()
--local json = require("json")
--local sound = SFXManager()
--local GameState = {}

local Helpers = {}

--print("loaded helpers")

--Function to spawn item from a certain pool w/ a certain price
function Helpers:spawnItemFromPool(pool, pos, price, seed)
	local spawnItem = Isaac.Spawn(
		EntityType.ENTITY_PICKUP, 
		PickupVariant.PICKUP_COLLECTIBLE, 
		game:GetItemPool():GetCollectible(pool, true, seed), 
		pos, 
		Vector(0,0), 
		nil)
	spawnItem = spawnItem:ToPickup()
	if(price ~= 0 and price ~= nil) then 
		spawnItem.AutoUpdatePrice = false
		spawnItem.Price = price 
	end
	
	return spawnItem
	--spawnItem = i
end

--Helper function for equality
function Helpers:getLowestConsumable()
	player = game:GetPlayer(1)
	local consumables = {
		{variant = PickupVariant.PICKUP_BOMB,count = player:GetNumBombs()},
		{variant = PickupVariant.PICKUP_KEY, count = player:GetNumKeys()},
		{variant = PickupVariant.PICKUP_COIN,count = player:GetNumCoins()},
	}
	
	local minConsumable = consumables[1]
	if consumables[1].count == consumables[2].count and consumables[1].count == consumables[3].count then
		--print("All Equal")
		return nil
	else
		for i, pickup in pairs(consumables) do
			if pickup.count < minConsumable.count then
				minConsumable = pickup 
			end
		end	
		--print("Lowest consumable: " .. minConsumable.variant)
		return minConsumable.variant
	end	
end


return Helpers