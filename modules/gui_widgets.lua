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
function RoRotaGUI.CreateButton(name, parent, width, height, text, noHighlight)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetWidth(width or 100)
    button:SetHeight(height or 22)
    button:SetText(text or "")
    RoRotaGUI.CreateBackdrop(button)
    button:SetNormalTexture("")
    button:SetHighlightTexture("")
    button:SetPushedTexture("")
    if not noHighlight then
        RoRotaGUI.SetHighlight(button)
    end
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

-- create help text (small gray text for hints)
function RoRotaGUI.CreateHelpText(parent, text, width)
    local helpText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetText(text)
    helpText:SetTextColor(0.7, 0.7, 0.7)
    helpText:SetWidth(width or 350)
    helpText:SetJustifyH("LEFT")
    return helpText
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

-- ============================================================================
-- SUBTAB SYSTEM
-- ============================================================================

-- Create subtab structure with sidebar and content area
function RoRotaGUI.CreateSubtabStructure(parent, subtabNames, createFunctions, loadFunctions)
    local subtabBar = CreateFrame("Frame", nil, parent)
    subtabBar:SetWidth(90)
    subtabBar:SetHeight(460)
    subtabBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    subtabBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    })
    subtabBar:SetBackdropColor(0, 0, 0, 0.5)
    
    local contentArea = CreateFrame("Frame", nil, parent)
    contentArea:SetWidth(390)
    contentArea:SetHeight(460)
    contentArea:SetPoint("TOPLEFT", parent, "TOPLEFT", 90, 0)
    
    parent.subtabs = {}
    parent.subtabFrames = {}
    
    for i = 1, table.getn(subtabNames) do
        local idx = i
        local btn = RoRotaGUI.CreateSubTab(subtabBar, -10 - (i-1)*33, subtabNames[i], function()
            for j = 1, table.getn(parent.subtabFrames) do
                if j == idx then
                    parent.subtabFrames[j]:Show()
                    RoRotaGUI.SetSubTabActive(parent.subtabs[j], true)
                else
                    parent.subtabFrames[j]:Hide()
                    RoRotaGUI.SetSubTabActive(parent.subtabs[j], false)
                end
            end
        end)
        parent.subtabs[i] = btn
        
        local subFrame = CreateFrame("Frame", nil, contentArea)
        subFrame:SetWidth(390)
        subFrame:SetHeight(460)
        subFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 0, 0)
        subFrame:Hide()
        parent.subtabFrames[i] = subFrame
        
        if createFunctions[i] then
            createFunctions[i](subFrame)
        end
    end
    
    parent.subtabFrames[1]:Show()
    RoRotaGUI.SetSubTabActive(parent.subtabs[1], true)
end

-- ============================================================================
-- PRIORITY LIST SYSTEM
-- ============================================================================

-- Create priority list with up/down arrows
function RoRotaGUI.CreatePriorityList(parent, x, y, width, height, items, onUpdate)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetWidth(width or 350)
    frame:SetHeight(height or 200)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    
    frame.items = items or {}
    frame.buttons = {}
    frame.onUpdate = onUpdate
    
    function frame:Refresh()
        -- Properly destroy old buttons
        for i, btn in ipairs(self.buttons) do
            if btn.upBtn then btn.upBtn:Hide() end
            if btn.downBtn then btn.downBtn:Hide() end
            btn:Hide()
        end
        self.buttons = {}
        
        local yPos = -5
        for i, item in ipairs(self.items) do
            local btn = RoRotaGUI.CreateButton(nil, self, 140, 22, item)
            btn:SetPoint("TOPLEFT", self, "TOPLEFT", 10, yPos)
            btn.index = i
            btn.item = item
            
            local currentIndex = i
            
            local upBtn = RoRotaGUI.CreateButton(nil, self, 25, 22, "↑", true)
            upBtn:SetPoint("LEFT", btn, "RIGHT", 3, 0)
            RoRotaGUI.SetHighlight(upBtn)
            upBtn:SetScript("OnClick", function()
                if currentIndex > 1 then
                    local temp = frame.items[currentIndex]
                    frame.items[currentIndex] = frame.items[currentIndex - 1]
                    frame.items[currentIndex - 1] = temp
                    if frame.onUpdate then frame.onUpdate(frame.items) end
                    frame:Refresh()
                end
            end)
            btn.upBtn = upBtn
            
            local downBtn = RoRotaGUI.CreateButton(nil, self, 25, 22, "↓", true)
            downBtn:SetPoint("LEFT", upBtn, "RIGHT", 3, 0)
            RoRotaGUI.SetHighlight(downBtn)
            downBtn:SetScript("OnClick", function()
                if currentIndex < table.getn(frame.items) then
                    local temp = frame.items[currentIndex]
                    frame.items[currentIndex] = frame.items[currentIndex + 1]
                    frame.items[currentIndex + 1] = temp
                    if frame.onUpdate then frame.onUpdate(frame.items) end
                    frame:Refresh()
                end
            end)
            btn.downBtn = downBtn
            
            table.insert(self.buttons, btn)
            yPos = yPos - 27
        end
    end
    
    function frame:SetItems(newItems)
        self.items = newItems or {}
        self:Refresh()
    end
    
    frame:Refresh()
    return frame
