-- RoRota Profile Auto-Switcher
-- Automatically switches profiles based on group status

RoRota.pendingProfileSwitch = nil
RoRota.lastGroupState = nil

function RoRota:GetTargetProfile()
	if not RoRotaDB or not RoRotaDB.autoSwitch or not RoRotaDB.autoSwitch.enabled then
		return nil
	end
	
	local inRaid = UnitInRaid("player")
	local partyMembers = GetNumPartyMembers()
	local inFullGroup = partyMembers >= 4
	
	if inRaid and RoRotaDB.autoSwitch.raidProfile then
		return RoRotaDB.autoSwitch.raidProfile
	elseif inFullGroup and RoRotaDB.autoSwitch.groupProfile then
		return RoRotaDB.autoSwitch.groupProfile
	elseif not inFullGroup and not inRaid and RoRotaDB.autoSwitch.soloProfile then
		return RoRotaDB.autoSwitch.soloProfile
	end
	
	return nil
end

function RoRota:CheckProfileSwitch()
	local targetProfile = self:GetTargetProfile()
	if not targetProfile then return end
	
	if not RoRotaDB.profiles or not RoRotaDB.profiles[targetProfile] then
		return
	end
	
	local charKey = UnitName("player").." - "..GetRealmName()
	local currentProfile = RoRotaDB.char and RoRotaDB.char[charKey] or "Default"
	
	if targetProfile ~= currentProfile then
		if InCombatLockdown() or UnitAffectingCombat("player") then
			self.pendingProfileSwitch = targetProfile
			return
		end
		
		if not RoRotaDB.char then RoRotaDB.char = {} end
		RoRotaDB.char[charKey] = targetProfile
		self:SetProfile(targetProfile)
		self:Print("Auto-switched to profile: "..targetProfile)
		
		if RoRotaGUIFrame and RoRotaGUIFrame:IsVisible() then
			LoadValues(RoRotaGUIFrame)
		end
	end
end

function RoRota:OnGroupStateChange()
	local inRaid = UnitInRaid("player")
	local partyMembers = GetNumPartyMembers()
	local inFullGroup = partyMembers >= 4
	local currentState = inRaid and "raid" or (inFullGroup and "group" or "solo")
	
	if self.lastGroupState ~= currentState then
		self.lastGroupState = currentState
		self:CheckProfileSwitch()
	end
end

function RoRota:CheckPendingSwitch()
	if self.pendingProfileSwitch and not InCombatLockdown() and not UnitAffectingCombat("player") then
		local targetProfile = self.pendingProfileSwitch
		self.pendingProfileSwitch = nil
		
		if RoRotaDB.profiles and RoRotaDB.profiles[targetProfile] then
			local charKey = UnitName("player").." - "..GetRealmName()
			if not RoRotaDB.char then RoRotaDB.char = {} end
			RoRotaDB.char[charKey] = targetProfile
			self:SetProfile(targetProfile)
			self:Print("Auto-switched to profile: "..targetProfile.." (after combat)")
			
			if RoRotaGUIFrame and RoRotaGUIFrame:IsVisible() then
				LoadValues(RoRotaGUIFrame)
			end
		end
	end
end
