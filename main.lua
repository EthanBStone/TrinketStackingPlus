local TrinketStacking = RegisterMod("TrinketStackingMod", 1)

local game = Game()
local json = require("json")
local sound = SFXManager()
local GameState = {}

local Helpers = require("helpers.lua")


TrinketStacking.EIDSUPPORT = true --Set this to false if you don't want the stacking effect listed with Extended Item Descriptions

--[[
Notes: 
Locusts are familiars, variant 43 "Blue Fly"
Center of a room: 320, 270
Extension cord laser: Subtype 2


====Current Interactions====
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

===Content Update 1===

*Pay To Win: Restock boxes appear in Blue Womb treasure rooms, and Chest/Dark Room starting room

*Store Key: Gives a damage up for each shop you enter while holding the store key

*Safety Scissors: Chance to resist explosive damage

*Hairpin: Killing the boss room boss drops a battery

===Content Update 2===

*Equality: Picking up a consumable gives a chance to spawn the consumable type that Isaac has the least of

*Crow Heart: Change to convert incoming damage into "fake" damage like dull razor

*Store Credit: Small chance to not destroy the trinket when buying from the shop. If the chance fails, drops several coins

*Your Soul: Small chance to not destroy the trinket when taking a devil deal. If the chance fails, drops a black sack

*Judas' Tongue: Chance to spawn a black heart when taking a devil deal

===Mini Update===
*Extension Cord: Most of your familiars' tears will be Tech Zero electrical tears, with a small chance to gain a Jacob's Ladder effect

*Baby-Bender: Familiars have more range and better homing

===Worms Update===
*Ring Worm - tears up

*Pulse Worm - dmg up

*Ouroboros Worm - tears + luck up

*Rainbow Worm - tears up

*Mom's Toenail- more frequent stomping, and some stomps target and slow enemies

*Callus - speed up

*The Left Hand - Opening red chests has a chance to spawn black hearts

*Pinky Eye - Luck up, meaning better chance to poison

===Next Update===
*Strange Key - Chance to replace non-quest item pedestals with Pandora's Box

*Flat Worm - Damage up
====BUGS====
*Continuing the run with fish tail will give you a chance to duplicate flies/spiders
*Wooden Cross's shield will stay on isaac when you drop it after it replenishes via holy card trigger
*Store key, vibrant/dim bulbs damage is not affected by dmg multipliers like soy milk or polyphemus
*Crow Heart doesnt give iframes

*Cracked dice's dice shard drop will be rerolled if you get the d20 effect
*Need to fix cache checking when you already have 1 of the trinket. intead of making playerflag a bool, make it be the trinket multiplier the player has, so if it gets reduced or increased we can call a cache check
]]--

TrinketStacking.DEBUG = 0 --ENABLES DEBUG MODE! Make sure this is 0 unless you are testing the mod

local gameStartedCheck = 0 

--Check for store key at the start of the game
local initialStoreKeyCheck = 0
function TrinketStacking:onStart(continuedRun)
	if continuedRun == true and TrinketStacking:HasData() then
		GameState = json.decode(TrinketStacking:LoadData() )
		--Evaluate cache for store key on run continue

	end
	if GameState.StoreKeyData == nil or continuedRun == false then GameState.StoreKeyData = {0,0,0,0,0,0,0,0} end
	if GameState.PANDORAS_BOX_CHECKED == nil or continuedRun == false then GameState.PANDORAS_BOX_CHECKED = {} end
	gameStartedCheck = 0 
end

function TrinketStacking:onGameExit(bool)
	if bool then
		TrinketStacking:SaveData(json.encode(GameState))
	end
end


local myosotisFlag = 0
--Makes sure hairpin only triggers once per boss room
local hairpinTriggered = 0

