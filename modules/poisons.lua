-- RoRota Poisons Module
-- Poison warning and auto-application system

RoRota.poisonCache = {}

-- Scan bags for available poisons (highest rank of each type)
function RoRota:ScanBagsForPoisons()
	local success, err = pcall(function()
		self.poisonCache = {}
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link then
					local s, e = string.find(link, "%[")
					local s2, e2 = string.find(link, "%]")
					if s and s2 then
						local name = string.sub(link, e + 1, s2 - 1)
						for poisonType, ranks in pairs(RoRotaConstants.POISON_SPELL_NAMES) do
							for _, rankName in ipairs(ranks) do
								if name == rankName then
									if not self.poisonCache[poisonType] then
										self.poisonCache[poisonType] = {bag = bag, slot = slot, name = name}
									end
									break
								end
							end
						end
						end
				end
			end
		end
	end)
	
	if not success then
		if RoRota.Debug then
			RoRota.Debug:Error("Poison bag scan failed", err)
		end
	end
end

-- Check if weapon has poison (16=MH, 17=OH)
function RoRota:HasWeaponPoison(slot)
	local hasMainHandEnchant, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
	if slot == 16 then
		return hasMainHandEnchant
	else
		return hasOffHandEnchant
	end
end

-- Apply poison to weapon
function RoRota:ApplyPoison(poisonType, weaponSlot)
	local poison = self.poisonCache[poisonType]
	if not poison then return false end
	
	local success, err = pcall(function()
		UseContainerItem(poison.bag, poison.slot)
		PickupInventoryItem(weaponSlot)
	end)
	
	if not success then
		if RoRota.Debug then
			RoRota.Debug:Error("Poison application failed", err)
		end
		return false
	end
	
	return true
end

-- Check if poison application succeeded
function RoRota:CheckPoisonApplied()
	if not self.poisonApplyPending then return end
	
	local now = GetTime()
	if now - self.poisonApplyTime < 3 then return end
	
	local slot = self.poisonApplyPending.slot
	local poisonType = self.poisonApplyPending.type
	
	if self:HasWeaponPoison(slot) then
		local hand = slot == 16 and "main hand" or "off hand"
		self:Print("Applied "..poisonType.." to "..hand)
		self.lastPoisonSlot = slot
	end
	
	self.poisonApplyPending = nil
end

-- Main check and apply function
function RoRota:CheckAndApplyPoisons()
	self:CheckPoisonApplied()
	
	local db = self.db and self.db.profile and self.db.profile.poisons
	if not db or not db.autoApply then return end
	
	if UnitAffectingCombat("player") and not db.applyInCombat then return end
	
	local now = GetTime()
	if now - self.lastPoisonApply < 2 then return end
	
	local mhPoison = db.mainHandPoison
	local ohPoison = db.offHandPoison
	local needApply = false
	
	if mhPoison and mhPoison ~= "None" and not self:HasWeaponPoison(16) then
		needApply = true
	end
	
	if ohPoison and ohPoison ~= "None" and not self:HasWeaponPoison(17) then
		needApply = true
	end
	
	if not needApply then return end
	
	self:ScanBagsForPoisons()
	
	if mhPoison and mhPoison ~= "None" and not self:HasWeaponPoison(16) then
		if self:ApplyPoison(mhPoison, 16) then
			self.poisonApplyPending = {slot = 16, type = mhPoison}
			self.poisonApplyTime = now
			self.lastPoisonApply = now
			return
		end
	end
	
	if ohPoison and ohPoison ~= "None" and not self:HasWeaponPoison(17) then
		if self:ApplyPoison(ohPoison, 17) then
			self.poisonApplyPending = {slot = 17, type = ohPoison}
			self.poisonApplyTime = now
			self.lastPoisonApply = now
		end
	end
end

