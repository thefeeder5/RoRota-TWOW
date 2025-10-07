-- RoRota Core.lua
-- Minimal addon initialization and event registration

RoRota = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0")

function RoRota:OnInitialize()
	self:RegisterDB("RoRotaDB")
	self:RegisterDefaults('profile', RoRotaDefaultProfile)
    -- Ensure any existing profiles gain missing keys from DEFAULT_PROFILE
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

RoRota.targetCasting = false
RoRota.castingTimeout = 0
RoRota.sapFailed = false
RoRota.sapFailTime = 0
RoRota.lastPoisonApply = 0
RoRota.poisonApplyPending = nil
RoRota.poisonApplyTime = 0
RoRota.lastPoisonSlot = 17

function RoRota:OnEnable()
    self:Print("RoRota enabled. Type /rorota or /rr to open settings.")
    
    if not RoRotaDB.immunities then
        RoRotaDB.immunities = {}
    end
    if not RoRotaDB.noPockets then
        RoRotaDB.noPockets = {}
    end
    
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
    self:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
    self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")
    self:RegisterEvent("UI_ERROR_MESSAGE")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self:RegisterEvent("RAID_ROSTER_UPDATE")
    
    SLASH_ROROTA1 = "/rorota"
    SLASH_ROROTA2 = "/rr"
    SlashCmdList["ROROTA"] = function(msg)
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
        end
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
    
    if self.CreateMinimapButton then
        self:CreateMinimapButton()
    end
    
    if self.CheckWeaponPoisons then
        self:ScheduleRepeatingEvent("RoRotaPoisonCheck", self.CheckWeaponPoisons, 30, self)
    end

    -- Install a defensive hook for GameTooltip:SetOwner to avoid other addons
    -- leaving GameTooltip in an inconsistent state (owner == nil). We do this
    -- non-invasively via hooksecurefunc so we don't change other libs.
    if GameTooltip and type(GameTooltip.SetOwner) == "function" then
        -- use hooksecurefunc if available (safe); otherwise fallback to wrapping
        if hooksecurefunc then
            hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
                -- if owner is nil, hide tooltip immediately to avoid downstream nil-owner usage
                if not owner then
                    pcall(function() GameTooltip:Hide() end)
                end
            end)
        else
            -- Older environments without hooksecurefunc are rare; best-effort wrap
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

function RoRota:PLAYER_REGEN_ENABLED()
    if self.CheckPendingSwitch then
        self:CheckPendingSwitch()
    end
end
