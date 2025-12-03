--[[ rotation ]]--
-- Rotation orchestrator with extracted decision logic.
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

-- Extract decision logic into separate functions
function RoRota:DecideAbility()
	-- Priority order: Interrupt → Defensive → Cooldowns → Opener → Rotation
	
	if self.GetInterruptAbility then
		local ability = self:GetInterruptAbility()
		if ability then return ability, "Interrupt" end
	end
	
	if self.GetDefensiveAbility then
		local ability = self:GetDefensiveAbility()
		if ability then return ability, "Defensive" end
	end
	
	if self.GetCooldownAbility then
		local ability = self:GetCooldownAbility()
		if ability then return ability, "Cooldown" end
	end
	
	if self.GetOpenerAbility then
		local ability = self:GetOpenerAbility()
		if ability then return ability, "Opener" end
	end
	
	if self.GetRotationAbility then
		local ability = self:GetRotationAbility()
		if ability then return ability, "Rotation" end
	end
	
	return nil, nil
end

function RoRota:CanCastAbility(ability)
	if not ability then return false end
	
	-- Check if ability is off-GCD
	if RoRotaStateMachine and RoRotaStateMachine.offGCDAbilities[ability] then
		return true
	end
	
	-- Check if on GCD
	if RoRotaStateMachine and RoRotaStateMachine:IsOnGCD() then
		return false
	end
	
	return true
end

function RoRota:CastAbility(ability, reason)
	if not ability then return false end
	
	self.lastAbilityCast = ability
	self.lastAbilityTime = GetTime()
	
	CastSpellByName(self:T(ability))
	
	-- Update state machine
	if RoRotaStateMachine then
		RoRotaStateMachine:CastAbility(ability)
	end
	
	-- Log cast
	if self.Debug and self.Debug.enabled then
		self.Debug:LogCast(ability, reason or "Cast")
	end
	
	-- Update finisher timers
	if self.IsFinisher and self:IsFinisher(ability) and self.UpdateFinisherTimer then
		local cp = self.Cache and self.Cache.comboPoints or GetComboPoints("player", "target")
		self:UpdateFinisherTimer(ability, cp)
	end
	
	return true
end

-- Internal rotation logic
local function RoRotaRunRotationInternal()
	local now = GetTime()
	
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
	
	-- 3. No target: apply poisons first, then auto-target
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
	
	-- 4. Target switch: reset state
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
		
		if RoRota.StartTTKTracking then
			local success, err = pcall(RoRota.StartTTKTracking, RoRota)
			if not success then
				-- Silent fail
			end
		end
	end
	
	-- 5. Stealth detection
	local isStealthed = RoRota.Cache and RoRota.Cache.stealthed or false
	if isStealthed and not was_stealthed then
		if RoRota.ResetOpenerState then RoRota:ResetOpenerState() end
	end
	was_stealthed = isStealthed
	
	-- 6. Check for immunity buffs (skip damaging abilities)
	if RoRota.TargetHasImmunityBuff and RoRota:TargetHasImmunityBuff() then
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 7. Decide ability using extracted logic
	local ability, reason = RoRota:DecideAbility()
	
	if ability then
		-- Check if we can cast
		if not RoRota:CanCastAbility(ability) then
			if RoRota.Debug then RoRota.Debug:EndTimer() end
			return
		end
		
		-- Cast ability
		RoRota:CastAbility(ability, reason)
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
	
	local ability, reason = self:DecideAbility()
	if ability then return ability end
	
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
