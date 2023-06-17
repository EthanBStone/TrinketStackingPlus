--print("initialize bbSoul")

local game = Game()

local bbSoul = {}

--For cache updates
bbSoul.ID = TrinketType.TRINKET_ISAACS_HEAD
bbSoul.caches = CacheFlag.CACHE_FAMILIARS
--

function bbSoul:cacheTrigger(player, flag)
	--print("bbSoul check")
	if player:GetTrinketMultiplier(TrinketType.TRINKET_SOUL) < 2 then
		return false
	end
	
	--print("bbSoul detected")
	--Remove all extra spawns of the familiars
	for i, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_BABY_SOUL, 0, 0)) do
		if ent:GetData().StackedSpawn == 1 and ent.SpawnerEntity ~= nil and ent.SpawnerEntity == player then
			ent:Remove()
		end
	end
	--Spawn extra familiars
	for j = 1, (player:GetTrinketMultiplier(TrinketType.TRINKET_SOUL) - 1) do
		local rng = player:GetTrinketRNG(TrinketType.TRINKET_SOUL)
		local rngRoll = rng:RandomInt(100)			
		local spawnedFamiliar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_BABY_SOUL, 0, player.Position + Vector(-5 + rng:RandomInt(10),-5 + rng:RandomInt(10)) , Vector(-20 + rng:RandomInt(40),-20 + rng:RandomInt(40)), player )
		spawnedFamiliar:GetData().StackedSpawn = 1				
	end	
end

return bbSoul