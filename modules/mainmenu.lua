--[[ mainmenu ]]--
-- Reorganized main GUI with 10 tabs following gui_widgets patterns

RoRotaMainMenu = RoRotaMainMenu or {}

local function ShowTab(frame, index)
    for i = 1, table.getn(frame.tabs) do
        if frame.tabs[i].content then
            if i == index then
                frame.tabs[i].content:Show()
                RoRotaGUI.SetSidebarButtonActive(frame.tabs[i].button, true)
            else
                frame.tabs[i].content:Hide()
                RoRotaGUI.SetSidebarButtonActive(frame.tabs[i].button, false)
            end
        end
    end
end

-- ============================================================================
-- TAB 1: ABOUT
-- ============================================================================

function RoRotaMainMenu.CreateAboutTab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -40)
    
    local setupMsg = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    setupMsg:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    setupMsg:SetText("RoRota - One-button rotation addon for Rogues")
    layout:Space(30)
    
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
    
    local guideBtn = RoRotaGUI.CreateButton(nil, parent, 180, 25, "Open Guide")
    guideBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 210, layout:GetY())
    guideBtn:SetScript("OnClick", function()
        RoRota:ShowGuide()
        RoRota:Print("Commands: /rr preview (toggle preview), /rr help (show commands)")
    end)
    layout:Space(50)
    
    local thanks = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    thanks:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    thanks:SetText("Special thanks: Turtle WoW community")
    thanks:SetTextColor(0.8, 0.8, 0.8)
    layout:Space(20)
    
    local link = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    link:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    link:SetText("GitHub: github.com/thefeeder5/RoRota-TWOW")
    link:SetTextColor(0.2, 1, 0.8)
end

function RoRotaMainMenu.LoadAboutTab(frame)
end

-- ============================================================================
-- TAB 2: OPENERS & EQUIPMENT (3 subtabs)
-- ============================================================================

local function CreateStealthOpenersSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Stealth Opener Priority (Top = First)")
    layout:Space(25)
    
    local openerAbilities = {"Ambush", "Garrote", "Cheap Shot", "Main Builder"}
    parent.openerList = RoRotaGUI.CreatePriorityList(parent, 20, layout:GetY(), 220, 130, openerAbilities, function(items)
        local priority = {}
        for _, ability in ipairs(items) do
            table.insert(priority, {ability = ability, conditions = ""})
        end
        RoRota.db.profile.opener.priority = priority
    end)
    layout:Space(140)
    
    layout:Row("Failsafe Attempts", RoRotaGUI.CreateDropdown("RoRotaStealthOpenerFailDD", parent, 0, 0, 100, 
        {"Disabled", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, function(v)
        RoRota.db.profile.opener.failsafeAttempts = v == "Disabled" and -1 or tonumber(v)
    end), 30)
    parent.failsafeDD = getglobal("RoRotaStealthOpenerFailDD")
    
    local pickPocketCheck = RoRotaGUI.CreateCheckbox("RoRotaPickPocket", parent, 20, layout:GetY(), "Pick Pocket before opener", function()
        RoRota.db.profile.opener.pickPocket = (this:GetChecked() == 1)
    end)
    layout:Space(25)
    
    parent.stealthEquipDD = CreateFrame("Frame", "RoRotaStealthEquipDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, parent.stealthEquipDD)
    parent.stealthEquipDD.dropdownWidth = 150
    layout:Row("Equipment Set", parent.stealthEquipDD, 30)
    
    local left = getglobal("RoRotaStealthEquipDDLeft")
    local middle = getglobal("RoRotaStealthEquipDDMiddle")
    local right = getglobal("RoRotaStealthEquipDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(parent.stealthEquipDD, function()
        local sets = {"None"}
        if RoRota.db.profile.equipmentSets then
            for name in pairs(RoRota.db.profile.equipmentSets) do
                table.insert(sets, name)
            end
            table.sort(sets)
        end
        for _, setName in ipairs(sets) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = setName
            info.value = setName
            info.func = function()
                RoRota.db.profile.opener.equipmentSet = (this.value == "None" and nil or this.value)
                UIDropDownMenu_SetSelectedValue(parent.stealthEquipDD, this.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

local function CreateVanishOpenersSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Vanish Opener Priority (Top = First)")
    layout:Space(25)
    
    local vanishAbilities = {"Ambush", "Garrote", "Cheap Shot", "Main Builder"}
    parent.vanishList = RoRotaGUI.CreatePriorityList(parent, 20, layout:GetY(), 220, 130, vanishAbilities, function(items)
        local priority = {}
        for _, ability in ipairs(items) do
            table.insert(priority, {ability = ability, conditions = ""})
        end
        RoRota.db.profile.vanishOpener.priority = priority
    end)
    layout:Space(140)
    
    parent.vanishEquipDD = CreateFrame("Frame", "RoRotaVanishEquipDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, parent.vanishEquipDD)
    parent.vanishEquipDD.dropdownWidth = 150
    layout:Row("Equipment Set", parent.vanishEquipDD, 30)
    
    local left = getglobal("RoRotaVanishEquipDDLeft")
    local middle = getglobal("RoRotaVanishEquipDDMiddle")
    local right = getglobal("RoRotaVanishEquipDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(parent.vanishEquipDD, function()
        local sets = {"None"}
        if RoRota.db.profile.equipmentSets then
            for name in pairs(RoRota.db.profile.equipmentSets) do
                table.insert(sets, name)
            end
            table.sort(sets)
        end
        for _, setName in ipairs(sets) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = setName
            info.value = setName
            info.func = function()
                RoRota.db.profile.vanishOpener.equipmentSet = (this.value == "None" and nil or this.value)
                UIDropDownMenu_SetSelectedValue(parent.vanishEquipDD, this.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Vanish Conditions:")
    layout:Space(25)
    local condEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaVanishCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.defensive.vanishConditions = text
    end)
    parent.vanishCondEB = condEB
end

local function CreateEquipmentSetsSubtab(parent)
    RoRotaGUI.CreateEquipmentTab(parent, parent)
end

function RoRotaMainMenu.CreateOpenersTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Stealth", "Vanish", "Equipment"},
        {CreateStealthOpenersSubtab, CreateVanishOpenersSubtab, CreateEquipmentSetsSubtab},
        {nil, nil, RoRotaGUI.LoadEquipmentTab}
    )
end

function RoRotaMainMenu.LoadOpenersTab(frame)
    if frame.subtabFrames and frame.subtabFrames[1] then
        local cfg = RoRota.db.profile.opener
        if cfg then
            local pickCheck = getglobal("RoRotaPickPocket")
            if pickCheck then
                pickCheck:SetChecked(cfg.pickPocket and 1 or nil)
            end
            
            if frame.subtabFrames[1].failsafeDD then
                local val = cfg.failsafeAttempts or -1
                local text = val == -1 and "Disabled" or tostring(val)
                UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].failsafeDD, text)
                UIDropDownMenu_SetText(text, frame.subtabFrames[1].failsafeDD)
            end
            
            if frame.subtabFrames[1].stealthEquipDD then
                UIDropDownMenu_Initialize(frame.subtabFrames[1].stealthEquipDD, frame.subtabFrames[1].stealthEquipDD.initialize)
                local val = cfg.equipmentSet or "None"
                UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].stealthEquipDD, val)
                UIDropDownMenu_SetText(val, frame.subtabFrames[1].stealthEquipDD)
            end
            
            if frame.subtabFrames[1].openerList then
                local items = {}
                if cfg.priority and table.getn(cfg.priority) == 4 then
                    for _, entry in ipairs(cfg.priority) do
                        table.insert(items, entry.ability)
                    end
                else
                    -- Reset to default if not exactly 4 abilities
                    items = {"Ambush", "Garrote", "Cheap Shot", "Main Builder"}
                    cfg.priority = {}
                    for _, ability in ipairs(items) do
                        table.insert(cfg.priority, {ability = ability, conditions = ""})
                    end
                end
                frame.subtabFrames[1].openerList:SetItems(items)
            end
        end
    end
    
    if frame.subtabFrames and frame.subtabFrames[2] then
        local cfg = RoRota.db.profile.vanishOpener
        if cfg then
            if frame.subtabFrames[2].vanishEquipDD then
                UIDropDownMenu_Initialize(frame.subtabFrames[2].vanishEquipDD, frame.subtabFrames[2].vanishEquipDD.initialize)
                local val = cfg.equipmentSet or "None"
                UIDropDownMenu_SetSelectedValue(frame.subtabFrames[2].vanishEquipDD, val)
                UIDropDownMenu_SetText(val, frame.subtabFrames[2].vanishEquipDD)
            end
            
            if frame.subtabFrames[2].vanishList then
                local items = {}
                if cfg.priority and table.getn(cfg.priority) == 4 then
                    for _, entry in ipairs(cfg.priority) do
                        table.insert(items, entry.ability)
                    end
                else
                    -- Reset to default if not exactly 4 abilities
                    items = {"Ambush", "Garrote", "Cheap Shot", "Main Builder"}
                    cfg.priority = {}
                    for _, ability in ipairs(items) do
                        table.insert(cfg.priority, {ability = ability, conditions = ""})
                    end
                end
                frame.subtabFrames[2].vanishList:SetItems(items)
            end
        end
    end
    
    if frame.subtabFrames and frame.subtabFrames[3] then
        RoRotaGUI.LoadEquipmentTab(frame.subtabFrames[3])
    end
end

-- ============================================================================
-- TAB 3: FINISHERS (9 subtabs)
-- ============================================================================

local function CreateFinisherGlobalSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Finisher Priority (Top = First)")
    layout:Space(25)
    
    local finishers = {"Slice and Dice", "Flourish", "Envenom", "Rupture", "Expose Armor", "Shadow of Death", "Kidney Shot", "Cold Blood Eviscerate"}
    parent.finisherList = RoRotaGUI.CreatePriorityList(parent, 20, layout:GetY(), 220, 220, finishers, function(items)
        RoRota.db.profile.finisherPriority = items
    end)
    layout:Space(230)
    
    layout:Row("Finisher Refresh Window (sec)",
        RoRotaGUI.CreateDecimalEditBox("RoRotaRefreshThresholdEB", parent, 0, 0, 50, 0, 10, function(v)
            RoRota.db.profile.finisherRefreshThreshold = v
        end), 25)
    
    layout:Row("TTK Tracking Enable",
        RoRotaGUI.CreateCheckbox("RoRotaTTKEnabledCheck", parent, 0, 0, "", function()
            RoRota.db.profile.ttk.enabled = (this:GetChecked() == 1)
        end), 25)
    
    layout:Row("TTK Exclude Bosses",
        RoRotaGUI.CreateCheckbox("RoRotaTTKExcludeBossesCheck", parent, 0, 0, "", function()
            RoRota.db.profile.ttk.excludeBosses = (this:GetChecked() == 1)
        end), 25)
end

local function CreateSndSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    parent.sndEnabledCheck = RoRotaGUI.CreateCheckbox("RoRotaSndEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.SliceAndDice.enabled = (this:GetChecked() == 1)
    end)
    layout:Row("Enable", parent.sndEnabledCheck, 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaSndMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.SliceAndDice.minCP = tonumber(v)
    end), 30)
    parent.sndMinCPDD = getglobal("RoRotaSndMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaSndMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.SliceAndDice.maxCP = tonumber(v)
    end), 30)
    parent.sndMaxCPDD = getglobal("RoRotaSndMaxCPDD")
    
    parent.sndMinHPEB = RoRotaGUI.CreateEditBox("RoRotaSndMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.SliceAndDice.targetMinHP = v
    end)
    layout:Row("Target Min HP %", parent.sndMinHPEB, 25)
    parent.sndMaxHPEB = RoRotaGUI.CreateEditBox("RoRotaSndMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.SliceAndDice.targetMaxHP = v
    end)
    layout:Row("Target Max HP %", parent.sndMaxHPEB, 25)
    parent.sndRefreshEB = RoRotaGUI.CreateDecimalEditBox("RoRotaSndRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.SliceAndDice.refreshThreshold = v
    end)
    layout:Row("Refresh Threshold (sec)", parent.sndRefreshEB, 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.sndCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaSndCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.SliceAndDice.conditions = text
    end)
