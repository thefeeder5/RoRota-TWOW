--[[ talents ]]--
-- Talent modifier functions for damage calculations.
-- Caches all talent ranks to minimize GetTalentInfo calls.

if RoRota.talents then return end

-- Talent cache (updated on login and talent changes)
RoRota.TalentCache = {
	improvedEviscerate = 0,
	improvedBladeTactics = 0,
	relentlessStrikes = 0,
	serratedBlades = 0,
	aggression = 0,
	improvedGhostlyStrike = 0,
	improvedHemorrhage = 0,
	vigor = 0,  -- +10 max energy per rank AND 50% chance per rank for 2 energy on poison application
	tasteForBlood = 0,
	bladeRush = 0,
}

function RoRota:UpdateAllTalents()
	-- Scan all talents once
	for tab = 1, 3 do
		local numTalents = GetNumTalents(tab)
		for i = 1, numTalents do
			local name, _, _, _, rank = GetTalentInfo(tab, i)
			if name then
				if string.find(name, "Improved Eviscerate") then
					self.TalentCache.improvedEviscerate = rank or 0
				elseif string.find(name, "Improved Blade Tactics") then
					self.TalentCache.improvedBladeTactics = rank or 0
				elseif string.find(name, "Relentless Strikes") then
					self.TalentCache.relentlessStrikes = rank or 0
				elseif string.find(name, "Serrated Blades") then
					self.TalentCache.serratedBlades = rank or 0
				elseif string.find(name, "Aggression") then
					self.TalentCache.aggression = rank or 0
				elseif string.find(name, "Improved Ghostly Strike") then
					self.TalentCache.improvedGhostlyStrike = rank or 0
				elseif string.find(name, "Improved Hemorrhage") then
					self.TalentCache.improvedHemorrhage = rank or 0
				elseif string.find(name, "Vigor") then
					self.TalentCache.vigor = rank or 0
				elseif string.find(name, "Taste for Blood") then
					self.TalentCache.tasteForBlood = rank or 0
				elseif string.find(name, "Blade Rush") then
					self.TalentCache.bladeRush = rank or 0
				end
			end
		end
	end
	
	-- Also update CP talents
	if self.UpdateCPTalents then
		self.CPTalents.lastUpdate = 0
		self:UpdateCPTalents()
	end
end

function RoRota:GetImprovedEviscerateMod()
	local rank = self.TalentCache.improvedEviscerate
	if rank == 1 then return 1.05
	elseif rank == 2 then return 1.10
	elseif rank == 3 then return 1.15
	end
	return 1.0
end

function RoRota:GetRelentlessStrikesMod()
	local i = 1
	while UnitBuff("player", i) do
		local texture, stacks = UnitBuff("player", i)
		if texture and string.find(texture, "Relentless Strikes") then
			return 1.0 + (stacks or 1) * 0.05
		end
		i = i + 1
	end
	return 1.0
end

function RoRota:GetTasteForBloodMod()
	local talentRank = self.TalentCache.tasteForBlood
	if talentRank == 0 then return 1.0 end
	local dmgPerCP = talentRank * 0.01
	local i = 1
	while UnitBuff("player", i) do
		local texture, stacks = UnitBuff("player", i)
		if texture and string.find(texture, "Taste for Blood") then
			return 1.0 + (stacks or 0) * dmgPerCP
		end
		i = i + 1
	end
	return 1.0
end

function RoRota:GetAggressionMod()
	local rank = self.TalentCache.aggression
	if rank == 1 then return 1.03
	elseif rank == 2 then return 1.06
	elseif rank == 3 then return 1.10
	end
	return 1.0
end

function RoRota:GetSerratedBladesMod()
	local rank = self.TalentCache.serratedBlades
	if rank == 1 then return 1.10
	elseif rank == 2 then return 1.20
	elseif rank == 3 then return 1.30
	end
	return 1.0
end

function RoRota:HasAdrenalineRush()
	return self:HasPlayerBuff("Adrenaline Rush")
end

function RoRota:GetRuthlessnessChance()
    local _, _, _, _, rank = GetTalentInfo(1, 9)
    if rank == 1 then return 0.33
    elseif rank == 2 then return 0.66
    elseif rank == 3 then return 1.0
    end
    return 0
end

-- mark module as loaded
RoRota.talents = true
