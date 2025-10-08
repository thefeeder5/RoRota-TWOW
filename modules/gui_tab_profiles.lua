--[[ gui_tab_profiles ]]--
-- Profile management tab with standardized layout.

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

RoRotaGUIProfilesLoaded = true
