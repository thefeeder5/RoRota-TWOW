--[[ gui_tab_builders ]]--
-- Builder settings tab with standardized layout.

function RoRotaGUI.CreateBuildersTab(parent, frame)
    local builders = {"Sinister Strike", "Backstab", "Noxious Assault"}
    local failsafeOptions = {"Disabled", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Main Builder")
    frame.mainBuilderDD = RoRotaGUI.CreateDropdown("RoRotaMainBuilderDD", parent, 350, y, 150, builders, function(value)
        RoRota.db.profile.mainBuilder = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Secondary Builder")
    frame.secondaryBuilderDD = RoRotaGUI.CreateDropdown("RoRotaSecondaryBuilderDD", parent, 350, y, 150, builders, function(value)
        RoRota.db.profile.secondaryBuilder = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Failsafe Attempts")
    frame.builderFailDD = RoRotaGUI.CreateDropdown("RoRotaBuilderFailDD", parent, 350, y, 100, failsafeOptions, function(value)
        RoRota.db.profile.builderFailsafe = value == "Disabled" and -1 or tonumber(value)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Riposte")
    frame.riposteCheck = RoRotaGUI.CreateCheckbox("RoRotaRiposteCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useRiposte = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Surprise Attack")
    frame.surpriseCheck = RoRotaGUI.CreateCheckbox("RoRotaSurpriseCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useSurpriseAttack = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Hemorrhage")
    frame.hemorrhageCheck = RoRotaGUI.CreateCheckbox("RoRotaHemorrhageCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Hemorrhage then RoRota.db.profile.abilities.Hemorrhage = {} end
        RoRota.db.profile.abilities.Hemorrhage.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Ghostly Strike")
    frame.gsCheck = RoRotaGUI.CreateCheckbox("RoRotaGSCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useGhostlyStrike = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Ghostly Strike Target Max HP")
    frame.gsTargetEB = RoRotaGUI.CreateEditBox("RoRotaGSTargetEB", parent, 350, y, 50, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyTargetMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Ghostly Strike Player Min HP")
    frame.gsPlayerMinEB = RoRotaGUI.CreateEditBox("RoRotaGSPlayerMinEB", parent, 350, y, 50, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyPlayerMinHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Ghostly Strike Player Max HP")
    frame.gsPlayerMaxEB = RoRotaGUI.CreateEditBox("RoRotaGSPlayerMaxEB", parent, 350, y, 50, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.ghostlyPlayerMaxHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Smart Combo Builders")
    frame.smartBuildersCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartBuildersCheck", parent, 350, y, "", function()
        RoRota.db.profile.smartBuilders = (this:GetChecked() == 1)
    end)
end

function RoRotaGUI.LoadBuildersTab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
    if frame.mainBuilderDD and p.mainBuilder then
        UIDropDownMenu_SetSelectedValue(frame.mainBuilderDD, p.mainBuilder)
        UIDropDownMenu_SetText(p.mainBuilder, frame.mainBuilderDD)
    end
    if frame.builderFailDD then
        local val = p.builderFailsafe or -1
        local text = val == -1 and "Disabled" or tostring(val)
        UIDropDownMenu_SetSelectedValue(frame.builderFailDD, text)
        UIDropDownMenu_SetText(text, frame.builderFailDD)
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
    if frame.gsTargetEB and p.defensive then
        frame.gsTargetEB:SetText(tostring(p.defensive.ghostlyTargetMaxHP or 30))
    end
    if frame.gsPlayerMinEB and p.defensive then
        frame.gsPlayerMinEB:SetText(tostring(p.defensive.ghostlyPlayerMinHP or 1))
    end
    if frame.gsPlayerMaxEB and p.defensive then
        frame.gsPlayerMaxEB:SetText(tostring(p.defensive.ghostlyPlayerMaxHP or 90))
    end
    if frame.smartBuildersCheck then
        frame.smartBuildersCheck:SetChecked(p.smartBuilders and 1 or nil)
    end
end

RoRotaGUIBuildersLoaded = true
