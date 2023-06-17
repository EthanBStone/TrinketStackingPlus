--print("initialize butt Penny")

local game = Game()

local momsToenail = {}
momsToenail.lastStompFrame = 0
momsToenail.lastStompPlayer = 1

function momsToenail:trigger(player)
	
	if player:GetTrinketMultiplier(TrinketType.TRINKET_MOMS_TOENAIL) < 2 then
		return false
	end
	
	if game:GetFrameCount() == momsToenail.lastStompFrame and momsToenail.lastStompPlayer == GetPtrHash(player) then
		return false
	end
	momsToenail.lastStompPlayer = GetPtrHash(player)
	momsToenail.lastStompFrame = game:GetFrameCount()
	
	--print("toenail trigger")
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
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, ent.Position, Vector(0,0), nil)				
		end
	end		
end

return momsToenail