--[[ immunity ]]--
-- Immunity tracking and Sap fail handling.
-- Tracks which targets are immune to which abilities.

-- return instantly if already loaded
if RoRota.immunity then return end

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
    if not RoRotaDB.noPockets then
        RoRotaDB.noPockets = {}
    end
    RoRotaDB.noPockets[targetName] = true
end

-- mark module as loaded
RoRota.immunity = true
