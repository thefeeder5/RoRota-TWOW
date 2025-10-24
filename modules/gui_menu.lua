--[[ gui_menu ]]--
-- Consolidated GUI menu file containing all tabs and subtabs

-- ============================================================================
-- ABOUT TAB
-- ============================================================================

function RoRotaGUI.CreateAboutTab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local y = -40
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    title:SetText("RoRota - Rogue One-Button Rotation")
    y = y - 30
    
    local version = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    version:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    version:SetText("Version " .. (RoRota.version or "Unknown"))
    y = y - 40
    
    local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    desc:SetText("A rotation helper addon for Rogues in Vanilla WoW.")
    y = y - 30
    
    local setupMsg = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setupMsg:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    setupMsg:SetText("For the addon to work you need to set up macros:")
    y = y - 30
    
    local rotationBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Create Rotation Macro")
    rotationBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    rotationBtn:SetScript("OnClick", function()
        local macroIndex = GetMacroIndexByName("RoRota")
        if macroIndex == 0 then
            CreateMacro("RoRota", 1, "/script RoRotaRunRotation()", 1, 1)
            RoRota:Print("Macro 'RoRota' created!")
        else
            EditMacro(macroIndex, "RoRota", 1, "/script RoRotaRunRotation()")
            RoRota:Print("Macro 'RoRota' updated!")
        end
    end)
    
    local poisonBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Create Poison Macro")
    poisonBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 210, y)
    poisonBtn:SetScript("OnClick", function()
        local macroIndex = GetMacroIndexByName("RoRotaPoison")
        if macroIndex == 0 then
            CreateMacro("RoRotaPoison", 1, "/script RoRotaApplyPoison()", 1, 1)
            RoRota:Print("Macro 'RoRotaPoison' created!")
        else
            EditMacro(macroIndex, "RoRotaPoison", 1, "/script RoRotaApplyPoison()")
            RoRota:Print("Macro 'RoRotaPoison' updated!")
        end
    end)
    y = y - 40
    
    local featuresTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    featuresTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    featuresTitle:SetText("Features:")
    y = y - 25
    
    local features = {
        "One-button rotation with smart ability selection",
        "Stealth opener system with failsafe",
        "Customizable finisher priority",
        "Energy pooling and smart features",
        "Poison management",
        "Profile system"
    }
    
    for _, feature in ipairs(features) do
        local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
        f:SetText("• " .. feature)
        y = y - 20
    end
    
    y = y - 20
    local commandsTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    commandsTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    commandsTitle:SetText("Commands:")
    y = y - 25
    
    local cmd1 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cmd1:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
    cmd1:SetText("/rr - Open settings")
    y = y - 20
    
    local cmd2 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cmd2:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
    cmd2:SetText("/rr preview - Toggle ability preview")
    y = y - 40
    
    local link = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    link:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    link:SetText("For more information, visit:")
    y = y - 20
    
    local github = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    github:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    github:SetText("github.com/thefeeder5/RoRota-TWOW")
    github:SetTextColor(0.2, 1, 0.8)
end

function RoRotaApplyPoison()
    if RoRota and RoRota.ApplyPoisonsManual then
        RoRota:ApplyPoisonsManual()
    end
end

function RoRotaGUI.LoadAboutTab(frame)
end

-- ============================================================================
-- OPENERS TAB
-- ============================================================================

