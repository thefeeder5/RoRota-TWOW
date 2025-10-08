--[[ gui_tab_poisons ]]--
-- Poison settings tab with standardized layout.

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
