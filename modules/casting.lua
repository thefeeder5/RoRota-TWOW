--[[ casting ]]--
-- Read-only target casting detection.
-- Detects enemy casting via SuperWoW API or combat log fallback.
--
-- Key functions:
--   IsTargetCasting() - Check if target is casting
--   OnCastingEvent() - Handle casting events (called by events.lua)

if not RoRota then return end
if RoRota.casting then return end

RoRota.currentTargetSpell = nil
RoRota.lastInterruptAttempt = 0
RoRota.spellTracking = {}  -- GUID-based spell tracking

function RoRota:IsTargetCasting()
    return self:IsUnitCasting("target")
end

-- Check if unit is casting (optionally check for specific spell)
function RoRota:IsUnitCasting(unit, spellName)
    if not UnitExists(unit) then return false end
    
    -- SuperWoW API: check for regular casts
    if UnitCastingInfo then
        local spell = UnitCastingInfo(unit)
        if spell then
            if not spellName then return true end
            return spell == spellName
        end
    end
    
    -- SuperWoW API: check for channeled spells
    if UnitChannelInfo then
        local spell = UnitChannelInfo(unit)
        if spell then
            if not spellName then return true end
            return spell == spellName
        end
    end
    
    -- Fallback: GUID-based tracking
    local _, guid = UnitExists(unit)
    if guid and self.spellTracking[guid] then
        local tracking = self.spellTracking[guid]
        -- Timeout after 10 seconds
        if GetTime() - tracking.startTime > 10 then
            self.spellTracking[guid] = nil
            return false
        end
        
        if not spellName then return true end
        
        -- Check specific spell
        if tracking.spellId and SpellInfo then
            return SpellInfo(tracking.spellId) == spellName
        end
        
        return tracking.spellName == spellName
    end
    
    -- Legacy fallback for target only
    if unit == "target" and self.targetCasting then
        if GetTime() > self.castingTimeout then
            self.targetCasting = false
            return false
        end
        if not spellName then return true end
        return self.currentTargetSpell == spellName
    end
    
    return false
end

-- Event Handlers (called from events.lua router)

function RoRota:OnCastingEvent(eventType, msg)
    if not UnitExists("target") or not msg then return end
    local targetName = UnitName("target")
    
    if string.find(msg, targetName) and string.find(msg, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
        
        -- Extract spell name
        local spellName = string.match(msg, "begins to cast (.+)%.")
        if spellName then
            self.currentTargetSpell = spellName
            
            -- Store in GUID tracking
            local _, guid = UnitExists("target")
            if guid then
                self.spellTracking[guid] = {
                    spellName = spellName,
                    startTime = GetTime()
                }
            end
        end
    end
end

function RoRota:OnSelfSpellEvent(msg)
    if not UnitExists("target") or not msg then return end
    local targetName = UnitName("target")
    
    if string.find(msg, "interrupts") and (string.find(msg, "Kick") or string.find(msg, "Gouge") or string.find(msg, "Kidney Shot")) then
        self.targetCasting = false
        self.castingTimeout = 0
        self.currentTargetSpell = nil
        
        -- Clear GUID tracking
        local _, guid = UnitExists("target")
        if guid then
            self.spellTracking[guid] = nil
        end
    end
    
    if (string.find(msg, "Kick") or string.find(msg, "Gouge") or string.find(msg, "Kidney Shot")) then
        self.lastInterruptAttempt = GetTime()
    end
    
    if string.find(msg, "failed") and string.find(msg, "immune") then
        for ability in string.gmatch(msg, "Your (.+) failed") do
            self:ProcessImmunity(targetName, ability)
        end
    end
end

function RoRota:OnCreatureSpellEvent(msg)
    if not msg then return end
    
    if self.lastInterruptAttempt > 0 and GetTime() - self.lastInterruptAttempt < 1.5 then
        if self.currentTargetSpell and self.targetCasting then
            self:MarkSpellUninterruptible(self.currentTargetSpell)
            self.currentTargetSpell = nil
            self.lastInterruptAttempt = 0
        end
    end
    
    if self.sapFailed and GetTime() - self.sapFailTime < 2 then
        self.sapFailed = true
    end
end

function RoRota:OnCombatStart()
    if self.sapFailed and GetTime() - self.sapFailTime < 3 then
        local action = self.db.profile.opener.sapFailAction
        if action and action ~= "None" then
            if action == "Vanish" and self:HasSpell("Vanish") and not self:IsOnCooldown("Vanish") then
                CastSpellByName("Vanish")
                self:Print("Sap failed! Using Vanish")
            elseif action == "Sprint" and self:HasSpell("Sprint") and not self:IsOnCooldown("Sprint") then
                CastSpellByName("Sprint")
                self:Print("Sap failed! Using Sprint")
            elseif action == "Evasion" and self:HasSpell("Evasion") and not self:IsOnCooldown("Evasion") then
                CastSpellByName("Evasion")
                self:Print("Sap failed! Using Evasion")
            end
        end
        self.sapFailed = false
    end
end

-- mark module as loaded
RoRota.casting = true
