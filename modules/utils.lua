--[[ utility functions ]]--
-- General utility functions used across modules

-- Deep merge two tables, preserving existing values in dst
function RoRota:DeepMerge(dst, src)
    if type(dst) ~= 'table' then dst = {} end
    if type(src) ~= 'table' then return dst end
    for k, v in pairs(src) do
        if type(v) == 'table' then
            dst[k] = self:DeepMerge(dst[k], v)
        else
            if dst[k] == nil then dst[k] = v end
        end
    end
    return dst
end

-- Get target distance (requires UnitXP integration for precise values)
function RoRota:GetTargetDistance()
	if not UnitExists("target") then return nil end
	
	-- Precise distance via UnitXP (SuperWoW)
	if RoRota.Integration and RoRota.Integration:HasUnitXP() then
		return UnitXP("distanceBetween", "player", "target")
	end
	
	-- Fallback: approximate distance via CheckInteractDistance
	if CheckInteractDistance("target", 3) then
		return 5  -- Melee range
	elseif CheckInteractDistance("target", 2) then
		return 10
	elseif CheckInteractDistance("target", 1) then
		return 25
	else
		return 35
	end
end

-- Check if target is in melee range
function RoRota:IsTargetInMeleeRange()
	if not UnitExists("target") then return false end
	
	-- Precise check via UnitXP
	if RoRota.Integration and RoRota.Integration:HasUnitXP() then
		local distance = UnitXP("distanceBetween", "player", "target")
		return distance and distance <= 5
	end
	
	-- Fallback: CheckInteractDistance
	return CheckInteractDistance("target", 3)
end

-- Print message with notification type check
function RoRota:PrintNotification(message, notificationType)
	if not self.db or not self.db.profile or not self.db.profile.notifications then
		self:Print(message)
		return
	end
	
	local notifications = self.db.profile.notifications
	
	-- Check if this notification type is enabled
	if notificationType == "immunity" and not notifications.showImmunityMessages then
		return
	elseif notificationType == "poison" and not notifications.showPoisonMessages then
		return
	elseif notificationType == "equipment" and not notifications.showEquipmentMessages then
		return
	end
	
	self:Print(message)
end
