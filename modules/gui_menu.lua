--[[ gui_menu ]]--
-- Consolidated GUI menu file containing all tabs and subtabs

-- ============================================================================
-- ABOUT TAB
-- ============================================================================

function RoRotaGUI.CreateAboutTab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    
    local setupMsg = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setupMsg:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    setupMsg:SetText("For the addon to work you need to set up macros:")
    layout:Space(20)
    
    local rotationBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Create Rotation Macro")
    rotationBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
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
    
    local aoeBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Create AoE Macro")
    aoeBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 210, layout:GetY())
    aoeBtn:SetScript("OnClick", function()
        local macroIndex = GetMacroIndexByName("RoRotaAoE")
        if macroIndex == 0 then
            CreateMacro("RoRotaAoE", 1, "/script RoRotaRunAOERotation()", 1, 1)
            RoRota:Print("Macro 'RoRotaAoE' created!")
        else
            EditMacro(macroIndex, "RoRotaAoE", 1, "/script RoRotaRunAOERotation()")
            RoRota:Print("Macro 'RoRotaAoE' updated!")
        end
    end)
    layout:Space(30)
    
    local poisonBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Create Poison Macro")
    poisonBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
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
    layout:Space(40)
    
    local commandsTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    commandsTitle:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    commandsTitle:SetText("Commands:")
    layout:Space(25)
    
    local cmd1 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cmd1:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, layout:GetY())
    cmd1:SetText("/rr - Open settings")
    layout:Space(15)
    
    local cmd2 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cmd2:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, layout:GetY())
    cmd2:SetText("/rr preview - Toggle ability preview")
    layout:Space(40)
    
    local link = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    link:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    link:SetText("For more information, visit:")
    layout:Space(15)
    
    local github = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    github:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
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
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    local cfg = RoRota.db.profile.opener
    local abilities = {"Ambush", "Garrote", "Cheap Shot", "Backstab", "Sinister Strike"}
    
    frame.openerDD = layout:Row("Main Opener",
        RoRotaGUI.CreateDropdown("RoRotaOpenerDD", parent, 0, 0, 150, abilities, function(v)
            cfg.ability = v
        end), 20, "Primary opener ability from stealth")
    
    frame.secondaryDD = layout:Row("Secondary Opener",
        RoRotaGUI.CreateDropdown("RoRotaSecondaryDD", parent, 0, 0, 150, abilities, function(v)
            cfg.secondaryAbility = v
        end), 20, "Fallback opener if main fails or is on cooldown")
    
    frame.openerFailDD = layout:Row("Failsafe Attempts",
        RoRotaGUI.CreateDropdown("RoRotaOpenerFailDD", parent, 0, 0, 100, 
            {"Disabled", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, function(v)
            cfg.failsafeAttempts = v == "Disabled" and -1 or tonumber(v)
        end), 20, "Retry opener this many times before using builder")
    
    frame.ppCheck = layout:Row("Pick Pocket Before Opener",
        RoRotaGUI.CreateCheckbox("RoRotaPPCheck", parent, 0, 0, "", function()
            cfg.pickPocket = (this:GetChecked() == 1)
        end), 20, "Automatically pick pocket before opening on targets")
    
    frame.coldBloodCheck = layout:Row("Use Cold Blood before Ambush",
        RoRotaGUI.CreateCheckbox("RoRotaColdBloodCheck", parent, 0, 0, "", function()
            cfg.useColdBlood = (this:GetChecked() == 1)
        end), 20, "Use Cold Blood for guaranteed crit on Ambush opener")
    
    frame.sapFailDD = layout:Row("After Failed Sap",
        RoRotaGUI.CreateDropdown("RoRotaSapFailDD", parent, 0, 0, 120, 
            {"None", "Vanish", "Sprint", "Evasion"}, function(v)
            cfg.sapFailAction = v
        end), 20, "Action to take when Sap breaks or fails")
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
    subtabBar:SetHeight(460)
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
    
    local subtabs = {"Global", "Slice\nand Dice", "Rupture", "Expose\nArmor", "Envenom", "Shadow\nof Death", "Eviscerate", "Flourish", "Kidney\nShot"}
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
    frame.finisherSubtabFrames[8].widgets = {}
    frame.finisherSubtabFrames[9].widgets = {}
    
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
    if RoRotaGUI.CreateFlourishSubTab then
        RoRotaGUI.CreateFlourishSubTab(frame.finisherSubtabFrames[8], frame.finisherSubtabFrames[8].widgets)
    end
    if RoRotaGUI.CreateKidneyShotSubTab then
        RoRotaGUI.CreateKidneyShotSubTab(frame.finisherSubtabFrames[9], frame.finisherSubtabFrames[9].widgets)
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
    if RoRotaGUI.LoadFlourishSubTab and frame.finisherSubtabFrames[8] then 
        RoRotaGUI.LoadFlourishSubTab(frame.finisherSubtabFrames[8].widgets) 
    end
    if RoRotaGUI.LoadKidneyShotSubTab and frame.finisherSubtabFrames[9] then 
        RoRotaGUI.LoadKidneyShotSubTab(frame.finisherSubtabFrames[9].widgets) 
    end
end

-- Finisher Global Subtab
function RoRotaGUI.CreateFinisherGlobalSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local finishers = {"Slice and Dice", "Flourish", "Envenom", "Rupture", "Expose Armor", "Shadow of Death", "Kidney Shot", "Cold Blood Eviscerate"}
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Finisher Priority")
    layout:Space(25)
    
    widgets.priorityButtons = {}
    for i, name in ipairs(finishers) do
        local btn = RoRotaGUI.CreateButton(nil, parent, 140, 22, name)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, layout:GetY())
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
        
        layout:Space(27)
    end
    
    widgets.UpdatePriorityList = function()
        local priority = RoRota.db.profile.finisherPriority or finishers
        for i, btn in ipairs(widgets.priorityButtons) do
            btn:SetText(priority[i] or "")
            btn.finisher = priority[i]
            btn.index = i
        end
    end
    
    layout:Space(10)
    
    widgets.refreshThresholdEB = layout:Row("Finisher Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaRefreshThresholdEB", parent, 0, 0, 50, 0, 10, function(v)
            RoRota.db.profile.finisherRefreshThreshold = v
        end), 20, "Refresh finisher when this many seconds remain")
    
    widgets.ttkEnabledCheck = layout:Row("TTK Tracking Enable",
        RoRotaGUI.CreateCheckbox("RoRotaTTKEnabledCheck", parent, 0, 0, "", function()
            RoRota.db.profile.ttk.enabled = (this:GetChecked() == 1)
        end), 20, "Skip DoTs on dying targets (auto-tuned)")
    
    widgets.ttkExcludeBossesCheck = layout:Row("TTK Exclude Bosses",
        RoRotaGUI.CreateCheckbox("RoRotaTTKExcludeBossesCheck", parent, 0, 0, "", function()
            RoRota.db.profile.ttk.excludeBosses = (this:GetChecked() == 1)
        end), 20, "Don't use TTK logic on boss targets")
