--[[ gui_tab_finishers ]]--
-- Finisher settings tab with expanded standardized layout.

function RoRotaGUI.CreateFinishersTab(parent, frame)
    local y = -40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Slice and Dice Enable")
    frame.sndCheck = RoRotaGUI.CreateCheckbox("RoRotaSndCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Slice and Dice Min CP")
    frame.sndMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaSndMinDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.minCP = value
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Slice and Dice Max CP")
    frame.sndMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaSndMaxDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.SliceAndDice then RoRota.db.profile.abilities.SliceAndDice = {} end
        RoRota.db.profile.abilities.SliceAndDice.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Envenom Enable")
    frame.envCheck = RoRotaGUI.CreateCheckbox("RoRotaEnvCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Envenom Min CP")
    frame.envMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMinDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.minCP = value
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Envenom Max CP")
    frame.envMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnvMaxDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Envenom then RoRota.db.profile.abilities.Envenom = {} end
        RoRota.db.profile.abilities.Envenom.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Rupture Enable")
    frame.ruptCheck = RoRotaGUI.CreateCheckbox("RoRotaRuptCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Rupture Min CP")
    frame.ruptMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMinDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.minCP = value
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Rupture Max CP")
    frame.ruptMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaRuptMaxDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.Rupture then RoRota.db.profile.abilities.Rupture = {} end
        RoRota.db.profile.abilities.Rupture.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Expose Armor Enable")
    frame.exposeCheck = RoRotaGUI.CreateCheckbox("RoRotaExposeCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.enabled = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Expose Armor Min CP")
    frame.exposeMinDD = RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMinDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.minCP = value
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Expose Armor Max CP")
    frame.exposeMaxDD = RoRotaGUI.CreateDropdownNumeric("RoRotaExposeMaxDD", parent, 350, y, 1, 5, 1, function(value)
        if not RoRota.db.profile.abilities then RoRota.db.profile.abilities = {} end
        if not RoRota.db.profile.abilities.ExposeArmor then RoRota.db.profile.abilities.ExposeArmor = {} end
        RoRota.db.profile.abilities.ExposeArmor.maxCP = value
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Smart Eviscerate")
    frame.smartEvisCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartEvisCheck", parent, 350, y, "", function()
        RoRota.db.profile.smartEviscerate = (this:GetChecked() == 1)
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Smart Rupture")
    frame.smartRuptCheck = RoRotaGUI.CreateCheckbox("RoRotaSmartRuptCheck", parent, 350, y, "", function()
        RoRota.db.profile.smartRupture = (this:GetChecked() == 1)
    end)
    y = y - 30
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Energy Pooling Enable")
    frame.energyPoolCheck = RoRotaGUI.CreateCheckbox("RoRotaEnergyPoolCheck", parent, 350, y, "", function()
        if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
        RoRota.db.profile.energyPooling.enabled = (this:GetChecked() == 1)
    end)
    y = y - 25
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Energy Pooling Threshold")
    frame.energyPoolDD = RoRotaGUI.CreateDropdownNumeric("RoRotaEnergyPoolDD", parent, 350, y, 0, 30, 5, function(value)
        if not RoRota.db.profile.energyPooling then RoRota.db.profile.energyPooling = {} end
        RoRota.db.profile.energyPooling.threshold = value
    end)
    y = y - 40
    
    RoRotaGUI.CreateLabel(parent, 20, y, "Finisher Priority (Eviscerate always last)")
    y = y - 25
    
    local finishers = {"Slice and Dice", "Envenom", "Rupture", "Expose Armor"}
    frame.priorityButtons = {}
    for i, name in ipairs(finishers) do
        local btn = RoRotaGUI.CreateButton(nil, parent, 150, 25, name)
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, y)
        btn.index = i
        btn.finisher = name
        frame.priorityButtons[i] = btn
        
        local upBtn = RoRotaGUI.CreateButton(nil, parent, 30, 25, "↑")
        upBtn:SetPoint("LEFT", btn, "RIGHT", 5, 0)
        upBtn:SetScript("OnClick", function()
            if btn.index > 1 then
                local temp = finishers[btn.index]
                finishers[btn.index] = finishers[btn.index - 1]
                finishers[btn.index - 1] = temp
                if not RoRota.db.profile.finisherPriority then RoRota.db.profile.finisherPriority = {} end
                RoRota.db.profile.finisherPriority = finishers
                if frame.UpdatePriorityList then frame.UpdatePriorityList() end
            end
        end)
        
        local downBtn = RoRotaGUI.CreateButton(nil, parent, 30, 25, "↓")
        downBtn:SetPoint("LEFT", upBtn, "RIGHT", 5, 0)
        downBtn:SetScript("OnClick", function()
            if btn.index < table.getn(finishers) then
                local temp = finishers[btn.index]
                finishers[btn.index] = finishers[btn.index + 1]
                finishers[btn.index + 1] = temp
                if not RoRota.db.profile.finisherPriority then RoRota.db.profile.finisherPriority = {} end
                RoRota.db.profile.finisherPriority = finishers
                if frame.UpdatePriorityList then frame.UpdatePriorityList() end
            end
        end)
        
        y = y - 30
    end
    
    frame.UpdatePriorityList = function()
        local priority = RoRota.db.profile.finisherPriority or finishers
        for i, btn in ipairs(frame.priorityButtons) do
            btn:SetText(priority[i] or "")
            btn.finisher = priority[i]
            btn.index = i
        end
    end
