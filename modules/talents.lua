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
	vigor = 0,
	tasteForBlood = 0,
	bladeRush = 0,
	dirtyDeeds = 0,
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
				elseif string.find(name, "Dirty Deeds") then
					self.TalentCache.dirtyDeeds = rank or 0
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
    if self.TalentCache and self.TalentCache.improvedEviscerate then
        local rank = self.TalentCache.improvedEviscerate
        if rank == 1 then return 1.05
        elseif rank == 2 then return 1.10
        elseif rank == 3 then return 1.15
        end
    end
    return 1.0
end

function RoRota:GetRelentlessStrikesMod()
    if self.BuffCache and self.BuffCache.player then
        local buff = self.BuffCache.player["Relentless Strikes"]
        if buff and buff[2] then
            return 1.0 + buff[2] * 0.05
        end
    end
    return 1.0
end

function RoRota:GetTasteForBloodMod()
    if not self.TalentCache or self.TalentCache.tasteForBlood == 0 then return 1.0 end
    local dmgPerCP = self.TalentCache.tasteForBlood * 0.01
    if self.BuffCache and self.BuffCache.player then
        local buff = self.BuffCache.player["Taste for Blood"]
        if buff and buff[2] then
            return 1.0 + buff[2] * dmgPerCP
        end
    end
    return 1.0
end

function RoRota:GetAggressionMod()
    if self.TalentCache and self.TalentCache.aggression then
        local rank = self.TalentCache.aggression
        if rank == 1 then return 1.03
        elseif rank == 2 then return 1.06
        elseif rank == 3 then return 1.10
        end
    end
    return 1.0
end

function RoRota:GetSerratedBladesMod()
    if self.TalentCache and self.TalentCache.serratedBlades then
        local rank = self.TalentCache.serratedBlades
        if rank == 1 then return 1.10
        elseif rank == 2 then return 1.20
        elseif rank == 3 then return 1.30
        end
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

local talentFrame = CreateFrame("Frame")
talentFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
talentFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
talentFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
talentFrame:SetScript("OnEvent", function()
    if RoRota.UpdateAllTalents then
        RoRota:UpdateAllTalents()
    end
end)

RoRota.talents = true