-- Manual poison application (for button)
function RoRota:ApplyPoisonsManual()
	local db = self.db and self.db.profile and self.db.profile.poisons
	if not db then
		self:Print("Poison settings not found")
		return
	end
	
	self:ScanBagsForPoisons()
	
	local mhPoison = db.mainHandPoison
	local ohPoison = db.offHandPoison
	local now = GetTime()
	
	if self.lastPoisonSlot == 17 then
		if mhPoison and mhPoison ~= "None" then
			if self:ApplyPoison(mhPoison, 16) then
				self.poisonApplyPending = {slot = 16, type = mhPoison}
				self.poisonApplyTime = now
				return
			else
				self:Print("Failed to apply "..mhPoison.." to main hand (not in bags?)")
			end
		end
		if ohPoison and ohPoison ~= "None" then
			if self:ApplyPoison(ohPoison, 17) then
				self.poisonApplyPending = {slot = 17, type = ohPoison}
				self.poisonApplyTime = now
			else
				self:Print("Failed to apply "..ohPoison.." to off hand (not in bags?)")
			end
		end
	else
		if ohPoison and ohPoison ~= "None" then
			if self:ApplyPoison(ohPoison, 17) then
				self.poisonApplyPending = {slot = 17, type = ohPoison}
				self.poisonApplyTime = now
				return
			else
				self:Print("Failed to apply "..ohPoison.." to off hand (not in bags?)")
			end
		end
		if mhPoison and mhPoison ~= "None" then
			if self:ApplyPoison(mhPoison, 16) then
				self.poisonApplyPending = {slot = 16, type = mhPoison}
				self.poisonApplyTime = now
			else
				self:Print("Failed to apply "..mhPoison.." to main hand (not in bags?)")
			end
		end
	end
end

-- Check weapon poisons and display warnings if needed
function RoRota:CheckWeaponPoisons(showDebug)
    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
    
    -- Convert expiration from milliseconds to seconds
    mainHandExpiration = mainHandExpiration and (mainHandExpiration / 1000) or 0
    offHandExpiration = offHandExpiration and (offHandExpiration / 1000) or 0
    
    -- Show debug info only when manually testing
    if showDebug then
        local mhMin = math.floor(mainHandExpiration / 60)
        local mhSec = math.mod(mainHandExpiration, 60)
        local ohMin = math.floor(offHandExpiration / 60)
        local ohSec = math.mod(offHandExpiration, 60)
        local msg = string.format("MH: %s %dm%ds %dc | OH: %s %dm%ds %dc", 
            hasMainHandEnchant and "Y" or "N", mhMin, mhSec, mainHandCharges or 0,
            hasOffHandEnchant and "Y" or "N", ohMin, ohSec, offHandCharges or 0)
        UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
    end
    
    if not self.db or not self.db.profile or not self.db.profile.poisons or not self.db.profile.poisons.enabled then
        return
    end
    
    local db = self.db.profile.poisons
    
    -- Check main hand
    if not hasMainHandEnchant then
        UIErrorsFrame:AddMessage("Main hand poison missing!", 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME)
    elseif mainHandExpiration > 0 and mainHandExpiration < db.timeThreshold then
        local minutes = math.floor(mainHandExpiration / 60)
        UIErrorsFrame:AddMessage(string.format("Main hand poison expires in %d min!", minutes), 1.0, 0.5, 0.0, 1.0, UIERRORS_HOLD_TIME)
    elseif mainHandCharges > 0 and mainHandCharges < db.chargesThreshold then
        UIErrorsFrame:AddMessage(string.format("Main hand poison: %d charges left!", mainHandCharges), 1.0, 0.5, 0.0, 1.0, UIERRORS_HOLD_TIME)
    end
    
    -- Check off hand
    if not hasOffHandEnchant then
        UIErrorsFrame:AddMessage("Off hand poison missing!", 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME)
    elseif offHandExpiration > 0 and offHandExpiration < db.timeThreshold then
        local minutes = math.floor(offHandExpiration / 60)
        UIErrorsFrame:AddMessage(string.format("Off hand poison expires in %d min!", minutes), 1.0, 0.5, 0.0, 1.0, UIERRORS_HOLD_TIME)
    elseif offHandCharges > 0 and offHandCharges < db.chargesThreshold then
        UIErrorsFrame:AddMessage(string.format("Off hand poison: %d charges left!", offHandCharges), 1.0, 0.5, 0.0, 1.0, UIERRORS_HOLD_TIME)
    end
end
