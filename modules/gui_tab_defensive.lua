--[[ gui_tab_defensive ]]--
-- Defensive and interrupt settings tab with standardized layout.

function RoRotaGUI.CreateDefensiveTab(parent, frame)
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Kick")
    frame.kickCheck = RoRotaGUI.CreateCheckbox("RoRotaKickCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useKick = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Gouge")
    frame.gougeCheck = RoRotaGUI.CreateCheckbox("RoRotaGougeCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useGouge = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Kidney Shot")
    frame.ksCheck = RoRotaGUI.CreateCheckbox("RoRotaKSCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.useKidneyShot = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Kidney Shot Max CP")
    frame.ksMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaKSMaxDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.interrupt then RoRota.db.profile.interrupt = {} end
        RoRota.db.profile.interrupt.kidneyMaxCP = value
    end)
    y = y - 40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Vanish")
    frame.vanishCheck = RoRotaGUI.CreateCheckbox("RoRotaVanishCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useVanish = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Vanish HP Threshold")
    frame.vanishEB = RoRotaGUI.CreateEditBox("RoRotaVanishEB", parent, 350, y, 50, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.vanishHP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Use Feint")
    frame.feintCheck = RoRotaGUI.CreateCheckbox("RoRotaFeintCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.useFeint = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Feint Mode")
    local feintModes = {"Always", "WhenTargeted", "HighThreat"}
    frame.feintModeDD = RoRotaGUI.CreateDropdown("RoRotaFeintModeDD", parent, 350, y, 150, feintModes, function(value)
        if not RoRota.db.profile.defensive then RoRota.db.profile.defensive = {} end
        RoRota.db.profile.defensive.feintMode = value
    end)
end

function RoRotaGUI.LoadDefensiveTab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
    if frame.kickCheck and p.interrupt then
        frame.kickCheck:SetChecked(p.interrupt.useKick and 1 or nil)
    end
    if frame.gougeCheck and p.interrupt then
        frame.gougeCheck:SetChecked(p.interrupt.useGouge and 1 or nil)
    end
    if frame.ksCheck and p.interrupt then
        frame.ksCheck:SetChecked(p.interrupt.useKidneyShot and 1 or nil)
    end
    if frame.ksMaxDD and p.interrupt then
        local val = p.interrupt.kidneyMaxCP or 2
        UIDropDownMenu_SetSelectedValue(frame.ksMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.ksMaxDD)
    end
    if frame.vanishCheck and p.defensive then
        frame.vanishCheck:SetChecked(p.defensive.useVanish and 1 or nil)
    end
    if frame.vanishEB and p.defensive then
        frame.vanishEB:SetText(tostring(p.defensive.vanishHP or 20))
    end
    if frame.feintCheck and p.defensive then
        frame.feintCheck:SetChecked(p.defensive.useFeint and 1 or nil)
    end
    if frame.feintModeDD and p.defensive and p.defensive.feintMode then
        UIDropDownMenu_SetSelectedValue(frame.feintModeDD, p.defensive.feintMode)
        UIDropDownMenu_SetText(p.defensive.feintMode, frame.feintModeDD)
    end
end

RoRotaGUIDefensiveLoaded = true