end

local function CreateRuptureSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaRuptureEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Rupture.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaRuptureMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Rupture.minCP = tonumber(v)
    end), 30)
    parent.ruptureMinCPDD = getglobal("RoRotaRuptureMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaRuptureMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Rupture.maxCP = tonumber(v)
    end), 30)
    parent.ruptureMaxCPDD = getglobal("RoRotaRuptureMaxCPDD")
    
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaRuptureMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Rupture.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaRuptureMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Rupture.targetMaxHP = v
    end), 25)
    layout:Row("Refresh Threshold (sec)", RoRotaGUI.CreateDecimalEditBox("RoRotaRuptureRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.Rupture.refreshThreshold = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.ruptureCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaRuptureCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.Rupture.conditions = text
    end)
end

local function CreateExposeSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaExposeEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.ExposeArmor.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaExposeMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.ExposeArmor.minCP = tonumber(v)
    end), 30)
    parent.exposeMinCPDD = getglobal("RoRotaExposeMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaExposeMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.ExposeArmor.maxCP = tonumber(v)
    end), 30)
    parent.exposeMaxCPDD = getglobal("RoRotaExposeMaxCPDD")
    
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaExposeMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.ExposeArmor.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaExposeMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.ExposeArmor.targetMaxHP = v
    end), 25)
    layout:Row("Refresh Threshold (sec)", RoRotaGUI.CreateDecimalEditBox("RoRotaExposeRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.ExposeArmor.refreshThreshold = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.exposeCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaExposeCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.ExposeArmor.conditions = text
    end)
end

local function CreateEnvenomSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaEnvenomEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Envenom.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaEnvenomMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Envenom.minCP = tonumber(v)
    end), 30)
    parent.envenomMinCPDD = getglobal("RoRotaEnvenomMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaEnvenomMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Envenom.maxCP = tonumber(v)
    end), 30)
    parent.envenomMaxCPDD = getglobal("RoRotaEnvenomMaxCPDD")
    
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaEnvenomMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Envenom.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaEnvenomMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Envenom.targetMaxHP = v
    end), 25)
    layout:Row("Refresh Threshold (sec)", RoRotaGUI.CreateDecimalEditBox("RoRotaEnvenomRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.Envenom.refreshThreshold = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.envenomCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaEnvenomCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.Envenom.conditions = text
    end)
end

local function CreateShadowOfDeathSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaShadowEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.ShadowOfDeath.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaShadowMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.ShadowOfDeath.minCP = tonumber(v)
    end), 30)
    parent.shadowMinCPDD = getglobal("RoRotaShadowMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaShadowMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.ShadowOfDeath.maxCP = tonumber(v)
    end), 30)
    parent.shadowMaxCPDD = getglobal("RoRotaShadowMaxCPDD")
    
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaShadowMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.ShadowOfDeath.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaShadowMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.ShadowOfDeath.targetMaxHP = v
    end), 25)
    layout:Row("Refresh Threshold (sec)", RoRotaGUI.CreateDecimalEditBox("RoRotaShadowRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.ShadowOfDeath.refreshThreshold = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.shadowCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaShadowCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.ShadowOfDeath.conditions = text
    end)
end

local function CreateEviscerateSub(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaEviscEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Eviscerate.enabled = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaEviscMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Eviscerate.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaEviscMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Eviscerate.targetMaxHP = v
    end), 25)
end

local function CreateFlourishSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaFlourishEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Flourish.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaFlourishMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Flourish.minCP = tonumber(v)
    end), 30)
    parent.flourishMinCPDD = getglobal("RoRotaFlourishMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaFlourishMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.Flourish.maxCP = tonumber(v)
    end), 30)
    parent.flourishMaxCPDD = getglobal("RoRotaFlourishMaxCPDD")
    
    layout:Row("Player Min HP %", RoRotaGUI.CreateEditBox("RoRotaFlourishMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Flourish.playerMinHP = v
    end), 25)
    layout:Row("Player Max HP %", RoRotaGUI.CreateEditBox("RoRotaFlourishMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Flourish.playerMaxHP = v
    end), 25)
    layout:Row("Refresh Threshold (sec)", RoRotaGUI.CreateDecimalEditBox("RoRotaFlourishRefresh", parent, 0, 0, 50, 0, 10, function(v)
        RoRota.db.profile.abilities.Flourish.refreshThreshold = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.flourishCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaFlourishCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.Flourish.conditions = text
    end)
end

local function CreateKidneyShotSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaKidneyEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.KidneyShot.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaKidneyMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.KidneyShot.minCP = tonumber(v)
    end), 30)
    parent.kidneyMinCPDD = getglobal("RoRotaKidneyMinCPDD")
    
    layout:Row("Max CP", RoRotaGUI.CreateDropdown("RoRotaKidneyMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.abilities.KidneyShot.maxCP = tonumber(v)
    end), 30)
    parent.kidneyMaxCPDD = getglobal("RoRotaKidneyMaxCPDD")
    
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaKidneyMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.KidneyShot.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaKidneyMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.KidneyShot.targetMaxHP = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.kidneyCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaKidneyCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.KidneyShot.conditions = text
    end)
end

