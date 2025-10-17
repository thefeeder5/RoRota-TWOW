-- RoRota Debug Module
-- Debugging, logging, and state inspection

RoRota.Debug = {
    enabled = false,
    traceEnabled = false,
    paused = false,
    logs = {},
    maxLogs = 100,
    window = nil,
}

-- Enable/disable debug mode
function RoRota.Debug:SetEnabled(enabled)
    self.enabled = enabled
    if enabled then
        RoRota:Print("Debug mode enabled. Use /rr debug off to disable.")
    else
        RoRota:Print("Debug mode disabled.")
    end
end

-- Enable/disable rotation trace
function RoRota.Debug:SetTrace(enabled, silent)
    self.traceEnabled = enabled
    if not silent then
        if enabled then
            RoRota:Print("Rotation trace enabled.")
        else
            RoRota:Print("Rotation trace disabled.")
        end
    end
end

-- Log a debug message
function RoRota.Debug:Log(message, level)
    if not self.enabled or self.paused then return end
    
    level = level or "INFO"
    local timestamp = date("%H:%M:%S")
    local logEntry = string.format("[%s] [%s] %s", timestamp, level, message)
    
    table.insert(self.logs, logEntry)
    if table.getn(self.logs) > self.maxLogs then
        table.remove(self.logs, 1)
    end
    
    -- Only show in chat if debug window is not open
    if not (self.window and self.window:IsVisible()) then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[RoRota Debug]|r " .. message)
    end
    
    -- Update debug window if open
    if self.window and self.window:IsVisible() then
        self:UpdateLogDisplay()
    end
end

-- Log ability cast with reason (simplified)
function RoRota.Debug:LogCast(ability, reason)
    if not self.enabled or self.paused then return end
    
    local timestamp = date("%H:%M:%S")
    local logEntry = string.format("[%s] Cast %s - %s", timestamp, ability, reason)
    
    table.insert(self.logs, logEntry)
    if table.getn(self.logs) > self.maxLogs then
        table.remove(self.logs, 1)
    end
    
    -- Update debug window if open
    if self.window and self.window:IsVisible() then
        self:UpdateLogDisplay()
    end
end

-- Trace rotation decision
function RoRota.Debug:Trace(ability, reason, details)
    if not self.traceEnabled then return end
    
    local msg = string.format("Ability: %s | Reason: %s", ability or "None", reason or "Unknown")
    if details then
        msg = msg .. " | " .. details
    end
    
    self:Log(msg, "TRACE")
end

-- Log error
function RoRota.Debug:Error(message, err)
    local msg = message
    if err then
        msg = msg .. " | Error: " .. tostring(err)
    end
    
    table.insert(self.logs, msg)
    RoRota:Print("|cFFFF0000[Error]|r " .. message)
end

-- Show current state
function RoRota.Debug:ShowState()
    if not RoRota.State then
        RoRota:Print("State system not initialized")
        return
    end
    
    local state = RoRota.State
    RoRota:Print("=== RoRota State ===")
    RoRota:Print("Combat: " .. (state.inCombat and "Yes" or "No"))
    RoRota:Print("Energy: " .. (state.energy or 0))
    RoRota:Print("Combo Points: " .. (state.comboPoints or 0))
    RoRota:Print("Stealth: " .. (state.stealthed and "Yes" or "No"))
    RoRota:Print("Target: " .. (state.hasTarget and "Yes" or "No"))
    
    if state.buffs then
        RoRota:Print("Active Buffs: " .. table.getn(state.buffs))
    end
    
    if state.targetDebuffs then
        RoRota:Print("Target Debuffs: " .. table.getn(state.targetDebuffs))
    end
    
    RoRota:Print("Last Update: " .. string.format("%.2f", GetTime() - (state.lastUpdate or 0)) .. "s ago")
end

-- Show recent logs
function RoRota.Debug:ShowLogs(count)
    count = count or 10
    RoRota:Print("=== Recent Logs (last " .. count .. ") ===")
    
    local start = math.max(1, table.getn(self.logs) - count + 1)
    for i = start, table.getn(self.logs) do
        DEFAULT_CHAT_FRAME:AddMessage(self.logs[i])
    end
end

-- Clear logs
function RoRota.Debug:ClearLogs()
    self.logs = {}
    RoRota:Print("Debug logs cleared.")
end

-- Performance tracking
RoRota.Debug.Performance = {
    rotationTime = 0,
    rotationCalls = 0,
    avgTime = 0,
}

