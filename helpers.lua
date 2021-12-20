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
	local player = game:GetPlayer(1)
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

function Helpers:getTearBoost(tearBoost, currTears, maxTears) 
	if (currTears - tearBoost) > maxTears then
		return tearBoost
	elseif currTears > 5 then
		return math.min(currTears - maxTears, tearBoost )
	else
		return 0
	end
end

--Code for Isaac's Head and ???'s Soul
function Helpers:updateTrinketFamiliars()
	local famCount = 2 --Amount of familiars in the following tables. ???'s soul + isaac's head = 2
	local familiarTrinket = {TrinketType.TRINKET_SOUL, TrinketType.TRINKET_ISAACS_HEAD}
	local familiarVariants = {FamiliarVariant.BLUE_BABY_SOUL, FamiliarVariant.ISAACS_HEAD}
	for pNum = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(pNum)
		for i = 1, famCount do 
			if player:GetTrinketMultiplier(familiarTrinket[i]) > 1 then
				--Remove all extra spawns of the familiars
				for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, familiarVariants[i], 0, 0)) do
					if ent:GetData().StackedSpawn == pNum then
						ent:Remove()
					end
				end
				for j = 1, (player:GetTrinketMultiplier(familiarTrinket[i]) - 1) do
					local rng = player:GetTrinketRNG(familiarTrinket[i])
					local rngRoll = rng:RandomInt(100)			
					local spawnedFamiliar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarVariants[i], 0, player.Position + Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)) , Vector(-20 + rng:RandomInt(40),-20 + rng:RandomInt(40)), player )
					spawnedFamiliar:GetData().StackedSpawn = pNum				
				end
			end		
		end
	end	
end



return Helpers