function RoRotaGUI.CreateOpenersTab(parent, frame)
    local abilities = {"Ambush", "Garrote", "Cheap Shot", "Backstab", "Sinister Strike"}
    local sapActions = {"None", "Vanish", "Sprint", "Evasion"}
    local failsafeOptions = {"Disabled", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Main Opener")
    frame.openerDD = RoRotaGUI.CreateDropdown("RoRotaOpenerDD", parent, 350, y, 150, abilities, function(value)
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.ability = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Secondary Opener")
    frame.secondaryDD = RoRotaGUI.CreateDropdown("RoRotaSecondaryDD", parent, 350, y, 150, abilities, function(value)
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.secondaryAbility = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Failsafe Attempts")
    frame.openerFailDD = RoRotaGUI.CreateDropdown("RoRotaOpenerFailDD", parent, 350, y, 100, failsafeOptions, function(value)
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.failsafeAttempts = value == "Disabled" and -1 or tonumber(value)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Pick Pocket Before Opener")
    frame.ppCheck = RoRotaGUI.CreateCheckbox("RoRotaPPCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.pickPocket = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Cold Blood before Ambush")
    frame.coldBloodCheck = RoRotaGUI.CreateCheckbox("RoRotaColdBloodCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.useColdBlood = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "After Failed Sap")
    frame.sapFailDD = RoRotaGUI.CreateDropdown("RoRotaSapFailDD", parent, 350, y, 120, sapActions, function(value)
        if not RoRota.db.profile.opener then RoRota.db.profile.opener = {} end
        RoRota.db.profile.opener.sapFailAction = value
    end)
end

function RoRotaGUI.LoadOpenersTab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
    if frame.openerDD and p.opener and p.opener.ability then
        UIDropDownMenu_SetSelectedValue(frame.openerDD, p.opener.ability)
        UIDropDownMenu_SetText(p.opener.ability, frame.openerDD)
    end
    if frame.openerFailDD and p.opener then
        local val = p.opener.failsafeAttempts or -1
        local text = val == -1 and "Disabled" or tostring(val)
        UIDropDownMenu_SetSelectedValue(frame.openerFailDD, text)
        UIDropDownMenu_SetText(text, frame.openerFailDD)
    end
    if frame.secondaryDD and p.opener and p.opener.secondaryAbility then
        UIDropDownMenu_SetSelectedValue(frame.secondaryDD, p.opener.secondaryAbility)
        UIDropDownMenu_SetText(p.opener.secondaryAbility, frame.secondaryDD)
    end
    if frame.ppCheck and p.opener then
        frame.ppCheck:SetChecked(p.opener.pickPocket and 1 or nil)
    end
    if frame.coldBloodCheck and p.opener then
        frame.coldBloodCheck:SetChecked(p.opener.useColdBlood and 1 or nil)
    end
    if frame.sapFailDD and p.opener and p.opener.sapFailAction then
        UIDropDownMenu_SetSelectedValue(frame.sapFailDD, p.opener.sapFailAction)
        UIDropDownMenu_SetText(p.opener.sapFailAction, frame.sapFailDD)
    end
end

RoRotaGUIAboutLoaded = true
RoRotaGUIOpenersLoaded = true

-- ============================================================================
-- FINISHERS TAB (with subtabs)
-- ============================================================================

function RoRotaGUI.CreateFinishersTab(parent, frame)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(500)
    subtabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    subtabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    subtabBar:SetBackdropColor(0, 0, 0, 0.5)
    
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetWidth(390)
    contentArea:SetHeight(500)
    contentArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 90, 0)
    
    local subtabs = {"Global", "Slice\nand Dice", "Rupture", "Expose\nArmor", "Envenom", "Shadow\nof Death", "Eviscerate"}
    frame.finisherSubtabs = {}
    frame.finisherSubtabFrames = {}
    
    for i, name in ipairs(subtabs) do
        local index = i
        local btn = RoRotaGUI.CreateSubTab(subtabBar, -10 - (i-1)*33, name, function()
            RoRotaGUI.ShowFinisherSubTab(frame, index)
        end)
        frame.finisherSubtabs[i] = {button = btn, name = name}
        
        local subFrame = CreateFrame("Frame", nil, contentArea)
        subFrame:SetWidth(390)
        subFrame:SetHeight(500)
        subFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
        subFrame:Hide()
        frame.finisherSubtabFrames[i] = subFrame
    end
    
    frame.finisherSubtabFrames[1].widgets = {}
    frame.finisherSubtabFrames[2].widgets = {}
    frame.finisherSubtabFrames[3].widgets = {}
    frame.finisherSubtabFrames[4].widgets = {}
    frame.finisherSubtabFrames[5].widgets = {}
    frame.finisherSubtabFrames[6].widgets = {}
    frame.finisherSubtabFrames[7].widgets = {}
    
    if RoRotaGUI.CreateFinisherGlobalSubTab then
        RoRotaGUI.CreateFinisherGlobalSubTab(frame.finisherSubtabFrames[1], frame.finisherSubtabFrames[1].widgets)
    end
    if RoRotaGUI.CreateSndSubTab then
        RoRotaGUI.CreateSndSubTab(frame.finisherSubtabFrames[2], frame.finisherSubtabFrames[2].widgets)
    end
    if RoRotaGUI.CreateRuptureSubTab then
        RoRotaGUI.CreateRuptureSubTab(frame.finisherSubtabFrames[3], frame.finisherSubtabFrames[3].widgets)
    end
    if RoRotaGUI.CreateExposeSubTab then
        RoRotaGUI.CreateExposeSubTab(frame.finisherSubtabFrames[4], frame.finisherSubtabFrames[4].widgets)
    end
    if RoRotaGUI.CreateEnvenomSubTab then
        RoRotaGUI.CreateEnvenomSubTab(frame.finisherSubtabFrames[5], frame.finisherSubtabFrames[5].widgets)
    end
    if RoRotaGUI.CreateShadowOfDeathSubTab then
        RoRotaGUI.CreateShadowOfDeathSubTab(frame.finisherSubtabFrames[6], frame.finisherSubtabFrames[6].widgets)
    end
    if RoRotaGUI.CreateEviscerateSub then
        RoRotaGUI.CreateEviscerateSub(frame.finisherSubtabFrames[7], frame.finisherSubtabFrames[7].widgets)
    end
    
    RoRotaGUI.ShowFinisherSubTab(frame, 1)
end

function RoRotaGUI.ShowFinisherSubTab(frame, index)
    for i = 1, table.getn(frame.finisherSubtabFrames) do
        if i == index then
            frame.finisherSubtabFrames[i]:Show()
            RoRotaGUI.SetSubTabActive(frame.finisherSubtabs[i].button, true)
        else
            frame.finisherSubtabFrames[i]:Hide()
            RoRotaGUI.SetSubTabActive(frame.finisherSubtabs[i].button, false)
        end
    end
end 

function RoRotaGUI.LoadFinishersTab(frame)
    if not frame.finisherSubtabFrames then return end
    if RoRotaGUI.LoadFinisherGlobalSubTab and frame.finisherSubtabFrames[1] then 
        RoRotaGUI.LoadFinisherGlobalSubTab(frame.finisherSubtabFrames[1].widgets) 
    end
    if RoRotaGUI.LoadSndSubTab and frame.finisherSubtabFrames[2] then 
        RoRotaGUI.LoadSndSubTab(frame.finisherSubtabFrames[2].widgets) 
    end
    if RoRotaGUI.LoadRuptureSubTab and frame.finisherSubtabFrames[3] then 
        RoRotaGUI.LoadRuptureSubTab(frame.finisherSubtabFrames[3].widgets) 
    end
    if RoRotaGUI.LoadExposeSubTab and frame.finisherSubtabFrames[4] then 
        RoRotaGUI.LoadExposeSubTab(frame.finisherSubtabFrames[4].widgets) 
    end
    if RoRotaGUI.LoadEnvenomSubTab and frame.finisherSubtabFrames[5] then 
        RoRotaGUI.LoadEnvenomSubTab(frame.finisherSubtabFrames[5].widgets) 
    end
    if RoRotaGUI.LoadShadowOfDeathSubTab and frame.finisherSubtabFrames[6] then 
        RoRotaGUI.LoadShadowOfDeathSubTab(frame.finisherSubtabFrames[6].widgets) 
    end
    if RoRotaGUI.LoadEviscerateSub and frame.finisherSubtabFrames[7] then 
        RoRotaGUI.LoadEviscerateSub(frame.finisherSubtabFrames[7].widgets) 
    end
end

-- Finisher Global Subtab
function RoRotaGUI.CreateFinisherGlobalSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Finisher Priority")
    y = y - 25
    
    local finishers = {"Slice and Dice", "Envenom", "Rupture", "Expose Armor", "Shadow of Death", "Cold Blood Eviscerate"}
    widgets.priorityButtons = {}
    for i, name in ipairs(finishers) do
        local btn = RoRotaGUI.CreateButton(nil, parent, 140, 22, name)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
        btn.index = i
        btn.finisher = name
        widgets.priorityButtons[i] = btn
        
        local upBtn = RoRotaGUI.CreateButton(nil, parent, 25, 22, "↑")
        upBtn:SetPoint("LEFT", btn, "RIGHT", 3, 0)
        upBtn:SetScript("OnClick", function()
            if btn.index > 1 then
                local temp = finishers[btn.index]
                finishers[btn.index] = finishers[btn.index - 1]
                finishers[btn.index - 1] = temp
                RoRota.db.profile.finisherPriority = finishers
                if widgets.UpdatePriorityList then widgets.UpdatePriorityList() end
            end
        end)
        
        local downBtn = RoRotaGUI.CreateButton(nil, parent, 25, 22, "↓")
        downBtn:SetPoint("LEFT", upBtn, "RIGHT", 3, 0)
        downBtn:SetScript("OnClick", function()
            if btn.index < table.getn(finishers) then
                local temp = finishers[btn.index]
                finishers[btn.index] = finishers[btn.index + 1]
                finishers[btn.index + 1] = temp
                RoRota.db.profile.finisherPriority = finishers
                if widgets.UpdatePriorityList then widgets.UpdatePriorityList() end
            end
        end)
        
        y = y - 27
    end
    
    widgets.UpdatePriorityList = function()
        local priority = RoRota.db.profile.finisherPriority or finishers
        for i, btn in ipairs(widgets.priorityButtons) do
            btn:SetText(priority[i] or "")
            btn.finisher = priority[i]
            btn.index = i
        end
    end
    
    y = y - 10
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Energy Pooling Enable")
    widgets.energyPoolCheck = RoRotaGUI.CreateCheckbox("RoRotaEnergyPoolCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
        RoRota.db.profile.energyPooling.enabled = (this:GetChecked() == 1)
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Energy Pooling Threshold")
    widgets.energyPoolDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnergyPoolDD", parent, 260, y, 0, 30, 5, function(value)
        if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
        RoRota.db.profile.energyPooling.threshold = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Finisher Refresh Window (sec)")
    if RoRotaGUI.CreateDecimalEditBox then
        widgets.refreshThresholdEB = RoRotaGUI.CreateDecimalEditBox("RoRotaRefreshThresholdEB", parent, 260, y, 50, 0, 10, function(value)
            RoRota.db.profile.finisherRefreshThreshold = value
        end)
    else
        widgets.refreshThresholdEB = RoRotaGUI.CreateEditBox("RoRotaRefreshThresholdEB", parent, 175, y, 50, function(value)
            RoRota.db.profile.finisherRefreshThreshold = value
        end)
    end
end

function RoRotaGUI.LoadFinisherGlobalSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.energyPoolCheck and p.energyPooling then
        widgets.energyPoolCheck:SetChecked(p.energyPooling.enabled and 1 or nil)
    end
    if widgets.energyPoolDD and p.energyPooling then
        local val = p.energyPooling.threshold or 10
        UIDropDownMenu_SetSelectedValue(widgets.energyPoolDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.energyPoolDD)
    end
    if widgets.refreshThresholdEB then
        local val = p.finisherRefreshThreshold or 2
        widgets.refreshThresholdEB:SetText(string.format("%.1f", val))
    end
    if widgets.UpdatePriorityList then
        widgets.UpdatePriorityList()
    end
end

-- SnD Subtab
function RoRotaGUI.CreateSndSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Enable Slice and Dice")
    widgets.sndCheck = RoRotaGUI.CreateCheckbox("RoRotaSndCheckNew", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Minimum CP")
    widgets.sndMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaSndMinDDNew", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.minCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Maximum CP")
    widgets.sndMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaSndMaxDDNew", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.sndTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaSndTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.targetMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.sndTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaSndTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.targetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.sndUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaSndUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.sndTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaSndTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.sndTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaSndTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.sndElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaSndElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadSndSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.sndCheck and p.abilities and p.abilities.SliceAndDice then
        widgets.sndCheck:SetChecked(p.abilities.SliceAndDice.enabled and 1 or nil)
    end
    if widgets.sndMinDD and p.abilities and p.abilities.SliceAndDice then
        local val = p.abilities.SliceAndDice.minCP or 1
        UIDropDownMenu_SetSelectedValue(widgets.sndMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.sndMinDD)
    end
    if widgets.sndMaxDD and p.abilities and p.abilities.SliceAndDice then
        local val = p.abilities.SliceAndDice.maxCP or 2
        UIDropDownMenu_SetSelectedValue(widgets.sndMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.sndMaxDD)
    end
    if widgets.sndTargetMinEB and p.abilities and p.abilities.SliceAndDice then
        widgets.sndTargetMinEB:SetText(tostring(p.abilities.SliceAndDice.targetMinHP or 0))
    end
    if widgets.sndTargetMaxEB and p.abilities and p.abilities.SliceAndDice then
        widgets.sndTargetMaxEB:SetText(tostring(p.abilities.SliceAndDice.targetMaxHP or 100))
    end
    if widgets.sndUseFlatHPCheck and p.abilities and p.abilities.SliceAndDice then
        widgets.sndUseFlatHPCheck:SetChecked(p.abilities.SliceAndDice.useFlatHP and 1 or nil)
    end
    if widgets.sndTargetMinFlatEB and p.abilities and p.abilities.SliceAndDice then
        widgets.sndTargetMinFlatEB:SetText(tostring(p.abilities.SliceAndDice.targetMinHPFlat or 0))
    end
    if widgets.sndTargetMaxFlatEB and p.abilities and p.abilities.SliceAndDice then
        widgets.sndTargetMaxFlatEB:SetText(tostring(p.abilities.SliceAndDice.targetMaxHPFlat or 9999999))
    end
    if widgets.sndElitesCheck and p.abilities and p.abilities.SliceAndDice then
        widgets.sndElitesCheck:SetChecked(p.abilities.SliceAndDice.onlyElites and 1 or nil)
    end
end

-- Rupture Subtab
function RoRotaGUI.CreateRuptureSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Enable Rupture")
    widgets.ruptCheck = RoRotaGUI.CreateCheckbox("RoRotaRuptCheckNew", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Minimum CP")
    widgets.ruptMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMinDDNew", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.minCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Maximum CP")
    widgets.ruptMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMaxDDNew", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Smart Rupture")
    widgets.smartRuptCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartRuptCheckNew", parent, 260, y, "", function()
        RoRota.db.profile.smartRupture = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.ruptTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaRuptTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.targetMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.ruptTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaRuptTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.targetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.ruptUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaRuptUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.ruptTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaRuptTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.ruptTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaRuptTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.ruptElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaRuptElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.onlyElites = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Taste for Blood (bypass immunity)")
    widgets.ruptTasteCheck = RoRotaGUI.CreateCheckbox("RoRotaRuptTasteCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.tasteForBlood = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadRuptureSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.ruptCheck and p.abilities and p.abilities.Rupture then
        widgets.ruptCheck:SetChecked(p.abilities.Rupture.enabled and 1 or nil)
    end
    if widgets.ruptMinDD and p.abilities and p.abilities.Rupture then
        local val = p.abilities.Rupture.minCP or 1
        UIDropDownMenu_SetSelectedValue(widgets.ruptMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.ruptMinDD)
    end
    if widgets.ruptMaxDD and p.abilities and p.abilities.Rupture then
        local val = p.abilities.Rupture.maxCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.ruptMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.ruptMaxDD)
    end
    if widgets.smartRuptCheck then
        widgets.smartRuptCheck:SetChecked(p.smartRupture and 1 or nil)
    end
    if widgets.ruptTargetMinEB and p.abilities and p.abilities.Rupture then
        widgets.ruptTargetMinEB:SetText(tostring(p.abilities.Rupture.targetMinHP or 0))
    end
    if widgets.ruptTargetMaxEB and p.abilities and p.abilities.Rupture then
        widgets.ruptTargetMaxEB:SetText(tostring(p.abilities.Rupture.targetMaxHP or 100))
    end
    if widgets.ruptUseFlatHPCheck and p.abilities and p.abilities.Rupture then
        widgets.ruptUseFlatHPCheck:SetChecked(p.abilities.Rupture.useFlatHP and 1 or nil)
    end
    if widgets.ruptTargetMinFlatEB and p.abilities and p.abilities.Rupture then
        widgets.ruptTargetMinFlatEB:SetText(tostring(p.abilities.Rupture.targetMinHPFlat or 0))
    end
    if widgets.ruptTargetMaxFlatEB and p.abilities and p.abilities.Rupture then
        widgets.ruptTargetMaxFlatEB:SetText(tostring(p.abilities.Rupture.targetMaxHPFlat or 9999999))
    end
    if widgets.ruptElitesCheck and p.abilities and p.abilities.Rupture then
        widgets.ruptElitesCheck:SetChecked(p.abilities.Rupture.onlyElites and 1 or nil)
    end
    if widgets.ruptTasteCheck and p.abilities and p.abilities.Rupture then
        widgets.ruptTasteCheck:SetChecked(p.abilities.Rupture.tasteForBlood and 1 or nil)
    end
end

-- Expose Subtab
function RoRotaGUI.CreateExposeSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Enable Expose Armor")
    widgets.exposeCheck = RoRotaGUI.CreateCheckbox("RoRotaExposeCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Minimum CP")
    widgets.exposeMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMinDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.minCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Maximum CP")
    widgets.exposeMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMaxDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.exposeTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaExposeTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.targetMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.exposeTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaExposeTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.targetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.exposeUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaExposeUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.exposeTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaExposeTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.exposeTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaExposeTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.exposeElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaExposeElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadExposeSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.exposeCheck and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeCheck:SetChecked(p.abilities.ExposeArmor.enabled and 1 or nil)
    end
    if widgets.exposeMinDD and p.abilities and p.abilities.ExposeArmor then
        local val = p.abilities.ExposeArmor.minCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.exposeMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.exposeMinDD)
    end
    if widgets.exposeMaxDD and p.abilities and p.abilities.ExposeArmor then
        local val = p.abilities.ExposeArmor.maxCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.exposeMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.exposeMaxDD)
    end
    if widgets.exposeTargetMinEB and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeTargetMinEB:SetText(tostring(p.abilities.ExposeArmor.targetMinHP or 0))
    end
    if widgets.exposeTargetMaxEB and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeTargetMaxEB:SetText(tostring(p.abilities.ExposeArmor.targetMaxHP or 100))
    end
    if widgets.exposeUseFlatHPCheck and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeUseFlatHPCheck:SetChecked(p.abilities.ExposeArmor.useFlatHP and 1 or nil)
    end
    if widgets.exposeTargetMinFlatEB and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeTargetMinFlatEB:SetText(tostring(p.abilities.ExposeArmor.targetMinHPFlat or 0))
    end
    if widgets.exposeTargetMaxFlatEB and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeTargetMaxFlatEB:SetText(tostring(p.abilities.ExposeArmor.targetMaxHPFlat or 9999999))
    end
    if widgets.exposeElitesCheck and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeElitesCheck:SetChecked(p.abilities.ExposeArmor.onlyElites and 1 or nil)
    end
end

-- Envenom Subtab
function RoRotaGUI.CreateEnvenomSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Enable Envenom")
    widgets.envCheck = RoRotaGUI.CreateCheckbox("RoRotaEnvCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Minimum CP")
    widgets.envMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMinDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.minCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Maximum CP")
    widgets.envMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMaxDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.envTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaEnvTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.targetMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.envTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaEnvTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.targetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.envUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaEnvUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.envTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaEnvTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.envTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaEnvTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.envElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaEnvElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadEnvenomSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.envCheck and p.abilities and p.abilities.Envenom then
        widgets.envCheck:SetChecked(p.abilities.Envenom.enabled and 1 or nil)
    end
    if widgets.envMinDD and p.abilities and p.abilities.Envenom then
        local val = p.abilities.Envenom.minCP or 1
        UIDropDownMenu_SetSelectedValue(widgets.envMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.envMinDD)
    end
    if widgets.envMaxDD and p.abilities and p.abilities.Envenom then
        local val = p.abilities.Envenom.maxCP or 2
        UIDropDownMenu_SetSelectedValue(widgets.envMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.envMaxDD)
    end
    if widgets.envTargetMinEB and p.abilities and p.abilities.Envenom then
        widgets.envTargetMinEB:SetText(tostring(p.abilities.Envenom.targetMinHP or 0))
    end
    if widgets.envTargetMaxEB and p.abilities and p.abilities.Envenom then
        widgets.envTargetMaxEB:SetText(tostring(p.abilities.Envenom.targetMaxHP or 100))
    end
    if widgets.envUseFlatHPCheck and p.abilities and p.abilities.Envenom then
        widgets.envUseFlatHPCheck:SetChecked(p.abilities.Envenom.useFlatHP and 1 or nil)
    end
    if widgets.envTargetMinFlatEB and p.abilities and p.abilities.Envenom then
        widgets.envTargetMinFlatEB:SetText(tostring(p.abilities.Envenom.targetMinHPFlat or 0))
    end
    if widgets.envTargetMaxFlatEB and p.abilities and p.abilities.Envenom then
        widgets.envTargetMaxFlatEB:SetText(tostring(p.abilities.Envenom.targetMaxHPFlat or 9999999))
    end
    if widgets.envElitesCheck and p.abilities and p.abilities.Envenom then
        widgets.envElitesCheck:SetChecked(p.abilities.Envenom.onlyElites and 1 or nil)
    end
end

-- Shadow of Death Subtab
function RoRotaGUI.CreateShadowOfDeathSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Enable Shadow of Death")
    widgets.shadowCheck = RoRotaGUI.CreateCheckbox("RoRotaShadowCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Minimum CP")
    widgets.shadowMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaShadowMinDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.minCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Maximum CP")
    widgets.shadowMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaShadowMaxDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.shadowTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaShadowTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.targetMinHP = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.shadowTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaShadowTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.targetMaxHP = tonumber(value) or 100
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.shadowUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaShadowUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.shadowTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaShadowTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.shadowTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaShadowTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.shadowElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaShadowElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ShadowOfDeath then RoRota.db.profile.abilities.ShadowOfDeath = {} end
        RoRota.db.profile.abilities.ShadowOfDeath.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadShadowOfDeathSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.shadowCheck and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowCheck:SetChecked(p.abilities.ShadowOfDeath.enabled and 1 or nil)
    end
    if widgets.shadowMinDD and p.abilities and p.abilities.ShadowOfDeath then
        local val = p.abilities.ShadowOfDeath.minCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.shadowMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.shadowMinDD)
    end
    if widgets.shadowMaxDD and p.abilities and p.abilities.ShadowOfDeath then
        local val = p.abilities.ShadowOfDeath.maxCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.shadowMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.shadowMaxDD)
    end
    if widgets.shadowTargetMinEB and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowTargetMinEB:SetText(tostring(p.abilities.ShadowOfDeath.targetMinHP or 0))
    end
    if widgets.shadowTargetMaxEB and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowTargetMaxEB:SetText(tostring(p.abilities.ShadowOfDeath.targetMaxHP or 100))
    end
    if widgets.shadowUseFlatHPCheck and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowUseFlatHPCheck:SetChecked(p.abilities.ShadowOfDeath.useFlatHP and 1 or nil)
    end
    if widgets.shadowTargetMinFlatEB and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowTargetMinFlatEB:SetText(tostring(p.abilities.ShadowOfDeath.targetMinHPFlat or 0))
    end
    if widgets.shadowTargetMaxFlatEB and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowTargetMaxFlatEB:SetText(tostring(p.abilities.ShadowOfDeath.targetMaxHPFlat or 9999999))
    end
    if widgets.shadowElitesCheck and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowElitesCheck:SetChecked(p.abilities.ShadowOfDeath.onlyElites and 1 or nil)
    end
