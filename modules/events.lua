--[[ events ]]--
-- Central event router that delegates to appropriate modules.
-- Keeps Core.lua clean by routing events to their logical owners.

if RoRota.events then return end

-- Casting events (CHAT_MSG_SPELL_*)
function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF()
    if self.OnCastingEvent then self:OnCastingEvent("BUFF", arg1) end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE()
    if self.OnCastingEvent then self:OnCastingEvent("DAMAGE", arg1) end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF()
    if self.OnCastingEvent then self:OnCastingEvent("BUFF", arg1) end
end

function RoRota:CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE()
    if self.OnCastingEvent then self:OnCastingEvent("DAMAGE", arg1) end
end

function RoRota:CHAT_MSG_SPELL_SELF_DAMAGE()
    if self.OnSelfSpellEvent then self:OnSelfSpellEvent(arg1) end
    
    -- Detect successful interrupts
    if string.find(arg1, "interrupted") or string.find(arg1, "Interrupt") then
        local targetName = UnitName("target")
        local spellName = self.currentTargetSpell or (self.interruptState and self.interruptState.lastInterruptedSpell)
        if targetName and spellName and self.StoreInterruptedSpell then
            self:StoreInterruptedSpell(targetName, spellName)
        end
    end
    
    -- Detect Vanish cast for Vanish opener mode
    if string.find(arg1, "Vanish") and self.SetVanishOpenerMode then
        self:SetVanishOpenerMode()
        
        -- Swap equipment if configured
        local vanishCfg = self.db and self.db.profile and self.db.profile.vanishOpener
        if vanishCfg and vanishCfg.equipmentSet and self.Equipment then
            self.Equipment:SwapToSet(vanishCfg.equipmentSet)
        end
    end
    
    if self.OnBuilderCast and self.db and self.db.profile then
        local mainBuilder = self.db.profile.mainBuilder
        local secondaryBuilder = self.db.profile.secondaryBuilder
        if mainBuilder and string.find(arg1, mainBuilder) then
            self:OnBuilderCast(mainBuilder)
        elseif secondaryBuilder and string.find(arg1, secondaryBuilder) then
            self:OnBuilderCast(secondaryBuilder)
        end
    end
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE()
    if self.OnCreatureSpellEvent then self:OnCreatureSpellEvent(arg1) end
end

function RoRota:CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS()
    -- Suppress spam from damage shields (thorns, etc)
end

function RoRota:CHAT_MSG_COMBAT_SELF_MISSES()
    if string.find(arg1, "You parry") then
        if not self.ReactiveAbilities then self.ReactiveAbilities = {} end
        self.ReactiveAbilities.riposteUntil = GetTime() + 5
    end
end

function RoRota:CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES()
    if string.find(arg1, "You dodge") then
        if not self.ReactiveAbilities then self.ReactiveAbilities = {} end
        self.ReactiveAbilities.surpriseUntil = GetTime() + 5
    end
end

function RoRota:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if self.OnCreatureSpellEvent then self:OnCreatureSpellEvent(arg1) end
end

function RoRota:CHAT_MSG_SPELL_AURA_GONE_OTHER()
    -- Detect interrupts via aura removal
    if self.Debug and self.Debug.enabled then
        if string.find(arg1, "interrupted") or string.find(arg1, "Interrupt") then
            self.Debug:Log("[INTERRUPT] AURA_GONE_OTHER: " .. arg1)
        end
    end
    if string.find(arg1, "interrupted") or string.find(arg1, "Interrupt") then
        local targetName = UnitName("target")
        local spellName = self.currentTargetSpell or (self.interruptState and self.interruptState.lastInterruptedSpell)
        if targetName and spellName and self.StoreInterruptedSpell then
            self:StoreInterruptedSpell(targetName, spellName)
        end
    end
end

function RoRota:UI_ERROR_MESSAGE()
    if self.OnErrorMessage then self:OnErrorMessage(arg1) end
    
    -- Track positioning errors
    if string.find(arg1, "must be") and (string.find(arg1, "behind") or string.find(arg1, "front")) then
        -- Check if in stealth (opener error) or not (builder error)
        local isStealthed = self.Cache and self.Cache.stealthed or false
        if isStealthed and self.OnOpenerPositionError then
            self:OnOpenerPositionError()
        elseif not isStealthed and self.OnBuilderPositionError then
            self:OnBuilderPositionError()
        end
    end
end

-- Combat state
function RoRota:PLAYER_REGEN_DISABLED()
    if self.OnCombatStart then self:OnCombatStart() end
end

function RoRota:PLAYER_REGEN_ENABLED()
    if self.CheckPendingSwitch then self:CheckPendingSwitch() end
    if self.ResetTTKTracking then
        local success, err = pcall(self.ResetTTKTracking, self)
        if not success then
            -- Silent fail
        end
    end
end

-- Aura changes
function RoRota:UNIT_AURA()
    if arg1 == "player" then
        local isStealthed = self.HasPlayerBuff and self:HasPlayerBuff("Stealth") or false
        
        if isStealthed and not UnitAffectingCombat("player") then
            local openerCfg = self.db and self.db.profile and self.db.profile.opener
            if openerCfg and openerCfg.equipmentSet and openerCfg.equipmentSet ~= "" and self.Equipment then
                self.Equipment:SwapToSet(openerCfg.equipmentSet)
            end
        end
    end
end

-- Group state
function RoRota:PARTY_MEMBERS_CHANGED()
    if self.OnGroupStateChange then self:OnGroupStateChange() end
end

function RoRota:RAID_ROSTER_UPDATE()
    if self.OnGroupStateChange then self:OnGroupStateChange() end
end

-- Talent updates
function RoRota:PLAYER_ENTERING_WORLD()
    if self.UpdateAllTalents then self:UpdateAllTalents() end
end

function RoRota:CHARACTER_POINTS_CHANGED()
    if self.UpdateAllTalents then self:UpdateAllTalents() end
end

-- SuperWoW UNIT_CASTEVENT
function RoRota:UNIT_CASTEVENT()
    if self.CombatLog then
        self.CombatLog:OnUnitCastEvent(arg1, arg2, arg3, arg4, arg5)
    end
end

-- Equipment swapping
function RoRota:ITEM_LOCK_CHANGED()
    if self.Equipment then
        self.Equipment:OnItemLockChanged()
    end
end

RoRota.events = true
