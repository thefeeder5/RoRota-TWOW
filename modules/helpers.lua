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
    local _, _, _, _, rank = GetTalentInfo(1, 16)
    return 100 + (rank * 5)
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

function RoRota:GetNextAbility()
    if not UnitExists("target") or UnitIsDead("target") then
        if not UnitAffectingCombat("player") and self:NeedsPoisonApplication() then
            return "Apply Poison"
        end
        return "No Target"
    end
    local cp = GetComboPoints("player", "target")
    local db = self.db.profile
    local isStealthed = self:HasPlayerBuff("Stealth")
    if isStealthed then
        if db.opener.pickPocket and not pick_pocket_used and self:HasSpell("Pick Pocket") and not self:TargetHasNoPockets() then
            return "Pick Pocket"
        end
        local opener = db.opener.ability or "Ambush"
        if self:IsTargetImmune(opener) and db.opener.secondaryAbility then
            return db.opener.secondaryAbility
        end
        return opener
    end
    if self:IsTargetCasting() then
        if db.interrupt.useKick and self:HasSpell("Kick") and self:HasEnoughEnergy("Kick") and not self:IsOnCooldown("Kick") and not self:IsTargetImmune("Kick") then
            return "Kick"
        elseif db.interrupt.useGouge and self:HasSpell("Gouge") and self:HasEnoughEnergy("Gouge") and not self:IsOnCooldown("Gouge") and not self:IsTargetImmune("Gouge") then
            return "Gouge"
        elseif db.interrupt.useKidneyShot and cp >= 1 and cp <= db.interrupt.kidneyMaxCP and self:HasSpell("Kidney Shot") and self:HasEnoughEnergy("Kidney Shot") and not self:IsTargetImmune("Kidney Shot") then
            return "Kidney Shot"
        end
    end
    if cp >= 1 and db.smartEviscerate and self:CanKillWithEviscerate(cp) and self:HasEnoughEnergy("Eviscerate") then
        return "Smart Eviscerate"
    end
    if cp >= 1 then
        for _, finisher in ipairs(db.finisherPriority) do
            if finisher == "SnD" and db.abilities.SliceAndDice.enabled then
                if cp >= db.abilities.SliceAndDice.minCP and cp <= db.abilities.SliceAndDice.maxCP then
                    local sndTime = self:GetBuffTimeRemaining("Slice and Dice")
                    if sndTime <= 2 and self:HasEnoughEnergy("Slice and Dice") then
                        return "Slice and Dice"
                    end
                end
            elseif finisher == "Envenom" and db.abilities.Envenom.enabled then
                if cp >= db.abilities.Envenom.minCP and cp <= db.abilities.Envenom.maxCP then
                    local envTime = self:GetBuffTimeRemaining("Envenom")
                    if envTime <= 2 and self:HasEnoughEnergy("Envenom") then
                        return "Envenom"
                    end
                end
            elseif finisher == "Rupture" and db.abilities.Rupture.enabled then
                if cp >= db.abilities.Rupture.minCP and cp <= db.abilities.Rupture.maxCP then
                    local ruptTime = self:GetDebuffTimeRemaining("Rupture")
                    if ruptTime <= 2 and self:HasEnoughEnergy("Rupture") then
                        if not (db.smartRupture and self:WouldOverkill("Rupture", cp)) then
                            return "Rupture"
                        end
                    end
                end
            elseif finisher == "ExposeArmor" and db.abilities.ExposeArmor.enabled then
                if cp >= db.abilities.ExposeArmor.minCP and cp <= db.abilities.ExposeArmor.maxCP then
                    if not self:HasTargetDebuff("Expose Armor") and self:HasEnoughEnergy("Expose Armor") then
                        return "Expose Armor"
                    end
                end
            end
        end
    end
    if cp >= 5 and self:HasEnoughEnergy("Eviscerate") then
        return "Eviscerate"
    end
    if db.energyPooling.enabled and cp >= 4 and not self:HasAdrenalineRush() then
        local currentEnergy = UnitMana("player")
        local poolThreshold = db.energyPooling.threshold
        if currentEnergy < self:GetEnergyCost("Eviscerate") + poolThreshold then
            return "Pooling Energy"
        end
    end
    if db.defensive.useGhostlyStrike and self:HasSpell("Ghostly Strike") and self:HasEnoughEnergy("Ghostly Strike") then
        if GetTime() >= RoRota.ghostlyStrikeCooldown then
            local targetHP = self:GetTargetHealthPercent()
            local playerHP = self:GetPlayerHealthPercent()
            if targetHP <= db.defensive.ghostlyTargetMaxHP and playerHP >= db.defensive.ghostlyPlayerMinHP and playerHP <= db.defensive.ghostlyPlayerMaxHP then
                return "Ghostly Strike"
            end
        end
    end
    local builder = db.mainBuilder
    if builder and self:HasEnoughEnergy(builder) then
        return builder
    end
    return "Waiting for Energy"
end

-- Get ability that comes after the specified ability
-- Used for ability queue preview
function RoRota:GetNextAbilityAfter(current_ability)
    if not current_ability or current_ability == "No Target" or current_ability == "Apply Poison" or current_ability == "Waiting for Energy" or current_ability == "Pooling Energy" then
        return "---"
    end
    
    local db = self.db.profile
    local cp = GetComboPoints("player", "target")
    local energy = UnitMana("player")
    
    -- if current is opener, next is builder or finisher
    if current_ability == db.opener.ability or current_ability == db.opener.secondaryAbility then
        if cp >= 5 then
            return "Eviscerate"
        end
        return db.mainBuilder or "Sinister Strike"
    end
    
    -- if current is interrupt, next is normal rotation
    if current_ability == "Kick" or current_ability == "Gouge" or current_ability == "Kidney Shot" then
        if cp >= 5 then
            return "Eviscerate"
        end
        return db.mainBuilder or "Sinister Strike"
    end
    
    -- if current is Pick Pocket, next is opener
    if current_ability == "Pick Pocket" then
        local opener = db.opener.ability or "Ambush"
        if self:IsTargetImmune(opener) and db.opener.secondaryAbility then
            return db.opener.secondaryAbility
        end
        return opener
    end
    
    -- if current is finisher, next is builder
    if current_ability == "Slice and Dice" or current_ability == "Envenom" or current_ability == "Rupture" or current_ability == "Expose Armor" or current_ability == "Eviscerate" or current_ability == "Smart Eviscerate" then
        return db.mainBuilder or "Sinister Strike"
    end
    
    -- if current is builder, check if we'll have 5 CP
    if current_ability == db.mainBuilder or current_ability == db.secondaryBuilder or current_ability == "Ghostly Strike" or current_ability == "Riposte" or current_ability == "Surprise Attack" then
        if cp >= 4 then
            return "Eviscerate"
        end
        return db.mainBuilder or "Sinister Strike"
    end
    
    return "---"
end

RoRotaHelpersLoaded = true
