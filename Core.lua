--[[ core ]]--
-- RoRota addon initialization and event registration.
-- This is the main entry point that loads the Ace2 framework and coordinates all modules.
--
-- Initialization:
--   OnInitialize()  - Register database and merge default profile
--   OnEnable()      - Class check, event registration, slash commands, minimap button
--   OnDisable()     - Cleanup on addon disable
--
-- Slash commands (handlers in modules/commands.lua):
--   /rr or /rorota  - Open settings GUI or execute debug commands
--   /rr help        - Show full command list

RoRota = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0")

-- Module State Variables
RoRota.targetCasting = false
RoRota.castingTimeout = 0
RoRota.sapFailed = false
RoRota.sapFailTime = 0
RoRota.lastPoisonApply = 0
RoRota.poisonApplyPending = nil
RoRota.poisonApplyTime = 0
RoRota.lastPoisonSlot = 17
RoRota.rotationReason = ""

-- Initialization

function RoRota:OnInitialize()
	self:RegisterDB("RoRotaDB")
	self:RegisterDefaults('profile', RoRotaDefaultProfile)
    
    -- deep merge existing profiles with default profile
    local function deepMerge(dst, src)
        if type(dst) ~= 'table' then dst = {} end
        if type(src) ~= 'table' then return dst end
        for k, v in pairs(src) do
            if type(v) == 'table' then
                dst[k] = deepMerge(dst[k], v)
            else
                if dst[k] == nil then dst[k] = v end
            end
        end
        return dst
    end
    if RoRotaDB and RoRotaDB.profiles then
        for name, profile in pairs(RoRotaDB.profiles) do
            RoRotaDB.profiles[name] = deepMerge(profile, RoRotaDefaultProfile)
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
    
    -- event registration (handlers in modules/events.lua)
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    self:RegisterEvent("CHARACTER_POINTS_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- initial talent scan
    if self.UpdateAllTalents then
        self:UpdateAllTalents()
    end
    
    -- minimap button
    if self.CreateMinimapButton then
        self:CreateMinimapButton()
    end
    
    -- slash command registration (must be after all modules load)
    -- use ScheduleEvent to delay until next frame
    self:ScheduleEvent(function()
        SLASH_ROROTA1 = "/rorota"
        SLASH_ROROTA2 = "/rr"
        SlashCmdList["ROROTA"] = function(msg)
            if RoRota.HandleSlashCommand then
                RoRota:HandleSlashCommand(msg)
            else
                RoRota:Print("Commands module not loaded")
            end
        end
    end, 0.1)
    
    -- poison check timer
    if self.CheckWeaponPoisons then
        self:ScheduleRepeatingEvent("RoRotaPoisonCheck", self.CheckWeaponPoisons, 30, self)
    end

    -- tooltip fix: prevent nil owner crashes from other addons
    if GameTooltip and type(GameTooltip.SetOwner) == "function" then
        if hooksecurefunc then
            hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
                if not owner then
                    pcall(function() GameTooltip:Hide() end)
                end
            end)
        else
            local origSetOwner = GameTooltip.SetOwner
            GameTooltip.SetOwner = function(self, owner, anchor)
                if not owner then
                    pcall(function() GameTooltip:Hide() end)
                    return
                end
                return origSetOwner(self, owner, anchor)
            end
        end
    end
end

function RoRota:OnDisable()
    self:Print("RoRota disabled.")
end
