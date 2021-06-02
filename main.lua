local TrinketStacking = RegisterMod("TrinketStackingMod", 1)
local game = Game()
local json = require("json")
local sound = SFXManager()

local GameState = {}

TrinketStacking.EIDSUPPORT = true --Set this to false if you don't want the stacking effect listed with Extended Item Descriptions

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

*Pay To Win: Restock boxes appear in Blue Womb treasure rooms, and Chest/Dark Room starting room

*Store Key: Gives a damage up for each shop you enter while holding the store key

*Safety Scissors: Chance to resist explosive damage

*Hairpin: Killing the boss room boss drops a battery

****BUGS
*Continuing the run with fish tail will give you a chance to duplicate flies/spiders
*Wooden Cross's shield will stay on isaac when you drop it after it replenishes via holy card trigger
*Store key, vibrant/dim bulbs damage is not affected by dmg multipliers like soy milk or polyphemus
]]--

TrinketStacking.DEBUG = 0 --ENABLES DEBUG MODE! Make sure this is 0 unless you are testing the mod


--Check for store key at the start of the game
local initialStoreKeyCheck = 0
function TrinketStacking:onStart(continuedRun)
	if continuedRun == true and TrinketStacking:HasData() then
		GameState = json.decode(TrinketStacking:LoadData() )
		--Evaluate cache for store key on run continue

	end
	if GameState.StoreKeyData == nil or continuedRun == false then GameState.StoreKeyData = {0,0,0,0,0,0,0,0} end
	if GameState.StoreKeyFlag == nil or continuedRun == false then GameState.StoreKeyFlag = {0,0,0,0,0,0,0,0} end
	initialStoreKeyCheck = 1
end

function TrinketStacking:onGameExit(bool)
	if bool then
		TrinketStacking:SaveData(json.encode(GameState))
	end
end


local myosotisFlag = 0
--Makes sure hairpin only triggers once per boss room
local hairpinTriggered = 0


function TrinketStacking:onUpdate()
	--DEBUG ONLY spawns items
	if TrinketStacking.DEBUG == 1 and game:GetFrameCount() == 1 then
		print("DEBUG MODE ENABLED FOR TRINKET STACKING PLUS")
		player = Isaac.GetPlayer(1)
		
		--Isaac.ExecuteCommand("debug 4") --Big dmg
		Isaac.ExecuteCommand("debug 3") --Infinite hp
		Isaac.ExecuteCommand("debug 7")	--Show dmg nums
		Isaac.ExecuteCommand("debug 8")	--Infinite charge
		Isaac.ExecuteCommand("debug 10") --Insta kills
		
		Isaac.Spawn(EntityType.ENTITY_DUMMY,0, 0, Vector(320, 270), Vector(0,0), player) --Dummy
		
		
		player:AddCollectible(534) --School Bag
		--player:AddCollectible(479,12) --Smelter
		player:AddCollectible(439,12) --Mom's box
		Isaac.Spawn(5,100, 439, player.Position + Vector(0,-60), Vector(0,0), player) --Mom's Box
		--player:AddCollectible(139) --Moms purse
		
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

		
		--Rotten penny
		--player:AddTrinket(126) --Rotten penny
		
		--Wish bone
		
		--player:AddTrinket(104) --Wish bone
		--player:AddCollectible(486)
		--player:AddCard(31)
		
		--Store key
		--[[
		player:AddTrinket(83) --Wish bone
		player:AddCard(10)	--Hermit card	
		]]--
		--Safety Scissors
		--player:AddTrinket(63) --Safety Scissors
		--player:AddCollectible(190) --Pyro
		
		--Hairpin
		player:AddTrinket(120) --Hairpin
		player:AddCard(5) -- Emp card
					
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

	--Store key flagging
	for i = 1, game:GetNumPlayers() do
		if GameState.StoreKeyFlag ~= nil then
			if GameState.StoreKeyFlag[i] == 0 then
				if player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 then
					--print("Player picked up store key")
					GameState.StoreKeyFlag[i] = 1
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
									
				end
			--Unflag store key if the player doesn't have it anymore
			elseif GameState.StoreKeyFlag[i] == 1 then
				if player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) <= 1 then
						--print("Player dropped store key")
						GameState.StoreKeyFlag[i] = 0
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
						player:EvaluateItems()
				end		
			
			end
		end
	end

	if GameState.StoreKeyFlag ~= nil and initialStoreKeyCheck == 1 then
		initialStoreKeyCheck = 2
		for i = 1, game:GetNumPlayers()do
			if GameState.StoreKeyFlag[i] >= 1 and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 then
					player = game:GetPlayer(i)
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()			
			end
		end	
	end
end


function TrinketStacking:onRender() 
	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		player:GetData().pNum = i			
	end

end

