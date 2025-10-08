-- RoRota Debug Module
-- Debugging, logging, and state inspection

RoRota.Debug = {
    enabled = false,
    traceEnabled = false,
    logs = {},
    maxLogs = 100,
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
function RoRota.Debug:SetTrace(enabled)
    self.traceEnabled = enabled
    if enabled then
        RoRota:Print("Rotation trace enabled.")
    else
        RoRota:Print("Rotation trace disabled.")
    end
end

-- Log a debug message
function RoRota.Debug:Log(message, level)
    if not self.enabled then return end
    
    level = level or "INFO"
    local timestamp = date("%H:%M:%S")
    local logEntry = string.format("[%s] [%s] %s", timestamp, level, message)
    
    table.insert(self.logs, logEntry)
    if table.getn(self.logs) > self.maxLogs then
        table.remove(self.logs, 1)
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[RoRota Debug]|r " .. message)
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
end

function RoRota.Debug:ResetPerformance()
    self.Performance = {
        rotationTime = 0,
        rotationCalls = 0,
        avgTime = 0,
    }
    RoRota:Print("Performance stats reset.")
end
