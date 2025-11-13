--[[ combatlog ]]--
-- Combat log tracking via UNIT_CASTEVENT (SuperWoW RAW_COMBATLOG)
-- Tracks player spell casts for precise timing and state management

if not RoRota then return end
if RoRota.combatlog then return end

RoRota.CombatLog = {
	playerGUID = nil,
	lastCast = {
		spellID = nil,
		spellName = nil,
		startTime = 0,
		castTime = 0,
		action = nil
	},
	gcdEnd = 0,
	castHistory = {},
	buffTimers = {},
	debuffTimers = {}
}

function RoRota.CombatLog:Initialize()
	local _, guid = UnitExists("player")
	self.playerGUID = guid
end

function RoRota.CombatLog:OnUnitCastEvent(caster, target, action, spellID, castTime)
	if not self.playerGUID then self:Initialize() end
	if caster ~= self.playerGUID then return end
	
	local now = GetTime()
	local spellName = SpellInfo and SpellInfo(spellID) or "Unknown"
	
	if action == "START" or action == "CHANNEL" then
		self.lastCast.spellID = spellID
		self.lastCast.spellName = spellName
		self.lastCast.startTime = now
		self.lastCast.castTime = castTime / 1000
		self.lastCast.action = action
		
		if RoRota.CastState then
			RoRota.CastState:OnCastStart(spellName, castTime / 1000)
		end
		
	elseif action == "CAST" then
		self.lastCast.action = "CAST"
		self.gcdEnd = now + 1.0
		
		if RoRota.CastState then
			RoRota.CastState:OnCastSuccess(spellName)
		end
		
		local cp = GetComboPoints("player", "target")
		
		if RoRota.IsFinisher and RoRota:IsFinisher(spellName) then
			if RoRota.UpdateFinisherTimer then
				RoRota:UpdateFinisherTimer(spellName, cp)
			end
		end
		
		self:TrackBuffDebuffApplication(spellName, cp, now)
		
		table.insert(self.castHistory, 1, {
			spell = spellName,
			time = now,
			action = "CAST"
		})
		if table.getn(self.castHistory) > 10 then
			table.remove(self.castHistory)
		end
		
	elseif action == "FAIL" or action == "INTERRUPTED" then
		self.lastCast.action = action
		
		if RoRota.CastState then
			RoRota.CastState:OnCastFailed(spellName, action)
		end
	end
end

function RoRota.CombatLog:IsOnGCD()
	return GetTime() < self.gcdEnd
end

function RoRota.CombatLog:IsCasting()
	if not self.lastCast.action then return false end
	return self.lastCast.action == "START" or self.lastCast.action == "CHANNEL"
end

function RoRota.CombatLog:GetLastCast()
	return self.lastCast.spellName, self.lastCast.action, self.lastCast.startTime
end

function RoRota.CombatLog:GetCastHistory()
	return self.castHistory
end

function RoRota.CombatLog:TrackBuffDebuffApplication(spellName, cp, now)
	if spellName == "Slice and Dice" then
		local duration = self:CalculateSndDuration(cp)
		self.buffTimers["Slice and Dice"] = now + duration
		RoRota.sndExpiry = now + duration
		
	elseif spellName == "Rupture" then
		local duration = self:CalculateRuptureDuration(cp)
		local targetName = UnitName("target")
		self.debuffTimers["Rupture"] = {
			expiry = now + duration,
			target = targetName
		}
		RoRota.ruptureExpiry = now + duration
		RoRota.ruptureTarget = targetName
		
	elseif spellName == "Envenom" then
		local duration = self:CalculateEnvenomDuration(cp)
		self.buffTimers["Envenom"] = now + duration
		RoRota.envenomExpiry = now + duration
		
	elseif spellName == "Expose Armor" then
		local targetName = UnitName("target")
		self.debuffTimers["Expose Armor"] = {
			expiry = now + 30,
			target = targetName
		}
		RoRota.exposeArmorExpiry = now + 30
		RoRota.exposeArmorTarget = targetName
		
	elseif spellName == "Shadow of Death" then
		local targetName = UnitName("target")
		self.debuffTimers["Shadow of Death"] = {
			expiry = now + 30,
			target = targetName
		}
		
	elseif spellName == "Kidney Shot" then
		local duration = 1 + cp
		local targetName = UnitName("target")
		self.debuffTimers["Kidney Shot"] = {
			expiry = now + duration,
			target = targetName
		}
		
	elseif spellName == "Flourish" then
		local duration = self:CalculateFlourishDuration(cp)
		self.buffTimers["Flourish"] = now + duration
	end
end

function RoRota.CombatLog:CalculateSndDuration(cp)
	local duration = 6 + (cp * 3)
	if RoRota.TalentCache and RoRota.TalentCache.improvedBladeTactics then
		duration = duration * (1 + (RoRota.TalentCache.improvedBladeTactics * 0.15))
	end
	return duration
end

function RoRota.CombatLog:CalculateRuptureDuration(cp)
	local duration = 6 + (cp * 2)
	if RoRota.TalentCache and RoRota.TalentCache.tasteForBlood then
		duration = duration + (RoRota.TalentCache.tasteForBlood * 2)
	end
	return duration
end

function RoRota.CombatLog:CalculateEnvenomDuration(cp)
	return 8 + (cp * 4)
end

function RoRota.CombatLog:CalculateFlourishDuration(cp)
	local duration = 6 + (cp * 2)
	if RoRota.TalentCache and RoRota.TalentCache.improvedBladeTactics then
		duration = duration * (1 + (RoRota.TalentCache.improvedBladeTactics * 0.15))
	end
	return duration
end

function RoRota.CombatLog:GetBuffTimeRemaining(buffName)
	local expiry = self.buffTimers[buffName]
	if not expiry then return 0 end
	local remaining = expiry - GetTime()
	return remaining > 0 and remaining or 0
end

function RoRota.CombatLog:GetDebuffTimeRemaining(debuffName)
	local data = self.debuffTimers[debuffName]
	if not data then return 0 end
	
	if data.target and UnitExists("target") then
		local currentTarget = UnitName("target")
		if currentTarget ~= data.target then
			return 0
		end
	end
	
	local remaining = data.expiry - GetTime()
	return remaining > 0 and remaining or 0
end

RoRota.combatlog = true
