-- RoRota State Module
-- Centralized state management with caching

RoRota.State = {
    -- Combat state
    inCombat = false,
    energy = 0,
    comboPoints = 0,
    
    -- Player state
    stealthed = false,
    health = 0,
    healthMax = 0,
    healthPercent = 100,
    
    -- Target state
    hasTarget = false,
    targetHealth = 0,
    targetHealthMax = 0,
    targetHealthPercent = 100,
    targetCasting = false,
    
    -- Buffs/Debuffs (cached)
    buffs = {},
    targetDebuffs = {},
    
    -- Timestamps
    lastUpdate = 0,
    lastBuffScan = 0,
    lastAbilityCheck = 0,
    
    -- Cache
    abilityCache = {},
    buffCache = {},
}

-- Update all state (called on rotation calculation)
function RoRota.State:Update()
    local now = GetTime()
    
    -- Always update these (cheap)
    self.inCombat = UnitAffectingCombat("player")
    self.energy = UnitMana("player")
    self.comboPoints = GetComboPoints("player", "target")
    self.stealthed = RoRota:HasPlayerBuff("Stealth")
    
    -- Player health
    self.health = UnitHealth("player")
    self.healthMax = UnitHealthMax("player")
    self.healthPercent = (self.health / self.healthMax) * 100
    
    -- Target state
    self.hasTarget = UnitExists("target") and not UnitIsDead("target")
    if self.hasTarget then
        self.targetHealth = UnitHealth("target")
        self.targetHealthMax = UnitHealthMax("target")
        self.targetHealthPercent = (self.targetHealth / self.targetHealthMax) * 100
    else
        self.targetHealth = 0
        self.targetHealthMax = 0
        self.targetHealthPercent = 0
    end
    
    -- Update buffs if cache expired (0.5s)
    if now - self.lastBuffScan > 0.5 then
        self:UpdateBuffs()
        self.lastBuffScan = now
    end
    
    self.lastUpdate = now
end

-- Update buff cache
function RoRota.State:UpdateBuffs()
    self.buffs = {}
    self.targetDebuffs = {}
    
    -- Scan player buffs
    local i = 1
    while UnitBuff("player", i) do
        local texture = UnitBuff("player", i)
        if texture then
            table.insert(self.buffs, texture)
        end
        i = i + 1
        if i > 40 then break end
    end
    
    -- Scan target debuffs
    if self.hasTarget then
        i = 1
        while UnitDebuff("target", i) do
            local texture = UnitDebuff("target", i)
            if texture then
                table.insert(self.targetDebuffs, texture)
            end
            i = i + 1
            if i > 40 then break end
        end
    end
end

-- Check if ability is available (with caching)
function RoRota.State:IsAbilityAvailable(abilityName)
    local now = GetTime()
    local cache = self.abilityCache[abilityName]
    
    -- Return cached result if still valid (0.5s)
    if cache and now - cache.time < 0.5 then
        return cache.available
    end
    
    -- Check ability availability
    local available = RoRota:HasSpell(abilityName) and RoRota:HasEnoughEnergy(abilityName) and not RoRota:IsOnCooldown(abilityName)
    
    -- Cache result
    self.abilityCache[abilityName] = {
        available = available,
        time = now
    }
    
    return available
end

-- Check if buff is active (uses cached buffs)
function RoRota.State:HasBuff(buffTexture)
    for _, texture in ipairs(self.buffs) do
        if string.find(texture, buffTexture) then
            return true
        end
    end
    return false
end

-- Check if target has debuff (uses cached debuffs)
function RoRota.State:TargetHasDebuff(debuffTexture)
    for _, texture in ipairs(self.targetDebuffs) do
        if string.find(texture, debuffTexture) then
            return true
        end
    end
    return false
end

-- Clear all caches
function RoRota.State:ClearCache()
    self.abilityCache = {}
    self.buffCache = {}
    self.lastBuffScan = 0
    self.lastAbilityCheck = 0
end

-- Event handlers
function RoRota.State:OnCombatStart()
    self.inCombat = true
    self:ClearCache()
end

function RoRota.State:OnCombatEnd()
    self.inCombat = false
    self:ClearCache()
end

function RoRota.State:OnAuraChange()
    -- Force buff rescan on next update
    self.lastBuffScan = 0
end
