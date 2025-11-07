--[[ ttk ]]--
-- Target Time-To-Kill estimation
-- Tracks target HP over time to estimate seconds until death

if not RoRota then return end
if RoRota.ttk then return end

-- Automatic constants (not user-configurable)
local SAMPLE_INTERVAL = 0.25  -- Sample every 0.25s for accuracy
local SAMPLE_WINDOW = 3.0     -- Use 3s window for DPS calculation
local DYING_THRESHOLD = 8.0   -- Consider dying when TTK < 8s
local MIN_SAMPLES = 3         -- Require at least 3 samples

RoRota.ttk = {
    targetGUID = nil,
    startHP = nil,
    startTime = nil,
    samples = {},
    lastSampleTime = 0,
    lastHP = nil,
}

function RoRota:StartTTKTracking()
    if not self.ttk then
        return
    end
    if not UnitExists("target") or UnitIsDead("target") then
        self:ResetTTKTracking()
        return
    end
    
    local guid = UnitGUID("target")
    if guid ~= self.ttk.targetGUID then
        self.ttk.targetGUID = guid
        self.ttk.startHP = UnitHealth("target")
        self.ttk.startTime = GetTime()
        self.ttk.samples = {}
    end
end

function RoRota:ResetTTKTracking()
    if not self.ttk then
        return
    end
    self.ttk.targetGUID = nil
    self.ttk.startHP = nil
    self.ttk.startTime = nil
    self.ttk.samples = {}
end

function RoRota:UpdateTTKSample()
    if not self.ttk then
        return
    end
    if not self.ttk.targetGUID or not UnitExists("target") then
        return
    end
    
    if UnitGUID("target") ~= self.ttk.targetGUID then
        self:StartTTKTracking()
        return
    end
    
    local currentTime = GetTime()
    
    -- Sample every 0.25s for better accuracy
    if currentTime - self.ttk.lastSampleTime < SAMPLE_INTERVAL then
        return
    end
    
    local currentHP = UnitHealth("target")
    
    if not self.ttk.startHP or not self.ttk.startTime then
        return
    end
    
    -- Detect healing: if HP increased, reset tracking
    if self.ttk.lastHP and currentHP > self.ttk.lastHP then
        self:StartTTKTracking()
        return
    end
    
    table.insert(self.ttk.samples, {
        hp = currentHP,
        time = currentTime
    })
    
    self.ttk.lastSampleTime = currentTime
    self.ttk.lastHP = currentHP
    
    -- Remove samples older than window
    while table.getn(self.ttk.samples) > 0 do
        local oldestSample = self.ttk.samples[1]
        if currentTime - oldestSample.time > SAMPLE_WINDOW then
            table.remove(self.ttk.samples, 1)
        else
            break
        end
    end
end

function RoRota:EstimateTTK()
    if not self.ttk then
        return nil
    end
    if not self.ttk.targetGUID or not UnitExists("target") then
        return nil
    end
    
    local sampleCount = table.getn(self.ttk.samples)
    
    -- Require minimum samples for accuracy
    if sampleCount < MIN_SAMPLES then
        return nil
    end
    
    local firstSample = self.ttk.samples[1]
    local lastSample = self.ttk.samples[sampleCount]
    local timeElapsed = lastSample.time - firstSample.time
    
    -- Need at least 1 second of data
    if timeElapsed < 1.0 then
        return nil
    end
    
    local currentHP = UnitHealth("target")
    if currentHP <= 0 then
        return 0
    end
    
    local hpLost = firstSample.hp - lastSample.hp
    
    if timeElapsed <= 0 or hpLost <= 0 then
        return nil
    end
    
    local dps = hpLost / timeElapsed
    local ttk = currentHP / dps
    
    return ttk
end

function RoRota:IsTargetDyingSoon()
    if not self.db or not self.db.profile or not self.db.profile.ttk then
        return false
    end
    if not self.db.profile.ttk.enabled then
        return false
    end
    
    -- Exclude bosses if configured
    if self.db.profile.ttk.excludeBosses and UnitClassification("target") == "worldboss" then
        return false
    end
    
    local ttk = self:EstimateTTK()
    if not ttk then
        return false
    end
    
    return ttk <= DYING_THRESHOLD and ttk > 0
end