--Trinkets that cause cache updates
local cacheUpdateTrinkets = {
	["Store Key"] = {id = 83, cache = {CacheFlag.CACHE_DAMAGE}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Pulse Worm"] = {id = 9, cache = {CacheFlag.CACHE_DAMAGE}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Rainbow Worm"] = {id = 64, cache = {CacheFlag.CACHE_FIREDELAY}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Callus"] = {id = 14, cache = {CacheFlag.CACHE_SPEED}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Pinky Eye"] = {id = 30, cache = {CacheFlag.CACHE_LUCK}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Flat Worm"] = {id = 12, cache = {CacheFlag.CACHE_DAMAGE}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["Isaac's Head"] = {id = 54, cache = {CacheFlag.CACHE_FAMILIARS}, playerFlags = {0,0,0,0,0,0,0,0}}, 
	["???'s Soul"] = {id = 57, cache = {CacheFlag.CACHE_FAMILIARS}, playerFlags = {0,0,0,0,0,0,0,0}}, 
}

function TrinketStacking:onUpdate()	
	--DEBUG ONLY spawns items
	if TrinketStacking.DEBUG == 1 and game:GetFrameCount() == 1 then
		print("DEBUG MODE ENABLED FOR TRINKET STACKING PLUS")
		local player = Isaac.GetPlayer(1)
		
		--Isaac.ExecuteCommand("debug 4") --Big dmg
		Isaac.ExecuteCommand("debug 3") --Infinite hp
		Isaac.ExecuteCommand("debug 7")	--Show dmg nums
		Isaac.ExecuteCommand("debug 8")	--Infinite charge
		--Isaac.ExecuteCommand("debug 10") --Insta kills
		
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
		--[[
		player:AddTrinket(120) --Hairpin
		player:AddCard(5) -- Emp card
		]]--
		
		--Your soul
		--[[
		player:AddTrinket(173) --Your soul
		player:AddCard(31) -- Joker
		]]--
		
		--Judas tongue
		player:AddTrinket(56) --Your soul
		player:AddCard(31) -- Joker
						
	end

	--Myosotis code
	if myosotisFlag == 1 then
		myosotisFlag = 0
		for i = 1, game:GetNumPlayers() do
			for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
				if pickup:GetData().TStack_Myosotis == nil then
					local rng = player:GetTrinketRNG(TrinketType.TRINKET_MYOSOTIS)
					local rngRoll = rng:RandomInt(100)
					local rngChance = 15 + (player:GetTrinketMultiplier(TrinketType.TRINKET_MYOSOTIS) - 1) * 10
					--print("Dupe rng: " .. rngRoll .. "|" .. rngChance)
					
					if rngRoll < rngChance then
						--print("Duped")
						local duplicate = Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, pickup.SubType, pickup.Position, Vector(-2 + rng:RandomInt(2), -2 + rng:RandomInt(2)), player)
						duplicate:GetData().TStack_Myosotis = 1
					end
				end
			end		
		end

	end

	--Flagging for cache changing trinkets
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		for _, trinket in pairs(cacheUpdateTrinkets) do
			if trinket.playerFlags[i] ~= nil then
				--Flag trinket if they didnt already have it
				if player:GetTrinketMultiplier(trinket.id) ~= trinket.playerFlags[i] then
					--print("Player picked up worm")
					trinket.playerFlags[i] = player:GetTrinketMultiplier(trinket.id)
					for x, caches in pairs(trinket.cache) do
						player:AddCacheFlags(caches)				
					end
					player:EvaluateItems()						
				end
			end			
		end
	
	end

	--Update cache at start of game
	if gameStartedCheck == 0 then
		gameStartedCheck = 1 
		for i = 1, game:GetNumPlayers()do
			player = game:GetPlayer(i)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)	
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)	
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			player:EvaluateItems()					
			
		end	
	end

	--Stomping for Mom's Toenail
	if ((25 * 30) + game:GetFrameCount() ) % (30 * 35) == 1 then
		for i = 1, game:GetNumPlayers() do
			local player = game:GetPlayer(i)	
			if player:GetTrinketMultiplier(TrinketType.TRINKET_MOMS_TOENAIL) > 1 then
				local maxFeet = player:GetTrinketMultiplier(TrinketType.TRINKET_MOMS_TOENAIL) - 1
				local currFeet = 0
				for _, ent in pairs(Isaac.FindInRadius(player.Position, 1200, EntityPartition.ENEMY)) do
					if currFeet >= maxFeet then	
						break
					end
					if ent:IsVulnerableEnemy() then
						currFeet =  currFeet + 1
						local slowColor = Color(1, 0.9, 0.9, 1, 0, 0, 0)
						ent:AddSlowing(EntityRef(player), 30, 0.5, slowColor)
						Isaac.Spawn(1000, 29, 0, ent.Position, Vector(0,0), nil)				
					end
				end			
			end

		end
	end
	
	--Checking for Strange key
	if game:GetFrameCount() % 30 == 1 then
		for i = 1, game:GetNumPlayers() do
			local player = game:GetPlayer(i)	
			local checkedSize = 0
			local hasItem = {0,0}
			for slot = 1, 2 do --For both active item slots
				local checkedSize = 0
				--Check to see if item has already been checked
				for _, item in pairs(GameState.PANDORAS_BOX_CHECKED) do
					checkedSize = checkedSize + 1
					if item == player:GetActiveItem(slot-1) then
						hasItem[slot] = 1
					end
				end
				
				if hasItem[slot] == 0 then
					--print("Add active item: " .. player:GetActiveItem(slot-1))
					GameState.PANDORAS_BOX_CHECKED[checkedSize + 1] = player:GetActiveItem(slot-1)
				end
				
			end

		end
	end
	

end


function TrinketStacking:onRender() 
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		player:GetData().pNum = i			
	end

end

--On new room entered: Locusts
function TrinketStacking:onNewRoom() 
	hairpinTriggered = 0
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomConfigR = roomDesc.Data
	local stageID = roomConfigR.StageID
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
	
	for _, bSoul in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_BABY_SOUL) ) do
		if bSoul:GetData().StackedSpawn ~= nil  then
			local rng = game:GetPlayer(0):GetTrinketRNG(TrinketType.TRINKET_SOUL)
			bSoul.Position = bSoul.Position + Vector(rng:RandomInt(30),rng:RandomInt(30))
		end
	
	end
end


