--[[ gui_tab_about ]]--
-- About tab with addon information.

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
    version:SetText("Version 0.7.1")
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
    -- Nothing to load
end

RoRotaGUIAboutLoaded = true
