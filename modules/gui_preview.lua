--[[ gui_preview ]]--
-- Rotation preview window showing current and next abilities.
-- Displays ability queue with icons, combo points, and energy.
--
-- Features:
--   - Shows current ability (what to press now)
--   - Shows next ability (what comes after)
--   - Real-time updates (0.1s throttle)
--   - Movable window (drag to reposition)
--   - Ability icons from constants table

function RoRota:CreateRotationPreview()
	if RoRotaPreviewFrame then return end
	
	local pf = CreateFrame("Frame", "RoRotaPreviewFrame", UIParent)
	pf:SetWidth(74)
	pf:SetHeight(38)
	pf.debugMode = false
	pf:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
	pf:SetMovable(true)
	pf:EnableMouse(true)
	pf:RegisterForDrag("LeftButton")
	pf:SetScript("OnDragStart", function() this:StartMoving() end)
	pf:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	
	-- background (hidden)
	pf.bg = pf:CreateTexture(nil, "BACKGROUND")
	pf.bg:SetAllPoints(pf)
	pf.bg:SetTexture(0, 0, 0, 0.7)
	pf.bg:Hide()
	
	-- border (hidden)
	pf.border = pf:CreateTexture(nil, "BORDER")
	pf.border:SetAllPoints(pf)
	pf.border:SetTexture(0.3, 0.3, 0.3, 1)
	pf.border:SetPoint("TOPLEFT", pf, "TOPLEFT", 1, -1)
	pf.border:SetPoint("BOTTOMRIGHT", pf, "BOTTOMRIGHT", -1, 1)
	pf.border:Hide()
	
	-- current ability icon
	pf.icon = pf:CreateTexture(nil, "ARTWORK")
	pf.icon:SetWidth(32)
	pf.icon:SetHeight(32)
	pf.icon:SetPoint("TOPLEFT", pf, "TOPLEFT", 3, -3)
	pf.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	-- current ability name (spans both icons)
	pf.abilityName = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.abilityName:SetPoint("TOPLEFT", pf.icon, "BOTTOMLEFT", 0, -1)
	pf.abilityName:SetWidth(68)
	pf.abilityName:SetJustifyH("CENTER")
	pf.abilityName:SetText("")
	
	-- next ability icon
	pf.nextIcon = pf:CreateTexture(nil, "ARTWORK")
	pf.nextIcon:SetWidth(32)
	pf.nextIcon:SetHeight(32)
	pf.nextIcon:SetPoint("LEFT", pf.icon, "RIGHT", 2, 0)
	pf.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	
	-- next ability name (hidden to save space)
	pf.nextAbilityName = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.nextAbilityName:SetPoint("TOP", pf.nextIcon, "BOTTOM", 0, -1)
	pf.nextAbilityName:SetWidth(32)
	pf.nextAbilityName:SetJustifyH("CENTER")
	pf.nextAbilityName:SetText("")
	pf.nextAbilityName:Hide()
	
	-- CP and Energy text
	pf.cpText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.cpText:SetPoint("TOPLEFT", pf.icon, "BOTTOMLEFT", 0, -2)
	pf.cpText:SetText("CP: 0")
	
	pf.energyText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.energyText:SetPoint("TOPLEFT", pf.cpText, "BOTTOMLEFT", 0, -1)
	pf.energyText:SetText("E: 0")
	
	-- reason text
	pf.reasonText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.reasonText:SetPoint("TOPLEFT", pf.energyText, "BOTTOMLEFT", 0, -2)
	pf.reasonText:SetWidth(134)
	pf.reasonText:SetJustifyH("LEFT")
	pf.reasonText:SetText("")
	pf.reasonText:SetTextColor(0.7, 0.7, 0.7)
	
	-- debuff info text (hidden, not used)
	pf.debuffText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.debuffText:SetPoint("TOPLEFT", pf.reasonText, "BOTTOMLEFT", 0, -2)
	pf.debuffText:SetWidth(134)
	pf.debuffText:SetJustifyH("LEFT")
	pf.debuffText:SetText("")
	pf.debuffText:SetTextColor(1, 0.8, 0)
	pf.debuffText:Hide()
	
	-- debug info text (multi-line)
	pf.debugText = pf:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	pf.debugText:SetPoint("TOPLEFT", pf.reasonText, "BOTTOMLEFT", 0, -2)
	pf.debugText:SetWidth(134)
	pf.debugText:SetJustifyH("LEFT")
	pf.debugText:SetText("")
	pf.debugText:SetTextColor(0.5, 1, 0.5)
	pf.debugText:SetJustifyV("TOP")
	
	pf.lastUpdate = 0
	pf:SetScript("OnUpdate", function()
		if not this.lastUpdate then this.lastUpdate = 0 end
		if GetTime() - this.lastUpdate > 0.1 then
			this.lastUpdate = GetTime()
			if RoRota and RoRota.GetNextAbility and RoRota.GetNextAbilityAfter then
				local current_ability = RoRota:GetNextAbility()
				local next_ability = RoRota:GetNextAbilityAfter(current_ability)
				local cp = GetComboPoints("player", "target")
				local energy = UnitMana("player")
				
				this.cpText:SetText("CP: "..cp)
				this.energyText:SetText("E: "..energy)
				
				-- update reason (only in debug mode)
				if this.debugMode and RoRota.rotationReason and RoRota.rotationReason ~= "" then
					this.reasonText:SetText(RoRota.rotationReason)
				else
					this.reasonText:SetText("")
				end
				
				-- always hide debuff summary line
				this.debuffText:SetText("")
				
				-- update debug info and resize window
				if this.debugMode and RoRota.db and RoRota.db.profile then
					this:SetWidth(140)
					this:SetHeight(120)
					this.cpText:Hide()
					this.energyText:Hide()
					local db = RoRota.db.profile
					local abilitiesCfg = db.abilities or {}
					local finisherPrio = db.finisherPriority or {"Slice and Dice", "Rupture", "Envenom", "Expose Armor"}
					local debugLines = {}
					local refreshThreshold = db.finisherRefreshThreshold or 2
					
					-- Calculate energy regen rate for predictions (do this first)
					local energyPerTick = RoRotaConstants.ENERGY_PER_TICK
					local tickTime = RoRotaConstants.ENERGY_TICK_TIME
					if RoRota.TalentCache and RoRota.TalentCache.bladeRush and RoRota.TalentCache.bladeRush > 0 then
						local _, agility = UnitStat("player", 2)
						local agiReduction = agility * 0.001
						tickTime = math.max(0.5, tickTime - agiReduction)
					end
					if RoRota:HasAdrenalineRush() then
						energyPerTick = 40
					end
					local energyPerSec = energyPerTick / tickTime
					
					-- predicted state (show when planner has a recommendation)
					if RoRota.Planner and RoRota.Planner.recommendation and RoRota.Planner.recommendation ~= "Pool" then
						local cpStr = string.format("%.2f", RoRota.Planner.predictedCP)
						if RoRota.Planner.predictedCP == math.floor(RoRota.Planner.predictedCP) then
							cpStr = string.format("%d", RoRota.Planner.predictedCP)
						end
						local pred = string.format("After: %sCP %.0fE", cpStr, RoRota.Planner.predictedEnergy)
						if RoRota.Planner.nextAbility then
							pred = pred .. " -> " .. RoRota.Planner.nextAbility
						end
						table.insert(debugLines, pred)
					end
					-- Also show prediction for Eviscerate at 5 CP (fallback finisher)
					if cp == 5 and (not RoRota.Planner or not RoRota.Planner.recommendation or RoRota.Planner.recommendation == "Sinister Strike") then
						-- Simulate Eviscerate
						local evisCost = RoRota:GetEnergyCost("Eviscerate")
						local newEnergy = energy - evisCost + (energyPerSec * 2)
						newEnergy = math.min(100, math.max(0, newEnergy))
						local ruthChance = RoRota:GetRuthlessnessChance()
						local newCP = ruthChance >= 1.0 and 1 or (ruthChance > 0 and ruthChance or 0)
						local cpStr = newCP == math.floor(newCP) and string.format("%d", newCP) or string.format("%.2f", newCP)
						local pred = string.format("After: %sCP %.0fE (Evis)", cpStr, newEnergy)
						table.insert(debugLines, pred)
					end
					
					for i, finisher in ipairs(finisherPrio) do
						local line = ""
						if finisher == "Slice and Dice" then
							local enabled = abilitiesCfg.SliceAndDice and abilitiesCfg.SliceAndDice.enabled
							if enabled then
								local time = RoRota:GetBuffTimeRemaining("Slice and Dice")
								local shouldUse = time <= refreshThreshold
								line = string.format("%d.SnD: %.0fs %s", i, time, shouldUse and "USE" or "skip")
							else
								line = i.."SnD: OFF"
							end
						elseif finisher == "Envenom" then
							local enabled = abilitiesCfg.Envenom and abilitiesCfg.Envenom.enabled
							if enabled then
								local time = RoRota:GetBuffTimeRemaining("Envenom")
								local shouldUse = time <= refreshThreshold
								line = string.format("%d.Env: %.0fs %s", i, time, shouldUse and "USE" or "skip")
							else
								line = i.."Env: OFF"
							end
						elseif finisher == "Rupture" then
							local enabled = abilitiesCfg.Rupture and abilitiesCfg.Rupture.enabled
							if enabled then
								local time = RoRota:GetDebuffTimeRemaining("Rupture")
								local shouldUse = time <= refreshThreshold
								line = string.format("%d.Rupt: %.0fs %s", i, time, shouldUse and "USE" or "skip")
							else
								line = i.."Rupt: OFF"
							end
						elseif finisher == "Expose Armor" then
							local enabled = abilitiesCfg.ExposeArmor and abilitiesCfg.ExposeArmor.enabled
							if enabled then
								local time = RoRota:GetDebuffTimeRemaining("Expose Armor")
								local shouldUse = time <= refreshThreshold
								line = string.format("%d.EA: %.0fs %s", i, time, shouldUse and "USE" or "skip")
							else
								line = i.."EA: OFF"
							end
						end
						table.insert(debugLines, line)
					end
					
					this.debugText:SetText(table.concat(debugLines, "\n"))
				else
					this:SetWidth(74)
					this:SetHeight(38)
					this.cpText:Hide()
					this.energyText:Hide()
					this.debugText:SetText("")
				end
				
				-- update current ability name
				if current_ability then
					if current_ability == "Pooling Energy" then
						this.abilityName:SetText("Pooling")
					elseif current_ability == "Waiting for Energy" then
						this.abilityName:SetText("Wait Energy")
					elseif current_ability == "No Target" then
						this.abilityName:SetText("No Target")
					elseif current_ability == "Apply Poison" then
						this.abilityName:SetText("Poison")
					elseif current_ability == "Smart Eviscerate" then
						this.abilityName:SetText("Eviscerate")
					else
						this.abilityName:SetText(current_ability)
					end
				else
					this.abilityName:SetText("")
				end
				
				-- update current ability icon
				if current_ability and RoRotaConstants and RoRotaConstants.ABILITY_ICONS then
					local icon_path = RoRotaConstants.ABILITY_ICONS[current_ability]
					if icon_path then
						this.icon:SetTexture(icon_path)
					else
						this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				else
					this.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
				
				-- update next ability name
				if next_ability then
					this.nextAbilityName:SetText(next_ability)
				else
					this.nextAbilityName:SetText("")
				end
				
				-- update next ability icon
				if next_ability and RoRotaConstants and RoRotaConstants.ABILITY_ICONS then
					local next_icon_path = RoRotaConstants.ABILITY_ICONS[next_ability]
					if next_icon_path then
						this.nextIcon:SetTexture(next_icon_path)
					else
						this.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				else
					this.nextIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
			end
		end
	end)
	
	pf:Hide()
end
