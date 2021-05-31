local TrinketStacking = RegisterMod("TrinketStackingMod", 1)
local game = Game()
local json = require("json")
local sound = SFXManager()

local GameState = {}

--[[
Notes: 
Locusts are familiars, variant 43 "Blue Fly"
Center of a room: 320, 270
Extension cord laser: Subtype 2
Bugs:
*Fish head might be spawning more flies than it should?
*Apple of sodom might be a bit buggy
*Move Wooden cross effect to on room cleared

Current Interactions:
*All "Locust of" trinkets work properly. Each extra multiplier give a 75% chance to spawn an extra locust

*Filigree Feather: Each additional multiplier gives you a spirit heart drop for every angel statue killed

*Holy/Wicked Crown: Each extra multiplier gives you an extra red/locked chest at the start of the Dark Room/Chest


*Bloody Crown: Mom's heart drops a boss item. Additional multipliers drop sacks
*Silver Dollar: Mom's heart drops a buyable shop item. Additional multipliers drop sacks

*Wooden Cross: When entering a hostile room, gain a chance to replenish your shield. Starts at 15%, increases by 10% per multiplier.

*???'s Soul and Isaac's Head: Each multiplier gives you an extra copy of the familiar

*Vibrant Bulb: When fully charged: +0.5 dmg, +0.1 speed, +1 luck per multiplier

*Dim Bulb: When partially charged: +0.75 dmg, +0.1 speed, and +1 luck per multiplier

*Apple of Sodom: Chance to spawn extra spiders

*Fish Tail: Small change to add extra flies/spiders

*AAA Battery: Chance to drop micro battery on room clear

*Fragmented Card: 50% Chance to spawn a sack when entering a secret room. More multipliers = more rolls

*Stem Cell: Spawns an extra red heart on the ground at the start of the stage per multiplier

*Myosotis: Chance to duplicate some of the carried over pickups

*Rotten Penny: Chance to spawn an extra fly on coin pickup. Higher multiplier = higher chance
]]--


local myosotisFlag = 0
local devilDealsCount = 0



function TrinketStacking.onGameExit() 
	TrinketStacking:SaveData(json.encode(GameState))
end

function TrinketStacking:onStart(continuedRun)
	devilDealsCount = game:GetDevilRoomDeals()
	
end

