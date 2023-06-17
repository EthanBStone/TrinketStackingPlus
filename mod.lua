local mod = RegisterMod("TrinketStackingRewriteMod", 1)
print("mod loaded")

local callbacks = require("callbacks.lua")

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, callbacks.onUpdate)
mod:AddCallback(ModCallbacks.MC_POST_RENDER, callbacks.onRender)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, callbacks.postNPCDeath)
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, callbacks.postNewLevel)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, callbacks.evaluateCache)
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, callbacks.preSpawnCleanAward)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, callbacks.postNewRoom)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, callbacks.playerTakeDmg, EntityType.ENTITY_PLAYER)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, callbacks.pre_pickup_collision)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, callbacks.on_use_item)
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, callbacks.post_npc_init)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, callbacks.post_player_update)
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, callbacks.post_tear_update)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, callbacks.evaluate_cache)
return mod