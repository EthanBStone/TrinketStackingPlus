--print("initialize isaac head")

local game = Game()

local isaacsHead = {}

--For cache updates
isaacsHead.ID = TrinketType.TRINKET_ISAACS_HEAD
isaacsHead.caches = CacheFlag.CACHE_FAMILIARS
--

function isaacsHead:cacheTrigger(player, flag)
	--print("isaac head check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_ISAACS_HEAD) < 2 then
		return false
	end
	
	--print("isaacs head detected")
	--Remove all extra spawns of the familiars
	for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ISAACS_HEAD, 0, 0)) do
		if ent:GetData().StackedSpawn == 1 and ent.SpawnerEntity ~= nil and ent.SpawnerEntity == player then
			ent:Remove()
		end
	end
	--Spawn extra familiars
	for j = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_ISAACS_HEAD) - 1) do
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_ISAACS_HEAD)
		local rngRoll = rng:RandomInt(100)			
		local spawnedFamiliar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ISAACS_HEAD, 0, player.Position + Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)) , Vector(-20 + rng:RandomInt(40),-20 + rng:RandomInt(40)), player )
		spawnedFamiliar:GetData().StackedSpawn = 1				
	end	
end

return isaacsHead