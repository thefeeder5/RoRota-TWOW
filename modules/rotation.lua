--[[ rotation ]]--
-- Rotation orchestrator (Phase 7: Simplified).
-- Coordinates decision modules in priority order.
--
-- Priority Chain:
--   1. Cache Update
--   2. No Target → Poison Check
--   3. Target Switch → Reset State
--   4. Interrupt → Kick/Gouge/Kidney
--   5. Defensive → Vanish/Feint/Riposte
--   6. Cooldowns → Cold Blood/Adrenaline Rush/Sprint/Preparation
--   7. Opener → Stealth openers
--   8. Rotation → Planner decisions
--
-- Entry Point: RoRotaRunRotation()

-- Throttling (legacy, now using CastState)
local last_rotation_time = 0
local cached_ability = nil
local THROTTLE_INTERVAL = 0.05

-- State tracking
local last_target = nil
local was_stealthed = false

-- Manual timer tracking (fallback)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
RoRota.exposeArmorExpiry = 0
RoRota.exposeArmorTarget = nil

-- Internal rotation logic
local function RoRotaRunRotationInternal()
	local now = GetTime()
	
	-- Throttle check (minimal, state machine does heavy lifting)
	if now - last_rotation_time < THROTTLE_INTERVAL then
		return
	end
	
	-- Check if we have a queued ability from previous GCD
	if RoRota.CastState then
		local queuedAbility, queuedReason = RoRota.CastState:GetQueuedAbility()
		if queuedAbility and RoRota.CastState:CanCast() then
			-- Validate queued finisher still valid (CP in range)
			local isValid = true
			if RoRota.IsFinisher and RoRota:IsFinisher(queuedAbility) then
				local cp = RoRota.Cache and RoRota.Cache.comboPoints or GetComboPoints("player", "target")
				if RoRota.db and RoRota.db.profile and RoRota.db.profile.finishers then
					local finisherCfg = RoRota.db.profile.finishers[queuedAbility]
					if finisherCfg and finisherCfg.enabled then
						local minCP = finisherCfg.minCP or 1
						local maxCP = finisherCfg.maxCP or 5
						if cp < minCP or cp > maxCP then
							isValid = false
						end
					end
				end
			end
			
			if isValid then
				last_rotation_time = now
				RoRota.lastAbilityCast = queuedAbility
				RoRota.lastAbilityTime = GetTime()
				CastSpellByName(RoRota:T(queuedAbility))
				if RoRota.CombatLog then RoRota.CombatLog.gcdEnd = GetTime() + 0.8 end
				if RoRota.Debug and RoRota.Debug.enabled then
					RoRota.Debug:LogCast(queuedAbility, queuedReason or "Queued")
				end
				if RoRota.IsFinisher and RoRota:IsFinisher(queuedAbility) and RoRota.UpdateFinisherTimer then
					local cp = RoRota.Cache and RoRota.Cache.comboPoints or GetComboPoints("player", "target")
					RoRota:UpdateFinisherTimer(queuedAbility, cp)
				end
				RoRota.CastState:ClearQueue()
				return
			else
				RoRota.CastState:ClearQueue()
			end
		end
	end
	
	last_rotation_time = now
	cached_ability = nil
	
	-- 1. Update caches
	if RoRota.UpdateBuffCache then
		RoRota:UpdateBuffCache()
	end
	if RoRota.Cache then
		RoRota.Cache:Update()
	end
	
	-- 2. Update TTK tracking
	if RoRota.UpdateTTKSample and UnitExists("target") and not UnitIsDead("target") then
		if not RoRota.ttk.targetGUID then
			RoRota:StartTTKTracking()
		end
		RoRota:UpdateTTKSample()
	end
	
	-- Performance tracking
	if RoRota.Debug then
		RoRota.Debug:StartTimer()
	end
	
	-- Get cached state
	local hasTarget = RoRota.Cache and RoRota.Cache.hasTarget or (UnitExists("target") and not UnitIsDead("target"))
	local inCombat = RoRota.Cache and RoRota.Cache.inCombat or UnitAffectingCombat("player")
	
	-- 2. No target: apply poisons first, then auto-target
	if not hasTarget then
		if not inCombat then
			if RoRota.CheckAndApplyPoisons then
				RoRota:CheckAndApplyPoisons()
			end
			if RoRota.Debug then RoRota.Debug:EndTimer() end
			return
		else
			-- In combat: auto-target next enemy
			TargetNearestEnemy()
			hasTarget = UnitExists("target") and not UnitIsDead("target")
			if not hasTarget then
				if RoRota.Debug then RoRota.Debug:EndTimer() end
				return
			end
		end
	end
	
	-- 3. Target switch: reset state and start auto-attack
	local targetName = UnitName("target")
	if targetName ~= last_target then
		last_target = targetName
		RoRota.targetCasting = false
		RoRota.castingTimeout = 0
		
		-- Reset GCD on target switch to prevent rotation freeze
		if RoRota.CombatLog then
			RoRota.CombatLog.gcdEnd = 0
		end
		
		if RoRota.ResetOpenerState then RoRota:ResetOpenerState() end
		if RoRota.ResetBuilderState then RoRota:ResetBuilderState() end
		if RoRota.ResetCBEvisState then RoRota:ResetCBEvisState() end
		
		if RoRota.ruptureTarget ~= targetName then
			RoRota.ruptureExpiry = 0
			RoRota.ruptureTarget = targetName
		end
		if RoRota.exposeArmorTarget ~= targetName then
			RoRota.exposeArmorExpiry = 0
			RoRota.exposeArmorTarget = nil
		end
		
		if RoRota.StartTTKTracking then
			local success, err = pcall(RoRota.StartTTKTracking, RoRota)
			if not success then
				-- Silent fail
			end
		end
	end
	
	-- Stealth detection
	local isStealthed = RoRota.Cache and RoRota.Cache.stealthed or false
	if isStealthed and not was_stealthed then
		if RoRota.ResetOpenerState then RoRota:ResetOpenerState() end
	end
	was_stealthed = isStealthed
	
	-- Get CP and energy for logging
	local cp = RoRota.Cache and RoRota.Cache.comboPoints or GetComboPoints("player", "target")
	local energy = RoRota.Cache and RoRota.Cache.energy or UnitMana("player")
	
	-- 4. Interrupt (highest priority)
	local ability = RoRota.GetInterruptAbility and RoRota:GetInterruptAbility()
	if ability then
		if RoRota.CastState and not RoRota.CastState:CanCast() then
			RoRota.CastState:QueueAbility(ability, "Target casting")
			if RoRota.Debug then RoRota.Debug:EndTimer() end
			return
		end
		
		-- Store interrupt in history immediately
		local targetName = UnitName("target")
		local spellName = RoRota.currentTargetSpell or (RoRota.interruptState and RoRota.interruptState.lastInterruptedSpell)
		if targetName and spellName and RoRota.StoreInterruptedSpell then
			RoRota:StoreInterruptedSpell(targetName, spellName)
		end
		
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		cached_ability = ability
		CastSpellByName(RoRota:T(ability))
		-- Kick is off-GCD, others trigger GCD
		if RoRota.CombatLog and ability ~= "Kick" then
			RoRota.CombatLog.gcdEnd = GetTime() + 1.0
		end
		RoRota.targetCasting = false
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 5. Defensive
	ability = RoRota.GetDefensiveAbility and RoRota:GetDefensiveAbility()
	if ability then
		if RoRota.CastState and not RoRota.CastState:CanCast() then
			RoRota.CastState:QueueAbility(ability, "Defensive ability")
			if RoRota.Debug then RoRota.Debug:EndTimer() end
			return
		end
		
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		cached_ability = ability
		CastSpellByName(RoRota:T(ability))
		if RoRota.CombatLog then RoRota.CombatLog.gcdEnd = GetTime() + 0.8 end
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 6. Cooldowns (off-GCD, bypass CanCast check)
	ability = RoRota.GetCooldownAbility and RoRota:GetCooldownAbility()
	if ability then
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		cached_ability = ability
		CastSpellByName(RoRota:T(ability))
		-- Cooldowns are off-GCD, don't set GCD timer
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- Check for immunity buffs (skip damaging abilities)
	if RoRota.TargetHasImmunityBuff and RoRota:TargetHasImmunityBuff() then
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 7. Opener (bypass GCD check when stealthed)
	ability = RoRota.GetOpenerAbility and RoRota:GetOpenerAbility()
	if ability then
		-- Cast immediately from stealth (don't queue)
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		cached_ability = ability
		CastSpellByName(RoRota:T(ability))
		if RoRota.CombatLog then RoRota.CombatLog.gcdEnd = GetTime() + 0.8 end
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 8. Rotation (planner)
	local reason, data
	if RoRota.GetRotationAbility then
		ability, reason, data = RoRota:GetRotationAbility()
	else
		-- Fallback: simple rotation (use configured builder)
		local mainBuilder = RoRota.db and RoRota.db.profile and RoRota.db.profile.mainBuilder or "Sinister Strike"
		if cp >= 5 and energy >= 30 then
			ability = "Eviscerate"
			reason = "5 CP finisher"
		elseif cp < 5 and energy >= 40 then
			ability = mainBuilder
			reason = "Build combo points"
		end
	end
	
	if ability then
		-- Don't cast or log if on GCD
		if RoRota.CastState and not RoRota.CastState:CanCast() then
			RoRota.CastState:QueueAbility(ability, reason)
			if RoRota.Debug then RoRota.Debug:EndTimer() end
			return
		end
		
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		cached_ability = ability
		CastSpellByName(RoRota:T(ability))
		if RoRota.CombatLog then RoRota.CombatLog.gcdEnd = GetTime() + 0.8 end
		if RoRota.Debug and RoRota.Debug.enabled then
			RoRota.Debug:LogCast(ability, reason or "Rotation")
		end
		
		-- Update finisher timers
		if RoRota.IsFinisher and RoRota:IsFinisher(ability) and RoRota.UpdateFinisherTimer then
			RoRota:UpdateFinisherTimer(ability, cp)
		end
		
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	if RoRota.Debug then RoRota.Debug:EndTimer() end
end

-- Get current ability without casting (for preview)
function RoRota:GetCurrentAbility()
	if self.UpdateBuffCache then
		self:UpdateBuffCache()
	end
	if self.Cache then
		self.Cache:Update()
	end
	
	local hasTarget = self.Cache and self.Cache.hasTarget or (UnitExists("target") and not UnitIsDead("target"))
	if not hasTarget then return nil end
	
	local ability
	
	if self.GetInterruptAbility then
		ability = self:GetInterruptAbility()
		if ability then return ability end
	end
	
	if self.GetDefensiveAbility then
		ability = self:GetDefensiveAbility()
		if ability then return ability end
	end
	
	if self.GetCooldownAbility then
		ability = self:GetCooldownAbility()
		if ability then return ability end
	end
	
	if self.GetOpenerAbility then
		ability = self:GetOpenerAbility()
		if ability then return ability end
	end
	
	if self.GetRotationAbility then
		ability = self:GetRotationAbility()
		if ability then return ability end
	end
	
	-- Fallback: show intended ability even if no energy
	local cp = GetComboPoints("player", "target")
	if cp >= 5 then
		return "Eviscerate"
	else
		return self.db.profile.mainBuilder or "Sinister Strike"
	end
end

-- Main entry point (error handling wrapper)
function RoRotaRunRotation()
	-- Cancel Blade Flurry if active
	if RoRota:HasPlayerBuff("Blade Flurry") then
		CastSpellByName(RoRota:T("Blade Flurry"))
		return
	end
	
	local success, err = pcall(RoRotaRunRotationInternal)
	
	if not success then
		local errMsg = err and tostring(err) or "unknown error"
		if RoRota.Debug then
			RoRota.Debug:Error("Rotation error", errMsg)
		else
			RoRota:Print("|cFFFF0000[RoRota Error]|r " .. errMsg)
		end
		
		-- Safe fallback
		if RoRota:HasSpell("Sinister Strike") and RoRota:HasEnoughEnergy("Sinister Strike") then
			CastSpellByName(RoRota:T("Sinister Strike"))
		end
	end
end

-- AoE rotation moved to rotationaoe.lua