function RoRota.Debug:StartTimer()
    if not self.enabled then return end
    self.Performance.startTime = GetTime()
end

function RoRota.Debug:EndTimer()
    if not self.enabled or not self.Performance.startTime then return end
    
    local elapsed = GetTime() - self.Performance.startTime
    self.Performance.rotationTime = self.Performance.rotationTime + elapsed
    self.Performance.rotationCalls = self.Performance.rotationCalls + 1
    self.Performance.avgTime = self.Performance.rotationTime / self.Performance.rotationCalls
    
    if elapsed > 0.01 then
        self:Log(string.format("Rotation took %.3fms (slow!)", elapsed * 1000), "WARN")
    end
end

function RoRota.Debug:ShowPerformance()
    local perf = self.Performance
    RoRota:Print("=== Performance Stats ===")
    RoRota:Print(string.format("Total Calls: %d", perf.rotationCalls))
    RoRota:Print(string.format("Total Time: %.3fs", perf.rotationTime))
    RoRota:Print(string.format("Avg Time: %.3fms", perf.avgTime * 1000))
    
    -- Phase 9: Performance validation
    if perf.avgTime > 0.001 then
        RoRota:Print("|cFFFF0000WARNING: Avg time > 1ms (slow!)|r")
    else
        RoRota:Print("|cFF00FF00Performance: GOOD (< 1ms)|r")
    end
    
    -- Cache stats
    if RoRota.Cache then
        local cacheStats = RoRota.Cache:GetStats()
        RoRota:Print(string.format("Cache Hit Rate: %.1f%%", cacheStats.hitRate))
        if cacheStats.hitRate < 50 then
            RoRota:Print("|cFFFF0000WARNING: Low cache hit rate|r")
        end
    end
end

function RoRota.Debug:ResetPerformance()
    self.Performance = {
        rotationTime = 0,
        rotationCalls = 0,
        avgTime = 0,
    }
    RoRota:Print("Performance stats reset.")
end

