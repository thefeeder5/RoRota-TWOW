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
    stun = {"Kidney Shot", "Cheap Shot"},
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
    
    -- Check if ignored for this immunity group
    if not RoRotaDB.immunityIgnored then RoRotaDB.immunityIgnored = {} end
    for groupName, abilities in pairs(immunity_groups) do
        for _, groupAbility in ipairs(abilities) do
            if groupAbility == ability then
                if RoRotaDB.immunityIgnored[groupName] and RoRotaDB.immunityIgnored[groupName][targetName] then
                    return
                end
                break
            end
        end
    end
    
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
    self:Print(targetName.." has no pockets - will skip Pick Pocket")
end

function RoRota:OnErrorMessage(msg)
    if not msg then return end
    
    -- Debug: print all error messages (remove this after testing)
    -- self:Print("Error: "..msg)
    
    if UnitExists("target") and (string.find(msg, "no pockets") or string.find(msg, "can't be pick pocketed")) then
        self:MarkTargetNoPockets()
    end
    
    if string.find(msg, "immune") then
        if not UnitExists("target") then return end
        local targetName = UnitName("target")
        
        -- Use last ability cast if within 1 second
        if self.lastAbilityCast and (GetTime() - self.lastAbilityTime) < 1 then
            self:ProcessImmunity(targetName, self.lastAbilityCast)
        elseif string.find(msg, "Sap") or self.sapFailed then
            self.sapFailed = true
            self.sapFailTime = GetTime()
            self:ProcessImmunity(targetName, "Sap")
        end
    end
end

function RoRota:IsSpellUninterruptible(spellName)
    if not spellName or not RoRotaDB or not RoRotaDB.uninterruptible or not UnitExists("target") then
        return false
    end
    local targetName = UnitName("target")
    return RoRotaDB.uninterruptible[targetName] and RoRotaDB.uninterruptible[targetName][spellName]
end

function RoRota:MarkSpellUninterruptible(spellName)
    if not spellName or not UnitExists("target") then return end
    local targetName = UnitName("target")
    if not RoRotaDB.uninterruptible then
        RoRotaDB.uninterruptible = {}
    end
    if not RoRotaDB.uninterruptible[targetName] then
        RoRotaDB.uninterruptible[targetName] = {}
    end
    if not RoRotaDB.uninterruptible[targetName][spellName] then
        RoRotaDB.uninterruptible[targetName][spellName] = true
        self:Print(targetName.."'s '"..spellName.."' cannot be interrupted - will skip")
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

-- Remove target from immunity list
function RoRota:RemoveImmunity(targetName)
    if not RoRotaDB or not RoRotaDB.immunities then return end
    if targetName then
        if RoRotaDB.immunities[targetName] then
            RoRotaDB.immunities[targetName] = nil
            self:Print("Removed '"..targetName.."' from immunity list")
        else
            self:Print("'"..targetName.."' not found in immunity list")
        end
    else
        if UnitExists("target") then
            local name = UnitName("target")
            if RoRotaDB.immunities[name] then
                RoRotaDB.immunities[name] = nil
                self:Print("Removed '"..name.."' from immunity list")
            else
                self:Print("'"..name.."' not found in immunity list")
            end
        else
            self:Print("No target selected")
        end
    end
end

-- Clear entire immunity list
function RoRota:ClearImmunities()
    if not RoRotaDB then return end
    RoRotaDB.immunities = {}
    self:Print("Cleared all immunities")
end

-- List all immune targets
function RoRota:ListImmunities()
    if not RoRotaDB or not RoRotaDB.immunities then
        self:Print("No immunities recorded")
        return
    end
    local count = 0
    for targetName, abilities in pairs(RoRotaDB.immunities) do
        count = count + 1
        local abilityList = ""
        for ability in pairs(abilities) do
            abilityList = abilityList .. ability .. ", "
        end
        abilityList = string.sub(abilityList, 1, -3)
        self:Print(targetName .. ": " .. abilityList)
    end
    if count == 0 then
        self:Print("No immunities recorded")
    end
end

-- Ignore target for specific immunity group
function RoRota:IgnoreImmunity(targetName, groupName)
    if not RoRotaDB then return end
    if not RoRotaDB.immunityIgnored then RoRotaDB.immunityIgnored = {} end
    if not RoRotaDB.immunityIgnored[groupName] then RoRotaDB.immunityIgnored[groupName] = {} end
    
    RoRotaDB.immunityIgnored[groupName][targetName] = true
    
    -- Remove from immunity database
    if RoRotaDB.immunities and RoRotaDB.immunities[targetName] then
        local groupAbilities = immunity_groups[groupName]
        if groupAbilities then
            for _, ability in ipairs(groupAbilities) do
                RoRotaDB.immunities[targetName][ability] = nil
            end
        end
    end
    
    self:Print("Ignored '"..targetName.."' for "..groupName.." immunity")
end

-- Unignore target for specific immunity group
function RoRota:UnignoreImmunity(targetName, groupName)
    if not RoRotaDB or not RoRotaDB.immunityIgnored then return end
    if not RoRotaDB.immunityIgnored[groupName] then return end
    
    if RoRotaDB.immunityIgnored[groupName][targetName] then
        RoRotaDB.immunityIgnored[groupName][targetName] = nil
        self:Print("Unignored '"..targetName.."' for "..groupName.." immunity")
    end
end

-- Get ignored targets for specific group
function RoRota:GetIgnoredTargets(groupName)
    if not RoRotaDB or not RoRotaDB.immunityIgnored then return {} end
    if not RoRotaDB.immunityIgnored[groupName] then return {} end
    
    local targets = {}
    for targetName in pairs(RoRotaDB.immunityIgnored[groupName]) do
        table.insert(targets, targetName)
    end
    table.sort(targets)
    return targets
end

-- Get targets immune to specific group
function RoRota:GetImmuneTargets(groupName)
    if not RoRotaDB or not RoRotaDB.immunities then return {} end
    local targets = {}
    local groupAbilities = immunity_groups[groupName]
    if not groupAbilities then return {} end
    
    for targetName, abilities in pairs(RoRotaDB.immunities) do
        for _, ability in ipairs(groupAbilities) do
            if abilities[ability] then
                table.insert(targets, targetName)
                break
            end
        end
    end
    
    table.sort(targets)
    return targets
end

-- Manually add target to immunity group
function RoRota:AddImmunity(targetName, groupName)
    if not RoRotaDB then return end
    if not RoRotaDB.immunities then RoRotaDB.immunities = {} end
    
    if not targetName and UnitExists("target") then
        targetName = UnitName("target")
    end
    
    if not targetName then
        self:Print("No target specified")
        return
    end
    
    local groupAbilities = immunity_groups[groupName]
    if not groupAbilities then
        self:Print("Invalid immunity group: "..groupName)
        return
    end
    
    if not RoRotaDB.immunities[targetName] then
        RoRotaDB.immunities[targetName] = {}
    end
    
    for _, ability in ipairs(groupAbilities) do
        RoRotaDB.immunities[targetName][ability] = true
    end
    
    self:Print("Added '"..targetName.."' to "..groupName.." immunity")
end

-- mark module as loaded
RoRota.immunity = true