end

-- ============================================================================
-- SCROLLABLE LIST SYSTEM
-- ============================================================================

function RoRotaGUI.CreateScrollableList(parent, x, y, width, height)
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetWidth(width or 350)
    scroll:SetHeight(height or 200)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    scroll:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    scroll:SetBackdropColor(0, 0, 0, 0.5)
    scroll:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(width - 30 or 320)
    content:SetHeight(1)
    scroll:SetScrollChild(content)
    
    local slider = CreateFrame("Slider", nil, scroll)
    slider:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -5, -18)
    slider:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -5, 18)
    slider:SetWidth(16)
    slider:SetOrientation("VERTICAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(0)
    slider:SetValueStep(1)
    RoRotaGUI.CreateBackdrop(slider)
    slider:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    slider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        scroll:SetVerticalScroll(value)
    end)
    
    scroll:SetScript("OnMouseWheel", function()
        local current = slider:GetValue()
        local min, max = slider:GetMinMaxValues()
        if arg1 > 0 then
            slider:SetValue(math.max(min, current - 20))
        else
            slider:SetValue(math.min(max, current + 20))
        end
    end)
    
    scroll:EnableMouseWheel(true)
    scroll.content = content
    scroll.slider = slider
    
    function scroll:UpdateScrollRange()
        local contentHeight = self.content:GetHeight()
        local scrollHeight = self:GetHeight()
        local maxScroll = math.max(0, contentHeight - scrollHeight + 20)
        self.slider:SetMinMaxValues(0, maxScroll)
        if maxScroll == 0 then
            self.slider:Hide()
        else
            self.slider:Show()
        end
    end
    
    return scroll
end

-- ============================================================================
-- EQUIPMENT TAB SYSTEM
-- ============================================================================