function TrinketStacking:onUpdate()
	--DEBUG ONLY spawns items
	if game:GetFrameCount() == 1 then
		player = Isaac.GetPlayer(1)
		
		Isaac.ExecuteCommand("debug 4") --Big dmg
		--Isaac.ExecuteCommand("debug 3") --Infinite hp
		Isaac.ExecuteCommand("debug 7")	--Show dmg nums
		Isaac.ExecuteCommand("debug 8")	--Infinite charge
		--Isaac.ExecuteCommand("debug 10") --Insta kills
		
		Isaac.Spawn(EntityType.ENTITY_DUMMY,0, 0, Vector(320, 270), Vector(0,0), player) --Dummy
		
		
		player:AddCollectible(534) --School Bag
		player:AddCollectible(479,12) --Smelter
		Isaac.Spawn(5,100, 439, player.Position + Vector(0,-60), Vector(0,0), player) --Mom's Box
		player:AddCollectible(139) --Moms purse
		
		--Locust testing
		--[[
		player:AddTrinket(TrinketType.TRINKET_DOOR_STOP)
		Isaac.Spawn(5,350, 113, player.Position, Vector(0,0), player) -- locust of wrath
		Isaac.Spawn(5,350, 113 + 32768, player.Position, Vector(0,0), player) --Gold locust of wrath
		--]]
		
		--Fillagree feather testing
		--[[
		player:AddCard(31) -- Joker card
		player:AddCollectible(584) --Book of virtues
		Isaac.Spawn(5,350, 123 + 32768, player.Position, Vector(0,0), player)
		]]--
		
		--Bloody Crown Testing
		--[[
		player:AddCard(5) -- Joker card
		player:AddTrinket(111) --Bloody crown
		]]--
		
		--Wooden Cross Testing
		--player:AddTrinket(121) --Wooden Cross
		
		--Vibrant/Dim Bulb testing
		--Isaac.Spawn(5,350, 100 + 32768, player.Position, Vector(0,0), player)
		--Isaac.Spawn(5,350, 101 + 32768, player.Position, Vector(0,0), player)
		
		---???'s soul
		---player:AddTrinket(57) --???'s soul
		--Isaac.Spawn(5,350, 57 + 32768, player.Position, Vector(0,0), player) --Gold ???'s soul
		--Isaac.Spawn(5,350, 54 + 32768, player.Position, Vector(0,0), player) --Gold isaacs head
	
		--Apple of Sodom
		--player:AddTrinket(140) --Apple of sodom
		--Isaac.Spawn(5,350, 140 + 32768, player.Position, Vector(0,0), player)
		--player:AddCollectible(286,12) --Blank card
		--player:AddCard(7) -- Lovers card
		
		--Fish tail 
		--[[
		player:AddTrinket(94) --Fish tail
		Isaac.Spawn(5,350, 94 + 32768, player.Position, Vector(0,0), player)
		player:AddCollectible(434,12) --Blank card
		]]--
		
		--Fragmented card
		--[[
		player:AddTrinket(102) --Frag card
		Isaac.Spawn(5,350, 102 + 32768, player.Position, Vector(0,0), player)
		player:AddCollectible(333) --Blank card
		player:AddCollectible(190) --Pyro
		player:AddCard(19) -- Moon card
		]]--
		
		--Extension Cord
		--[[
		player:AddCollectible(139) --Moms purse
		player:AddTrinket(57) --???'s soul
		player:AddTrinket(125) --Extension cord
		player:AddCollectible(8) --Brother bobby
		]]--
		
		--Stem Cell
		--[[
		player:AddCollectible(139) --Moms purse
		player:AddCollectible(84) --We need to go deeper
		player:AddTrinket(119) --Stem cell
		]]--

		--Myosotis
		--[[
		
		player:AddCollectible(84) --We need to go deeper
		player:AddTrinket(137) --myosotis
		]]--
		
		--Judas Tongue
		--[[
		player:AddTrinket(56) --judas tongue
		player:AddCard(31)
		]]--
		
		--Rotten penny

		player:AddTrinket(126) --Rotten penny
		
		
	end

	--Myosotis code
	if myosotisFlag == 1 then
		myosotisFlag = 0
		for i = 1, game:GetNumPlayers() do
			for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
				if pickup:GetData().TStack_Myosotis == nil then
					rng = player:GetTrinketRNG(TrinketType.TRINKET_MYOSOTIS)
					rngRoll = rng:RandomInt(100)
					rngChance = 15 + (player:GetTrinketMultiplier(TrinketType.TRINKET_MYOSOTIS) - 1) * 10
					--print("Dupe rng: " .. rngRoll .. "|" .. rngChance)
					
					if rngRoll < rngChance then
						--print("Duped")
						duplicate = Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, pickup.SubType, pickup.Position, Vector(-2 + rng:RandomInt(2), -2 + rng:RandomInt(2)), player)
						duplicate:GetData().TStack_Myosotis = 1
					end
				end
			end		
		end

	end

	--Devil Deal code for judas tongue, WIP
	--[[
	if devilDealsCount < game:GetDevilRoomDeals() then
		print("Devil deal taken!: ")
		devilDealsCount = game:GetDevilRoomDeals()
		for i = 1, game:GetNumPlayers() do
			player = game:GetPlayer(i)
			
			print("Cooldown: " .. player.ItemHoldCooldown) 
				--print(player.QueuedItem.Touched)
				--print(player:IsHoldingItem())
			--else
				--print(false)
			
			--end
			
			
			
		
		end
	end
	]]--
end



--local debugSpawned = false
function TrinketStacking:onRender() 

	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		player:GetData().pNum = i			
	end
	--[[
	if game:GetFrameCount () % 60 == 1  then
		for i, ent in pairs(Isaac.GetRoomEntities()) do
			print("Type: " .. ent.Type .. " Variant:" .. ent.Variant .. " Subtype: " .. ent.SubType)
		end
	end
	]]--
