--[[ energytick ]]--
-- Energy tick tracking and prediction.
-- Tracks energy regeneration timing via events.
--
-- Key functions:
--   GetNextEnergyTick() - Time until next energy tick
--   GetEnergyTickTime() - Tick duration (with talents)
--   PredictEnergyAt(time) - Predicted energy at future time

if not RoRota then return end
if RoRota.energytick then return end

RoRota.EnergyTick = {
	lastEnergy = 0,
	tickStart = 0,
	tickDuration = 2.0,
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_ENERGY")

frame:SetScript("OnEvent", function()
	if event == "PLAYER_ENTERING_WORLD" then
		RoRota.EnergyTick.lastEnergy = UnitMana("player")
		RoRota.EnergyTick.tickStart = GetTime()
	elseif event == "UNIT_ENERGY" and arg1 == "player" then
		local currentEnergy = UnitMana("player")
		local diff = currentEnergy - RoRota.EnergyTick.lastEnergy
		
		if diff > 0 then
			RoRota.EnergyTick.tickStart = GetTime()
		end
		
		RoRota.EnergyTick.lastEnergy = currentEnergy
	end
end)

function RoRota:GetNextEnergyTick()
	local elapsed = GetTime() - self.EnergyTick.tickStart
	local tickTime = self:GetEnergyTickTime()
	local remaining = tickTime - elapsed
	
	if remaining < 0 then
		remaining = 0
	end
	
	return remaining
end

function RoRota:GetEnergyTickTime()
	local tickTime = RoRotaConstants.ENERGY_TICK_TIME
	
	if self.TalentCache and self.TalentCache.bladeRush and self.TalentCache.bladeRush > 0 then
		local _, agility = UnitStat("player", 2)
		local reductionPerAgi = self.TalentCache.bladeRush == 1 and 0.0006 or 0.0012
		local agiReduction = agility * reductionPerAgi
		tickTime = math.max(0.5, tickTime - agiReduction)
	end
	
	return tickTime
end

-- Pure calculation: predict energy at future time
function RoRota:PredictEnergyAt(seconds)
	local currentEnergy = UnitMana("player")
	local tickTime = self:GetEnergyTickTime()
	local ticksInFuture = math.floor(seconds / tickTime)
	local energyGain = ticksInFuture * RoRotaConstants.ENERGY_PER_TICK
	
	local maxEnergy = 100
	if self.TalentCache and self.TalentCache.vigor then
		if self.TalentCache.vigor == 1 then
			maxEnergy = 105
		elseif self.TalentCache.vigor == 2 then
			maxEnergy = 110
		end
	end
	
	return math.min(maxEnergy, currentEnergy + energyGain)
end

RoRota.energytick = true
