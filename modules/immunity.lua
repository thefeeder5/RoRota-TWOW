--[[ immunity ]]--
-- Read-only immunity detection.
-- Tracks which targets are immune to which abilities.
--
-- Key functions:
--   IsTargetImmune(ability) - Check if target is immune
--   TargetHasNoPockets() - Check if target has no pockets
--   IsSpellUninterruptible(spell) - Check if spell cannot be interrupted

if not RoRota then return end
if RoRota.immunity then return end

-- shared immunity groups
local immunity_groups = {
    bleed = {"Garrote", "Rupture"},
    stun = {"Kidney Shot"},
    incapacitate = {"Gouge", "Sap"},
}

-- targets that should not trigger immunity tracking
local banned_targets = {
    ["Apprentice Training Dummy"] = true,
    ["Expert Training Dummy"] = true,
    ["Heroic Training Dummy"] = true,
}

function RoRota:IsTargetImmune(abilityName)
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.immunities then
        return false
    end
    local targetName = UnitName("target")
    return RoRotaDB.immunities[targetName] and RoRotaDB.immunities[targetName][abilityName]
end

function RoRota:TargetHasNoPockets()
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.noPockets then
        return false
    end
    local targetName = UnitName("target")
    return RoRotaDB.noPockets[targetName]
end

function RoRota:ProcessImmunity(targetName, ability)
    if UnitIsPlayer("target") then return end
    if banned_targets[targetName] then return end
    
    if not RoRotaDB.immunities[targetName] then
        RoRotaDB.immunities[targetName] = {}
    end
    RoRotaDB.immunities[targetName][ability] = true
    for groupName, abilities in pairs(immunity_groups) do
        for _, groupAbility in ipairs(abilities) do
            if groupAbility == ability then
                for _, sharedAbility in ipairs(abilities) do
                    RoRotaDB.immunities[targetName][sharedAbility] = true
                end
                self:Print(targetName.." is immune to "..ability.." (and related abilities)")
                return
            end
        end
    end
    self:Print(targetName.." is immune to "..ability)
end

function RoRota:UsedSap()
    self.sapFailed = true
    self.sapFailTime = GetTime()
end

function RoRota:MarkTargetNoPockets()
    if not UnitExists("target") then return end
    local targetName = UnitName("target")
    if banned_targets[targetName] then return end
    if not RoRotaDB.noPockets then
        RoRotaDB.noPockets = {}
    end
    RoRotaDB.noPockets[targetName] = true
    self:Print(targetName.." has no pockets - will skip Pick Pocket")
end

function RoRota:OnErrorMessage(msg)
    if not msg then return end
    
    if UnitExists("target") and (string.find(msg, "no pockets") or string.find(msg, "can't be pick pocketed")) then
        self:MarkTargetNoPockets()
    end
    
    if string.find(msg, "immune") or string.find(msg, "resist") then
        if string.find(msg, "Sap") or self.sapFailed then
            self.sapFailed = true
            self.sapFailTime = GetTime()
        end
    end
end

function RoRota:IsSpellUninterruptible(spellName)
    if not spellName or not RoRotaDB or not RoRotaDB.uninterruptible then
        return false
    end
    return RoRotaDB.uninterruptible[spellName]
end

function RoRota:MarkSpellUninterruptible(spellName)
    if not spellName then return end
    if not RoRotaDB.uninterruptible then
        RoRotaDB.uninterruptible = {}
    end
    if not RoRotaDB.uninterruptible[spellName] then
        RoRotaDB.uninterruptible[spellName] = true
        self:Print("Spell '"..spellName.."' cannot be interrupted - will skip")
    end
end

-- clean banned targets from immunity database
function RoRota:CleanBannedTargets()
    if not RoRotaDB then return end
    local cleaned = false
    if RoRotaDB.immunities then
        for targetName in pairs(banned_targets) do
            if RoRotaDB.immunities[targetName] then
                RoRotaDB.immunities[targetName] = nil
                cleaned = true
            end
        end
    end
    if RoRotaDB.noPockets then
        for targetName in pairs(banned_targets) do
            if RoRotaDB.noPockets[targetName] then
                RoRotaDB.noPockets[targetName] = nil
                cleaned = true
            end
        end
    end
    if cleaned then
        self:Print("Cleaned training dummies from immunity database")
    end
end

-- mark module as loaded
RoRota.immunity = true
