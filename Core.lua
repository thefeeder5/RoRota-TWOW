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

-- Module State Variables
RoRota.targetCasting = false
RoRota.castingTimeout = 0
RoRota.sapFailed = false
RoRota.sapFailTime = 0
RoRota.lastPoisonApply = 0
RoRota.poisonApplyPending = nil
RoRota.poisonApplyTime = 0
RoRota.lastPoisonSlot = 17

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
    
    -- event registration
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
    
    -- slash command registration
    SLASH_ROROTA1 = "/rorota"
    SLASH_ROROTA2 = "/rr"
    SlashCmdList["ROROTA"] = function(msg)
        -- debug commands
        if msg == "checkbuffs" then
            if RoRota.HasWeaponPoison then
                local mh = RoRota:HasWeaponPoison(16)
                local oh = RoRota:HasWeaponPoison(17)
                RoRota:Print("MH has poison: "..(mh and "Yes" or "No"))
                RoRota:Print("OH has poison: "..(oh and "Yes" or "No"))
                RoRota:Print("Configured MH: "..(RoRota.db.profile.poisons.mainHandPoison or "None"))
                RoRota:Print("Configured OH: "..(RoRota.db.profile.poisons.offHandPoison or "None"))
            end
            return
        elseif msg == "scanbags" then
            if RoRota.ScanBagsForPoisons then
                RoRota:ScanBagsForPoisons()
                RoRota:Print("Poison cache:")
                for pType, data in pairs(RoRota.poisonCache) do
                    RoRota:Print(pType.." -> "..data.name.." (bag "..data.bag..", slot "..data.slot..")")
                end
            end
            return
        elseif msg == "testpoison" or msg == "poison" then
            if RoRota.CheckWeaponPoisons then
                RoRota:Print("Testing poison warnings...")
                RoRota:CheckWeaponPoisons(true)
                local hasMain, mainExp, mainCharges, hasOff, offExp, offCharges = GetWeaponEnchantInfo()
                mainExp = mainExp and (mainExp / 1000) or 0
                offExp = offExp and (offExp / 1000) or 0
                RoRota:Print("Main Hand: "..(hasMain and "Yes" or "No").." | Exp: "..math.floor(mainExp/60).."m | Charges: "..(mainCharges or 0))
                RoRota:Print("Off Hand: "..(hasOff and "Yes" or "No").." | Exp: "..math.floor(offExp/60).."m | Charges: "..(offCharges or 0))
                local db = RoRota.db.profile.poisons
                if db then
                    RoRota:Print("Settings: Enabled="..(db.enabled and "Yes" or "No").." | Time="..(db.timeThreshold or 0).."s | Charges="..(db.chargesThreshold or 0))
                end
            else
                RoRota:Print("Poison module not loaded")
            end
            return
        elseif msg == "preview" then
            if RoRota.CreateRotationPreview then
                RoRota:CreateRotationPreview()
                if RoRotaPreviewFrame then
                    if RoRotaPreviewFrame:IsVisible() then
                        RoRotaPreviewFrame:Hide()
                    else
                        RoRotaPreviewFrame:Show()
                    end
                end
            end
            return
        elseif msg == "debug on" then
            if RoRota.Debug then RoRota.Debug:SetEnabled(true) end
            return
        elseif msg == "debug off" then
            if RoRota.Debug then RoRota.Debug:SetEnabled(false) end
            return
        elseif msg == "trace on" then
            if RoRota.Debug then RoRota.Debug:SetTrace(true) end
            return
        elseif msg == "trace off" then
            if RoRota.Debug then RoRota.Debug:SetTrace(false) end
            return
        elseif msg == "state" then
            if RoRota.Debug then RoRota.Debug:ShowState() end
            return
        elseif msg == "logs" then
            if RoRota.Debug then RoRota.Debug:ShowLogs(20) end
            return
        elseif msg == "perf" then
            if RoRota.Debug then RoRota.Debug:ShowPerformance() end
            return
        elseif msg == "integration" or msg == "int" then
            if RoRota.Integration and RoRota.Integration.PrintStatus then
                RoRota.Integration:PrintStatus()
            else
                RoRota:Print("Integration module not loaded")
            end
            return
        elseif msg == "help" then
            RoRota:Print("=== RoRota Commands ===")
            RoRota:Print("/rr - Open settings")
            RoRota:Print("/rr preview - Toggle rotation preview")
            RoRota:Print("/rr integration - Show SuperWoW/Nampower status")
            RoRota:Print("/rr debug on/off - Toggle debug mode")
            RoRota:Print("/rr trace on/off - Toggle rotation trace")
            RoRota:Print("/rr state - Show current state")
            RoRota:Print("/rr logs - Show recent debug logs")
            RoRota:Print("/rr perf - Show performance stats")
            RoRota:Print("/rr poison - Test poison warnings")
            return
        end
        
        -- default: open GUI
        if not RoRotaGUIFrame then
            if RoRota.CreateGUI then
                RoRota:CreateGUI()
            else
                RoRota:Print("GUI module not loaded. Please /reload")
                return
            end
        end
        if RoRotaGUIFrame then
            RoRotaGUIFrame:Show()
        end
    end
    
    -- minimap button
    if self.CreateMinimapButton then
        self:CreateMinimapButton()
    end
    
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

-- Event Handlers

function RoRota:PARTY_MEMBERS_CHANGED()
    if self.OnGroupStateChange then
        self:OnGroupStateChange()
    end
end

function RoRota:RAID_ROSTER_UPDATE()
    if self.OnGroupStateChange then
        self:OnGroupStateChange()
    end
end

function RoRota:PLAYER_REGEN_DISABLED()
    if self.State then
        self.State:OnCombatStart()
    end
end

function RoRota:PLAYER_REGEN_ENABLED()
    if self.State then
        self.State:OnCombatEnd()
    end
    if self.CheckPendingSwitch then
        self:CheckPendingSwitch()
    end
end

function RoRota:UNIT_AURA()
    if arg1 == "player" or arg1 == "target" then
        if self.State then
            self.State:OnAuraChange()
        end
    end
end

function RoRota:UI_ERROR_MESSAGE()
    local msg = arg1
    if msg and (string.find(msg, "can't be pick pocketed") or string.find(msg, "no pockets") or string.find(msg, "nothing to steal")) then
        if self.MarkTargetNoPockets then
            self:MarkTargetNoPockets()
        end
    end
end
