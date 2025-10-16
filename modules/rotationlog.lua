--[[ rotationlog ]]--
-- Tracks rotation decisions for debugging

if not RoRota then 
	RoRota = {}
end

if not RoRota.RotationLog then
	RoRota.RotationLog = {
		entries = {},
		maxEntries = 15,
	}
end

function RoRota:LogRotationDecision(ability, reason, state)
	local entry = {
		time = GetTime(),
		ability = ability or "POOL",
		reason = reason or "Unknown",
		cp = state and state.cp or UnitMana("player"),
		energy = state and state.energy or UnitMana("player"),
		deadline = nil,
	}
	
	if self.Timeline and self.Timeline.nextDeadline then
		local dl = self.Timeline.nextDeadline
		entry.deadline = string.format("%s(%.1fs)", dl.name, dl.expiresIn)
	end
	
	table.insert(self.RotationLog.entries, 1, entry)
	
	while table.getn(self.RotationLog.entries) > self.RotationLog.maxEntries do
		table.remove(self.RotationLog.entries)
	end
end

function RoRota:GetRotationLogText()
	local lines = {"=== RoRota Rotation Log (Last 15 Decisions) ===", ""}
	
	for i, entry in ipairs(self.RotationLog.entries) do
		local timeStr = string.format("[%.1fs ago]", GetTime() - entry.time)
		local stateStr = string.format("CP:%d E:%d", entry.cp, entry.energy)
		local deadlineStr = entry.deadline and string.format(" DL:%s", entry.deadline) or ""
		local line = string.format("%s %s %s%s - %s", 
			timeStr, entry.ability, stateStr, deadlineStr, entry.reason)
		table.insert(lines, line)
	end
	
	table.insert(lines, "")
	table.insert(lines, "=== End Log ===")
	
	return table.concat(lines, "\n")
end

function RoRota:ShowRotationLog()
	local logText = self:GetRotationLogText()
	
	if not RoRotaLogFrame then
		local frame = CreateFrame("Frame", "RoRotaLogFrame", UIParent)
		frame:SetWidth(600)
		frame:SetHeight(400)
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		frame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11 }
		})
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", function() this:StartMoving() end)
		frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
		
		local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", frame, "TOP", 0, -15)
		title:SetText("Rotation Log")
		
		local scroll = CreateFrame("ScrollFrame", "RoRotaLogScroll", frame, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
		scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
		
		local editbox = CreateFrame("EditBox", "RoRotaLogEditBox", scroll)
		editbox:SetWidth(550)
		editbox:SetHeight(320)
		editbox:SetMultiLine(true)
		editbox:SetAutoFocus(false)
		editbox:SetFontObject(GameFontWhite)
		editbox:SetScript("OnEscapePressed", function() RoRotaLogFrame:Hide() end)
		scroll:SetScrollChild(editbox)
		
		local selectAll = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		selectAll:SetWidth(80)
		selectAll:SetHeight(22)
		selectAll:SetPoint("BOTTOM", frame, "BOTTOM", -45, 15)
		selectAll:SetText("Select All")
		selectAll:SetScript("OnClick", function() 
			RoRotaLogFrame.editbox:HighlightText()
			RoRotaLogFrame.editbox:SetFocus()
		end)
		
		local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		close:SetWidth(80)
		close:SetHeight(22)
		close:SetPoint("BOTTOM", frame, "BOTTOM", 45, 15)
		close:SetText("Close")
		close:SetScript("OnClick", function() RoRotaLogFrame:Hide() end)
		
		frame.editbox = editbox
	end
	
	RoRotaLogFrame.editbox:SetText(logText)
	RoRotaLogFrame.editbox:HighlightText()
	RoRotaLogFrame:Show()
end

function RoRota:ClearRotationLog()
	self.RotationLog.entries = {}
	self:Print("Rotation log cleared.")
end