--On hostile room start, for locusts
function TrinketStacking:onHostileRoomStart()
	for pNum = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(pNum)
		--Code for all locust items
		for locustIndex = 1, 5 do
			if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) > 1 then
				for j = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN + locustIndex) - 1) do
					local rng = player:GetTrinketRNG(TrinketType.TRINKET_PAY_TO_WIN + locustIndex)
					local rngRoll = rng:RandomInt(100)
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
			local player = game:GetPlayer(i)
			if player:GetTrinketMultiplier(TrinketType.TRINKET_FILIGREE_FEATHERS) > 1 then
				local rng = RNG()
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
	local level = game:GetLevel()
	local stage = level:GetStage()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomConfigR = roomDesc.Data
	local stageID = roomConfigR.StageID
	
	--Wicked/Holy Crown and Pay To Win Code
	if stage == LevelStage.STAGE6 then --Dark room/Chest stage	
		--Pay To Win
		if stageID == 16 or stageID == 17 then --Dark Room or Chest
			for i = 1, game:GetNumPlayers() do
				local player = game:GetPlayer(i)
				if player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) > 1 then
					
					local rng = player:GetTrinketRNG(TrinketType.TRINKET_PAY_TO_WIN)
					--for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) - 1) do
					for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_PAY_TO_WIN) - 1) do	
						--print("Spawning")
						Isaac.Spawn(EntityType.ENTITY_SLOT, 10, 0, Vector(320,270) + Vector(-100 + rng:RandomInt(200),-100 + rng:RandomInt(200)), Vector(0,0), player)
					end
				end			
			end		
		end
		--Wicked/Holy Crown
		local crownTrinketID = nil
		local crownChestType = nil
		if stageID == 16 then --Dark room only
			crownTrinketID = TrinketType.TRINKET_WICKED_CROWN
			crownChestType = PickupVariant.PICKUP_REDCHEST
		elseif stageID == 17 then --The chest only
			crownTrinketID = TrinketType.TRINKET_HOLY_CROWN
			crownChestType = PickupVariant.PICKUP_LOCKEDCHEST
		end
		
		if crownChestType ~= nil and crownTrinketID ~=nil then
			for i = 1, game:GetNumPlayers() do
				local player = game:GetPlayer(i)
				if player:GetTrinketMultiplier(crownTrinketID) > 1 then
					local rng = RNG()
					for i = 1, (player:GetTrinketMultiplier(crownTrinketID) - 1) do		
						Isaac.Spawn(EntityType.ENTITY_PICKUP, crownChestType, ChestSubType.CHEST_CLOSED, Vector(320,270), Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20) ), player)
					end
				end			
			end
	
		end
	end

	--Stem Cells code
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_STEM_CELL) > 1 then
			local rng = RNG()
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
	local level = game:GetLevel()
	local stage = level:GetStage()
	--Make sure the room is the boss room on the womb
	if game:GetRoom():GetType() == RoomType.ROOM_BOSS  and (stage == LevelStage.STAGE4_2 or stage == LevelStage.STAGE4_1) and momsHeartKills % 2 == 1 then
		local seed = game:GetSeeds():GetStartSeed()
		for i = 1, game:GetNumPlayers() do
			--Iterate for Bloody Crown and Silver Dollar
			local player = game:GetPlayer(i)
			for j = 1, 2 do
					local price = 0
					local pool = ItemPoolType.POOL_BOSS
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
								local spawnItem = Helpers:spawnItemFromPool(pool, Vector(10 + rng:RandomInt(190), 10 + rng:RandomInt(370)), price, seed)
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
local MAX_TEARS = 5
function TrinketStacking:onCacheEval(player, cacheFlag)
	if player:GetData().pNum ~= nil then
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
		
		local pNum = player:GetData().pNum
		--Store key code
		local storeKeyDmg = 0
		if pNum ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 and GameState.StoreKeyData[pNum] >= 1 then
			
			storeKeyDmg = 0.15 + GameState.StoreKeyData[pNum] * 0.1
		
		end
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			--Apply Pulse Worm
			if cacheUpdateTrinkets["Pulse Worm"].playerFlags[pNum] >= 2 then
				player.Damage = player.Damage  + 0.25 + 0.6 * (player:GetTrinketMultiplier(TrinketType.TRINKET_PULSE_WORM) - 1)
			end
			--Apply Flat Worm
			if cacheUpdateTrinkets["Flat Worm"].playerFlags[pNum] >= 2 then
				player.Damage = player.Damage  + 0.25 + 0.6 * (player:GetTrinketMultiplier(TrinketType.TRINKET_FLAT_WORM) - 1)
			end				
			player.Damage = player.Damage + bulbBoosts.DMG + storeKeyDmg
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			--Apply Rainbow worm
			if cacheUpdateTrinkets["Rainbow Worm"].playerFlags[pNum] >= 2 then
				local rWormBoost = Helpers:getTearBoost(1 + (1.5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_RAINBOW_WORM) - 1)), player.MaxFireDelay, MAX_TEARS)
				player.MaxFireDelay = player.MaxFireDelay - rWormBoost
			
			end	
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			if cacheUpdateTrinkets["Callus"].playerFlags[pNum] >= 2 then
				player.MoveSpeed = player.MoveSpeed + 0.1 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CALLUS) - 1)
			end
			player.MoveSpeed = player.MoveSpeed + bulbBoosts.SPEED
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			--Apply Pinky Eye
			if cacheUpdateTrinkets["Pinky Eye"].playerFlags[pNum] >= 2 then
				player.Luck = player.Luck + (2 * (player:GetTrinketMultiplier(TrinketType.TRINKET_PINKY_EYE) - 1))
			end				
			player.Luck = player.Luck + bulbBoosts.LUCK
		end	
		--Update trinket familiars
		if cacheFlag == CacheFlag.CACHE_FAMILIARS then
			Helpers.updateTrinketFamiliars()
		end
	end
	