end

--On new room entered: Locusts, familiars
function TrinketStacking:onNewRoom() 
	devilDealsCount = game:GetDevilRoomDeals()
	level = game:GetLevel()
	room = level:GetCurrentRoom()
	roomDesc = level:GetCurrentRoomDesc()
	--Check to see if the room has been seen before
	if(roomDesc.VisitedCount <= 1) then
		if not roomDesc.Clear  then
			TrinketStacking.onHostileRoomStart()
		end
		--Trigger on secret rooms for Fragmented card
		if room:GetType() == RoomType.ROOM_SECRET then
			TrinketStacking.onSecretRoomEntered()
		end
	end
	--Code for ???'s Soul and Isaac's Head
	famCount = 2
	familiarTrinket = {TrinketType.TRINKET_SOUL, TrinketType.TRINKET_ISAACS_HEAD}
	familiarVariants = {FamiliarVariant.BLUE_BABY_SOUL, FamiliarVariant.ISAACS_HEAD}
	for pNum = 1, game:GetNumPlayers() do
		player = game:GetPlayer(pNum)
		for i = 1, famCount do 
			if player:GetTrinketMultiplier(familiarTrinket[i]) > 1 then
				--Remove all extra spawns of the familiars
				for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, familiarVariants[i], 0, 0)) do
					if ent:GetData().StackedSpawn == 1 then
						--print("Killing old familiar")
						ent:Die()
					end
				end
				for j = 1, (player:GetTrinketMultiplier(familiarTrinket[i]) - 1) do
					rng = player:GetTrinketRNG(familiarTrinket[i])
					rngRoll = rng:RandomInt(100)			
					local spawnedFamiliar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarVariants[i], 0, player.Position + Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)) , Vector(-20 + rng:RandomInt(40),-20 + rng:RandomInt(40)), player )
					spawnedFamiliar:GetData().StackedSpawn = 1
					--print("Spawning new familiar")				
				end
			end		
		end
	end	


	
end

--On hostile room start, for things like locusts and Wooden Cross
function TrinketStacking:onHostileRoomStart()
	for pNum = 1, game:GetNumPlayers() do
		player = game:GetPlayer(pNum)
		--Code for all locust items
		for locustIndex = 1, 5 do
			if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) > 1 then
				for j = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) - 1) do
					rng = player:GetTrinketRNG(TrinketType.TRINKET_PAY_TO_WIN + locustIndex)
					rngRoll = rng:RandomInt(100)
					--print("Locust[" .. locustIndex .. "] Roll: " .. rngRoll)
					if rngRoll <= 75 then 
						Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, locustIndex, player.Position, Vector(0,0), player)
						--print("Extra locust")
					end				
				end

				
				
			end
		end
	
		--Code for Wooden Cross
		if player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_WOODEN_CROSS)
			local rngRoll = rng:RandomInt(100)
			local crossChance = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) - 1) * 10
			--print("WoodenCross Roll: " .. rngRoll .. "|" .. crossChance )
			if rngRoll < crossChance then
				print("WoodenCross Triggered!")
				player:UseCard(Card.CARD_HOLY)
			end
		end
		


	end	
end
--Filigree Feather code
function TrinketStacking:onAngelKill(ent)
	--Make sure the room is either angel or sac room so it doesnt trigger for the mega satan fight
	if game:GetRoom():GetType() == RoomType.ROOM_ANGEL  or game:GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
		for i = 1, game:GetNumPlayers() do
			player = game:GetPlayer(i)
			if player:GetTrinketMultiplier(TrinketType.TRINKET_FILIGREE_FEATHERS) > 1 then
				rng = RNG()
				for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_FILIGREE_FEATHERS) - 1) do
					--print("Triggered filigree soul heart!")
					
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, ent.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
				end
			end
		end

	end
	
	
end

