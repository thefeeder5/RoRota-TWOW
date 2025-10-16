--[[ gui_cpdebug ]]--
-- CP Planning System debug window

if RoRota.gui_cpdebug then return end

function RoRota:CreateCPDebugWindow()
	if RoRotaCPDebugFrame then return end
	
	local frame = CreateFrame("Frame", "RoRotaCPDebugFrame", UIParent)
	frame:SetWidth(400)
	frame:SetHeight(500)
	frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function() this:StartMoving() end)
	frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	frame:Hide()
	
	frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
	frame.text:SetJustifyH("LEFT")
	frame.text:SetJustifyV("TOP")
	frame.text:SetWidth(390)
	frame.text:SetHeight(490)
	frame.text:SetTextColor(1, 1, 1, 1)
	
	frame:SetScript("OnUpdate", function()
		if not this:IsVisible() then return end
		RoRota:UpdateCPDebugWindow()
	end)
	
	RoRotaCPDebugFrame = frame
end

function RoRota:UpdateCPDebugWindow()
	if not RoRotaCPDebugFrame or not RoRotaCPDebugFrame:IsVisible() then return end
	if not UnitExists("target") then
		RoRotaCPDebugFrame.text:SetText("No target selected")
		return
	end
	
	local lines = {}
	local cp = GetComboPoints("player", "target")
	local energy = UnitMana("player")
	
	table.insert(lines, "|cFFFFFF00=== CP PLANNING DEBUG ===|r")
	table.insert(lines, string.format("CP: %d | Energy: %d", cp, energy))
	table.insert(lines, "")
	
	self:UpdateTimeline()
	
	table.insert(lines, "|cFF00FF00--- TIMELINE ---|r")
	if table.getn(self.Timeline.finishers) == 0 then
		table.insert(lines, "No active finishers")
	else
		for i, f in ipairs(self.Timeline.finishers) do
			local color = f.inPlanningWindow and "|cFFFF0000" or "|cFFFFFFFF"
			table.insert(lines, string.format("%s%d. %s|r", color, i, f.name))
			table.insert(lines, string.format("   Expires: %.1fs | Window: %.1fs", f.expiresIn, f.planningWindow))
			table.insert(lines, string.format("   Priority: %d | %s", f.priority, f.inPlanningWindow and "IN WINDOW" or "outside"))
		end
	end
	
	if self.Timeline.nextDeadline then
		table.insert(lines, "")
		table.insert(lines, string.format("|cFFFF00FFNext Deadline: %s in %.1fs|r", 
			self.Timeline.nextDeadline.name, self.Timeline.nextDeadline.expiresIn))
	end
	
	table.insert(lines, "")
	table.insert(lines, "|cFF00FF00--- CP PACING ---|r")
	
	if self.CreateSimulatedState and self.CalculateCPPacing then
		local state = self:CreateSimulatedState()
		local pacing = self:CalculateCPPacing(state)
		
		table.insert(lines, string.format("In Planning Window: %s", pacing.inPlanningWindow and "|cFFFF0000YES|r" or "NO"))
		
		if pacing.cpNeeded then
			table.insert(lines, string.format("CP Needed: %d", pacing.cpNeeded))
		end
		
		if pacing.gcdsAvailable then
			table.insert(lines, string.format("GCDs Available: %d", pacing.gcdsAvailable))
		end
		
		if pacing.isAheadOfSchedule then
			table.insert(lines, "|cFF00FFFFStatus: AHEAD - Should DUMP CP|r")
		elseif pacing.isBehindSchedule then
			table.insert(lines, "|cFFFF0000Status: BEHIND - Should BUILD NOW|r")
		elseif pacing.inPlanningWindow then
			table.insert(lines, "|cFF00FF00Status: ON SCHEDULE|r")
		else
			table.insert(lines, "Status: FREE BUILDING")
		end
		
		table.insert(lines, "")
		table.insert(lines, "|cFF00FF00--- DECISION ---|r")
		
		local ability, reason, data = self:PlanRotationSimulated(state)
		if ability then
			table.insert(lines, string.format("|cFFFFFF00Next: %s|r", ability))
			table.insert(lines, string.format("Reason: %s (code=%d)", self:FormatPlanReason(reason, data) or "Unknown", reason or 0))
		else
			table.insert(lines, string.format("|cFFFF0000Next: POOLING|r"))
			table.insert(lines, string.format("Reason: %s (code=%d)", self:FormatPlanReason(reason, data) or "Unknown", reason or 0))
		end
		

	end
	
	table.insert(lines, "")
	table.insert(lines, "|cFF808080Drag to move | /rr cpdebug to toggle|r")
	
	RoRotaCPDebugFrame.text:SetText(table.concat(lines, "\n"))
end

function RoRota:ToggleCPDebugWindow()
	if not RoRotaCPDebugFrame then
		self:CreateCPDebugWindow()
	end
	
	if RoRotaCPDebugFrame:IsVisible() then
		RoRotaCPDebugFrame:Hide()
	else
		RoRotaCPDebugFrame:Show()
	end
end

RoRota.gui_cpdebug = true