end


function TrinketStacking:onPlayerUpdate(player) 

	local data = player:GetData()

	--The "gassy" effect caused by butt penny, stores farts for the player
	if data.BP_Gassy ~= nil and data.BP_Gassy.Time > 0 then
		local currFrame = game:GetFrameCount()
		--Conditions for a fart to trigger
		if currFrame % 30 == 1 and currFrame ~= data.BP_Gassy.LastFrame then
			game:Fart(player.Position, 85, player, 1, 3)
			data.BP_Gassy.Time = data.BP_Gassy.Time - 1
			data.BP_Gassy.LastFrame = currFrame
			--print("gassy fart: " .. data.BP_Gassy.Time .. " farts left. Frame: " .. currFrame)
		end	
	end
end

--Chance to add addition flies/spiders with Fish Tail
function TrinketStacking:onBlueFlySpider(fly)
	local player = fly.Player
	if (fly:GetData().Stacked_Check == nil) and (player:GetTrinketMultiplier(TrinketType.TRINKET_FISH_TAIL) > 1) then
		fly:GetData().Stacked_Check = true
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_FISH_TAIL)
		
		for rolls = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_FISH_TAIL) - 1) do
			local rngRoll = rng:RandomInt(100)
			--print("FishTail: " .. rngRoll .. "|3")
			if rngRoll <= 3 then
				--print("Extra fly spawn")
				local spawned = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, fly.Variant, 0, player.Position, Vector(0,0), player)
				spawned:GetData().Stacked_Check = true
			end		
		end
	end
	
end

function TrinketStacking:onRoomClear(rng, pos)
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		--AAA Battery code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) > 1 then
			local rngRoll = rng:RandomInt(100)
			local rngChance = 5 * player:GetTrinketMultiplier(TrinketType.TRINKET_AAA_BATTERY) --10% chance to get micro battery on room clear, extra 5% per multiplier
			--print("Battery roll: " .. rngRoll .. "|" .. rngChance)
			
			if rngRoll <= rngChance then
				local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pos, Vector(0.25,-0.25), nil)
			end
		end
	
		--Code for Wooden Cross
		if player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_WOODEN_CROSS)
			local rngRoll = rng:RandomInt(100)
			local crossChance = 5 + (player:GetTrinketMultiplier(TrinketType.TRINKET_WOODEN_CROSS) - 1) * 10
			--print("WoodenCross Roll: " .. rngRoll .. "|" .. crossChance )
			if rngRoll <= crossChance then
				--print("WoodenCross Triggered!")
				player:UseCard(Card.CARD_HOLY)
			end
		end
		
		
		local curRoomType = game:GetRoom():GetType() 
		--Code for Temporary Tattoo
		if player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO) > 1 and curRoomType == RoomType.ROOM_CHALLENGE then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_TEMPORARY_TATTOO)
			for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO) - 1) do
				--print("Sack spawned")
				--print("i=" .. i .. " mult=" .. player:GetTrinketMultiplier(TrinketType.TRINKET_TEMPORARY_TATTOO))
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, pos, Vector(-10 + rng:RandomInt(20),-10 + rng:RandomInt(20)), nil)			
			end
		end	

		--Code for blue key
		if player:GetTrinketMultiplier(TrinketType.TRINKET_BLUE_KEY) > 1 and curRoomType == 28 and game:GetRoom():GetRoomConfigStage() == 0 then
			--print("Blue key room cleared")
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLUE_KEY)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 25 * player:GetTrinketMultiplier(TrinketType.TRINKET_BLUE_KEY)
			--print("Blue key Roll: " .. rngRoll .. "|" .. rngChance )
			if rngRoll <= rngChance then
				--print("Blue key drop Triggered!")
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, pos, Vector(-2 + rng:RandomInt(4), -2 + rng:RandomInt(4)), nil)
			end			
		end
	end
	
end

function TrinketStacking:onSecretRoomEntered()
	--print("Secret room entered!")
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) > 1 then
			for i = 1, player:GetTrinketMultiplier(TrinketType.TRINKET_FRAGMENTED_CARD) - 1 do
				local rng = player:GetTrinketRNG(TrinketType.TRINKET_FRAGMENTED_CARD)
				local rngRoll = rng:RandomInt(100)
				local rngChance = 50
				--print("Frag Card Sack Roll: " .. rngRoll .. "|" .. rngChance)
				if rngRoll <= rngChance then
					local sack = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 0, player.Position, Vector(-15 + rng:RandomInt(30),-15 + rng:RandomInt(30)), nil)
				end	
			end
		end
	end
end

