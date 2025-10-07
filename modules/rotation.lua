-- RoRota Rotation Module
-- Main rotation logic executed by keybind

-- Failsafe counters to prevent ability spam when out of range/facing/etc
local openerAttempts = 0
local builderAttempts = 0
local pickPocketUsed = false
local lastTarget = nil
local wasStealthed = false
local lastCP = 0

-- Manual buff/debuff expiry timers (fallback when SuperWoW API unavailable)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
-- Manual cooldown tracking for Ghostly Strike (GetSpellCooldown unreliable for this ability)
RoRota.ghostlyStrikeCooldown = 0

-- Main rotation function called by keybind
-- Priority order: Poisons > Vanish > Interrupts > Defensive > Opener > Kill-shot > Finishers > Energy Pool > Builders
function RoRotaRunRotation()
    if not UnitExists("target") or UnitIsDead("target") then
        -- Apply poisons when out of combat and no target
        if not UnitAffectingCombat("player") and RoRota.CheckAndApplyPoisons then
            RoRota:CheckAndApplyPoisons()
        end
        return
    end
    
    -- Reset state when switching targets
    local targetName = UnitName("target")
    if targetName ~= lastTarget then
        openerAttempts = 0
        builderAttempts = 0
        pickPocketUsed = false
        lastTarget = targetName
        lastCP = 0
        RoRota.targetCasting = false
        RoRota.castingTimeout = 0
        -- Only reset Rupture timer if different target
        if RoRota.ruptureTarget ~= targetName then
            RoRota.ruptureExpiry = 0
            RoRota.ruptureTarget = targetName
        end
    end
    
    -- Reset opener attempts when leaving stealth
    local isStealthed = RoRota:HasPlayerBuff("Stealth")
    if wasStealthed and not isStealthed then
        openerAttempts = 0
    end
    wasStealthed = isStealthed
    
    local cp = GetComboPoints("player", "target")
    local db = RoRota.db.profile or {}
    -- Provide local safe references for subtables that may be missing in some profiles
    local defensive = db.defensive or {}
    local interrupt = db.interrupt or {}
    local openerCfg = db.opener or {}
    local abilitiesCfg = db.abilities or {}
    local energyCfg = db.energyPooling or {}
    local finisherPrio = db.finisherPriority or (RoRotaConstants and RoRotaConstants.DEFAULT_PROFILE and RoRotaConstants.DEFAULT_PROFILE.finisherPriority) or {"SnD","ExposeArmor","Eviscerate","Rupture"}

    -- Defensive: Vanish at low HP
    if defensive.useVanish and RoRota:GetPlayerHealthPercent() <= (defensive.vanishHP or 0) then
        if RoRota:HasSpell("Vanish") and not RoRota:IsOnCooldown("Vanish") then
            CastSpellByName("Vanish")
            return
        end
        -- Wait for GCD if we want to Vanish but can't yet
        if RoRota:HasSpell("Vanish") then
            return
        end
    end
    
    -- Interrupts (high priority) - check immunity before casting
    if RoRota:IsTargetCasting() then
        if interrupt.useKick and RoRota:HasSpell("Kick") and RoRota:HasEnoughEnergy("Kick") and not RoRota:IsOnCooldown("Kick") and not RoRota:IsTargetImmune("Kick") then
            CastSpellByName("Kick")
            RoRota.targetCasting = false
            return
        elseif interrupt.useGouge and RoRota:HasSpell("Gouge") and RoRota:HasEnoughEnergy("Gouge") and not RoRota:IsOnCooldown("Gouge") and not RoRota:IsTargetImmune("Gouge") then
            CastSpellByName("Gouge")
            RoRota.targetCasting = false
            return
        elseif interrupt.useKidneyShot and cp >= 1 and cp <= (interrupt.kidneyMaxCP or 5) and RoRota:HasSpell("Kidney Shot") and RoRota:HasEnoughEnergy("Kidney Shot") and not RoRota:IsTargetImmune("Kidney Shot") then
            CastSpellByName("Kidney Shot")
            RoRota.targetCasting = false
            return
        end
        -- If target is casting and we have interrupts enabled but can't use them yet (GCD/energy/cooldown), wait
        if interrupt.useKick or interrupt.useGouge or interrupt.useKidneyShot then
            return
        end
    end
    
    -- Defensive: Feint (only in group/raid)
    if defensive.useFeint and RoRota:IsInGroupOrRaid() and RoRota:HasSpell("Feint") and RoRota:HasEnoughEnergy("Feint") then
        local shouldFeint = false
        if defensive.feintMode == "Always" then
            shouldFeint = true
        elseif defensive.feintMode == "WhenTargeted" and RoRota:IsPlayerTargeted() then
            shouldFeint = true
        elseif defensive.feintMode == "HighThreat" then
            local threat = RoRota:GetThreatSituation()
            if threat >= 2 then
                shouldFeint = true
            end
        end
        if shouldFeint then
            if not RoRota:IsOnCooldown("Feint") then
                CastSpellByName("Feint")
                return
            end
            -- Wait for GCD if we want to Feint but it's on cooldown (likely GCD)
            return
        end
    end
    
    -- Reactive: Riposte (after parry) - wait for GCD since buff window is limited
    if defensive.useRiposte and RoRota:CanUseRiposte() then
        if RoRota:HasSpell("Riposte") and RoRota:HasEnoughEnergy("Riposte") then
            CastSpellByName("Riposte")
            return
        end
        -- Wait for GCD/energy since Riposte buff has limited duration
        return
    end
    
    -- Reactive: Surprise Attack (after dodge) - wait for GCD since buff window is limited
    if defensive.useSurpriseAttack and RoRota:CanUseSurpriseAttack() then
        if RoRota:HasSpell("Surprise Attack") and RoRota:HasEnoughEnergy("Surprise Attack") then
            CastSpellByName("Surprise Attack")
            return
        end
        -- Wait for GCD/energy since Surprise Attack buff has limited duration
        return
    end
    
    -- Pick Pocket before opener (skip if target has no pockets)
    if isStealthed and openerCfg.pickPocket and not pickPocketUsed and RoRota:HasSpell("Pick Pocket") then
        if not RoRota:TargetHasNoPockets() then
            CastSpellByName("Pick Pocket")
            pickPocketUsed = true
            return
        end
    end
    
    -- Opener logic: Use secondary opener if primary fails after X attempts or is immune
    if isStealthed then
        local opener = openerCfg.ability
        -- Check if main opener is immune, switch to secondary immediately
        if opener and RoRota:IsTargetImmune(opener) and openerCfg.secondaryAbility then
            opener = openerCfg.secondaryAbility
        elseif (openerCfg.failsafeAttempts or -1) >= 0 and openerAttempts > (openerCfg.failsafeAttempts or -1) and openerCfg.secondaryAbility then
            opener = openerCfg.secondaryAbility
        end
        if opener and not RoRota:IsTargetImmune(opener) then
            CastSpellByName(opener)
        end
        openerAttempts = openerAttempts + 1
        return
    end
    
    -- Smart Eviscerate: Kill with Eviscerate at any CP if it will finish target
    if cp >= 1 and db.smartEviscerate then
        if RoRota:CanKillWithEviscerate(cp) and RoRota:HasEnoughEnergy("Eviscerate") then
            CastSpellByName("Eviscerate")
            return
        end
    end
    
    -- Finisher priority system: Loop through user-defined priority order
    if cp >= 1 then
        for _, finisher in ipairs(finisherPrio) do
            if finisher == "SnD" and abilitiesCfg.SliceAndDice and abilitiesCfg.SliceAndDice.enabled then
                if cp >= (abilitiesCfg.SliceAndDice.minCP or 1) and cp <= (abilitiesCfg.SliceAndDice.maxCP or 5) then
                    local sndTime = RoRota:GetBuffTimeRemaining("Slice and Dice")
                    if sndTime <= 2 and RoRota:HasEnoughEnergy("Slice and Dice") then
                        CastSpellByName("Slice and Dice")
                        RoRota.sndExpiry = GetTime() + 9 + (cp * 3)
                        return
                    end
                end
            elseif finisher == "Envenom" and abilitiesCfg.Envenom and abilitiesCfg.Envenom.enabled then
                if cp >= (abilitiesCfg.Envenom.minCP or 1) and cp <= (abilitiesCfg.Envenom.maxCP or 5) then
                    local envTime = RoRota:GetBuffTimeRemaining("Envenom")
                    if envTime <= 2 and RoRota:HasEnoughEnergy("Envenom") then
                        CastSpellByName("Envenom")
                        RoRota.envenomExpiry = GetTime() + 6 + (cp * 2)
                        return
                    end
                end
            elseif finisher == "Rupture" and abilitiesCfg.Rupture and abilitiesCfg.Rupture.enabled then
                if cp >= (abilitiesCfg.Rupture.minCP or 1) and cp <= (abilitiesCfg.Rupture.maxCP or 5) then
                    local ruptTime = RoRota:GetDebuffTimeRemaining("Rupture")
                    if ruptTime <= 2 and RoRota:HasEnoughEnergy("Rupture") then
                        local skipRupture = false
                        if db.smartRupture and RoRota:WouldOverkill("Rupture", cp) then
                            skipRupture = true
                        end
                        if not skipRupture then
                            CastSpellByName("Rupture")
                            RoRota.ruptureExpiry = GetTime() + 6 + (cp * 2)
                            RoRota.ruptureTarget = targetName
                            return
                        end
                    end
                end
            elseif finisher == "ExposeArmor" and abilitiesCfg.ExposeArmor and abilitiesCfg.ExposeArmor.enabled then
                if cp >= (abilitiesCfg.ExposeArmor.minCP or 5) and cp <= (abilitiesCfg.ExposeArmor.maxCP or 5) then
                    if not RoRota:HasTargetDebuff("Expose Armor") and RoRota:HasEnoughEnergy("Expose Armor") then
                        CastSpellByName("Expose Armor")
                        return
                    end
                end
            end
        end
    end
    
    -- Eviscerate at 5 CP
    if cp >= 5 and RoRota:HasEnoughEnergy("Eviscerate") then
        CastSpellByName("Eviscerate")
        return
    end
    
    -- Energy pooling: Wait for energy at 4+ CP to ensure we can cast finisher immediately at 5 CP
    if energyCfg.enabled and cp >= 4 and not RoRota:HasAdrenalineRush() then
        local currentEnergy = UnitMana("player")
        local poolThreshold = energyCfg.threshold or 0
        if currentEnergy < RoRota:GetEnergyCost("Eviscerate") + poolThreshold then
            return
        end
    end
    
    -- Ghostly Strike as builder when conditions met
    if defensive.useGhostlyStrike and RoRota:HasSpell("Ghostly Strike") and RoRota:HasEnoughEnergy("Ghostly Strike") then
        if GetTime() >= RoRota.ghostlyStrikeCooldown then
            local targetHP = RoRota:GetTargetHealthPercent()
            local playerHP = RoRota:GetPlayerHealthPercent()
            if targetHP <= (defensive.ghostlyTargetMaxHP or 100) and playerHP >= (defensive.ghostlyPlayerMinHP or 0) and playerHP <= (defensive.ghostlyPlayerMaxHP or 100) then
                CastSpellByName("Ghostly Strike")
                RoRota.ghostlyStrikeCooldown = GetTime() + 20
                return
            end
        end
    end
    
    -- Reset builder attempts if CP increased (successful builder cast)
    if cp > lastCP then
        builderAttempts = 0
    end
    lastCP = cp
    
    -- Builder logic with failsafe: Switch to secondary builder if primary fails repeatedly
    local builder = db.mainBuilder
    if db.builderFailsafe and db.builderFailsafe >= 0 and builderAttempts > db.builderFailsafe and db.secondaryBuilder then
        builder = db.secondaryBuilder
    end
    
    if builder and RoRota:HasEnoughEnergy(builder) then
        CastSpellByName(builder)
        builderAttempts = builderAttempts + 1
    end
end
