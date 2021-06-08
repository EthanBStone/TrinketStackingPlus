--EID Descriptions
	
local game = Game()
	
if EID then
	local trinketInfo = {
		--Locust of War
		["113"] = {Name = "Locust of War", Desc = "Adds a chance to spawn extra locusts"},
		--Locust of Pestilence
		["114"] = {Name = "Locust of Pestilence", Desc = "Adds a chance to spawn extra locusts"},
		--Locust of Famine
		["115"] = {Name = "Locust of Famine", Desc = "Adds a chance to spawn extra locusts"},
		--Locust of Death
		["116"] = {Name = "Locust of Death", Desc = "Adds a chance to spawn extra locusts"},
		--Locust of Conquest
		["117"] = {Name = "Locust of Conquest", Desc = "Adds a chance to spawn extra locusts"},
		--Filigree Feather
		["123"] = {Name = "Filigree Feather", Desc = "Angel statue bosses also drop soul hearts"},
		--Wicked Crown
		["161"] = {Name = "Wicked Crown", Desc = "Extra chests spawn at the start of the Dark Room floor"},
		--Holy Crown
		["155"] = {Name = "Holy Crown", Desc = "Extra chests spawn at the start of The Chest floor"},
		--Bloody Crown
		["111"] = {Name = "Bloody Crown", Desc = "Mom's Heart drops a boss item when killed"},
		--Silver Dollar
		["110"] = {Name = "Silver Dollar", Desc = "Mom's Heart drops a buyable shop item when killed"},	
		--Wooden Cross
		["121"] = {Name = "Wooden Cross", Desc = "Chance to replenish shield on room clear"},	
		--???'s Soul
		["57"] = {Name = "???'s Soul", Desc = "Extra copy of the familiar"},
		--Isaac's Head
		["54"] = {Name = "Isaac's Head", Desc = "Extra copy of the familiar"},
		--Vibrant Bulb
		["100"] = {Name = "Vibrant Bulb", Desc = "Extra stat boosts when fully charged"},		
		--Dim Bulb
		["101"] = {Name = "Dim Bulb", Desc = "Extra stat boosts when partially charged and NOT fully charged"},
		--Apple of Sodom
		["140"] = {Name = "Apple of Sodom", Desc = "Chance to spawn extra spiders on heart pickup"},
		--Fish Tail
		["94"] = {Name = "Fish Tail", Desc = "Chance to generate extra flies/spiders"},
		--AAA Battery
		["3"] = {Name = "AAA Battery", Desc = "Chance to spawn a micro battery on room clear"},			
		--Fragmented Card
		["102"] = {Name = "Fragmented Card", Desc = "Chance to spawn extra sacks when entering a secret room"},
		--Stem Cell
		["119"] = {Name = "Stem Cell", Desc = "Spawn red hearts in the starting room of each floor"},
		--Myosotis
		["137"] = {Name = "Myosotis", Desc = "Chance to duplicate the carried over pickups"},
		--Rotten Penny
		["126"] = {Name = "Rotten Penny", Desc = "Chance to spawn extra flies on coin pickup"},
		
		--Content Update 1
		
		--Pay To Win
		["112"] = {Name = "Pay To Win", Desc = "Restock boxes appear in Blue Womb treasure rooms, and Chest/Dark Room starting room"},		
		--Store Key
		["83"] = {Name = "Store Key", Desc = "Gives a damage up for each shop you enter while holding the store key"},
		--Safety Scissors
		["63"] = {Name = "Safety Scissors", Desc = "Chance to resist explosive damage"},
		--Hairpin
		["120"] = {Name = "Hairpin", Desc = "Killing the boss room boss drops a battery"},	
		
		--Content Update 2
		
		--Equality
		["103"] = {Name = "Equality", Desc = "Picking up a consumable gives a chance to spawn the consumable type that Isaac has the least of"},	
		--Crow Heart
		["107"] = {Name = "Crow Heart", Desc = "Change to convert incoming damage into \"fake\" damage like dull razor"},	
		--Store Credit
		["13"] = {Name = "Store Credit", Desc = "Small chance to not destroy the trinket when buying from the shop. If the chance fails, drops several coins"},
		--Your Soul
		["173"] = {Name = "Your Soul", Desc = "Small chance to not destroy the trinket when taking a devil deal. If the chance fails, drops a black sack"},
		--Judas' Tongue
		["56"] = {Name = "Judas' Tongue", Desc = "Chance to spawn a black heart when taking a devil deal"},		
	
		--Mini Update
		--Extension Cord
		["125"] = {Name = "Extension Cord", Desc = "Most of your familiars' tears will be Tech Zero electrical tears, with a small chance to gain a Jacob's Ladder effect"},	
		--Baby-Bender
		["127"] = {Name = "Baby-Bender", Desc = "Familiars have more range and better homing"},

		--Worms Update
		--Pulse Worm
		["9"] = {Name = "Pulse Worm", Desc = "Damage up"},
		--Ring Worm
		["11"] = {Name = "Ring Worm", Desc = "Tears up"},
		--Ouroboros Worm
		["96"] = {Name = "Ouroboros Worm", Desc = "Tears and luck up"},
		--Rainbow Worm
		["64"] = {Name = "Rainbow Worm", Desc = "Tears up"},
		--Mom's Toenail
		["16"] = {Name = "Mom's Toenail", Desc = "More frequent stomping, and some stomps target and slow enemies"},
		--Callus
		["14"] = {Name = "Callus", Desc = "Speed up"},
		--The Left Hand 
		["61"] = {Name = "The Left Hand ", Desc = "Opening red chests has a chance to spawn black hearts"},
		--Pinky Eye
		["30"] = {Name = "Pinky Eye", Desc = "Luck up, meaning better poison chance"},
		
		--Update
		--Strange Key
		["175"] = {Name = "Strange Key", Desc = "Gives a chance to replace any non-quest item pedestal with Pandoras Box"},
		--Flat Worm
		["12"] = {Name = "Flat Worm", Desc = "Damage up"},	
	}	
	
	--Check to see if the EID description should be displayed
	local function TrinketStackingPlusCondition(descObj)
		for key, item in pairs(trinketInfo) do
			currID = tonumber(key)
			if (descObj.ObjSubType == currID or descObj.ObjSubType == currID  + 32768) and descObj.ObjType == 5 and descObj.ObjVariant == PickupVariant.PICKUP_TRINKET then
				--Gold trinket Check
				if descObj.ObjSubType == currID  + 32768  then
					return true
				end		
				--Check to see if the player has Moms Box or multiple stacks of the trinket
				for i = 1, game:GetNumPlayers() do
					player = game:GetPlayer(i)
					--Check to see if player has multiple stacks of the trinket
					if player:GetTrinketMultiplier(currID) >= 1 then
						return true
					end
					--Check to see if player has Mom's Box
					if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
						return true
					end
				end	
			end
		end
		return false
	end
	
	--Append the trinket's custom description 
	local function TrinketStackingPlusCallback(descObj)
		EID:appendToDescription(descObj, "#{{Collectible439}} Stacking+: ")
		trinketID = descObj.ObjSubType
		if descObj.ObjSubType > 32768 then
			trinketID = descObj.ObjSubType - 32768
		end
		trinketID = tostring(trinketID)
		stackingDesc = trinketInfo[trinketID].Desc
		EID:appendToDescription(descObj, stackingDesc)

		return descObj
	end
	
	EID:addDescriptionModifier("TrinketStackingPlus", TrinketStackingPlusCondition, TrinketStackingPlusCallback)	
	
end	