--On new room entered: Locusts, familiars
function TrinketStacking:onNewRoom() 
	hairpinTriggered = 0
	level = game:GetLevel()
	room = level:GetCurrentRoom()
	roomDesc = level:GetCurrentRoomDesc()
	roomConfigR = roomDesc.Data
	stageID = roomConfigR.StageID
	--Check to see if the room has been seen before
	if(roomDesc.VisitedCount <= 1) then
		if not roomDesc.Clear  then
			TrinketStacking.onHostileRoomStart()
		end
		--Trigger on secret rooms for Fragmented card
		if room:GetType() == RoomType.ROOM_SECRET then
			TrinketStacking.onSecretRoomEntered()
		end
		--Store Key increment
		if room:GetType() == RoomType.ROOM_SHOP then
			TrinketStacking.onShopEntered()
		end		
		
		--Pay to Win code for Blue Womb/Hush 
		if stageID == 13 and roomConfigR.Type == RoomType.ROOM_TREASURE then --Blue Womb/Hush floor
			if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) > 1 then
				Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, Vector(150,300) + Vector(0, -50 + rng:RandomInt(100)), Vector(0,0), player)
			end
			
		end
	end
	--Code for ???'s Soul and Isaac's Head
	famCount = 2 --Amount of familiars in the following tables. ???'s soul + isaac's head = 2
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

--On hostile room start, for locusts
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
	hairpinTriggered = 0
	level = game:GetLevel()
	stage = level:GetStage()
	room = level:GetCurrentRoom()
	roomDesc = level:GetCurrentRoomDesc()
	roomConfigR = roomDesc.Data
	stageID = roomConfigR.StageID
	
	--Wicked/Holy Crown and Pay To Win Code
	if stage == LevelStage.STAGE6 then --Dark room/Chest stage	
		--Pay To Win
		if stageID == 16 or stageID == 17 then --Dark Room or Chest
			for i = 1, game:GetNumPlayers() do
				player = game:GetPlayer(i)
				if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) > 1 then
					
					rng = player:GetTrinketRNG(TrinketType.TRINKET_PAY_TO_WIN)
					--for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) - 1) do
					for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) - 1) do	
						--print("Spawning")
						Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, Vector(320,270) + Vector(-100 + rng:RandomInt(200),-100 + rng:RandomInt(200)), Vector(0,0), player)
					end
				end			
			end		
		end
		--Wicked/Holy Crown
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
			--print("Flagging myosotis")
			myosotisFlag = 1
		end
	end

	
	

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
							--Spawn item
							if i == 1 then
								local spawnItem = TrinketStacking:spawnItemFromPool(pool, Vector(10 + rng:RandomInt(190), 10 + rng:RandomInt(370)), price, seed)
							--Spawn sacks
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
	
	pNum = player:GetData().pNum
	--Store key code
	local storeKeyDmg = 0
	if pNum ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 and GameState.StoreKeyData[pNum] >= 1 then
		
		storeKeyDmg = 0.15 + GameState.StoreKeyData[pNum] * 0.1
	
	end
	if cacheFlag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + bulbBoosts.DMG + storeKeyDmg
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
				pickup:GetData().Stack_Sodom = 1
				local appleSpiderRolls = 0
				--Half heart
				if pickup.SubType == HeartSubType.HEART_HALF then
					appleSpiderRolls = 1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				--Full heart
				elseif pickup.SubType == HeartSubType.HEART_FULL then
					appleSpiderRolls = 1 *(player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				--Double heart
				elseif pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
					appleSpiderRolls = 2 *(player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) - 1)
				end

				--print("Spider Rolls: " .. appleSpiderRolls)
				rng = player:GetTrinketRNG(TrinketType.TRINKET_APPLE_OF_SODOM)
				for spiderNum = 1, appleSpiderRolls do
					rngRoll = rng:RandomInt(100)
					if rngRoll < 50 then 
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
				--print("Roll: " .. rngRoll .. "|" .. rngChance)	
				if rngRoll <= rngChance then 
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
			--print("FishTail: " .. rngRoll .. "|3")
			if rngRoll <= 3 then
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
		--AAA Battery code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) > 1 then
			rngRoll = rng:RandomInt(100)
			rngChance = 5 * player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) --10% chance to get micro battery on room clear, extra 5% per multiplier
			--print("Battery roll: " .. rngRoll .. "|" .. rngChance)
			
			if rngRoll <= rngChance then
				battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pos, Vector(0.25,-0.25), nil)
			end
		end
	
		--Code for Wooden Cross
		if player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_WOODEN_CROSS)
			local rngRoll = rng:RandomInt(100)
			local crossChance = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) - 1) * 10
			--print("WoodenCross Roll: " .. rngRoll .. "|" .. crossChance )
			if rngRoll < crossChance then
				--print("WoodenCross Triggered!")
				player:UseCard(Card.CARD_HOLY)
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

