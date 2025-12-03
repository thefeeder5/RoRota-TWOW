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

-- Initialize state if needed
if not RoRota.State then RoRota.State = {} end
if not RoRota.State.lastTarget then RoRota.State.lastTarget = nil end
if not RoRota.State.wasStealthed then RoRota.State.wasStealthed = false end

-- Manual timer tracking (fallback)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
RoRota.exposeArmorExpiry = 0
RoRota.exposeArmorTarget = nil

-- Inline rotation decision logic (subtasks 8-10 reverted)
function RoRota:DecideAbility()
	-- Interrupt
	if self:IsTargetCasting() then
		if self:HasSpell("Kick") and self:HasEnoughEnergy("Kick") and not self:IsOnCooldown("Kick") then
			return "Kick"
		end
	end
	
	-- Opener
	if self:HasPlayerBuff("Stealth") and self:HasSpell("Ambush") then
		return "Ambush"
	end
	
	-- Rotation
	if self.PlanRotation then
		local state = self:CreateSimulatedState()
		local ability = self:PlanRotation(state)
		return ability
	end
	
	return nil
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
	if targetName ~= RoRota.State.lastTarget then
		RoRota.State.lastTarget = targetName
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
	if isStealthed and not RoRota.State.wasStealthed then
		if RoRota.ResetOpenerState then RoRota:ResetOpenerState() end
	end
	RoRota.State.wasStealthed = isStealthed
	
	-- 6. Check for immunity buffs (skip damaging abilities)
	if RoRota.TargetHasImmunityBuff and RoRota:TargetHasImmunityBuff() then
		if RoRota.Debug then RoRota.Debug:EndTimer() end
		return
	end
	
	-- 7. Decide ability
	local ability = RoRota:DecideAbility()
	
	if ability then
		RoRota.lastAbilityCast = ability
		RoRota.lastAbilityTime = GetTime()
		CastSpellByName(RoRota:T(ability))
		
		if RoRota.IsFinisher and RoRota:IsFinisher(ability) and RoRota.UpdateFinisherTimer then
			local cp = RoRota.Cache and RoRota.Cache.comboPoints or GetComboPoints("player", "target")
			RoRota:UpdateFinisherTimer(ability, cp)
		end
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