end

function RoRotaGUI.LoadFinisherGlobalSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.refreshThresholdEB then
        local val = p.finisherRefreshThreshold or 2
        widgets.refreshThresholdEB:SetText(string.format("%.1f", val))
    end
    if widgets.UpdatePriorityList then
        widgets.UpdatePriorityList()
    end
    if widgets.ttkEnabledCheck and p.ttk then
        widgets.ttkEnabledCheck:SetChecked(p.ttk.enabled and 1 or nil)
    end
    if widgets.ttkExcludeBossesCheck and p.ttk then
        widgets.ttkExcludeBossesCheck:SetChecked(p.ttk.excludeBosses and 1 or nil)
    end
end

-- SnD Subtab
function RoRotaGUI.CreateSndSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -15)
    local cfg = RoRota.db.profile.abilities.SliceAndDice
    
    widgets.sndCheck = layout:Row("Enable Slice and Dice",
        RoRotaGUI.CreateCheckbox("RoRotaSndCheckNew", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 25, "Enable Slice and Dice in rotation")
    
    widgets.sndMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaSndMinDDNew", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 25, "Minimum combo points to use SnD")
    
    widgets.sndMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaSndMaxDDNew", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 25, "Maximum combo points to use SnD")
    
    widgets.sndTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaSndTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = v
        end), 25, "Only use SnD if target HP is above this")
    
    widgets.sndTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaSndTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = v
        end), 25, "Only use SnD if target HP is below this")
    
    widgets.sndUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaSndUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 25, "Use flat HP values instead of percentages")
    
    widgets.sndTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaSndTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 25, "Minimum target HP in thousands (e.g. 50 = 50000)")
    
    widgets.sndTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaSndTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 25, "Maximum target HP in thousands")
    
    widgets.sndElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaSndElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 25, "Only use SnD on elite/boss targets")
    
    widgets.sndRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaSndRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 25, "Refresh SnD when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.sndConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaSndConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
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
    if widgets.sndRefreshEB and p.abilities and p.abilities.SliceAndDice then
        local val = p.abilities.SliceAndDice.refreshThreshold or p.finisherRefreshThreshold or 2
        widgets.sndRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.sndConditionsEB and p.abilities and p.abilities.SliceAndDice then
        widgets.sndConditionsEB:SetText(p.abilities.SliceAndDice.conditions or "")
    end
end

-- Rupture Subtab
function RoRotaGUI.CreateRuptureSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.Rupture
    
    widgets.ruptCheck = layout:Row("Enable Rupture",
        RoRotaGUI.CreateCheckbox("RoRotaRuptCheckNew", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Rupture in rotation")
    
    widgets.ruptMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMinDDNew", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Rupture")
    
    widgets.ruptMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMaxDDNew", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Rupture")
    
    widgets.smartRuptCheck = layout:Row("Smart Rupture",
        RoRotaGUI.CreateCheckbox("RoRotaSmartRuptCheckNew", parent, 0, 0, "", function()
            RoRota.db.profile.smartRupture = (this:GetChecked() == 1)
        end), 20, "Only use Rupture if target will live long enough")
    
    widgets.ruptTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaRuptTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = v
        end), 20, "Only use Rupture if target HP is above this")
    
    widgets.ruptTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaRuptTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = v
        end), 20, "Only use Rupture if target HP is below this")
    
    widgets.ruptUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaRuptUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 20, "Use flat HP values instead of percentages")
    
    widgets.ruptTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaRuptTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 20, "Minimum target HP in thousands")
    
    widgets.ruptTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaRuptTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 20, "Maximum target HP in thousands")
    
    widgets.ruptElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaRuptElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Rupture on elite/boss targets")
    
    widgets.ruptTasteCheck = layout:Row("Taste for Blood (bypass immunity)",
        RoRotaGUI.CreateCheckbox("RoRotaRuptTasteCheck", parent, 0, 0, "", function()
            cfg.tasteForBlood = (this:GetChecked() == 1)
        end), 20, "Use Rupture even on bleed-immune targets with Taste for Blood")
    
    widgets.ruptRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaRuptRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 20, "Refresh Rupture when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.ruptConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaRuptConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
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
    if widgets.ruptRefreshEB and p.abilities and p.abilities.Rupture then
        local val = p.abilities.Rupture.refreshThreshold or p.finisherRefreshThreshold or 2
        widgets.ruptRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.ruptConditionsEB and p.abilities and p.abilities.Rupture then
        widgets.ruptConditionsEB:SetText(p.abilities.Rupture.conditions or "")
    end
end

-- Expose Subtab
function RoRotaGUI.CreateExposeSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.ExposeArmor
    
    widgets.exposeCheck = layout:Row("Enable Expose Armor",
        RoRotaGUI.CreateCheckbox("RoRotaExposeCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Expose Armor in rotation")
    
    widgets.exposeMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Expose Armor")
    
    widgets.exposeMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Expose Armor")
    
    widgets.exposeTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaExposeTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = v
        end), 20, "Only use Expose Armor if target HP is above this")
    
    widgets.exposeTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaExposeTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = v
        end), 20, "Only use Expose Armor if target HP is below this")
    
    widgets.exposeUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaExposeUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 20, "Use flat HP values instead of percentages")
    
    widgets.exposeTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaExposeTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 20, "Minimum target HP in thousands")
    
    widgets.exposeTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaExposeTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 20, "Maximum target HP in thousands")
    
    widgets.exposeElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaExposeElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Expose Armor on elite/boss targets")
    
    widgets.exposeRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaExposeRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 20, "Refresh Expose Armor when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.exposeConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaExposeConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
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
    if widgets.exposeRefreshEB and p.abilities and p.abilities.ExposeArmor then
        local val = p.abilities.ExposeArmor.refreshThreshold or p.finisherRefreshThreshold or 2
        widgets.exposeRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.exposeConditionsEB and p.abilities and p.abilities.ExposeArmor then
        widgets.exposeConditionsEB:SetText(p.abilities.ExposeArmor.conditions or "")
    end
end

