--[[ gui ]]--
-- Main GUI module with vertical sidebar navigation.

RoRotaGUI = RoRotaGUI or {}

local function ShowTab(frame, index)
    for i = 1, table.getn(frame.tabs) do
        if frame.tabs[i].content then
            if i == index then
                frame.tabs[i].content:Show()
                RoRotaGUI.SetSidebarButtonActive(frame.tabs[i].button, true)
                if i == 3 and frame.tabs[3].content.UpdatePriorityList then
                    frame.tabs[3].content.UpdatePriorityList()
                end
            else
                frame.tabs[i].content:Hide()
                RoRotaGUI.SetSidebarButtonActive(frame.tabs[i].button, false)
            end
        end
    end
end

function RoRotaGUI.LoadAllTabs(frame)
    if not frame or not RoRota.db or not RoRota.db.profile then return end
    
    if RoRotaGUI.LoadAboutTab then RoRotaGUI.LoadAboutTab(frame) end
    if RoRotaGUI.LoadOpenersTab then RoRotaGUI.LoadOpenersTab(frame) end
    if RoRotaGUI.LoadBuildersTab and frame.tabs[3] and frame.tabs[3].content then RoRotaGUI.LoadBuildersTab(frame.tabs[3].content) end
    if RoRotaGUI.LoadFinishersTab and frame.tabs[4] and frame.tabs[4].content then RoRotaGUI.LoadFinishersTab(frame.tabs[4].content) end
    if RoRotaGUI.LoadDefensiveTab and frame.tabs[5] and frame.tabs[5].content then RoRotaGUI.LoadDefensiveTab(frame.tabs[5].content) end
    if RoRotaGUI.LoadAoETab and frame.tabs[6] and frame.tabs[6].content then RoRotaGUI.LoadAoETab(frame.tabs[6].content) end
    if RoRotaGUI.LoadPoisonsTab and frame.tabs[7] and frame.tabs[7].content then RoRotaGUI.LoadPoisonsTab(frame.tabs[7].content) end
    if RoRotaGUI.LoadProfilesTab and frame.tabs[8] and frame.tabs[8].content then RoRotaGUI.LoadProfilesTab(frame.tabs[8].content) end
    if RoRotaGUI.LoadImmunitiesTab and frame.tabs[9] and frame.tabs[9].content then RoRotaGUI.LoadImmunitiesTab(frame.tabs[9].content) end
    if RoRotaGUI.LoadPreviewTab and frame.tabs[10] and frame.tabs[10].content then RoRotaGUI.LoadPreviewTab(frame.tabs[10].content) end
end

function RoRota:CreateGUI()
    if RoRotaGUIFrame then return end
    
    local f = CreateFrame("Frame", "RoRotaGUIFrame", UIParent)
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
    f:SetScript("OnShow", function() RoRotaGUI.LoadAllTabs(this) end)
    table.insert(UISpecialFrames, "RoRotaGUIFrame")
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
    local tabNames = {"About", "Openers", "Builders", "Finishers", "Defensive", "AoE", "Poisons", "Profiles", "Immunities", "Preview"}
    
    for i = 1, 10 do
        local idx = i
        local btn = RoRotaGUI.CreateSidebarButton(sidebar, -40 - (i-1)*32, tabNames[i], function()
            ShowTab(f, idx)
        end)
        f.tabs[i] = {button = btn}
    end
    
    local t1 = CreateFrame("Frame", nil, content)
    t1:SetWidth(480)
    t1:SetHeight(460)
    t1:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    f.tabs[1].content = t1
    if RoRotaGUI.CreateAboutTab then RoRotaGUI.CreateAboutTab(t1, f) end
    
    local t2 = CreateFrame("Frame", nil, content)
    t2:SetWidth(480)
    t2:SetHeight(460)
    t2:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t2:Hide()
    f.tabs[2].content = t2
    if RoRotaGUI.CreateOpenersTab then RoRotaGUI.CreateOpenersTab(t2, f) end
    
    local t3 = CreateFrame("Frame", nil, content)
    t3:SetWidth(480)
    t3:SetHeight(460)
    t3:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t3:Hide()
    f.tabs[3].content = t3
    if RoRotaGUI.CreateBuildersTab then RoRotaGUI.CreateBuildersTab(t3, t3) end
    
    local t4 = CreateFrame("Frame", nil, content)
    t4:SetWidth(480)
    t4:SetHeight(460)
    t4:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t4:Hide()
    f.tabs[4].content = t4
    if RoRotaGUI.CreateFinishersTab then RoRotaGUI.CreateFinishersTab(t4, t4) end
    
    local t5 = CreateFrame("Frame", nil, content)
    t5:SetWidth(480)
    t5:SetHeight(460)
    t5:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t5:Hide()
    f.tabs[5].content = t5
    if RoRotaGUI.CreateDefensiveTab then RoRotaGUI.CreateDefensiveTab(t5, t5) end
    
    local t6 = CreateFrame("Frame", nil, content)
    t6:SetWidth(480)
    t6:SetHeight(460)
    t6:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t6:Hide()
    f.tabs[6].content = t6
    if RoRotaGUI.CreateAoETab then RoRotaGUI.CreateAoETab(t6, t6) end
    
    local t7 = CreateFrame("Frame", nil, content)
    t7:SetWidth(480)
    t7:SetHeight(460)
    t7:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t7:Hide()
    f.tabs[7].content = t7
    if RoRotaGUI.CreatePoisonsTab then RoRotaGUI.CreatePoisonsTab(t7, t7) end
    
    local t8 = CreateFrame("Frame", nil, content)
    t8:SetWidth(480)
    t8:SetHeight(460)
    t8:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t8:Hide()
    f.tabs[8].content = t8
    if RoRotaGUI.CreateProfilesTab then RoRotaGUI.CreateProfilesTab(t8, t8) end
    
    local t9 = CreateFrame("Frame", nil, content)
    t9:SetWidth(480)
    t9:SetHeight(460)
    t9:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t9:Hide()
    f.tabs[9].content = t9
    if RoRotaGUI.CreateImmunitiesTab then RoRotaGUI.CreateImmunitiesTab(t9, t9) end
    
    local t10 = CreateFrame("Frame", nil, content)
    t10:SetWidth(480)
    t10:SetHeight(460)
    t10:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t10:Hide()
    f.tabs[10].content = t10
    if RoRotaGUI.CreatePreviewTab then RoRotaGUI.CreatePreviewTab(t10, f) end
    
    ShowTab(f, 1)
end