end

function RoRotaGUI.LoadFinishersTab(frame)
    local p = RoRota.db.profile
    if not p then return end
    
    if frame.sndCheck and p.abilities and p.abilities.SliceAndDice then
        frame.sndCheck:SetChecked(p.abilities.SliceAndDice.enabled and 1 or nil)
    end
    if frame.sndMinDD and p.abilities and p.abilities.SliceAndDice then
        local val = p.abilities.SliceAndDice.minCP or 1
        UIDropDownMenu_SetSelectedValue(frame.sndMinDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.sndMinDD)
    end
    if frame.sndMaxDD and p.abilities and p.abilities.SliceAndDice then
        local val = p.abilities.SliceAndDice.maxCP or 2
        UIDropDownMenu_SetSelectedValue(frame.sndMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.sndMaxDD)
    end
    if frame.envCheck and p.abilities and p.abilities.Envenom then
        frame.envCheck:SetChecked(p.abilities.Envenom.enabled and 1 or nil)
    end
    if frame.envMinDD and p.abilities and p.abilities.Envenom then
        local val = p.abilities.Envenom.minCP or 1
        UIDropDownMenu_SetSelectedValue(frame.envMinDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.envMinDD)
    end
    if frame.envMaxDD and p.abilities and p.abilities.Envenom then
        local val = p.abilities.Envenom.maxCP or 2
        UIDropDownMenu_SetSelectedValue(frame.envMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.envMaxDD)
    end
    if frame.ruptCheck and p.abilities and p.abilities.Rupture then
        frame.ruptCheck:SetChecked(p.abilities.Rupture.enabled and 1 or nil)
    end
    if frame.ruptMinDD and p.abilities and p.abilities.Rupture then
        local val = p.abilities.Rupture.minCP or 1
        UIDropDownMenu_SetSelectedValue(frame.ruptMinDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.ruptMinDD)
    end
    if frame.ruptMaxDD and p.abilities and p.abilities.Rupture then
        local val = p.abilities.Rupture.maxCP or 5
        UIDropDownMenu_SetSelectedValue(frame.ruptMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.ruptMaxDD)
    end
    if frame.exposeCheck and p.abilities and p.abilities.ExposeArmor then
        frame.exposeCheck:SetChecked(p.abilities.ExposeArmor.enabled and 1 or nil)
    end
    if frame.exposeMinDD and p.abilities and p.abilities.ExposeArmor then
        local val = p.abilities.ExposeArmor.minCP or 5
        UIDropDownMenu_SetSelectedValue(frame.exposeMinDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.exposeMinDD)
    end
    if frame.exposeMaxDD and p.abilities and p.abilities.ExposeArmor then
        local val = p.abilities.ExposeArmor.maxCP or 5
        UIDropDownMenu_SetSelectedValue(frame.exposeMaxDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.exposeMaxDD)
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
    if frame.energyPoolDD and p.energyPooling then
        local val = p.energyPooling.threshold or 10
        UIDropDownMenu_SetSelectedValue(frame.energyPoolDD, val)
        UIDropDownMenu_SetText(tostring(val), frame.energyPoolDD)
    end
end

RoRotaGUIFinishersLoaded = true
