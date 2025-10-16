--[[ state ]]--
-- Read-only state queries.
-- Direct WoW API calls with no caching or side effects.
--
-- Key functions:
--   GetCurrentState() - Returns complete state snapshot
--   IsInCombat() - Returns combat status
--   HasTarget() - Returns target existence
--   GetComboPoints() - Returns current CP
--   GetEnergy() - Returns current energy
--   IsStealthed() - Returns stealth status

if not RoRota then return end
if RoRota.state then return end

RoRota.State = {}

-- Get complete state snapshot (read-only)
function RoRota.State:GetCurrentState()
	return {
		energy = UnitMana("player"),
		comboPoints = GetComboPoints("player", "target"),
		inCombat = UnitAffectingCombat("player"),
		stealthed = self:IsStealthed(),
		hasTarget = self:HasTarget(),
		healthPercent = self:GetHealthPercent(),
		targetHealthPercent = self:GetTargetHealthPercent(),
	}
end

-- Read-only state queries (no caching)

function RoRota.State:IsInCombat()
	return UnitAffectingCombat("player")
end

function RoRota.State:HasTarget()
	return UnitExists("target") and not UnitIsDead("target")
end

function RoRota.State:GetComboPoints()
	return GetComboPoints("player", "target")
end

function RoRota.State:GetEnergy()
	return UnitMana("player")
end

function RoRota.State:IsStealthed()
	local i = 1
	while UnitBuff("player", i) do
		local texture = UnitBuff("player", i)
		if texture and string.find(texture, "Stealth") then
			return true
		end
		i = i + 1
		if i > 40 then break end
	end
	return false
end

function RoRota.State:GetHealthPercent()
	return (UnitHealth("player") / UnitHealthMax("player")) * 100
end

function RoRota.State:GetTargetHealthPercent()
	if not self:HasTarget() then return 100 end
	return (UnitHealth("target") / UnitHealthMax("target")) * 100
end

-- Legacy compatibility (deprecated, use Cache instead)
function RoRota.State:Update()
	-- No-op for backward compatibility
end

RoRota.state = true
