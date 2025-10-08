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

-- throttling cache
local last_rotation_time = 0
local cached_ability = nil
local THROTTLE_INTERVAL = 0.1

-- manual timer tracking (fallback when SuperWoW API unavailable)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
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
        -- reset rupture timer
        if RoRota.ruptureTarget ~= targetName then
            RoRota.ruptureExpiry = 0
            RoRota.ruptureTarget = targetName
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
    local finisherPrio = db.finisherPriority or (RoRotaConstants and RoRotaConstants.DEFAULT_PROFILE and RoRotaConstants.DEFAULT_PROFILE.finisherPriority) or {"SnD","ExposeArmor","Eviscerate","Rupture"}

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
        if RoRota:CanKillWithEviscerate(cp) and RoRota:HasEnoughEnergy("Eviscerate") then
            cached_ability = "Eviscerate"
            if RoRota.Debug then
                RoRota.Debug:Trace("Eviscerate", "Smart Kill-shot", string.format("CP: %d", cp))
            end
            CastSpellByName("Eviscerate")
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
    end
    
    -- finisher priority loop
    if cp >= 1 then
        for _, finisher in ipairs(finisherPrio) do
            if finisher == "Slice and Dice" and abilitiesCfg.SliceAndDice and abilitiesCfg.SliceAndDice.enabled then
                if cp >= (abilitiesCfg.SliceAndDice.minCP or 1) and cp <= (abilitiesCfg.SliceAndDice.maxCP or 5) then
                    local sndTime = RoRota:GetBuffTimeRemaining("Slice and Dice")
                    if sndTime <= 2 and RoRota:HasEnoughEnergy("Slice and Dice") then
                        cached_ability = "Slice and Dice"
                        CastSpellByName("Slice and Dice")
                        RoRota.sndExpiry = GetTime() + 9 + (cp * 3)
                        if RoRota.Debug then RoRota.Debug:EndTimer() end
                        return
                    end
                end
            elseif finisher == "Envenom" and abilitiesCfg.Envenom and abilitiesCfg.Envenom.enabled then
                if cp >= (abilitiesCfg.Envenom.minCP or 1) and cp <= (abilitiesCfg.Envenom.maxCP or 5) then
                    local envTime = RoRota:GetBuffTimeRemaining("Envenom")
                    if envTime <= 2 and RoRota:HasEnoughEnergy("Envenom") then
                        cached_ability = "Envenom"
                        CastSpellByName("Envenom")
                        RoRota.envenomExpiry = GetTime() + 6 + (cp * 2)
                        if RoRota.Debug then RoRota.Debug:EndTimer() end
                        return
                    end
                end
            elseif finisher == "Rupture" and abilitiesCfg.Rupture and abilitiesCfg.Rupture.enabled then
                if cp >= (abilitiesCfg.Rupture.minCP or 1) and cp <= (abilitiesCfg.Rupture.maxCP or 5) then
                    local ruptTime = RoRota:GetDebuffTimeRemaining("Rupture")
                    if ruptTime <= 2 and RoRota:HasEnoughEnergy("Rupture") then
                        local skip_rupture = false
                        if db.smartRupture and RoRota:WouldOverkill("Rupture", cp) then
                            skip_rupture = true
                        end
                        if not skip_rupture then
                            cached_ability = "Rupture"
                            CastSpellByName("Rupture")
                            RoRota.ruptureExpiry = GetTime() + 6 + (cp * 2)
                            RoRota.ruptureTarget = targetName
                            if RoRota.Debug then RoRota.Debug:EndTimer() end
                            return
                        end
                    end
                end
            elseif finisher == "ExposeArmor" and abilitiesCfg.ExposeArmor and abilitiesCfg.ExposeArmor.enabled then
                if cp >= (abilitiesCfg.ExposeArmor.minCP or 5) and cp <= (abilitiesCfg.ExposeArmor.maxCP or 5) then
                    if not RoRota:HasTargetDebuff("Expose Armor") and RoRota:HasEnoughEnergy("Expose Armor") then
                        cached_ability = "Expose Armor"
                        CastSpellByName("Expose Armor")
                        if RoRota.Debug then RoRota.Debug:EndTimer() end
                        return
                    end
                end
            end
        end
    end
    
    -- eviscerate at 5 CP
    if cp >= 5 and RoRota:HasEnoughEnergy("Eviscerate") then
        cached_ability = "Eviscerate"
        CastSpellByName("Eviscerate")
        if RoRota.Debug then RoRota.Debug:EndTimer() end
        return
    end
    
    -- Builders
    
    -- energy pooling at 4+ CP
    -- TODO: This implementation is simplified and needs rework for proper energy pooling
    -- True pooling should wait at 5 CP when buffs/debuffs are active, not at 4 CP
    if energyCfg.enabled and cp >= 4 and not RoRota:HasAdrenalineRush() then
        local poolThreshold = energyCfg.threshold or 0
        if energy < RoRota:GetEnergyCost("Eviscerate") + poolThreshold then
            if RoRota.Debug then
                RoRota.Debug:Trace("Pooling Energy", "Waiting for finisher energy", string.format("Energy: %d/%d", energy, RoRota:GetEnergyCost("Eviscerate") + poolThreshold))
            end
            if RoRota.Debug then RoRota.Debug:EndTimer() end
            return
        end
    end
    
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
    
    -- CP overflow prevention: don't build at 5 CP
    if cp >= 5 then
        if RoRota.Debug then RoRota.Debug:EndTimer() end
        return
    end
    
    -- main builder with failsafe
    local builder = db.mainBuilder
    if db.builderFailsafe and db.builderFailsafe >= 0 and builder_attempts > db.builderFailsafe and db.secondaryBuilder then
        builder = db.secondaryBuilder
    end
    
    -- smart combo builders: wait for swing window
    if db.smartBuilders and builder and (builder == "Sinister Strike" or builder == "Backstab" or builder == "Noxious Assault") then
        if RoRota.SwingTimer and not RoRota.SwingTimer:CanUseBuilder() then
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