end

-- Eviscerate Subtab
function RoRotaGUI.CreateEviscerateSub(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use CB Eviscerate (finisher)")
    widgets.cbEvisFinisherCheck = RoRotaGUI.CreateCheckbox("RoRotaCBEvisFinisherCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ColdBloodEviscerate then RoRota.db.profile.abilities.ColdBloodEviscerate = {} end
        RoRota.db.profile.abilities.ColdBloodEviscerate.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Eviscerate-to-kill (execute)")
    widgets.smartEvisCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartEvisCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.smartEviscerate = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "CB before execute Eviscerate")
    widgets.coldBloodCheck = RoRotaGUI.CreateCheckbox("RoRotaColdBloodEvisCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.useColdBlood = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Cold Blood Min CP")
    widgets.coldBloodMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaColdBloodMinDDEvis", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.coldBloodMinCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.evisTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaEvisTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.targetMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.evisTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaEvisTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.targetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Flat HP Checks")
    widgets.evisUseFlatHPCheck = RoRotaGUI.CreateCheckbox("RoRotaEvisUseFlatHPCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.useFlatHP = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP (flat)")
    widgets.evisTargetMinFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaEvisTargetMinFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.targetMinHPFlat = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP (flat)")
    widgets.evisTargetMaxFlatEB = RoRotaGUI.CreateFlatHPEditBox("RoRotaEvisTargetMaxFlatEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.targetMaxHPFlat = tonumber(value) or 9999999
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.evisElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaEvisElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Eviscerate then RoRota.db.profile.abilities.Eviscerate = {} end
        RoRota.db.profile.abilities.Eviscerate.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadEviscerateSub(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.cbEvisFinisherCheck and p.abilities and p.abilities.ColdBloodEviscerate then
        widgets.cbEvisFinisherCheck:SetChecked(p.abilities.ColdBloodEviscerate.enabled and 1 or nil)
    end
    if widgets.smartEvisCheck and p.abilities and p.abilities.Eviscerate then
        widgets.smartEvisCheck:SetChecked(p.abilities.Eviscerate.smartEviscerate and 1 or nil)
    end
    if widgets.coldBloodCheck and p.abilities and p.abilities.Eviscerate then
        widgets.coldBloodCheck:SetChecked(p.abilities.Eviscerate.useColdBlood and 1 or nil)
    end
    if widgets.coldBloodMinDD and p.abilities and p.abilities.Eviscerate then
        local val = p.abilities.Eviscerate.coldBloodMinCP or 4
        UIDropDownMenu_SetSelectedValue(widgets.coldBloodMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.coldBloodMinDD)
    end
    if widgets.evisTargetMinEB and p.abilities and p.abilities.Eviscerate then
        widgets.evisTargetMinEB:SetText(tostring(p.abilities.Eviscerate.targetMinHP or 0))
    end
    if widgets.evisTargetMaxEB and p.abilities and p.abilities.Eviscerate then
        widgets.evisTargetMaxEB:SetText(tostring(p.abilities.Eviscerate.targetMaxHP or 100))
    end
    if widgets.evisUseFlatHPCheck and p.abilities and p.abilities.Eviscerate then
        widgets.evisUseFlatHPCheck:SetChecked(p.abilities.Eviscerate.useFlatHP and 1 or nil)
    end
    if widgets.evisTargetMinFlatEB and p.abilities and p.abilities.Eviscerate then
        widgets.evisTargetMinFlatEB:SetText(tostring(p.abilities.Eviscerate.targetMinHPFlat or 0))
    end
    if widgets.evisTargetMaxFlatEB and p.abilities and p.abilities.Eviscerate then
        widgets.evisTargetMaxFlatEB:SetText(tostring(p.abilities.Eviscerate.targetMaxHPFlat or 9999999))
    end
    if widgets.evisElitesCheck and p.abilities and p.abilities.Eviscerate then
        widgets.evisElitesCheck:SetChecked(p.abilities.Eviscerate.onlyElites and 1 or nil)
    end
end

RoRotaGUIFinishersLoaded = true

-- ============================================================================
-- BUILDERS TAB (with subtabs)
-- ============================================================================

function RoRotaGUI.CreateBuildersTab(parent, frame)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(500)
    subtabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    subtabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    subtabBar:SetBackdropColor(0, 0, 0, 0.5)
    
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetWidth(390)
    contentArea:SetHeight(500)
    contentArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 90, 0)
    
    local subtabs = {"Global", "Riposte", "Surprise\nAttack", "Mark\nfor Death", "Hemorrhage", "Ghostly\nStrike"}
    frame.builderSubtabs = {}
    frame.builderSubtabFrames = {}
    
    for i, name in ipairs(subtabs) do
        local index = i
        local btn = RoRotaGUI.CreateSubTab(subtabBar, -10 - (i-1)*33, name, function()
            RoRotaGUI.ShowBuilderSubTab(frame, index)
        end)
        frame.builderSubtabs[i] = {button = btn, name = name}
        
        local subFrame = CreateFrame("Frame", nil, contentArea)
        subFrame:SetWidth(390)
        subFrame:SetHeight(500)
        subFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
        subFrame:Hide()
        frame.builderSubtabFrames[i] = subFrame
    end
    
    frame.builderSubtabFrames[1].widgets = {}
    frame.builderSubtabFrames[2].widgets = {}
    frame.builderSubtabFrames[3].widgets = {}
    frame.builderSubtabFrames[4].widgets = {}
    frame.builderSubtabFrames[5].widgets = {}
    frame.builderSubtabFrames[6].widgets = {}
    
    if RoRotaGUI.CreateBuilderGlobalSubTab then RoRotaGUI.CreateBuilderGlobalSubTab(frame.builderSubtabFrames[1], frame.builderSubtabFrames[1].widgets) end
    if RoRotaGUI.CreateRiposteSubTab then RoRotaGUI.CreateRiposteSubTab(frame.builderSubtabFrames[2], frame.builderSubtabFrames[2].widgets) end
    if RoRotaGUI.CreateSurpriseSubTab then RoRotaGUI.CreateSurpriseSubTab(frame.builderSubtabFrames[3], frame.builderSubtabFrames[3].widgets) end
    if RoRotaGUI.CreateMarkForDeathSubTab then RoRotaGUI.CreateMarkForDeathSubTab(frame.builderSubtabFrames[4], frame.builderSubtabFrames[4].widgets) end
    if RoRotaGUI.CreateHemorrhageSubTab then RoRotaGUI.CreateHemorrhageSubTab(frame.builderSubtabFrames[5], frame.builderSubtabFrames[5].widgets) end
    if RoRotaGUI.CreateGhostlySubTab then RoRotaGUI.CreateGhostlySubTab(frame.builderSubtabFrames[6], frame.builderSubtabFrames[6].widgets) end
    
    RoRotaGUI.ShowBuilderSubTab(frame, 1)
end

function RoRotaGUI.ShowBuilderSubTab(frame, index)
    for i = 1, table.getn(frame.builderSubtabFrames) do
        if i == index then
            frame.builderSubtabFrames[i]:Show()
            RoRotaGUI.SetSubTabActive(frame.builderSubtabs[i].button, true)
        else
            frame.builderSubtabFrames[i]:Hide()
            RoRotaGUI.SetSubTabActive(frame.builderSubtabs[i].button, false)
        end
    end
end

function RoRotaGUI.LoadBuildersTab(frame)
    if not frame.builderSubtabFrames then return end
    if RoRotaGUI.LoadBuilderGlobalSubTab and frame.builderSubtabFrames[1] then RoRotaGUI.LoadBuilderGlobalSubTab(frame.builderSubtabFrames[1].widgets) end
    if RoRotaGUI.LoadRiposteSubTab and frame.builderSubtabFrames[2] then RoRotaGUI.LoadRiposteSubTab(frame.builderSubtabFrames[2].widgets) end
    if RoRotaGUI.LoadSurpriseSubTab and frame.builderSubtabFrames[3] then RoRotaGUI.LoadSurpriseSubTab(frame.builderSubtabFrames[3].widgets) end
    if RoRotaGUI.LoadMarkForDeathSubTab and frame.builderSubtabFrames[4] then RoRotaGUI.LoadMarkForDeathSubTab(frame.builderSubtabFrames[4].widgets) end
    if RoRotaGUI.LoadHemorrhageSubTab and frame.builderSubtabFrames[5] then RoRotaGUI.LoadHemorrhageSubTab(frame.builderSubtabFrames[5].widgets) end
    if RoRotaGUI.LoadGhostlySubTab and frame.builderSubtabFrames[6] then RoRotaGUI.LoadGhostlySubTab(frame.builderSubtabFrames[6].widgets) end
end

-- Builder Global Subtab
function RoRotaGUI.CreateBuilderGlobalSubTab(parent, widgets)
    local y = -20
    local builders = {"Sinister Strike", "Backstab", "Noxious Assault"}
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Main Builder")
    widgets.mainBuilderDD = RoRotaGUI.CreateDropdown("RoRotaMainBuilderDD", parent, 150, y, 150, builders, function(value)
        RoRota.db.profile.mainBuilder = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Secondary Builder")
    widgets.secondaryBuilderDD = RoRotaGUI.CreateDropdown("RoRotaSecondaryBuilderDD", parent, 150, y, 150, builders, function(value)
        RoRota.db.profile.secondaryBuilder = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Failsafe Attempts")
    widgets.builderFailDD = RoRotaGUI.CreateDropdownNumeric("RoRotaBuilderFailDD", parent, 260, y, 1, 10, 1, function(value)
        RoRota.db.profile.builderFailsafe = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Sync with Swings")
    widgets.smartBuildersCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartBuildersCheck", parent, 260, y, "", function()
        RoRota.db.profile.smartBuilders = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadBuilderGlobalSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.mainBuilderDD and p.mainBuilder then
        UIDropDownMenu_SetSelectedValue(widgets.mainBuilderDD, p.mainBuilder)
        UIDropDownMenu_SetText(p.mainBuilder, widgets.mainBuilderDD)
    end
    if widgets.secondaryBuilderDD and p.secondaryBuilder then
        UIDropDownMenu_SetSelectedValue(widgets.secondaryBuilderDD, p.secondaryBuilder)
        UIDropDownMenu_SetText(p.secondaryBuilder, widgets.secondaryBuilderDD)
    end
    if widgets.builderFailDD then
        local val = p.builderFailsafe or -1
        UIDropDownMenu_SetSelectedValue(widgets.builderFailDD, val)
        UIDropDownMenu_SetText(val == -1 and "Disabled" or tostring(val), widgets.builderFailDD)
    end
    if widgets.smartBuildersCheck then
        widgets.smartBuildersCheck:SetChecked(p.smartBuilders and 1 or nil)
    end
end

-- Riposte Subtab
function RoRotaGUI.CreateRiposteSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Riposte")
    widgets.riposteCheck = RoRotaGUI.CreateCheckbox("RoRotaRiposteCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useRiposte = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.riposteTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaRiposteTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.riposteTargetMinHP = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.riposteTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaRiposteTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.riposteTargetMaxHP = tonumber(value) or 100
    end)
end

function RoRotaGUI.LoadRiposteSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.riposteCheck and p.defensive then
        widgets.riposteCheck:SetChecked(p.defensive.useRiposte and 1 or nil)
    end
    if widgets.riposteTargetMinEB and p.defensive then
        widgets.riposteTargetMinEB:SetText(tostring(p.defensive.riposteTargetMinHP or 0))
    end
    if widgets.riposteTargetMaxEB and p.defensive then
        widgets.riposteTargetMaxEB:SetText(tostring(p.defensive.riposteTargetMaxHP or 100))
    end
end

-- Surprise Subtab
function RoRotaGUI.CreateSurpriseSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Surprise Attack")
    widgets.surpriseCheck = RoRotaGUI.CreateCheckbox("RoRotaSurpriseCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useSurpriseAttack = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.surpriseTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaSurpriseTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.surpriseTargetMinHP = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.surpriseTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaSurpriseTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.surpriseTargetMaxHP = tonumber(value) or 100
    end)
end

function RoRotaGUI.LoadSurpriseSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.surpriseCheck and p.defensive then
        widgets.surpriseCheck:SetChecked(p.defensive.useSurpriseAttack and 1 or nil)
    end
    if widgets.surpriseTargetMinEB and p.defensive then
        widgets.surpriseTargetMinEB:SetText(tostring(p.defensive.surpriseTargetMinHP or 0))
    end
    if widgets.surpriseTargetMaxEB and p.defensive then
        widgets.surpriseTargetMaxEB:SetText(tostring(p.defensive.surpriseTargetMaxHP or 100))
    end
end

-- Mark for Death Subtab
function RoRotaGUI.CreateMarkForDeathSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Mark for Death")
    widgets.markCheck = RoRotaGUI.CreateCheckbox("RoRotaMarkCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.MarkForDeath then RoRota.db.profile.abilities.MarkForDeath = {} end
        RoRota.db.profile.abilities.MarkForDeath.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.markTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaMarkTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.MarkForDeath then RoRota.db.profile.abilities.MarkForDeath = {} end
        RoRota.db.profile.abilities.MarkForDeath.targetMinHP = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.markTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaMarkTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.MarkForDeath then RoRota.db.profile.abilities.MarkForDeath = {} end
        RoRota.db.profile.abilities.MarkForDeath.targetMaxHP = tonumber(value) or 100
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.markElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaMarkElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.MarkForDeath then RoRota.db.profile.abilities.MarkForDeath = {} end
        RoRota.db.profile.abilities.MarkForDeath.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadMarkForDeathSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.markCheck and p.abilities and p.abilities.MarkForDeath then
        widgets.markCheck:SetChecked(p.abilities.MarkForDeath.enabled and 1 or nil)
    end
    if widgets.markTargetMinEB and p.abilities and p.abilities.MarkForDeath then
        widgets.markTargetMinEB:SetText(tostring(p.abilities.MarkForDeath.targetMinHP or 0))
    end
    if widgets.markTargetMaxEB and p.abilities and p.abilities.MarkForDeath then
        widgets.markTargetMaxEB:SetText(tostring(p.abilities.MarkForDeath.targetMaxHP or 100))
    end
    if widgets.markElitesCheck and p.abilities and p.abilities.MarkForDeath then
        widgets.markElitesCheck:SetChecked(p.abilities.MarkForDeath.onlyElites and 1 or nil)
    end
end

-- Hemorrhage Subtab
function RoRotaGUI.CreateHemorrhageSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Hemorrhage")
    widgets.hemorrhageCheck = RoRotaGUI.CreateCheckbox("RoRotaHemorrhageCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only when debuff missing")
    widgets.hemorrhageMissingCheck = RoRotaGUI.CreateCheckbox("RoRotaHemorrhageMissingCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.onlyWhenMissing = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Min HP %")
    widgets.hemorrhageTargetMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaHemorrhageTargetMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.targetMinHP = tonumber(value) or 0
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.hemorrhageTargetMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaHemorrhageTargetMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.targetMaxHP = tonumber(value) or 100
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Only use on Elites")
    widgets.hemorrhageElitesCheck = RoRotaGUI.CreateCheckbox("RoRotaHemorrhageElitesCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.onlyElites = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadHemorrhageSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.hemorrhageCheck and p.abilities and p.abilities.Hemorrhage then
        widgets.hemorrhageCheck:SetChecked(p.abilities.Hemorrhage.enabled and 1 or nil)
    end
    if widgets.hemorrhageMissingCheck and p.abilities and p.abilities.Hemorrhage then
        widgets.hemorrhageMissingCheck:SetChecked(p.abilities.Hemorrhage.onlyWhenMissing and 1 or nil)
    end
    if widgets.hemorrhageTargetMinEB and p.abilities and p.abilities.Hemorrhage then
        widgets.hemorrhageTargetMinEB:SetText(tostring(p.abilities.Hemorrhage.targetMinHP or 0))
    end
    if widgets.hemorrhageTargetMaxEB and p.abilities and p.abilities.Hemorrhage then
        widgets.hemorrhageTargetMaxEB:SetText(tostring(p.abilities.Hemorrhage.targetMaxHP or 100))
    end
    if widgets.hemorrhageElitesCheck and p.abilities and p.abilities.Hemorrhage then
        widgets.hemorrhageElitesCheck:SetChecked(p.abilities.Hemorrhage.onlyElites and 1 or nil)
    end
end

-- Ghostly Subtab
function RoRotaGUI.CreateGhostlySubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Ghostly Strike")
    widgets.gsCheck = RoRotaGUI.CreateCheckbox("RoRotaGSCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useGhostlyStrike = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Target Max HP %")
    widgets.gsTargetEB = RoRotaGUI.CreatePercentEditBox("RoRotaGSTargetEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyTargetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Player Min HP %")
    widgets.gsPlayerMinEB = RoRotaGUI.CreatePercentEditBox("RoRotaGSPlayerMinEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyPlayerMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Player Max HP %")
    widgets.gsPlayerMaxEB = RoRotaGUI.CreatePercentEditBox("RoRotaGSPlayerMaxEB", parent, 175, y, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyPlayerMaxHP = value
    end)
end

function RoRotaGUI.LoadGhostlySubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.gsCheck and p.defensive then
        widgets.gsCheck:SetChecked(p.defensive.useGhostlyStrike and 1 or nil)
    end
    if widgets.gsTargetEB and p.defensive then
        widgets.gsTargetEB:SetText(tostring(p.defensive.ghostlyTargetMaxHP or 30))
    end
    if widgets.gsPlayerMinEB and p.defensive then
        widgets.gsPlayerMinEB:SetText(tostring(p.defensive.ghostlyPlayerMinHP or 1))
    end
    if widgets.gsPlayerMaxEB and p.defensive then
        widgets.gsPlayerMaxEB:SetText(tostring(p.defensive.ghostlyPlayerMaxHP or 90))
    end
end

RoRotaGUIBuildersLoaded = true

-- ============================================================================
-- DEFENSIVE TAB (with subtabs)
-- ============================================================================

function RoRotaGUI.CreateDefensiveTab(parent, frame)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(500)
    subtabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    subtabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    subtabBar:SetBackdropColor(0, 0, 0, 0.5)
    
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetWidth(390)
    contentArea:SetHeight(500)
    contentArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 90, 0)
    
    local subtabs = {"Global", "Interrupts", "Survival"}
    frame.defensiveSubtabs = {}
    frame.defensiveSubtabFrames = {}
    
    for i, name in ipairs(subtabs) do
        local index = i
        local btn = RoRotaGUI.CreateSubTab(subtabBar, -10 - (i-1)*33, name, function()
            RoRotaGUI.ShowDefensiveSubTab(frame, index)
        end)
        frame.defensiveSubtabs[i] = {button = btn, name = name}
        
        local subFrame = CreateFrame("Frame", nil, contentArea)
        subFrame:SetWidth(390)
        subFrame:SetHeight(500)
        subFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
        subFrame:Hide()
        frame.defensiveSubtabFrames[i] = subFrame
    end
    
    frame.defensiveSubtabFrames[1].widgets = {}
    frame.defensiveSubtabFrames[2].widgets = {}
    frame.defensiveSubtabFrames[3].widgets = {}
    
    if RoRotaGUI.CreateDefensiveGlobalSubTab then RoRotaGUI.CreateDefensiveGlobalSubTab(frame.defensiveSubtabFrames[1], frame.defensiveSubtabFrames[1].widgets) end
    if RoRotaGUI.CreateInterruptsSubTab then RoRotaGUI.CreateInterruptsSubTab(frame.defensiveSubtabFrames[2], frame.defensiveSubtabFrames[2].widgets) end
    if RoRotaGUI.CreateSurvivalSubTab then RoRotaGUI.CreateSurvivalSubTab(frame.defensiveSubtabFrames[3], frame.defensiveSubtabFrames[3].widgets) end
    
    RoRotaGUI.ShowDefensiveSubTab(frame, 1)
end

function RoRotaGUI.ShowDefensiveSubTab(frame, index)
    for i = 1, table.getn(frame.defensiveSubtabFrames) do
        if i == index then
            frame.defensiveSubtabFrames[i]:Show()
            RoRotaGUI.SetSubTabActive(frame.defensiveSubtabs[i].button, true)
        else
            frame.defensiveSubtabFrames[i]:Hide()
            RoRotaGUI.SetSubTabActive(frame.defensiveSubtabs[i].button, false)
        end
    end
end

function RoRotaGUI.LoadDefensiveTab(frame)
    if not frame.defensiveSubtabFrames then return end
    if RoRotaGUI.LoadDefensiveGlobalSubTab and frame.defensiveSubtabFrames[1] then RoRotaGUI.LoadDefensiveGlobalSubTab(frame.defensiveSubtabFrames[1].widgets) end
    if RoRotaGUI.LoadInterruptsSubTab and frame.defensiveSubtabFrames[2] then RoRotaGUI.LoadInterruptsSubTab(frame.defensiveSubtabFrames[2].widgets) end
    if RoRotaGUI.LoadSurvivalSubTab and frame.defensiveSubtabFrames[3] then RoRotaGUI.LoadSurvivalSubTab(frame.defensiveSubtabFrames[3].widgets) end
end

-- Defensive Global Subtab
function RoRotaGUI.CreateDefensiveGlobalSubTab(parent, widgets)
    local y = -20
    RoRotaGUI.CreateLabel(parent, 10, y, "Reserved for future settings")
end

function RoRotaGUI.LoadDefensiveGlobalSubTab(widgets)
end

-- Interrupts Subtab
function RoRotaGUI.CreateInterruptsSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Kick")
    widgets.kickCheck = RoRotaGUI.CreateCheckbox("RoRotaKickCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useKick = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Gouge")
    widgets.gougeCheck = RoRotaGUI.CreateCheckbox("RoRotaGougeCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useGouge = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Kidney Shot")
    widgets.ksCheck = RoRotaGUI.CreateCheckbox("RoRotaKSCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useKidneyShot = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Kidney Shot Max CP")
    widgets.ksMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaKSMaxDD", parent, 260, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.kidneyMaxCP = value
    end)
end

function RoRotaGUI.LoadInterruptsSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.kickCheck and p.interrupt then
        widgets.kickCheck:SetChecked(p.interrupt.useKick and 1 or nil)
    end
    if widgets.gougeCheck and p.interrupt then
        widgets.gougeCheck:SetChecked(p.interrupt.useGouge and 1 or nil)
    end
    if widgets.ksCheck and p.interrupt then
        widgets.ksCheck:SetChecked(p.interrupt.useKidneyShot and 1 or nil)
    end
    if widgets.ksMaxDD and p.interrupt then
        local val = p.interrupt.kidneyMaxCP or 2
        UIDropDownMenu_SetSelectedValue(widgets.ksMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.ksMaxDD)
    end
end

-- Survival Subtab
function RoRotaGUI.CreateSurvivalSubTab(parent, widgets)
    local y = -20
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Vanish")
    widgets.vanishCheck = RoRotaGUI.CreateCheckbox("RoRotaVanishCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useVanish = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Vanish HP% Threshold")
    widgets.vanishEB = RoRotaGUI.CreateEditBox("RoRotaVanishEB", parent, 175, y, 50, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.vanishHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Use Feint")
    widgets.feintCheck = RoRotaGUI.CreateCheckbox("RoRotaFeintCheck", parent, 260, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useFeint = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Feint Mode")
    local feintModes = {"Always", "WhenTargeted", "HighThreat"}
    widgets.feintModeDD = RoRotaGUI.CreateDropdown("RoRotaFeintModeDD", parent, 200, y, 150, feintModes, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.feintMode = value
    end)
end

function RoRotaGUI.LoadSurvivalSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.vanishCheck and p.defensive then
        widgets.vanishCheck:SetChecked(p.defensive.useVanish and 1 or nil)
    end
    if widgets.vanishEB and p.defensive then
        widgets.vanishEB:SetText(tostring(p.defensive.vanishHP or 20))
    end
    if widgets.feintCheck and p.defensive then
        widgets.feintCheck:SetChecked(p.defensive.useFeint and 1 or nil)
    end
    if widgets.feintModeDD and p.defensive and p.defensive.feintMode then
        UIDropDownMenu_SetSelectedValue(widgets.feintModeDD, p.defensive.feintMode)
        UIDropDownMenu_SetText(p.defensive.feintMode, widgets.feintModeDD)
    end
end

RoRotaGUIDefensiveLoaded = true

-- ============================================================================
-- POISONS TAB
-- ============================================================================

function RoRotaGUI.CreatePoisonsTab(parent, frame)
    local poisonTypes = {"None", "Agitating Poison", "Corrosive Poison", "Crippling Poison", "Deadly Poison", "Dissolvent Poison", "Instant Poison", "Mind-numbing Poison", "Wound Poison", "Sharpening Stone"}
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Auto-Apply Poisons")
    frame.autoApplyCheck = RoRotaGUI.CreateCheckbox("RoRotaAutoApplyCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.autoApply = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Allow in Combat")
    frame.applyInCombatCheck = RoRotaGUI.CreateCheckbox("RoRotaApplyInCombatCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.applyInCombat = (this:GetChecked() == 1)
    end)
    y = y - 40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Main Hand Poison")
    frame.mainHandPoisonDD = RoRotaGUI.CreateDropdown("RoRotaMainHandPoisonDD", parent, 350, y, 180, poisonTypes, function(value)
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.mainHandPoison = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Off Hand Poison")
    frame.offHandPoisonDD = RoRotaGUI.CreateDropdown("RoRotaOffHandPoisonDD", parent, 350, y, 180, poisonTypes, function(value)
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.offHandPoison = value
    end)
    y = y - 40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Enable Poison Warnings")
    frame.poisonCheck = RoRotaGUI.CreateCheckbox("RoRotaPoisonCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Time Threshold (minutes)")
    local timeOptions = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
    frame.poisonTimeDD = RoRotaGUI.CreateDropdown("RoRotaPoisonTimeDD", parent, 350, y, 80, timeOptions, function(value)
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.timeThreshold = tonumber(value) * 60
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Charges Threshold")
    frame.poisonChargesDD = RoRotaGUI.CreateDropdownNumeric("RoRotaPoisonChargesDD", parent, 350, y, 5, 50, 5, function(value)
        if not RoRota.db.profile.poisons then RoRota.db.profile.poisons = {} end
        RoRota.db.profile.poisons.chargesThreshold = value
    end)
    y = y - 40
    
    local testBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Test Warning")
    testBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    testBtn:SetScript("OnClick", function()
        if RoRota.CheckWeaponPoisons then
            RoRota:CheckWeaponPoisons(true)
        else
            RoRota:Print("Poison module not loaded")
        end
    end)
end

function RoRotaGUI.LoadPoisonsTab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
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
    if frame.poisonTimeDD and p.poisons then
        local val = math.floor((p.poisons.timeThreshold or 180) / 60)
        UIDropDownMenu_SetSelectedValue(frame.poisonTimeDD, tostring(val))
        UIDropDownMenu_SetText(tostring(val), frame.poisonTimeDD)
    end
    if frame.poisonChargesDD and p.poisons then
        local val = p.poisons.chargesThreshold or 10
        UIDropDownMenu_SetSelectedValue(frame.poisonChargesDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.poisonChargesDD)
    end
end

RoRotaGUIPoisonsLoaded = true

-- ============================================================================
-- PROFILES TAB
-- ============================================================================

function RoRotaGUI.CreateProfilesTab(parent, frame)
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Current Profile")
    
    local function GetCurrentProfile()
        local charKey = UnitName("player").." - "..GetRealmName()
        return RoRotaDB.char and RoRotaDB.char[charKey] or "Default"
    end
    
    local function UpdateProfileDropdown()
        if not frame.profileDD then return end
        local current = GetCurrentProfile()
        UIDropDownMenu_SetSelectedValue(frame.profileDD, current)
        UIDropDownMenu_SetText(current, frame.profileDD)
    end
    
    frame.profileDD = CreateFrame("Frame", "RoRotaProfileDD", parent, "UIDropDownMenuTemplate")
    local offset = 150 - 100
    frame.profileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 350 - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(150, frame.profileDD)
    
    local left = getglobal("RoRotaProfileDDLeft")
    local middle = getglobal("RoRotaProfileDDMiddle")
    local right = getglobal("RoRotaProfileDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(frame.profileDD, function()
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
                if RoRotaGUIFrame and RoRotaGUI.LoadAllTabs then
                    RoRotaGUI.LoadAllTabs(RoRotaGUIFrame)
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UpdateProfileDropdown()
    y = y - 40
    
    local newBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "New Profile")
    newBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
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
                    if RoRotaGUIFrame and RoRotaGUI.LoadAllTabs then
                        RoRotaGUI.LoadAllTabs(RoRotaGUIFrame)
                    end
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
    
    local deleteBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Delete Profile")
    deleteBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 150, y)
    
    local exportBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    exportBtn:SetWidth(120)
    exportBtn:SetHeight(25)
    exportBtn:SetText("Export/Import")
    exportBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 280, y)
    RoRotaGUI.SkinButton(exportBtn)
    exportBtn:SetScript("OnClick", function()
        if RoRota and RoRota.ShowExportWindow then
            RoRota:ShowExportWindow()
        end
    end)
    y = y - 50
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Enable Auto-Switching")
    frame.autoSwitchCheck = RoRotaGUI.CreateCheckbox("RoRotaAutoSwitchCheck", parent, 350, y, "", function()
        if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
        RoRotaDB.autoSwitch.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
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
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Solo Profile")
    frame.soloProfileDD = CreateFrame("Frame", "RoRotaSoloProfileDD", parent, "UIDropDownMenuTemplate")
    local offset = 150 - 100
    frame.soloProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 350 - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(150, frame.soloProfileDD)
    
    local left = getglobal("RoRotaSoloProfileDDLeft")
    local middle = getglobal("RoRotaSoloProfileDDMiddle")
    local right = getglobal("RoRotaSoloProfileDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(frame.soloProfileDD, function()
        local names = GetProfileNames()
        for _, pname in ipairs(names) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pname
            info.value = pname
            local p = pname
            info.func = function()
                if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
                RoRotaDB.autoSwitch.soloProfile = p
                UIDropDownMenu_SetSelectedValue(frame.soloProfileDD, p)
                UIDropDownMenu_SetText(p, frame.soloProfileDD)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Group Profile")
    frame.groupProfileDD = CreateFrame("Frame", "RoRotaGroupProfileDD", parent, "UIDropDownMenuTemplate")
    local offset = 150 - 100
    frame.groupProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 350 - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(150, frame.groupProfileDD)
    
    local left = getglobal("RoRotaGroupProfileDDLeft")
    local middle = getglobal("RoRotaGroupProfileDDMiddle")
    local right = getglobal("RoRotaGroupProfileDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(frame.groupProfileDD, function()
        local names = GetProfileNames()
        for _, pname in ipairs(names) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pname
            info.value = pname
            local p = pname
            info.func = function()
                if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
                RoRotaDB.autoSwitch.groupProfile = p
                UIDropDownMenu_SetSelectedValue(frame.groupProfileDD, p)
                UIDropDownMenu_SetText(p, frame.groupProfileDD)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Raid Profile")
    frame.raidProfileDD = CreateFrame("Frame", "RoRotaRaidProfileDD", parent, "UIDropDownMenuTemplate")
    local offset = 150 - 100
    frame.raidProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 350 - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(150, frame.raidProfileDD)
    
    local left = getglobal("RoRotaRaidProfileDDLeft")
    local middle = getglobal("RoRotaRaidProfileDDMiddle")
    local right = getglobal("RoRotaRaidProfileDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(frame.raidProfileDD, function()
        local names = GetProfileNames()
        for _, pname in ipairs(names) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = pname
            info.value = pname
            local p = pname
            info.func = function()
                if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
                RoRotaDB.autoSwitch.raidProfile = p
                UIDropDownMenu_SetSelectedValue(frame.raidProfileDD, p)
                UIDropDownMenu_SetText(p, frame.raidProfileDD)
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
                        if RoRotaGUIFrame and RoRotaGUI.LoadAllTabs then
                            RoRotaGUI.LoadAllTabs(RoRotaGUIFrame)
                        end
                    end
                end
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show("ROROTA_DELETE_PROFILE")
    end)
end

function RoRotaGUI.LoadProfilesTab(frame)
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

-- ============================================================================
-- PREVIEW TAB
-- ============================================================================

function RoRotaGUI.CreatePreviewTab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local y = -40
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    title:SetText("Preview Window Settings")
    y = y - 40
    
    local toggleBtn = RoRotaGUI.CreateButton(nil, parent, 150, 25, "Toggle Preview")
    toggleBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    toggleBtn:SetScript("OnClick", function()
        if RoRota and RoRota.CreateRotationPreview then
            if not RoRotaPreviewFrame then
                RoRota:CreateRotationPreview()
            end
            if RoRotaPreviewFrame then
                RoRotaPreviewFrame.enabled = not RoRotaPreviewFrame.enabled
                if RoRotaPreviewFrame.enabled then
                    RoRota:Print("Preview enabled")
                else
                    RoRota:Print("Preview disabled")
                end
            end
        end
    end)
    y = y - 40
    
    local depthLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    depthLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
    depthLabel:SetText("Show abilities:")
    
    local depthDropdown = RoRotaGUI.CreateDropdown("RoRotaPreviewDepthDropdown", parent, 140, y, 60, {"1", "2", "3"}, function(value)
        if RoRota and RoRota.db and RoRota.db.profile then
            RoRota.db.profile.previewDepth = tonumber(value)
        end
    end)
    frame.previewDepthDropdown = depthDropdown
    y = y - 30
    
    local depthDesc = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
    depthDesc:SetText("1 = Current ability only")
    y = y - 18
    
    local depthDesc2 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc2:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
    depthDesc2:SetText("2 = Current + Next ability")
    y = y - 18
    
    local depthDesc3 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc3:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, y)
    depthDesc3:SetText("3 = Current + Next + Next+1 ability")
end

function RoRotaGUI.LoadPreviewTab(frame)
    if frame.previewDepthDropdown and RoRota and RoRota.db and RoRota.db.profile then
        local depth = RoRota.db.profile.previewDepth or 1
        UIDropDownMenu_SetSelectedValue(frame.previewDepthDropdown, tostring(depth))
    end
end

RoRotaGUIProfilesLoaded = true

-- ============================================================================
-- IMMUNITIES TAB (with subtabs)
-- ============================================================================

function RoRotaGUI.CreateImmunitiesTab(parent, frame)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(500)
    subtabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    subtabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    subtabBar:SetBackdropColor(0, 0, 0, 0.5)
    
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetWidth(390)
    contentArea:SetHeight(500)
    contentArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 90, 0)
    
    local subtabs = {"Bleed", "Stun", "Incapacitate"}
    frame.immunitySubtabs = {}
    frame.immunitySubtabFrames = {}
    
    for i, name in ipairs(subtabs) do
        local index = i
        local btn = RoRotaGUI.CreateSubTab(subtabBar, -10 - (i-1)*33, name, function()
            RoRotaGUI.ShowImmunitySubTab(frame, index)
        end)
        frame.immunitySubtabs[i] = {button = btn, name = name}
        
        local subFrame = CreateFrame("Frame", nil, contentArea)
        subFrame:SetWidth(390)
        subFrame:SetHeight(500)
        subFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
        subFrame:Hide()
        frame.immunitySubtabFrames[i] = subFrame
    end
    
    if RoRotaGUI.CreateImmunitySubTab then
        RoRotaGUI.CreateImmunitySubTab(frame.immunitySubtabFrames[1], "bleed")
        RoRotaGUI.CreateImmunitySubTab(frame.immunitySubtabFrames[2], "stun")
        RoRotaGUI.CreateImmunitySubTab(frame.immunitySubtabFrames[3], "incapacitate")
    end
    
    RoRotaGUI.ShowImmunitySubTab(frame, 1)
end

function RoRotaGUI.ShowImmunitySubTab(frame, index)
    for i = 1, table.getn(frame.immunitySubtabFrames) do
        if i == index then
            frame.immunitySubtabFrames[i]:Show()
            RoRotaGUI.SetSubTabActive(frame.immunitySubtabs[i].button, true)
        else
            frame.immunitySubtabFrames[i]:Hide()
            RoRotaGUI.SetSubTabActive(frame.immunitySubtabs[i].button, false)
        end
    end
    -- Refresh after showing
    if frame.immunitySubtabFrames[index] and frame.immunitySubtabFrames[index].Refresh then
        frame.immunitySubtabFrames[index]:Refresh()
    end
end

function RoRotaGUI.CreateImmunitySubTab(parent, groupName)
    local y = -10
    
    -- Top section: Active immunities
    local topLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    topLabel:SetText("Targets added to immune group")
    y = y - 20
    
    local topScroll = CreateFrame("ScrollFrame", nil, parent)
    topScroll:SetWidth(350)
    topScroll:SetHeight(180)
    topScroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    
    local topList = CreateFrame("Frame", nil, topScroll)
    topList:SetWidth(350)
    topList:SetHeight(1)
    topScroll:SetScrollChild(topList)
    
    local topSlider = CreateFrame("Slider", nil, topScroll)
    topSlider:SetPoint("TOPRIGHT", topScroll, "TOPRIGHT", 18, 0)
    topSlider:SetPoint("BOTTOMRIGHT", topScroll, "BOTTOMRIGHT", 18, 0)
    topSlider:SetWidth(16)
    topSlider:SetOrientation("VERTICAL")
    topSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    topSlider:SetMinMaxValues(0, 100)
    topSlider:SetValue(0)
    topSlider:SetScript("OnValueChanged", function()
        topScroll:SetVerticalScroll(this:GetValue())
    end)
    parent.topSlider = topSlider
    parent.topSliderMax = 100
    topScroll:EnableMouseWheel(true)
    topScroll:SetScript("OnMouseWheel", function()
        if not parent.topSlider then return end
        local current = parent.topSlider:GetValue()
        local maxVal = parent.topSliderMax or 100
        local step = 20
        if arg1 > 0 then
            parent.topSlider:SetValue(math.max(0, current - step))
        else
            parent.topSlider:SetValue(math.min(maxVal, current + step))
        end
    end)
    
    y = y - 190
    
    -- Bottom section: Ignored targets
    local bottomLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bottomLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    bottomLabel:SetText("Targets ignored in immune group")
    y = y - 20
    
    local bottomScroll = CreateFrame("ScrollFrame", nil, parent)
    bottomScroll:SetWidth(350)
    bottomScroll:SetHeight(180)
    bottomScroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    
    local bottomList = CreateFrame("Frame", nil, bottomScroll)
    bottomList:SetWidth(350)
    bottomList:SetHeight(1)
    bottomScroll:SetScrollChild(bottomList)
    
    local bottomSlider = CreateFrame("Slider", nil, bottomScroll)
    bottomSlider:SetPoint("TOPRIGHT", bottomScroll, "TOPRIGHT", 18, 0)
    bottomSlider:SetPoint("BOTTOMRIGHT", bottomScroll, "BOTTOMRIGHT", 18, 0)
    bottomSlider:SetWidth(16)
    bottomSlider:SetOrientation("VERTICAL")
    bottomSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    bottomSlider:SetMinMaxValues(0, 100)
    bottomSlider:SetValue(0)
    bottomSlider:SetScript("OnValueChanged", function()
        bottomScroll:SetVerticalScroll(this:GetValue())
    end)
    parent.bottomSlider = bottomSlider
    parent.bottomSliderMax = 100
    bottomScroll:EnableMouseWheel(true)
    bottomScroll:SetScript("OnMouseWheel", function()
        if not parent.bottomSlider then return end
        local current = parent.bottomSlider:GetValue()
        local maxVal = parent.bottomSliderMax or 100
        local step = 20
        if arg1 > 0 then
            parent.bottomSlider:SetValue(math.max(0, current - step))
        else
            parent.bottomSlider:SetValue(math.min(maxVal, current + step))
        end
    end)
    
    parent.topList = topList
    parent.bottomList = bottomList
    parent.groupName = groupName
    
    function parent:Refresh()
        if not RoRota then return end
        
        -- Get active immune targets
        local activeTargets = RoRota:GetImmuneTargets(self.groupName) or {}
        
        -- Get ignored targets
        local ignoredTargets = RoRota:GetIgnoredTargets(self.groupName) or {}
        
        -- Clear top list
        local topChildren = {self.topList:GetChildren()}
        for i = 1, table.getn(topChildren) do
            topChildren[i]:Hide()
        end
        
        -- Clear bottom list
        local bottomChildren = {self.bottomList:GetChildren()}
        for i = 1, table.getn(bottomChildren) do
            bottomChildren[i]:Hide()
        end
        
        -- Populate top list (active immunities)
        local yPos = -5
        for _, tName in ipairs(activeTargets) do
            local row = CreateFrame("Frame", nil, self.topList)
            row:SetWidth(360)
            row:SetHeight(22)
            row:SetPoint("TOPLEFT", self.topList, "TOPLEFT", 0, yPos)
            
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
            nameText:SetText(tName)
            
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetWidth(50)
            deleteBtn:SetHeight(18)
            deleteBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            deleteBtn:SetText("Delete")
            deleteBtn.targetName = tName
            RoRotaGUI.SkinButton(deleteBtn)
            deleteBtn:SetScript("OnClick", function()
                RoRota:RemoveImmunity(this.targetName)
                parent:Refresh()
            end)
            
            local ignoreBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            ignoreBtn:SetWidth(50)
            ignoreBtn:SetHeight(18)
            ignoreBtn:SetPoint("RIGHT", deleteBtn, "LEFT", -3, 0)
            ignoreBtn:SetText("Ignore")
            ignoreBtn.targetName = tName
            ignoreBtn.groupName = self.groupName
            RoRotaGUI.SkinButton(ignoreBtn)
            ignoreBtn:SetScript("OnClick", function()
                RoRota:IgnoreImmunity(this.targetName, this.groupName)
                parent:Refresh()
            end)
            
            yPos = yPos - 24
        end
        local topHeight = math.max(1, math.abs(yPos))
        self.topList:SetHeight(topHeight)
        if self.topSlider then
            local maxVal = math.max(0, topHeight - 180)
            self.topSlider:SetMinMaxValues(0, maxVal)
            self.topSliderMax = maxVal
        end
        
        -- Populate bottom list (ignored targets)
        yPos = -5
        for _, tName in ipairs(ignoredTargets) do
            local row = CreateFrame("Frame", nil, self.bottomList)
            row:SetWidth(360)
            row:SetHeight(22)
            row:SetPoint("TOPLEFT", self.bottomList, "TOPLEFT", 0, yPos)
            
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
            nameText:SetText(tName)
            nameText:SetTextColor(0.6, 0.6, 0.6)
            
            local unignoreBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            unignoreBtn:SetWidth(60)
            unignoreBtn:SetHeight(18)
            unignoreBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            unignoreBtn:SetText("Unignore")
            unignoreBtn.targetName = tName
            unignoreBtn.groupName = self.groupName
            RoRotaGUI.SkinButton(unignoreBtn)
            unignoreBtn:SetScript("OnClick", function()
                RoRota:UnignoreImmunity(this.targetName, this.groupName)
                parent:Refresh()
            end)
            
            yPos = yPos - 24
        end
        local bottomHeight = math.max(1, math.abs(yPos))
        self.bottomList:SetHeight(bottomHeight)
        if self.bottomSlider then
            local maxVal = math.max(0, bottomHeight - 180)
            self.bottomSlider:SetMinMaxValues(0, maxVal)
            self.bottomSliderMax = maxVal
        end
    end
    
    y = y - 190
    
    local addBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    addBtn:SetWidth(100)
    addBtn:SetHeight(25)
    addBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    addBtn:SetText("Add Target")
    RoRotaGUI.SkinButton(addBtn)
    addBtn:SetScript("OnClick", function()
        local dialogName = "ROROTA_ADD_IMMUNITY_"..string.upper(parent.groupName)
        StaticPopupDialogs[dialogName] = {
            text = "Enter target name:",
            button1 = "Add",
            button2 = "Cancel",
            hasEditBox = 1,
            maxLetters = 50,
            OnAccept = function()
                local name = getglobal(this:GetParent():GetName().."EditBox"):GetText()
                if name and name ~= "" then
                    RoRota:AddImmunity(name, parent.groupName)
                    parent:Refresh()
                end
            end,
            OnShow = function()
                getglobal(this:GetName().."EditBox"):SetFocus()
            end,
            EditBoxOnEnterPressed = function()
                local name = this:GetText()
                if name and name ~= "" then
                    RoRota:AddImmunity(name, parent.groupName)
                    parent:Refresh()
                end
                this:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function()
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show(dialogName)
    end)
    
    local clearBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    clearBtn:SetWidth(80)
    clearBtn:SetHeight(25)
    clearBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
    clearBtn:SetText("Clear All")
    RoRotaGUI.SkinButton(clearBtn)
    clearBtn:SetScript("OnClick", function()
        if not RoRotaDB or not RoRotaDB.immunities then return end
        local targets = RoRota:GetImmuneTargets(parent.groupName)
        for _, targetName in ipairs(targets) do
            RoRota:RemoveImmunity(targetName)
        end
        parent:Refresh()
    end)
end

function RoRotaGUI.LoadImmunitiesTab(frame)
    if not frame.immunitySubtabFrames then return end
    for i = 1, table.getn(frame.immunitySubtabFrames) do
        if frame.immunitySubtabFrames[i].Refresh then
            frame.immunitySubtabFrames[i]:Refresh()
        end
    end
end

RoRotaGUIImmunitiesLoaded = true
RoRotaGUIPreviewLoaded = true