--On player hurt, used for safety scissors and crow heart, cracked dice, missing poster
function TrinketStacking:onPlayerHurt(player, dmg, flags, dmgSource, cdFrames)
	local player = player:ToPlayer()
	--Safety scissors code
	if (flags & DamageFlag.DAMAGE_EXPLOSION) > 0 then
		if player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_SAFETY_SCISSORS)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 40 + (20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_SAFETY_SCISSORS) - 1))
			--print("Resist expl: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				return false
			end
		end
	end

	--Crow Heart code
	if (flags & DamageFlag.DAMAGE_FAKE) == 0 then
		if player:GetTrinketMultiplier(TrinketType.TRINKET_CROW_HEART) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_CROW_HEART)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 20 + (5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CROW_HEART) - 1))
			--print("Fake dmg: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				player:TakeDamage(0, DamageFlag.DAMAGE_FAKE, EntityRef(player), 9999)
				return false
			end
		end	
	end

	--Bag lunch code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_BAG_LUNCH) > 1 then
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_BAG_LUNCH)
		local rngRoll = rng:RandomInt(100)
		local rngChance = 2 * (player:GetTrinketMultiplier(TrinketType.TRINKET_BAG_LUNCH) - 1 )
		
		--print("Bag lunch roll: " .. rngRoll .. "|" .. rngChance)
		if rngRoll <= rngChance then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_LUNCH, player.Position, Vector(0,0), nil)
			--print("Baglunch payout")
		end
	end

	--Wish bone code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_WISH_BONE) > 1 then
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_WISH_BONE)
		local rngRoll = rng:RandomInt(100)
		local rngChance = 2 * (player:GetTrinketMultiplier(TrinketType.TRINKET_WISH_BONE) - 1 )
		
		--print("Wishbone roll: " .. rngRoll .. "|" .. rngChance)
		if rngRoll <= rngChance then
			--print("Wishbone payout")
			local seed = game:GetSeeds():GetStartSeed()
			local roomType = game:GetRoom():GetType()
			
			local pool = game:GetItemPool()
			local poolType = pool:GetPoolForRoom(roomType, seed)
			--print("room = " .. roomType .. " pool = " .. poolType)
			Helpers:spawnItemFromPool( poolType, player.Position, 0, seed)
			
		end
	end

	--Cracked dice code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_DICE) > 1 then
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_CRACKED_DICE)
		local rngRoll = rng:RandomInt(100)
		local rngChance = 3 + (2 * (player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_DICE) - 1 ) )
		
		--print("cracked dice roll: " .. rngRoll .. "|" .. rngChance)
		if rngRoll <= rngChance then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD, player.Position, Vector(2,2), nil)
			--print("Dice payout")
		end
	end

	--Missing poster code
	if player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_POSTER) > 1 then
		if flags == (DamageFlag.DAMAGE_SPIKES + DamageFlag.DAMAGE_NO_PENALTIES) and dmgSource.Type == 0 and dmgSource.Variant == 0 and game:GetRoom():GetType() == RoomType.ROOM_SACRIFICE then
			--print("Sac room dmg taken")
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_MISSING_POSTER)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 10 + 5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_MISSING_POSTER) )
			--print("m poster roll: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 0, 0, player.Position, Vector(-2 + rng:RandomInt(4),-2 + rng:RandomInt(4) ), nil)
				--print("M Poster payout")
			end
		end
		
	end
	
end

--Store key code
function TrinketStacking:onShopEntered()
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		local pNum = player:GetData().pNum
		if pNum ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) > 1 then
			GameState.StoreKeyData[pNum] = GameState.StoreKeyData[pNum] + (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_KEY) - 1)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			--print("Store key data: " ..GameState.StoreKeyData[pNum])
		end
	end
end

--On boss kill, for Hairpin
function TrinketStacking:onNPCDeath(enemy)
	--On boss killed
	if enemy:IsBoss() and hairpinTriggered == 0 then
		local level = game:GetLevel()
		local room = level:GetCurrentRoom()
		local roomType = room:GetType()
		if roomType == RoomType.ROOM_BOSS then
			for i = 1, game:GetNumPlayers() do
				local player = game:GetPlayer(i)		
				if player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) > 1 then
					local rng = player:GetTrinketRNG(TrinketType.TRINKET_HAIRPIN)
					hairpinTriggered = 1
					for spawns = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_HAIRPIN) - 1) do
						local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, Vector(320,270), Vector(-10 + rng:RandomInt(10),rng:RandomInt(3) ), nil)
					end
				end
			end
		end
	end
end