-- Envenom Subtab
function RoRotaGUI.CreateEnvenomSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.Envenom
    
    widgets.envCheck = layout:Row("Enable Envenom",
        RoRotaGUI.CreateCheckbox("RoRotaEnvCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Envenom in rotation")
    
    widgets.envMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Envenom")
    
    widgets.envMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Envenom")
    
    widgets.envTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaEnvTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = v
        end), 20, "Only use Envenom if target HP is above this")
    
    widgets.envTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaEnvTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = v
        end), 20, "Only use Envenom if target HP is below this")
    
    widgets.envUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaEnvUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 20, "Use flat HP values instead of percentages")
    
    widgets.envTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaEnvTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 20, "Minimum target HP in thousands")
    
    widgets.envTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaEnvTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 20, "Maximum target HP in thousands")
    
    widgets.envElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaEnvElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Envenom on elite/boss targets")
    
    widgets.envRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaEnvRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 20, "Refresh Envenom when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.envConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaEnvConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
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
    if widgets.envRefreshEB and p.abilities and p.abilities.Envenom then
        local val = p.abilities.Envenom.refreshThreshold or p.finisherRefreshThreshold or 2
        widgets.envRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.envConditionsEB and p.abilities and p.abilities.Envenom then
        widgets.envConditionsEB:SetText(p.abilities.Envenom.conditions or "")
    end
end

-- Shadow of Death Subtab
function RoRotaGUI.CreateShadowOfDeathSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.ShadowOfDeath
    
    widgets.shadowCheck = layout:Row("Enable Shadow of Death",
        RoRotaGUI.CreateCheckbox("RoRotaShadowCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Shadow of Death in rotation")
    
    widgets.shadowMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaShadowMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Shadow of Death")
    
    widgets.shadowMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaShadowMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Shadow of Death")
    
    widgets.shadowTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaShadowTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = tonumber(v) or 0
        end), 20, "Only use Shadow of Death if target HP is above this")
    
    widgets.shadowTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaShadowTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = tonumber(v) or 100
        end), 20, "Only use Shadow of Death if target HP is below this")
    
    widgets.shadowUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaShadowUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 20, "Use flat HP values instead of percentages")
    
    widgets.shadowTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaShadowTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 20, "Minimum target HP in thousands")
    
    widgets.shadowTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaShadowTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 20, "Maximum target HP in thousands")
    
    widgets.shadowElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaShadowElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Shadow of Death on elite/boss targets")
    
    widgets.shadowRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaShadowRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 20, "Refresh Shadow of Death when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.shadowConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaShadowConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
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
    if widgets.shadowRefreshEB and p.abilities and p.abilities.ShadowOfDeath then
        local val = p.abilities.ShadowOfDeath.refreshThreshold or p.finisherRefreshThreshold or 2
        widgets.shadowRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.shadowConditionsEB and p.abilities and p.abilities.ShadowOfDeath then
        widgets.shadowConditionsEB:SetText(p.abilities.ShadowOfDeath.conditions or "")
    end
end