function RoRotaMainMenu.CreateFinishersTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Global", "Slice\nand Dice", "Rupture", "Expose\nArmor", "Envenom", "Shadow\nof Death", "Eviscerate", "Flourish", "Kidney\nShot"},
        {CreateFinisherGlobalSubtab, CreateSndSubtab, CreateRuptureSubtab, CreateExposeSubtab, CreateEnvenomSubtab, CreateShadowOfDeathSubtab, CreateEviscerateSub, CreateFlourishSubtab, CreateKidneyShotSubtab},
        {nil, nil, nil, nil, nil, nil, nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadFinishersTab(frame)
    if not frame.subtabFrames then return end
    local p = RoRota.db.profile
    if not p then return end
    
    -- Global subtab
    if frame.subtabFrames[1] then
        local refreshEB = getglobal("RoRotaRefreshThresholdEB")
        if refreshEB then
            refreshEB:SetText(string.format("%.1f", p.finisherRefreshThreshold or 2))
        end
        local ttkCheck = getglobal("RoRotaTTKEnabledCheck")
        if ttkCheck and p.ttk then
            ttkCheck:SetChecked(p.ttk.enabled and 1 or nil)
        end
        local ttkBossCheck = getglobal("RoRotaTTKExcludeBossesCheck")
        if ttkBossCheck and p.ttk then
            ttkBossCheck:SetChecked(p.ttk.excludeBosses and 1 or nil)
        end
        if frame.subtabFrames[1].finisherList and p.finisherPriority then
            frame.subtabFrames[1].finisherList:SetItems(p.finisherPriority)
        end
    end
    
    -- SnD subtab
    if frame.subtabFrames[2] and p.abilities.SliceAndDice then
        local cfg = p.abilities.SliceAndDice
        if frame.subtabFrames[2].sndEnabledCheck then
            frame.subtabFrames[2].sndEnabledCheck:SetChecked(cfg.enabled and 1 or nil)
        end
        if frame.subtabFrames[2].sndMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[2].sndMinCPDD, tostring(cfg.minCP or 1))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 1), frame.subtabFrames[2].sndMinCPDD)
        end
        if frame.subtabFrames[2].sndMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[2].sndMaxCPDD, tostring(cfg.maxCP or 2))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 2), frame.subtabFrames[2].sndMaxCPDD)
        end
        if frame.subtabFrames[2].sndMinHPEB then
            frame.subtabFrames[2].sndMinHPEB:SetText(tostring(cfg.targetMinHP or 10))
        end
        if frame.subtabFrames[2].sndMaxHPEB then
            frame.subtabFrames[2].sndMaxHPEB:SetText(tostring(cfg.targetMaxHP or 100))
        end
        if frame.subtabFrames[2].sndRefreshEB then
            frame.subtabFrames[2].sndRefreshEB:SetText(string.format("%.1f", cfg.refreshThreshold or 2))
        end
        if frame.subtabFrames[2].sndCondEB then
            frame.subtabFrames[2].sndCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Rupture subtab
    if frame.subtabFrames[3] and p.abilities.Rupture then
        local cfg = p.abilities.Rupture
        local check = getglobal("RoRotaRuptureEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[3].ruptureMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[3].ruptureMinCPDD, tostring(cfg.minCP or 1))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 1), frame.subtabFrames[3].ruptureMinCPDD)
        end
        if frame.subtabFrames[3].ruptureMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[3].ruptureMaxCPDD, tostring(cfg.maxCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 5), frame.subtabFrames[3].ruptureMaxCPDD)
        end
        local minHP = getglobal("RoRotaRuptureMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 15)) end
        local maxHP = getglobal("RoRotaRuptureMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        local refresh = getglobal("RoRotaRuptureRefresh")
        if refresh then refresh:SetText(string.format("%.1f", cfg.refreshThreshold or 2)) end
        if frame.subtabFrames[3].ruptureCondEB then
            frame.subtabFrames[3].ruptureCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Expose Armor subtab
    if frame.subtabFrames[4] and p.abilities.ExposeArmor then
        local cfg = p.abilities.ExposeArmor
        local check = getglobal("RoRotaExposeEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[4].exposeMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[4].exposeMinCPDD, tostring(cfg.minCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 5), frame.subtabFrames[4].exposeMinCPDD)
        end
        if frame.subtabFrames[4].exposeMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[4].exposeMaxCPDD, tostring(cfg.maxCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 5), frame.subtabFrames[4].exposeMaxCPDD)
        end
        local minHP = getglobal("RoRotaExposeMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaExposeMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        local refresh = getglobal("RoRotaExposeRefresh")
        if refresh then refresh:SetText(string.format("%.1f", cfg.refreshThreshold or 2)) end
        if frame.subtabFrames[4].exposeCondEB then
            frame.subtabFrames[4].exposeCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Envenom subtab
    if frame.subtabFrames[5] and p.abilities.Envenom then
        local cfg = p.abilities.Envenom
        local check = getglobal("RoRotaEnvenomEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[5].envenomMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[5].envenomMinCPDD, tostring(cfg.minCP or 1))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 1), frame.subtabFrames[5].envenomMinCPDD)
        end
        if frame.subtabFrames[5].envenomMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[5].envenomMaxCPDD, tostring(cfg.maxCP or 2))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 2), frame.subtabFrames[5].envenomMaxCPDD)
        end
        local minHP = getglobal("RoRotaEnvenomMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 10)) end
        local maxHP = getglobal("RoRotaEnvenomMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        local refresh = getglobal("RoRotaEnvenomRefresh")
        if refresh then refresh:SetText(string.format("%.1f", cfg.refreshThreshold or 2)) end
        if frame.subtabFrames[5].envenomCondEB then
            frame.subtabFrames[5].envenomCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Shadow of Death subtab
    if frame.subtabFrames[6] and p.abilities.ShadowOfDeath then
        local cfg = p.abilities.ShadowOfDeath
        local check = getglobal("RoRotaShadowEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[6].shadowMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[6].shadowMinCPDD, tostring(cfg.minCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 5), frame.subtabFrames[6].shadowMinCPDD)
        end
        if frame.subtabFrames[6].shadowMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[6].shadowMaxCPDD, tostring(cfg.maxCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 5), frame.subtabFrames[6].shadowMaxCPDD)
        end
        local minHP = getglobal("RoRotaShadowMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaShadowMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        local refresh = getglobal("RoRotaShadowRefresh")
        if refresh then refresh:SetText(string.format("%.1f", cfg.refreshThreshold or 2)) end
        if frame.subtabFrames[6].shadowCondEB then
            frame.subtabFrames[6].shadowCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Eviscerate subtab
    if frame.subtabFrames[7] and p.abilities.Eviscerate then
        local cfg = p.abilities.Eviscerate
        local check = getglobal("RoRotaEviscEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        local minHP = getglobal("RoRotaEviscMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaEviscMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
    end
    
    -- Flourish subtab
    if frame.subtabFrames[8] and p.abilities.Flourish then
        local cfg = p.abilities.Flourish
        local check = getglobal("RoRotaFlourishEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[8].flourishMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[8].flourishMinCPDD, tostring(cfg.minCP or 1))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 1), frame.subtabFrames[8].flourishMinCPDD)
        end
        if frame.subtabFrames[8].flourishMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[8].flourishMaxCPDD, tostring(cfg.maxCP or 2))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 2), frame.subtabFrames[8].flourishMaxCPDD)
        end
        local minHP = getglobal("RoRotaFlourishMinHP")
        if minHP then minHP:SetText(tostring(cfg.playerMinHP or 0)) end
        local maxHP = getglobal("RoRotaFlourishMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.playerMaxHP or 100)) end
        local refresh = getglobal("RoRotaFlourishRefresh")
        if refresh then refresh:SetText(string.format("%.1f", cfg.refreshThreshold or 2)) end
        if frame.subtabFrames[8].flourishCondEB then
            frame.subtabFrames[8].flourishCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Kidney Shot subtab
    if frame.subtabFrames[9] and p.abilities.KidneyShot then
        local cfg = p.abilities.KidneyShot
        local check = getglobal("RoRotaKidneyEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        if frame.subtabFrames[9].kidneyMinCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[9].kidneyMinCPDD, tostring(cfg.minCP or 1))
            UIDropDownMenu_SetText(tostring(cfg.minCP or 1), frame.subtabFrames[9].kidneyMinCPDD)
        end
        if frame.subtabFrames[9].kidneyMaxCPDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[9].kidneyMaxCPDD, tostring(cfg.maxCP or 5))
            UIDropDownMenu_SetText(tostring(cfg.maxCP or 5), frame.subtabFrames[9].kidneyMaxCPDD)
        end
        local minHP = getglobal("RoRotaKidneyMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaKidneyMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        if frame.subtabFrames[9].kidneyCondEB then
            frame.subtabFrames[9].kidneyCondEB:SetText(cfg.conditions or "")
        end
    end
end

-- ============================================================================
-- TAB 4: BUILDERS (6 subtabs)
-- ============================================================================

local function CreateBuilderGlobalSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    layout:Row("Main Builder", RoRotaGUI.CreateDropdown("RoRotaMainBuilderDD", parent, 0, 0, 150,
        {"Sinister Strike", "Backstab", "Hemorrhage", "Noxious Assault"}, function(v)
        RoRota.db.profile.mainBuilder = v
    end), 30)
    parent.mainBuilderDD = getglobal("RoRotaMainBuilderDD")
    
    layout:Row("Secondary Builder", RoRotaGUI.CreateDropdown("RoRotaSecBuilderDD", parent, 0, 0, 150,
        {"Sinister Strike", "Backstab", "Hemorrhage", "Noxious Assault"}, function(v)
        RoRota.db.profile.secondaryBuilder = v
    end), 30)
    parent.secBuilderDD = getglobal("RoRotaSecBuilderDD")
    
    layout:Row("Failsafe Attempts", RoRotaGUI.CreateDropdown("RoRotaBuilderFailDD", parent, 0, 0, 100,
        {"Disabled", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, function(v)
        RoRota.db.profile.builderFailsafe = v == "Disabled" and -1 or tonumber(v)
    end), 30)
    parent.builderFailDD = getglobal("RoRotaBuilderFailDD")
    
    layout:Row("Smart Builders", RoRotaGUI.CreateCheckbox("RoRotaSmartBuilders", parent, 0, 0, "", function()
        RoRota.db.profile.smartBuilders = (this:GetChecked() == 1)
    end), 25)
end

local function CreateRiposteSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaRiposteEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useRiposte = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaRiposteMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.riposteTargetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaRiposteMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.riposteTargetMaxHP = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.riposteCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaRiposteCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.defensive.riposteConditions = text
    end)
end

local function CreateSurpriseSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaSurpriseEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useSurpriseAttack = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaSurpriseMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.surpriseTargetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaSurpriseMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.surpriseTargetMaxHP = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.surpriseCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaSurpriseCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.defensive.surpriseConditions = text
    end)
end

local function CreateMarkSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaMarkEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.MarkForDeath.enabled = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaMarkMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.MarkForDeath.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaMarkMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.MarkForDeath.targetMaxHP = v
    end), 25)
    layout:Row("Elite Only", RoRotaGUI.CreateCheckbox("RoRotaMarkElite", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.MarkForDeath.onlyElites = (this:GetChecked() == 1)
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.markCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaMarkCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.MarkForDeath.conditions = text
    end)
end

local function CreateHemoSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaHemoEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Hemorrhage.enabled = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Only When Missing", RoRotaGUI.CreateCheckbox("RoRotaHemoMissing", parent, 0, 0, "", function()
        RoRota.db.profile.abilities.Hemorrhage.onlyWhenMissing = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Min HP %", RoRotaGUI.CreateEditBox("RoRotaHemoMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Hemorrhage.targetMinHP = v
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaHemoMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.abilities.Hemorrhage.targetMaxHP = v
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.hemoCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaHemoCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.abilities.Hemorrhage.conditions = text
    end)
end

local function CreateGhostlySubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaGhostlyEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useGhostlyStrike = (this:GetChecked() == 1)
    end), 25)
    layout:Row("Target Max HP %", RoRotaGUI.CreateEditBox("RoRotaGhostlyTargetHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.ghostlyTargetMaxHP = v
    end), 25)
    layout:Row("Player Min HP %", RoRotaGUI.CreateEditBox("RoRotaGhostlyMinHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.ghostlyPlayerMinHP = v
    end), 25)
    layout:Row("Player Max HP %", RoRotaGUI.CreateEditBox("RoRotaGhostlyMaxHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.ghostlyPlayerMaxHP = v
    end), 25)
    layout:Row("Targeted Only", RoRotaGUI.CreateCheckbox("RoRotaGhostlyTargeted", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.ghostlyTargetedOnly = (this:GetChecked() == 1)
    end), 25)
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.ghostlyCondEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaGhostlyCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.defensive.ghostlyConditions = text
    end)
end

