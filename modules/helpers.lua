-- RoRota Helpers Module
-- Utility functions for checking buffs, debuffs, cooldowns, and calculating damage

-- Check if player has learned a spell by scanning spellbook
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

-- Get energy cost of spell, accounting for talent reductions
function RoRota:GetEnergyCost(spellName)
	local baseCost = RoRotaConstants.ENERGY_COSTS[spellName] or 0
	-- Improved Ghostly Strike talent (Subtlety tree)
	if spellName == "Ghostly Strike" then
		local _, _, _, _, rank = GetTalentInfo(3, 8)
		if rank == 1 then baseCost = baseCost - 3
		elseif rank == 2 then baseCost = baseCost - 6
		elseif rank == 3 then baseCost = baseCost - 10
		end
	-- Improved Hemorrhage talent (Subtlety tree)
	elseif spellName == "Hemorrhage" then
		local _, _, _, _, rank = GetTalentInfo(3, 17)
		if rank == 1 then baseCost = baseCost - 2
		elseif rank == 2 then baseCost = baseCost - 5
		end
	end
	return baseCost
end

function RoRota:HasEnoughEnergy(spellName)
	return UnitMana("player") >= self:GetEnergyCost(spellName)
end

function RoRota:HasPlayerBuff(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local name = UnitBuff("player", i)
        if name and string.find(name, buffName) then
            return true
        end
        i = i + 1
    end
    return false
end

function RoRota:HasTargetDebuff(debuffName)
    local i = 1
    while UnitDebuff("target", i) do
        local name = UnitDebuff("target", i)
        if name and string.find(name, debuffName) then
            return true
        end
        i = i + 1
    end
    return false
end

-- Check if target is casting or channeling a spell
-- Uses SuperWoW API if available, falls back to combat log tracking with timeout
function RoRota:IsTargetCasting()
    -- SuperWoW API: Check for regular casts
    if UnitCastingInfo then
        local spell = UnitCastingInfo("target")
        if spell then return true end
    end
    -- SuperWoW API: Check for channeled spells
    if UnitChannelInfo then
        local spell = UnitChannelInfo("target")
        if spell then return true end
    end
    -- Fallback: Combat log tracking with 3-second timeout
    if RoRota.targetCasting and GetTime() > RoRota.castingTimeout then
        RoRota.targetCasting = false
    end
    return RoRota.targetCasting or false
end

function RoRota:GetThreatSituation()
    if UnitThreatSituation then
        return UnitThreatSituation("player", "target") or 0
    end
    return 0
end

-- Check if spell is on cooldown using SuperWoW API
-- Returns true if cooldown > 1.5s (ignores GCD)
function RoRota:IsOnCooldown(spellIdOrName)
    local success, result1, result2 = pcall(GetSpellCooldown, spellIdOrName)
    -- result1 = start time, result2 = duration
    if success and result1 and result1 > 0 and result2 and result2 > 1.5 then
        return true
    end
    return false
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

function RoRota:GetAttackPower()
    local base, posBuff, negBuff = UnitAttackPower("player")
    return base + posBuff + negBuff
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

-- Get remaining time on player buff
-- Tries SuperWoW API first, falls back to manual timer tracking
function RoRota:GetBuffTimeRemaining(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitBuff("player", i)
        if texture and string.find(texture, buffName) and timeLeft then
            return timeLeft
        end
        i = i + 1
    end
    -- Fallback: Manual timer tracking
    if buffName == "Slice and Dice" then
        if not RoRota.sndExpiry or RoRota.sndExpiry == 0 then return 0 end
        return math.max(0, RoRota.sndExpiry - GetTime())
    elseif buffName == "Envenom" then
        if not RoRota.envenomExpiry or RoRota.envenomExpiry == 0 then return 0 end
        return math.max(0, RoRota.envenomExpiry - GetTime())
    end
    return 0
end

-- Get remaining time on target debuff
-- Tries SuperWoW API first, falls back to manual timer tracking
function RoRota:GetDebuffTimeRemaining(debuffName)
    local i = 1
    while UnitDebuff("target", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitDebuff("target", i)
        if texture and string.find(texture, debuffName) and timeLeft then
            return timeLeft
        end
        i = i + 1
    end
    -- Fallback: Manual timer tracking (only for Rupture, target-specific)
    if debuffName == "Rupture" then
        if UnitExists("target") and UnitName("target") == RoRota.ruptureTarget then
            if not RoRota.ruptureExpiry or RoRota.ruptureExpiry == 0 then return 0 end
            return math.max(0, RoRota.ruptureExpiry - GetTime())
        end
    end
    return 0
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

function RoRota:HasAdrenalineRush()
    return self:HasPlayerBuff("Adrenaline Rush")
end

function RoRota:GetSerratedBladesMod()
    local _, _, _, _, rank = GetTalentInfo(3, 6)
    if rank == 1 then return 1.10
    elseif rank == 2 then return 1.20
    elseif rank == 3 then return 1.30
    end
    return 1.0
end

-- Calculate if finisher would overkill target (waste damage)
-- Used for smart Rupture/Eviscerate to avoid wasting CP on dying targets
function RoRota:WouldOverkill(spellName, cp)
    if not self.db.profile.overkillPrevention then return false end
    local targetHP = UnitHealth("target")
    local damage = 0
    local ap = self:GetAttackPower()
    
    if spellName == "Eviscerate" then
        local rank = self:GetSpellRank("Eviscerate")
        if rank then
            local rankData = RoRotaConstants.EVISCERATE_DAMAGE[rank]
            local baseDmg = rankData and rankData[cp] or 0
            local apBonus = ap * (RoRotaConstants.EVISCERATE_AP_COEF[cp] or 0)
            local talentMod = self:GetImprovedEviscerateMod()
            local relentlessMod = self:GetRelentlessStrikesMod()
            local tasteForBloodMod = self:GetTasteForBloodMod()
            local aggressionMod = self:GetAggressionMod()
            damage = (baseDmg + apBonus) * RoRotaConstants.ARMOR_MITIGATION * talentMod * relentlessMod * tasteForBloodMod * aggressionMod
        end
    elseif spellName == "Rupture" then
        local rank = self:GetSpellRank("Rupture")
        if rank then
            local rankData = RoRotaConstants.RUPTURE_DAMAGE[rank]
            local baseDmg = rankData and rankData[cp] or 0
            local apBonus = ap * (RoRotaConstants.RUPTURE_AP_COEF[cp] or 0)
            local serratedMod = self:GetSerratedBladesMod()
            local totalDmg = (baseDmg + apBonus) * serratedMod
            local duration = 6 + (cp * 2)
            local tickCount = duration / 2
            damage = totalDmg * ((tickCount - 2) / tickCount)
        end
    end
    
    return damage > targetHP
end

-- Calculate if Eviscerate will kill target at current CP
-- Accounts for all damage modifiers: talents, buffs, AP, armor
function RoRota:CanKillWithEviscerate(cp)
    local targetHP = UnitHealth("target")
    local rank = self:GetSpellRank("Eviscerate")
    if not rank then return false end
    local rankData = RoRotaConstants.EVISCERATE_DAMAGE[rank]
    if not rankData then return false end
    local baseDmg = rankData[cp]
    if not baseDmg then return false end
    local ap = self:GetAttackPower()
    local apBonus = ap * (RoRotaConstants.EVISCERATE_AP_COEF[cp] or 0)
    -- Apply all damage modifiers
    local talentMod = self:GetImprovedEviscerateMod()
    local relentlessMod = self:GetRelentlessStrikesMod()
    local tasteForBloodMod = self:GetTasteForBloodMod()
    local aggressionMod = self:GetAggressionMod()
    local damage = (baseDmg + apBonus) * RoRotaConstants.ARMOR_MITIGATION * talentMod * relentlessMod * tasteForBloodMod * aggressionMod
    return damage >= targetHP
end

function RoRota:CanUseRiposte()
    return self:HasPlayerBuff("Riposte")
end

function RoRota:CanUseSurpriseAttack()
    return self:HasPlayerBuff("Surprise Attack")
end

-- Check if target is immune to an ability
function RoRota:IsTargetImmune(abilityName)
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.immunities then
        return false
    end
    local targetName = UnitName("target")
    return RoRotaDB.immunities[targetName] and RoRotaDB.immunities[targetName][abilityName]
end

-- Check if target has no pockets for Pick Pocket
function RoRota:TargetHasNoPockets()
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.noPockets then
        return false
    end
    local targetName = UnitName("target")
    return RoRotaDB.noPockets[targetName]
end

-- Track Sap usage for fail detection
function RoRota:UsedSap()
    self.sapFailed = true
    self.sapFailTime = GetTime()
end

-- Shared immunity groups - abilities that share the same immunity type
local immunityGroups = {
    bleed = {"Garrote", "Rupture"},
    stun = {"Cheap Shot", "Kidney Shot"},
    incapacitate = {"Gouge", "Sap"},
}

-- Process ability immunity detection and mark shared immunity groups
function RoRota:ProcessImmunity(targetName, ability)
    if not RoRotaDB.immunities[targetName] then
        RoRotaDB.immunities[targetName] = {}
    end
    RoRotaDB.immunities[targetName][ability] = true
    for groupName, abilities in pairs(immunityGroups) do
        for _, groupAbility in ipairs(abilities) do
            if groupAbility == ability then
                for _, sharedAbility in ipairs(abilities) do
                    RoRotaDB.immunities[targetName][sharedAbility] = true
                end
                self:Print(targetName.." is immune to "..ability.." (and related abilities)")
                return
            end
        end
    end
    self:Print(targetName.." is immune to "..ability)
end

-- Check if poisons need to be applied
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

-- Preview next ability that will be cast by rotation
-- Mirrors RoRotaRunRotation logic for real-time rotation display
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
        local opener = db.opener.ability or "Ambush"
        -- Check immunity and switch to secondary if needed
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
        return "Eviscerate (Kill)"
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

-- Combat log event handlers for casting detection
function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

-- Detect ability immunity from combat log
function RoRota:CHAT_MSG_SPELL_SELF_DAMAGE()
    if not UnitExists("target") or not arg1 then return end
    local targetName = UnitName("target")
    if string.find(arg1, "failed") and string.find(arg1, "immune") then
        for ability in string.gmatch(arg1, "Your (.+) failed") do
            self:ProcessImmunity(targetName, ability)
        end
    end
end

-- Detect Pick Pocket and Sap failures
function RoRota:UI_ERROR_MESSAGE()
    if not arg1 then return end
    if UnitExists("target") and (string.find(arg1, "no pockets") or string.find(arg1, "can't be pick pocketed")) then
        local targetName = UnitName("target")
        RoRotaDB.noPockets[targetName] = true
        self:Print(targetName.." has no pockets - will skip Pick Pocket")
    end
    if string.find(arg1, "immune") or string.find(arg1, "resist") then
        if string.find(arg1, "Sap") or self.sapFailed then
            self.sapFailed = true
            self.sapFailTime = GetTime()
        end
    end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE()
    if not arg1 then return end
    if self.sapFailed and GetTime() - self.sapFailTime < 2 then
        self.sapFailed = true
    end
end

-- Sap fail emergency action
function RoRota:PLAYER_REGEN_DISABLED()
    if self.sapFailed and GetTime() - self.sapFailTime < 3 then
        local action = self.db.profile.opener.sapFailAction
        if action and action ~= "None" then
            if action == "Vanish" and self:HasSpell("Vanish") and not self:IsOnCooldown("Vanish") then
                CastSpellByName("Vanish")
                self:Print("Sap failed! Using Vanish")
            elseif action == "Sprint" and self:HasSpell("Sprint") and not self:IsOnCooldown("Sprint") then
                CastSpellByName("Sprint")
                self:Print("Sap failed! Using Sprint")
            elseif action == "Evasion" and self:HasSpell("Evasion") and not self:IsOnCooldown("Evasion") then
                CastSpellByName("Evasion")
                self:Print("Sap failed! Using Evasion")
            end
        end
        self.sapFailed = false
    end
end

RoRotaHelpersLoaded = true
