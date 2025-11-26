--[[ cache ]]--
-- Performance cache layer for state values.
-- Reduces WoW API calls by caching frequently accessed values.
--
-- Key functions:
--   Update() - Refresh all cached values (throttled)
--   GetCachedState() - Returns cached state snapshot
--   InvalidateCache() - Force cache refresh on next Update()

if not RoRota then return end
if RoRota.cache then return end

RoRota.Cache = {
	lastUpdate = 0,
	throttleInterval = 0.1,
	
	-- Cached values
	energy = 0,
	comboPoints = 0,
	hasTarget = false,
	targetName = nil,
	inCombat = false,
	stealthed = false,
	autoAttacking = false,
	healthPercent = 100,
	targetHealthPercent = 100,
	targetHealth = 0,
	targetHealthMax = 1,
	playerHealth = 0,
	playerHealthMax = 1,
	
	-- Stats
	hits = 0,
	misses = 0,
}

function RoRota.Cache:Update()
	local now = GetTime()
	
	-- Throttle updates
	if now - self.lastUpdate < self.throttleInterval then
		self.hits = self.hits + 1
		return false
	end
	
	self.misses = self.misses + 1
	self.lastUpdate = now
	
	-- Update cached values
	self.energy = UnitMana("player")
	self.comboPoints = GetComboPoints("player", "target")
	self.hasTarget = UnitExists("target") and not UnitIsDead("target")
	self.targetName = self.hasTarget and UnitName("target") or nil
	self.inCombat = UnitAffectingCombat("player")
	
	-- Player health (absolute and percent)
	self.playerHealth = UnitHealth("player")
	self.playerHealthMax = UnitHealthMax("player")
	self.healthPercent = (self.playerHealth / self.playerHealthMax) * 100
	
	-- Stealth detection (use tooltip for accuracy)
	self.stealthed = false
	if RoRota.HasPlayerBuff then
		self.stealthed = RoRota:HasPlayerBuff("Stealth")
	end
	
	-- Auto-attack detection (check if currently attacking)
	self.autoAttacking = IsCurrentAction(1) or UnitAffectingCombat("player")
	
	-- Target health (absolute and percent)
	if self.hasTarget then
		self.targetHealth = UnitHealth("target")
		self.targetHealthMax = UnitHealthMax("target")
		self.targetHealthPercent = (self.targetHealth / self.targetHealthMax) * 100
	else
		self.targetHealth = 0
		self.targetHealthMax = 1
		self.targetHealthPercent = 100
	end
	
	-- TTK tracking
	if RoRota.UpdateTTKSample then
		local success, err = pcall(RoRota.UpdateTTKSample, RoRota)
		if not success then
			-- Silent fail
		end
	end
	
	return true
end

function RoRota.Cache:GetCachedState()
	return {
		energy = self.energy,
		comboPoints = self.comboPoints,
		hasTarget = self.hasTarget,
		targetName = self.targetName,
		inCombat = self.inCombat,
		stealthed = self.stealthed,
		autoAttacking = self.autoAttacking,
		healthPercent = self.healthPercent,
		targetHealthPercent = self.targetHealthPercent,
	}
end

function RoRota.Cache:InvalidateCache()
	self.lastUpdate = 0
end

function RoRota.Cache:GetStats()
	local total = self.hits + self.misses
	local hitRate = total > 0 and (self.hits / total * 100) or 0
	return {
		hits = self.hits,
		misses = self.misses,
		total = total,
		hitRate = hitRate,
	}
end

RoRota.cache = true