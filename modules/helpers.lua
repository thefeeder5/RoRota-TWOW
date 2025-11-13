--[[ helpers ]]--
-- Shared utility functions.
-- General helpers that don't fit into specific modules.
--
-- Key functions:
--   UpdateRotationCache() - Cache energy costs and talent values
--   GetThreatSituation() - Get threat level
--   IsInGroupOrRaid() - Check if in group
--   IsTargetElite/Boss/Rare() - Target classification
--
-- Note: Most helpers moved to specialized modules (abilities, buffs, damage, etc.)

-- Global rotation cache (updated on login and talent changes)
RoRota.RotationCache = {
	dirty = true,
	energyCosts = {},
	maxEnergy = 100,
	ruthlessnessChance = 0,
	lastUpdate = 0
}

function RoRota:UpdateRotationCache()
	local cache = self.RotationCache
	
	-- Cache energy costs for common abilities
	for _, ability in ipairs({"Sinister Strike", "Backstab", "Hemorrhage", "Ghostly Strike", "Eviscerate", "Rupture", "Slice and Dice", "Envenom", "Expose Armor", "Kick", "Gouge", "Feint"}) do
		cache.energyCosts[ability] = self:GetEnergyCost(ability)
	end
	
	-- Cache max energy from Vigor talent
	cache.maxEnergy = 100
	if self.TalentCache and self.TalentCache.vigor and self.TalentCache.vigor > 0 then
		cache.maxEnergy = 110
	end
	
	-- Cache Ruthlessness chance
	cache.ruthlessnessChance = self:GetRuthlessnessChance()
	
	cache.dirty = false
	cache.lastUpdate = GetTime()
end

function RoRota:InvalidateRotationCache()
	self.RotationCache.dirty = true
end

function RoRota:GetThreatSituation()
    if UnitThreatSituation then
        return UnitThreatSituation("player", "target") or 0
    end
    -- Vanilla fallback: estimate threat based on target's target
    if not UnitExists("target") then return 0 end
    if not UnitExists("targettarget") then return 0 end
    if UnitIsUnit("targettarget", "player") then
        return 3  -- High threat (being targeted)
    end
    -- Check if in group and someone else has aggro
    if self:IsInGroupOrRaid() then
        return 1  -- Low threat (in group, not targeted)
    end
    return 0
end

function RoRota:GetTargetHealthPercent()
    local current = UnitHealth("target")
    local max = UnitHealthMax("target")
    if max == 0 then return 0 end
    return (current / max) * 100
end

function RoRota:GetPlayerHealthPercent()
    local current = UnitHealth("player")
    local max = UnitHealthMax("player")
    if max == 0 then return 0 end
    return (current / max) * 100
end

function RoRota:GetMaxEnergy()
	if self.RotationCache and not self.RotationCache.dirty then
		return self.RotationCache.maxEnergy
	end
	if not RoRota.TalentCache then return 100 end
	return 100 + (RoRota.TalentCache.vigor * 5)
end

function RoRota:IsInGroupOrRaid()
    return GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0
end

function RoRota:IsPlayerTargeted()
    if not UnitExists("targettarget") then return false end
    return UnitIsUnit("targettarget", "player")
end

function RoRota:NeedsPoisonApplication()
	local db = self.db and self.db.profile and self.db.profile.poisons
	if not db or not db.autoApply then return false end
	if UnitAffectingCombat("player") and not db.applyInCombat then return false end
	
	local mhPoison = db.mainHandPoison
	local ohPoison = db.offHandPoison
	
	if mhPoison and mhPoison ~= "None" and not self:HasWeaponPoison(16) then
		return true
	end
	
	if ohPoison and ohPoison ~= "None" and not self:HasWeaponPoison(17) then
		return true
	end
	
	return false
end

-- Target classification helpers
function RoRota:GetTargetClassification()
	if not UnitExists("target") then return nil end
	local classification = UnitClassification("target")
	return classification
end

function RoRota:IsTargetElite()
	local classification = self:GetTargetClassification()
	return classification == "elite" or classification == "worldboss" or classification == "rareelite"
end

function RoRota:IsTargetBoss()
	local classification = self:GetTargetClassification()
	return classification == "worldboss"
end

function RoRota:IsTargetRare()
	local classification = self:GetTargetClassification()
	return classification == "rare" or classification == "rareelite"
end

-- Get target distance (requires unitxp sp3)
function RoRota:GetTargetDistance()
	if not UnitExists("target") then return nil end
	if not RoRota.Integration or not RoRota.Integration:HasUnitXP() then
		return nil
	end
	return UnitXP("distanceBetween", "player", "target")
end

-- Check if target is in melee range
function RoRota:IsTargetInMeleeRange()
	if not UnitExists("target") then return false end
	if RoRota.Integration and RoRota.Integration:HasUnitXP() then
		local distance = UnitXP("distanceBetween", "player", "target")
		return distance and distance <= 5
	end
	return CheckInteractDistance("target", 3)
end

-- Rotation reason (for debug display)
RoRota.rotationReason = ""

if not RoRota then return end
if RoRota.helpers then return end

RoRota.helpers = true