--On player hurt, used for safety scissors
function TrinketStacking:onPlayerHurt(player, dmg, flags, dmgSource, cdFrames)
	player = player:ToPlayer()
	--Safety scissors code
	if (flags & DamageFlag.DAMAGE_EXPLOSION) > 0 then
		if player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) > 1 then
			rng = player:GetTrinketRNG(TrinketType.TRINKET_SAFETY_SCISSORS)
			rngRoll = rng:RandomInt(100)
			rngChance = 40 + (20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) - 1))
			--print("Resist expl: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				return false
			end
		end
	end
end

--Store key code
function TrinketStacking:onShopEntered()
	for i = 1, game:GetNumPlayers() do
		player = game:GetPlayer(i)
		pNum = player:GetData().pNum
		if pNum ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 then
			GameState.StoreKeyData[pNum] = GameState.StoreKeyData[pNum] + (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) - 1)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			--print("Store key data: " ..GameState.StoreKeyData[pNum])
		end
	end
end


function TrinketStacking:onNPCDeath(enemy)
	--On boss killed
	if enemy:IsBoss() and hairpinTriggered == 0 then
		level = game:GetLevel()
		room = level:GetCurrentRoom()
		roomType = room:GetType()
		if roomType == RoomType.ROOM_BOSS then
			for i = 1, game:GetNumPlayers() do
				player = game:GetPlayer(i)		
				if player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) > 1 then
					rng = player:GetTrinketRNG(TrinketType.TRINKET_HAIRPIN)
					hairpinTriggered = 1
					for spawns = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) - 1) do
						battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, Vector(320,270), Vector(-10 + rng:RandomInt(10),rng:RandomInt(3) ), nil)
					end
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

--Player Hurt
TrinketStacking:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TrinketStacking.onPlayerHurt, EntityType.ENTITY_PLAYER)

--Game start/exit for any save data
TrinketStacking:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, TrinketStacking.onStart)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, TrinketStacking.onGameExit)

--On NPC death
TrinketStacking:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, TrinketStacking.onNPCDeath)

local changedEID = false
if EID and not changedEID then
	changedEID = true
	local currStr = ""
	local currID = 0
	local startStr = "#{{Collectible439}} Stacking+: "
	
	--Locusts
	for l = 1, 5 do
		local currID = 112 + l
		local currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Adds a chance to spawn extra locusts"
		EID:addTrinket(currID, currStr)
	end
	
	--Filigree Feather
	currID = 123
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Angel statue bosses also drop soul hearts"
	EID:addTrinket(currID, currStr)	
	
	--Wicked Crown
	currID = 161
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra chests spawn at the start of the Dark Room floor"
	EID:addTrinket(currID, currStr)	

	--Holy Crown
	currID = 155
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra chests spawn at the start of The Chest floor"
	EID:addTrinket(currID, currStr)	

	--Bloody Crown
	currID = 111
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Mom's Heart drops a boss item when killed"
	EID:addTrinket(currID, currStr)	
	
	--Silver Dollar
	currID = 110
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Mom's Heart drops a buyable shop item when killed"
	EID:addTrinket(currID, currStr)	
	
	--Wooden Cross
	currID = 121
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to replenish shield on room clear"
	EID:addTrinket(currID, currStr)	

	--???'s Soul
	currID = 57
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra copy of the familiar"
	EID:addTrinket(currID, currStr)	

	--Isaac's Head
	currID = 54
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra copy of the familiar"
	EID:addTrinket(currID, currStr)	
	
	--Vibrant Bulb
	currID = 100
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra stat boosts when fully charged"
	EID:addTrinket(currID, currStr)	
		
	--Dim Bulb
	currID = 101
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Extra stat boosts when partially charged and NOT fully charged"
	EID:addTrinket(currID, currStr)	
	
	--Apple of Sodom
	currID = 140
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to spawn extra spiders on heart pickup"
	EID:addTrinket(currID, currStr)	
			
	--Fish Tail
	currID = 94
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to generate extra flies/spiders"
	EID:addTrinket(currID, currStr)	

	--AAA Battery
	currID = 3
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to spawn a micro battery on room clear"
	EID:addTrinket(currID, currStr)	

	--Fragmented Card
	currID = 102
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to spawn extra sacks when entering a secret room"
	EID:addTrinket(currID, currStr)	

	--Stem Cell
	currID = 119
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Spawn red hearts in the starting room of each floor"
	EID:addTrinket(currID, currStr)	
	
	--Myosotis
	currID = 137
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to duplicate the carried over pickups"
	EID:addTrinket(currID, currStr)	
	
	--Rotten Penny
	currID = 126
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to spawn extra flies on coin pickup"
	EID:addTrinket(currID, currStr)	
	
	--Pay To Win
	currID = 112
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Restock boxes appear in Blue Womb treasure rooms, and Chest/Dark Room starting room"
	EID:addTrinket(currID, currStr)	

	--Store Key
	currID = 83
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Gives a damage up for each shop you enter while holding the store key"
	EID:addTrinket(currID, currStr)		
	
	--Safety Scissors
	currID = 63
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Chance to resist explosive damage"
	EID:addTrinket(currID, currStr)	

	--Hairpin
	currID = 120
	currStr = EID:getDescriptionObj(5, 350, currID).Description .. startStr .. "Killing the boss room boss drops a battery"
	EID:addTrinket(currID, currStr)		
end