-- Create debug window
function RoRota.Debug:CreateWindow()
    if self.window then
        self.window:Show()
        return
    end
    
    local f = CreateFrame("Frame", "RoRotaDebugFrame", UIParent)
    f:SetWidth(500)
    f:SetHeight(400)
    f:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
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
    table.insert(UISpecialFrames, "RoRotaDebugFrame")
    
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("RoRota Debug Console")
    
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    
    -- Clear button
    local clearBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    clearBtn:SetWidth(60)
    clearBtn:SetHeight(20)
    clearBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -35)
    clearBtn:SetText("Clear")
    clearBtn:SetScript("OnClick", function()
        RoRota.Debug:ClearLogs()
        RoRota.Debug:UpdateLogDisplay()
    end)
    
    -- Module status button
    local moduleBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    moduleBtn:SetWidth(80)
    moduleBtn:SetHeight(20)
    moduleBtn:SetPoint("LEFT", clearBtn, "RIGHT", 5, 0)
    moduleBtn:SetText("Modules")
    moduleBtn:SetScript("OnClick", function()
        RoRota.Debug:ShowModuleStatus()
    end)
    
    -- Pause button
    local pauseBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    pauseBtn:SetWidth(60)
    pauseBtn:SetHeight(20)
    pauseBtn:SetPoint("LEFT", moduleBtn, "RIGHT", 5, 0)
    pauseBtn:SetText("Pause")
    pauseBtn:SetScript("OnClick", function()
        RoRota.Debug.paused = not RoRota.Debug.paused
        pauseBtn:SetText(RoRota.Debug.paused and "Resume" or "Pause")
    end)
    
    -- Copy all button
    local copyBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    copyBtn:SetWidth(70)
    copyBtn:SetHeight(20)
    copyBtn:SetPoint("LEFT", pauseBtn, "RIGHT", 5, 0)
    copyBtn:SetText("Copy All")
    copyBtn:SetScript("OnClick", function()
        if f.logText then
            f.logText:SetFocus()
            f.logText:HighlightText()
        end
    end)
    
    -- State display (expanded for queue + pacing)
    local stateFrame = CreateFrame("Frame", nil, f)
    stateFrame:SetWidth(480)
    stateFrame:SetHeight(140)
    stateFrame:SetPoint("TOPLEFT", clearBtn, "BOTTOMLEFT", 0, -10)
    stateFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    stateFrame:SetBackdropColor(0, 0, 0, 0.5)
    
    f.stateText = stateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.stateText:SetPoint("TOPLEFT", stateFrame, "TOPLEFT", 5, -5)
    f.stateText:SetJustifyH("LEFT")
    f.stateText:SetWidth(470)
    
    -- Log display (adjusted for larger state frame)
    local logFrame = CreateFrame("ScrollFrame", nil, f)
    logFrame:SetWidth(480)
    logFrame:SetHeight(200)
    logFrame:SetPoint("TOPLEFT", stateFrame, "BOTTOMLEFT", 0, -10)
    
    local logContent = CreateFrame("Frame", nil, logFrame)
    logContent:SetWidth(480)
    logContent:SetHeight(1000)
    logFrame:SetScrollChild(logContent)
    
    logContent:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = {left = 2, right = 2, top = 2, bottom = 2}
    })
    logContent:SetBackdropColor(0, 0, 0, 0.8)
    
    f.logText = CreateFrame("EditBox", nil, logContent)
    f.logText:SetPoint("TOPLEFT", logContent, "TOPLEFT", 5, -5)
    f.logText:SetWidth(470)
    f.logText:SetHeight(1000)
    f.logText:SetMultiLine(true)
    f.logText:SetAutoFocus(false)
    f.logText:SetFontObject(GameFontNormalSmall)
    f.logText:SetTextColor(1, 1, 1, 1)
    f.logText:EnableMouse(true)
    f.logText:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    
    -- Scroll slider
    local slider = CreateFrame("Slider", nil, logFrame)
    slider:SetPoint("TOPRIGHT", logFrame, "TOPRIGHT", 0, -10)
    slider:SetPoint("BOTTOMRIGHT", logFrame, "BOTTOMRIGHT", 0, 10)
    slider:SetWidth(16)
    slider:SetOrientation("VERTICAL")
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
    slider:SetMinMaxValues(0, 760)
    slider:SetValueStep(20)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function()
        logFrame:SetVerticalScroll(this:GetValue())
    end)
    
    logFrame:EnableMouseWheel(true)
    logFrame:SetScript("OnMouseWheel", function()
        local current = slider:GetValue()
        local step = 40
        if arg1 > 0 then
            slider:SetValue(math.max(0, current - step))
        else
            slider:SetValue(math.min(760, current + step))
        end
    end)
    
    f.slider = slider
    self.window = f
    
    -- Update display
    self:UpdateStateDisplay()
    self:UpdateLogDisplay()
    
    -- Auto-update timer
    f:SetScript("OnUpdate", function()
        if RoRota.Debug.paused then return end
        if not this.lastUpdate then this.lastUpdate = 0 end
        if GetTime() - this.lastUpdate > 0.1 then
            if RoRota.Cache and RoRota.Cache.Update then
                RoRota.Cache:Update()
            end
            RoRota.Debug:UpdateStateDisplay()
            this.lastUpdate = GetTime()
        end
    end)
end

-- Update state display
function RoRota.Debug:UpdateStateDisplay()
    if not self.window or not self.window.stateText then return end
    
    local cache = RoRota.Cache or {}
    local lines = {}
    
    -- Line 1: Basic state (use Cache for consistency)
    local isStealthed = cache.stealthed or false
    table.insert(lines, string.format("Energy: %d | CP: %d | Combat: %s | Stealth: %s", 
        cache.energy or 0,
        cache.comboPoints or 0,
        cache.inCombat and "Yes" or "No",
        isStealthed and "Yes" or "No"))
    
    -- Line 2: Ability queue
    if RoRota.PredictNextAbilities then
        local queue = RoRota:PredictNextAbilities(3)
        local queueStr = "Queue: " .. (queue[1] or "None")
        if queue[2] then queueStr = queueStr .. " -> " .. queue[2] end
        if queue[3] then queueStr = queueStr .. " -> " .. queue[3] end
        table.insert(lines, queueStr)
    end
    
    -- Line 3: Timeline deadline
    if RoRota.Timeline and RoRota.Timeline.nextDeadline then
        local dl = RoRota.Timeline.nextDeadline
        table.insert(lines, string.format("Deadline: %s in %.1fs (priority %d)",
            dl.name, dl.expiresIn, dl.priority))
    else
        table.insert(lines, "Deadline: None")
    end
    
    -- Line 4: Failsafe counters
    local builderAttempts = "?"
    local openerAttempts = "?"
    if RoRota.GetBuilderFailsafeInfo then
        local info = RoRota:GetBuilderFailsafeInfo()
        builderAttempts = info.attempts
    end
    if RoRota.GetOpenerFailsafeInfo then
        local info = RoRota:GetOpenerFailsafeInfo()
        openerAttempts = info.attempts
    end
    table.insert(lines, string.format("Failsafe: Builder=%s | Opener=%s", builderAttempts, openerAttempts))
    
    -- Line 5: CP Pacing
    if RoRota.CreateSimulatedState and RoRota.CalculateCPPacing then
        local state = RoRota:CreateSimulatedState()
        local pacing = RoRota:CalculateCPPacing(state)
        if pacing.isAheadOfSchedule then
            table.insert(lines, "Pacing: AHEAD - Should DUMP CP")
        elseif pacing.isBehindSchedule then
            table.insert(lines, string.format("Pacing: BEHIND (need %.0f GCDs) - BUILD NOW", pacing.gcdsAvailable or 0))
        elseif pacing.inPlanningWindow then
            table.insert(lines, "Pacing: ON SCHEDULE")
        else
            table.insert(lines, "Pacing: FREE BUILDING")
        end
    end
    
    -- Line 6: Performance
    local perf = self.Performance
    table.insert(lines, string.format("Perf: %.2fms avg | Cache: %.0f%% hit",
        (perf.avgTime or 0) * 1000,
        RoRota.Cache and RoRota.Cache:GetStats().hitRate or 0))
    
    -- Line 7: Preview window status
    if RoRotaPreviewFrame then
        local hasTarget = UnitExists("target") and not UnitIsDead("target")
        table.insert(lines, string.format("Preview: enabled=%s | hasTarget=%s | visible=%s",
            tostring(RoRotaPreviewFrame.enabled),
            tostring(hasTarget),
            tostring(RoRotaPreviewFrame:IsVisible())))
    else
        table.insert(lines, "Preview: Frame not created")
    end
    
    self.window.stateText:SetText(table.concat(lines, "\n"))
