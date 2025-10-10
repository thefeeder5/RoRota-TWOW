--[[ rotation ]]--
-- Main rotation logic for ability priority and execution.
-- This module handles the complete rotation flow from openers to finishers.
--
-- Features:
--   - Stealth opener logic with failsafe switching
--   - Interrupt priority (Kick > Gouge > Kidney Shot)
--   - Smart Eviscerate (execute at any CP if it kills target)
--   - Smart Rupture (skip if it would overkill)
--   - Finisher priority system (user-configurable)
--   - Energy pooling at 4+ CP
--   - Builder failsafe (switch if primary fails repeatedly)
--   - Defensive abilities (Vanish, Feint, Riposte, Surprise Attack)
--   - Throttling (0.1s interval) to reduce CPU usage
--   - Error handling with safe fallback to Sinister Strike
--
-- External function:
--   RoRotaRunRotation()
--     Main entry point called by keybind or macro
--     Wrapped in pcall for error safety

-- State tracking variables
local opener_attempts = 0
local builder_attempts = 0
local pick_pocket_used = false
local last_target = nil
local was_stealthed = false
local last_cp = 0
local cold_blood_used = false

-- throttling cache
local last_rotation_time = 0
local cached_ability = nil
local THROTTLE_INTERVAL = 0.1

-- manual timer tracking (fallback when SuperWoW API unavailable)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
RoRota.exposeArmorExpiry = 0
RoRota.exposeArmorTarget = nil
RoRota.ghostlyStrikeCooldown = 0

