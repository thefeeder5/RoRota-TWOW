--[[ abilities ]]--
-- Cached ability information queries.
-- Event-driven spellbook indexing for O(1) lookups.
--
-- Key functions:
--   HasSpell(name) - Check if spell is learned (cached)
--   GetEnergyCost(name) - Get energy cost with talents
--   IsOnCooldown(name) - Check if ability is on cooldown
--   GetCooldownRemaining(name) - Get cooldown time remaining
--   IsFinisher(name) - Check if ability is a finisher
--   IsBuilder(name) - Check if ability is a builder

if not RoRota then return end
if RoRota.abilities then return end

RoRota.SpellbookCache = {
    spells = {},
    dirty = true,
}

function RoRota:BuildSpellbookIndex()
    local cache = self.SpellbookCache.spells
    for k in pairs(cache) do cache[k] = nil end
    
    local i = 1
    while true do
        local name = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        cache[name] = i
        i = i + 1
    end
    
    self.SpellbookCache.dirty = false
end

function RoRota:HasSpell(spellName)
    if self.SpellbookCache.dirty then
        self:BuildSpellbookIndex()
    end
    return self.SpellbookCache.spells[spellName] ~= nil
end

function RoRota:GetEnergyCost(spellName)
	local baseCost = RoRotaConstants.ENERGY_COSTS[spellName] or 0
	if not self.TalentCache then return baseCost end
	
	if spellName == "Ghostly Strike" then
		local rank = self.TalentCache.improvedGhostlyStrike
		if rank == 1 then baseCost = baseCost - 3
		elseif rank == 2 then baseCost = baseCost - 6
		elseif rank == 3 then baseCost = baseCost - 10
		end
	elseif spellName == "Hemorrhage" then
		local rank = self.TalentCache.improvedHemorrhage
		if rank == 1 then baseCost = baseCost - 2
		elseif rank == 2 then baseCost = baseCost - 5
		end
	elseif spellName == "Cheap Shot" or spellName == "Garrote" then
		local rank = self.TalentCache.dirtyDeeds or 0
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
	if self.SpellbookCache.dirty then
		self:BuildSpellbookIndex()
	end
	return self.SpellbookCache.spells[spellName]
end

function RoRota:IsOnCooldown(spellName, ignoreGCD)
	local spellID = self:GetSpellID(spellName)
	if not spellID then return false end
	
	local start, duration = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
	if not start or not duration then return false end
	
	-- Ignore GCD (<=1.5s) if requested
	if ignoreGCD and duration > 0 and duration <= 1.5 then
		return false
	end
	
	if start > 0 and duration > 1.5 then
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
    local spellID = self:GetSpellID(spellName)
    if not spellID then return nil end
    
    local name, rank = GetSpellName(spellID, BOOKTYPE_SPELL)
    if rank and string.find(rank, "Rank ") then
        local r = tonumber(string.sub(rank, 6))
        if r then return r end
    end
    return nil
end

function RoRota:IsFinisher(abilityName)
	local finishers = {"Eviscerate", "Slice and Dice", "Rupture", "Envenom", "Expose Armor", "Kidney Shot", "Shadow of Death", "Flourish"}
	for _, finisher in ipairs(finishers) do
		if abilityName == finisher then return true end
	end
	return false
end

function RoRota:IsBuilder(abilityName)
	local builders = {"Sinister Strike", "Backstab", "Hemorrhage", "Noxious Assault", "Ghostly Strike", "Ambush", "Garrote", "Cheap Shot", "Mark for Death", "Riposte", "Surprise Attack"}
	for _, builder in ipairs(builders) do
		if abilityName == builder then return true end
	end
	return false
end

function RoRota:GetAbilityCP(abilityName)
	local baseCP = 1
	
	if abilityName == "Cheap Shot" then
		baseCP = 2
	elseif abilityName == "Mark for Death" then
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

-- Action bar slot cache for reactive abilities
RoRota.ActionSlotCache = {}

function RoRota:FindActionSlot(spellName)
	if self.ActionSlotCache[spellName] then
		return self.ActionSlotCache[spellName]
	end
	
	for slot = 1, 120 do
		local actionText = GetActionText(slot)
		if actionText == spellName then
			self.ActionSlotCache[spellName] = slot
			return slot
		end
	end
	return nil
end

function RoRota:IsReactiveUsable(spellName)
	local slot = self:FindActionSlot(spellName)
	if not slot then return false end
	
	local isUsable = IsUsableAction(slot)
	local start, duration = GetActionCooldown(slot)
	
	-- Usable and not on cooldown (or only GCD)
	return isUsable and (start == 0 or duration == 1.5)
end

local spellFrame = CreateFrame("Frame")
spellFrame:RegisterEvent("SPELLS_CHANGED")
spellFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
spellFrame:SetScript("OnEvent", function()
    RoRota.SpellbookCache.dirty = true
end)

local actionFrame = CreateFrame("Frame")
actionFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
actionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
actionFrame:SetScript("OnEvent", function()
    for k in pairs(RoRota.ActionSlotCache) do
        RoRota.ActionSlotCache[k] = nil
    end
end)

RoRota.abilities = true
