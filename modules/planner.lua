--[[ planner ]]--
-- Rotation planner decision module.
-- Strategic planning with state simulation and timeline integration.
--
-- Key function:
--   GetRotationAbility() - Returns ability, reason, data or nil
--
-- Features:
--   - Smart Eviscerate (execute at any CP if kills)
--   - CP pacing with timeline deadlines
--   - Builder failsafe
--   - Cold Blood Eviscerate support
--   - Ability queue prediction

if not RoRota then return end
if RoRota.planner then return end

RoRota.Planner = {}
RoRota.PlannerCache = {
	timelineDirty = true,
	lastBuffCheck = 0
}

-- Reason codes for decisions (formatted only when displayed)
local REASON = {
	POOL_DEADLINE = 1,
	POOL_ENERGY = 2,
	SAVE_CP = 3,
	DEADLINE = 4,
	EXPIRING = 5,
	CB_EVIS = 6,
	CP_DUMP = 7,
	CP_OVERFLOW = 8,
	BUILD = 9,
	GHOSTLY = 10,
	TICK_WAIT = 11,
	EXECUTE = 12
}

-- Module state for builder failsafe
local builder_attempts = 0
local last_builder_cast = nil

-- Cold Blood Eviscerate state tracking
local cb_evis_ready = false

function RoRota:ResetBuilderState()
	builder_attempts = 0
	last_builder_cast = nil
end

function RoRota:GetBuilderFailsafeInfo()
	return {
		attempts = builder_attempts,
		lastCast = last_builder_cast,
		threshold = self.db.profile.builderFailsafeAttempts or 3
	}
end