-- Internal Rotation Logic
local function RoRotaRunRotationInternal()
    local now = GetTime()
    
    -- throttling check
    if now - last_rotation_time < THROTTLE_INTERVAL then
        if RoRota.Debug and RoRota.Debug.enabled then
            RoRota.Debug:Log(string.format("Throttled (%.3fs since last)", now - last_rotation_time), "DEBUG")
        end
        if cached_ability then
            CastSpellByName(cached_ability)
        end
        return
    end
    
    last_rotation_time = now
    cached_ability = nil
    
    -- update cached state
    if RoRota.State then
        RoRota.State:Update()
    end
    
    -- update CP talents (cached, only updates every 5s)
    if RoRota.UpdateCPTalents then
        RoRota:UpdateCPTalents()
    end
    
    -- performance tracking
    if RoRota.Debug then
        RoRota.Debug:StartTimer()
    end
    
    -- use cached state
    local state = RoRota.State or {}
    local hasTarget = state.hasTarget or (UnitExists("target") and not UnitIsDead("target"))
    local inCombat = state.inCombat or UnitAffectingCombat("player")
    
    -- No Target: Apply poisons if needed
    if not hasTarget then
        if not inCombat and RoRota.CheckAndApplyPoisons then
            RoRota:CheckAndApplyPoisons()
        end
        if RoRota.Debug then RoRota.Debug:EndTimer() end
        return
    end
    
    -- Target Switch: Reset state
    local targetName = UnitName("target")
    if targetName ~= last_target then
        opener_attempts = 0
        builder_attempts = 0
        pick_pocket_used = false
        last_target = targetName
        last_cp = 0
        RoRota.targetCasting = false
        RoRota.castingTimeout = 0
        -- reset timers on target switch
        if RoRota.ruptureTarget ~= targetName then
            RoRota.ruptureExpiry = 0
            RoRota.ruptureTarget = nil
        end
        if RoRota.exposeArmorTarget ~= targetName then
            RoRota.exposeArmorExpiry = 0
            RoRota.exposeArmorTarget = nil
        end

    end
    
    -- stealth detection: reset opener attempts when entering/leaving stealth
    local isStealthed = RoRota:HasPlayerBuff("Stealth")
    if isStealthed and not was_stealthed then
        -- entered stealth mid-combat
        opener_attempts = 0
        pick_pocket_used = false
    elseif was_stealthed and not isStealthed then
        -- left stealth
        opener_attempts = 0
    end
    was_stealthed = isStealthed
    
    -- use cached values
    local cp = state.comboPoints or GetComboPoints("player", "target")
    local energy = state.energy or UnitMana("player")
    local db = RoRota.db.profile or {}
    -- safe references for profile subtables
    local defensive = db.defensive or {}
    local interrupt = db.interrupt or {}
    local openerCfg = db.opener or {}
    local abilitiesCfg = db.abilities or {}
    local energyCfg = db.energyPooling or {}
    local finisherPrio = db.finisherPriority or (RoRotaConstants and RoRotaConstants.DEFAULT_PROFILE and RoRotaConstants.DEFAULT_PROFILE.finisherPriority) or {"Slice and Dice","Expose Armor","Eviscerate","Rupture"}

    -- Defensive Abilities
    
    -- vanish at low HP
    local playerHP = state.healthPercent or RoRota:GetPlayerHealthPercent()
    if defensive.useVanish and playerHP <= (defensive.vanishHP or 0) then
        if RoRota:HasSpell("Vanish") and not RoRota:IsOnCooldown("Vanish") then
            cachedAbility = "Vanish"
            CastSpellByName("Vanish")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        -- wait for GCD
        if RoRota:HasSpell("Vanish") then
            return
        end
    end
    
    -- Interrupts (High Priority)
    if RoRota:IsTargetCasting() then
        -- skip if spell is known to be uninterruptible
        if RoRota.currentTargetSpell and RoRota:IsSpellUninterruptible(RoRota.currentTargetSpell) then
            -- don't try to interrupt
        elseif interrupt.useKick and RoRota:HasSpell("Kick") and RoRota:HasEnoughEnergy("Kick") and not RoRota:IsOnCooldown("Kick") and not RoRota:IsTargetImmune("Kick") then
            cachedAbility = "Kick"
            CastSpellByName("Kick")
            RoRota.targetCasting = false
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        elseif interrupt.useGouge and RoRota:HasSpell("Gouge") and RoRota:HasEnoughEnergy("Gouge") and not RoRota:IsOnCooldown("Gouge") and not RoRota:IsTargetImmune("Gouge") then
            cachedAbility = "Gouge"
            CastSpellByName("Gouge")
            RoRota.targetCasting = false
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        elseif interrupt.useKidneyShot and cp >= 1 and cp <= (interrupt.kidneyMaxCP or 5) and RoRota:HasSpell("Kidney Shot") and RoRota:HasEnoughEnergy("Kidney Shot") and not RoRota:IsTargetImmune("Kidney Shot") then
            cachedAbility = "Kidney Shot"
            CastSpellByName("Kidney Shot")
            RoRota.targetCasting = false
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        -- wait for interrupt to be ready
        if interrupt.useKick or interrupt.useGouge or interrupt.useKidneyShot then
            return
        end
    end
    
    -- feint (group/raid only)
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
                cachedAbility = "Feint"
                CastSpellByName("Feint")
                if RoRota.Debug then RoRota.Debug:EndTimer() end
                return
            end
            -- wait for GCD
            return
        end
    end
    
    -- riposte (after parry)
    if defensive.useRiposte and RoRota:CanUseRiposte() then
        if RoRota:HasSpell("Riposte") and RoRota:HasEnoughEnergy("Riposte") then
            cachedAbility = "Riposte"
            CastSpellByName("Riposte")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        -- wait for GCD/energy
        return
    end
    
    -- surprise attack (after dodge)
    if defensive.useSurpriseAttack and RoRota:CanUseSurpriseAttack() then
        if RoRota:HasSpell("Surprise Attack") and RoRota:HasEnoughEnergy("Surprise Attack") then
            cachedAbility = "Surprise Attack"
            CastSpellByName("Surprise Attack")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        -- wait for GCD/energy
        return
    end
    
    -- Stealth Opener
    
    -- pick pocket before opener
    if isStealthed and openerCfg.pickPocket and not pick_pocket_used and RoRota:HasSpell("Pick Pocket") then
        if not RoRota:TargetHasNoPockets() then
            cached_ability = "Pick Pocket"
            CastSpellByName("Pick Pocket")
            pick_pocket_used = true
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
    end
    
    -- opener with failsafe
    if isStealthed then
        local opener = openerCfg.ability
        -- switch to secondary if immune
        if opener and RoRota:IsTargetImmune(opener) and openerCfg.secondaryAbility then
            opener = openerCfg.secondaryAbility
        elseif (openerCfg.failsafeAttempts or -1) >= 0 and opener_attempts > (openerCfg.failsafeAttempts or -1) and openerCfg.secondaryAbility then
            opener = openerCfg.secondaryAbility
        end
        -- use Cold Blood before Ambush if enabled
        if openerCfg.useColdBlood and opener == "Ambush" and RoRota:HasSpell("Cold Blood") and not RoRota:IsOnCooldown("Cold Blood") and not RoRota:HasPlayerBuff("Cold Blood") then
            CastSpellByName("Cold Blood")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        if opener and not RoRota:IsTargetImmune(opener) then
            cached_ability = opener
            CastSpellByName(opener)
        end
        opener_attempts = opener_attempts + 1
        if RoRota.Debug then RoRota.Debug:EndTimer() end
        return
    end
    
    -- Finishers
    
    -- smart eviscerate (execute)
    if cp >= 1 and db.smartEviscerate then
        local minCP = db.coldBloodMinCP or 4
        -- check if can kill with current CP
        if RoRota:CanKillWithEviscerate(cp) and RoRota:HasEnoughEnergy("Eviscerate") then
            -- use Cold Blood if: enabled, meets min CP, and target doesn't die without it
            if db.useColdBloodEviscerate and cp >= minCP and RoRota:HasSpell("Cold Blood") and not RoRota:IsOnCooldown("Cold Blood") and not RoRota:HasPlayerBuff("Cold Blood") then
                CastSpellByName("Cold Blood")
                if RoRota.Debug then RoRota.Debug:EndTimer() end
                return
            end
            cached_ability = "Eviscerate"
            if RoRota.Debug then
                RoRota.Debug:Trace("Eviscerate", "Smart Kill-shot", string.format("CP: %d", cp))
            end
            CastSpellByName("Eviscerate")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
    end
    
    -- strategic finisher planning
    if cp >= 1 and cp < 5 and RoRota.PlanRotation then
        local plannedAbility, reason = RoRota:PlanRotation(cp, energy)
        
        if plannedAbility and RoRota:IsFinisher(plannedAbility) then
            RoRota.rotationReason = reason or ""
            
            -- smart rupture check
            if plannedAbility == "Rupture" and db.smartRupture and RoRota:WouldOverkill("Rupture", cp) then
                if RoRota.Debug and RoRota.Debug.enabled then
                    RoRota.Debug:Log("Rupture skipped: would overkill", "TRACE")
                end
                -- continue to eviscerate fallback
            else
                cached_ability = plannedAbility
                CastSpellByName(plannedAbility)
                
                -- set timers
                if plannedAbility == "Slice and Dice" then
                    -- Turtle WoW: 9/12/15/18/21 seconds (base 6 + cp * 3)
                    local duration = 6 + (cp * 3)
                    -- Improved Blade Tactics: +15% per rank
                    if RoRota.TalentCache and RoRota.TalentCache.improvedBladeTactics then
                        duration = duration * (1 + (RoRota.TalentCache.improvedBladeTactics * 0.15))
                    end
                    RoRota.sndExpiry = GetTime() + duration
                elseif plannedAbility == "Envenom" then
                    -- Turtle WoW: 12/16/20/24/28 seconds (base 8 + cp * 4)
                    RoRota.envenomExpiry = GetTime() + 8 + (cp * 4)
                elseif plannedAbility == "Rupture" then
                    local duration = 6 + (cp * 2)
                    if RoRota.TalentCache and RoRota.TalentCache.tasteForBlood then
                        duration = duration + (RoRota.TalentCache.tasteForBlood * 2)
                    end
                    RoRota.ruptureExpiry = GetTime() + duration
                    RoRota.ruptureTarget = targetName
                elseif plannedAbility == "Expose Armor" then
                    RoRota.exposeArmorExpiry = GetTime() + 30
                    RoRota.exposeArmorTarget = targetName
                end
                
                if RoRota.Debug then RoRota.Debug:EndTimer() end
                return
            end
        elseif not plannedAbility and reason then
            -- planner says to pool
            RoRota.rotationReason = reason
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        -- if planner returned a builder, fall through to continue building
    end
    
    -- eviscerate at 5 CP (or 4 CP if overflow risk)
    local shouldFinish = cp == 5
    if not shouldFinish and RoRota.ShouldUseFinisherEarly then
        shouldFinish = RoRota:ShouldUseFinisherEarly(cp)
    end
    
    if shouldFinish and RoRota:HasEnoughEnergy("Eviscerate") then
        -- use Cold Blood before Eviscerate if enabled and meets minimum CP
        local minCP = db.coldBloodMinCP or 4
        if db.useColdBloodEviscerate and cp >= minCP and RoRota:HasSpell("Cold Blood") and not RoRota:IsOnCooldown("Cold Blood") and not RoRota:HasPlayerBuff("Cold Blood") and not cold_blood_used then
            CastSpellByName("Cold Blood")
            cold_blood_used = true
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
        cold_blood_used = false
        cached_ability = "Eviscerate"
        if RoRota.Debug and cp == 4 then
            RoRota.Debug:Trace("Eviscerate", "Early finisher (CP overflow prevention)", string.format("CP: %d", cp))
        end
        CastSpellByName("Eviscerate")
        if RoRota.Debug then RoRota.Debug:EndTimer() end
        return
    end
    
    -- Builders
    

    
    -- ghostly strike (conditional builder)
    if defensive.useGhostlyStrike and RoRota:HasSpell("Ghostly Strike") and RoRota:HasEnoughEnergy("Ghostly Strike") then
        if GetTime() >= RoRota.ghostlyStrikeCooldown then
            local targetHP = state.targetHealthPercent or RoRota:GetTargetHealthPercent()
            if targetHP <= (defensive.ghostlyTargetMaxHP or 100) and playerHP >= (defensive.ghostlyPlayerMinHP or 0) and playerHP <= (defensive.ghostlyPlayerMaxHP or 100) then
                if RoRota.Debug then
                    RoRota.Debug:Trace("Ghostly Strike", "Conditions met", string.format("Target HP: %.1f%%, Player HP: %.1f%%", targetHP, playerHP))
                end
                cached_ability = "Ghostly Strike"
                CastSpellByName("Ghostly Strike")
                RoRota.ghostlyStrikeCooldown = GetTime() + 20
                if RoRota.Debug then RoRota.Debug:EndTimer() end
                return
            end
        end
    end
    
    -- reset builder attempts if CP increased
    if cp > last_cp then
        builder_attempts = 0
    end
    last_cp = cp
    
    -- use planner recommendation for builder
    if RoRota.Planner and RoRota.Planner.recommendation and not RoRota:IsFinisher(RoRota.Planner.recommendation) then
        RoRota.rotationReason = RoRota.Planner.reason or ""
    end
    
    -- main builder with failsafe
    local builder = db.mainBuilder
    if db.builderFailsafe and db.builderFailsafe >= 0 and builder_attempts > db.builderFailsafe and db.secondaryBuilder then
        builder = db.secondaryBuilder
    end
    
    -- smart combo builders: wait for swing window
    if db.smartBuilders and builder and (builder == "Sinister Strike" or builder == "Backstab" or builder == "Noxious Assault") then
        if RoRota.SwingTimer and not RoRota.SwingTimer:CanUseBuilder() then
            RoRota.rotationReason = "Waiting for swing timer"
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
    end
    
    if builder and RoRota:HasEnoughEnergy(builder) then
        if RoRota.Debug then
            RoRota.Debug:Trace(builder, "Builder", string.format("Attempt: %d, CP: %d, Energy: %d", builder_attempts + 1, cp, energy))
        end
        cached_ability = builder
        CastSpellByName(builder)
        builder_attempts = builder_attempts + 1
    else
        RoRota.rotationReason = "Waiting for energy"
    end
    
    -- end performance tracking
    if RoRota.Debug then
        RoRota.Debug:EndTimer()
    end
end

-- Main Entry Point (Error Handling Wrapper)
function RoRotaRunRotation()
    local success, err = pcall(RoRotaRunRotationInternal)
    
    if not success then
        -- Log error
        if RoRota.Debug then
            RoRota.Debug:Error("Rotation error", err)
        else
            RoRota:Print("|cFFFF0000[Error]|r Rotation failed: " .. tostring(err))
        end
        
        -- Safe fallback: cast Sinister Strike if available
        if RoRota:HasSpell("Sinister Strike") and RoRota:HasEnoughEnergy("Sinister Strike") then
            CastSpellByName("Sinister Strike")
        end
    end
end
