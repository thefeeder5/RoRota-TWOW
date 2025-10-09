-- RoRota State Module
-- Centralized state management with caching
-- Only caches frequently accessed values (energy, CP, health)
-- For buff/debuff checking, use buffs.lua functions directly

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
    
    -- Timestamps
    lastUpdate = 0,
}

-- Update all state (called on rotation calculation)
function RoRota.State:Update()
    -- Update frequently accessed values
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
    
    self.lastUpdate = GetTime()
end



-- Event handlers
function RoRota.State:OnCombatStart()
    self.inCombat = true
end

function RoRota.State:OnCombatEnd()
    self.inCombat = false
end

function RoRota.State:OnAuraChange()
    -- State update will happen on next rotation call
end
