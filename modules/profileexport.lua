--[[ profileexport ]]--
-- Profile import/export with base64 encoding

if not RoRota then return end

local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64encode(str)
    local result = ""
    local padding = ""
    local len = string.len(str)
    local i = 1
    
    while i <= len do
        local byte1 = string.byte(str, i)
        local byte2 = i + 1 <= len and string.byte(str, i + 1) or 0
        local byte3 = i + 2 <= len and string.byte(str, i + 2) or 0
        
        local enc1 = math.floor(byte1 / 4)
        local enc2 = math.mod(byte1, 4) * 16 + math.floor(byte2 / 16)
        local enc3 = math.mod(byte2, 16) * 4 + math.floor(byte3 / 64)
        local enc4 = math.mod(byte3, 64)
        
        result = result .. string.sub(base64chars, enc1 + 1, enc1 + 1)
        result = result .. string.sub(base64chars, enc2 + 1, enc2 + 1)
        
        if i + 1 <= len then
            result = result .. string.sub(base64chars, enc3 + 1, enc3 + 1)
        else
            padding = padding .. "="
        end
        
        if i + 2 <= len then
            result = result .. string.sub(base64chars, enc4 + 1, enc4 + 1)
        else
            padding = padding .. "="
        end
        
        i = i + 3
    end
    
    return result .. padding
end

local function base64decode(str)
    str = string.gsub(str, "=", "")
    local result = ""
    local len = string.len(str)
    local i = 1
    
    while i <= len do
        local char1 = string.sub(str, i, i)
        local char2 = string.sub(str, i + 1, i + 1)
        local char3 = string.sub(str, i + 2, i + 2)
        local char4 = string.sub(str, i + 3, i + 3)
        
        local pos1 = string.find(base64chars, char1, 1, true)
        local pos2 = string.find(base64chars, char2, 1, true)
        if not pos1 or not pos2 then return nil end
        
        local enc1 = pos1 - 1
        local enc2 = pos2 - 1
        local enc3 = 0
        local enc4 = 0
        
        if char3 ~= "" then
            local pos3 = string.find(base64chars, char3, 1, true)
            if pos3 then enc3 = pos3 - 1 end
        end
        if char4 ~= "" then
            local pos4 = string.find(base64chars, char4, 1, true)
            if pos4 then enc4 = pos4 - 1 end
        end
        
        local byte1 = enc1 * 4 + math.floor(enc2 / 16)
        local byte2 = math.mod(enc2, 16) * 16 + math.floor(enc3 / 4)
        local byte3 = math.mod(enc3, 4) * 64 + enc4
        
        result = result .. string.char(byte1)
        if char3 ~= "" then result = result .. string.char(byte2) end
        if char4 ~= "" then result = result .. string.char(byte3) end
        
        i = i + 4
    end
    
    return result
end

local function serializeTable(tbl, indent)
    indent = indent or 0
    local result = "{"
    local first = true
    
    for k, v in pairs(tbl) do
        if not first then result = result .. "," end
        first = false
        
        if type(k) == "string" then
            result = result .. "[\"" .. k .. "\"]="
        else
            result = result .. "[" .. k .. "]="
        end
        
        if type(v) == "table" then
            result = result .. serializeTable(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. "\"" .. string.gsub(v, "\"", "\\\"") .. "\""
        elseif type(v) == "boolean" then
            result = result .. (v and "true" or "false")
        else
            result = result .. tostring(v)
        end
    end
    
    return result .. "}"
end

function RoRota:ExportProfile()
    if not self.db or not self.db.profile then
        self:Print("No profile to export")
        return nil
    end
    
    local serialized = serializeTable(self.db.profile)
    local encoded = base64encode(serialized)
    return encoded
end

function RoRota:ImportProfile(encoded)
    if not encoded or encoded == "" then
        self:Print("No data to import")
        return false
    end
    
    local decoded = base64decode(encoded)
    local func = loadstring("return " .. decoded)
    
    if not func then
        self:Print("Invalid profile data")
        return false
    end
    
    local success, profile = pcall(func)
    if not success or type(profile) ~= "table" then
        self:Print("Failed to parse profile data")
        return false
    end
    
    self.db.profile = profile
    self:Print("Profile imported successfully")
    
    if RoRotaGUIFrame and RoRotaGUI.LoadAllTabs then
        RoRotaGUI.LoadAllTabs(RoRotaGUIFrame)
    end
    
    return true
end

function RoRota:ShowExportWindow()
    if RoRotaExportFrame then
        local editBox = getglobal("RoRotaExportEditBox")
        if editBox then
            editBox:SetText("")
            editBox:ClearFocus()
        end
        RoRotaExportFrame:Show()
        return
    end
    
    local f = CreateFrame("Frame", "RoRotaExportFrame", UIParent)
    f:SetWidth(500)
    f:SetHeight(300)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    f:SetBackdropColor(0, 0, 0, 0.9)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    table.insert(UISpecialFrames, "RoRotaExportFrame")
    
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Profile Export/Import")
    
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    
    local scroll = CreateFrame("ScrollFrame", "RoRotaExportScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -40)
    scroll:SetPoint("BOTTOMRIGHT", -30, 50)
    
    local editBox = CreateFrame("EditBox", "RoRotaExportEditBox", scroll)
    editBox:SetWidth(460)
    editBox:SetHeight(200)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    scroll:SetScrollChild(editBox)
    
    local exportBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    exportBtn:SetWidth(100)
    exportBtn:SetHeight(25)
    exportBtn:SetPoint("BOTTOMLEFT", 10, 10)
    exportBtn:SetText("Export")
    exportBtn:SetScript("OnClick", function()
        local data = RoRota:ExportProfile()
        if data then
            editBox:SetText(data)
            editBox:HighlightText()
            editBox:SetFocus()
            RoRota:Print("Profile exported - press Ctrl+C to copy")
        end
    end)
    
    local decryptBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    decryptBtn:SetWidth(100)
    decryptBtn:SetHeight(25)
    decryptBtn:SetPoint("BOTTOM", 0, 10)
    decryptBtn:SetText("Decrypt")
    decryptBtn:SetScript("OnClick", function()
        local text = editBox:GetText()
        if text and text ~= "" then
            local decoded = base64decode(text)
            if decoded then
                editBox:SetText(decoded)
                RoRota:Print("Profile decrypted")
            else
                RoRota:Print("Already decrypted or invalid data")
            end
        end
    end)
    
    local importBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    importBtn:SetWidth(100)
    importBtn:SetHeight(25)
    importBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    importBtn:SetText("Import")
    importBtn:SetScript("OnClick", function()
        local text = editBox:GetText()
        if text and text ~= "" then
            local decoded = base64decode(text)
            if not decoded then
                decoded = text
            end
            local func = loadstring("return " .. decoded)
            if not func then
                RoRota:Print("Invalid profile data")
                return
            end
            local success, profile = pcall(func)
            if not success or type(profile) ~= "table" then
                RoRota:Print("Failed to parse profile data")
                return
            end
            RoRota.db.profile = profile
            RoRota:Print("Profile imported successfully")
            if RoRotaGUIFrame and RoRotaGUI.LoadAllTabs then
                RoRotaGUI.LoadAllTabs(RoRotaGUIFrame)
            end
            f:Hide()
        end
    end)
    
    f:Show()
end
