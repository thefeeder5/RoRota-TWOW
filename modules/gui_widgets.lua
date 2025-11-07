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
    RoRotaGUI.SetHighlight(button)
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
    UIDropDownMenu_SetWidth(width or 100, dd)
    dd.dropdownWidth = width or 100
    
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
    UIDropDownMenu_SetWidth(80, dd)
    dd.dropdownWidth = 80
    
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
    if not parent then return nil end
    
    local btn = CreateFrame("Button", nil, parent)
    if not btn then return nil end
    
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
    
    RoRotaGUI.SetHighlight(btn)
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

-- create editbox for numeric input (generic)
function RoRotaGUI.CreateEditBox(name, parent, x, y, width, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(width or 30)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetNumeric(true)
    eb:SetMaxLetters(10)
    
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

-- create editbox for percentage (0-100)
function RoRotaGUI.CreatePercentEditBox(name, parent, x, y, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(40)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetNumeric(true)
    eb:SetMaxLetters(3)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    eb:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        local value = tonumber(this:GetText()) or 0
        if value < 0 then value = 0 end
        if value > 100 then value = 100 end
        this:SetText(tostring(value))
        if callback then callback(value) end
    end)
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return eb
end

-- create editbox for flat HP in thousands (0-99999k = 0-99999000)
function RoRotaGUI.CreateFlatHPEditBox(name, parent, x, y, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(60)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetNumeric(true)
    eb:SetMaxLetters(5)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    eb:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        local value = tonumber(this:GetText()) or 0
        if value < 0 then value = 0 end
        if value > 99999 then value = 99999 end
        this:SetText(tostring(value))
        if callback then callback(value * 1000) end
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
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(5)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    eb:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        local value = tonumber(this:GetText()) or 0
        if min and value < min then value = min end
        if max and value > max then value = max end
        this:SetText(string.format("%.1f", value))
        if callback then callback(value) end
    end)
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return eb
end

-- create editbox for text input (comma-separated lists)
function RoRotaGUI.CreateTextEditBox(name, parent, x, y, width, callback)
    local eb = CreateFrame("EditBox", name, parent)
    eb:SetWidth(width or 200)
    eb:SetHeight(20)
    eb:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 85, y + 2)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(200)
    
    RoRotaGUI.CreateBackdrop(eb)
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(5, 5, 0, 0)
    
    eb:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        if callback then callback(this:GetText()) end
    end)
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    
    return eb
end

-- create multi-line editbox for conditions
function RoRotaGUI.CreateMultiLineEditBox(name, parent, x, y, width, height, callback)
    local scroll = CreateFrame("ScrollFrame", name.."Scroll", parent)
    scroll:SetWidth(width or 350)
    scroll:SetHeight(height or 80)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    
    RoRotaGUI.CreateBackdrop(scroll)
    scroll:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    local eb = CreateFrame("EditBox", name, scroll)
    eb:SetWidth(width - 10 or 340)
    eb:SetHeight(height or 80)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(500)
    eb:SetFontObject("GameFontHighlightSmall")
    eb:SetTextInsets(5, 5, 5, 5)
    
    scroll:SetScrollChild(eb)
    
    eb:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        if callback then callback(this:GetText()) end
    end)
    eb:SetScript("OnEditFocusLost", function()
        if callback then callback(this:GetText()) end
    end)
    
    return eb
end

-- create setting row (label left, control right)
function RoRotaGUI.CreateSettingRow(parent, y, labelText, controlX)
    local label = RoRotaGUI.CreateLabel(parent, 20, y, labelText)
    return label, controlX or 350
end

-- create horizontal tab button
function RoRotaGUI.CreateHorizontalTab(parent, x, text, onClick)
    if not parent then return nil end
    
    local btn = CreateFrame("Button", nil, parent)
    if not btn then return nil end
    
    btn:SetWidth(85)
    btn:SetHeight(25)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", x, 0)
    RoRotaGUI.CreateBackdrop(btn)
    btn:SetNormalTexture("")
    btn:SetHighlightTexture("")
    btn:SetPushedTexture("")
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.text:SetText(text)
    
    RoRotaGUI.SetHighlight(btn)
    btn:SetScript("OnClick", onClick)
    
    return btn
end

-- set horizontal tab active
function RoRotaGUI.SetHorizontalTabActive(btn, active)
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

function RoRotaGUI.CreateSubTab(parent, y, text, onClick)
    if not parent then return nil end
    
    local btn = CreateFrame("Button", nil, parent)
    if not btn then return nil end
    
    btn:SetWidth(80)
    btn:SetHeight(30)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, y)
    RoRotaGUI.CreateBackdrop(btn)
    btn:SetNormalTexture("")
    btn:SetHighlightTexture("")
    btn:SetPushedTexture("")
    
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.text:SetText(text)
    btn.text:SetJustifyH("CENTER")
    btn.text:SetWidth(75)
    
    RoRotaGUI.SetHighlight(btn)
    btn:SetScript("OnClick", onClick)
    
    return btn
