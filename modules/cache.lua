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
	healthPercent = 100,
	targetHealthPercent = 100,
	
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
	self.healthPercent = (UnitHealth("player") / UnitHealthMax("player")) * 100
	
	-- Stealth detection (use tooltip for accuracy)
	self.stealthed = false
	if RoRota.HasPlayerBuff then
		self.stealthed = RoRota:HasPlayerBuff("Stealth")
	end
	
	-- Target health
	if self.hasTarget then
		self.targetHealthPercent = (UnitHealth("target") / UnitHealthMax("target")) * 100
	else
		self.targetHealthPercent = 100
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