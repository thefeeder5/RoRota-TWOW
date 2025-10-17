-- RoRota GUI - Minimap Button

function RoRota:CreateMinimapButton()
	if RoRotaMinimapButton then return end
	if not Minimap then return end
	
	local btn = CreateFrame("Button", "RoRotaMinimapButton", Minimap)
	btn:SetWidth(32)
	btn:SetHeight(32)
	btn:SetFrameStrata("MEDIUM")
	btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -15, 0)
	btn:SetMovable(true)
	btn:EnableMouse(true)
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	local icon = btn:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\Icons\\Ability_Rogue_Eviscerate")
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
	
	local overlay = btn:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(52)
	overlay:SetHeight(52)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
	
	btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	
	btn:SetScript("OnClick", function()
		if arg1 == "LeftButton" then
			if not RoRotaGUIFrame then
				if RoRota.CreateGUI then
					RoRota:CreateGUI()
				end
			end
			if RoRotaGUIFrame then
				if RoRotaGUIFrame:IsVisible() then
					RoRotaGUIFrame:Hide()
				else
					RoRotaGUIFrame:Show()
				end
			end
		elseif arg1 == "RightButton" then
			if not RoRotaMinimapMenu then
				RoRotaMinimapMenu = CreateFrame("Frame", "RoRotaMinimapMenu", UIParent, "UIDropDownMenuTemplate")
			end
			
			local function GetCurrentProfile()
				local charKey = UnitName("player").." - "..GetRealmName()
				return RoRotaDB.char and RoRotaDB.char[charKey] or "Default"
			end
			
			UIDropDownMenu_Initialize(RoRotaMinimapMenu, function()
				local info = UIDropDownMenu_CreateInfo()
				info.text = "RoRota"
				info.isTitle = true
				info.notCheckable = true
				UIDropDownMenu_AddButton(info)
				
				info = UIDropDownMenu_CreateInfo()
				info.text = "Toggle Rotation Preview"
				info.notCheckable = true
				info.func = function()
					if RoRota.CreateRotationPreview then
						if not RoRotaPreviewFrame then
							RoRota:CreateRotationPreview()
						end
						if RoRotaPreviewFrame then
							RoRotaPreviewFrame.enabled = not RoRotaPreviewFrame.enabled
							if RoRotaPreviewFrame.enabled then
								RoRota:Print("Preview enabled")
							else
								RoRota:Print("Preview disabled")
							end
						end
					end
					CloseDropDownMenus()
				end
				UIDropDownMenu_AddButton(info)
				
				if RoRotaDB and RoRotaDB.profiles then
					local current = GetCurrentProfile()
					local names = {}
					for pname in pairs(RoRotaDB.profiles) do
						table.insert(names, pname)
					end
					table.sort(names)
					
					info = UIDropDownMenu_CreateInfo()
					info.text = "Profiles:"
					info.isTitle = true
					info.notCheckable = true
					UIDropDownMenu_AddButton(info)
					
					for _, pname in ipairs(names) do
						info = UIDropDownMenu_CreateInfo()
						info.text = "  "..pname
						info.checked = (pname == current)
						local p = pname
						info.func = function()
							if not RoRotaDB.char then RoRotaDB.char = {} end
							local ck = UnitName("player").." - "..GetRealmName()
							RoRotaDB.char[ck] = p
							if RoRotaDB.profiles[p] then
								RoRota:SetProfile(p)
								RoRota:Print("Switched to profile: "..p)
								if RoRotaGUIFrame and RoRotaGUIFrame:IsVisible() then
									LoadValues(RoRotaGUIFrame)
								end
							end
							CloseDropDownMenus()
						end
						UIDropDownMenu_AddButton(info)
					end
				end
				
				info = UIDropDownMenu_CreateInfo()
				info.text = "Close"
				info.notCheckable = true
				info.func = function() CloseDropDownMenus() end
				UIDropDownMenu_AddButton(info)
			end, "MENU")
			
			ToggleDropDownMenu(1, nil, RoRotaMinimapMenu, "cursor", 0, 0)
		end
	end)
	
	btn:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText("RoRota")
		GameTooltip:AddLine("Click to open settings", 1, 1, 1)
		GameTooltip:Show()
	end)
	
	btn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	btn:Show()
end
