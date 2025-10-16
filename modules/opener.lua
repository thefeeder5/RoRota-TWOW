--[[ opener ]]--
-- Opener decision module.
-- Returns stealth opener ability or nil.
--
-- Key function:
--   GetOpenerAbility() - Returns opener or nil (stealth only)
--
-- Handles: Pick Pocket, Cold Blood, failsafe, immunity

if not RoRota then return end
if RoRota.opener then return end

-- Module state
local opener_attempts = 0
local pick_pocket_used = false
local cold_blood_ready = false
local last_target = nil

function RoRota:GetOpenerAbility()
	local isStealthed = self:HasPlayerBuff("Stealth")
	if not isStealthed then
		-- Reset opener state when leaving stealth
		opener_attempts = 0
		pick_pocket_used = false
		cold_blood_ready = false
		return nil
	end
	
	local openerCfg = self.db.profile.opener or {}
	local targetName = UnitName("target")
	
	-- Reset state on target switch
	if targetName ~= last_target then
		opener_attempts = 0
		pick_pocket_used = false
		cold_blood_ready = false
		last_target = targetName
	end
	
	-- Pick Pocket before opener
	if openerCfg.pickPocket and not pick_pocket_used and self:HasSpell("Pick Pocket") then
		if not self:TargetHasNoPockets() then
			pick_pocket_used = true
			return "Pick Pocket"
		end
	end
	
	-- Cold Blood before Ambush (check BEFORE failsafe)
	local opener = openerCfg.ability
	if not cold_blood_ready and openerCfg.useColdBlood and opener == "Ambush" and self:HasSpell("Cold Blood") and not self:IsOnCooldown("Cold Blood") and not self:HasPlayerBuff("Cold Blood") then
		cold_blood_ready = true
		return "Cold Blood"
	end
	
	-- Select opener with failsafe (after CB check)
	if opener and self:IsTargetImmune(opener) and openerCfg.secondaryAbility then
		opener = openerCfg.secondaryAbility
	elseif (openerCfg.failsafeAttempts or -1) >= 0 and opener_attempts >= (openerCfg.failsafeAttempts or -1) and openerCfg.secondaryAbility then
		opener = openerCfg.secondaryAbility
	end
	
	-- Cast opener (don't increment counter, it's incremented by actual cast event)
	if opener and not self:IsTargetImmune(opener) then
		cold_blood_ready = false
		return opener
	end
	
	return nil
end

function RoRota:OnOpenerPositionError()
	opener_attempts = opener_attempts + 1
end

function RoRota:ResetOpenerState()
	opener_attempts = 0
	pick_pocket_used = false
	cold_blood_ready = false
	last_target = nil
end

function RoRota:GetOpenerFailsafeInfo()
	return {
		attempts = opener_attempts,
		threshold = self.db.profile.opener and self.db.profile.opener.failsafeAttempts or -1
	}
end

RoRota.opener = true