--On Coin pickup, for rotten penny, butt penny, cursed penny
function TrinketStacking:onCoinPickup(pickup, ent, bool)
	if ent.Type == EntityType.ENTITY_PLAYER and pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
		local player = ent:ToPlayer()
		--Rotten Penny code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_ROTTEN_PENNY)
			local rngRoll = rng:RandomInt(100)
			local rngChance = (30 + 20 * (player:GetTrinketMultiplier(TrinketType.TRINKET_ROTTEN_PENNY) - 1) )
			--print("Roll: " .. rngRoll .. "|" .. rngChance)	
			if rngRoll <= rngChance then 
				player:AddBlueFlies(1, player.Position, player )
			end		
		end	
	
		--Add gassy stacks with butt penny
		if player:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY) > 1 then
			local data = ent:GetData()
			if data.BP_Gassy == nil or data.BP_Gassy.Time < 0 then
				data.BP_Gassy = { Time = 0, LastFrame = 0 }
			end
			
			--The value of Gassy.Time is how many farts the player will do 
			--A better value coin will give more farts
			local coinMult = 1
			
			if pickup.SubType == CoinSubType.COIN_DOUBLEPACK or pickup.SubType == CoinSubType.COIN_LUCKYPENNY or pickup.SubType == CoinSubType.COIN_NICKEL then
				coinMult = 2
				
			elseif pickup.SubType == CoinSubType.COIN_DIME then
				coinMult = 3
			end
			data.BP_Gassy.Time = data.BP_Gassy.Time + ( coinMult * (3 * player:GetTrinketMultiplier(TrinketType.TRINKET_BUTT_PENNY) ) )
			--The max cap of farts the player can store with butt penny
			if data.BP_Gassy.Time > 20 then
				data.BP_Gassy.Time = 20
			end
		end
	
		--Cursed penny code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_CURSED_PENNY) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_CURSED_PENNY)
			local rngRoll = rng:RandomInt(100)	
			--A better value coin will give a flat better chance to create an item
			local coinMult = 0
			if pickup.SubType == CoinSubType.COIN_DOUBLEPACK or pickup.SubType == CoinSubType.COIN_LUCKYPENNY or pickup.SubType == CoinSubType.COIN_NICKEL then
				coinMult = 2	
			elseif pickup.SubType == CoinSubType.COIN_DIME then
				coinMult = 4
			end
			local rngChance = coinMult + ( 4 + (2 * player:GetTrinketMultiplier(TrinketType.TRINKET_CURSED_PENNY) - 1) )
			--print("Cursed penny roll: " .. rngRoll .. "|" .. rngChance) 
			if rngRoll <= rngChance then
				--print("Keeper box used")
				player:UseActiveItem(CollectibleType.COLLECTIBLE_KEEPERS_BOX, UseFlag.USE_MIMIC)
			end
		end
	
		--Counterfeit penny code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_COUNTERFEIT_PENNY) > 1 then	
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_COUNTERFEIT_PENNY)
			local rngRoll = rng:RandomInt(100)	
			local rngChance = 5 + (15 * (player:GetTrinketMultiplier(TrinketType.TRINKET_COUNTERFEIT_PENNY) - 1) ) 
			--print("Counterfeit penny roll: " .. rngRoll .. "|" .. rngChance) 
			if rngRoll <= rngChance then
				--print("Counter penny proc")
				player:AddCoins(1)
			end			
		end		
	end
end

--On heart pickup, for apple of sodom
function TrinketStacking:onHeartPickup(pickup, ent, bool)
	if ent.Type == EntityType.ENTITY_PLAYER then
		local player = ent:ToPlayer()
		--Apple of sodom code
		if player:GetTrinketMultiplier(TrinketType.TRINKET_APPLE_OF_SODOM) > 1 then		
			--You get more chances at extra spiders if the heart is of greater value
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
			--print("Spider Rolls: " .. appleSpiderRolls)
			rng = player:GetTrinketRNG(TrinketType.TRINKET_APPLE_OF_SODOM)
			for spiderNum = 1, appleSpiderRolls do
				rngRoll = rng:RandomInt(100)
				--print("Roll: " .. rngRoll .. "|" .. "50")
				if rngRoll < 50 then 
					player:AddBlueSpider(player.Position)
				end
			end				
		end		
	end		
end

--Only for equality
function TrinketStacking:onEqualityPickup(pickup, ent, bool)
	if ent.Type == EntityType.ENTITY_PLAYER and pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
		local player = ent:ToPlayer()
		if player:GetTrinketMultiplier(TrinketType.TRINKET_EQUALITY) > 1 then
			local dropVariant = Helpers:getLowestConsumable()
			if dropVariant ~= nil then
				--Do extra drop
				local rng = player:GetTrinketRNG(TrinketType.TRINKET_EQUALITY)
				local rngRoll = rng:RandomInt(100)
				--10% chance per extra multiplier of equality
				local rngChance = math.min(35, 5 + 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_EQUALITY) - 1))
				--print("Equality Roll: " .. rngRoll .. "|" .. rngChance)
				if rngRoll <= rngChance then
					local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, dropVariant, 0, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)), nil)
				end
				
			end
		end
	
	
	end
end

