--[[ abilities ]]--
-- Read-only ability information queries.
-- Handles spell availability, energy costs, cooldowns, and spell ranks.
--
-- Key functions:
--   HasSpell(name) - Check if spell is learned
--   GetEnergyCost(name) - Get energy cost with talents
--   IsOnCooldown(name) - Check if ability is on cooldown
--   GetCooldownRemaining(name) - Get cooldown time remaining
--   IsFinisher(name) - Check if ability is a finisher
--   IsBuilder(name) - Check if ability is a builder

if not RoRota then return end
if RoRota.abilities then return end

function RoRota:HasSpell(spellName)
    local i = 1
    while true do
        local spell = GetSpellName(i, BOOKTYPE_SPELL)
        if not spell then break end
        if spell == spellName then return true end
        i = i + 1
    end
    return false
end

function RoRota:GetEnergyCost(spellName)
	local baseCost = RoRotaConstants.ENERGY_COSTS[spellName] or 0
	-- Improved Ghostly Strike talent (Subtlety 3,8)
	if spellName == "Ghostly Strike" then
		local _, _, _, _, rank = GetTalentInfo(3, 8)
		if rank == 1 then baseCost = baseCost - 3
		elseif rank == 2 then baseCost = baseCost - 6
		elseif rank == 3 then baseCost = baseCost - 10
		end
	-- Improved Hemorrhage talent (Subtlety 3,17)
	elseif spellName == "Hemorrhage" then
		local _, _, _, _, rank = GetTalentInfo(3, 17)
		if rank == 1 then baseCost = baseCost - 2
		elseif rank == 2 then baseCost = baseCost - 5
		end
	-- Dirty Deeds talent (Subtlety 3,14): -10/-20 energy for Cheap Shot and Garrote
	elseif spellName == "Cheap Shot" or spellName == "Garrote" then
		local _, _, _, _, rank = GetTalentInfo(3, 14)
		if rank == 1 then baseCost = baseCost - 10
		elseif rank == 2 then baseCost = baseCost - 20
		end
	end
	return baseCost
end

function RoRota:HasEnoughEnergy(spellName)
	return UnitMana("player") >= self:GetEnergyCost(spellName)
end

function RoRota:GetSpellID(spellName)
	local i = 1
	while true do
		local name = GetSpellName(i, BOOKTYPE_SPELL)
		if not name then break end
		if name == spellName then return i end
		i = i + 1
	end
	return nil
end

function RoRota:IsOnCooldown(spellName)
	local spellID = self:GetSpellID(spellName)
	if not spellID then return false end
	
	local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
	if start and start > 0 and duration and duration > 1.5 then
		return true
	end
	return false
end

function RoRota:GetCooldownRemaining(spellName)
	local spellID = self:GetSpellID(spellName)
	if not spellID then return 0 end
	
	local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
	if start and start > 0 and duration and duration > 1.5 then
		local remaining = duration - (GetTime() - start)
		return math.max(0, remaining)
	end
	return 0
end

function RoRota:GetSpellRank(spellName)
    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then
            if rank and string.find(rank, "Rank ") then
                local r = tonumber(string.sub(rank, 6))
                if r then return r end
            end
        end
        i = i + 1
    end
    return nil
end

function RoRota:IsFinisher(abilityName)
	local finishers = {"Eviscerate", "Slice and Dice", "Rupture", "Envenom", "Expose Armor", "Kidney Shot"}
	for _, finisher in ipairs(finishers) do
		if abilityName == finisher then return true end
	end
	return false
end

function RoRota:IsBuilder(abilityName)
	local builders = {"Sinister Strike", "Backstab", "Hemorrhage", "Noxious Assault", "Ghostly Strike", "Ambush", "Garrote", "Cheap Shot"}
	for _, builder in ipairs(builders) do
		if abilityName == builder then return true end
	end
	return false
end

function RoRota:GetAbilityCP(abilityName)
	local baseCP = 1
	
	if abilityName == "Cheap Shot" then
		baseCP = 2
	end
	
	-- Initiative talent (Subtlety 3,7): 33%/66%/100% chance for +1 CP
	if abilityName == "Ambush" or abilityName == "Garrote" or abilityName == "Cheap Shot" then
		local _, _, _, _, rank = GetTalentInfo(3, 7)
		if rank == 3 then
			baseCP = baseCP + 1
		end
	end
	
	return baseCP
end

RoRota.abilities = true
