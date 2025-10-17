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
    if RoRotaGUI.LoadPoisonsTab then RoRotaGUI.LoadPoisonsTab(frame) end
    if RoRotaGUI.LoadProfilesTab then RoRotaGUI.LoadProfilesTab(frame) end
    if RoRotaGUI.LoadPreviewTab then RoRotaGUI.LoadPreviewTab(frame) end
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
    
    local scrollFrame = CreateFrame("ScrollFrame", "RoRotaScrollFrame", f)
    scrollFrame:SetWidth(480)
    scrollFrame:SetHeight(460)
    scrollFrame:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -30)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(480)
    content:SetHeight(800)
    scrollFrame:SetScrollChild(content)
    
    local slider = CreateFrame("Slider", "RoRotaScrollSlider", scrollFrame)
    slider:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -10)
    slider:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 10)
    slider:SetWidth(16)
    slider:SetOrientation("VERTICAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    slider:SetMinMaxValues(0, 340)
    slider:SetValueStep(10)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function()
        scrollFrame:SetVerticalScroll(this:GetValue())
    end)
    
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function()
        local current = slider:GetValue()
        local step = 30
        if arg1 > 0 then
            slider:SetValue(math.max(0, current - step))
        else
            slider:SetValue(math.min(340, current + step))
        end
    end)

    f.tabs = {}
    local tabNames = {"About", "Openers", "Builders", "Finishers", "Defensive", "Poisons", "Profiles", "Preview"}
    
    for i = 1, 8 do
        local idx = i
        local btn = RoRotaGUI.CreateSidebarButton(sidebar, -40 - (i-1)*35, tabNames[i], function()
            ShowTab(f, idx)
        end)
        f.tabs[i] = {button = btn}
    end
    
    local t1 = CreateFrame("Frame", nil, content)
    t1:SetWidth(480)
    t1:SetHeight(800)
    t1:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    f.tabs[1].content = t1
    if RoRotaGUI.CreateAboutTab then RoRotaGUI.CreateAboutTab(t1, f) end
    
    local t2 = CreateFrame("Frame", nil, content)
    t2:SetWidth(480)
    t2:SetHeight(800)
    t2:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t2:Hide()
    f.tabs[2].content = t2
    if RoRotaGUI.CreateOpenersTab then RoRotaGUI.CreateOpenersTab(t2, f) end
    
    local t3 = CreateFrame("Frame", nil, content)
    t3:SetWidth(480)
    t3:SetHeight(800)
    t3:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t3:Hide()
    f.tabs[3].content = t3
    if RoRotaGUI.CreateBuildersTab then RoRotaGUI.CreateBuildersTab(t3, t3) end
    
    local t4 = CreateFrame("Frame", nil, content)
    t4:SetWidth(480)
    t4:SetHeight(800)
    t4:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t4:Hide()
    f.tabs[4].content = t4
    if RoRotaGUI.CreateFinishersTab then RoRotaGUI.CreateFinishersTab(t4, t4) end
    
    local t5 = CreateFrame("Frame", nil, content)
    t5:SetWidth(480)
    t5:SetHeight(800)
    t5:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t5:Hide()
    f.tabs[5].content = t5
    if RoRotaGUI.CreateDefensiveTab then RoRotaGUI.CreateDefensiveTab(t5, t5) end
    
    local t6 = CreateFrame("Frame", nil, content)
    t6:SetWidth(480)
    t6:SetHeight(800)
    t6:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t6:Hide()
    f.tabs[6].content = t6
    if RoRotaGUI.CreatePoisonsTab then RoRotaGUI.CreatePoisonsTab(t6, f) end
    
    local t7 = CreateFrame("Frame", nil, content)
    t7:SetWidth(480)
    t7:SetHeight(800)
    t7:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t7:Hide()
    f.tabs[7].content = t7
    if RoRotaGUI.CreateProfilesTab then RoRotaGUI.CreateProfilesTab(t7, f) end
    
    local t8 = CreateFrame("Frame", nil, content)
    t8:SetWidth(480)
    t8:SetHeight(800)
    t8:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    t8:Hide()
    f.tabs[8].content = t8
    if RoRotaGUI.CreatePreviewTab then RoRotaGUI.CreatePreviewTab(t8, f) end
    
    ShowTab(f, 1)
end
