--[[ cache ]]--
-- Performance cache layer for state values.
-- Reduces WoW API calls by caching frequently accessed values.
--
-- Key functions:
--   Update() - Refresh all cached values (throttled)
--   GetCachedState() - Returns cached state snapshot
--   InvalidateOn(event) - Mark cache entries dirty on events
--   GetBuffTime(name) - Get buff time with TTL
--   GetDebuffTime(name) - Get debuff time with TTL
--   GetEquippedWeapon(slot) - Get equipped weapon with TTL

if not RoRota then return end
if RoRota.cache then return end

RoRota.Cache = {
	lastUpdate = 0,
	throttleInterval = 0.1,
	dirty = false,
	
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
	
	-- Buff/Debuff time caches
	buffTimes = {},
	debuffTimes = {},
	buffTimesLastUpdate = 0,
	debuffTimesLastUpdate = 0,
	
	-- Equipment cache
	equipment = {},
	equipmentLastUpdate = 0,
	
	-- Stats
	hits = 0,
	misses = 0,
	
	-- Invalidation map
	invalidationMap = {
		["UNIT_AURA"] = {"buffTimes", "debuffTimes"},
		["PLAYER_REGEN_DISABLED"] = {"inCombat"},
		["PLAYER_REGEN_ENABLED"] = {"inCombat"},
		["ITEM_LOCK_CHANGED"] = {"equipment"},
	},
}

function RoRota.Cache:InvalidateOn(event)
	local entries = self.invalidationMap[event]
	if not entries then return end
	
	for _, entry in ipairs(entries) do
		if entry == "buffTimes" then
			for k in pairs(self.buffTimes) do
				self.buffTimes[k] = nil
			end
			self.buffTimesLastUpdate = 0
		elseif entry == "debuffTimes" then
			for k in pairs(self.debuffTimes) do
				self.debuffTimes[k] = nil
			end
			self.debuffTimesLastUpdate = 0
		elseif entry == "inCombat" then
			self.dirty = true
		elseif entry == "equipment" then
			for k in pairs(self.equipment) do
				self.equipment[k] = nil
			end
			self.equipmentLastUpdate = 0
		end
	end
end

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

function RoRota.Cache:GetBuffTime(buffName)
	if not buffName then return 0 end
	
	local now = GetTime()
	local ttl = RoRotaConstants.CACHE_TTL_BUFF_DEBUFF or 0.1
	
	-- Check if cached and not expired
	if self.buffTimes[buffName] and (now - self.buffTimesLastUpdate) < ttl then
		return self.buffTimes[buffName]
	end
	
	-- Query WoW API
	local i = 1
	while true do
		local name = UnitBuff("player", i)
		if not name then break end
		if name == buffName then
			local _, _, _, _, _, duration, expirationTime = UnitBuff("player", i)
			local timeRemaining = expirationTime - GetTime()
			self.buffTimes[buffName] = math.max(0, timeRemaining)
			self.buffTimesLastUpdate = now
			return self.buffTimes[buffName]
		end
		i = i + 1
	end
	
	-- Buff not found
	self.buffTimes[buffName] = 0
	self.buffTimesLastUpdate = now
	return 0
end

function RoRota.Cache:GetDebuffTime(debuffName)
	if not debuffName then return 0 end
	
	local now = GetTime()
	local ttl = RoRotaConstants.CACHE_TTL_BUFF_DEBUFF or 0.1
	
	-- Check if cached and not expired
	if self.debuffTimes[debuffName] and (now - self.debuffTimesLastUpdate) < ttl then
		return self.debuffTimes[debuffName]
	end
	
	-- Query WoW API
	local i = 1
	while true do
		local name = UnitDebuff("target", i)
		if not name then break end
		if name == debuffName then
			local _, _, _, _, _, duration, expirationTime = UnitDebuff("target", i)
			local timeRemaining = expirationTime - GetTime()
			self.debuffTimes[debuffName] = math.max(0, timeRemaining)
			self.debuffTimesLastUpdate = now
			return self.debuffTimes[debuffName]
		end
		i = i + 1
	end
	
	-- Debuff not found
	self.debuffTimes[debuffName] = 0
	self.debuffTimesLastUpdate = now
	return 0
end

function RoRota.Cache:GetEquippedWeapon(slot)
	if not slot then return nil end
	
	local now = GetTime()
	local ttl = RoRotaConstants.CACHE_TTL_EQUIPMENT or 1.0
	
	-- Check if cached and not expired
	if self.equipment[slot] and (now - self.equipmentLastUpdate) < ttl then
		return self.equipment[slot]
	end
	
	-- Query WoW API
	local itemLink = GetInventoryItemLink("player", slot)
	if itemLink then
		local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemLink)
		self.equipment[slot] = {
			link = itemLink,
			type = itemType,
			subType = itemSubType,
		}
		self.equipmentLastUpdate = now
		return self.equipment[slot]
	end
	
	-- No item equipped
	self.equipment[slot] = nil
	self.equipmentLastUpdate = now
	return nil
end

RoRota.cache = true
