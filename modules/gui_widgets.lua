--[[ gui_widgets ]]--
-- Widget library for consistent GUI styling.
-- Provides pfUI-style backdrops, buttons, checkboxes, sliders, and dropdowns.

RoRotaGUI = RoRotaGUI or {}

-- backdrop style
local backdrop = {
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 12,
    insets = {left = 2, right = 2, top = 2, bottom = 2}
}

-- create backdrop on frame
function RoRotaGUI.CreateBackdrop(frame)
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
end

-- create label
function RoRotaGUI.CreateLabel(parent, x, y, text)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(text)
    return label
end

-- skin button with hover
function RoRotaGUI.SkinButton(button)
    RoRotaGUI.CreateBackdrop(button)
    button:SetNormalTexture("")
    button:SetHighlightTexture("")
    button:SetPushedTexture("")
    
    button:SetScript("OnEnter", function()
        this:SetBackdropBorderColor(0.2, 1, 0.8, 1)
    end)
    button:SetScript("OnLeave", function()
        this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    end)
end

-- skin checkbox
function RoRotaGUI.SkinCheckbox(checkbox)
    checkbox:SetNormalTexture("")
    checkbox:SetPushedTexture("")
    checkbox:SetHighlightTexture("")
    RoRotaGUI.CreateBackdrop(checkbox)
    checkbox:SetBackdropColor(0, 0, 0, 0.5)
end

-- skin slider
function RoRotaGUI.SkinSlider(slider)
    RoRotaGUI.CreateBackdrop(slider)
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    local thumb = slider:GetThumbTexture()
    thumb:SetWidth(16)
    thumb:SetHeight(16)
end

-- create dropdown (borderless)
function RoRotaGUI.CreateDropdown(name, parent, x, y, width, items, callback)
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    local offset = (width or 100) - 100
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(width or 100, dd)
    
    local left = getglobal(name.."Left")
    local middle = getglobal(name.."Middle")
    local right = getglobal(name.."Right")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(dd, function()
        for _, item in ipairs(items or {}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.value = item
            info.func = function()
                if callback then callback(this.value) end
                UIDropDownMenu_SetSelectedValue(dd, this.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    return dd
end

-- create slider
function RoRotaGUI.CreateSlider(name, parent, x, y, min, max, step, width, lowText, highText, labelText, callback)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    slider:SetMinMaxValues(min or 0, max or 100)
    slider:SetValueStep(step or 1)
    slider:SetWidth(width or 120)
    
    if name then
        local low = getglobal(name.."Low")
        local high = getglobal(name.."High")
        local txt = getglobal(name.."Text")
        if low and lowText then low:SetText(tostring(lowText)) end
        if high and highText then high:SetText(tostring(highText)) end
        if txt and labelText then txt:SetText(tostring(labelText)) end
    end
    
    slider:SetScript("OnValueChanged", function()
        if callback then callback(this or slider) end
    end)
    
    RoRotaGUI.SkinSlider(slider)
    return slider
end

-- create checkbox
function RoRotaGUI.CreateCheckbox(name, parent, x, y, text, callback)
    local check = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 95, y - 2)
    check:SetWidth(20)
    check:SetHeight(20)
    local label = getglobal(name.."Text")
    if label then label:SetText(text) end
    check:SetScript("OnClick", callback)
    RoRotaGUI.SkinCheckbox(check)
    return check
end

-- create button
function RoRotaGUI.CreateButton(name, parent, width, height, text)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetWidth(width or 100)
    button:SetHeight(height or 22)
    button:SetText(text or "")
    RoRotaGUI.SkinButton(button)
    return button
end

-- create numeric dropdown
function RoRotaGUI.CreateDropdownNumeric(name, parent, x, y, min, max, step, callback)
    local items = {}
    if min == -1 then
        table.insert(items, "Disabled")
        min = 0
    end
    for i = min, max, step do
        table.insert(items, tostring(i))
    end
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    local offset = 80 - 100
    dd:SetPoint("TOPLEFT", parent, "TOPLEFT", x - 16 - offset, y + 4)
    UIDropDownMenu_SetWidth(80, dd)
    
    local left = getglobal(name.."Left")
    local middle = getglobal(name.."Middle")
    local right = getglobal(name.."Right")
    if left then left:SetTexture("") end
    if middle then middle:SetTexture("") end
    if right then right:SetTexture("") end
    
    UIDropDownMenu_Initialize(dd, function()
        for _, item in ipairs(items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.value = item == "Disabled" and -1 or tonumber(item)
            info.func = function()
                if callback then callback(this.value) end
                UIDropDownMenu_SetSelectedValue(dd, this.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    return dd
end

-- create sidebar button
function RoRotaGUI.CreateSidebarButton(parent, y, text, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetWidth(90)
    btn:SetHeight(30)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, y)
    RoRotaGUI.CreateBackdrop(btn)
    btn:SetNormalTexture("")
    btn:SetHighlightTexture("")
    btn:SetPushedTexture("")
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.text:SetText(text)
    
    btn:SetScript("OnEnter", function()
        this:SetBackdropBorderColor(0.2, 1, 0.8, 1)
    end)
    btn:SetScript("OnLeave", function()
        if not this.active then
            this:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        end
    end)
    btn:SetScript("OnClick", onClick)
    
    return btn
end

-- set sidebar button active
function RoRotaGUI.SetSidebarButtonActive(btn, active)
    if active then
        btn:SetBackdropBorderColor(0.2, 1, 0.8, 1)
        btn.text:SetTextColor(1, 1, 1)
        btn.active = true
    else
        btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        btn.text:SetTextColor(0.6, 0.6, 0.6)
        btn.active = false
    end
end

-- create editbox for numeric input
function RoRotaGUI.CreateEditBox(name, parent, x, y, width, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(width or 30)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetNumeric(true)
    eb:SetMaxLetters(3)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    local font = eb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    eb:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        if callback then callback(tonumber(this:GetText()) or 0) end
    end)
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return eb
end

-- create editbox for decimal input
function RoRotaGUI.CreateDecimalEditBox(name, parent, x, y, width, min, max, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(width or 50)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(3)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    local function validate()
        local text = this:GetText()
        local num = tonumber(text)
        if num then
            if num < min then num = min end
            if num > max then num = max end
            num = math.floor(num * 10 + 0.5) / 10
            this:SetText(string.format("%.1f", num))
            if callback then callback(num) end
        else
            this:SetText(string.format("%.1f", min))
            if callback then callback(min) end
        end
    end
    
    eb:SetScript("OnEnterPressed", function()
        validate()
        this:ClearFocus()
    end)
    eb:SetScript("OnEditFocusLost", validate)
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return eb
end

-- create setting row (label left, control right)
function RoRotaGUI.CreateSettingRow(parent, y, labelText, controlX)
    local label = RoRotaGUI.CreateLabel(parent, 20, y, labelText)
    return label, controlX or 350
end

RoRotaGUIWidgetsLoaded = true