-- Eviscerate Subtab
function RoRotaGUI.CreateEviscerateSub(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.Eviscerate
    local cbCfg = RoRota.db.profile.abilities.ColdBloodEviscerate
    
    widgets.cbEvisFinisherCheck = layout:Row("Use CB Eviscerate (finisher)",
        RoRotaGUI.CreateCheckbox("RoRotaCBEvisFinisherCheck", parent, 0, 0, "", function()
            cbCfg.enabled = (this:GetChecked() == 1)
        end), 20, "Use Cold Blood + Eviscerate as a finisher in rotation")
    
    widgets.smartEvisCheck = layout:Row("Eviscerate-to-kill (execute)",
        RoRotaGUI.CreateCheckbox("RoRotaSmartEvisCheck", parent, 0, 0, "", function()
            cfg.smartEviscerate = (this:GetChecked() == 1)
        end), 20, "Use Eviscerate when it will kill the target")
    
    widgets.coldBloodCheck = layout:Row("CB before execute Eviscerate",
        RoRotaGUI.CreateCheckbox("RoRotaColdBloodEvisCheck", parent, 0, 0, "", function()
            cfg.useColdBlood = (this:GetChecked() == 1)
        end), 20, "Use Cold Blood before execute Eviscerate")
    
    widgets.coldBloodMinDD = layout:Row("Cold Blood Min CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaColdBloodMinDDEvis", parent, 0, 0, 1, 5, 1, function(v)
            cfg.coldBloodMinCP = v
        end), 20, "Minimum CP to use Cold Blood with Eviscerate")
    
    widgets.evisTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaEvisTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = v
        end), 20, "Only use Eviscerate if target HP is above this")
    
    widgets.evisTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaEvisTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = v
        end), 20, "Only use Eviscerate if target HP is below this")
    
    widgets.evisUseFlatHPCheck = layout:Row("Use Flat HP Checks",
        RoRotaGUI.CreateCheckbox("RoRotaEvisUseFlatHPCheck", parent, 0, 0, "", function()
            cfg.useFlatHP = (this:GetChecked() == 1)
        end), 20, "Use flat HP values instead of percentages")
    
    widgets.evisTargetMinFlatEB = layout:Row("Target Min HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaEvisTargetMinFlatEB", parent, 0, 0, function(v)
            cfg.targetMinHPFlat = tonumber(v) or 0
        end), 20, "Minimum target HP in thousands")
    
    widgets.evisTargetMaxFlatEB = layout:Row("Target Max HP (flat, in thousands)",
        RoRotaGUI.CreateFlatHPEditBox("RoRotaEvisTargetMaxFlatEB", parent, 0, 0, function(v)
            cfg.targetMaxHPFlat = tonumber(v) or 9999999
        end), 20, "Maximum target HP in thousands")
    
    widgets.evisElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaEvisElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Eviscerate on elite/boss targets")
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
    subtabBar:SetHeight(460)
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local builders = {"Sinister Strike", "Backstab", "Noxious Assault"}
    local cfg = RoRota.db.profile
    
    widgets.mainBuilderDD = layout:Row("Main Builder",
        RoRotaGUI.CreateDropdown("RoRotaMainBuilderDD", parent, 0, 0, 150, builders, function(v)
            cfg.mainBuilder = v
        end), 20, "Primary combo point builder")
    
    widgets.secondaryBuilderDD = layout:Row("Secondary Builder",
        RoRotaGUI.CreateDropdown("RoRotaSecondaryBuilderDD", parent, 0, 0, 150, builders, function(v)
            cfg.secondaryBuilder = v
        end), 20, "Fallback builder if main fails")
    
    widgets.builderFailDD = layout:Row("Failsafe Attempts",
        RoRotaGUI.CreateDropdownNumeric("RoRotaBuilderFailDD", parent, 0, 0, 1, 10, 1, function(v)
            cfg.builderFailsafe = v
        end), 20, "Retry builder this many times before switching")
    
    widgets.smartBuildersCheck = layout:Row("Sync with Swings",
        RoRotaGUI.CreateCheckbox("RoRotaSmartBuildersCheck", parent, 0, 0, "", function()
            cfg.smartBuilders = (this:GetChecked() == 1)
        end), 20, "Wait for swing timer before using builder")
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.defensive
    
    widgets.riposteCheck = layout:Row("Use Riposte",
        RoRotaGUI.CreateCheckbox("RoRotaRiposteCheck", parent, 0, 0, "", function()
            cfg.useRiposte = (this:GetChecked() == 1)
        end), 20, "Use Riposte when available after parry")
    
    widgets.riposteTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaRiposteTargetMinEB", parent, 0, 0, function(v)
            cfg.riposteTargetMinHP = tonumber(v) or 0
        end), 20, "Only use Riposte if target HP is above this")
    
    widgets.riposteTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaRiposteTargetMaxEB", parent, 0, 0, function(v)
            cfg.riposteTargetMaxHP = tonumber(v) or 100
        end), 20, "Only use Riposte if target HP is below this")
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.defensive
    
    widgets.surpriseCheck = layout:Row("Use Surprise Attack",
        RoRotaGUI.CreateCheckbox("RoRotaSurpriseCheck", parent, 0, 0, "", function()
            cfg.useSurpriseAttack = (this:GetChecked() == 1)
        end), 20, "Use Surprise Attack as combo point builder")
    
    widgets.surpriseTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaSurpriseTargetMinEB", parent, 0, 0, function(v)
            cfg.surpriseTargetMinHP = tonumber(v) or 0
        end), 20, "Only use Surprise Attack if target HP is above this")
    
    widgets.surpriseTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaSurpriseTargetMaxEB", parent, 0, 0, function(v)
            cfg.surpriseTargetMaxHP = tonumber(v) or 100
        end), 20, "Only use Surprise Attack if target HP is below this")
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.MarkForDeath
    
    widgets.markCheck = layout:Row("Use Mark for Death",
        RoRotaGUI.CreateCheckbox("RoRotaMarkCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Use Mark for Death as combo point builder")
    
    widgets.markTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaMarkTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = tonumber(v) or 0
        end), 20, "Only use Mark for Death if target HP is above this")
    
    widgets.markTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaMarkTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = tonumber(v) or 100
        end), 20, "Only use Mark for Death if target HP is below this")
    
    widgets.markElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaMarkElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Mark for Death on elite/boss targets")
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.Hemorrhage
    
    widgets.hemorrhageCheck = layout:Row("Use Hemorrhage",
        RoRotaGUI.CreateCheckbox("RoRotaHemorrhageCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Use Hemorrhage as combo point builder")
    
    widgets.hemorrhageMissingCheck = layout:Row("Only when debuff missing",
        RoRotaGUI.CreateCheckbox("RoRotaHemorrhageMissingCheck", parent, 0, 0, "", function()
            cfg.onlyWhenMissing = (this:GetChecked() == 1)
        end), 20, "Only use Hemorrhage when debuff is not active")
    
    widgets.hemorrhageTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaHemorrhageTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = tonumber(v) or 0
        end), 20, "Only use Hemorrhage if target HP is above this")
    
    widgets.hemorrhageTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaHemorrhageTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = tonumber(v) or 100
        end), 20, "Only use Hemorrhage if target HP is below this")
    
    widgets.hemorrhageElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaHemorrhageElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Hemorrhage on elite/boss targets")
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.defensive
    
    widgets.gsCheck = layout:Row("Use Ghostly Strike",
        RoRotaGUI.CreateCheckbox("RoRotaGSCheck", parent, 0, 0, "", function()
            cfg.useGhostlyStrike = (this:GetChecked() == 1)
        end), 20, "Use Ghostly Strike as combo point builder")
    
    widgets.gsTargetEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaGSTargetEB", parent, 0, 0, function(v)
            cfg.ghostlyTargetMaxHP = v
        end), 20, "Only use Ghostly Strike if target HP is below this")
    
    widgets.gsPlayerMinEB = layout:Row("Player Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaGSPlayerMinEB", parent, 0, 0, function(v)
            cfg.ghostlyPlayerMinHP = v
        end), 20, "Only use Ghostly Strike if player HP is above this")
    
    widgets.gsPlayerMaxEB = layout:Row("Player Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaGSPlayerMaxEB", parent, 0, 0, function(v)
            cfg.ghostlyPlayerMaxHP = v
        end), 20, "Only use Ghostly Strike if player HP is below this")
    
    widgets.gsTargetedOnlyCheck = layout:Row("Use when targeted only",
        RoRotaGUI.CreateCheckbox("RoRotaGSTargetedOnlyCheck", parent, 0, 0, "", function()
            cfg.ghostlyTargetedOnly = (this:GetChecked() == 1)
        end), 20, "Only use Ghostly Strike when target is attacking you")
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
    if widgets.gsTargetedOnlyCheck and p.defensive then
        widgets.gsTargetedOnlyCheck:SetChecked(p.defensive.ghostlyTargetedOnly and 1 or nil)
    end
end

RoRotaGUIBuildersLoaded = true

-- ============================================================================
-- DEFENSIVE TAB (with subtabs)
-- ============================================================================

function RoRotaGUI.CreateDefensiveTab(parent, frame)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(460)
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.defensive
    
    widgets.useHealthPotionCheck = layout:Row("Auto-use Health Potions",
        RoRotaGUI.CreateCheckbox("RoRotaUseHealthPotionCheck", parent, 0, 0, "", function()
            cfg.useHealthPotion = (this:GetChecked() == 1)
        end), 20, "Automatically use health potions when low HP")
    
    widgets.healthPotionHPEB = layout:Row("Health Potion HP% Threshold",
        RoRotaGUI.CreateEditBox("RoRotaHealthPotionHPEB", parent, 0, 0, 50, function(v)
            cfg.healthPotionHP = tonumber(v) or 30
        end), 20, "Use health potion when HP drops below this percentage")
end

function RoRotaGUI.LoadDefensiveGlobalSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.useHealthPotionCheck and p.defensive then
        widgets.useHealthPotionCheck:SetChecked(p.defensive.useHealthPotion and 1 or nil)
    end
    if widgets.healthPotionHPEB and p.defensive then
        widgets.healthPotionHPEB:SetText(tostring(p.defensive.healthPotionHP or 30))
    end
end