function RoRotaMainMenu.CreateBuildersTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Global", "Riposte", "Surprise\nAttack", "Mark for\nDeath", "Hemorrhage", "Ghostly\nStrike"},
        {CreateBuilderGlobalSubtab, CreateRiposteSubtab, CreateSurpriseSubtab, CreateMarkSubtab, CreateHemoSubtab, CreateGhostlySubtab},
        {nil, nil, nil, nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadBuildersTab(frame)
    if not frame.subtabFrames then return end
    local p = RoRota.db.profile
    if not p then return end
    
    -- Global subtab
    if frame.subtabFrames[1] then
        if frame.subtabFrames[1].mainBuilderDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].mainBuilderDD, p.mainBuilder or "Sinister Strike")
            UIDropDownMenu_SetText(p.mainBuilder or "Sinister Strike", frame.subtabFrames[1].mainBuilderDD)
        end
        if frame.subtabFrames[1].secBuilderDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].secBuilderDD, p.secondaryBuilder or "Sinister Strike")
            UIDropDownMenu_SetText(p.secondaryBuilder or "Sinister Strike", frame.subtabFrames[1].secBuilderDD)
        end
        if frame.subtabFrames[1].builderFailDD then
            local val = p.builderFailsafe or 3
            local text = val == -1 and "Disabled" or tostring(val)
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].builderFailDD, text)
            UIDropDownMenu_SetText(text, frame.subtabFrames[1].builderFailDD)
        end
        local smartCheck = getglobal("RoRotaSmartBuilders")
        if smartCheck then
            smartCheck:SetChecked(p.smartBuilders and 1 or nil)
        end
    end
    
    -- Riposte subtab
    if frame.subtabFrames[2] and p.defensive then
        local check = getglobal("RoRotaRiposteEnabled")
        if check then check:SetChecked(p.defensive.useRiposte and 1 or nil) end
        local minHP = getglobal("RoRotaRiposteMinHP")
        if minHP then minHP:SetText(tostring(p.defensive.riposteTargetMinHP or 0)) end
        local maxHP = getglobal("RoRotaRiposteMaxHP")
        if maxHP then maxHP:SetText(tostring(p.defensive.riposteTargetMaxHP or 100)) end
        if frame.subtabFrames[2].riposteCondEB then
            frame.subtabFrames[2].riposteCondEB:SetText(p.defensive.riposteConditions or "")
        end
    end
    
    -- Surprise Attack subtab
    if frame.subtabFrames[3] and p.defensive then
        local check = getglobal("RoRotaSurpriseEnabled")
        if check then check:SetChecked(p.defensive.useSurpriseAttack and 1 or nil) end
        local minHP = getglobal("RoRotaSurpriseMinHP")
        if minHP then minHP:SetText(tostring(p.defensive.surpriseTargetMinHP or 0)) end
        local maxHP = getglobal("RoRotaSurpriseMaxHP")
        if maxHP then maxHP:SetText(tostring(p.defensive.surpriseTargetMaxHP or 100)) end
        if frame.subtabFrames[3].surpriseCondEB then
            frame.subtabFrames[3].surpriseCondEB:SetText(p.defensive.surpriseConditions or "")
        end
    end
    
    -- Mark for Death subtab
    if frame.subtabFrames[4] and p.abilities.MarkForDeath then
        local cfg = p.abilities.MarkForDeath
        local check = getglobal("RoRotaMarkEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        local minHP = getglobal("RoRotaMarkMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaMarkMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        local elite = getglobal("RoRotaMarkElite")
        if elite then elite:SetChecked(cfg.onlyElites and 1 or nil) end
        if frame.subtabFrames[4].markCondEB then
            frame.subtabFrames[4].markCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Hemorrhage subtab
    if frame.subtabFrames[5] and p.abilities.Hemorrhage then
        local cfg = p.abilities.Hemorrhage
        local check = getglobal("RoRotaHemoEnabled")
        if check then check:SetChecked(cfg.enabled and 1 or nil) end
        local missing = getglobal("RoRotaHemoMissing")
        if missing then missing:SetChecked(cfg.onlyWhenMissing and 1 or nil) end
        local minHP = getglobal("RoRotaHemoMinHP")
        if minHP then minHP:SetText(tostring(cfg.targetMinHP or 0)) end
        local maxHP = getglobal("RoRotaHemoMaxHP")
        if maxHP then maxHP:SetText(tostring(cfg.targetMaxHP or 100)) end
        if frame.subtabFrames[5].hemoCondEB then
            frame.subtabFrames[5].hemoCondEB:SetText(cfg.conditions or "")
        end
    end
    
    -- Ghostly Strike subtab
    if frame.subtabFrames[6] and p.defensive then
        local check = getglobal("RoRotaGhostlyEnabled")
        if check then check:SetChecked(p.defensive.useGhostlyStrike and 1 or nil) end
        local targetHP = getglobal("RoRotaGhostlyTargetHP")
        if targetHP then targetHP:SetText(tostring(p.defensive.ghostlyTargetMaxHP or 30)) end
        local minHP = getglobal("RoRotaGhostlyMinHP")
        if minHP then minHP:SetText(tostring(p.defensive.ghostlyPlayerMinHP or 1)) end
        local maxHP = getglobal("RoRotaGhostlyMaxHP")
        if maxHP then maxHP:SetText(tostring(p.defensive.ghostlyPlayerMaxHP or 90)) end
        local targeted = getglobal("RoRotaGhostlyTargeted")
        if targeted then targeted:SetChecked(p.defensive.ghostlyTargetedOnly and 1 or nil) end
        if frame.subtabFrames[6].ghostlyCondEB then
            frame.subtabFrames[6].ghostlyCondEB:SetText(p.defensive.ghostlyConditions or "")
        end
    end
end

-- ============================================================================
-- TAB 5: DEFENSIVE (4 subtabs)
-- ============================================================================

local function CreateInterruptSettingsSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    layout:Row("Use Kick", RoRotaGUI.CreateCheckbox("RoRotaUseKick", parent, 0, 0, "", function()
        RoRota.db.profile.interrupt.useKick = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Use Deadly Throw", RoRotaGUI.CreateCheckbox("RoRotaUseDeadlyThrow", parent, 0, 0, "", function()
        RoRota.db.profile.interrupt.useDeadlyThrow = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Use Gouge", RoRotaGUI.CreateCheckbox("RoRotaUseGouge", parent, 0, 0, "", function()
        RoRota.db.profile.interrupt.useGouge = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Use Kidney Shot", RoRotaGUI.CreateCheckbox("RoRotaUseKidneyInt", parent, 0, 0, "", function()
        RoRota.db.profile.interrupt.useKidneyShot = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Kidney Max CP", RoRotaGUI.CreateDropdown("RoRotaKidneyIntMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.interrupt.kidneyMaxCP = tonumber(v)
    end), 30)
    parent.kidneyIntMaxCPDD = getglobal("RoRotaKidneyIntMaxCPDD")
    
    layout:Row("Filter Mode", RoRotaGUI.CreateDropdown("RoRotaIntFilterModeDD", parent, 0, 0, 200, 
        {"Interrupt All (Ignore List)", "Interrupt None (Priority List)"}, function(v)
        RoRota.db.profile.interrupt.filterMode = v
    end), 30)
    parent.filterModeDD = getglobal("RoRotaIntFilterModeDD")
end

local function CreateInterruptFilterSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Filter List (Target - Spell):")
    layout:Space(25)
    
    parent.filterList = CreateFrame("Frame", nil, parent)
    parent.filterList:SetWidth(350)
    parent.filterList:SetHeight(200)
    parent.filterList:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    parent.filterList:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    parent.filterList:SetBackdropColor(0, 0, 0, 0.5)
    layout:Space(210)
    
    parent.targetNameEB = RoRotaGUI.CreateEditBox("RoRotaNewFilterTargetEB", parent, 20, layout:GetY(), 150, function() end)
    RoRotaGUI.CreateLabel(parent, 180, layout:GetY(), "Target (* = wildcard)")
    layout:Space(30)
    
    parent.spellNameEB = RoRotaGUI.CreateEditBox("RoRotaNewFilterSpellEB", parent, 20, layout:GetY(), 150, function() end)
    RoRotaGUI.CreateLabel(parent, 180, layout:GetY(), "Spell Name")
    layout:Space(30)
    
    local addBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Add")
    addBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    addBtn:SetScript("OnClick", function()
        local targetName = parent.targetNameEB:GetText()
        local spellName = parent.spellNameEB:GetText()
        if targetName and targetName ~= "" and spellName and spellName ~= "" then
            if not RoRota.db.profile.interrupt.filterList then
                RoRota.db.profile.interrupt.filterList = {}
            end
            local key = targetName .. " - " .. spellName
            table.insert(RoRota.db.profile.interrupt.filterList, key)
            parent.targetNameEB:SetText("")
            parent.spellNameEB:SetText("")
            if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[5].content.Load then
                RoRotaMainMenuFrame.tabs[5].content.Load()
            end
        end
    end)
    
    local clearBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Clear All")
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 130, layout:GetY())
    clearBtn:SetScript("OnClick", function()
        RoRota.db.profile.interrupt.filterList = {}
        if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[5].content.Load then
            RoRotaMainMenuFrame.tabs[5].content.Load()
        end
    end)
end

local function CreateInterruptHistorySubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Interrupt History (Target - Spell):")
    layout:Space(25)
    
    parent.historyList = CreateFrame("Frame", nil, parent)
    parent.historyList:SetWidth(350)
    parent.historyList:SetHeight(300)
    parent.historyList:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    parent.historyList:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, insets = {left = 4, right = 4, top = 4, bottom = 4}})
    parent.historyList:SetBackdropColor(0, 0, 0, 0.5)
    layout:Space(310)
    
    local clearBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Clear History")
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    clearBtn:SetScript("OnClick", function()
        RoRota.db.profile.interrupt.history = {}
        if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[5].content.Load then
            RoRotaMainMenuFrame.tabs[5].content.Load()
        end
    end)
end

local function CreateSurvivalSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    layout:Row("Use Vanish", RoRotaGUI.CreateCheckbox("RoRotaUseVanish", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useVanish = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Vanish HP %", RoRotaGUI.CreateEditBox("RoRotaVanishHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.vanishHP = v
    end), 25)
    
    layout:Row("Use Feint", RoRotaGUI.CreateCheckbox("RoRotaUseFeint", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useFeint = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Feint Mode", RoRotaGUI.CreateDropdown("RoRotaFeintModeDD", parent, 0, 0, 100, 
        {"Always", "Targeted", "Never"}, function(v)
        RoRota.db.profile.defensive.feintMode = v
    end), 30)
    parent.feintModeDD = getglobal("RoRotaFeintModeDD")
    
    layout:Row("Use Evasion", RoRotaGUI.CreateCheckbox("RoRotaUseEvasion", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.evasion.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Evasion HP %", RoRotaGUI.CreateEditBox("RoRotaEvasionHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.evasion.hpThreshold = v
    end), 25)
end