--On start of new level, for Wicked Crown/Holy Crown, Stem Cells
function TrinketStacking:onNewLevel() 
	level = game:GetLevel()
	stage = level:GetStage()
	room = level:GetCurrentRoom()
	roomDesc = level:GetCurrentRoomDesc()
	roomConfigR = roomDesc.Data
	stageID = roomConfigR.StageID
	
	
	--Wicked/Holy Crown Code
	if stage == LevelStage.STAGE6 then --Dark room/Chest stage	
		crownTrinketID = nil
		crownChestType = nil
		if stageID == 16 then --Dark room only
			crownTrinketID = TrinketType.TRINKET_WICKED_CROWN
			crownChestType = PickupVariant.PICKUP_REDCHEST
		elseif stageID == 17 then --The chest only
			crownTrinketID = TrinketType.TRINKET_HOLY_CROWN
			crownChestType = PickupVariant.PICKUP_LOCKEDCHEST
		end
		
		if crownChestType ~= nil and crownTrinketID ~=nil then
			for i = 1, game:GetNumPlayers() do
				player = game:GetPlayer(i)
				if player:GetTrinketMultiplier(crownTrinketID) > 1 then
					rng = RNG()
					for i = 1, (player:GetTrinketMultiplier(crownTrinketID) - 1) do		
						Isaac.Spawn(EntityType.ENTITY_PICKUP, crownChestType, ChestSubType.CHEST_CLOSED, Vector(320,270), Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20) ), player)
					end
				end			
			end
	
		end
	end

	--Stem Cells code
	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_STEM_CELL) > 1 then
			rng = RNG()
			for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_STEM_CELL) - 1) do		
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, Vector(320,270), Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
			end
		end
		
		--Myosotis flag
		if player:GetTrinketMultiplier(TrinketType.TRINKET_MYOSOTIS) > 1 then
			print("Flagging myosotis")
			myosotisFlag = 1
		end
	end

	
	

end

--On player hurt: 
function TrinketStacking:onPlayerHurt(player, dmg, dmgFlags, dmgSource, cdFrames)
	player = player:ToPlayer()
	--print("Player hurt")


end

--Bloody Crown/Silver Dollar code
local momsHeartKills = 0
function TrinketStacking:onMomsHeartKill(ent)
	momsHeartKills = momsHeartKills + 1
	level = game:GetLevel()
	stage = level:GetStage()
	--Make sure the room is the boss room on the womb
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS  and (stage == LevelStage.STAGE4_2 or stage == LevelStage.STAGE4_1) and momsHeartKills % 2 == 1 then
		local seed = game:GetSeeds():GetStartSeed()
		for i = 1, game:GetNumPlayers() do
			--Iterate for Bloody Crown and Silver Dollar
			player = game:GetPlayer(i)
			for j = 1, 2 do
					local price = 0
					local crownTrinketID = nil
					if j == 1 then
						crownTrinketID = TrinketType.TRINKET_BLOODY_CROWN
						pool = ItemPoolType.POOL_BOSS
						price = 0
						
					else
						crownTrinketID = TrinketType.TRINKET_SILVER_DOLLAR
						pool = ItemPoolType.POOL_SHOP
						price = 15
					end
					
					if player:GetTrinketMultiplier(crownTrinketID) > 1 then
						local rng = player:GetTrinketRNG(crownTrinketID)
						for i = 1, (player:GetTrinketMultiplier(crownTrinketID) - 1) do
							--print("Triggered Mom's Heart Crown/Silver Dollar!")
							if i == 1 then
								local spawnItem = TrinketStacking:spawnItemFromPool(ItemPoolType.POOL_BOSS, Vector(10 + rng:RandomInt(190), 10 + rng:RandomInt(370)), price, seed)
							else
								local spawnItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)
							end
											
							
						end
					end			
			
			end
	
		end

	end	
end
--Function to spawn item from a certain pool w/ a certain price
function TrinketStacking:spawnItemFromPool(pool, pos, price, seed)
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