-- Interrupts Subtab
function RoRotaGUI.CreateInterruptsSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.interrupt
    
    widgets.kickCheck = layout:Row("Use Kick",
        RoRotaGUI.CreateCheckbox("RoRotaKickCheck", parent, 0, 0, "", function()
            cfg.useKick = (this:GetChecked() == 1)
        end), 20, "Use Kick to interrupt enemy casts")
    
    widgets.deadlyThrowCheck = layout:Row("Use Deadly Throw",
        RoRotaGUI.CreateCheckbox("RoRotaDeadlyThrowCheck", parent, 0, 0, "", function()
            cfg.useDeadlyThrow = (this:GetChecked() == 1)
        end), 20, "Use Deadly Throw to interrupt at range (requires thrown weapon)")
    
    widgets.gougeCheck = layout:Row("Use Gouge",
        RoRotaGUI.CreateCheckbox("RoRotaGougeCheck", parent, 0, 0, "", function()
            cfg.useGouge = (this:GetChecked() == 1)
        end), 20, "Use Gouge to interrupt when Kick is on cooldown")
    
    widgets.ksCheck = layout:Row("Use Kidney Shot",
        RoRotaGUI.CreateCheckbox("RoRotaKSCheck", parent, 0, 0, "", function()
            cfg.useKidneyShot = (this:GetChecked() == 1)
        end), 20, "Use Kidney Shot to interrupt when other interrupts unavailable")
    
    widgets.ksMaxDD = layout:Row("Kidney Shot Max CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaKSMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.kidneyMaxCP = v
        end), 20, "Maximum CP to spend on Kidney Shot interrupt")
end

function RoRotaGUI.LoadInterruptsSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.kickCheck and p.interrupt then
        widgets.kickCheck:SetChecked(p.interrupt.useKick and 1 or nil)
    end
    if widgets.deadlyThrowCheck and p.interrupt then
        widgets.deadlyThrowCheck:SetChecked(p.interrupt.useDeadlyThrow and 1 or nil)
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
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.defensive
    
    widgets.vanishCheck = layout:Row("Use Vanish",
        RoRotaGUI.CreateCheckbox("RoRotaVanishCheck", parent, 0, 0, "", function()
            cfg.useVanish = (this:GetChecked() == 1)
        end), 20, "Use Vanish as emergency escape")
    
    widgets.vanishEB = layout:Row("Vanish HP% Threshold",
        RoRotaGUI.CreateEditBox("RoRotaVanishEB", parent, 0, 0, 50, function(v)
            cfg.vanishHP = v
        end), 20, "Use Vanish when HP drops below this percentage")
    
    widgets.feintCheck = layout:Row("Use Feint",
        RoRotaGUI.CreateCheckbox("RoRotaFeintCheck", parent, 0, 0, "", function()
            cfg.useFeint = (this:GetChecked() == 1)
        end), 20, "Use Feint to reduce threat")
    
    widgets.feintModeDD = layout:Row("Feint Mode",
        RoRotaGUI.CreateDropdown("RoRotaFeintModeDD", parent, 0, 0, 150,
            {"Always", "WhenTargeted", "HighThreat"}, function(v)
            cfg.feintMode = v
        end), 20, "When to use Feint: Always, when targeted, or at high threat")
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
-- AOE TAB
-- ============================================================================

function RoRotaGUI.CreateAoETab(parent, frame)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    local cfg = RoRota.db.profile.aoe
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    title:SetText("AoE Rotation Settings")
    layout:Space(40)
    
    frame.aoeInterruptsCheck = layout:Row("Use Interrupts",
        RoRotaGUI.CreateCheckbox("RoRotaAoEInterruptsCheck", parent, 0, 0, "", function()
            cfg.useInterrupts = (this:GetChecked() == 1)
        end), 20, "Use interrupts during AoE rotation")
    
    frame.aoeDefensiveCheck = layout:Row("Use Defensive Skills",
        RoRotaGUI.CreateCheckbox("RoRotaAoEDefensiveCheck", parent, 0, 0, "", function()
            cfg.useDefensive = (this:GetChecked() == 1)
        end), 20, "Use defensive cooldowns during AoE")
    
    frame.aoeSndCheck = layout:Row("Use SnD in AoE",
        RoRotaGUI.CreateCheckbox("RoRotaAoESndCheck", parent, 0, 0, "", function()
            cfg.useSnD = (this:GetChecked() == 1)
        end), 20, "Maintain Slice and Dice during AoE")
    
    frame.aoeSndMaxDD = layout:Row("SnD Max CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaAoESndMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.sndMaxCP = v
        end), 20, "Maximum CP to spend on SnD in AoE")
    
    frame.aoeBuilderDD = layout:Row("AoE Builder",
        RoRotaGUI.CreateDropdown("RoRotaAoEBuilderDD", parent, 0, 0, 150, 
            {"Sinister Strike", "Backstab", "Noxious Assault"}, function(v)
            cfg.builder = v
        end), 20, "Combo point builder for AoE rotation")
    
    frame.aoeFinisherDD = layout:Row("Damage Finisher",
        RoRotaGUI.CreateDropdown("RoRotaAoEFinisherDD", parent, 0, 0, 150,
            {"Eviscerate", "Rupture", "Envenom"}, function(v)
            cfg.finisher = v
        end), 20, "Damage finisher for AoE rotation")
    
    frame.aoeFinisherMinDD = layout:Row("Finisher Min CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaAoEFinisherMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.finisherMinCP = v
        end), 20, "Minimum CP for damage finisher in AoE")
end

function RoRotaGUI.LoadAoETab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
    if frame.aoeInterruptsCheck and p.aoe then
        frame.aoeInterruptsCheck:SetChecked(p.aoe.useInterrupts and 1 or nil)
    end
    if frame.aoeDefensiveCheck and p.aoe then
        frame.aoeDefensiveCheck:SetChecked(p.aoe.useDefensive and 1 or nil)
    end
    if frame.aoeSndCheck and p.aoe then
        frame.aoeSndCheck:SetChecked(p.aoe.useSnD and 1 or nil)
    end
    if frame.aoeSndMaxDD and p.aoe then
        local val = p.aoe.sndMaxCP or 5
        UIDropDownMenu_SetSelectedValue(frame.aoeSndMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.aoeSndMaxDD)
    end
    if frame.aoeBuilderDD and p.aoe and p.aoe.builder then
        UIDropDownMenu_SetSelectedValue(frame.aoeBuilderDD, p.aoe.builder)
        UIDropDownMenu_SetText(p.aoe.builder, frame.aoeBuilderDD)
    end
    if frame.aoeFinisherDD and p.aoe and p.aoe.finisher then
        UIDropDownMenu_SetSelectedValue(frame.aoeFinisherDD, p.aoe.finisher)
        UIDropDownMenu_SetText(p.aoe.finisher, frame.aoeFinisherDD)
    end
    if frame.aoeFinisherMinDD and p.aoe then
        local val = p.aoe.finisherMinCP or 5
        UIDropDownMenu_SetSelectedValue(frame.aoeFinisherMinDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.aoeFinisherMinDD)
    end
end

