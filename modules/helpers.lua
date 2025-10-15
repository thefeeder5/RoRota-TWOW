--[[ helpers ]]--
-- Utility functions for rotation system.
-- This module contains general helper functions that don't fit into specific modules.
--
-- Functions moved to specialized modules:
--   abilities.lua - HasSpell, GetEnergyCost, HasEnoughEnergy, IsOnCooldown, GetSpellRank
--   buffs.lua - HasPlayerBuff, HasTargetDebuff, GetBuffTimeRemaining, GetDebuffTimeRemaining
--   damage.lua - WouldOverkill, CanKillWithEviscerate, GetAttackPower
--   talents.lua - All talent modifier functions
--   immunity.lua - IsTargetImmune, TargetHasNoPockets, ProcessImmunity, UsedSap
--   casting.lua - IsTargetCasting, all event handlers

function RoRota:GetThreatSituation()
    if UnitThreatSituation then
        return UnitThreatSituation("player", "target") or 0
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

-- Rotation Preview

-- Rotation reason (for debug display)
RoRota.rotationReason = ""

function RoRota:IsTargetBoss()
	local classification = self:GetTargetClassification()
	return classification == "worldboss"
end

function RoRota:IsTargetRare()
	local classification = self:GetTargetClassification()
	return classification == "rare" or classification == "rareelite"
end

-- Check if ability is a finisher
function RoRota:IsFinisher(ability)
	if not ability then return false end
	return ability == "Eviscerate" or ability == "Slice and Dice" or ability == "Rupture" 
		or ability == "Envenom" or ability == "Expose Armor" or ability == "Kidney Shot"
		or ability == "Cold Blood"
end

-- Calculate expected CP after using a builder (accounts for Seal Fate, etc.)
function RoRota:CalculateExpectedCP(ability, currentCP)
	if not ability or self:IsFinisher(ability) then
		return currentCP
	end
	
	local expectedCP = math.min(5, currentCP + 1)
	return expectedCP
end