--Additional multipliers for the bulb trinkets will grant you an addition of these stats
local VibrantBulbBoosts =  {
	SPEED = 0.1,
	DMG = 0.5,
	LUCK = 1
}
local DimBulbBoosts =  {
	SPEED = 0.1,
	DMG = 0.75,
	LUCK = 1
}
function TrinketStacking:onCacheEval(player, cacheFlag)
	
	local hasChargedActive = 0
	local hasUnChargedActive = 0
	local bulbTrinketToCheck = nil
	--This will be the total amount of boosts gained from bulb trinkets
	local bulbBoosts =  {
		SPEED = 0,
		DMG = 0,
		LUCK = 0
	}
	--Check for bulb trinket conditions
	if player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB)  > 1 or player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB) > 1 then
		--Check every active slot for an uncharged item
		
		for slot = 0, 2 do
			if player:GetActiveItem(slot) ~= 0 then
				if player:NeedsCharge(slot) then
					hasUnChargedActive = hasUnChargedActive + 1
				else
					hasChargedActive = hasChargedActive + 1
				end	
			end
		end
		
		if hasUnChargedActive > 0 and player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB) > 1 then
			bulbBoosts.SPEED = bulbBoosts.SPEED + DimBulbBoosts.SPEED * (player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB) - 1)
			bulbBoosts.DMG = bulbBoosts.DMG + DimBulbBoosts.DMG * (player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB) - 1)
			bulbBoosts.LUCK = bulbBoosts.DMG + DimBulbBoosts.LUCK * (player:GetTrinketMultiplier(TrinketType.TRINKET_DIM_BULB) - 1)
			--print("Bulb: Dim: Dmg = " .. bulbBoosts.DMG)
		end
		if hasChargedActive > 0 and player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB) > 1 then
			bulbBoosts.SPEED = bulbBoosts.SPEED + VibrantBulbBoosts.SPEED * (player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB) - 1)
			bulbBoosts.DMG = bulbBoosts.DMG + VibrantBulbBoosts.DMG * (player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB) - 1)
			bulbBoosts.LUCK = bulbBoosts.DMG + VibrantBulbBoosts.LUCK * (player:GetTrinketMultiplier(TrinketType.TRINKET_VIBRANT_BULB) - 1)
			
			--print("Bulb: Vibrant: Dmg = " .. bulbBoosts.DMG)
		end
	end	
	

	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + bulbBoosts.DMG
	end
	if cacheFlag == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed + bulbBoosts.SPEED
	end
	if cacheFlag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + bulbBoosts.LUCK
	end
end

function TrinketStacking:onPlayerUpdate(player) 
	--Apple of sodom code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) > 1 then	
		for pIndex, pickup in pairs(Isaac.FindInRadius(player.Position, 10, EntityPartition.PICKUP)) do
			if pickup.Variant == PickupVariant.PICKUP_HEART and pickup:GetData().Stack_Sodom ~= 1 and pickup:GetSprite():GetAnimation() == "Idle" then		
				pickup:GetSprite():Play("Collect", true)
				print("Apple heart detected")
				pickup:GetData().Stack_Sodom = 1
				local appleSpiderRolls = 0
				--Half heart
				if pickup.SubType == HeartSubType.HEART_HALF then
					appleSpiderRolls = 1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				--Full heart
				elseif pickup.SubType == HeartSubType.HEART_FULL then
					appleSpiderRolls = 2 *(player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				--Double heart
				elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
					appleSpiderRolls = 3 *(player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				end

				print("Spider Rolls: " .. appleSpiderRolls)
				rng = player:GetTrinketRNG(TrinketType.TRINKET_APPLE_OF_SODOM)
				for spiderNum = 1, appleSpiderRolls do
					rngRoll = rng:RandomInt(100)
					if rngRoll < 50 then 
						print("Spawned apple spider")
						--Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, player.Position, Vector(0,0), player)
						player:AddBlueSpider(player.Position)
					end
					

				end
				
				
				
			end
			
		end	
	end
	--Rotten Penny code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) > 1 then
		for pIndex, pickup in pairs(Isaac.FindInRadius(player.Position, 10, EntityPartition.PICKUP)) do
			if pickup.Variant == PickupVariant.PICKUP_COIN and pickup:GetData().ROTTEN_PENNY_CHECK ~= 1 and pickup:GetSprite():GetAnimation() == "Collect" then		
				pickup:GetData().ROTTEN_PENNY_CHECK = 1
				rng = player:GetTrinketRNG(TrinketType.TRINKET_ROTTEN_PENNY)
				rngRoll = rng:RandomInt(100)
				rngChance = (30 + 20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) - 1) )
				print("Roll: " .. rngRoll .. "|" .. rngChance)	
				if rngRoll <= rngChance then 
					--print("Spawned rotten penny fly")
					player:AddBlueFlies(1, player.Position, player )
				end				
			end
		end
	end