--For buying shop/devil deals, Store Credit, Your Soul
function TrinketStacking:onShopPickup(pickup, ent, bool)
	if ent.Type == EntityType.ENTITY_PLAYER then
		local player = ent:ToPlayer()
		--Store Credit code
		--print("is shop item")
		if pickup:IsShopItem() and player.ItemHoldCooldown == 0 and not player:IsHoldingItem() then
			--print("IsShop True")
			--print("Price: " .. pickup.Price)
			local edgecase = false
			local buyType = shop
			--Devil Deal detected
			if pickup.Price < 0 and pickup.Price > -7 then
				buyType = "devil"
				--print("Devil deal!")
				if player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL) then
					edgecase = false
				elseif pickup.Price == PickupPrice.PRICE_THREE_SOULHEARTS then 
					if player:GetSoulHearts() <= 0 then
						edgecase = true
					end
				elseif pickup.Price == PickupPrice.PRICE_ONE_HEART or pickup.Price == PickupPrice.PRICE_TWO_HEARTS then
					if player:GetMaxHearts() <= 0 then
						edgecase = true
					end				
				elseif pickup.Price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS then
					if player:GetMaxHearts() <= 0 or player:GetSoulHearts() <= 0 then
						edgecase = true
					end							
				else	
					edgecase = true
				end
			--Shop item detected
			elseif pickup.Price == PickupPrice.PRICE_FREE or pickup.Price > 0 then
				buyType = "shop"
				--Hearts Edgecase
				if pickup.Variant == PickupVariant.PICKUP_HEART then
					if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_ROTTEN or pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
						if not player:CanPickRedHearts() then
							--print("Heart edgecase")
							edgecase = true
						end
						
					elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_BLACK or pickup.SubType == HeartSubType.HEART_BLENDED or pickup.SubType == HeartSubType.HEART_BONE then
						if not player:CanPickSoulHearts() then
							--print("Heart edgecase")
							edgecase = true
						end			
					
					end
				--Battery Edgecase
				elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
					if not player:NeedsCharge(0) and not player:NeedsCharge(1) and not player:NeedsCharge(2) and not player:NeedsCharge(3) then
						--print("Battery edgecase")
						edgecase = true
					end
				elseif pickup.Variant == PickupVariant.PICKUP_BOMB or pickup.Variant == PickupVariant.PICKUP_KEY  or pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or PickupVariant.PICKUP_PILL or PickupVariant.PICKUP_GRAB_BAG or PickupVariant.PICKUP_TAROTCARD or PickupVariant.PICKUP_TRINKET then
					edgecase = false
				
				--Everything else is an edgecase, just in case I mess up
				else
					edgecase = true
				end	
			end
			--Player has purchased an item
			if not edgecase then
				--Purchased free item with store credit
				if buyType == "shop" and pickup.Price == -1000 and player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) > 1 then
					TrinketStacking:onStoreCreditPurchase(player, pickup)
				end
				--Purchased Devil deal
				if buyType == "devil"  then
					if pickup.Price == -6 and player:GetTrinketMultiplier(TrinketType.TRINKET_YOUR_SOUL) > 1 then
						TrinketStacking:onYourSoulPurchase(player, pickup)
					elseif player:GetTrinketMultiplier(TrinketType.TRINKET_JUDAS_TONGUE) > 1 then
						TrinketStacking:onJudasTonguePurchase(player, pickup)
					end				

				end
			end				
		end
	end
end

--For Store credit
function TrinketStacking:onStoreCreditPurchase(player, pickup)
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_STORE_CREDIT)
	local rngRoll = rng:RandomInt(100)
	local rngChance = math.min(35, 5 + 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) - 1))
	--print("Store Credit Roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_STORE_CREDIT, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)), nil)
	--RNG Failed
	else
		--print("Rng failed, spawning coins")
		local minCoins = (player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT) - 1) * 2 + 2
		rngRoll = minCoins + rng:RandomInt(5)	
		--print("Min coins: " .. minCoins .. " Roll: " .. rngRoll)
		for i = 1, rngRoll do
			local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, player.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)), nil)
		end
	end	

end
--For Your Soul
function TrinketStacking:onYourSoulPurchase(player, pickup)
	--print("Your soul used!")
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_YOUR_SOUL)
	local rngRoll = rng:RandomInt(100)
	local rngChance = math.min(25, 10 * (player:GetTrinketMultiplier(TrinketType.TRINKET_YOUR_SOUL) - 1))
	--print("Your soul Roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_YOUR_SOUL, player.Position, Vector(-2 + rng:RandomInt(4),-2 + rng:RandomInt(4)), nil)
	--RNG Failed
	else
		--print("Rng failed, spawning sacks")
		for i = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_YOUR_SOUL) - 1) do
			local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK, player.Position, Vector(-2 + rng:RandomInt(4),-2 + rng:RandomInt(4)), nil)
		end
	end	

end

--For Judas' Tongue
function TrinketStacking:onJudasTonguePurchase(player, pickup)
	--print("Judas tongue used!")
	local rng = player:GetTrinketRNG(TrinketType.TRINKET_JUDAS_TONGUE)
	local rngRoll = rng:RandomInt(100)
	local rngChance = math.min(75, 30 * (player:GetTrinketMultiplier(TrinketType.TRINKET_JUDAS_TONGUE) - 1))
	--print("Judas tongue Roll: " .. rngRoll .. "|" .. rngChance)
	if rngRoll <= rngChance then
		local loot = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, player.Position, Vector(-2 + rng:RandomInt(4),-2 + rng:RandomInt(4)), nil)
	end	

end

local function TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<x) or BitSet128(1<<x,0)
end

--Familiar tear effects, baby-bender and extension cord
function TrinketStacking:onTearUpdate(tear)	
	if tear:GetData().FAM_TRINKET_CHECK == nil and tear.SpawnerType == EntityType.ENTITY_FAMILIAR then
		tear:GetData().FAM_TRINKET_CHECK = 1
		local familiar = tear.SpawnerEntity:ToFamiliar()
		local player = familiar.SpawnerEntity
		player = player:ToPlayer()
		--Extension Cord code
		if player ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_EXTENSION_CORD)
			local rngRoll = rng:RandomInt(100)
			if rngRoll <= 95 then
				tear:AddTearFlags(TearFlags.TEAR_LASER)	
			end
			if player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) > 2 then
				rngRoll = rng:RandomInt(100)
				if rngRoll <= 25 * (player:GetTrinketMultiplier(TrinketType.TRINKET_EXTENSION_CORD) - 2) then
					tear:AddTearFlags(TearFlags.TEAR_JACOBS)	
				end				
			end

		end
		--Baby Bender
		if player ~= nil and player:GetTrinketMultiplier(TrinketType.TRINKET_BABY_BENDER) > 1 then
			tear:AddTearFlags(TEARFLAG(71))
			tear.Height = tear.Height * (1 + (player:GetTrinketMultiplier(TrinketType.TRINKET_BABY_BENDER) - 1) * 0.5)
		
		end
	end
