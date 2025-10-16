--[[ cppacing ]]--
-- Pure CP pacing calculations.
-- Calculates optimal combo point pacing based on timeline.
--
-- Key functions:
--   CalculateCPPacing(state) - Returns pacing decision
--   Returns: shouldBuild, shouldDump, shouldPool, urgency

if not RoRota then return end
if RoRota.cppacing then return end

RoRota.CPPacing = {
	lastPacing = nil,
}

function RoRota:CalculateCPPacing(state)
	local deadline = self:GetNextDeadline()
	
	if not deadline then
		return {
			inPlanningWindow = false,
			shouldBuild = state.cp < 5,
			shouldDump = state.cp >= 5,
			shouldPool = false,
			canUseAnyFinisher = true,
		}
	end
	
	local timeToDeadline = deadline.expiresIn
	local planningWindow = deadline.planningWindow
	
	if timeToDeadline > planningWindow then
		return {
			inPlanningWindow = false,
			shouldBuild = state.cp < 5,
			shouldDump = state.cp >= 5,
			shouldPool = false,
			canUseAnyFinisher = true,
			deadline = deadline,
		}
	end
	
	local cpNeeded = 5 - state.cp
	local gcdsAvailable = math.floor(timeToDeadline / 1.0)
	
	local finisherEnergyCost = self:GetEnergyCost(deadline.name)
	local db = self.db.profile
	local builderCost = self:GetEnergyCost(db.mainBuilder or "Sinister Strike")
	
	local totalEnergyNeeded = finisherEnergyCost + (cpNeeded * builderCost)
	local energyDeficit = totalEnergyNeeded - state.energy
	local hasEnergyDeficit = energyDeficit > 0
	
	local gcdsNeeded = cpNeeded
	
	if cpNeeded == 0 and hasEnergyDeficit then
		return {
			inPlanningWindow = true,
			shouldBuild = false,
			shouldDump = false,
			shouldPool = true,
			urgent = true,
			deadline = deadline,
			cpNeeded = 0,
			gcdsAvailable = gcdsAvailable,
			energyDeficit = energyDeficit,
		}
	end
	
	if gcdsNeeded < gcdsAvailable - 2 then
		-- Don't dump if deadline expires soon (within 5s) - wait for refresh
		if timeToDeadline <= 5 then
			return {
				inPlanningWindow = true,
				shouldBuild = false,
				shouldDump = false,
				shouldPool = true,
				deadline = deadline,
				cpNeeded = cpNeeded,
				gcdsAvailable = gcdsAvailable,
			}
		end
		
		local canAffordDump = state.energy >= 30 + finisherEnergyCost
		
		return {
			inPlanningWindow = true,
			shouldBuild = false,
			shouldDump = canAffordDump,
			shouldPool = not canAffordDump,
			canUseLowerPriorityFinisher = canAffordDump,
			isAheadOfSchedule = canAffordDump,
			deadline = deadline,
			cpNeeded = cpNeeded,
			gcdsAvailable = gcdsAvailable,
		}
	elseif gcdsNeeded > gcdsAvailable or hasEnergyDeficit then
		return {
			inPlanningWindow = true,
			shouldBuild = true,
			shouldDump = false,
			urgent = true,
			isBehindSchedule = true,
			deadline = deadline,
			cpNeeded = cpNeeded,
			gcdsAvailable = gcdsAvailable,
			energyDeficit = energyDeficit,
		}
	else
		return {
			inPlanningWindow = true,
			shouldBuild = cpNeeded > 0,
			shouldDump = cpNeeded == 0,
			shouldPool = false,
			deadline = deadline,
			cpNeeded = cpNeeded,
			gcdsAvailable = gcdsAvailable,
		}
	end
end

RoRota.cppacing = true
