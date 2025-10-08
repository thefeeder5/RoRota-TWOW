--[[ gui_tab_openers ]]--
-- Opener settings tab with standardized layout.

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
    if frame.sapFailDD and p.opener and p.opener.sapFailAction then
        UIDropDownMenu_SetSelectedValue(frame.sapFailDD, p.opener.sapFailAction)
        UIDropDownMenu_SetText(p.opener.sapFailAction, frame.sapFailDD)
    end
end

RoRotaGUIOpenersLoaded = true
