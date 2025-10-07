-- RoRota GUI - Rotation Preview Window

function RoRota:CreateRotationPreview()
	if RoRotaPreviewFrame then return end
	
	local pf = CreateFrame("Frame", "RoRotaPreviewFrame", UIParent)
	pf:SetWidth(200)
	pf:SetHeight(80)
	pf:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	pf:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = {left = 11, right = 12, top = 12, bottom = 11}
	})
	pf:SetMovable(true)
	pf:EnableMouse(true)
	pf:RegisterForDrag("LeftButton")
	pf:SetScript("OnDragStart", function() this:StartMoving() end)
	pf:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	
	pf.title = pf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	pf.title:SetPoint("TOP", pf, "TOP", 0, -8)
	pf.title:SetText("Next Ability")
	
	pf.icon = pf:CreateTexture(nil, "ARTWORK")
	pf.icon:SetWidth(40)
	pf.icon:SetHeight(40)
	pf.icon:SetPoint("LEFT", pf, "LEFT", 20, -5)
	pf.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	pf.abilityText = pf:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	pf.abilityText:SetPoint("LEFT", pf.icon, "RIGHT", 10, 10)
	pf.abilityText:SetText("---")
	
	pf.cpText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.cpText:SetPoint("LEFT", pf.icon, "RIGHT", 10, -5)
	pf.cpText:SetText("CP: 0")
	
	pf.energyText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.energyText:SetPoint("LEFT", pf.icon, "RIGHT", 10, -18)
	pf.energyText:SetText("Energy: 0")
	
	pf.lastUpdate = 0
	pf:SetScript("OnUpdate", function()
		if not this.lastUpdate then this.lastUpdate = 0 end
		if GetTime() - this.lastUpdate > 0.1 then
			this.lastUpdate = GetTime()
			if RoRota and RoRota.GetNextAbility then
				local nextAbility = RoRota:GetNextAbility()
				local cp = GetComboPoints("player", "target")
				local energy = UnitMana("player")
				
				this.abilityText:SetText(nextAbility or "---")
				this.abilityText:SetTextColor(1, 1, 1)
				this.cpText:SetText("CP: "..cp)
				this.energyText:SetText("Energy: "..energy)
				
				if nextAbility and RoRotaConstants and RoRotaConstants.ABILITY_ICONS then
					local iconPath = RoRotaConstants.ABILITY_ICONS[nextAbility]
					if iconPath then
						this.icon:SetTexture(iconPath)
					else
						this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				end
			end
		end
	end)
	
	pf:Hide()
end
