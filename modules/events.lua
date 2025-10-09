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
end

function RoRota:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE()
    if self.OnCreatureSpellEvent then self:OnCreatureSpellEvent(arg1) end
end

-- Error messages (immunity, no pockets)
function RoRota:UI_ERROR_MESSAGE()
    if self.OnErrorMessage then self:OnErrorMessage(arg1) end
end

-- Combat state
function RoRota:PLAYER_REGEN_DISABLED()
    if self.State then self.State:OnCombatStart() end
    if self.OnCombatStart then self:OnCombatStart() end
end

function RoRota:PLAYER_REGEN_ENABLED()
    if self.State then self.State:OnCombatEnd() end
    if self.CheckPendingSwitch then self:CheckPendingSwitch() end
end

-- Aura changes
function RoRota:UNIT_AURA()
    if arg1 == "player" or arg1 == "target" then
        if self.State then self.State:OnAuraChange() end
    end
end

-- Group state
function RoRota:PARTY_MEMBERS_CHANGED()
    if self.OnGroupStateChange then self:OnGroupStateChange() end
end

function RoRota:RAID_ROSTER_UPDATE()
    if self.OnGroupStateChange then self:OnGroupStateChange() end
end

RoRota.events = true
