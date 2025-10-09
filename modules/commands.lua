--[[ commands ]]--
-- Slash command handlers for RoRota.
-- Handles all /rr and /rorota commands for debugging, testing, and configuration.

if not RoRota then return end
if RoRota.commands then return end

function RoRota:HandleSlashCommand(msg)
    -- debug commands
    if msg == "checkbuffs" then
        if self.HasWeaponPoison then
            local mh = self:HasWeaponPoison(16)
            local oh = self:HasWeaponPoison(17)
            self:Print("MH has poison: "..(mh and "Yes" or "No"))
            self:Print("OH has poison: "..(oh and "Yes" or "No"))
            self:Print("Configured MH: "..(self.db.profile.poisons.mainHandPoison or "None"))
            self:Print("Configured OH: "..(self.db.profile.poisons.offHandPoison or "None"))
        end
        return
    elseif msg == "scanbags" then
        if self.ScanBagsForPoisons then
            self:ScanBagsForPoisons()
            self:Print("Poison cache:")
            for pType, data in pairs(self.poisonCache) do
                self:Print(pType.." -> "..data.name.." (bag "..data.bag..", slot "..data.slot..")")
            end
        end
        return
    elseif msg == "testpoison" or msg == "poison" then
        if self.CheckWeaponPoisons then
            self:Print("Testing poison warnings...")
            self:CheckWeaponPoisons(true)
            local hasMain, mainExp, mainCharges, hasOff, offExp, offCharges = GetWeaponEnchantInfo()
            mainExp = mainExp and (mainExp / 1000) or 0
            offExp = offExp and (offExp / 1000) or 0
            self:Print("Main Hand: "..(hasMain and "Yes" or "No").." | Exp: "..math.floor(mainExp/60).."m | Charges: "..(mainCharges or 0))
            self:Print("Off Hand: "..(hasOff and "Yes" or "No").." | Exp: "..math.floor(offExp/60).."m | Charges: "..(offCharges or 0))
            local db = self.db.profile.poisons
            if db then
                self:Print("Settings: Enabled="..(db.enabled and "Yes" or "No").." | Time="..(db.timeThreshold or 0).."s | Charges="..(db.chargesThreshold or 0))
            end
        else
            self:Print("Poison module not loaded")
        end
        return
    elseif msg == "preview" then
        if self.CreateRotationPreview then
            self:CreateRotationPreview()
            if RoRotaPreviewFrame then
                if RoRotaPreviewFrame:IsVisible() then
                    RoRotaPreviewFrame:Hide()
                else
                    RoRotaPreviewFrame:Show()
                end
            end
        end
        return
    elseif msg == "debug on" or msg == "debug" then
        if self.Debug then
            self.Debug:SetEnabled(true)
            self.Debug:SetTrace(true)
            if RoRotaPreviewFrame then
                RoRotaPreviewFrame.debugMode = true
                RoRotaPreviewFrame:SetHeight(220)
            end
        end
        return
    elseif msg == "debug off" then
        if self.Debug then
            self.Debug:SetEnabled(false)
            self.Debug:SetTrace(false)
            if RoRotaPreviewFrame then
                RoRotaPreviewFrame.debugMode = false
                RoRotaPreviewFrame:SetHeight(150)
            end
        end
        return
    elseif msg == "state" then
        if self.Debug then self.Debug:ShowState() end
        return
    elseif msg == "logs" then
        if self.Debug then self.Debug:ShowLogs(20) end
        return
    elseif msg == "perf" then
        if self.Debug then self.Debug:ShowPerformance() end
        return
    elseif msg == "integration" or msg == "int" then
        if self.Integration and self.Integration.PrintStatus then
            self.Integration:PrintStatus()
        else
            self:Print("Integration module not loaded")
        end
        return
    elseif msg == "icons" then
        self:Print("=== Rogue Ability Icons ===")
        local i = 1
        while true do
            local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
            if not name then break end
            local spellTexture = GetSpellTexture(i, BOOKTYPE_SPELL)
            if spellTexture then
                self:Print(name.." = \""..spellTexture.."\"")
            end
            i = i + 1
        end
        return
    elseif msg == "debuffs" then
        if not UnitExists("target") then
            self:Print("No target selected")
            return
        end
        self:Print("=== Target Debuffs (Raw) ===")
        local i = 1
        while UnitDebuff("target", i) do
            local texture, stacks, debuffType, duration, timeLeft = UnitDebuff("target", i)
            if not RoRotaTooltip then
                CreateFrame("GameTooltip", "RoRotaTooltip", nil, "GameTooltipTemplate")
                RoRotaTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
            end
            RoRotaTooltip:ClearLines()
            RoRotaTooltip:SetUnitDebuff("target", i)
            local tooltipText = RoRotaTooltipTextLeft1:GetText()
            self:Print(string.format("%d: %s", i, tooltipText or "nil"))
            self:Print(string.format("   timeLeft=%s, duration=%s", tostring(timeLeft), tostring(duration)))
            self:Print(string.format("   texture=%s", texture or "nil"))
            i = i + 1
        end
        self:Print("=== GetDebuffTimeRemaining ===")
        if self.GetDebuffTimeRemaining then
            local eaTime = self:GetDebuffTimeRemaining("Expose Armor")
            local ruptTime = self:GetDebuffTimeRemaining("Rupture")
            self:Print("Expose Armor: "..eaTime.."s")
            self:Print("Rupture: "..ruptTime.."s")
        end
        return
    elseif msg == "talents" then
        if self.UpdateCPTalents then
            self:UpdateCPTalents()
            local t = self.CPTalents
            self:Print("=== CP Talents ===")
            DEFAULT_CHAT_FRAME:AddMessage("Ruthlessness: "..t.ruthlessness.."/3 ("..math.floor(self:GetRuthlessnessChance()*100).."%)")
            DEFAULT_CHAT_FRAME:AddMessage("Relentless Strikes: "..t.relentlessStrikes.."/1")
            DEFAULT_CHAT_FRAME:AddMessage("Seal Fate: "..t.sealFate.."/5 ("..math.floor(t.sealFate*20).."%)")
            DEFAULT_CHAT_FRAME:AddMessage("Improved Backstab: "..t.improvedBackstab.."/3 ("..math.floor(t.improvedBackstab*15).."%)")
            DEFAULT_CHAT_FRAME:AddMessage("Setup: "..t.setup.."/3 ("..math.floor(t.setup*15).."%)")
            DEFAULT_CHAT_FRAME:AddMessage("Improved Ambush: "..t.improvedAmbush.."/3 ("..math.floor(t.improvedAmbush*5).." energy)")
            DEFAULT_CHAT_FRAME:AddMessage("Initiative: "..t.initiative.."/3 ("..math.floor(t.initiative*33).."%)")
            DEFAULT_CHAT_FRAME:AddMessage("Mark for Death: "..(t.markForDeath and "Yes" or "No"))
            local critVal = t.critChance or 0
            DEFAULT_CHAT_FRAME:AddMessage("Crit Chance: "..tostring(math.floor(critVal*10)/10).." percent")
        else
            self:Print("CP module not loaded")
        end
        return
    elseif msg == "plan" then
        if not UnitExists("target") then
            self:Print("No target selected")
            return
        end
        if self.planner and self.PlanRotation then
            local cp = GetComboPoints("player", "target")
            local energy = UnitMana("player")
            self:Print("=== Planner Debug ===")
            self:Print("Current: "..cp.." CP, "..energy.." Energy")
            local ability, reason = self:PlanRotation(cp, energy)
            self:Print("Recommendation: "..(ability or "nil"))
            self:Print("Reason: "..(reason or "nil"))
            if self.Planner then
                self:Print("Predicted: "..self.Planner.predictedCP.." CP, "..math.floor(self.Planner.predictedEnergy).." Energy")
            end
        else
            self:Print("Planner module not loaded. Check for errors with /console scriptErrors 1")
            self:Print("RoRota.planner="..tostring(self.planner).." RoRota.PlanRotation="..tostring(self.PlanRotation))
        end
        return
    elseif msg == "help" then
        self:Print("=== RoRota Commands ===")
        self:Print("/rr - Open settings")
        self:Print("/rr preview - Toggle rotation preview")
        self:Print("/rr debuffs - Show target debuffs (debug)")
        self:Print("/rr icons - Show all ability icons")
        self:Print("/rr talents - Show CP talent info")
        self:Print("/rr plan - Show planner recommendation")
        self:Print("/rr integration - Show SuperWoW/Nampower status")
        self:Print("/rr debug - Toggle debug mode (shows in preview)")
        self:Print("/rr state - Show current state")
        self:Print("/rr logs - Show recent debug logs")
        self:Print("/rr perf - Show performance stats")
        self:Print("/rr poison - Test poison warnings")
        return
    end
    
    -- default: open GUI
    if not RoRotaGUIFrame then
        if self.CreateGUI then
            self:CreateGUI()
        else
            self:Print("GUI module not loaded. Please /reload")
            return
        end
    end
    if RoRotaGUIFrame then
        RoRotaGUIFrame:Show()
    end
end

RoRota.commands = true