function RoRotaMainMenu.CreateDefensiveTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Interrupt\nSettings", "Interrupt\nFilter", "Interrupt\nHistory", "Survival"},
        {CreateInterruptSettingsSubtab, CreateInterruptFilterSubtab, CreateInterruptHistorySubtab, CreateSurvivalSubtab},
        {nil, nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadDefensiveTab(frame)
    if not frame.subtabFrames then return end
    local p = RoRota.db.profile
    if not p then return end
    
    -- Interrupt Settings subtab
    if frame.subtabFrames[1] and p.interrupt then
        local cfg = p.interrupt
        local kickCheck = getglobal("RoRotaUseKick")
        if kickCheck then kickCheck:SetChecked(cfg.useKick and 1 or nil) end
        local deadlyCheck = getglobal("RoRotaUseDeadlyThrow")
        if deadlyCheck then deadlyCheck:SetChecked(cfg.useDeadlyThrow and 1 or nil) end
        local gougeCheck = getglobal("RoRotaUseGouge")
        if gougeCheck then gougeCheck:SetChecked(cfg.useGouge and 1 or nil) end
        local kidneyCheck = getglobal("RoRotaUseKidneyInt")
        if kidneyCheck then kidneyCheck:SetChecked(cfg.useKidneyShot and 1 or nil) end
        
        if frame.subtabFrames[1].kidneyIntMaxCPDD then
            local val = tostring(cfg.kidneyMaxCP or 2)
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].kidneyIntMaxCPDD, val)
            UIDropDownMenu_SetText(val, frame.subtabFrames[1].kidneyIntMaxCPDD)
        end
        
        if frame.subtabFrames[1].filterModeDD then
            local val = cfg.filterMode or "Interrupt All (Ignore List)"
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].filterModeDD, val)
            UIDropDownMenu_SetText(val, frame.subtabFrames[1].filterModeDD)
        end
    end
    
    -- Interrupt Filter subtab
    if frame.subtabFrames[2] and frame.subtabFrames[2].filterList and p.interrupt then
        for _, child in ipairs({frame.subtabFrames[2].filterList:GetChildren()}) do
            child:Hide()
        end
        
        local y = -8
        if p.interrupt.filterList then
            for i, entry in ipairs(p.interrupt.filterList) do
                local text = frame.subtabFrames[2].filterList:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                text:SetPoint("TOPLEFT", frame.subtabFrames[2].filterList, "TOPLEFT", 8, y)
                text:SetText(entry)
                
                local delBtn = CreateFrame("Button", nil, frame.subtabFrames[2].filterList)
                delBtn:SetWidth(40)
                delBtn:SetHeight(15)
                delBtn:SetPoint("TOPLEFT", frame.subtabFrames[2].filterList, "TOPLEFT", 260, y + 2)
                delBtn:SetNormalFontObject("GameFontNormalSmall")
                delBtn:SetText("Delete")
                delBtn:SetScript("OnClick", function()
                    table.remove(p.interrupt.filterList, i)
                    if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[5].content.Load then
                        RoRotaMainMenuFrame.tabs[5].content.Load()
                    end
                end)
                
                y = y - 18
            end
        end
    end
    
    -- Interrupt History subtab
    if frame.subtabFrames[3] and frame.subtabFrames[3].historyList and p.interrupt then
        for _, child in ipairs({frame.subtabFrames[3].historyList:GetChildren()}) do
            child:Hide()
        end
        
        local y = -8
        if p.interrupt.history then
            for i, entry in ipairs(p.interrupt.history) do
                local text = frame.subtabFrames[3].historyList:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                text:SetPoint("TOPLEFT", frame.subtabFrames[3].historyList, "TOPLEFT", 8, y)
                text:SetText(entry)
                
                local ignoreBtn = RoRotaGUI.CreateButton(nil, frame.subtabFrames[3].historyList, 50, 15, "Ignore")
                ignoreBtn:SetPoint("TOPLEFT", 250, y + 2)
                ignoreBtn:SetScript("OnClick", function()
                    if not p.interrupt.filterList then p.interrupt.filterList = {} end
                    table.insert(p.interrupt.filterList, entry)
                    table.remove(p.interrupt.history, i)
                    if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[5].content.Load then
                        RoRotaMainMenuFrame.tabs[5].content.Load()
                    end
                end)
                
                y = y - 18
            end
        end
    end
    
    -- Survival subtab
    if frame.subtabFrames[4] and p.defensive then
        local cfg = p.defensive
        local vanishCheck = getglobal("RoRotaUseVanish")
        if vanishCheck then vanishCheck:SetChecked(cfg.useVanish and 1 or nil) end
        local vanishHP = getglobal("RoRotaVanishHP")
        if vanishHP then vanishHP:SetText(tostring(cfg.vanishHP or 20)) end
        
        local feintCheck = getglobal("RoRotaUseFeint")
        if feintCheck then feintCheck:SetChecked(cfg.useFeint and 1 or nil) end
        
        if frame.subtabFrames[4].feintModeDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[4].feintModeDD, cfg.feintMode or "Always")
            UIDropDownMenu_SetText(cfg.feintMode or "Always", frame.subtabFrames[4].feintModeDD)
        end
        
        local evasionCheck = getglobal("RoRotaUseEvasion")
        if evasionCheck and cfg.evasion then evasionCheck:SetChecked(cfg.evasion.enabled and 1 or nil) end
        local evasionHP = getglobal("RoRotaEvasionHP")
        if evasionHP and cfg.evasion then evasionHP:SetText(tostring(cfg.evasion.hpThreshold or 30)) end
    end
end

-- ============================================================================
-- TAB 6: COOLDOWNS (4 subtabs)
-- ============================================================================

local function CreateColdBloodSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaColdBloodEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.cooldowns.coldBlood.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min CP", RoRotaGUI.CreateDropdown("RoRotaColdBloodMinCPDD", parent, 0, 0, 60, {"3","4","5"}, function(v)
        RoRota.db.profile.cooldowns.coldBlood.minCP = tonumber(v)
    end), 30)
    parent.minCPDD = getglobal("RoRotaColdBloodMinCPDD")
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.condEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaColdBloodCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.cooldowns.coldBlood.conditions = text
    end)
end

local function CreateSprintSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaSprintEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.cooldowns.sprint.enabled = (this:GetChecked() == 1)
    end), 25)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.condEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaSprintCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.cooldowns.sprint.conditions = text
    end)
end

local function CreateAdrenalineRushSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaAdrenalineEnabled", parent, 0, 0, "", function()
        RoRota.db.profile.cooldowns.adrenalineRush.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Min Energy", RoRotaGUI.CreateEditBox("RoRotaAdrenalineMinEnergy", parent, 0, 0, 50, function(v)
        RoRota.db.profile.cooldowns.adrenalineRush.minEnergy = v
    end), 25)
    parent.minEnergyEB = getglobal("RoRotaAdrenalineMinEnergy")
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.condEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaAdrenalineCond", parent, 20, layout:GetY(), 350, 60, function(text)
        RoRota.db.profile.cooldowns.adrenalineRush.conditions = text
    end)
end

local function CreatePreparationSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    layout:Row("Enable", RoRotaGUI.CreateCheckbox("RoRotaPreparationEnabled", parent, 0, 0, "", function()
        if not RoRota.db.profile.cooldowns.preparation then
            RoRota.db.profile.cooldowns.preparation = {}
        end
        RoRota.db.profile.cooldowns.preparation.enabled = (this:GetChecked() == 1)
    end), 25)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Conditions:")
    layout:Space(25)
    parent.condEB = RoRotaGUI.CreateMultiLineEditBox("RoRotaPreparationCond", parent, 20, layout:GetY(), 350, 60, function(text)
        if not RoRota.db.profile.cooldowns.preparation then
            RoRota.db.profile.cooldowns.preparation = {}
        end
        RoRota.db.profile.cooldowns.preparation.conditions = text
    end)
end

function RoRotaMainMenu.CreateCooldownsTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Cold Blood", "Sprint", "Adrenaline\nRush", "Preparation"},
        {CreateColdBloodSubtab, CreateSprintSubtab, CreateAdrenalineRushSubtab, CreatePreparationSubtab},
        {nil, nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadCooldownsTab(frame)
    if not frame.subtabFrames then return end
    local p = RoRota.db.profile
    if not p or not p.cooldowns then return end
    
    -- Cold Blood
    if frame.subtabFrames[1] and p.cooldowns.coldBlood then
        local coldCheck = getglobal("RoRotaColdBloodEnabled")
        if coldCheck then coldCheck:SetChecked(p.cooldowns.coldBlood.enabled and 1 or nil) end
        
        if frame.subtabFrames[1].minCPDD then
            local val = tostring(p.cooldowns.coldBlood.minCP or 5)
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].minCPDD, val)
            UIDropDownMenu_SetText(val, frame.subtabFrames[1].minCPDD)
        end
        
        if frame.subtabFrames[1].condEB then
            frame.subtabFrames[1].condEB:SetText(p.cooldowns.coldBlood.conditions or "")
        end
    end
    
    -- Sprint
    if frame.subtabFrames[2] and p.cooldowns.sprint then
        local sprintCheck = getglobal("RoRotaSprintEnabled")
        if sprintCheck then sprintCheck:SetChecked(p.cooldowns.sprint.enabled and 1 or nil) end
        
        if frame.subtabFrames[2].condEB then
            frame.subtabFrames[2].condEB:SetText(p.cooldowns.sprint.conditions or "")
        end
    end
    
    -- Adrenaline Rush
    if frame.subtabFrames[3] and p.cooldowns.adrenalineRush then
        local adrenalineCheck = getglobal("RoRotaAdrenalineEnabled")
        if adrenalineCheck then adrenalineCheck:SetChecked(p.cooldowns.adrenalineRush.enabled and 1 or nil) end
        
        if frame.subtabFrames[3].minEnergyEB then
            frame.subtabFrames[3].minEnergyEB:SetText(tostring(p.cooldowns.adrenalineRush.minEnergy or 20))
        end
        
        if frame.subtabFrames[3].condEB then
            frame.subtabFrames[3].condEB:SetText(p.cooldowns.adrenalineRush.conditions or "")
        end
    end
    
    -- Preparation
    if frame.subtabFrames[4] and p.cooldowns.preparation then
        local prepCheck = getglobal("RoRotaPreparationEnabled")
        if prepCheck then prepCheck:SetChecked(p.cooldowns.preparation.enabled and 1 or nil) end
        
        if frame.subtabFrames[4].condEB then
            frame.subtabFrames[4].condEB:SetText(p.cooldowns.preparation.conditions or "")
        end
    end
end

-- ============================================================================
-- TAB 7: AOE (no subtabs)
-- ============================================================================

