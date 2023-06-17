

-- Inclusions
local cacheChecking = require("cacheChecking")
--Trinkets
local trinkets = require("trinkets/trinketsDatabase")

local game = Game()

local callbacks = {}

function callbacks:onUpdate()
	--print("On update")
end

function callbacks:onRender()
	--print("On render")
end


function callbacks:postNPCDeath(npc)
	--print("On npc death: " .. npc.Type)
	
	if npc.Type == EntityType.ENTITY_GABRIEL or npc.Type == EntityType.ENTITY_URIEL  then
		trinkets.filigreeFeather:trigger(npc)
	end 
end

function callbacks:postNewLevel()
	---[[
	--print("On new level")
	local level = game:GetLevel()
	local stage = level:GetStage()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	local roomConfigR = roomDesc.Data
	local stageID = roomConfigR.StageID

	if stage == LevelStage.STAGE6 then --Dark room/Chest stage	
		trinkets.holyWickedCrown:trigger(stageID)
	end
	
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		trinkets.stemCell:trigger(player)

	end	
	--]]
end

function callbacks:evaluateCache(entityPlayer, cacheFlag)
	--print("On cache eval")
end

function callbacks:preSpawnCleanAward(rng, position)
	--print("On room clear")
	--print("Pos x" .. position.X .. " Y: " .. position.Y)
	--Iterate for all players
	for i = 1, game:GetNumPlayers() do
		local player = game:GetPlayer(i)
		
		trinkets.aaaBattery:trigger(rng, position, player)
		trinkets.woodenCross:trigger(rng, position, player)
		trinkets.temporaryTattoo:trigger(rng, position, player)
		trinkets.blueKey:trigger(rng, position, player)
		trinkets.bloodyCrownSD:trigger(position, player)
	end
	
end

function callbacks:postNewRoom()
	---[[
	local level = game:GetLevel()
	local room = level:GetCurrentRoom()
	local roomDesc = level:GetCurrentRoomDesc()
	
	--First visit of a room
	if(room:IsFirstVisit()) then
		-- Hostile room entered
		if not roomDesc.Clear  then
			trinkets.locusts:trigger()
		end
		--Entered secret room
		if room:GetType() == RoomType.ROOM_SECRET then
			trinkets.fragmentedCard:trigger()
		end
		--Enter shop
		if room:GetType() == RoomType.ROOM_SHOP then
			trinkets.storeKey:trigger(room)
		end		
		
		
	end
		--]]
end

function callbacks:playerTakeDmg(player, dmg, flags, dmgSource, cdFrames)
	--print("Player take dmg")
	local retVal = nil
	player = player:ToPlayer()
	
	trinkets.crackedDice:trigger(player)
	
	if trinkets.safetyScissors:trigger(player, flags) == false then
		retVal = false
	end
	
	if trinkets.crowHeart:trigger(player, flags) == false then
		retVal = false
	end	
	
	trinkets.bagLunch:trigger(player, flags)
	trinkets.missingPoster:trigger(player, flags, dmgSource)
	trinkets.wishBone:trigger(player, flags)
	
	return retVal
end

function callbacks:pre_pickup_collision(pickup, player, low)
	--Only trigger for players
	if player.Type ~= EntityType.ENTITY_PLAYER then
		return nil
	end
	player = player:ToPlayer()
	
	if pickup.SubType == ChestSubType.CHEST_CLOSED then
			--Red chest
			if pickup.Variant == PickupVariant.PICKUP_REDCHEST then
				trinkets.leftHand:trigger(pickup, player)
			end
	--Coins
	elseif pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
		trinkets.counterfeitPenny:trigger(pickup, player)
		trinkets.rottenPenny:trigger(pickup, player)
		trinkets.buttPenny:pickup(pickup, player)
	--Items
	elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		trinkets.storeCredit:setTarget(pickup, player)
	
	end
	
	
end

function callbacks:on_use_item(item, rng, user, flags, slot, data)
	if item == CollectibleType.COLLECTIBLE_TELEPORT then
		trinkets.brokenRemote:trigger(user, flags)
	end
	
end

function callbacks:post_npc_init(npc)
	if npc.Type == EntityType.ENTITY_PLAYER then
		local player = npc:ToPlayer()
	end

end


function callbacks:post_player_update(player)
	local currFrame = game:GetFrameCount()
	--Occurs every second
	if currFrame % 30 == 0 then
		trinkets.buttPenny:gasTrigger(player)
		cacheChecking:check(player, trinkets.cacheTrinkets)
	end
	
	-- 1050 = 30 * 35 evey 35 seconds
	if currFrame % 1050 == 0 then
		trinkets.momsToenail:trigger(player)
	end

	trinkets.storeCredit:trigger(player)
end

function callbacks:post_tear_update(tear)
	--print("tear fired")
	--Initialize tears
	if tear:GetData().TSPLUS_NEWTEAR == nil then
		if tear.SpawnerType ~= nil and tear.SpawnerType == EntityType.ENTITY_FAMILIAR and tear.SpawnerEntity ~= nil then
			local familiar = tear.SpawnerEntity
			--print(familiar.SpawnerType)
			if familiar.SpawnerType ~= EntityType.ENTITY_PLAYER then
				return nil
			end		
			--print("familiar shot!")
			local player = familiar.SpawnerEntity
			player = player:ToPlayer()

			trinkets.extensionCord:trigger(player, tear)
		end
		tear:GetData().TSPLUS_NEWTEAR = false
	end
end



function callbacks:evaluate_cache(player, flag)
	--Damage flags
	if flag == CacheFlag.CACHE_DAMAGE then
		trinkets.pulseWorm:cacheTrigger(player,flag)
		trinkets.flatWorm:cacheTrigger(player,flag)
	end
	--Luck flags
	if flag == CacheFlag.CACHE_LUCK then
		trinkets.pinkyEye:cacheTrigger(player, flag)
	end
	--speed
	if flag == CacheFlag.CACHE_SPEED then
		trinkets.callus:cacheTrigger(player, flag)
	end
	--familiars
	if flag == CacheFlag.CACHE_FAMILIARS then
		trinkets.isaacsHead:cacheTrigger(player, flag)
		trinkets.bbSoul:cacheTrigger(player, flag)
	end	
	
	--Multiple cache triggers
	trinkets.vibrantBulb:cacheTrigger(player, flag)
	trinkets.dimBulb:cacheTrigger(player, flag)
end


return callbacks