end


--On Red Chest open, for the Left Hand
function TrinketStacking:onRedChestOpen(pickup, ent, bool)
	if ent.Type == EntityType.ENTITY_PLAYER and pickup:GetData().LHAND_CHECK == nil then
		pickup:GetData().LHAND_CHECK = 1
		local player = ent:ToPlayer()
		--Left Hand
		if player:GetTrinketMultiplier(TrinketType.TRINKET_LEFT_HAND) > 1 then
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_LEFT_HAND)
			local rngRoll = rng:RandomInt(100)
			local rngChance = (5 + 15 * (player:GetTrinketMultiplier(TrinketType.TRINKET_LEFT_HAND) - 1) )
			--print("Roll: " .. rngRoll .. "|" .. rngChance)	
			if rngRoll <= rngChance then 
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, pickup.Position, Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10) ), player)	
			end		
		end	
	end
end


--On collectible spawned, for strange key
GameState.PANDORAS_BOX_CHECKED = {}
local questItemIDs = {
	550, --Broken Shovel
	552, --Mom's Shovel
	238, --Key P1
	239, --Key P2
	328, --Negative
	327, --Polaroid
	551, --Broken Shovel
	668, --Dads note
	633, --Dogma
	626, --Knife p1
	627, --Knife p2

}
function TrinketStacking:onStrangeKeyCheck(pickup)
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		local canReplace = true
		local checkedSize = 0
		if player:GetTrinketMultiplier(TrinketType.TRINKET_STRANGE_KEY) > 1 then
			--Check to see if item has already been checked
			for _, item in pairs(GameState.PANDORAS_BOX_CHECKED) do
				checkedSize = checkedSize + 1
				if item == pickup.SubType then
					--print("Table: " .. item .. " pickup: " .. pickup.SubType)
					--print("Already checked")
					canReplace = false
				end
			end
			--Check for quest items
			for _, questItem in pairs(questItemIDs) do
				if questItem == pickup.SubType then
					--print("isQuest")
					canReplace = false
				end
			end
			--Try to replace the item
			if canReplace then
				GameState.PANDORAS_BOX_CHECKED[checkedSize + 1] = pickup.SubType
				local rng = player:GetTrinketRNG(TrinketType.TRINKET_STRANGE_KEY)
				local rngRoll = rng:RandomInt(100)
				local rngChance = 5 + 5 * (player:GetTrinketMultiplier(TrinketType.TRINKET_STRANGE_KEY) - 1)
				--print("Strange key roll: " .. rngRoll .. "|" .. rngChance)
				if rngRoll <= rngChance then
					--print("Transform into pandoras box!")
					pickup:Morph(5, 100, CollectibleType.COLLECTIBLE_BLUE_BOX, true, true, false)
				end
			end		
		end		
	end
end


function TrinketStacking.onTeleporter(item, tpRng, user, flags, slot, data)
	--print("TELEPORTER USED")
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		if player:GetTrinketMultiplier(TrinketType.TRINKET_BROKEN_REMOTE) > 1 then
			--print("Detect broken remote")
			local rng = player:GetTrinketRNG(TrinketType.TRINKET_BROKEN_REMOTE)
			local rngRoll = rng:RandomInt(100)
			local rngChance = 10 + 25 * player:GetTrinketMultiplier(TrinketType.TRINKET_BROKEN_REMOTE)
			--print("B remote roll: " .. rngRoll .. "|" .. rngChance)
			if rngRoll <= rngChance then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT_2)
				--print("B remote payout")
			end			
			return false			
		end		
	end

end

TrinketStacking:AddCallback(ModCallbacks.MC_USE_ITEM, TrinketStacking.onTeleporter, CollectibleType.COLLECTIBLE_TELEPORT)

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

--On pickup collections
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onCoinPickup, PickupVariant.PICKUP_COIN)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onHeartPickup, PickupVariant.PICKUP_HEART)

--For equality only
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onEqualityPickup, PickupVariant.PICKUP_COIN)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onEqualityPickup, PickupVariant.PICKUP_KEY)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onEqualityPickup, PickupVariant.PICKUP_BOMB)

--For Store Credit Only
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_KEY)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_BOMB)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_GRAB_BAG)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_PILL)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_LIL_BATTERY)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_HEART)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_TAROTCARD)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_COLLECTIBLE)
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onShopPickup, PickupVariant.PICKUP_TRINKET)

--For Left Hand
TrinketStacking:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TrinketStacking.onRedChestOpen, PickupVariant.PICKUP_REDCHEST)

--For extenstion cord
TrinketStacking:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, TrinketStacking.onTearUpdate)

--For Strange Key
TrinketStacking:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, TrinketStacking.onStrangeKeyCheck, PickupVariant.PICKUP_COLLECTIBLE)
---


--EID Support
local EID_Info = require("eid_support.lua")








