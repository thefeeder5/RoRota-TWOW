--[[ planner ]]--
-- Strategic rotation planner that simulates future states.
-- Makes decisions about finisher timing, energy pooling, and CP overflow.

if RoRota.planner then return end

RoRota.Planner = {
	predictedCP = 0,
	predictedEnergy = 0,
	recommendation = nil,
	reason = nil,
	nextAbility = nil,
}

function RoRota:SimulateAbility(ability, cp, energy)
	local energyCost = self:GetEnergyCost(ability)
	local newCP = cp
	local newEnergy = energy - energyCost
	
	-- Vigor talent: energy refund on poison application (50% chance per rank)
	if self.TalentCache and self.TalentCache.vigor > 0 then
		local poisonApps = 0
		if ability == "Noxious Assault" then
			poisonApps = 2  -- applies poison from both hands
		end
		
		if poisonApps > 0 then
			local refundChance = self.TalentCache.vigor * 0.5  -- 50% per rank
			local expectedRefund = poisonApps * 2 * refundChance  -- 2 energy per proc
			newEnergy = newEnergy + expectedRefund
		end
	end
	
	-- Calculate energy regen based on tick time
	local energyPerTick = RoRotaConstants.ENERGY_PER_TICK
	local tickTime = RoRotaConstants.ENERGY_TICK_TIME
	
	-- Blade Rush: 1 agility = 1ms faster tick (no cap)
	if self.TalentCache and self.TalentCache.bladeRush and self.TalentCache.bladeRush > 0 then
		local _, agility = UnitStat("player", 2)
		local agiReduction = agility * 0.001  -- 1ms per agi
		tickTime = math.max(0.5, tickTime - agiReduction)  -- minimum 0.5s tick time
	end
	
	-- Adrenaline Rush: 40 energy per tick instead of 20
	if self:HasAdrenalineRush() then
		energyPerTick = 40
	end
	
	-- Calculate energy gained during GCD (assume 2s GCD)
	-- Energy per second = energyPerTick / tickTime
	-- Energy during 2s GCD = (energyPerTick / tickTime) * 2
	local gcdTime = 2.0
	local energyRegen = (energyPerTick / tickTime) * gcdTime
	
	-- Vigor talent increases max energy
	local maxEnergy = 100
	if self.TalentCache and self.TalentCache.vigor and self.TalentCache.vigor > 0 then
		maxEnergy = 110
	end
	
	newEnergy = math.min(maxEnergy, math.max(0, newEnergy + energyRegen))
	
	if self:IsFinisher(ability) then
		-- Ruthlessness: chance for 1 CP after finisher
		local ruthlessnessChance = self:GetRuthlessnessChance()
		if ruthlessnessChance >= 1.0 then
			newCP = 1
		elseif ruthlessnessChance > 0 then
			newCP = ruthlessnessChance  -- show decimal (e.g., 0.66 for 2/3)
		else
			newCP = 0
		end
	else
		-- Use CalculateExpectedCP for builders (accounts for Seal Fate, etc.)
		newCP = self:CalculateExpectedCP(ability, cp)
	end
	
	return newCP, newEnergy
end

function RoRota:ShouldRefreshFinisher(finisher, cp, energy, timeRemaining)
	local db = self.db.profile
	local abilitiesCfg = db.abilities or {}
	local finisherKey = finisher
	if finisher == "Slice and Dice" then finisherKey = "SliceAndDice"
	elseif finisher == "Expose Armor" then finisherKey = "ExposeArmor"
	end
	local cfg = abilitiesCfg[finisherKey]
	
	if not cfg or not cfg.enabled then return false end
	if cp < (cfg.minCP or 1) or cp > (cfg.maxCP or 5) then return false end
	if not self:HasEnoughEnergy(finisher) then return false end
	
	-- Priority 1: Finisher not active or about to expire
	local threshold = db.finisherRefreshThreshold or 2
	if timeRemaining <= threshold then return true end
	
	-- Priority 2: At 5 CP with good energy, refresh early if <5s remaining
	if cp == 5 and energy >= self:GetEnergyCost(finisher) + 40 then
		if timeRemaining < 5 then return true end
	end
	
	return false