end

-- Update log display
function RoRota.Debug:UpdateLogDisplay()
    if not self.window or not self.window.logText then return end
    
    local logLines = {}
    local start = math.max(1, table.getn(self.logs) - 50 + 1)
    
    for i = start, table.getn(self.logs) do
        table.insert(logLines, self.logs[i])
    end
    
    self.window.logText:SetText(table.concat(logLines, "\n"))
    
    -- Auto-scroll to bottom
    if self.window.slider then
        self.window.slider:SetValue(760)
    end
end

-- Show module status
function RoRota.Debug:ShowModuleStatus()
    local modules = {
        {"abilities", RoRota.abilities},
        {"buffs", RoRota.buffs},
        {"casting", RoRota.casting},
        {"commands", RoRota.commands},
        {"cppacing", RoRota.cppacing},
        {"damage", RoRota.damage},
        {"defensive", RoRota.defensive},
        {"energytick", RoRota.energytick},
        {"events", RoRota.events},
        {"gui_cpdebug", RoRota.gui_cpdebug},
        {"gui_preview", RoRota.gui_preview},
        {"immunity", RoRota.immunity},
        {"interrupt", RoRota.interrupt},
        {"opener", RoRota.opener},
        {"planner", RoRota.planner},
        {"state", RoRota.state},
        {"talents", RoRota.talents},
        {"timeline", RoRota.timeline}
    }
    
    -- Add to debug window logs
    local timestamp = date("%H:%M:%S")
    table.insert(self.logs, string.format("[%s] [MODULE] === MODULE STATUS ===", timestamp))
    
    for _, module in ipairs(modules) do
        local name = module[1]
        local loaded = module[2] and "LOADED" or "NOT LOADED"
        table.insert(self.logs, string.format("[%s] [MODULE] %s: %s", timestamp, name, loaded))
    end
    
    -- Check key functions
    table.insert(self.logs, string.format("[%s] [MODULE] === FUNCTION STATUS ===", timestamp))
    local functions = {
        {"GetRotationAbility", RoRota.GetRotationAbility},
        {"CreateSimulatedState", RoRota.CreateSimulatedState},
        {"HasSpell", RoRota.HasSpell},
        {"GetEnergyCost", RoRota.GetEnergyCost}
    }
    
    for _, func in ipairs(functions) do
        local name = func[1]
        local exists = func[2] and "EXISTS" or "MISSING"
        table.insert(self.logs, string.format("[%s] [MODULE] %s: %s", timestamp, name, exists))
    end
    
    -- Update debug window display
    if self.window and self.window:IsVisible() then
        self:UpdateLogDisplay()
    end
end

-- Show debug window
function RoRota.Debug:Show()
    -- Auto-enable debug and trace when opening window
    self.enabled = true
    self.traceEnabled = true
    self:CreateWindow()
end