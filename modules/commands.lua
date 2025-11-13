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
            if RoRota.Debug then RoRota.Debug:SetEnabled(true, "normal") end
            return
        elseif msg == "debug full" then
            if RoRota.Debug then RoRota.Debug:SetEnabled(true, "full") end
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
        elseif msg == "ttk" then
            if not RoRota.ttk then
                RoRota:Print("TTK module not loaded")
                return
            end
            if not RoRota.db or not RoRota.db.profile or not RoRota.db.profile.ttk then
                RoRota:Print("TTK config missing in profile")
                return
            end
            local profile = RoRota.db.profile
            local ttk = profile.ttk
            RoRota:Print("=== TTK Status ===")
            RoRota:Print("Enabled: "..(ttk.enabled and "Yes" or "No"))
            RoRota:Print("Exclude Bosses: "..(ttk.excludeBosses and "Yes" or "No"))
            RoRota:Print("Current Samples: "..table.getn(RoRota.ttk.samples))
            if UnitExists("target") then
                local estimate = RoRota:EstimateTTK()
                if estimate then
                    RoRota:Print("Target TTK: "..string.format("%.1f", estimate).."s")
                    RoRota:Print("Is Dying Soon: "..(RoRota:IsTargetDyingSoon() and "Yes" or "No"))
                else
                    RoRota:Print("Target TTK: Not enough data")
                end
            else
                RoRota:Print("No target selected")
            end
            return
        elseif msg == "buffs" then
            if RoRota.BuffCache then
                RoRota:UpdateBuffCache()
                RoRota:Print("=== Player Buffs ===")
                for name in pairs(RoRota.BuffCache.player) do
                    RoRota:Print(name)
                end
            end
            return
        elseif msg == "cachestats" or msg == "cacheinfo" then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00=== Cache Status ===")
            
            if RoRota.BuffCache then
                local playerBuffs = 0
                for _ in pairs(RoRota.BuffCache.player) do playerBuffs = playerBuffs + 1 end
                local targetDebuffs = 0
                for _ in pairs(RoRota.BuffCache.target) do targetDebuffs = targetDebuffs + 1 end
                local targetBuffs = 0
                if RoRota.BuffCache.targetBuffs then
                    for _ in pairs(RoRota.BuffCache.targetBuffs) do targetBuffs = targetBuffs + 1 end
                end
                local lastUpdate = GetTime() - RoRota.BuffCache.lastUpdate
                DEFAULT_CHAT_FRAME:AddMessage("Buff Cache: "..playerBuffs.." player, "..targetDebuffs.." target debuffs, "..targetBuffs.." target buffs")
                DEFAULT_CHAT_FRAME:AddMessage("Last update: "..lastUpdate.." seconds ago")
            end
            
            if RoRota.SpellbookCache then
                local spellCount = 0
                for _ in pairs(RoRota.SpellbookCache.spells) do spellCount = spellCount + 1 end
                DEFAULT_CHAT_FRAME:AddMessage("Spellbook Cache: "..spellCount.." spells")
                DEFAULT_CHAT_FRAME:AddMessage("Dirty: "..(RoRota.SpellbookCache.dirty and "Yes" or "No"))
            end
            
            if RoRota.ActionSlotCache then
                local slotCount = 0
                for _ in pairs(RoRota.ActionSlotCache) do slotCount = slotCount + 1 end
                DEFAULT_CHAT_FRAME:AddMessage("Action Slots: "..slotCount.." cached")
            end
            
            if RoRota.Cache then
                local stats = RoRota.Cache:GetStats()
                local hitRate = stats.total > 0 and (stats.hits * 100 / stats.total) or 0
                DEFAULT_CHAT_FRAME:AddMessage("State Cache: "..stats.total.." calls ("..math.floor(hitRate).."% throttled)")
            end
            
            return
        elseif msg == "bufftimers" or msg == "bt" then
            if RoRota.CombatLog then
                RoRota:Print("=== Buff Timers ===")
                local hasBuffs = false
                for buffName, expiry in pairs(RoRota.CombatLog.buffTimers) do
                    local remaining = expiry - GetTime()
                    if remaining > 0 then
                        RoRota:Print(buffName..": "..string.format("%.1f", remaining).."s")
                        hasBuffs = true
                    end
                end
                if not hasBuffs then
                    RoRota:Print("No active buffs tracked")
                end
                
                RoRota:Print("=== Debuff Timers ===")
                local hasDebuffs = false
                for debuffName, data in pairs(RoRota.CombatLog.debuffTimers) do
                    local remaining = data.expiry - GetTime()
                    if remaining > 0 then
                        local targetInfo = data.target and (" on "..data.target) or ""
                        RoRota:Print(debuffName..targetInfo..": "..string.format("%.1f", remaining).."s")
                        hasDebuffs = true
                    end
                end
                if not hasDebuffs then
                    RoRota:Print("No active debuffs tracked")
                end
            else
                RoRota:Print("CombatLog module not loaded")
            end
            return
        elseif msg == "caststate" or msg == "cs" then
            if RoRota.CastState then
                local state, reason = RoRota.CastState:GetState()
                RoRota:Print("=== Cast State ===")
                RoRota:Print("State: "..state)
                if reason then
                    RoRota:Print("Lock Reason: "..reason)
                end
                if state == "LOCKED" and RoRota.CastState.lockUntil then
                    local remaining = RoRota.CastState.lockUntil - GetTime()
                    if remaining > 0 then
                        RoRota:Print("Lock Expires: "..string.format("%.2f", remaining).."s")
                    end
                end
                RoRota:Print("Can Cast: "..(RoRota.CastState:CanCast() and "Yes" or "No"))
                if RoRota.CombatLog then
                    RoRota:Print("On GCD: "..(RoRota.CombatLog:IsOnGCD() and "Yes" or "No"))
                    if RoRota.CombatLog.gcdEnd > GetTime() then
                        local gcdRemaining = RoRota.CombatLog.gcdEnd - GetTime()
                        RoRota:Print("GCD Expires: "..string.format("%.2f", gcdRemaining).."s")
                    end
                    RoRota:Print("Casting: "..(RoRota.CombatLog:IsCasting() and "Yes" or "No"))
                    local spell, action, time = RoRota.CombatLog:GetLastCast()
                    if spell then
                        RoRota:Print("Last Cast: "..spell.." ("..action..")")
                    end
                    local history = RoRota.CombatLog:GetCastHistory()
                    if table.getn(history) > 0 then
                        RoRota:Print("Recent casts:")
                        for i = 1, math.min(5, table.getn(history)) do
                            local cast = history[i]
                            RoRota:Print("  "..cast.spell.." ("..string.format("%.1f", GetTime() - cast.time).."s ago)")
                        end
                    end
                end
                if RoRota.GetTimeToNextTick then
                    local nextTick = RoRota:GetTimeToNextTick()
                    RoRota:Print("Next Energy Tick: "..string.format("%.2f", nextTick).."s")
                end
            else
                RoRota:Print("CastState module not loaded")
            end
            return

        elseif msg == "testswap" or msg == "swap" then
            if not RoRota.Equipment then
                RoRota:Print("Equipment module not loaded")
                return
            end
            local setName = RoRota.db.profile.opener.equipmentSet
            if not setName then
                RoRota:Print("No equipment set configured for stealth opener")
                return
            end
            RoRota:Print("Testing equipment swap to: "..setName)
            RoRota.Equipment:SwapToSet(setName)
            return
        elseif msg == "help" then
            RoRota:Print("=== RoRota Commands ===")
            RoRota:Print("/rr - Open settings")
            RoRota:Print("/rr testswap - Test equipment swap manually")
            RoRota:Print("/rr buffs - List all player buffs")
            RoRota:Print("/rr bufftimers - Show tracked buff/debuff timers")
            RoRota:Print("/rr cachestats - Show cache statistics")
            RoRota:Print("/rr caststate - Show cast state and history")
            RoRota:Print("/rr debug - Open debug window")
            RoRota:Print("/rr preview - Toggle rotation preview")
            RoRota:Print("/rr ttk - Show TTK status and debug info")
            RoRota:Print("/rr immunity - List all immune targets")
            RoRota:Print("/rr immunity remove <name> - Remove target")
            RoRota:Print("/rr immunity clear - Clear all immunities")
            RoRota:Print("/rr integration - Show SuperWoW/Nampower status")
            RoRota:Print("/rr debug on - Enable debug (normal)")
            RoRota:Print("/rr debug full - Enable debug (full logs)")
            RoRota:Print("/rr debug off - Disable debug")
            RoRota:Print("/rr trace on/off - Toggle rotation trace")
            RoRota:Print("/rr state - Show current state")
            RoRota:Print("/rr logs - Show recent debug logs")
            RoRota:Print("/rr perf - Show performance stats")
            RoRota:Print("/rr poison - Test poison warnings")
            return
        end
        
        -- default: open new menu
        if RoRotaMainMenu and RoRotaMainMenu.Show then
            RoRotaMainMenu:Show()
        else
            RoRota:Print("MainMenu module not loaded. Please /reload")
        end
    end
end
