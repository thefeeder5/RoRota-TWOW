--[[ combopoints ]]--
-- Combo point generation and talent calculations for Turtle WoW.
-- Handles base CP, talent bonuses, and strategic CP planning.

if RoRota.combopoints then return end

-- Talent cache
RoRota.CPTalents = {
	ruthlessness = 0,
	relentlessStrikes = 0,
	sealFate = 0,
	improvedBackstab = 0,
	setup = 0,
	improvedAmbush = 0,
	initiative = 0,
	markForDeath = false,
	critChance = 0,
	lastUpdate = 0,
}

function RoRota:GetAbilityCP(ability)
	return RoRotaConstants.CP_GENERATION[ability] or 0
end

function RoRota:IsBuilder(ability)
	local cp = RoRotaConstants.CP_GENERATION[ability]
	return cp and cp > 0
end

function RoRota:IsFinisher(ability)
	return RoRotaConstants.FINISHERS[ability]
end

function RoRota:UpdateCPTalents()
	local now = GetTime()
	if now - self.CPTalents.lastUpdate < 5 then return end
	
	self.CPTalents.lastUpdate = now
	
	-- Reset all
	self.CPTalents.ruthlessness = 0
	self.CPTalents.relentlessStrikes = 0
	self.CPTalents.sealFate = 0
	self.CPTalents.improvedBackstab = 0
	self.CPTalents.setup = 0
	self.CPTalents.improvedAmbush = 0
	self.CPTalents.initiative = 0
	self.CPTalents.markForDeath = false
	
	-- Scan all 3 talent trees
	for tab = 1, 3 do
		local numTalents = GetNumTalents(tab)
		for i = 1, numTalents do
			local name, _, _, _, rank = GetTalentInfo(tab, i)
			if name then
				if string.find(name, "Ruthlessness") then
					self.CPTalents.ruthlessness = rank or 0
				elseif string.find(name, "Relentless Strikes") then
					self.CPTalents.relentlessStrikes = rank or 0
				elseif string.find(name, "Seal Fate") then
					self.CPTalents.sealFate = rank or 0
				elseif string.find(name, "Improved Backstab") then
					self.CPTalents.improvedBackstab = rank or 0
				elseif string.find(name, "Setup") then
					self.CPTalents.setup = rank or 0
				elseif string.find(name, "Improved Ambush") then
					self.CPTalents.improvedAmbush = rank or 0
				elseif string.find(name, "Initiative") then
					self.CPTalents.initiative = rank or 0
				elseif string.find(name, "Mark for Death") then
					self.CPTalents.markForDeath = (rank or 0) > 0
				end
			end
		end
	end
	
	-- Crit chance (scan spellbook tooltips)
	if not RoRotaCritTooltip then
		CreateFrame("GameTooltip", "RoRotaCritTooltip", nil, "GameTooltipTemplate")
		RoRotaCritTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	end
	
	local critChance = 0
	for tab = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for spell = 1, numSpells do
			local currentPage = math.ceil(spell / SPELLS_PER_PAGE)
			local spellID = spell + offset + (SPELLS_PER_PAGE * (currentPage - 1))
			RoRotaCritTooltip:ClearLines()
			RoRotaCritTooltip:SetSpell(spellID, BOOKTYPE_SPELL)
			for line = 1, RoRotaCritTooltip:NumLines() do
				local left = getglobal("RoRotaCritTooltipTextLeft"..line)
				if left then
					local text = left:GetText()
					if text then
						local value = string.match(text, "([%d%.]+)%% chance to crit")
						if value then
							critChance = critChance + tonumber(value)
							break
						end
					end
				end
			end
		end
	end
	
	-- Fallback: calculate from agility if parsing failed
	if critChance == 0 then
		local _, agility = UnitStat("player", 2)
		critChance = agility / 29
	end
	
	self.CPTalents.critChance = critChance
end

function RoRota:CalculateExpectedCP(ability, currentCP)
	local baseCP = self:GetAbilityCP(ability)
	if baseCP == 0 then return currentCP end
	
	local expectedCP = currentCP + baseCP
	local talents = self.CPTalents
	
	-- Seal Fate (crit = +1 CP)
	if talents.sealFate > 0 then
		local sealFateChance = talents.sealFate * 0.20
		local critChance = talents.critChance / 100
		expectedCP = expectedCP + (sealFateChance * critChance)
	end
	
	-- Improved Backstab (Backstab only)
	if ability == "Backstab" and talents.improvedBackstab > 0 then
		local backstabChance = talents.improvedBackstab * 0.15
		expectedCP = expectedCP + backstabChance
	end
	
	-- Initiative (openers only)
	if (ability == "Ambush" or ability == "Garrote" or ability == "Cheap Shot") and talents.initiative > 0 then
		local initiativeChance = talents.initiative * 0.33
		expectedCP = expectedCP + initiativeChance
	end
	
	return math.min(expectedCP, 5)
end

function RoRota:GetRuthlessnessChance()
	local rank = self.CPTalents.ruthlessness
	if rank == 1 then return 0.33
	elseif rank == 2 then return 0.66
	elseif rank == 3 then return 1.00
	end
	return 0
end

function RoRota:GetRelentlessStrikesChance(cp)
	if self.CPTalents.relentlessStrikes == 0 then return 0 end
	return cp * 0.20
end

function RoRota:ShouldUseFinisherEarly(currentCP)
	if currentCP ~= 4 then return false end
	if not self.CPTalents then return false end
	
	local talents = self.CPTalents
	
	-- At 4 CP with Seal Fate: check overflow risk
	if currentCP == 4 and talents.sealFate >= 4 then
		local critChance = talents.critChance / 100
		local sealFateChance = talents.sealFate * 0.20
		local overflowRisk = critChance * sealFateChance
		
		-- If >30% chance to waste CP, use finisher now
		if overflowRisk > 0.30 then
			return true
		end
	end
	
	return false
end

RoRota.combopoints = true
