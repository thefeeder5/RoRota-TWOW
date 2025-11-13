--[[ integration ]]--
-- SuperWoW and Nampower integration module.
-- Detects external addons and provides enhanced features when available.
--
-- Features:
--   - SuperWoW detection (extended buff/debuff timers, casting, threat)
--   - Nampower detection (precise energy tracking)
--   - Feature availability checks
--   - Graceful fallbacks when not available

RoRota.Integration = RoRota.Integration or {}

-- detect SuperWoW
function RoRota.Integration:HasSuperWoW()
    -- check for SUPERWOW_VERSION global
    if SUPERWOW_VERSION then
        return true
    end
    return false
end

-- detect Nampower
function RoRota.Integration:HasNampower()
    -- check for Nampower v2 CVar
    local has_nampower = pcall(GetCVar, "NP_QueueCastTimeSpells")
    return has_nampower
end

-- detect unitxp sp3
function RoRota.Integration:HasUnitXP()
    return UnitXP ~= nil
end

-- get energy with Nampower precision if available
function RoRota.Integration:GetEnergy()
    if self:HasNampower() and Nampower and Nampower.GetEnergy then
        return Nampower.GetEnergy()
    end
    return UnitMana("player")
end

-- get max energy with Nampower if available
function RoRota.Integration:GetMaxEnergy()
    if self:HasNampower() and Nampower and Nampower.GetMaxEnergy then
        return Nampower.GetMaxEnergy()
    end
    return RoRota:GetMaxEnergy()
end

-- print integration status
function RoRota.Integration:PrintStatus()
    local superWow = self:HasSuperWoW()
    local nampower = self:HasNampower()
    local unitxp = self:HasUnitXP()
    
    RoRota:Print("Integration Status:")
    RoRota:Print(string.format("  SuperWoW: %s", superWow and "|cFF00FF00Detected|r" or "|cFFFF0000Not Found|r"))
    RoRota:Print(string.format("  Nampower: %s", nampower and "|cFF00FF00Detected|r" or "|cFFFF0000Not Found|r"))
    RoRota:Print(string.format("  UnitXP: %s", unitxp and "|cFF00FF00Detected|r" or "|cFFFF0000Not Found|r"))
    
    if superWow then
        RoRota:Print("  - Enhanced buff/debuff timers active")
        RoRota:Print("  - Cast detection available")
        RoRota:Print("  - Threat API available")
    end
    
    if nampower then
        RoRota:Print("  - Precise energy tracking active")
    end
    
    if unitxp then
        RoRota:Print("  - Distance checking available")
    end
end

RoRotaIntegrationLoaded = true