end

--Chance to add addition flies/spiders with Fish Tail
function TrinketStacking:onBlueFlySpider(fly)
	player = fly.Player
	if (fly:GetData().Stacked_Check == nil) and (player:GetTrinketMultiplier(TrinketType.TRINKET_FISH_TAIL) > 1) then
		fly:GetData().Stacked_Check = true
		rng = player:GetTrinketRNG(TrinketType.TRINKET_FISH_TAIL)
		
		for rolls = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_FISH_TAIL) - 1) do
			rngRoll = rng:RandomInt(100)
			if rngRoll <= 5 then
				--print("Extra fly spawn")
				spawned = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, fly.Variant, 0, player.Position, Vector(0,0), player)
				spawned:GetData().Stacked_Check = true
			end		
		end
	end
	
end

function TrinketStacking:onRoomClear(rng, pos)

	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) > 1 then
			rngRoll = rng:RandomInt(100)
			rngChance = 5 * player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) --10% chance to get micro battery on room clear, extra 5% per multiplier
			print("Battery roll: " .. rngRoll .. "|" .. rngChance)
			
			if rngRoll <= rngChance then
				battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pos, Vector(0.25,-0.25), nil)
			end
		end
	end
	
end

function TrinketStacking:onSecretRoomEntered()
	--print("Secret room entered!")
	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) > 1 then
			for i = 1, player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) - 1 do
				rng = player:GetTrinketRNG(TrinketType.TRINKET_FRAGMENTED_CARD)
				rngRoll = rng:RandomInt(100)
				rngChance = 50
				--print("Frag Card Sack Roll: " .. rngRoll .. "|" .. rngChance)
				if rngRoll <= rngChance then
					sack = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, player.Position, Vector(-15 + rng:RandomInt(30),-15 + rng:RandomInt(30)), nil)
				end	
			end
		end
	end
end



TrinketStacking:AddCallback(ModCallbacks.MC_POST_UPDATE, TrinketStacking.onUpdate)
TrinketStacking:AddCallback(ModCallbacks.MC_POST_RENDER, TrinketStacking.onRender)
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, TrinketStacking.onNewRoom)
--Angel statue boss killed for Filigree Feather
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, TrinketStacking.onAngelKill, EntityType.ENTITY_GABRIEL)
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, TrinketStacking.onAngelKill, EntityType.ENTITY_URIEL)

--For Bloody Crown
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TrinketStacking.onNewLevel)

--On player harmed
TrinketStacking:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TrinketStacking.onPlayerHurt, EntityType.ENTITY_PLAYER)

--On Mom's Heart kill, for Bloody Crown
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, TrinketStacking.onMomsHeartKill, EntityType.ENTITY_MOMS_HEART)

--Cache update for stat boosting items
TrinketStacking:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, TrinketStacking.onCacheEval)

--Blue flies created, for Fish Tail
TrinketStacking:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, TrinketStacking.onBlueFlySpider, FamiliarVariant.BLUE_FLY)
TrinketStacking:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, TrinketStacking.onBlueFlySpider, FamiliarVariant.BLUE_SPIDER)

--On room clear, for AAA Battery
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, TrinketStacking.onRoomClear)
--Player update
TrinketStacking:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, TrinketStacking.onPlayerUpdate)
--Game start
TrinketStacking:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TrinketStacking.onStart)


--TrinketStacking:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TrinketStacking.onStart)
--TrinketStacking:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, TrinketStacking.onGameExit)



