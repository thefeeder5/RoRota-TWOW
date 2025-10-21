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

function RoRota:CHAT_MSG_COMBAT_SELF_MISSES()
    -- Only track parries against the player ("You parry" or "Your attacks are parried")
    if string.find(arg1, "parry") and string.find(arg1, "You") then
        self.riposteAvailable = GetTime()
    end
end

function RoRota:CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES()
    -- Only track dodges by the player ("You dodge")
    if string.find(arg1, "dodge") and string.find(arg1, "You") then
        self.surpriseAttackAvailable = GetTime()
    end
end

function RoRota:CHAT_MSG_COMBAT_HOSTILE_DEATH()
    if self.OnCreatureSpellEvent then self:OnCreatureSpellEvent(arg1) end
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
end

-- Aura changes
function RoRota:UNIT_AURA()
    -- Cache will update on next rotation cycle
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

RoRota.events = true
