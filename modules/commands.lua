--[[ slash commands ]]--
-- All /rr and /rorota slash command handlers

function RoRota:RegisterSlashCommands()
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
                    RoRotaPreviewFrame.enabled = not RoRotaPreviewFrame.enabled
                    if RoRotaPreviewFrame.enabled then
                        RoRota:Print("Preview enabled")
                        RoRotaPreviewFrame:Show()
                    else
                        RoRota:Print("Preview disabled")
                    end
                end
            end
            return
        elseif msg == "debug" then
            if RoRota.Debug then 
                RoRota.Debug:Show()
            else
                RoRota:Print("Debug module not loaded")
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
        elseif msg == "immunity" or msg == "immune" then
            if RoRota.ListImmunities then
                RoRota:ListImmunities()
            end
            if RoRota.GetImmuneTargets then
                RoRota:Print("Bleed immune: "..table.getn(RoRota:GetImmuneTargets("bleed")))
                RoRota:Print("Stun immune: "..table.getn(RoRota:GetImmuneTargets("stun")))
                RoRota:Print("Incapacitate immune: "..table.getn(RoRota:GetImmuneTargets("incapacitate")))
            end
            return
        elseif string.find(msg, "^immunity remove ") or string.find(msg, "^immune remove ") then
            local targetName = string.gsub(msg, "^immunity remove ", "")
            targetName = string.gsub(targetName, "^immune remove ", "")
            if RoRota.RemoveImmunity then
                RoRota:RemoveImmunity(targetName)
            end
            return
        elseif msg == "immunity clear" or msg == "immune clear" then
            if RoRota.ClearImmunities then
                RoRota:ClearImmunities()
            end
            return
        elseif msg == "help" then
            RoRota:Print("=== RoRota Commands ===")
            RoRota:Print("/rr - Open settings")
            RoRota:Print("/rr debug - Open debug window")
            RoRota:Print("/rr preview - Toggle rotation preview")
            RoRota:Print("/rr immunity - List all immune targets")
            RoRota:Print("/rr immunity remove <name> - Remove target")
            RoRota:Print("/rr immunity clear - Clear all immunities")
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
end