function RoRotaMainMenu.CreateAoETab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    layout:Row("Use Interrupts", RoRotaGUI.CreateCheckbox("RoRotaAoEUseInterrupts", parent, 0, 0, "", function()
        RoRota.db.profile.aoe.useInterrupts = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Use Defensive Skills", RoRotaGUI.CreateCheckbox("RoRotaAoEUseDefensive", parent, 0, 0, "", function()
        RoRota.db.profile.aoe.useDefensive = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Use SnD in AoE", RoRotaGUI.CreateCheckbox("RoRotaAoEUseSnD", parent, 0, 0, "", function()
        RoRota.db.profile.aoe.useSnD = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("SnD Max CP", RoRotaGUI.CreateDropdown("RoRotaAoESndMaxCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.aoe.sndMaxCP = tonumber(v)
    end), 30)
    parent.sndMaxCPDD = getglobal("RoRotaAoESndMaxCPDD")
    
    layout:Row("AoE Builder", RoRotaGUI.CreateDropdown("RoRotaAoEBuilderDD", parent, 0, 0, 150,
        {"Sinister Strike", "Backstab", "Hemorrhage", "Noxious Assault"}, function(v)
        RoRota.db.profile.aoe.builder = v
    end), 30)
    parent.builderDD = getglobal("RoRotaAoEBuilderDD")
    
    layout:Row("Damage Finisher", RoRotaGUI.CreateDropdown("RoRotaAoEFinisherDD", parent, 0, 0, 150,
        {"Eviscerate", "Envenom", "Rupture"}, function(v)
        RoRota.db.profile.aoe.finisher = v
    end), 30)
    parent.finisherDD = getglobal("RoRotaAoEFinisherDD")
    
    layout:Row("Finisher Min CP", RoRotaGUI.CreateDropdown("RoRotaAoEFinisherMinCPDD", parent, 0, 0, 60, {"1","2","3","4","5"}, function(v)
        RoRota.db.profile.aoe.finisherMinCP = tonumber(v)
    end), 30)
    parent.finisherMinCPDD = getglobal("RoRotaAoEFinisherMinCPDD")
end

function RoRotaMainMenu.LoadAoETab(frame)
    local p = RoRota.db.profile
    if not p or not p.aoe then return end
    
    local interruptsCheck = getglobal("RoRotaAoEUseInterrupts")
    if interruptsCheck then interruptsCheck:SetChecked(p.aoe.useInterrupts and 1 or nil) end
    
    local defensiveCheck = getglobal("RoRotaAoEUseDefensive")
    if defensiveCheck then defensiveCheck:SetChecked(p.aoe.useDefensive and 1 or nil) end
    
    local sndCheck = getglobal("RoRotaAoEUseSnD")
    if sndCheck then sndCheck:SetChecked(p.aoe.useSnD and 1 or nil) end
    
    if frame.sndMaxCPDD then
        UIDropDownMenu_SetSelectedValue(frame.sndMaxCPDD, tostring(p.aoe.sndMaxCP or 5))
        UIDropDownMenu_SetText(tostring(p.aoe.sndMaxCP or 5), frame.sndMaxCPDD)
    end
    
    if frame.builderDD then
        UIDropDownMenu_SetSelectedValue(frame.builderDD, p.aoe.builder or "Sinister Strike")
        UIDropDownMenu_SetText(p.aoe.builder or "Sinister Strike", frame.builderDD)
    end
    
    if frame.finisherDD then
        UIDropDownMenu_SetSelectedValue(frame.finisherDD, p.aoe.finisher or "Eviscerate")
        UIDropDownMenu_SetText(p.aoe.finisher or "Eviscerate", frame.finisherDD)
    end
    
    if frame.finisherMinCPDD then
        UIDropDownMenu_SetSelectedValue(frame.finisherMinCPDD, tostring(p.aoe.finisherMinCP or 5))
        UIDropDownMenu_SetText(tostring(p.aoe.finisherMinCP or 5), frame.finisherMinCPDD)
    end
end

-- ============================================================================
-- TAB 8: PROFILES (no subtabs)
-- ============================================================================

function RoRotaMainMenu.CreateProfilesTab(parent, frame)
    parent:Show()
    parent:EnableMouse(false)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
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
    
    frame.profileDD = CreateFrame("Frame", "RoRotaNewProfileDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, frame.profileDD)
    frame.profileDD.dropdownWidth = 150
    layout:Row("Current Profile", frame.profileDD, 30)
    
    local left = getglobal("RoRotaNewProfileDDLeft")
    local middle = getglobal("RoRotaNewProfileDDMiddle")
    local right = getglobal("RoRotaNewProfileDDRight")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(frame.profileDD, function()
        if not RoRotaDB.profiles then RoRotaDB.profiles = {} end
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
                if RoRotaMainMenuFrame then
                    for i = 1, table.getn(RoRotaMainMenuFrame.tabs) do
                        if RoRotaMainMenuFrame.tabs[i].content and RoRotaMainMenuFrame.tabs[i].content.Load then
                            RoRotaMainMenuFrame.tabs[i].content.Load()
                        end
                    end
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UpdateProfileDropdown()
    
    local newBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "New Profile")
    newBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    newBtn:SetScript("OnClick", function()
        StaticPopupDialogs["ROROTA_NEW_PROFILE_NEW"] = {
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
                    RoRotaDB.profiles[name] = RoRota:DeepMerge({}, RoRotaDefaultProfile)
                    if not RoRotaDB.char then RoRotaDB.char = {} end
                    local charKey = UnitName("player").." - "..GetRealmName()
                    RoRotaDB.char[charKey] = name
                    RoRota:SetProfile(name)
                    RoRota:Print("Created new profile: "..name)
                    UpdateProfileDropdown()
                    if RoRotaMainMenuFrame then
                        for i = 1, table.getn(RoRotaMainMenuFrame.tabs) do
                            if RoRotaMainMenuFrame.tabs[i].content and RoRotaMainMenuFrame.tabs[i].content.Load then
                                RoRotaMainMenuFrame.tabs[i].content.Load()
                            end
                        end
                    end
                end
            end,
            OnShow = function()
                getglobal(this:GetName().."EditBox"):SetFocus()
            end,
            EditBoxOnEnterPressed = function()
                local parent = this:GetParent()
                StaticPopupDialogs["ROROTA_NEW_PROFILE_NEW"].OnAccept()
                parent:Hide()
            end,
            EditBoxOnEscapePressed = function()
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show("ROROTA_NEW_PROFILE_NEW")
    end)
    
    local deleteBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Delete Profile")
    deleteBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 150, layout:GetY())
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
        StaticPopupDialogs["ROROTA_DELETE_PROFILE_NEW"] = {
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
                        if RoRotaMainMenuFrame then
                            for i = 1, table.getn(RoRotaMainMenuFrame.tabs) do
                                if RoRotaMainMenuFrame.tabs[i].content and RoRotaMainMenuFrame.tabs[i].content.Load then
                                    RoRotaMainMenuFrame.tabs[i].content.Load()
                                end
                            end
                        end
                    end
                end
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show("ROROTA_DELETE_PROFILE_NEW")
    end)
    
    local exportBtn = RoRotaGUI.CreateButton(nil, parent, 120, 25, "Export/Import")
    exportBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 280, layout:GetY())
    exportBtn:SetScript("OnClick", function()
        if RoRota and RoRota.ShowExportWindow then
            RoRota:ShowExportWindow()
        end
    end)
    layout:Space(30)
    
    layout:Row("Enable Auto-Switching", RoRotaGUI.CreateCheckbox("RoRotaNewAutoSwitchCheck", parent, 0, 0, "", function()
        if not RoRotaDB.autoSwitch then RoRotaDB.autoSwitch = {} end
        RoRotaDB.autoSwitch.enabled = (this:GetChecked() == 1)
    end), 25)
    
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
    
    frame.soloProfileDD = CreateFrame("Frame", "RoRotaNewSoloProfileDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, frame.soloProfileDD)
    frame.soloProfileDD.dropdownWidth = 150
    layout:Row("Solo Profile", frame.soloProfileDD, 30)
    
    local left = getglobal("RoRotaNewSoloProfileDDLeft")
    local middle = getglobal("RoRotaNewSoloProfileDDMiddle")
    local right = getglobal("RoRotaNewSoloProfileDDRight")
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
    
    frame.groupProfileDD = CreateFrame("Frame", "RoRotaNewGroupProfileDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, frame.groupProfileDD)
    frame.groupProfileDD.dropdownWidth = 150
    layout:Row("Group Profile", frame.groupProfileDD, 30)
    
    local left = getglobal("RoRotaNewGroupProfileDDLeft")
    local middle = getglobal("RoRotaNewGroupProfileDDMiddle")
    local right = getglobal("RoRotaNewGroupProfileDDRight")
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
    
    frame.raidProfileDD = CreateFrame("Frame", "RoRotaNewRaidProfileDD", parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(150, frame.raidProfileDD)
    frame.raidProfileDD.dropdownWidth = 150
    layout:Row("Raid Profile", frame.raidProfileDD, 30)
    
    local left = getglobal("RoRotaNewRaidProfileDDLeft")
    local middle = getglobal("RoRotaNewRaidProfileDDMiddle")
    local right = getglobal("RoRotaNewRaidProfileDDRight")
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
end

function RoRotaMainMenu.LoadProfilesTab(frame)
    if not RoRotaDB then return end
    
    local autoCheck = getglobal("RoRotaNewAutoSwitchCheck")
    if autoCheck and RoRotaDB.autoSwitch then
        autoCheck:SetChecked(RoRotaDB.autoSwitch.enabled and 1 or nil)
    end
    
    if frame.soloProfileDD and RoRotaDB.autoSwitch then
        UIDropDownMenu_Initialize(frame.soloProfileDD, frame.soloProfileDD.initialize)
        local val = RoRotaDB.autoSwitch.soloProfile or "Default"
        UIDropDownMenu_SetSelectedValue(frame.soloProfileDD, val)
        UIDropDownMenu_SetText(val, frame.soloProfileDD)
    end
    
    if frame.groupProfileDD and RoRotaDB.autoSwitch then
        UIDropDownMenu_Initialize(frame.groupProfileDD, frame.groupProfileDD.initialize)
        local val = RoRotaDB.autoSwitch.groupProfile or "Default"
        UIDropDownMenu_SetSelectedValue(frame.groupProfileDD, val)
        UIDropDownMenu_SetText(val, frame.groupProfileDD)
    end
    
    if frame.raidProfileDD and RoRotaDB.autoSwitch then
        UIDropDownMenu_Initialize(frame.raidProfileDD, frame.raidProfileDD.initialize)
        local val = RoRotaDB.autoSwitch.raidProfile or "Default"
        UIDropDownMenu_SetSelectedValue(frame.raidProfileDD, val)
        UIDropDownMenu_SetText(val, frame.raidProfileDD)
    end
end

-- ============================================================================
-- TAB 9: SETTINGS (3 subtabs)
-- ============================================================================

local function CreatePoisonsSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    local poisonTypes = {"None", "Agitating Poison", "Corrosive Poison", "Crippling Poison", "Deadly Poison", "Dissolvent Poison", "Instant Poison", "Mind-numbing Poison", "Wound Poison", "Sharpening Stone"}
    
    layout:Row("Auto-Apply Poisons", RoRotaGUI.CreateCheckbox("RoRotaNewAutoApplyCheck", parent, 0, 0, "", function()
        RoRota.db.profile.poisons.autoApply = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Allow in Combat", RoRotaGUI.CreateCheckbox("RoRotaNewApplyInCombatCheck", parent, 0, 0, "", function()
        RoRota.db.profile.poisons.applyInCombat = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Main Hand Poison", RoRotaGUI.CreateDropdown("RoRotaNewMainHandPoisonDD", parent, 0, 0, 180, poisonTypes, function(v)
        RoRota.db.profile.poisons.mainHandPoison = v
    end), 30)
    parent.mainHandPoisonDD = getglobal("RoRotaNewMainHandPoisonDD")
    
    layout:Row("Off Hand Poison", RoRotaGUI.CreateDropdown("RoRotaNewOffHandPoisonDD", parent, 0, 0, 180, poisonTypes, function(v)
        RoRota.db.profile.poisons.offHandPoison = v
    end), 30)
    parent.offHandPoisonDD = getglobal("RoRotaNewOffHandPoisonDD")
    
    layout:Row("Enable Poison Warnings", RoRotaGUI.CreateCheckbox("RoRotaNewPoisonCheck", parent, 0, 0, "", function()
        RoRota.db.profile.poisons.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Time Threshold (minutes)", RoRotaGUI.CreateDropdown("RoRotaNewPoisonTimeDD", parent, 0, 0, 80,
        {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, function(v)
        RoRota.db.profile.poisons.timeThreshold = tonumber(v) * 60
    end), 30)
    parent.poisonTimeDD = getglobal("RoRotaNewPoisonTimeDD")
    
    layout:Row("Charges Threshold", RoRotaGUI.CreateDropdownNumeric("RoRotaNewPoisonChargesDD", parent, 0, 0, 5, 50, 5, function(v)
        RoRota.db.profile.poisons.chargesThreshold = v
    end), 30)
    parent.poisonChargesDD = getglobal("RoRotaNewPoisonChargesDD")
    
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

local function CreatePreviewSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
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
    
    local depthDropdown = RoRotaGUI.CreateDropdown("RoRotaNewPreviewDepthDD", parent, 140, layout:GetY(), 60, {"1", "2", "3"}, function(value)
        RoRota.db.profile.previewDepth = tonumber(value)
    end)
    parent.previewDepthDD = depthDropdown
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

local function CreateConsumablesSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    layout:Row("Use Health Potion", RoRotaGUI.CreateCheckbox("RoRotaNewUseHealthPotion", parent, 0, 0, "", function()
        RoRota.db.profile.defensive.useHealthPotion = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Health Potion HP %", RoRotaGUI.CreateEditBox("RoRotaNewHealthPotionHP", parent, 0, 0, 50, function(v)
        RoRota.db.profile.defensive.healthPotionHP = v
    end), 25)
    
    layout:Row("Use Thistle Tea", RoRotaGUI.CreateCheckbox("RoRotaNewUseThistleTea", parent, 0, 0, "", function()
        if not RoRota.db.profile.consumables.thistleTea then
            RoRota.db.profile.consumables.thistleTea = {}
        end
        RoRota.db.profile.consumables.thistleTea.enabled = (this:GetChecked() == 1)
    end), 25)
    
    layout:Row("Thistle Tea Energy Threshold", RoRotaGUI.CreateEditBox("RoRotaNewThistleTeaEnergy", parent, 0, 0, 50, function(v)
        if not RoRota.db.profile.consumables.thistleTea then
            RoRota.db.profile.consumables.thistleTea = {}
        end
        RoRota.db.profile.consumables.thistleTea.energyThreshold = v
    end), 25)
end

function RoRotaMainMenu.CreateSettingsTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Poisons", "Preview", "Consumables"},
        {CreatePoisonsSubtab, CreatePreviewSubtab, CreateConsumablesSubtab},
        {nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadSettingsTab(frame)
    if not frame.subtabFrames then return end
    local p = RoRota.db.profile
    if not p then return end
    
    -- Poisons subtab
    if frame.subtabFrames[1] and p.poisons then
        local autoCheck = getglobal("RoRotaNewAutoApplyCheck")
        if autoCheck then autoCheck:SetChecked(p.poisons.autoApply and 1 or nil) end
        local combatCheck = getglobal("RoRotaNewApplyInCombatCheck")
        if combatCheck then combatCheck:SetChecked(p.poisons.applyInCombat and 1 or nil) end
        
        if frame.subtabFrames[1].mainHandPoisonDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].mainHandPoisonDD, p.poisons.mainHandPoison or "None")
            UIDropDownMenu_SetText(p.poisons.mainHandPoison or "None", frame.subtabFrames[1].mainHandPoisonDD)
        end
        if frame.subtabFrames[1].offHandPoisonDD then
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].offHandPoisonDD, p.poisons.offHandPoison or "None")
            UIDropDownMenu_SetText(p.poisons.offHandPoison or "None", frame.subtabFrames[1].offHandPoisonDD)
        end
        
        local poisonCheck = getglobal("RoRotaNewPoisonCheck")
        if poisonCheck then poisonCheck:SetChecked(p.poisons.enabled and 1 or nil) end
        
        if frame.subtabFrames[1].poisonTimeDD then
            local val = math.floor((p.poisons.timeThreshold or 180) / 60)
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].poisonTimeDD, tostring(val))
            UIDropDownMenu_SetText(tostring(val), frame.subtabFrames[1].poisonTimeDD)
        end
        if frame.subtabFrames[1].poisonChargesDD then
            local val = p.poisons.chargesThreshold or 10
            UIDropDownMenu_SetSelectedValue(frame.subtabFrames[1].poisonChargesDD, val)
            UIDropDownMenu_SetText(tostring(val), frame.subtabFrames[1].poisonChargesDD)
        end
    end
    
    -- Preview subtab
    if frame.subtabFrames[2] and frame.subtabFrames[2].previewDepthDD then
        local depth = p.previewDepth or 1
        UIDropDownMenu_SetSelectedValue(frame.subtabFrames[2].previewDepthDD, tostring(depth))
        UIDropDownMenu_SetText(tostring(depth), frame.subtabFrames[2].previewDepthDD)
    end
    
    -- Consumables subtab
    if frame.subtabFrames[3] then
        if p.defensive then
            local healthPotCheck = getglobal("RoRotaNewUseHealthPotion")
            if healthPotCheck then healthPotCheck:SetChecked(p.defensive.useHealthPotion and 1 or nil) end
            local healthPotHP = getglobal("RoRotaNewHealthPotionHP")
            if healthPotHP then healthPotHP:SetText(tostring(p.defensive.healthPotionHP or 30)) end
        end
        if p.consumables and p.consumables.thistleTea then
            local thistleCheck = getglobal("RoRotaNewUseThistleTea")
            if thistleCheck then thistleCheck:SetChecked(p.consumables.thistleTea.enabled and 1 or nil) end
            local thistleEnergy = getglobal("RoRotaNewThistleTeaEnergy")
            if thistleEnergy then thistleEnergy:SetText(tostring(p.consumables.thistleTea.energyThreshold or 20)) end
        end
    end
end

-- ============================================================================
-- TAB 10: IMMUNITIES (5 subtabs)
-- ============================================================================

local function CreateImmunityGroupSubtab(parent, groupName)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Immune Targets:")
    layout:Space(25)
    
    parent.immuneList = RoRotaGUI.CreateScrollableList(parent, 20, layout:GetY(), 350, 280)
    parent.immuneList.groupName = groupName
    layout:Space(290)
    
    parent.targetNameEB = RoRotaGUI.CreateTextEditBox("RoRotaNewImmunityTargetEB_"..groupName, parent, 20, layout:GetY(), 200, function() end)
    layout:Space(30)
    
    local addBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Add Target")
    addBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    addBtn:SetScript("OnClick", function()
        local targetName = parent.targetNameEB:GetText()
        if targetName and targetName ~= "" then
            RoRota:AddImmunity(targetName, groupName)
            parent.targetNameEB:SetText("")
            if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
                RoRotaMainMenuFrame.tabs[10].content.Load()
            end
        end
    end)
    
    local clearBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Clear All")
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 130, layout:GetY())
    clearBtn:SetScript("OnClick", function()
        if not RoRotaDB or not RoRotaDB.immunities then return end
        local immunityGroups = {bleed = {"Garrote", "Rupture"}, stun = {"Kidney Shot", "Cheap Shot"}, incapacitate = {"Gouge", "Sap"}}
        local groupAbilities = immunityGroups[groupName]
        if groupAbilities then
            for targetName, abilities in pairs(RoRotaDB.immunities) do
                for _, ability in ipairs(groupAbilities) do
                    abilities[ability] = nil
                end
            end
        end
        if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
            RoRotaMainMenuFrame.tabs[10].content.Load()
        end
    end)
