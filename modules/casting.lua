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

-- Event Handlers

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
        -- extract spell name
        for spell in string.gmatch(arg1, "begins to cast (.+)%.") do
            self.currentTargetSpell = spell
        end
    end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE()
    if UnitExists("target") and arg1 and string.find(arg1, UnitName("target")) and string.find(arg1, "begins to cast") then
        self.targetCasting = true
        self.castingTimeout = GetTime() + 3
    end
end

function RoRota:CHAT_MSG_SPELL_SELF_DAMAGE()
    if not UnitExists("target") or not arg1 then return end
    local targetName = UnitName("target")
    
    -- detect successful interrupt
    if string.find(arg1, "interrupts") and (string.find(arg1, "Kick") or string.find(arg1, "Gouge") or string.find(arg1, "Kidney Shot")) then
        self.targetCasting = false
        self.castingTimeout = 0
        self.currentTargetSpell = nil
    end
    
    -- detect failed interrupt (spell still casting after kick)
    if (string.find(arg1, "Kick") or string.find(arg1, "Gouge") or string.find(arg1, "Kidney Shot")) then
        self.lastInterruptAttempt = GetTime()
    end
    
    -- detect immunity
    if string.find(arg1, "failed") and string.find(arg1, "immune") then
        for ability in string.gmatch(arg1, "Your (.+) failed") do
            self:ProcessImmunity(targetName, ability)
        end
    end
end

function RoRota:UI_ERROR_MESSAGE()
    if not arg1 then return end
    if UnitExists("target") and (string.find(arg1, "no pockets") or string.find(arg1, "can't be pick pocketed")) then
        local targetName = UnitName("target")
        RoRotaDB.noPockets[targetName] = true
        self:Print(targetName.." has no pockets - will skip Pick Pocket")
    end
    if string.find(arg1, "immune") or string.find(arg1, "resist") then
        if string.find(arg1, "Sap") or self.sapFailed then
            self.sapFailed = true
            self.sapFailTime = GetTime()
        end
    end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE()
    if not arg1 then return end
    
    -- detect spell completion after interrupt attempt (uninterruptible)
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

function RoRota:PLAYER_REGEN_DISABLED()
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
