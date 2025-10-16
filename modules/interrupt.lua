--[[ interrupt ]]--
-- Interrupt decision module.
-- Returns interrupt ability or nil based on target casting state.
--
-- Key function:
--   GetInterruptAbility() - Returns Kick/Gouge/Kidney or nil
--
-- Priority: Kick > Gouge > Kidney Shot
-- Delays interrupts by 1s to maximize damage mitigation

if not RoRota then return end
if RoRota.interrupt then return end

local castStartTime = 0
local lastCastingSpell = nil

function RoRota:GetInterruptAbility()
	if not self:IsTargetCasting() then
		castStartTime = 0
		lastCastingSpell = nil
		return nil
	end
	
	local interrupt = self.db.profile.interrupt or {}
	
	-- Skip if spell is uninterruptible
	if self.currentTargetSpell and self:IsSpellUninterruptible(self.currentTargetSpell) then
		castStartTime = 0
		lastCastingSpell = nil
		return nil
	end
	
	-- Track when cast started
	if self.currentTargetSpell ~= lastCastingSpell then
		castStartTime = GetTime()
		lastCastingSpell = self.currentTargetSpell
	end
	
	-- Wait 1 second before interrupting (maximize damage mitigation)
	local castDuration = GetTime() - castStartTime
	if castDuration < 1.0 then
		return nil
	end
	
	-- Priority: Kick > Gouge > Kidney Shot
	if interrupt.useKick and self:HasSpell("Kick") and self:HasEnoughEnergy("Kick") and not self:IsOnCooldown("Kick") and not self:IsTargetImmune("Kick") then
		return "Kick"
	end
	
	if interrupt.useGouge and self:HasSpell("Gouge") and self:HasEnoughEnergy("Gouge") and not self:IsOnCooldown("Gouge") and not self:IsTargetImmune("Gouge") then
		return "Gouge"
	end
	
	local cp = GetComboPoints("player", "target")
	if interrupt.useKidneyShot and cp >= 1 and cp <= (interrupt.kidneyMaxCP or 5) and self:HasSpell("Kidney Shot") and self:HasEnoughEnergy("Kidney Shot") and not self:IsTargetImmune("Kidney Shot") then
		return "Kidney Shot"
	end
	
	return nil
end

RoRota.interrupt = true
