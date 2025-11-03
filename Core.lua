--[[ core ]]--
-- RoRota addon initialization, event registration, and slash commands.
-- This is the main entry point that loads the Ace2 framework and coordinates all modules.
--
-- Initialization:
--   OnInitialize()  - Register database and merge default profile
--   OnEnable()      - Class check, event registration, slash commands, minimap button
--   OnDisable()     - Cleanup on addon disable
--
-- Slash commands:
--   /rr or /rorota           - Open settings GUI
--   /rr preview              - Toggle rotation preview window
--   /rr debug on/off         - Toggle debug mode
--   /rr trace on/off         - Toggle rotation trace logging
--   /rr state                - Show cached state values
--   /rr logs                 - Show recent debug logs
--   /rr perf                 - Show performance statistics
--   /rr poison               - Test poison warnings
--   /rr help                 - Show command list

RoRota = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0")

-- Extract version from .toc file
RoRota.version = GetAddOnMetadata("RoRota-TWOW", "Version") or "Unknown"

-- Module State Variables
RoRota.targetCasting = false
RoRota.castingTimeout = 0
RoRota.sapFailed = false
RoRota.sapFailTime = 0
RoRota.riposteAvailable = 0
RoRota.surpriseAttackAvailable = 0
RoRota.lastPoisonApply = 0
RoRota.poisonApplyPending = nil
RoRota.poisonApplyTime = 0
RoRota.lastPoisonSlot = 17
RoRota.lastAbilityCast = nil
RoRota.lastAbilityTime = 0

-- Initialization

function RoRota:OnInitialize()
	self:RegisterDB("RoRotaDB")
	self:RegisterDefaults('profile', RoRotaDefaultProfile)
    
    -- deep merge existing profiles with default profile
    if RoRotaDB and RoRotaDB.profiles then
        for name, profile in pairs(RoRotaDB.profiles) do
            RoRotaDB.profiles[name] = self:DeepMerge(profile, RoRotaDefaultProfile)
        end
    end
end

function RoRota:OnEnable()
    -- class check: disable if not rogue
    local _, class = UnitClass("player")
    if class ~= "ROGUE" then
        self:Print("RoRota is only for Rogues. Addon disabled.")
        self:Disable()
        return
    end
    
    self:Print("RoRota enabled. Type /rorota or /rr to open settings.")
    
    -- initialize database tables
    if not RoRotaDB.immunities then
        RoRotaDB.immunities = {}
    end
    if not RoRotaDB.noPockets then
        RoRotaDB.noPockets = {}
    end
    if not RoRotaDB.uninterruptible then
        RoRotaDB.uninterruptible = {}
    end
    if not RoRotaDB.immunityBuffs then
        RoRotaDB.immunityBuffs = {}
    end
    
    -- event registration (handlers in modules/events.lua)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHARACTER_POINTS_CHANGED")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_DMGSHIELDS_ON_OTHERS")
    self:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
    self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
    self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    
    -- slash command registration (handlers in modules/commands.lua)
    if self.RegisterSlashCommands then
        self:RegisterSlashCommands()
    end
    
    -- initialize rotation cache
    if self.UpdateRotationCache then
        self:UpdateRotationCache()
    end
    
    -- minimap button
    if self.CreateMinimapButton then
        self:CreateMinimapButton()
    end
    
    -- poison check timer
    if self.CheckWeaponPoisons then
        self:ScheduleRepeatingEvent("RoRotaPoisonCheck", self.CheckWeaponPoisons, 30, self)
    end
    
    -- compatibility fixes (in modules/fixes.lua)
    if self.ApplyCompatibilityFixes then
        self:ApplyCompatibilityFixes()
    end
end

function RoRota:OnDisable()
    self:Print("RoRota disabled.")
end