function RoRota:OnBuilderPositionError()
	-- Only increment if NOT in stealth (don't count opener failures)
	if not self:HasPlayerBuff("Stealth") then
		builder_attempts = builder_attempts + 1
	end
end

function RoRota:OnBuilderCast(ability)
	local mainBuilder = self.db.profile.mainBuilder
	local secondaryBuilder = self.db.profile.secondaryBuilder
	if ability == mainBuilder or ability == secondaryBuilder then
		builder_attempts = 0
		last_builder_cast = ability
	end
end

function RoRota:ResetCBEvisState()
	cb_evis_ready = false
end

function RoRota:ShouldRefreshFinisher(finisher, state, cache)
	local finisherKey = finisher
	if finisher == "Slice and Dice" then finisherKey = "SliceAndDice"
	elseif finisher == "Expose Armor" then finisherKey = "ExposeArmor"
	elseif finisher == "Cold Blood Eviscerate" then finisherKey = "ColdBloodEviscerate"
	elseif finisher == "Shadow of Death" then finisherKey = "ShadowOfDeath"
	end
	local cfg = cache.abilities[finisherKey]
	
	if finisher == "Rupture" and cfg and cfg.tasteForBlood and self:IsTargetImmune(finisher) then
		if self:HasPlayerBuff("Taste for Blood") then
			return false
		end
	elseif self:IsTargetImmune(finisher) then
		return false
	end
	
	-- Cold Blood Eviscerate: special handling
	if finisher == "Cold Blood Eviscerate" then
		if not cfg or not cfg.enabled then 
			cb_evis_ready = false
			return false 
		end
		if state.cp < (cfg.minCP or 5) then 
			cb_evis_ready = false
			return false 
		end
		if not self:HasSpell("Cold Blood") then 
			cb_evis_ready = false
			return false 
		end
		-- Check cooldown only if buff is not active
		local cbBuffActive = self:HasPlayerBuff("Cold Blood")
		if not cbBuffActive then
			-- No buff, check if CB is available
			if self:IsOnCooldown("Cold Blood") then 
				cb_evis_ready = false
				return false 
			end
		end
		if state.energy < cache.energyCosts["Eviscerate"] then 
			cb_evis_ready = false
			return false 
		end
		
		-- Target HP check
		local targetMinHP = cfg.targetMinHP or 0
		local targetMaxHP = cfg.targetMaxHP or 100
		if cache.targetHPPct < targetMinHP or cache.targetHPPct > targetMaxHP then
			return false
		end
		
		-- Elite check
		if cfg.onlyElites and not self:IsTargetElite() then
			return false
		end
		
		return true
	end
	
	if not cfg or not cfg.enabled then return false end
	
	-- CP range check
	if finisher == "Eviscerate" then
		-- Eviscerate always requires 5 CP (smartEviscerate execute logic handles lower CP)
		if state.cp < 5 then return false end
	else
		-- All other finishers check minCP/maxCP
		if state.cp < (cfg.minCP or 1) then return false end
		if state.cp > (cfg.maxCP or 5) then return false end
	end
	
	-- Target HP check
	local targetMinHP = cfg.targetMinHP or 0
	local targetMaxHP = cfg.targetMaxHP or 100
	if cache.targetHPPct < targetMinHP or cache.targetHPPct > targetMaxHP then
		return false
	end
	
	-- Elite check
	if cfg.onlyElites and not self:IsTargetElite() then
		return false
	end
	
	if cache.targetHPPct < 15 then
		if finisher == "Rupture" then return false end
		if cache.targetHPPct < 10 and (finisher == "Slice and Dice" or finisher == "Envenom") then return false end
	end
	
	-- Smart Rupture: skip if would overkill
	if finisher == "Rupture" and cache.db.smartRupture and self:WouldOverkill("Rupture", state.cp) then
		return false
	end
	
	if state.energy < cache.energyCosts[finisher] then return false end
	
	local timeRemaining = self:GetBuffTimeRemaining(finisher)
	local threshold = cache.refreshThreshold
	
	local duration = self:CalculateFinisherDuration(finisher, state.cp)
	if timeRemaining > duration * 0.1 and timeRemaining > threshold then
		return false
	end
	
	if timeRemaining <= threshold then return true end
	
	if state.cp == 5 and state.energy >= cache.energyCosts[finisher] + 40 then
		if timeRemaining < 5 then return true end
	end
	
	return false
end

function RoRota:GetOptimalFinisher(state, cache)
	for i, finisher in ipairs(cache.finisherPrio) do
		local shouldUse = self:ShouldRefreshFinisher(finisher, state, cache)
			
			if shouldUse then
				if finisher == "Cold Blood Eviscerate" then
					local hasCBBuff = self:HasPlayerBuff("Cold Blood")
					if hasCBBuff then
						if self:HasPlayerBuff("Stealth") and self:HasSpell("Ambush") then
							return "Ambush", REASON.CB_EVIS, 0
						else
							return "Eviscerate", REASON.CB_EVIS, 0
						end
					else
						return "Cold Blood", REASON.CB_EVIS, 0
					end
				else
					local timeRemaining = self:GetBuffTimeRemaining(finisher)
					return finisher, REASON.EXPIRING, timeRemaining
				end
			end
		end
	
	return nil, nil, 0
end

-- Energy pooling is REMOVED - it caused more problems than it solved
-- The rotation now just builds/spends CPs naturally without complex pooling logic
function RoRota:ShouldPoolEnergy(state, pacing, cache)
	return false, nil, 0
end

function RoRota:GetOptimalFinisherWithTimeline(state, pacing, cache)
	local finisher, reason, data = self:GetOptimalFinisher(state, cache)
	if finisher then
		return finisher, reason, data
	end
	
	-- Fallback: dump CP at 5 with Eviscerate
	if pacing.shouldDump and state.cp >= 5 then
		local cost = cache.energyCosts["Eviscerate"] or 30
		if state.energy >= cost then
			return "Eviscerate", REASON.CP_DUMP, 0
		end
	end
	
	return nil, nil, 0
end

function RoRota:PlanRotation(state)
	-- Update global rotation cache if dirty (optimization #1, #2)
	if self.RotationCache.dirty then
		self:UpdateRotationCache()
	end
	
	-- Build per-call cache with config and dynamic values
	local cache = {
		db = self.db.profile,
		abilities = self.db.profile.abilities or {},
		defensive = self.db.profile.defensive or {},
		finisherPrio = self.db.profile.finisherPriority or {"Slice and Dice", "Rupture", "Envenom", "Expose Armor", "Shadow of Death"},
		refreshThreshold = self.db.profile.finisherRefreshThreshold or 2,
		mainBuilder = state.mainBuilder,
		targetHPPct = UnitHealth("target") / UnitHealthMax("target") * 100,
		playerHPPct = UnitHealth("player") / UnitHealthMax("player") * 100,
		-- Use cached values from global cache
		energyCosts = self.RotationCache.energyCosts,
		maxEnergy = self.RotationCache.maxEnergy,
		ruthlessnessChance = self.RotationCache.ruthlessnessChance
	}
	
	-- Update timeline only when needed (optimization #4)
	local now = GetTime()
	if self.PlannerCache.timelineDirty or (now - self.PlannerCache.lastBuffCheck) > 0.1 then
		self:UpdateTimeline()
		self.PlannerCache.timelineDirty = false
		self.PlannerCache.lastBuffCheck = now
	end
	
	-- Execute phase: Smart Eviscerate (kill at any CP)
	if state.cp >= 1 and cache.db.smartEviscerate and not self:IsTargetImmune("Eviscerate") then
		if self:CanKillWithEviscerate(state.cp) and state.energy >= cache.energyCosts["Eviscerate"] then
			-- Use Cold Blood if configured and available
			local coldBloodMinCP = cache.db.coldBloodMinCP or 4
			if cache.db.useColdBloodEviscerate and state.cp >= coldBloodMinCP then
				if self:HasSpell("Cold Blood") and not self:IsOnCooldown("Cold Blood") and not self:HasPlayerBuff("Cold Blood") then
					return "Cold Blood", REASON.EXECUTE, state.cp
				end
			end
			return "Eviscerate", REASON.EXECUTE, state.cp
		end
	end
	
	local pacing = self:CalculateCPPacing(state)
	
	-- Early exit: CP = 0 always builds (optimization #3)
	if state.cp == 0 then
		return cache.mainBuilder, REASON.BUILD, 1
	end
	
	-- CP overflow prevention: at 5 CP, check if we should wait for deadline
	if state.cp == 5 then
		-- Check if Cold Blood Eviscerate is enabled and high priority
		local cbEvisConfig = cache.abilities.ColdBloodEviscerate
		if cbEvisConfig and cbEvisConfig.enabled and self:HasSpell("Cold Blood") then
			local cbCooldown = self:GetCooldownRemaining("Cold Blood")
			if cbCooldown > 0 and cbCooldown <= 5 then
				-- Check if CB Evis is high priority in the list
				local cbEvisPriority = nil
				for i, finisher in ipairs(cache.finisherPrio) do
					if finisher == "Cold Blood Eviscerate" then
						cbEvisPriority = i
						break
					end
				end
				
				-- If CB Evis is in priority list, wait for it unless energy would overcap
				if cbEvisPriority then
					local maxEnergy = cache.maxEnergy or 100
					local wouldOvercap = state.energy >= (maxEnergy - 20)
					if not wouldOvercap then
						return nil, REASON.SAVE_CP, cbCooldown
					end
				end
			end
		end
		
		-- Don't use finisher if deadline expires within 5s (wait for refresh)
		-- UNLESS: high energy risks overcap OR deadline finisher can't be used at current CP
		if pacing.deadline and not pacing.deadline.virtual and pacing.deadline.expiresIn > 0 and pacing.deadline.expiresIn <= 5 then
			local deadlineFinisher = pacing.deadline.name
			local finisherKey = deadlineFinisher
			if deadlineFinisher == "Slice and Dice" then finisherKey = "SliceAndDice"
			elseif deadlineFinisher == "Expose Armor" then finisherKey = "ExposeArmor"
			end
			local deadlineCfg = cache.abilities[finisherKey]
			
			-- Check if deadline finisher can be used at current CP
			local canUseAtCurrentCP = false
			if deadlineCfg then
				local minCP = deadlineCfg.minCP or 1
				local maxCP = deadlineCfg.maxCP or 5
				canUseAtCurrentCP = state.cp >= minCP and state.cp <= maxCP
			end
			
			-- Only wait if deadline finisher can be used at current CP AND won't overcap
			if canUseAtCurrentCP then
				local maxEnergy = cache.maxEnergy or 100
				local wouldOvercap = state.energy >= (maxEnergy - 20)
				if not wouldOvercap then
					return nil, REASON.SAVE_CP, pacing.deadline.expiresIn
				end
			end
		end
		
		local finisher, reason, data = self:GetOptimalFinisherWithTimeline(state, pacing, cache)
		if finisher then
			return finisher, reason, data
		end
	end
	
	local finisher, reason, data = self:GetOptimalFinisherWithTimeline(state, pacing, cache)
	if finisher then
		return finisher, reason, data
	end
	
	-- If saving CP for deadline, return early (don't fall through to fallback)
	if reason == REASON.SAVE_CP then
		return nil, reason, data
	end
	
	-- Build phase: CP < 5, need to build
	if state.cp < 5 then
		if cache.defensive.useRiposte and self.riposteAvailable and (GetTime() - self.riposteAvailable) < 5 then
			if self:HasSpell("Riposte") and self:HasEnoughEnergy("Riposte") and not self:IsOnCooldown("Riposte") then
				local targetMinHP = cache.defensive.riposteTargetMinHP or 0
				local targetMaxHP = cache.defensive.riposteTargetMaxHP or 100
				if cache.targetHPPct >= targetMinHP and cache.targetHPPct <= targetMaxHP then
					return "Riposte", REASON.BUILD, state.cp + 1
				end
			end
		end
		
		if cache.defensive.useSurpriseAttack and self.surpriseAttackAvailable and (GetTime() - self.surpriseAttackAvailable) < 5 then
			if self:HasSpell("Surprise Attack") and self:HasEnoughEnergy("Surprise Attack") and not self:IsOnCooldown("Surprise Attack") then
				local targetMinHP = cache.defensive.surpriseTargetMinHP or 0
				local targetMaxHP = cache.defensive.surpriseTargetMaxHP or 100
				if cache.targetHPPct >= targetMinHP and cache.targetHPPct <= targetMaxHP then
					return "Surprise Attack", REASON.BUILD, state.cp + 2
				end
			end
		end
		
		if cache.abilities.MarkForDeath and cache.abilities.MarkForDeath.enabled then
			if self:HasSpell("Mark for Death") and self:HasEnoughEnergy("Mark for Death") and not self:IsOnCooldown("Mark for Death") then
				local targetMinHP = cache.abilities.MarkForDeath.targetMinHP or 0
				local targetMaxHP = cache.abilities.MarkForDeath.targetMaxHP or 100
				if cache.targetHPPct >= targetMinHP and cache.targetHPPct <= targetMaxHP then
					if cache.abilities.MarkForDeath.onlyElites and not self:IsTargetElite() then
					else
						return "Mark for Death", REASON.BUILD, state.cp + 2
					end
				end
			end
		end
		
		if cache.abilities.Hemorrhage and cache.abilities.Hemorrhage.enabled then
			if self:HasSpell("Hemorrhage") and self:HasEnoughEnergy("Hemorrhage") then
				local targetMinHP = cache.abilities.Hemorrhage.targetMinHP or 0
				local targetMaxHP = cache.abilities.Hemorrhage.targetMaxHP or 100
				if cache.targetHPPct >= targetMinHP and cache.targetHPPct <= targetMaxHP then
					if cache.abilities.Hemorrhage.onlyElites and not self:IsTargetElite() then
					else
						local shouldUse = true
						if cache.abilities.Hemorrhage.onlyWhenMissing then
							shouldUse = not self:HasTargetDebuff("Hemorrhage")
						end
						if shouldUse then
							return "Hemorrhage", REASON.BUILD, state.cp + 1
						end
					end
				end
			end
		end
		
		if cache.defensive.useGhostlyStrike and self:HasSpell("Ghostly Strike") and not self:IsOnCooldown("Ghostly Strike") and not self:IsTargetImmune("Ghostly Strike") then
			if state.energy >= cache.energyCosts["Ghostly Strike"] then
				if cache.targetHPPct <= (cache.defensive.ghostlyTargetMaxHP or 100) and 
				   cache.playerHPPct >= (cache.defensive.ghostlyPlayerMinHP or 0) and 
				   cache.playerHPPct <= (cache.defensive.ghostlyPlayerMaxHP or 100) then
					return "Ghostly Strike", REASON.GHOSTLY, 0
				end
			end
		end
		
		local builder = cache.mainBuilder
		local failsafeThreshold = cache.db.builderFailsafeAttempts or 3
		if builder_attempts >= failsafeThreshold and cache.db.secondaryBuilder then
			builder = cache.db.secondaryBuilder
		end
		local builderCost = cache.energyCosts[builder] or 40
		
		-- Check immunity before using builder
		if self:IsTargetImmune(builder) then
			-- Try secondary builder if main is immune
			if cache.db.secondaryBuilder and not self:IsTargetImmune(cache.db.secondaryBuilder) then
				builder = cache.db.secondaryBuilder
				builderCost = cache.energyCosts[builder] or 40
				builder_attempts = 0
			else
				return nil, REASON.BUILD, 0
			end
		end
		
		-- Check if we have energy for builder
		if state.energy >= builderCost then
			-- Smart builders: check swing timer
			if cache.db.smartBuilders and (builder == "Sinister Strike" or builder == "Backstab" or builder == "Noxious Assault") then
				if self.SwingTimer and not self.SwingTimer:CanUseBuilder() then
					return nil, REASON.TICK_WAIT, 0
				end
			end
			
			return builder, REASON.BUILD, state.cp + 1
		end
		
		-- Not enough energy: DON'T increment failsafe counter, just wait
		return nil, REASON.TICK_WAIT, 0
	end
	
	-- Fallback: dump CP at 5 with Eviscerate
	if state.cp >= 5 and not self:IsTargetImmune("Eviscerate") then
		local cost = cache.energyCosts["Eviscerate"] or 30
		if state.energy >= cost then
			return "Eviscerate", REASON.CP_DUMP, 0
		end
	end
	
	return nil, nil, 0
end

-- Simple lookahead: predict next N abilities (ignores energy)
function RoRota:PredictNextAbilities(count)
	local queue = {}
	local cp = GetComboPoints("player", "target")
	local mainBuilder = self.db.profile.mainBuilder or "Sinister Strike"
	local isStealthed = self:HasPlayerBuff("Stealth")
	
	-- If stealthed, show opener sequence (skip Pick Pocket)
	if isStealthed then
		local openerCfg = self.db.profile.opener or {}
		local opener = openerCfg.ability
		local idx = 1
		
		-- Skip Pick Pocket
		if opener == "Pick Pocket" then
			opener = openerCfg.secondaryOpener or "Garrote"
		end
		
		-- Cold Blood before Ambush (check cooldown AND buff)
		local hasCBBuff = self:HasPlayerBuff("Cold Blood")
		local cbOnCooldown = self:IsOnCooldown("Cold Blood")
		if openerCfg.useColdBlood and opener == "Ambush" and self:HasSpell("Cold Blood") and not hasCBBuff and not cbOnCooldown then
			queue[idx] = "Cold Blood"
			idx = idx + 1
		end
		
		-- Opener ability
		if opener and idx <= (count or 3) then
			queue[idx] = opener
			idx = idx + 1
			-- Calculate CP from opener (with talent support)
			cp = cp + (self:GetAbilityCP(opener) or 1)
		end
		
		-- Fill rest with builder/finisher logic
		for i = idx, (count or 3) do
			if cp >= 5 then
				queue[i] = "Eviscerate"
				cp = 0
			else
				queue[i] = mainBuilder
				cp = cp + 1
			end
		end
		
		return queue
	end
	
	-- Normal rotation: builder/finisher logic (ignores energy)
	for i = 1, (count or 3) do
		if cp >= 5 then
			queue[i] = "Eviscerate"
			cp = 0
		else
			queue[i] = mainBuilder
			cp = cp + 1
		end
	end
	
	return queue
end

-- Format reason codes into human-readable strings
function RoRota:FormatPlanReason(reason, data, finisher)
	if not reason then return nil end
	
	if reason == REASON.POOL_DEADLINE then
		return string.format("Pooling for %s (%.1fs)", finisher or "finisher", data)
	elseif reason == REASON.POOL_ENERGY then
		return "Pooling energy"
	elseif reason == REASON.SAVE_CP then
		return string.format("Saving CP for %s deadline", finisher or "finisher")
	elseif reason == REASON.DEADLINE then
		return string.format("%s deadline (%.1fs)", finisher or "finisher", data)
	elseif reason == REASON.EXPIRING then
		return string.format("%s expires in %.0fs", finisher or "finisher", data)
	elseif reason == REASON.CB_EVIS then
		return "Cold Blood Eviscerate ready"
	elseif reason == REASON.CP_DUMP then
		return "CP dump: " .. (finisher or "Eviscerate")
	elseif reason == REASON.CP_OVERFLOW then
		return "CP overflow prevention (will get 1 CP back)"
	elseif reason == REASON.BUILD then
		return string.format("Build to %d CP", data)
	elseif reason == REASON.GHOSTLY then
		return "Conditional builder"
	elseif reason == REASON.TICK_WAIT then
		return string.format("Tick in %.1fs (avoid cap)", data)
	elseif reason == REASON.EXECUTE then
		return string.format("Execute: Kill with %d CP", data)
	end
	
	return "Unknown"
end

-- Helper: Create state snapshot for planning
function RoRota:CreateSimulatedState()
	local state = {
		cp = GetComboPoints("player", "target"),
		energy = UnitMana("player"),
		mainBuilder = self.db.profile.mainBuilder or "Sinister Strike",
	}
	return state
end

-- Helper: Calculate finisher duration based on CP
function RoRota:CalculateFinisherDuration(finisher, cp)
	if finisher == "Slice and Dice" then
		local duration = 6 + (cp * 3)
		if self.TalentCache and self.TalentCache.improvedBladeTactics then
			duration = duration * (1 + (self.TalentCache.improvedBladeTactics * 0.15))
		end
		return duration
	elseif finisher == "Envenom" then
		return 8 + (cp * 4)
	elseif finisher == "Rupture" then
		local duration = 6 + (cp * 2)
		if self.TalentCache and self.TalentCache.tasteForBlood then
			duration = duration + (self.TalentCache.tasteForBlood * 2)
		end
		return duration
	elseif finisher == "Expose Armor" then
		return 30
	end
	return 0
end

-- Main rotation entry point (called by rotation.lua)
function RoRota:GetRotationAbility()
	if not self.PlanRotation then 
		return nil 
	end
	
	local state = self:CreateSimulatedState()
	local ability, reason, data = self:PlanRotation(state)
	local reasonText = self:FormatPlanReason(reason, data, ability)
	
	return ability, reasonText, data
end

RoRota.planner = true

