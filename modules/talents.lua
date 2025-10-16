--[[ talents ]]--
-- Read-only talent information queries.
-- Caches talent ranks and provides modifier calculations.
--
-- Key functions:
--   UpdateAllTalents() - Refresh talent cache
--   GetRuthlessnessChance() - Get Ruthlessness proc chance
--   GetImprovedEviscerateMod() - Get Eviscerate damage modifier
--   HasAdrenalineRush() - Check if Adrenaline Rush is active

if not RoRota then return end
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
	
	-- Invalidate rotation cache so it rebuilds with new talent values
	if self.InvalidateRotationCache then
		self:InvalidateRotationCache()
	end
end

function RoRota:GetImprovedEviscerateMod()
    local _, _, _, _, rank = GetTalentInfo(1, 1)
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
    local _, _, _, _, talentRank = GetTalentInfo(1, 10)
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
    local _, _, _, _, rank = GetTalentInfo(2, 17)
    if rank == 1 then return 1.03
    elseif rank == 2 then return 1.06
    elseif rank == 3 then return 1.10
    end
    return 1.0
end

function RoRota:GetSerratedBladesMod()
    local _, _, _, _, rank = GetTalentInfo(3, 6)
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
    if not self.TalentCache then return 0 end
    -- Ruthlessness gives 20% chance per rank to gain 1 CP on finisher use
    -- This is typically found in Assassination tree
    for tab = 1, 3 do
        local numTalents = GetNumTalents(tab)
        for i = 1, numTalents do
            local name, _, _, _, rank = GetTalentInfo(tab, i)
            if name and string.find(name, "Ruthlessness") then
                return (rank or 0) * 0.20
            end
        end
    end
    return 0
end

-- mark module as loaded
RoRota.talents = true
