--[[ gui_preview ]]--
-- Rotation preview window showing current and next abilities.
-- Displays ability queue with icons, combo points, and energy.
--
-- Features:
--   - Shows current ability (what to press now)
--   - Shows next ability (what comes after)
--   - Real-time updates (0.1s throttle)
--   - Movable window (drag to reposition)
--   - Ability icons from constants table

function RoRota:CreateRotationPreview()
	if RoRotaPreviewFrame then return end
	
	local pf = CreateFrame("Frame", "RoRotaPreviewFrame", UIParent)
	pf:SetWidth(100)
	pf:SetHeight(60)
	pf:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	pf:SetMovable(true)
	pf:EnableMouse(true)
	pf:RegisterForDrag("LeftButton")
	pf:SetScript("OnDragStart", function() this:StartMoving() end)
	pf:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	
	-- current ability icon
	pf.icon = pf:CreateTexture(nil, "ARTWORK")
	pf.icon:SetWidth(32)
	pf.icon:SetHeight(32)
	pf.icon:SetPoint("TOPLEFT", pf, "TOPLEFT", 5, -5)
	pf.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	-- next ability icon
	pf.nextIcon = pf:CreateTexture(nil, "ARTWORK")
	pf.nextIcon:SetWidth(32)
	pf.nextIcon:SetHeight(32)
	pf.nextIcon:SetPoint("LEFT", pf.icon, "RIGHT", 3, 0)
	pf.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	-- CP and Energy text
	pf.cpText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.cpText:SetPoint("TOPLEFT", pf.icon, "BOTTOMLEFT", 0, -3)
	pf.cpText:SetText("CP: 0")
	
	pf.energyText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.energyText:SetPoint("LEFT", pf.cpText, "RIGHT", 8, 0)
	pf.energyText:SetText("Energy: 0")
	
	
	pf.lastUpdate = 0
	pf:SetScript("OnUpdate", function()
		if not this.lastUpdate then this.lastUpdate = 0 end
		if GetTime() - this.lastUpdate > 0.1 then
			this.lastUpdate = GetTime()
			if RoRota and RoRota.GetNextAbility and RoRota.GetNextAbilityAfter then
				local current_ability = RoRota:GetNextAbility()
				local next_ability = RoRota:GetNextAbilityAfter(current_ability)
				local cp = GetComboPoints("player", "target")
				local energy = UnitMana("player")
				
				this.cpText:SetText("CP: "..cp)
				this.energyText:SetText("Energy: "..energy)
				
				-- update current ability icon
				if current_ability and RoRotaConstants and RoRotaConstants.ABILITY_ICONS then
					local icon_path = RoRotaConstants.ABILITY_ICONS[current_ability]
					if icon_path then
						this.icon:SetTexture(icon_path)
					else
						this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				else
					this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
				
				-- update next ability icon
				if next_ability and RoRotaConstants and RoRotaConstants.ABILITY_ICONS then
					local next_icon_path = RoRotaConstants.ABILITY_ICONS[next_ability]
					if next_icon_path then
						this.nextIcon:SetTexture(next_icon_path)
					else
						this.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				else
					this.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
			end
		end
	end)
	
	pf:Hide()
end
