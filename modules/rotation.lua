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
--   6. Opener → Stealth openers
--   7. Rotation → Planner decisions
--
-- Entry Point: RoRotaRunRotation()

-- Throttling
local last_rotation_time = 0
local cached_ability = nil
local THROTTLE_INTERVAL = 0.1

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
	
	-- Throttle check
	if now - last_rotation_time < THROTTLE_INTERVAL then
		if cached_ability then
			CastSpellByName(cached_ability)
		end
		return
	end
	
	last_rotation_time = now
	cached_ability = nil
	
	-- 1. Update cache
	if RoRota.Cache then
		RoRota.Cache:Update()
	end
	
	-- Performance tracking
	if RoRota.Debug then
		RoRota.Debug:StartTimer()
	end
	
	-- Get cached state
	local hasTarget = RoRota.Cache and RoRota.Cache.hasTarget or (UnitExists("target") and not UnitIsDead("target"))
	local inCombat = RoRota.Cache and RoRota.Cache.inCombat or UnitAffectingCombat("player")
	
	-- 2. No target: apply poisons
	if not hasTarget then
		if not inCombat and RoRota.CheckAndApplyPoisons then
			RoRota:CheckAndApplyPoisons()
		end
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 3. Target switch: reset state
	local targetName = UnitName("target")
	if targetName ~= last_target then
		last_target = targetName
		RoRota.targetCasting = false
		RoRota.castingTimeout = 0
		
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
		if RoRota.Debug and RoRota.Debug.enabled then
			RoRota.Debug:LogCast(ability, "Target casting")
		end
		cached_ability = ability
		CastSpellByName(ability)
		RoRota.targetCasting = false
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 5. Defensive
	ability = RoRota.GetDefensiveAbility and RoRota:GetDefensiveAbility()
	if ability then
		if RoRota.Debug and RoRota.Debug.enabled then
			RoRota.Debug:LogCast(ability, "Defensive ability")
		end
		cached_ability = ability
		CastSpellByName(ability)
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 6. Opener
	ability = RoRota.GetOpenerAbility and RoRota:GetOpenerAbility()
	if ability then
		if RoRota.Debug and RoRota.Debug.enabled then
			RoRota.Debug:LogCast(ability, "Opener from stealth")
		end
		cached_ability = ability
		CastSpellByName(ability)
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 7. Rotation (planner)
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
		if RoRota.Debug and RoRota.Debug.enabled then
			RoRota.Debug:LogCast(ability, reason or "Rotation decision")
		end
		
		cached_ability = ability
		CastSpellByName(ability)
		
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
	local success, err = pcall(RoRotaRunRotationInternal)
	
	if not success then
		if RoRota.Debug then
			RoRota.Debug:Error("Rotation error", err)
		else
			RoRota:Print("|cFFFF0000[Error]|r Rotation failed: " .. tostring(err))
		end
		
		-- Safe fallback
		if RoRota:HasSpell("Sinister Strike") and RoRota:HasEnoughEnergy("Sinister Strike") then
			CastSpellByName("Sinister Strike")
		end
	end
end