end

function RoRota:GetOptimalFinisher(cp, energy)
	local db = self.db.profile
	local abilitiesCfg = db.abilities or {}
	local finisherPrio = db.finisherPriority or {"Slice and Dice", "Rupture", "Envenom", "Expose Armor"}
	
	for i, finisher in ipairs(finisherPrio) do
		local timeRemaining = 0
		
		if finisher == "Slice and Dice" then
			timeRemaining = self:GetBuffTimeRemaining("Slice and Dice")
		elseif finisher == "Envenom" then
			timeRemaining = self:GetBuffTimeRemaining("Envenom")
		elseif finisher == "Rupture" then
			timeRemaining = self:GetDebuffTimeRemaining("Rupture")
		elseif finisher == "Expose Armor" then
			timeRemaining = self:GetDebuffTimeRemaining("Expose Armor")
		end
		
		local shouldUse = self:ShouldRefreshFinisher(finisher, cp, energy, timeRemaining)
		if self.Debug and self.Debug.enabled then
			self.Debug:Log(string.format("Planner check %s: time=%.0f, shouldUse=%s, cp=%d", finisher, timeRemaining, tostring(shouldUse), cp))
		end
		
		if shouldUse then
			return finisher, string.format("%s expires in %.0fs", finisher, timeRemaining)
		end
	end
	
	return nil, nil
end

function RoRota:ShouldPoolEnergy(cp, energy)
	if cp < 5 then return false end
	if self:HasAdrenalineRush() then return false end
	
	local db = self.db.profile
	local energyCfg = db.energyPooling or {}
	if not energyCfg.enabled then return false end
	
	-- Check if any finisher needs refresh soon
	local finisher, reason = self:GetOptimalFinisher(cp, energy)
	if finisher then
		-- Don't pool if finisher is ready
		return false
	end
	
	-- Check if we have enough energy for any finisher
	local hasEnergyForFinisher = false
	local finisherPrio = db.finisherPriority or {"Slice and Dice", "Rupture", "Envenom", "Expose Armor"}
	for _, f in ipairs(finisherPrio) do
		if self:HasEnoughEnergy(f) then
			hasEnergyForFinisher = true
			break
		end
	end
	
	if not hasEnergyForFinisher then
		return true, "Pooling for finisher energy"
	end
	
	-- All buffs/debuffs active, pool to avoid wasting CP
	return true, "All finishers active, pooling"
end

function RoRota:PlanRotation(cp, energy)
	self.Planner.predictedCP = cp
	self.Planner.predictedEnergy = energy
	self.Planner.recommendation = nil
	self.Planner.reason = nil
	self.Planner.nextAbility = nil
	
	-- Check for finisher
	local finisher, reason = self:GetOptimalFinisher(cp, energy)
	if finisher then
		local newCP, newEnergy = self:SimulateAbility(finisher, cp, energy)
		self.Planner.predictedCP = newCP
		self.Planner.predictedEnergy = newEnergy
		self.Planner.recommendation = finisher
		self.Planner.reason = reason
		
		-- Plan next ability after finisher
		local nextFinisher = self:GetOptimalFinisher(math.floor(newCP), newEnergy)
		if nextFinisher then
			self.Planner.nextAbility = nextFinisher
		end
		
		return finisher, reason
	end
	
	-- Check if should pool
	local shouldPool, poolReason = self:ShouldPoolEnergy(cp, energy)
	if shouldPool then
		self.Planner.recommendation = "Pool"
		self.Planner.reason = poolReason
		return nil, poolReason
	end
	
	-- Use builder
	local db = self.db.profile
	local builder = db.mainBuilder or "Sinister Strike"
	local newCP, newEnergy = self:SimulateAbility(builder, cp, energy)
	self.Planner.predictedCP = newCP
	self.Planner.predictedEnergy = newEnergy
	self.Planner.recommendation = builder
	self.Planner.reason = string.format("Build to %.1f CP", newCP)
	
	return builder, self.Planner.reason
end

RoRota.planner = true