RoRotaGUIAoELoaded = true

-- ============================================================================
-- POISONS TAB
-- ============================================================================

function RoRotaGUI.CreatePoisonsTab(parent, frame)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    local cfg = RoRota.db.profile.poisons
    local poisonTypes = {"None", "Agitating Poison", "Corrosive Poison", "Crippling Poison", "Deadly Poison", "Dissolvent Poison", "Instant Poison", "Mind-numbing Poison", "Wound Poison", "Sharpening Stone"}
    
    frame.autoApplyCheck = layout:Row("Auto-Apply Poisons",
        RoRotaGUI.CreateCheckbox("RoRotaAutoApplyCheck", parent, 0, 0, "", function()
            cfg.autoApply = (this:GetChecked() == 1)
        end), 20, "Automatically apply poisons when they expire")
    
    frame.applyInCombatCheck = layout:Row("Allow in Combat",
        RoRotaGUI.CreateCheckbox("RoRotaApplyInCombatCheck", parent, 0, 0, "", function()
            cfg.applyInCombat = (this:GetChecked() == 1)
        end), 40, "Allow poison application during combat")
    
    frame.mainHandPoisonDD = layout:Row("Main Hand Poison",
        RoRotaGUI.CreateDropdown("RoRotaMainHandPoisonDD", parent, 0, 0, 180, poisonTypes, function(v)
            cfg.mainHandPoison = v
        end), 20, "Poison to apply on main hand weapon")
    
    frame.offHandPoisonDD = layout:Row("Off Hand Poison",
        RoRotaGUI.CreateDropdown("RoRotaOffHandPoisonDD", parent, 0, 0, 180, poisonTypes, function(v)
            cfg.offHandPoison = v
        end), 40, "Poison to apply on off hand weapon")
    
    frame.poisonCheck = layout:Row("Enable Poison Warnings",
        RoRotaGUI.CreateCheckbox("RoRotaPoisonCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Show warnings when poisons are about to expire")
    
    frame.poisonTimeDD = layout:Row("Time Threshold (minutes)",
        RoRotaGUI.CreateDropdown("RoRotaPoisonTimeDD", parent, 0, 0, 80,
            {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, function(v)
            cfg.timeThreshold = tonumber(v) * 60
        end), 20, "Warn when poison has this many minutes remaining")
    
    frame.poisonChargesDD = layout:Row("Charges Threshold",
        RoRotaGUI.CreateDropdownNumeric("RoRotaPoisonChargesDD", parent, 0, 0, 5, 50, 5, function(v)
            cfg.chargesThreshold = v
        end), 40, "Warn when poison has this many charges remaining")
    
    local testBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Test Warning")
    testBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
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
    frame.profileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 285, y + 4)
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
    y = y - 20
    
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
    frame.soloProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 285, y + 4)
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
    y = y - 20
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Group Profile")
    frame.groupProfileDD = CreateFrame("Frame", "RoRotaGroupProfileDD", parent, "UIDropDownMenuTemplate")
    frame.groupProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 285, y + 4)
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
    y = y - 20
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Raid Profile")
    frame.raidProfileDD = CreateFrame("Frame", "RoRotaRaidProfileDD", parent, "UIDropDownMenuTemplate")
    frame.raidProfileDD:SetPoint("TOPLEFT", parent, "TOPLEFT", 285, y + 4)
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
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    title:SetText("Preview Window Settings")
    layout:Space(40)
    
    local toggleBtn = RoRotaGUI.CreateButton(nil, parent, 150, 25, "Toggle Preview")
    toggleBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
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
    layout:Space(40)
    
    local depthLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    depthLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    depthLabel:SetText("Show abilities:")
    
    local depthDropdown = RoRotaGUI.CreateDropdown("RoRotaPreviewDepthDropdown", parent, 140, layout:GetY(), 60, {"1", "2", "3"}, function(value)
        if RoRota and RoRota.db and RoRota.db.profile then
            RoRota.db.profile.previewDepth = tonumber(value)
        end
    end)
    frame.previewDepthDropdown = depthDropdown
    layout:Space(20)
    
    local depthDesc = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, layout:GetY())
    depthDesc:SetText("1 = Current ability only")
    layout:Space(18)
    
    local depthDesc2 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc2:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, layout:GetY())
    depthDesc2:SetText("2 = Current + Next ability")
    layout:Space(18)
    
    local depthDesc3 = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    depthDesc3:SetPoint("TOPLEFT", parent, "TOPLEFT", 40, layout:GetY())
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
    subtabBar:SetHeight(460)
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
    
    local subtabs = {"Bleed", "Stun", "Incapacitate", "Immunity\nBuffs", "Silence"}
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
    if RoRotaGUI.CreateImmunityBuffsSubTab then
        RoRotaGUI.CreateImmunityBuffsSubTab(frame.immunitySubtabFrames[4])
    end
    if RoRotaGUI.CreateSilenceSubTab then
        RoRotaGUI.CreateSilenceSubTab(frame.immunitySubtabFrames[5])
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
    y = y - 15
    
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
    y = y - 15
    
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
    if frame.immunitySubtabFrames[4] and frame.immunitySubtabFrames[4].Refresh then
        frame.immunitySubtabFrames[4]:Refresh()
    end
    if frame.immunitySubtabFrames[5] and frame.immunitySubtabFrames[5].Refresh then
        frame.immunitySubtabFrames[5]:Refresh()
    end
end

