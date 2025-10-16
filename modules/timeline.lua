--[[ timeline ]]--
-- Pure finisher timeline calculations.
-- Tracks finisher expiration times and planning windows.
--
-- Key functions:
--   UpdateTimeline() - Scan and calculate timeline
--   GetNextDeadline() - Get next expiring finisher
--   GetPlanningWindow(finisher, duration) - Calculate planning window
--   UpdateFinisherTimer(ability, cp) - Update manual timer tracking

if not RoRota then return end
if RoRota.timeline then return end

RoRota.Timeline = {
	finishers = {},
	nextDeadline = nil,
	lastUpdate = 0,
}

-- Manual timer tracking (fallback when SuperWoW API unavailable)
RoRota.sndExpiry = 0
RoRota.envenomExpiry = 0
RoRota.ruptureExpiry = 0
RoRota.ruptureTarget = nil
RoRota.exposeArmorExpiry = 0
RoRota.exposeArmorTarget = nil

function RoRota:UpdateTimeline()
	local now = GetTime()
	local db = self.db.profile
	local finisherPrio = db.finisherPriority or {"Slice and Dice", "Rupture", "Envenom", "Expose Armor"}
	
	local activeFinishers = {}
	
	for i, finisherName in ipairs(finisherPrio) do
		local finisherKey = finisherName
		if finisherName == "Slice and Dice" then finisherKey = "SliceAndDice"
		elseif finisherName == "Expose Armor" then finisherKey = "ExposeArmor"
		end
		
		local cfg = db.abilities and db.abilities[finisherKey]
		if cfg and cfg.enabled then
			local timeRemaining = 0
			
			if finisherName == "Slice and Dice" then
				timeRemaining = self:GetBuffTimeRemaining("Slice and Dice")
			elseif finisherName == "Envenom" then
				timeRemaining = self:GetBuffTimeRemaining("Envenom")
			elseif finisherName == "Rupture" then
				timeRemaining = self:GetDebuffTimeRemaining("Rupture")
			elseif finisherName == "Expose Armor" then
				timeRemaining = self:GetDebuffTimeRemaining("Expose Armor")
			end
			
			if timeRemaining > 0 then
				local planningWindow = self:GetPlanningWindow(finisherName, timeRemaining)
				
				table.insert(activeFinishers, {
					name = finisherName,
					priority = i,
					expiresAt = now + timeRemaining,
					expiresIn = timeRemaining,
					duration = timeRemaining,
					planningWindow = planningWindow,
					inPlanningWindow = timeRemaining <= planningWindow,
				})
			end
		end
	end
	
	table.sort(activeFinishers, function(a, b)
		if math.abs(a.expiresIn - b.expiresIn) < 2 then
			return a.priority < b.priority
		else
			return a.expiresIn < b.expiresIn
		end
	end)
	
	local nextDeadline = nil
	for _, f in ipairs(activeFinishers) do
		if f.inPlanningWindow or f.expiresIn <= 5 then
			nextDeadline = f
			break
		end
	end
	
	if not nextDeadline and table.getn(activeFinishers) > 0 then
		nextDeadline = activeFinishers[1]
	end
	
	-- If no active finishers, create virtual deadline for highest priority missing finisher
	if not nextDeadline then
		for i, finisherName in ipairs(finisherPrio) do
			local finisherKey = finisherName
			if finisherName == "Slice and Dice" then finisherKey = "SliceAndDice"
			elseif finisherName == "Expose Armor" then finisherKey = "ExposeArmor"
			end
			local cfg = db.abilities and db.abilities[finisherKey]
			if cfg and cfg.enabled then
				nextDeadline = {
					name = finisherName,
					priority = i,
					expiresAt = 0,
					expiresIn = 0,
					duration = 0,
					planningWindow = 999,
					inPlanningWindow = false,
					virtual = true,
				}
				break
			end
		end
	end
	
	self.Timeline.finishers = activeFinishers
	self.Timeline.nextDeadline = nextDeadline
	self.Timeline.lastUpdate = now
end

function RoRota:GetPlanningWindow(finisher, duration)
	local baseWindow
	if duration >= 20 then
		baseWindow = 15
	elseif duration >= 15 then
		baseWindow = 12
	else
		baseWindow = 10
	end
	
	local currentCP = GetComboPoints("player", "target")
	local currentEnergy = UnitMana("player")
	
	if currentCP >= 4 then
		baseWindow = baseWindow * 0.7
	end
	
	if currentEnergy < 50 then
		baseWindow = baseWindow * 1.2
	end
	
	return baseWindow
end

function RoRota:GetNextDeadline()
	return self.Timeline.nextDeadline
end

function RoRota:IsInPlanningWindow(finisher)
	for _, f in ipairs(self.Timeline.finishers) do
		if f.name == finisher then
			return f.inPlanningWindow
		end
	end
	return false
end

function RoRota:UpdateFinisherTimer(ability, cp)
	local now = GetTime()
	local targetName = UnitName("target")
	
	if ability == "Slice and Dice" then
		local duration = 6 + (cp * 3)
		if self.TalentCache and self.TalentCache.improvedBladeTactics then
			duration = duration * (1 + (self.TalentCache.improvedBladeTactics * 0.15))
		end
		self.sndExpiry = now + duration
	elseif ability == "Envenom" then
		self.envenomExpiry = now + 8 + (cp * 4)
	elseif ability == "Rupture" then
		local duration = 6 + (cp * 2)
		if self.TalentCache and self.TalentCache.tasteForBlood then
			duration = duration + (self.TalentCache.tasteForBlood * 2)
		end
		self.ruptureExpiry = now + duration
		self.ruptureTarget = targetName
	elseif ability == "Expose Armor" then
		self.exposeArmorExpiry = now + 30
		self.exposeArmorTarget = targetName
	end
end

RoRota.timeline = true
