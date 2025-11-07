--[[ gui_preview ]]--
-- Rotation preview window

function RoRota:CreateRotationPreview()
	if RoRotaPreviewFrame then return end
	
	-- Create main frame
	local f = CreateFrame("Frame", "RoRotaPreviewFrame", UIParent)
	f:SetWidth(200)
	f:SetHeight(42)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	f:SetFrameStrata("HIGH")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() this:StartMoving() end)
	f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	
	-- Lock indicator
	f.lockText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.lockText:SetPoint("BOTTOM", f, "TOP", 0, 2)
	f.lockText:SetTextColor(1, 0.5, 0)
	f.lockText:Hide()
	
	-- Create ability rows (3 max)
	f.rows = {}
	for i = 1, 3 do
		local row = CreateFrame("Frame", nil, f)
		row:SetWidth(190)
		row:SetHeight(32)
		row:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -(i-1)*32)
		
		-- Icon
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetWidth(32)
		row.icon:SetHeight(32)
		row.icon:SetPoint("LEFT", row, "LEFT", 0, 0)
		row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		
		-- Name
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
		row.text:SetJustifyH("LEFT")
		row.text:SetText("")
		
		row:Hide()
		f.rows[i] = row
	end
	
	-- State
	f.enabled = false
	f.lastUpdate = 0
	
	-- Show initially so OnUpdate runs
	f:Show()
	
	-- Update logic
	f:SetScript("OnUpdate", function()
		-- Throttle
		if GetTime() - this.lastUpdate < 0.1 then return end
		this.lastUpdate = GetTime()
		
		-- Check if should show
		local hasTarget = UnitExists("target") and not UnitIsDead("target")
		local shouldShow = this.enabled and hasTarget
		
		if not shouldShow then
			for i = 1, 3 do this.rows[i]:Hide() end
			this.lockText:Hide()
			return
		end
		
		-- Show lock status
		if RoRota.CastState then
			local state, reason = RoRota.CastState:GetState()
			if state == "LOCKED" and reason then
				local remaining = RoRota.CastState.lockUntil - GetTime()
				if remaining > 0 then
					this.lockText:SetText(reason.." ("..string.format("%.1f", remaining).."s)")
					this.lockText:Show()
				else
					this.lockText:Hide()
				end
			elseif state == "GCD" and RoRota.CombatLog then
				local gcdRemaining = RoRota.CombatLog.gcdEnd - GetTime()
				if gcdRemaining > 0 then
					this.lockText:SetText("GCD ("..string.format("%.1f", gcdRemaining).."s)")
					this.lockText:Show()
				else
					this.lockText:Hide()
				end
			else
				this.lockText:Hide()
			end
		else
			this.lockText:Hide()
		end
		
		-- Get depth
		local depth = RoRota.db.profile.previewDepth or 1
		this:SetHeight(depth * 32)
		
		-- Get abilities using real rotation logic
		local abilities = {}
		if RoRota.GetRotationAbility then
			local ability = RoRota:GetRotationAbility()
			if ability then
				table.insert(abilities, ability)
			end
		end
		
		-- Fill remaining slots with simplified prediction
		if table.getn(abilities) < depth then
			local queue = RoRota:PredictNextAbilities(depth)
			for i = 1, table.getn(queue) do
				if queue[i] and table.getn(abilities) < depth then
					table.insert(abilities, queue[i])
				end
			end
		end
		
		-- Update rows
		for i = 1, 3 do
			local row = this.rows[i]
			if i <= depth and abilities[i] then
				row.text:SetText(abilities[i])
				local iconPath = RoRotaConstants.ABILITY_ICONS[abilities[i]]
				if iconPath then
					row.icon:SetTexture(iconPath)
				else
					row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
				row:Show()
			else
				row:Hide()
			end
		end
	end)
end

RoRota.gui_preview = true