function RoRotaGUI.CreateImmunityBuffsSubTab(parent)
    local y = -10
    
    local topLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    topLabel:SetText("Buff names that prevent attacks")
    y = y - 15
    
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetWidth(350)
    scroll:SetHeight(380)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    
    local list = CreateFrame("Frame", nil, scroll)
    list:SetWidth(350)
    list:SetHeight(1)
    scroll:SetScrollChild(list)
    
    local slider = CreateFrame("Slider", nil, scroll)
    slider:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 18, 0)
    slider:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 18, 0)
    slider:SetWidth(16)
    slider:SetOrientation("VERTICAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function()
        scroll:SetVerticalScroll(this:GetValue())
    end)
    parent.slider = slider
    parent.sliderMax = 100
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function()
        if not parent.slider then return end
        local current = parent.slider:GetValue()
        local maxVal = parent.sliderMax or 100
        local step = 20
        if arg1 > 0 then
            parent.slider:SetValue(math.max(0, current - step))
        else
            parent.slider:SetValue(math.min(maxVal, current + step))
        end
    end)
    
    parent.list = list
    
    function parent:Refresh()
        if not RoRotaDB or not RoRotaDB.immunityBuffs then
            RoRotaDB.immunityBuffs = {}
        end
        
        local children = {self.list:GetChildren()}
        for i = 1, table.getn(children) do
            children[i]:Hide()
        end
        
        local buffs = {}
        for buffName in pairs(RoRotaDB.immunityBuffs) do
            table.insert(buffs, buffName)
        end
        table.sort(buffs)
        
        local yPos = -5
        for _, buffName in ipairs(buffs) do
            local row = CreateFrame("Frame", nil, self.list)
            row:SetWidth(360)
            row:SetHeight(22)
            row:SetPoint("TOPLEFT", self.list, "TOPLEFT", 0, yPos)
            
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
            nameText:SetText(buffName)
            
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetWidth(50)
            deleteBtn:SetHeight(18)
            deleteBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            deleteBtn:SetText("Delete")
            deleteBtn.buffName = buffName
            RoRotaGUI.SkinButton(deleteBtn)
            deleteBtn:SetScript("OnClick", function()
                RoRotaDB.immunityBuffs[this.buffName] = nil
                parent:Refresh()
            end)
            
            yPos = yPos - 24
        end
        
        local height = math.max(1, math.abs(yPos))
        self.list:SetHeight(height)
        if self.slider then
            local maxVal = math.max(0, height - 380)
            self.slider:SetMinMaxValues(0, maxVal)
            self.sliderMax = maxVal
        end
    end
    
    y = y - 390
    
    local addBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    addBtn:SetWidth(100)
    addBtn:SetHeight(25)
    addBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    addBtn:SetText("Add Buff")
    RoRotaGUI.SkinButton(addBtn)
    addBtn:SetScript("OnClick", function()
        StaticPopupDialogs["ROROTA_ADD_IMMUNITY_BUFF"] = {
            text = "Enter buff name:",
            button1 = "Add",
            button2 = "Cancel",
            hasEditBox = 1,
            maxLetters = 50,
            OnAccept = function()
                local name = getglobal(this:GetParent():GetName().."EditBox"):GetText()
                if name and name ~= "" then
                    if not RoRotaDB.immunityBuffs then
                        RoRotaDB.immunityBuffs = {}
                    end
                    RoRotaDB.immunityBuffs[name] = true
                    RoRota:Print("Added immunity buff: "..name)
                    parent:Refresh()
                end
            end,
            OnShow = function()
                getglobal(this:GetName().."EditBox"):SetFocus()
            end,
            EditBoxOnEnterPressed = function()
                local name = this:GetText()
                if name and name ~= "" then
                    if not RoRotaDB.immunityBuffs then
                        RoRotaDB.immunityBuffs = {}
                    end
                    RoRotaDB.immunityBuffs[name] = true
                    RoRota:Print("Added immunity buff: "..name)
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
        StaticPopup_Show("ROROTA_ADD_IMMUNITY_BUFF")
    end)
    
    local clearBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    clearBtn:SetWidth(80)
    clearBtn:SetHeight(25)
    clearBtn:SetPoint("LEFT", addBtn, "RIGHT", 10, 0)
    clearBtn:SetText("Clear All")
    RoRotaGUI.SkinButton(clearBtn)
    clearBtn:SetScript("OnClick", function()
        RoRotaDB.immunityBuffs = {}
        parent:Refresh()
    end)
end

function RoRotaGUI.CreateSilenceSubTab(parent)
    local y = -10
    
    local topLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    topLabel:SetText("Uninterruptible spells (Target - Spell)")
    y = y - 15
    
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetWidth(350)
    scroll:SetHeight(380)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    
    local list = CreateFrame("Frame", nil, scroll)
    list:SetWidth(350)
    list:SetHeight(1)
    scroll:SetScrollChild(list)
    
    local slider = CreateFrame("Slider", nil, scroll)
    slider:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 18, 0)
    slider:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 18, 0)
    slider:SetWidth(16)
    slider:SetOrientation("VERTICAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function()
        scroll:SetVerticalScroll(this:GetValue())
    end)
    parent.slider = slider
    parent.sliderMax = 100
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function()
        if not parent.slider then return end
        local current = parent.slider:GetValue()
        local maxVal = parent.sliderMax or 100
        local step = 20
        if arg1 > 0 then
            parent.slider:SetValue(math.max(0, current - step))
        else
            parent.slider:SetValue(math.min(maxVal, current + step))
        end
    end)
    
    parent.list = list
    
    function parent:Refresh()
        if not RoRotaDB then return end
        if not RoRotaDB.uninterruptible or type(RoRotaDB.uninterruptible) ~= "table" then
            RoRotaDB.uninterruptible = {}
        end
        
        local children = {self.list:GetChildren()}
        for i = 1, table.getn(children) do
            children[i]:Hide()
        end
        
        local entries = {}
        for targetName, spells in pairs(RoRotaDB.uninterruptible) do
            if type(spells) == "table" then
                for spellName in pairs(spells) do
                    table.insert(entries, {target = targetName, spell = spellName})
                end
            end
        end
        table.sort(entries, function(a, b)
            if a.target == b.target then
                return a.spell < b.spell
            end
            return a.target < b.target
        end)
        
        local yPos = -5
        for _, entry in ipairs(entries) do
            local row = CreateFrame("Frame", nil, self.list)
            row:SetWidth(360)
            row:SetHeight(22)
            row:SetPoint("TOPLEFT", self.list, "TOPLEFT", 0, yPos)
            
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameText:SetPoint("LEFT", row, "LEFT", 5, 0)
            nameText:SetText(entry.target.." - "..entry.spell)
            
            local deleteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            deleteBtn:SetWidth(50)
            deleteBtn:SetHeight(18)
            deleteBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            deleteBtn:SetText("Delete")
            deleteBtn.targetName = entry.target
            deleteBtn.spellName = entry.spell
            RoRotaGUI.SkinButton(deleteBtn)
            deleteBtn:SetScript("OnClick", function()
                if RoRotaDB.uninterruptible[this.targetName] then
                    RoRotaDB.uninterruptible[this.targetName][this.spellName] = nil
                    local hasSpells = false
                    for _ in pairs(RoRotaDB.uninterruptible[this.targetName]) do
                        hasSpells = true
                        break
                    end
                    if not hasSpells then
                        RoRotaDB.uninterruptible[this.targetName] = nil
                    end
                end
                parent:Refresh()
            end)
            
            yPos = yPos - 24
        end
        
        local height = math.max(1, math.abs(yPos))
        self.list:SetHeight(height)
        if self.slider then
            local maxVal = math.max(0, height - 380)
            self.slider:SetMinMaxValues(0, maxVal)
            self.sliderMax = maxVal
        end
    end
    
    y = y - 390
    
    local clearBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    clearBtn:SetWidth(80)
    clearBtn:SetHeight(25)
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    clearBtn:SetText("Clear All")
    RoRotaGUI.SkinButton(clearBtn)
    clearBtn:SetScript("OnClick", function()
        RoRotaDB.uninterruptible = {}
        parent:Refresh()
    end)