end

local function CreateBleedSubtab(parent)
    CreateImmunityGroupSubtab(parent, "bleed")
end

local function CreateStunSubtab(parent)
    CreateImmunityGroupSubtab(parent, "stun")
end

local function CreateIncapacitateSubtab(parent)
    CreateImmunityGroupSubtab(parent, "incapacitate")
end

local function CreateImmunityBuffsSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Immunity Buff Names:")
    layout:Space(25)
    
    parent.buffList = RoRotaGUI.CreateScrollableList(parent, 20, layout:GetY(), 350, 200)
    layout:Space(210)
    
    parent.buffNameEB = RoRotaGUI.CreateTextEditBox("RoRotaNewImmunityBuffEB", parent, 20, layout:GetY(), 200, function() end)
    layout:Space(30)
    
    local addBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Add Buff")
    addBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    addBtn:SetScript("OnClick", function()
        local buffName = parent.buffNameEB:GetText()
        if buffName and buffName ~= "" then
            if not RoRotaDB.immunityBuffs then RoRotaDB.immunityBuffs = {} end
            table.insert(RoRotaDB.immunityBuffs, buffName)
            parent.buffNameEB:SetText("")
            if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
                RoRotaMainMenuFrame.tabs[10].content.Load()
            end
        end
    end)
    
    local clearBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Clear All")
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 130, layout:GetY())
    clearBtn:SetScript("OnClick", function()
        RoRotaDB.immunityBuffs = {}
        if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
            RoRotaMainMenuFrame.tabs[10].content.Load()
        end
    end)