function RoRotaGUI.CreateEquipmentTab(parent, frame)
    local y = -10
    
    RoRotaGUI.CreateLabel(parent, 10, y, "Manage Equipment Sets")
    y = y - 25
    
    local setListFrame = CreateFrame("Frame", nil, parent)
    setListFrame:SetWidth(360)
    setListFrame:SetHeight(150)
    setListFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    setListFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    setListFrame:SetBackdropColor(0, 0, 0, 0.5)
    setListFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    frame.setListFrame = setListFrame
    frame.setButtons = {}
    
    y = y - 160
    
    local newSetBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "New Set")
    newSetBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    newSetBtn:SetScript("OnClick", function()
        StaticPopupDialogs["ROROTA_NEW_EQUIPMENT_SET"] = {
            text = "Enter set name:",
            button1 = "Create",
            button2 = "Cancel",
            hasEditBox = 1,
            maxLetters = 32,
            OnAccept = function()
                local name = getglobal(this:GetParent():GetName().."EditBox"):GetText()
                if name and name ~= "" then
                    if not RoRota.db.profile.equipmentSets then
                        RoRota.db.profile.equipmentSets = {}
                    end
                    if RoRota.db.profile.equipmentSets[name] then
                        RoRota:Print("Set '"..name.."' already exists")
                        return
                    end
                    RoRota.db.profile.equipmentSets[name] = {
                        mainHand = nil,
                        offHand = nil,
                        trinket1 = nil,
                        trinket2 = nil
                    }
                    RoRota:Print("Created equipment set: "..name)
                    frame.selectedSet = name
                    RoRotaGUI.RefreshEquipmentTab(frame)
                end
            end,
            OnShow = function()
                getglobal(this:GetName().."EditBox"):SetFocus()
            end,
            EditBoxOnEnterPressed = function()
                StaticPopupDialogs["ROROTA_NEW_EQUIPMENT_SET"].OnAccept()
                this:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function()
                this:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1
        }
        StaticPopup_Show("ROROTA_NEW_EQUIPMENT_SET")
    end)
    
    local deleteSetBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Delete Set")
    deleteSetBtn:SetPoint("LEFT", newSetBtn, "RIGHT", 10, 0)
    deleteSetBtn:SetScript("OnClick", function()
        if not frame.selectedSet then
            RoRota:Print("No set selected")
            return
        end
        RoRota.db.profile.equipmentSets[frame.selectedSet] = nil
        RoRota:Print("Deleted set: "..frame.selectedSet)
        frame.selectedSet = nil
        RoRotaGUI.RefreshEquipmentTab(frame)
    end)
    
    local saveBtn = RoRotaGUI.CreateButton(nil, parent, 100, 25, "Save Current")
    saveBtn:SetPoint("LEFT", deleteSetBtn, "RIGHT", 10, 0)
    saveBtn:SetScript("OnClick", function()
        if not frame.selectedSet then
            RoRota:Print("No set selected")
            return
        end
        local mhLink = GetInventoryItemLink("player", 16)
        local ohLink = GetInventoryItemLink("player", 17)
        local t1Link = GetInventoryItemLink("player", 13)
        local t2Link = GetInventoryItemLink("player", 14)
        
        local set = RoRota.db.profile.equipmentSets[frame.selectedSet]
        set.mainHand = mhLink or nil
        set.offHand = ohLink or nil
        set.trinket1 = t1Link or nil
        set.trinket2 = t2Link or nil
        
        RoRota:Print("Saved current equipment to: "..frame.selectedSet)
        RoRotaGUI.LoadEquipmentEditor(frame)
    end)
    
    y = y - 40
    
    local editorFrame = CreateFrame("Frame", nil, parent)
    editorFrame:SetWidth(360)
    editorFrame:SetHeight(120)
    editorFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    editorFrame:Hide()
    frame.editorFrame = editorFrame
    
    local editorY = -10
    RoRotaGUI.CreateLabel(editorFrame, 10, editorY, "Set Items:")
    editorY = editorY - 25
    
    RoRotaGUI.CreateLabel(editorFrame, 10, editorY, "Main Hand:")
    frame.mainHandLabel = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.mainHandLabel:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", 100, editorY)
    frame.mainHandLabel:SetText("-")
    editorY = editorY - 20
    
    RoRotaGUI.CreateLabel(editorFrame, 10, editorY, "Off Hand:")
    frame.offHandLabel = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.offHandLabel:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", 100, editorY)
    frame.offHandLabel:SetText("-")
    editorY = editorY - 20
    
    RoRotaGUI.CreateLabel(editorFrame, 10, editorY, "Trinket 1:")
    frame.trinket1Label = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.trinket1Label:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", 100, editorY)
    frame.trinket1Label:SetText("-")
    editorY = editorY - 20
    
    RoRotaGUI.CreateLabel(editorFrame, 10, editorY, "Trinket 2:")
    frame.trinket2Label = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.trinket2Label:SetPoint("TOPLEFT", editorFrame, "TOPLEFT", 100, editorY)
    frame.trinket2Label:SetText("-")
end

function RoRotaGUI.RefreshEquipmentTab(frame)
    if not frame or not frame.setListFrame then return end
    
    for _, btn in ipairs(frame.setButtons) do
        btn:Hide()
    end
    frame.setButtons = {}
    
    local sets = {}
    if RoRota.db.profile.equipmentSets then
        for name in pairs(RoRota.db.profile.equipmentSets) do
            table.insert(sets, name)
        end
    end
    table.sort(sets)
    
    local yPos = -10
    for _, setName in ipairs(sets) do
        local btn = CreateFrame("Button", nil, frame.setListFrame, "UIPanelButtonTemplate")
        btn:SetWidth(340)
        btn:SetHeight(25)
        btn:SetPoint("TOPLEFT", frame.setListFrame, "TOPLEFT", 10, yPos)
        btn:SetText(setName)
        btn.setName = setName
        RoRotaGUI.SkinButton(btn)
        
        btn:SetScript("OnClick", function()
            frame.selectedSet = this.setName
            RoRotaGUI.LoadEquipmentEditor(frame)
        end)
        
        table.insert(frame.setButtons, btn)
        yPos = yPos - 30
    end
    
    if frame.selectedSet and RoRota.db.profile.equipmentSets[frame.selectedSet] then
        RoRotaGUI.LoadEquipmentEditor(frame)
    else
        frame.editorFrame:Hide()
    end
end

function RoRotaGUI.LoadEquipmentEditor(frame)
    if not frame.selectedSet or not RoRota.db.profile.equipmentSets[frame.selectedSet] then
        frame.editorFrame:Hide()
        return
    end
    
    local set = RoRota.db.profile.equipmentSets[frame.selectedSet]
    
    frame.mainHandLabel:SetText(set.mainHand or "-")
    frame.offHandLabel:SetText(set.offHand or "-")
    frame.trinket1Label:SetText(set.trinket1 or "-")
    frame.trinket2Label:SetText(set.trinket2 or "-")
    
    frame.editorFrame:Show()
end

function RoRotaGUI.LoadEquipmentTab(frame)
    RoRotaGUI.RefreshEquipmentTab(frame)
end

RoRotaGUIWidgetsLoaded = true