end

RoRotaGUIImmunitiesLoaded = true
RoRotaGUIPreviewLoaded = true

-- Flourish Subtab
function RoRotaGUI.CreateFlourishSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.Flourish
    
    widgets.flourishCheck = layout:Row("Enable Flourish",
        RoRotaGUI.CreateCheckbox("RoRotaFlourishCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Flourish in rotation")
    
    widgets.flourishMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaFlourishMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Flourish")
    
    widgets.flourishMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaFlourishMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Flourish")
    
    widgets.flourishPlayerMinEB = layout:Row("Player Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaFlourishPlayerMinEB", parent, 0, 0, function(v)
            cfg.playerMinHP = tonumber(v) or 0
        end), 20, "Only use Flourish if player HP is above this")
    
    widgets.flourishPlayerMaxEB = layout:Row("Player Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaFlourishPlayerMaxEB", parent, 0, 0, function(v)
            cfg.playerMaxHP = tonumber(v) or 100
        end), 20, "Only use Flourish if player HP is below this")
    
    widgets.flourishRefreshEB = layout:Row("Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaFlourishRefreshEB", parent, 0, 0, 50, 0, 10, function(v)
            cfg.refreshThreshold = v
        end), 20, "Refresh Flourish when this many seconds remain")
    
    RoRotaGUI.CreateLabel(parent, 10, layout:GetY(), "Extra Conditions")
    layout:Space(20)
    widgets.flourishConditionsEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaFlourishConditionsEB", parent, 10, layout:GetY(), 360, 90, function(v)
        cfg.conditions = v
    end)
end

function RoRotaGUI.LoadFlourishSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.flourishCheck and p.abilities and p.abilities.Flourish then
        widgets.flourishCheck:SetChecked(p.abilities.Flourish.enabled and 1 or nil)
    end
    if widgets.flourishMinDD and p.abilities and p.abilities.Flourish then
        local val = p.abilities.Flourish.minCP or 4
        UIDropDownMenu_SetSelectedValue(widgets.flourishMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.flourishMinDD)
    end
    if widgets.flourishMaxDD and p.abilities and p.abilities.Flourish then
        local val = p.abilities.Flourish.maxCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.flourishMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.flourishMaxDD)
    end
    if widgets.flourishPlayerMinEB and p.abilities and p.abilities.Flourish then
        widgets.flourishPlayerMinEB:SetText(tostring(p.abilities.Flourish.playerMinHP or 0))
    end
    if widgets.flourishPlayerMaxEB and p.abilities and p.abilities.Flourish then
        widgets.flourishPlayerMaxEB:SetText(tostring(p.abilities.Flourish.playerMaxHP or 80))
    end
    if widgets.flourishRefreshEB and p.abilities and p.abilities.Flourish then
        local val = p.abilities.Flourish.refreshThreshold or 0
        widgets.flourishRefreshEB:SetText(string.format("%.1f", val))
    end
    if widgets.flourishConditionsEB and p.abilities and p.abilities.Flourish then
        widgets.flourishConditionsEB:SetText(p.abilities.Flourish.conditions or "")
    end
end

-- Kidney Shot Subtab
function RoRotaGUI.CreateKidneyShotSubTab(parent, widgets)
    local layout = RoRotaGUI.CreateLayout(parent, 10, -20)
    local cfg = RoRota.db.profile.abilities.KidneyShot
    
    widgets.kidneyCheck = layout:Row("Enable Kidney Shot",
        RoRotaGUI.CreateCheckbox("RoRotaKidneyCheck", parent, 0, 0, "", function()
            cfg.enabled = (this:GetChecked() == 1)
        end), 20, "Enable Kidney Shot in rotation")
    
    widgets.kidneyMinDD = layout:Row("Minimum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaKidneyMinDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.minCP = v
        end), 20, "Minimum combo points for Kidney Shot")
    
    widgets.kidneyMaxDD = layout:Row("Maximum CP",
        RoRotaGUI.CreateDropdownNumeric("RoRotaKidneyMaxDD", parent, 0, 0, 1, 5, 1, function(v)
            cfg.maxCP = v
        end), 20, "Maximum combo points for Kidney Shot")
    
    widgets.kidneyTargetMinEB = layout:Row("Target Min HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaKidneyTargetMinEB", parent, 0, 0, function(v)
            cfg.targetMinHP = tonumber(v) or 0
        end), 20, "Only use Kidney Shot if target HP is above this")
    
    widgets.kidneyTargetMaxEB = layout:Row("Target Max HP %",
        RoRotaGUI.CreatePercentEditBox("RoRotaKidneyTargetMaxEB", parent, 0, 0, function(v)
            cfg.targetMaxHP = tonumber(v) or 100
        end), 20, "Only use Kidney Shot if target HP is below this")
    
    widgets.kidneyElitesCheck = layout:Row("Only use on Elites",
        RoRotaGUI.CreateCheckbox("RoRotaKidneyElitesCheck", parent, 0, 0, "", function()
            cfg.onlyElites = (this:GetChecked() == 1)
        end), 20, "Only use Kidney Shot on elite/boss targets")
end

function RoRotaGUI.LoadKidneyShotSubTab(widgets)
    local p = RoRota.db.profile
    if not p then return end
    
    if widgets.kidneyCheck and p.abilities and p.abilities.KidneyShot then
        widgets.kidneyCheck:SetChecked(p.abilities.KidneyShot.enabled and 1 or nil)
    end
    if widgets.kidneyMinDD and p.abilities and p.abilities.KidneyShot then
        local val = p.abilities.KidneyShot.minCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.kidneyMinDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.kidneyMinDD)
    end
    if widgets.kidneyMaxDD and p.abilities and p.abilities.KidneyShot then
        local val = p.abilities.KidneyShot.maxCP or 5
        UIDropDownMenu_SetSelectedValue(widgets.kidneyMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), widgets.kidneyMaxDD)
    end
    if widgets.kidneyTargetMinEB and p.abilities and p.abilities.KidneyShot then
        widgets.kidneyTargetMinEB:SetText(tostring(p.abilities.KidneyShot.targetMinHP or 0))
    end
    if widgets.kidneyTargetMaxEB and p.abilities and p.abilities.KidneyShot then
        widgets.kidneyTargetMaxEB:SetText(tostring(p.abilities.KidneyShot.targetMaxHP or 100))
    end
    if widgets.kidneyElitesCheck and p.abilities and p.abilities.KidneyShot then
        widgets.kidneyElitesCheck:SetChecked(p.abilities.KidneyShot.onlyElites and 1 or nil)
    end
end
