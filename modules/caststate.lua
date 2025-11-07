--[[ caststate ]]--
-- Cast state machine with COMBATLOG integration
-- Prevents rotation execution during invalid windows (casting, GCD, locked)

if not RoRota then return end
if RoRota.caststate then return end

RoRota.CastState = {
	state = "IDLE",
	lockUntil = 0,
	lockReason = nil,
	lastAbility = nil
}

function RoRota.CastState:CanCast()
	local now = GetTime()
	
	if self.state == "LOCKED" and now < self.lockUntil then
		return false
	end
	
	if RoRota.CombatLog and RoRota.CombatLog:IsOnGCD() then
		return false
	end
	
	if RoRota.CombatLog and RoRota.CombatLog:IsCasting() then
		return false
	end
	
	return true
end

function RoRota.CastState:OnCastStart(ability, castTime)
	self.state = "CASTING"
	self.lastAbility = ability
end

function RoRota.CastState:OnCastSuccess(ability)
	self.state = "GCD"
end

function RoRota.CastState:OnCastFailed(ability, reason)
	self.state = "IDLE"
	
	if reason == "FAIL" then
		if ability == RoRota.db.profile.mainBuilder or ability == RoRota.db.profile.secondaryBuilder then
			if RoRota.OnBuilderPositionError then
				RoRota:OnBuilderPositionError()
			end
		end
		
		local openerCfg = RoRota.db.profile.opener
		if openerCfg and (ability == openerCfg.ability or ability == openerCfg.secondaryAbility) then
			if RoRota.OnOpenerPositionError then
				RoRota:OnOpenerPositionError()
			end
		end
	end
end

function RoRota.CastState:LockRotation(duration, reason)
	self.state = "LOCKED"
	self.lockUntil = GetTime() + duration
	self.lockReason = reason
end

function RoRota.CastState:GetState()
	local now = GetTime()
	if self.state == "LOCKED" and now >= self.lockUntil then
		self.state = "IDLE"
		self.lockReason = nil
	end
	return self.state, self.lockReason
end

RoRota.caststate = true