end

-- set subtab active
function RoRotaGUI.SetSubTabActive(btn, active)
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

-- ============================================================================
-- LAYOUT SYSTEM
-- ============================================================================

-- Layout manager for automatic positioning
function RoRotaGUI.CreateLayout(parent, startX, startY)
    return {
        parent = parent,
        x = startX or 20,
        y = startY or -20,
        
        -- Add a row (label + control)
        Row = function(self, label, control, spacing, tooltip)
            local lbl = RoRotaGUI.CreateLabel(self.parent, self.x, self.y, label)
            if tooltip and lbl then
                RoRotaGUI.SetTooltip(lbl, tooltip)
            end
            if control and type(control) == "table" and control.SetPoint then
                control:ClearAllPoints()
                local parentWidth = self.parent:GetWidth() or 480
                local rightEdge = parentWidth < 450 and 345 or 435
                local xPos = rightEdge
                local name = control.GetName and control:GetName() or ""
                if string.find(name, "DD") or string.find(name, "DropDown") then
                    local dropdownWidth = control.dropdownWidth or 100
                    xPos = rightEdge - dropdownWidth
                else
                    xPos = rightEdge - 20
                end
                control:SetPoint("TOPLEFT", self.parent, "TOPLEFT", xPos, self.y)
                if tooltip then
                    RoRotaGUI.SetTooltip(control, tooltip)
                end
            end
            self.y = self.y - (spacing or 20)
            return control
        end,
        
        -- Add spacing
        Space = function(self, amount)
            self.y = self.y - (amount or 10)
        end,
        
        -- Add custom widget at current position
        Add = function(self, widget, spacing)
            widget:SetPoint("TOPLEFT", self.parent, "TOPLEFT", self.x, self.y)
            self.y = self.y - (spacing or 20)
            return widget
        end,
        
        -- Get current Y position
        GetY = function(self)
            return self.y
        end,
        
        -- Set Y position
        SetY = function(self, y)
            self.y = y
        end
    }
end

-- ============================================================================
-- HIGHLIGHT SYSTEM
-- ============================================================================

-- Automatic hover highlight with lock support
function RoRotaGUI.SetHighlight(frame, r, g, b)
    if not frame then return end
    
    r, g, b = r or 0.2, g or 1, b or 0.8
    
    frame.highlightColor = {r, g, b}
    frame.normalColor = {0.3, 0.3, 0.3}
    
    local origEnter = frame:GetScript("OnEnter")
    local origLeave = frame:GetScript("OnLeave")
    
    frame:SetScript("OnEnter", function()
        if origEnter then origEnter() end
        if not frame.locked then
            frame:SetBackdropBorderColor(unpack(frame.highlightColor))
        end
    end)
    
    frame:SetScript("OnLeave", function()
        if origLeave then origLeave() end
        if not frame.locked then
            frame:SetBackdropBorderColor(unpack(frame.normalColor))
        end
    end)
    
    frame.LockHighlight = function(self)
        self.locked = true
        self:SetBackdropBorderColor(unpack(self.highlightColor))
    end
    
    frame.UnlockHighlight = function(self)
        self.locked = false
        self:SetBackdropBorderColor(unpack(self.normalColor))
    end
end

-- ============================================================================
-- TOOLTIP SYSTEM
-- ============================================================================

-- Add tooltip to any frame (single line)
function RoRotaGUI.SetTooltip(frame, text)
    if not frame or not text or text == "" then return end
    if not frame.GetScript then return end
    
    local origEnter = frame:GetScript("OnEnter")
    local origLeave = frame:GetScript("OnLeave")
    
    frame:SetScript("OnEnter", function()
        if origEnter then origEnter() end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        if origLeave then origLeave() end
        GameTooltip:Hide()
    end)
end

-- Add tooltip with title and description
function RoRotaGUI.SetTooltipMulti(frame, title, description)
    if not frame or not title then return end
    if not frame.GetScript then return end
    
    local origEnter = frame:GetScript("OnEnter")
    local origLeave = frame:GetScript("OnLeave")
    
    frame:SetScript("OnEnter", function()
        if origEnter then origEnter() end
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText(title, 1, 1, 1)
        if description then
            GameTooltip:AddLine(description, 0.8, 0.8, 0.8, true)
        end
        GameTooltip:Show()
    end)
    
    frame:SetScript("OnLeave", function()
        if origLeave then origLeave() end
        GameTooltip:Hide()
    end)
end

RoRotaGUIWidgetsLoaded = true
