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
local lastInterruptedSpell = nil

function RoRota:StoreInterruptedSpell(targetName, spellName)
	if not targetName or not spellName then return end
	
	local interrupt = self.db.profile.interrupt or {}
	if not interrupt.history then
		interrupt.history = {}
	end
	
	local key = targetName .. " - " .. spellName
	
	-- Only store if unique
	for _, entry in ipairs(interrupt.history) do
		if entry == key then
			return
		end
	end
	
	table.insert(interrupt.history, key)
end

function RoRota:ShouldInterruptSpell(targetName, spellName)
	if not targetName or not spellName then return false end
	
	local interrupt = self.db.profile.interrupt or {}
	local filterMode = interrupt.filterMode or "Interrupt All (Ignore List)"
	local filterList = interrupt.filterList or {}
	
	local exactKey = targetName .. " - " .. spellName
	local wildcardKey = "* - " .. spellName
	
	local inList = false
	for _, entry in ipairs(filterList) do
		if entry == exactKey or entry == wildcardKey then
			inList = true
			break
		end
	end
	
	if filterMode == "Interrupt All (Ignore List)" then
		return not inList
	else
		return inList
	end
end

function RoRota:GetInterruptAbility()
	if not self:IsTargetCasting() then
		castStartTime = 0
		lastCastingSpell = nil
		return nil
	end
	
	-- Expose for interrupt history
	if not self.interruptState then self.interruptState = {} end
	self.interruptState.lastInterruptedSpell = lastInterruptedSpell
	
	local interrupt = self.db.profile.interrupt or {}
	
	-- Skip if spell is uninterruptible
	if self.currentTargetSpell and self:IsSpellUninterruptible(self.currentTargetSpell) then
		castStartTime = 0
		lastCastingSpell = nil
		return nil
	end
	
	-- Check interrupt filter
	local targetName = UnitName("target") or ""
	if self.currentTargetSpell and not self:ShouldInterruptSpell(targetName, self.currentTargetSpell) then
		castStartTime = 0
		lastCastingSpell = nil
		return nil
	end
	
	-- Track when cast started
	if self.currentTargetSpell ~= lastCastingSpell then
		castStartTime = GetTime()
		lastCastingSpell = self.currentTargetSpell
		lastInterruptedSpell = self.currentTargetSpell
	end
	
	-- Wait 1 second before interrupting (maximize damage mitigation)
	local castDuration = GetTime() - castStartTime
	if castDuration < 1.0 then
		return nil
	end
	
	-- Check range for Deadly Throw vs Kick
	local targetDistance = self:GetTargetDistance()
	local throwingSpec = self.TalentCache and self.TalentCache.throwingWeaponSpec or 0
	local deadlyThrowMaxRange = 30 + (throwingSpec * 3)
	local hasThrown = GetInventoryItemLink("player", 18) ~= nil
	
	-- Priority: Kick (melee) > Deadly Throw (ranged) > Gouge > Kidney Shot
	if interrupt.useKick and self:HasSpell("Kick") and self:HasEnoughEnergy("Kick") and not self:IsOnCooldown("Kick") and not self:IsTargetImmune("Kick") and targetDistance <= 5 then
		return "Kick"
	end
	
	if interrupt.useDeadlyThrow and self:HasSpell("Deadly Throw") and self:HasEnoughEnergy("Deadly Throw") and not self:IsOnCooldown("Deadly Throw") and not self:IsTargetImmune("Deadly Throw") and hasThrown and targetDistance >= 8 and targetDistance <= deadlyThrowMaxRange then
		return "Deadly Throw"
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