end

local function CreateSilenceSubtab(parent)
    local layout = RoRotaGUI.CreateLayout(parent, 20, -20)
    
    RoRotaGUI.CreateLabel(parent, 20, layout:GetY(), "Uninterruptible Spells:")
    layout:Space(25)
    
    parent.spellList = RoRotaGUI.CreateScrollableList(parent, 20, layout:GetY(), 350, 200)
    layout:Space(210)
    
    local clearBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Clear All")
    clearBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, layout:GetY())
    clearBtn:SetScript("OnClick", function()
        RoRotaDB.uninterruptible = {}
        if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
            RoRotaMainMenuFrame.tabs[10].content.Load()
        end
    end)
end

function RoRotaMainMenu.CreateImmunitiesTab(parent, frame)
    RoRotaGUI.CreateSubtabStructure(
        parent,
        {"Bleed", "Stun", "Incapacitate", "Immunity\nBuffs", "Silence"},
        {CreateBleedSubtab, CreateStunSubtab, CreateIncapacitateSubtab, CreateImmunityBuffsSubtab, CreateSilenceSubtab},
        {nil, nil, nil, nil, nil}
    )
end

function RoRotaMainMenu.LoadImmunitiesTab(frame)
    if not frame.subtabFrames then return end
    if not RoRotaDB then return end
    
    -- Load Bleed/Stun/Incapacitate subtabs (1-3)
    for i = 1, 3 do
        if frame.subtabFrames[i] and frame.subtabFrames[i].immuneList then
            local groupName = frame.subtabFrames[i].immuneList.groupName
            local immuneTargets = RoRota:GetImmuneTargets(groupName)
            
            -- Clear existing
            for _, child in ipairs({frame.subtabFrames[i].immuneList.content:GetChildren()}) do
                child:Hide()
            end
            
            -- Display immune targets with delete buttons
            local y = -8
            for idx, targetName in ipairs(immuneTargets) do
                local text = frame.subtabFrames[i].immuneList.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                text:SetPoint("TOPLEFT", frame.subtabFrames[i].immuneList.content, "TOPLEFT", 8, y)
                text:SetText(targetName)
                
                local delBtn = RoRotaGUI.CreateButton(nil, frame.subtabFrames[i].immuneList.content, 50, 18, "Delete")
                delBtn:SetPoint("TOPLEFT", frame.subtabFrames[i].immuneList.content, "TOPLEFT", 260, y + 2)
                delBtn:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 10)
                local localTarget = targetName
                local localGroup = groupName
                delBtn:SetScript("OnClick", function()
                    RoRota:RemoveImmunity(localTarget, localGroup)
                    this:GetParent():GetParent():GetParent():Hide()
                    if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
                        RoRotaMainMenuFrame.tabs[10].content.Load()
                    end
                    this:GetParent():GetParent():GetParent():Show()
                end)
                
                y = y - 20
            end
            frame.subtabFrames[i].immuneList.content:SetHeight(math.max(1, math.abs(y) + 8))
            frame.subtabFrames[i].immuneList:UpdateScrollRange()
        end
    end
    
    -- Load Immunity Buffs subtab (4)
    if frame.subtabFrames[4] and frame.subtabFrames[4].buffList and frame.subtabFrames[4].buffList.content then
        for _, child in ipairs({frame.subtabFrames[4].buffList.content:GetChildren()}) do
            child:Hide()
        end
        
        local y = -8
        if RoRotaDB.immunityBuffs then
            for idx, buffName in ipairs(RoRotaDB.immunityBuffs) do
                local text = frame.subtabFrames[4].buffList.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                text:SetPoint("TOPLEFT", frame.subtabFrames[4].buffList.content, "TOPLEFT", 8, y)
                text:SetText(buffName)
                
                local delBtn = RoRotaGUI.CreateButton(nil, frame.subtabFrames[4].buffList.content, 50, 18, "Delete")
                delBtn:SetPoint("TOPLEFT", frame.subtabFrames[4].buffList.content, "TOPLEFT", 260, y + 2)
                delBtn:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 10)
                local localIdx = idx
                delBtn:SetScript("OnClick", function()
                    table.remove(RoRotaDB.immunityBuffs, localIdx)
                    this:GetParent():GetParent():GetParent():Hide()
                    if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
                        RoRotaMainMenuFrame.tabs[10].content.Load()
                    end
                    this:GetParent():GetParent():GetParent():Show()
                end)
                
                y = y - 20
            end
        end
        frame.subtabFrames[4].buffList.content:SetHeight(math.max(1, math.abs(y) + 8))
        frame.subtabFrames[4].buffList:UpdateScrollRange()
    end
    
    -- Load Silence subtab (5)
    if frame.subtabFrames[5] and frame.subtabFrames[5].spellList then
        for _, child in ipairs({frame.subtabFrames[5].spellList.content:GetChildren()}) do
            child:Hide()
        end
        
        local y = -8
        if RoRotaDB.uninterruptible then
            for targetName, spells in pairs(RoRotaDB.uninterruptible) do
                if type(spells) == "table" then
                    for spellName in pairs(spells) do
                        local text = frame.subtabFrames[5].spellList.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        text:SetPoint("TOPLEFT", frame.subtabFrames[5].spellList.content, "TOPLEFT", 8, y)
                        text:SetText(targetName .. " - " .. spellName)
                        
                        local delBtn = RoRotaGUI.CreateButton(nil, frame.subtabFrames[5].spellList.content, 50, 18, "Delete")
                        delBtn:SetPoint("TOPLEFT", frame.subtabFrames[5].spellList.content, "TOPLEFT", 260, y + 2)
                        delBtn:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 10)
                        local localTarget = targetName
                        local localSpell = spellName
                        delBtn:SetScript("OnClick", function()
                            if RoRotaDB.uninterruptible[localTarget] then
                                RoRotaDB.uninterruptible[localTarget][localSpell] = nil
                            end
                            this:GetParent():GetParent():GetParent():Hide()
                            if RoRotaMainMenuFrame and RoRotaMainMenuFrame.tabs[10].content.Load then
                                RoRotaMainMenuFrame.tabs[10].content.Load()
                            end
                            this:GetParent():GetParent():GetParent():Show()
                        end)
                        
                        y = y - 20
                    end
                end
            end
        end
        frame.subtabFrames[5].spellList.content:SetHeight(math.max(1, math.abs(y) + 8))
        frame.subtabFrames[5].spellList:UpdateScrollRange()
    end
end

-- ============================================================================
-- MAIN MENU CREATION
-- ============================================================================

function RoRotaMainMenu:Create()
    if RoRotaMainMenuFrame then return end
    
    local f = CreateFrame("Frame", "RoRotaMainMenuFrame", UIParent)
    f:SetWidth(600)
    f:SetHeight(500)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    f:SetScript("OnShow", function()
        for i = 1, table.getn(this.tabs) do
            if this.tabs[i].content and this.tabs[i].content.Load then
                this.tabs[i].content.Load()
            end
        end
    end)
    table.insert(UISpecialFrames, "RoRotaMainMenuFrame")
    f:Hide()
    
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("RoRota v" .. (RoRota.version or "Unknown"))
    
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    
    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetWidth(100)
    sidebar:SetHeight(500)
    sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    sidebar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    sidebar:SetBackdropColor(0, 0, 0, 0.5)
    
    local content = CreateFrame("Frame", nil, f)
    content:SetWidth(480)
    content:SetHeight(460)
    content:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -30)
    
    f.tabs = {}
    local tabNames = {"About", "Openers", "Finishers", "Builders", "Defensive", "Cooldowns", "AoE", "Profiles", "Settings", "Immunities"}
    
    for i = 1, 10 do
        local idx = i
        local btn = RoRotaGUI.CreateSidebarButton(sidebar, -40 - (i-1)*32, tabNames[i], function()
            ShowTab(f, idx)
        end)
        f.tabs[i] = {button = btn}
    end
    
    -- Create tab content frames
    for i = 1, 10 do
        local t = CreateFrame("Frame", nil, content)
        t:SetWidth(480)
        t:SetHeight(460)
        t:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        if i > 1 then t:Hide() end
        f.tabs[i].content = t
    end
    
    -- Initialize all tabs
    local tabFunctions = {
        RoRotaMainMenu.CreateAboutTab,
        RoRotaMainMenu.CreateOpenersTab,
        RoRotaMainMenu.CreateFinishersTab,
        RoRotaMainMenu.CreateBuildersTab,
        RoRotaMainMenu.CreateDefensiveTab,
        RoRotaMainMenu.CreateCooldownsTab,
        RoRotaMainMenu.CreateAoETab,
        RoRotaMainMenu.CreateProfilesTab,
        RoRotaMainMenu.CreateSettingsTab,
        RoRotaMainMenu.CreateImmunitiesTab
    }
    
    for i = 1, 10 do
        if tabFunctions[i] then
            tabFunctions[i](f.tabs[i].content, f.tabs[i])
            local contentFrame = f.tabs[i].content
            local tabIndex = i
            contentFrame.Load = function()
                local loadFunc = RoRotaMainMenu["Load" .. ({"About", "Openers", "Finishers", "Builders", "Defensive", "Cooldowns", "AoE", "Profiles", "Settings", "Immunities"})[tabIndex] .. "Tab"]
                if loadFunc then loadFunc(contentFrame) end
            end
        end
    end
    
    ShowTab(f, 1)
end

function RoRotaMainMenu:Show()
    if not RoRotaMainMenuFrame then
        self:Create()
    end
    if RoRotaMainMenuFrame then
        for i = 1, table.getn(RoRotaMainMenuFrame.tabs) do
            if RoRotaMainMenuFrame.tabs[i].content and RoRotaMainMenuFrame.tabs[i].content.Load then
                RoRotaMainMenuFrame.tabs[i].content.Load()
            end
        end
        RoRotaMainMenuFrame:Show()
    end
end

function RoRotaMainMenu:Hide()
    if RoRotaMainMenuFrame then
        RoRotaMainMenuFrame:Hide()
    end
end
