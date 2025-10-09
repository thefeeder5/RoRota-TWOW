--[[ casting ]]--
-- Cast detection and combat log event handlers.
-- Tracks enemy casting and handles immunity/Sap fail detection.

-- return instantly if already loaded
if RoRota.casting then return end

RoRota.currentTargetSpell = nil
RoRota.lastInterruptAttempt = 0

function RoRota:IsTargetCasting()
    -- SuperWoW API: check for regular casts
    if UnitCastingInfo then
        local spell = UnitCastingInfo("target")
        if spell then return true end
    end
    -- SuperWoW API: check for channeled spells
    if UnitChannelInfo then
        local spell = UnitChannelInfo("target")
        if spell then return true end
    end
    -- fallback: combat log tracking with 3-second timeout
    if RoRota.targetCasting and GetTime() > RoRota.castingTimeout then
        RoRota.targetCasting = false
    end
    return RoRota.targetCasting or false
end

-- Event Handlers (called from events.lua router)

function RoRota:OnCastingEvent(eventType, msg)
    if not UnitExists("target") or not msg then return end
    if string.find(msg, UnitName("target")) and string.find(msg, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
        if eventType == "BUFF" then
            for spell in string.gmatch(msg, "begins to cast (.+)%.") do
                self.currentTargetSpell = spell
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
