--[[ immunity ]]--
-- Immunity tracking and Sap fail handling.
-- Tracks which targets are immune to which abilities.

-- return instantly if already loaded
if RoRota.immunity then return end

-- NPCs to ignore for immunity tracking (training dummies)
local ignored_npcs = {
    ["Apprentice Training Dummy"] = true,
    ["Expert Training Dummy"] = true,
    ["Heroic Training Dummy"] = true,
}

-- shared immunity groups
local immunity_groups = {
    bleed = {"Garrote", "Rupture"},
    stun = {"Cheap Shot", "Kidney Shot"},
    incapacitate = {"Gouge", "Sap"},
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
    if UnitIsPlayer("target") or ignored_npcs[targetName] then return end
    
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
    if ignored_npcs[targetName] then return end
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
    
    if self.OnOpenerError then
        self:OnOpenerError(msg)
    end
    
    if self.OnBuilderError then
        self:OnBuilderError(msg)
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

function RoRota:CleanupIgnoredNPCs()
    if not RoRotaDB then return end
    if RoRotaDB.immunities then
        for npcName in pairs(ignored_npcs) do
            RoRotaDB.immunities[npcName] = nil
        end
    end
    if RoRotaDB.noPockets then
        for npcName in pairs(ignored_npcs) do
            RoRotaDB.noPockets[npcName] = nil
        end
    end
end

-- mark module as loaded
RoRota.immunity = true
