--[[ consumables ]]--
-- Auto-use health potions and other consumables

if not RoRota then return end

function RoRota:FindHealthPotion()
	for _, potionName in ipairs(RoRotaConstants.HEALTH_POTIONS) do
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local itemLink = GetContainerItemLink(bag, slot)
				if itemLink then
					local _, _, itemName = string.find(itemLink, "%[(.+)%]")
					if itemName == potionName then
						return bag, slot, potionName
					end
				end
			end
		end
	end
	return nil, nil, nil
end

function RoRota:UseHealthPotion()
	local profile = self.db and self.db.profile
	if not profile or not profile.defensive then return false end
	
	if not profile.defensive.useHealthPotion then return false end
	
	local hpPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100
	local threshold = profile.defensive.healthPotionHP or 30
	
	if hpPercent > threshold then return false end
	
	local bag, slot, potionName = self:FindHealthPotion()
	if bag and slot then
		UseContainerItem(bag, slot)
		return true
	end
	
	return false
end
