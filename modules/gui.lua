-- RoRota GUI Module - All-in-one

RoRotaGUI = RoRotaGUI or {}

local function CreateLabel(parent, x, y, text, font)
	local lbl = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
	lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	lbl:SetText(text)
	return lbl
end

local function CreateDropdown(name, parent, x, y, width, items, callback)
	local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
	dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	UIDropDownMenu_SetWidth(width or 120, dd)
	UIDropDownMenu_Initialize(dd, function()
		for _, item in ipairs(items or {}) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = item
			info.value = item
			info.func = function()
				if callback then callback(this.value) end
				UIDropDownMenu_SetSelectedValue(dd, this.value)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	return dd
end

local function CreateSlider(name, parent, x, y, min, max, step, width, lowText, highText, labelText, callback)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	slider:SetMinMaxValues(min or 0, max or 100)
	slider:SetValueStep(step or 1)
	slider:SetWidth(width or 120)
	if name then
		local low = getglobal(name.."Low")
		local high = getglobal(name.."High")
		local txt = getglobal(name.."Text")
		if low and lowText then low:SetText(tostring(lowText)) end
		if high and highText then high:SetText(tostring(highText)) end
		if txt and labelText then txt:SetText(tostring(labelText)) end
	end
	slider:SetScript("OnValueChanged", function()
		if callback then callback(this or slider) end
	end)
	return slider
end

local function CreateCheck(name, parent, x, y, text, callback)
	local chk = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	chk:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	local lbl = getglobal(name.."Text")
	if lbl then lbl:SetText(text) end
	chk:SetScript("OnClick", callback)
	return chk
end

local function ShowTab(frame, index)
	for i = 1, table.getn(frame.tabs) do
		if frame.tabs[i].content then
			if i == index then
				frame.tabs[i].content:Show()
				frame.tabs[i].label:SetTextColor(1, 1, 1)
				if i == 3 and frame.tabs[3].content.UpdatePriorityList then
					frame.tabs[3].content.UpdatePriorityList()
				end
			else
				frame.tabs[i].content:Hide()
				frame.tabs[i].label:SetTextColor(0.5, 0.5, 0.5)
			end
		end
	end
end

local function LoadValues(frame)
	if not frame or not RoRota.db or not RoRota.db.profile then return end
	local p = RoRota.db.profile
	
	if frame.openerDD and p.opener and p.opener.ability then
		UIDropDownMenu_SetSelectedValue(frame.openerDD, p.opener.ability)
		UIDropDownMenu_SetText(p.opener.ability, frame.openerDD)
	end
	if frame.openerFailSlider and p.opener then
		frame.openerFailSlider:SetValue(p.opener.failsafeAttempts or -1)
	end
	if frame.secondaryDD and p.opener and p.opener.secondaryAbility then
		UIDropDownMenu_SetSelectedValue(frame.secondaryDD, p.opener.secondaryAbility)
		UIDropDownMenu_SetText(p.opener.secondaryAbility, frame.secondaryDD)
	end
	if frame.ppCheck and p.opener then
		frame.ppCheck:SetChecked(p.opener.pickPocket and 1 or nil)
	end
	if frame.sapFailDD and p.opener and p.opener.sapFailAction then
		UIDropDownMenu_SetSelectedValue(frame.sapFailDD, p.opener.sapFailAction)
		UIDropDownMenu_SetText(p.opener.sapFailAction, frame.sapFailDD)
	end
	
	if frame.mainBuilderDD and p.mainBuilder then
		UIDropDownMenu_SetSelectedValue(frame.mainBuilderDD, p.mainBuilder)
		UIDropDownMenu_SetText(p.mainBuilder, frame.mainBuilderDD)
	end
	if frame.builderFailSlider then
		frame.builderFailSlider:SetValue(p.builderFailsafe or -1)
	end
	if frame.secondaryBuilderDD and p.secondaryBuilder then
		UIDropDownMenu_SetSelectedValue(frame.secondaryBuilderDD, p.secondaryBuilder)
		UIDropDownMenu_SetText(p.secondaryBuilder, frame.secondaryBuilderDD)
	end
	if frame.riposteCheck and p.defensive then
		frame.riposteCheck:SetChecked(p.defensive.useRiposte and 1 or nil)
	end
	if frame.surpriseCheck and p.defensive then
		frame.surpriseCheck:SetChecked(p.defensive.useSurpriseAttack and 1 or nil)
	end
	if frame.hemorrhageCheck and p.abilities and p.abilities.Hemorrhage then
		frame.hemorrhageCheck:SetChecked(p.abilities.Hemorrhage.enabled and 1 or nil)
	end
	if frame.gsCheck and p.defensive then
		frame.gsCheck:SetChecked(p.defensive.useGhostlyStrike and 1 or nil)
	end
	if frame.gsTargetSlider and p.defensive then
		frame.gsTargetSlider:SetValue(p.defensive.ghostlyTargetMaxHP or 30)
	end
	if frame.gsPlayerMinSlider and p.defensive then
		frame.gsPlayerMinSlider:SetValue(p.defensive.ghostlyPlayerMinHP or 1)
	end
	if frame.gsPlayerMaxSlider and p.defensive then
		frame.gsPlayerMaxSlider:SetValue(p.defensive.ghostlyPlayerMaxHP or 90)
	end
	
	if frame.kickCheck and p.interrupt then
		frame.kickCheck:SetChecked(p.interrupt.useKick and 1 or nil)
	end
	if frame.gougeCheck and p.interrupt then
		frame.gougeCheck:SetChecked(p.interrupt.useGouge and 1 or nil)
	end
	if frame.ksCheck and p.interrupt then
		frame.ksCheck:SetChecked(p.interrupt.useKidneyShot and 1 or nil)
	end
	if frame.ksMaxSlider and p.interrupt then
		frame.ksMaxSlider:SetValue(p.interrupt.kidneyMaxCP or 2)
	end
	if frame.vanishCheck and p.defensive then
		frame.vanishCheck:SetChecked(p.defensive.useVanish and 1 or nil)
	end
	if frame.vanishSlider and p.defensive then
		frame.vanishSlider:SetValue(p.defensive.vanishHP or 20)
	end
	if frame.feintCheck and p.defensive then
		frame.feintCheck:SetChecked(p.defensive.useFeint and 1 or nil)
	end
	if frame.feintModeDD and p.defensive and p.defensive.feintMode then
		UIDropDownMenu_SetSelectedValue(frame.feintModeDD, p.defensive.feintMode)
		UIDropDownMenu_SetText(p.defensive.feintMode, frame.feintModeDD)
	end
	
	if frame.sndCheck and p.abilities and p.abilities.SliceAndDice then
		frame.sndCheck:SetChecked(p.abilities.SliceAndDice.enabled and 1 or nil)
	end
	if frame.sndMinSlider and p.abilities and p.abilities.SliceAndDice then
		frame.sndMinSlider:SetValue(p.abilities.SliceAndDice.minCP or 1)
	end
	if frame.sndMaxSlider and p.abilities and p.abilities.SliceAndDice then
		frame.sndMaxSlider:SetValue(p.abilities.SliceAndDice.maxCP or 2)
	end
	
	if frame.envCheck and p.abilities and p.abilities.Envenom then
		frame.envCheck:SetChecked(p.abilities.Envenom.enabled and 1 or nil)
	end
	if frame.envMinSlider and p.abilities and p.abilities.Envenom then
		frame.envMinSlider:SetValue(p.abilities.Envenom.minCP or 1)
	end
	if frame.envMaxSlider and p.abilities and p.abilities.Envenom then
		frame.envMaxSlider:SetValue(p.abilities.Envenom.maxCP or 2)
	end
	
	if frame.ruptCheck and p.abilities and p.abilities.Rupture then
		frame.ruptCheck:SetChecked(p.abilities.Rupture.enabled and 1 or nil)
	end
	if frame.ruptMinSlider and p.abilities and p.abilities.Rupture then
		frame.ruptMinSlider:SetValue(p.abilities.Rupture.minCP or 1)
	end
	if frame.ruptMaxSlider and p.abilities and p.abilities.Rupture then
		frame.ruptMaxSlider:SetValue(p.abilities.Rupture.maxCP or 5)
	end
	
	if frame.exposeCheck and p.abilities and p.abilities.ExposeArmor then
		frame.exposeCheck:SetChecked(p.abilities.ExposeArmor.enabled and 1 or nil)
	end
	if frame.exposeMinSlider and p.abilities and p.abilities.ExposeArmor then
		frame.exposeMinSlider:SetValue(p.abilities.ExposeArmor.minCP or 5)
	end
	if frame.exposeMaxSlider and p.abilities and p.abilities.ExposeArmor then
		frame.exposeMaxSlider:SetValue(p.abilities.ExposeArmor.maxCP or 5)
	end
	
	if frame.smartEvisCheck then
		frame.smartEvisCheck:SetChecked(p.smartEviscerate and 1 or nil)
	end
	if frame.smartRuptCheck then
		frame.smartRuptCheck:SetChecked(p.smartRupture and 1 or nil)
	end
	
	if frame.energyPoolCheck and p.energyPooling then
		frame.energyPoolCheck:SetChecked(p.energyPooling.enabled and 1 or nil)
	end
	if frame.energyPoolSlider and p.energyPooling then
		frame.energyPoolSlider:SetValue(p.energyPooling.threshold or 10)
	end
	
	if frame.autoApplyCheck and p.poisons then
		frame.autoApplyCheck:SetChecked(p.poisons.autoApply and 1 or nil)
	end
	if frame.applyInCombatCheck and p.poisons then
		frame.applyInCombatCheck:SetChecked(p.poisons.applyInCombat and 1 or nil)
	end
	if frame.mainHandPoisonDD and p.poisons and p.poisons.mainHandPoison then
		UIDropDownMenu_SetSelectedValue(frame.mainHandPoisonDD, p.poisons.mainHandPoison)
		UIDropDownMenu_SetText(p.poisons.mainHandPoison, frame.mainHandPoisonDD)
	end
	if frame.offHandPoisonDD and p.poisons and p.poisons.offHandPoison then
		UIDropDownMenu_SetSelectedValue(frame.offHandPoisonDD, p.poisons.offHandPoison)
		UIDropDownMenu_SetText(p.poisons.offHandPoison, frame.offHandPoisonDD)
	end
	if frame.poisonCheck and p.poisons then
		frame.poisonCheck:SetChecked(p.poisons.enabled and 1 or nil)
	end
	if frame.poisonTimeSlider and p.poisons then
		frame.poisonTimeSlider:SetValue(p.poisons.timeThreshold or 180)
	end
	if frame.poisonChargesSlider and p.poisons then
		frame.poisonChargesSlider:SetValue(p.poisons.chargesThreshold or 10)
	end
	
	if frame.autoSwitchCheck and RoRotaDB.autoSwitch then
		frame.autoSwitchCheck:SetChecked(RoRotaDB.autoSwitch.enabled and 1 or nil)
	end
	if frame.soloProfileDD and RoRotaDB.autoSwitch and RoRotaDB.autoSwitch.soloProfile then
		UIDropDownMenu_SetSelectedValue(frame.soloProfileDD, RoRotaDB.autoSwitch.soloProfile)
		UIDropDownMenu_SetText(RoRotaDB.autoSwitch.soloProfile, frame.soloProfileDD)
	end
	if frame.groupProfileDD and RoRotaDB.autoSwitch and RoRotaDB.autoSwitch.groupProfile then
		UIDropDownMenu_SetSelectedValue(frame.groupProfileDD, RoRotaDB.autoSwitch.groupProfile)
		UIDropDownMenu_SetText(RoRotaDB.autoSwitch.groupProfile, frame.groupProfileDD)
	end
	if frame.raidProfileDD and RoRotaDB.autoSwitch and RoRotaDB.autoSwitch.raidProfile then
		UIDropDownMenu_SetSelectedValue(frame.raidProfileDD, RoRotaDB.autoSwitch.raidProfile)
		UIDropDownMenu_SetText(RoRotaDB.autoSwitch.raidProfile, frame.raidProfileDD)
	end
end

function RoRota:CreateGUI()
	if RoRotaGUIFrame then return end
	
	local f = CreateFrame("Frame", "RoRotaGUIFrame", UIParent)
	f:SetWidth(520)
	f:SetHeight(600)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = {left = 11, right = 12, top = 12, bottom = 11}
	})
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() this:StartMoving() end)
	f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	f:SetScript("OnShow", function() LoadValues(this) end)
	table.insert(UISpecialFrames, "RoRotaGUIFrame")
	f:Hide()
	
	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", f, "TOP", 0, -20)
	title:SetText("RoRota Configuration v0.2")
	
	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
	
	local previewBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	previewBtn:SetWidth(150)
	previewBtn:SetHeight(25)
	previewBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 15)
	previewBtn:SetText("Toggle Rotation Preview")
	previewBtn:SetScript("OnClick", function()
		if RoRota.CreateRotationPreview then
			RoRota:CreateRotationPreview()
			if RoRotaPreviewFrame then
				if RoRotaPreviewFrame:IsVisible() then
					RoRotaPreviewFrame:Hide()
				else
					RoRotaPreviewFrame:Show()
				end
			end
		end
	end)
	
	f.tabs = {}
	local tabNames = {"Openers", "Builders", "Finishers", "Defensive", "Poisons", "Profiles"}
	for i = 1, 6 do
		local tab = CreateFrame("Button", nil, f)
		tab:SetWidth(78)
		tab:SetHeight(28)
		tab:SetPoint("TOPLEFT", f, "TOPLEFT", 20 + (i-1)*80, -50)
		tab:SetNormalTexture("Interface\\ChatFrame\\ChatFrameTab-BGLeft")
		tab.label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		tab.label:SetPoint("CENTER", tab, "CENTER", 0, -2)
		tab.label:SetText(tabNames[i])
		local idx = i
		tab:SetScript("OnClick", function() ShowTab(f, idx) end)
		f.tabs[i] = tab
	end
	
	local t1 = CreateFrame("Frame", nil, f)
	t1:SetAllPoints()
	f.tabs[1].content = t1
	
	CreateLabel(t1, 20, -100, "Main Opener:")
	local abilities = {"Ambush", "Garrote", "Cheap Shot", "Backstab", "Sinister Strike"}
	f.openerDD = CreateDropdown("RoRotaOpenerDD", t1, 200, -100, 150, abilities, function(value)
		if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
		RoRota.db.profile.opener.ability = value
	end)
	
	CreateLabel(t1, 20, -145, "Secondary Opener:")
	f.secondaryDD = CreateDropdown("RoRotaSecondaryDD", t1, 200, -145, 150, abilities, function(value)
		if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
		RoRota.db.profile.opener.secondaryAbility = value
	end)
	
	CreateLabel(t1, 20, -190, "Tries before Secondary:")
	f.openerFailSlider = CreateSlider("RoRotaOpenerFailSlider", t1, 200, -190, -1, 10, 1, 200, "-1", "10", "Tries", function(slider)
		if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
		local v = slider:GetValue()
		RoRota.db.profile.opener.failsafeAttempts = v
		getglobal(slider:GetName().."Text"):SetText(v == -1 and "No secondary" or "Tries: "..v)
	end)
	
	f.ppCheck = CreateCheck("RoRotaPPCheck", t1, 20, -240, "Try to Pick Pocket before opener", function()
		if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
		RoRota.db.profile.opener.pickPocket = (this:GetChecked() == 1)
	end)
	
	CreateLabel(t1, 20, -275, "Ability to cast after failed Sap:")
	local sapActions = {"None", "Vanish", "Sprint", "Evasion"}
	f.sapFailDD = CreateDropdown("RoRotaSapFailDD", t1, 200, -275, 150, sapActions, function(value)
		if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
		RoRota.db.profile.opener.sapFailAction = value
	end)
	
	local t2 = CreateFrame("Frame", nil, f)
	t2:SetAllPoints()
	t2:Hide()
	f.tabs[2].content = t2
	
	CreateLabel(t2, 20, -100, "Main Builder:")
	local builders = {"Sinister Strike", "Backstab", "Noxious Assault"}
	f.mainBuilderDD = CreateDropdown("RoRotaMainBuilderDD", t2, 200, -100, 150, builders, function(value)
		RoRota.db.profile.mainBuilder = value
	end)
	
	CreateLabel(t2, 20, -145, "Secondary Builder:")
	f.secondaryBuilderDD = CreateDropdown("RoRotaSecondaryBuilderDD", t2, 200, -145, 150, builders, function(value)
		RoRota.db.profile.secondaryBuilder = value
	end)
	
	CreateLabel(t2, 20, -190, "Tries before Secondary:")
	f.builderFailSlider = CreateSlider("RoRotaBuilderFailSlider", t2, 200, -190, -1, 10, 1, 200, "-1", "10", "Tries", function(slider)
		local v = slider:GetValue()
		RoRota.db.profile.builderFailsafe = v
		getglobal(slider:GetName().."Text"):SetText(v == -1 and "No secondary" or "Tries: "..v)
	end)
	
	f.riposteCheck = CreateCheck("RoRotaRiposteCheck", t2, 20, -240, "Use Riposte", function()
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.useRiposte = (this:GetChecked() == 1)
	end)
	
	f.surpriseCheck = CreateCheck("RoRotaSurpriseCheck", t2, 20, -270, "Use Surprise Attack", function()
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.useSurpriseAttack = (this:GetChecked() == 1)
	end)
	
	f.hemorrhageCheck = CreateCheck("RoRotaHemorrhageCheck", t2, 20, -300, "Use Hemorrhage", function()
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
		RoRota.db.profile.abilities.Hemorrhage.enabled = (this:GetChecked() == 1)
	end)
	
	f.gsCheck = CreateCheck("RoRotaGSCheck", t2, 20, -330, "Use Ghostly Strike", function()
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.useGhostlyStrike = (this:GetChecked() == 1)
	end)
	
	CreateLabel(t2, 200, -330, "Target Max HP:")
	f.gsTargetSlider = CreateSlider("RoRotaGSTargetSlider", t2, 290, -330, 1, 100, 1, 120, "1%", "100%", "HP", function(slider)
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		local v = slider:GetValue()
		RoRota.db.profile.defensive.ghostlyTargetMaxHP = v
		getglobal(slider:GetName().."Text"):SetText("Target: "..v.."%")
	end)
	
	CreateLabel(t2, 200, -370, "Player Min HP:")
	f.gsPlayerMinSlider = CreateSlider("RoRotaGSPlayerMinSlider", t2, 290, -370, 1, 100, 1, 120, "1%", "100%", "HP", function(slider)
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		local v = slider:GetValue()
		RoRota.db.profile.defensive.ghostlyPlayerMinHP = v
		getglobal(slider:GetName().."Text"):SetText("Min: "..v.."%")
	end)
	
	CreateLabel(t2, 200, -410, "Player Max HP:")
	f.gsPlayerMaxSlider = CreateSlider("RoRotaGSPlayerMaxSlider", t2, 290, -410, 1, 100, 1, 120, "1%", "100%", "HP", function(slider)
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		local v = slider:GetValue()
		RoRota.db.profile.defensive.ghostlyPlayerMaxHP = v
		getglobal(slider:GetName().."Text"):SetText("Max: "..v.."%")
	end)
	
	local t3 = CreateFrame("Frame", nil, f)
	t3:SetAllPoints()
	t3:Hide()
	f.tabs[3].content = t3
	
	f.sndCheck = CreateCheck("RoRotaSndCheck", t3, 20, -100, "Use Slice and Dice", function()
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
		RoRota.db.profile.abilities.SliceAndDice.enabled = (this:GetChecked() == 1)
	end)
	CreateLabel(t3, 200, -100, "Min CP:")
	f.sndMinSlider = CreateSlider("RoRotaSndMinSlider", t3, 260, -100, 1, 5, 1, 80, "1", "5", "Min", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
		RoRota.db.profile.abilities.SliceAndDice.minCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Min: "..slider:GetValue())
	end)
	CreateLabel(t3, 360, -100, "Max CP:")
	f.sndMaxSlider = CreateSlider("RoRotaSndMaxSlider", t3, 420, -100, 1, 5, 1, 80, "1", "5", "Max", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
		RoRota.db.profile.abilities.SliceAndDice.maxCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Max: "..slider:GetValue())
	end)
	
	f.envCheck = CreateCheck("RoRotaEnvCheck", t3, 20, -140, "Use Envenom", function()
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
		RoRota.db.profile.abilities.Envenom.enabled = (this:GetChecked() == 1)
	end)
	CreateLabel(t3, 200, -140, "Min CP:")
	f.envMinSlider = CreateSlider("RoRotaEnvMinSlider", t3, 260, -140, 1, 5, 1, 80, "1", "5", "Min", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
		RoRota.db.profile.abilities.Envenom.minCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Min: "..slider:GetValue())
	end)
	CreateLabel(t3, 360, -140, "Max CP:")
	f.envMaxSlider = CreateSlider("RoRotaEnvMaxSlider", t3, 420, -140, 1, 5, 1, 80, "1", "5", "Max", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
		RoRota.db.profile.abilities.Envenom.maxCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Max: "..slider:GetValue())
	end)
	
	f.ruptCheck = CreateCheck("RoRotaRuptCheck", t3, 20, -180, "Use Rupture", function()
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
		RoRota.db.profile.abilities.Rupture.enabled = (this:GetChecked() == 1)
	end)
	CreateLabel(t3, 200, -180, "Min CP:")
	f.ruptMinSlider = CreateSlider("RoRotaRuptMinSlider", t3, 260, -180, 1, 5, 1, 80, "1", "5", "Min", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
		RoRota.db.profile.abilities.Rupture.minCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Min: "..slider:GetValue())
	end)
	CreateLabel(t3, 360, -180, "Max CP:")
	f.ruptMaxSlider = CreateSlider("RoRotaRuptMaxSlider", t3, 420, -180, 1, 5, 1, 80, "1", "5", "Max", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
		RoRota.db.profile.abilities.Rupture.maxCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Max: "..slider:GetValue())
	end)
	
	f.exposeCheck = CreateCheck("RoRotaExposeCheck", t3, 20, -220, "Use Expose Armor", function()
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
		RoRota.db.profile.abilities.ExposeArmor.enabled = (this:GetChecked() == 1)
	end)
	CreateLabel(t3, 200, -220, "Min CP:")
	f.exposeMinSlider = CreateSlider("RoRotaExposeMinSlider", t3, 260, -220, 1, 5, 1, 80, "1", "5", "Min", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
		RoRota.db.profile.abilities.ExposeArmor.minCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Min: "..slider:GetValue())
	end)
	CreateLabel(t3, 360, -220, "Max CP:")
	f.exposeMaxSlider = CreateSlider("RoRotaExposeMaxSlider", t3, 420, -220, 1, 5, 1, 80, "1", "5", "Max", function(slider)
		if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
		if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
		RoRota.db.profile.abilities.ExposeArmor.maxCP = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Max: "..slider:GetValue())
	end)
	
	f.smartEvisCheck = CreateCheck("RoRotaSmartEvisCheck", t3, 20, -260, "Smart Eviscerate (kill at any CP)", function()
		RoRota.db.profile.smartEviscerate = (this:GetChecked() == 1)
	end)
	
	f.smartRuptCheck = CreateCheck("RoRotaSmartRuptCheck", t3, 20, -290, "Smart Rupture (skip if overkill)", function()
		RoRota.db.profile.smartRupture = (this:GetChecked() == 1)
	end)
	
	f.energyPoolCheck = CreateCheck("RoRotaEnergyPoolCheck", t3, 20, -320, "Energy Pooling", function()
		if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
		RoRota.db.profile.energyPooling.enabled = (this:GetChecked() == 1)
	end)
	CreateLabel(t3, 200, -320, "Threshold:")
	f.energyPoolSlider = CreateSlider("RoRotaEnergyPoolSlider", t3, 270, -320, 0, 30, 1, 120, "0", "30", "Energy", function(slider)
		if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
		RoRota.db.profile.energyPooling.threshold = slider:GetValue()
		getglobal(slider:GetName().."Text"):SetText("Threshold: "..slider:GetValue())
	end)
	
	CreateLabel(t3, 20, -370, "Finisher Priority Order:", "GameFontNormalLarge")
	local prioList = CreateFrame("Frame", nil, t3)
	prioList:SetPoint("TOPLEFT", t3, "TOPLEFT", 20, -400)
	prioList:SetWidth(200)
	prioList:SetHeight(120)
	local prioButtons = {}
	local selectedIndex = 1
	local function UpdatePriorityList()
		local prio = RoRota.db.profile.finisherPriority or {"Envenom", "SnD", "Rupture", "ExposeArmor"}
		for i = 1, 4 do
			if not prioButtons[i] then
				prioButtons[i] = CreateFrame("Button", nil, prioList)
				prioButtons[i]:SetWidth(180)
				prioButtons[i]:SetHeight(22)
				prioButtons[i]:SetPoint("TOPLEFT", prioList, "TOPLEFT", 0, -(i-1)*25)
				prioButtons[i]:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
				prioButtons[i]:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
				prioButtons[i].text = prioButtons[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				prioButtons[i].text:SetPoint("LEFT", prioButtons[i], "LEFT", 5, 0)
				prioButtons[i].index = i
				local idx = i
				prioButtons[i]:SetScript("OnClick", function() selectedIndex = idx UpdatePriorityList() end)
			end
			local finisher = prio[i]
			local name = finisher == "SnD" and "Slice and Dice" or finisher == "ExposeArmor" and "Expose Armor" or finisher
			prioButtons[i].text:SetText(i..". "..name)
			if i == selectedIndex then
				prioButtons[i].text:SetTextColor(1, 1, 0)
			else
				prioButtons[i].text:SetTextColor(1, 1, 1)
			end
		end
	end
	t3.UpdatePriorityList = UpdatePriorityList
	local upBtn = CreateFrame("Button", nil, t3, "UIPanelButtonTemplate")
	upBtn:SetWidth(60)
	upBtn:SetHeight(25)
	upBtn:SetPoint("TOPLEFT", t3, "TOPLEFT", 230, -405)
	upBtn:SetText("Up")
	upBtn:SetScript("OnClick", function()
		if selectedIndex > 1 then
			if not RoRota.db.profile.finisherPriority then
				RoRota.db.profile.finisherPriority = {"Envenom", "SnD", "Rupture", "ExposeArmor"}
			end
			local prio = RoRota.db.profile.finisherPriority
			local temp = prio[selectedIndex-1]
			prio[selectedIndex-1] = prio[selectedIndex]
			prio[selectedIndex] = temp
			selectedIndex = selectedIndex - 1
			UpdatePriorityList()
		end
	end)
	local downBtn = CreateFrame("Button", nil, t3, "UIPanelButtonTemplate")
	downBtn:SetWidth(60)
	downBtn:SetHeight(25)
	downBtn:SetPoint("TOPLEFT", t3, "TOPLEFT", 230, -435)
	downBtn:SetText("Down")
	downBtn:SetScript("OnClick", function()
		if selectedIndex < 4 then
			if not RoRota.db.profile.finisherPriority then
				RoRota.db.profile.finisherPriority = {"Envenom", "SnD", "Rupture", "ExposeArmor"}
			end
			local prio = RoRota.db.profile.finisherPriority
			local temp = prio[selectedIndex+1]
			prio[selectedIndex+1] = prio[selectedIndex]
			prio[selectedIndex] = temp
			selectedIndex = selectedIndex + 1
			UpdatePriorityList()
		end
	end)
	UpdatePriorityList()
	
	local t4 = CreateFrame("Frame", nil, f)
	t4:SetAllPoints()
	t4:Hide()
	f.tabs[4].content = t4
	
	CreateLabel(t4, 20, -100, "Interrupts", "GameFontNormalLarge")
	f.kickCheck = CreateCheck("RoRotaKickCheck", t4, 20, -130, "Use Kick", function()
		if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
		RoRota.db.profile.interrupt.useKick = (this:GetChecked() == 1)
	end)
	
	f.gougeCheck = CreateCheck("RoRotaGougeCheck", t4, 20, -160, "Use Gouge", function()
		if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
		RoRota.db.profile.interrupt.useGouge = (this:GetChecked() == 1)
	end)
	
	f.ksCheck = CreateCheck("RoRotaKSCheck", t4, 20, -190, "Use Kidney Shot", function()
		if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
		RoRota.db.profile.interrupt.useKidneyShot = (this:GetChecked() == 1)
	end)
	CreateLabel(t4, 200, -190, "Max CP:")
	f.ksMaxSlider = CreateSlider("RoRotaKSMaxSlider", t4, 260, -190, 1, 5, 1, 120, "1", "5", "CP", function(slider)
		if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
		local v = slider:GetValue()
		RoRota.db.profile.interrupt.kidneyMaxCP = v
		getglobal(slider:GetName().."Text"):SetText("Max CP: "..v)
	end)
	
	CreateLabel(t4, 20, -240, "Defensive", "GameFontNormalLarge")
	f.vanishCheck = CreateCheck("RoRotaVanishCheck", t4, 20, -270, "Use Vanish", function()
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.useVanish = (this:GetChecked() == 1)
	end)
	CreateLabel(t4, 200, -270, "HP Threshold:")
	f.vanishSlider = CreateSlider("RoRotaVanishSlider", t4, 290, -270, 1, 100, 1, 120, "1%", "100%", "HP", function(slider)
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		local v = slider:GetValue()
		RoRota.db.profile.defensive.vanishHP = v
		getglobal(slider:GetName().."Text"):SetText("HP: "..v.."%")
	end)
	
	f.feintCheck = CreateCheck("RoRotaFeintCheck", t4, 20, -310, "Use Feint (group/raid only)", function()
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.useFeint = (this:GetChecked() == 1)
	end)
	CreateLabel(t4, 240, -310, "Mode:")
	local feintModes = {"Always", "WhenTargeted", "HighThreat"}
	f.feintModeDD = CreateDropdown("RoRotaFeintModeDD", t4, 280, -310, 150, feintModes, function(value)
		if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
		RoRota.db.profile.defensive.feintMode = value
	end)
	
	local t5 = CreateFrame("Frame", nil, f)
	t5:SetAllPoints()
	t5:Hide()
	f.tabs[5].content = t5
	
	CreateLabel(t5, 20, -100, "Poison Auto-Application", "GameFontNormalLarge")
	f.autoApplyCheck = CreateCheck("RoRotaAutoApplyCheck", t5, 20, -130, "Auto-apply poisons", function()
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		RoRota.db.profile.poisons.autoApply = (this:GetChecked() == 1)
	end)
	
	f.applyInCombatCheck = CreateCheck("RoRotaApplyInCombatCheck", t5, 20, -160, "Allow in combat", function()
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		RoRota.db.profile.poisons.applyInCombat = (this:GetChecked() == 1)
	end)
	
	CreateLabel(t5, 20, -200, "Main Hand Poison:")
	local poisonTypes = {"None", "Agitating Poison", "Corrosive Poison", "Crippling Poison", "Deadly Poison", "Dissolvent Poison", "Instant Poison", "Mind-numbing Poison", "Wound Poison", "Sharpening Stone"}
	f.mainHandPoisonDD = CreateDropdown("RoRotaMainHandPoisonDD", t5, 160, -200, 180, poisonTypes, function(value)
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		RoRota.db.profile.poisons.mainHandPoison = value
	end)
	
	CreateLabel(t5, 20, -245, "Off Hand Poison:")
	f.offHandPoisonDD = CreateDropdown("RoRotaOffHandPoisonDD", t5, 160, -245, 180, poisonTypes, function(value)
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		RoRota.db.profile.poisons.offHandPoison = value
	end)
	
	CreateLabel(t5, 20, -300, "Poison Warnings", "GameFontNormalLarge")
	f.poisonCheck = CreateCheck("RoRotaPoisonCheck", t5, 20, -330, "Enable poison warnings", function()
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		RoRota.db.profile.poisons.enabled = (this:GetChecked() == 1)
	end)
	
	CreateLabel(t5, 20, -370, "Time Threshold:")
	f.poisonTimeSlider = CreateSlider("RoRotaPoisonTimeSlider", t5, 20, -400, 60, 600, 30, 220, "1m", "10m", "Time", function(slider)
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		local v = slider:GetValue()
		RoRota.db.profile.poisons.timeThreshold = v
		local m = math.floor(v / 60)
		getglobal(slider:GetName().."Text"):SetText("Warn at: "..m.." min")
	end)
	
	CreateLabel(t5, 20, -450, "Charges Threshold:")
	f.poisonChargesSlider = CreateSlider("RoRotaPoisonChargesSlider", t5, 20, -480, 5, 50, 5, 220, "5", "50", "Charges", function(slider)
		if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
		local v = slider:GetValue()
		RoRota.db.profile.poisons.chargesThreshold = v
		getglobal(slider:GetName().."Text"):SetText("Warn at: "..v.." charges")
	end)
	
	local testWarnBtn = CreateFrame("Button", nil, t5, "UIPanelButtonTemplate")
	testWarnBtn:SetWidth(120)
	testWarnBtn:SetHeight(25)
	testWarnBtn:SetPoint("TOPLEFT", t5, "TOPLEFT", 20, -530)
	testWarnBtn:SetText("Test Warning")
	testWarnBtn:SetScript("OnClick", function()
		if RoRota.CheckWeaponPoisons then
			RoRota:CheckWeaponPoisons(true)
		else
			RoRota:Print("Poison module not loaded")
		end
	end)
	
	local applyBtn = CreateFrame("Button", nil, t5, "UIPanelButtonTemplate")
	applyBtn:SetWidth(120)
	applyBtn:SetHeight(25)
	applyBtn:SetPoint("TOPLEFT", t5, "TOPLEFT", 150, -530)
	applyBtn:SetText("Apply Poisons")
	applyBtn:SetScript("OnClick", function()
		if RoRota.ApplyPoisonsManual then
			RoRota:ApplyPoisonsManual()
		else
			RoRota:Print("Poison applicator not loaded")
		end
	end)
	
	local t6 = CreateFrame("Frame", nil, f)
	t6:SetAllPoints()
	t6:Hide()
	f.tabs[6].content = t6
	
	CreateLabel(t6, 20, -100, "Profile Management", "GameFontNormalLarge")
	
	CreateLabel(t6, 20, -140, "Current Profile:")
	local function GetCurrentProfile()
		local charKey = UnitName("player").." - "..GetRealmName()
		return RoRotaDB.char and RoRotaDB.char[charKey] or "Default"
	end
	
	local function UpdateProfileDropdown()
		if not f.profileDD then return end
		local current = GetCurrentProfile()
		UIDropDownMenu_SetSelectedValue(f.profileDD, current)
		UIDropDownMenu_SetText(current, f.profileDD)
	end
	
	f.profileDD = CreateFrame("Frame", "RoRotaProfileDD", t6, "UIDropDownMenuTemplate")
	f.profileDD:SetPoint("TOPLEFT", t6, "TOPLEFT", 140, -145)
	UIDropDownMenu_SetWidth(200, f.profileDD)
	UIDropDownMenu_Initialize(f.profileDD, function()
		if not RoRotaDB.profiles then RoRotaDB.profiles = {} end
		if not RoRotaDB.profiles["Default"] then
			local function deepCopy(t)
				if type(t) ~= "table" then return t end
				local copy = {}
				for k, v in pairs(t) do
					copy[k] = deepCopy(v)
				end
				return copy
			end
			RoRotaDB.profiles["Default"] = deepCopy(RoRotaDefaultProfile)
		end
		
		local names = {}
		for profileName in pairs(RoRotaDB.profiles) do
			table.insert(names, profileName)
		end
		table.sort(names)
		
		local current = GetCurrentProfile()
		for _, pname in ipairs(names) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = pname
			info.value = pname
			info.checked = (pname == current)
			local localName = pname
			info.func = function()
				if not RoRotaDB.char then RoRotaDB.char = {} end
				local charKey = UnitName("player").." - "..GetRealmName()
				RoRotaDB.char[charKey] = localName
				RoRota:SetProfile(localName)
				RoRota:Print("Switched to profile: "..localName)
				UpdateProfileDropdown()
				if RoRotaGUIFrame and RoRotaGUIFrame:IsVisible() then
					LoadValues(RoRotaGUIFrame)
				end
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	UpdateProfileDropdown()
	
	local newBtn = CreateFrame("Button", nil, t6, "UIPanelButtonTemplate")
	newBtn:SetWidth(120)
	newBtn:SetHeight(25)
	newBtn:SetPoint("TOPLEFT", t6, "TOPLEFT", 20, -190)
	newBtn:SetText("New Profile")
	newBtn:SetScript("OnClick", function()
		StaticPopupDialogs["ROROTA_NEW_PROFILE"] = {
			text = "Enter new profile name:",
			button1 = "Create",
			button2 = "Cancel",
			hasEditBox = 1,
			maxLetters = 32,
			OnAccept = function()
				local name = getglobal(this:GetParent():GetName().."EditBox"):GetText()
				if name and name ~= "" then
					if RoRotaDB.profiles and RoRotaDB.profiles[name] then
						RoRota:Print("Profile '"..name.."' already exists.")
						return
					end
					if not RoRotaDB.profiles then RoRotaDB.profiles = {} end
					local function deepCopy(t)
						if type(t) ~= "table" then return t end
						local copy = {}
						for k, v in pairs(t) do
							copy[k] = deepCopy(v)
						end
						return copy
					end
					RoRotaDB.profiles[name] = deepCopy(RoRotaDefaultProfile)
					if not RoRotaDB.char then RoRotaDB.char = {} end
					local charKey = UnitName("player").." - "..GetRealmName()
					RoRotaDB.char[charKey] = name
					RoRota:SetProfile(name)
					RoRota:Print("Created new profile: "..name)
					UpdateProfileDropdown()
					if RoRotaGUIFrame then LoadValues(RoRotaGUIFrame) end
				end
			end,
			OnShow = function()
				getglobal(this:GetName().."EditBox"):SetFocus()
			end,
			EditBoxOnEnterPressed = function()
				local parent = this:GetParent()
				StaticPopupDialogs["ROROTA_NEW_PROFILE"].OnAccept()
				parent:Hide()
			end,
			EditBoxOnEscapePressed = function()
				this:GetParent():Hide()
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show("ROROTA_NEW_PROFILE")
	end)
	
	local deleteBtn = CreateFrame("Button", nil, t6, "UIPanelButtonTemplate")
	deleteBtn:SetWidth(120)
	deleteBtn:SetHeight(25)
	deleteBtn:SetPoint("TOPLEFT", t6, "TOPLEFT", 150, -190)
	deleteBtn:SetText("Delete Profile")
	
	CreateLabel(t6, 20, -240, "Auto-Switch Profiles", "GameFontNormalLarge")
	f.autoSwitchCheck = CreateCheck("RoRotaAutoSwitchCheck", t6, 20, -270, "Enable Auto-Switching", function()
		if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
		RoRotaDB.autoSwitch.enabled = (this:GetChecked() == 1)
	end)
	
	local function GetProfileNames()
		local names = {}
		if RoRotaDB and RoRotaDB.profiles then
			for pname in pairs(RoRotaDB.profiles) do
				table.insert(names, pname)
			end
			table.sort(names)
		end
		return names
	end
	
	CreateLabel(t6, 20, -310, "Solo Profile:")
	f.soloProfileDD = CreateFrame("Frame", "RoRotaSoloProfileDD", t6, "UIDropDownMenuTemplate")
	f.soloProfileDD:SetPoint("TOPLEFT", t6, "TOPLEFT", 120, -315)
	UIDropDownMenu_SetWidth(150, f.soloProfileDD)
	UIDropDownMenu_Initialize(f.soloProfileDD, function()
		local names = GetProfileNames()
		for _, pname in ipairs(names) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = pname
			info.value = pname
			local p = pname
			info.func = function()
				if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
				RoRotaDB.autoSwitch.soloProfile = p
				UIDropDownMenu_SetSelectedValue(f.soloProfileDD, p)
				UIDropDownMenu_SetText(p, f.soloProfileDD)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	CreateLabel(t6, 20, -350, "Group Profile:")
	f.groupProfileDD = CreateFrame("Frame", "RoRotaGroupProfileDD", t6, "UIDropDownMenuTemplate")
	f.groupProfileDD:SetPoint("TOPLEFT", t6, "TOPLEFT", 120, -355)
	UIDropDownMenu_SetWidth(150, f.groupProfileDD)
	UIDropDownMenu_Initialize(f.groupProfileDD, function()
		local names = GetProfileNames()
		for _, pname in ipairs(names) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = pname
			info.value = pname
			local p = pname
			info.func = function()
				if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
				RoRotaDB.autoSwitch.groupProfile = p
				UIDropDownMenu_SetSelectedValue(f.groupProfileDD, p)
				UIDropDownMenu_SetText(p, f.groupProfileDD)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	CreateLabel(t6, 20, -390, "Raid Profile:")
	f.raidProfileDD = CreateFrame("Frame", "RoRotaRaidProfileDD", t6, "UIDropDownMenuTemplate")
	f.raidProfileDD:SetPoint("TOPLEFT", t6, "TOPLEFT", 120, -395)
	UIDropDownMenu_SetWidth(150, f.raidProfileDD)
	UIDropDownMenu_Initialize(f.raidProfileDD, function()
		local names = GetProfileNames()
		for _, pname in ipairs(names) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = pname
			info.value = pname
			local p = pname
			info.func = function()
				if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
				RoRotaDB.autoSwitch.raidProfile = p
				UIDropDownMenu_SetSelectedValue(f.raidProfileDD, p)
				UIDropDownMenu_SetText(p, f.raidProfileDD)
			end
			UIDropDownMenu_AddButton(info)
		end
	end)
	
	deleteBtn:SetScript("OnClick", function()
		local current = GetCurrentProfile()
		local profileCount = 0
		if RoRotaDB and RoRotaDB.profiles then
			for _ in pairs(RoRotaDB.profiles) do
				profileCount = profileCount + 1
			end
		end
		if profileCount <= 1 then
			RoRota:Print("Cannot delete the last profile")
			return
		end
		
		StaticPopupDialogs["ROROTA_DELETE_PROFILE"] = {
			text = "Delete profile '"..current.."'?",
			button1 = "Delete",
			button2 = "Cancel",
			OnAccept = function()
				local charKey = UnitName("player").." - "..GetRealmName()
				local toDelete = RoRotaDB.char and RoRotaDB.char[charKey] or "Default"
				if RoRotaDB and RoRotaDB.profiles then
					local newProfile = nil
					for name in pairs(RoRotaDB.profiles) do
						if name ~= toDelete then
							newProfile = name
							break
						end
					end
					if newProfile then
						RoRotaDB.profiles[toDelete] = nil
						if not RoRotaDB.char then RoRotaDB.char = {} end
						RoRotaDB.char[charKey] = newProfile
						RoRota:SetProfile(newProfile)
						RoRota:Print("Deleted profile: "..toDelete)
						UpdateProfileDropdown()
						if RoRotaGUIFrame then LoadValues(RoRotaGUIFrame) end
					end
				end
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1
		}
		StaticPopup_Show("ROROTA_DELETE_PROFILE")
	end)
	
	ShowTab(f, 1)
end
