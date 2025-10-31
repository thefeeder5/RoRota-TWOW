--[[ ttk ]]--
-- Target Time-To-Kill estimation
-- Tracks target HP over time to estimate seconds until death

if not RoRota then return end
if RoRota.ttk then return end

RoRota.ttk = {
    targetGUID = nil,
    startHP = nil,
    startTime = nil,
    samples = {},
    lastSampleTime = 0,
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
    
    -- Only record sample every 0.5 seconds
    if currentTime - self.ttk.lastSampleTime < 0.5 then
        return
    end
    
    local currentHP = UnitHealth("target")
    
    if not self.ttk.startHP or not self.ttk.startTime then
        return
    end
    
    table.insert(self.ttk.samples, {
        hp = currentHP,
        time = currentTime
    })
    
    self.ttk.lastSampleTime = currentTime
    
    -- Remove samples older than needed
    if not self.db or not self.db.profile or not self.db.profile.ttk then
        return
    end
    local windowSize = self.db.profile.ttk.sampleWindow or 3
    
    while table.getn(self.ttk.samples) > 0 do
        local oldestSample = self.ttk.samples[1]
        if currentTime - oldestSample.time > windowSize then
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
    
    if not self.db or not self.db.profile or not self.db.profile.ttk then
        return nil
    end
    
    local sampleCount = table.getn(self.ttk.samples)
    if sampleCount < 2 then
        return nil
    end
    
    local windowSize = self.db.profile.ttk.sampleWindow or 3
    local firstSample = self.ttk.samples[1]
    local lastSample = self.ttk.samples[sampleCount]
    local timeElapsed = lastSample.time - firstSample.time
    
    -- Need at least the configured window size of data
    if timeElapsed < windowSize then
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

function RoRota:IsTargetDyingSoon(threshold)
    if not self.db or not self.db.profile or not self.db.profile.ttk then
        return false
    end
    local ttk = self.db.profile.ttk
    if not ttk.enabled then
        return false
    end
    
    threshold = threshold or ttk.dyingThreshold or 10
    
    if ttk.excludeBosses and UnitClassification("target") == "worldboss" then
        return false
    end
    
    local ttk = self:EstimateTTK()
    if not ttk then
        return false
    end
    
    return ttk <= threshold and ttk > 0
end
