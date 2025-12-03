--[[ conditions ]]--
-- Centralized condition evaluation system
-- Provides reusable condition checks for rotation logic

if not RoRota then return end
if RoRota.conditions then return end

RoRotaConditionParser = {}
RoRota.Conditions = {}

-- Performance: weapon type cache (cleared on equipment change)
local weaponTypeCache = nil
local weaponTypeCacheTime = 0

-- Performance: condition string parsing cache
local conditionParseCache = {}
local conditionParseCacheSize = 0
local MAX_PARSE_CACHE_SIZE = 50

-- Helper: Check weapon type (cached)
local function CheckWeaponType(weaponType)
	if not weaponType then return false end
	local now = GetTime()
	if weaponTypeCache and (now - weaponTypeCacheTime) < 1 then
		return weaponTypeCache == weaponType
	end
	
	local mhLink = GetInventoryItemLink("player", 16)
	if not mhLink then
		weaponTypeCache = nil
		return false
	end
	local _, _, _, _, _, itemType, itemSubType = GetItemInfo(mhLink)
	if not itemSubType then
		weaponTypeCache = nil
		return false
	end
	
	local subType = string.lower(itemSubType)
	weaponTypeCache = nil
	if string.find(subType, "dagger") then weaponTypeCache = "dagger"
	elseif string.find(subType, "sword") then weaponTypeCache = "sword"
	elseif string.find(subType, "mace") then weaponTypeCache = "mace"
	elseif string.find(subType, "axe") then weaponTypeCache = "axe"
	elseif string.find(subType, "fist") then weaponTypeCache = "fist"
	end
	weaponTypeCacheTime = now
	
	local wType = string.lower(weaponType)
	if wType == "daggers" then wType = "dagger" end
	if wType == "swords" then wType = "sword" end
	if wType == "maces" then wType = "mace" end
	if wType == "axes" then wType = "axe" end
	if wType == "fist weapon" then wType = "fist" end
	
	return weaponTypeCache == wType
end

-- Condition evaluators (moved into parser)
RoRotaConditionParser.evaluators = {
	-- Buff conditions
	has_buff = function(buffName)
		return RoRota:HasPlayerBuff(buffName)
	end,
	
	buff_time = function(buffName, minTime)
		local time = RoRota:GetBuffTimeRemaining(buffName)
		return time >= (minTime or 0)
	end,
	
	buff_missing = function(buffName)
		return not RoRota:HasPlayerBuff(buffName)
	end,
	
	-- Debuff conditions
	has_debuff = function(debuffName)
		return RoRota:HasTargetDebuff(debuffName)
	end,
	
	debuff_missing = function(debuffName)
		return not RoRota:HasTargetDebuff(debuffName)
	end,
	
	-- Resource conditions
	cp_min = function(value)
		return GetComboPoints("player", "target") >= value
	end,
	
	cp_max = function(value)
		return GetComboPoints("player", "target") <= value
	end,
	
	cp_equals = function(value)
		return GetComboPoints("player", "target") == value
	end,
	
	energy_min = function(value)
		return UnitMana("player") >= value
	end,
	
	-- Target conditions
	target_hp_below = function(percent)
		local hp = RoRota.Cache and RoRota.Cache.targetHealthPercent or 100
		return hp < percent
	end,
	
	target_hp_above = function(percent)
		local hp = RoRota.Cache and RoRota.Cache.targetHealthPercent or 100
		return hp > percent
	end,
	
	target_elite = function()
		return RoRota:IsTargetElite()
	end,
	
	target_boss = function()
		return UnitClassification("target") == "worldboss"
	end,
	
	target_dying = function(threshold)
		if not RoRota.IsTargetDyingSoon then return false end
		local success, result = pcall(RoRota.IsTargetDyingSoon, RoRota, threshold)
		return success and result
	end,
	
	-- Cooldown conditions
	cd_ready = function(spellName)
		return not RoRota:IsOnCooldown(spellName)
	end,
	
	cd_soon = function(spellName, seconds)
		local cd = RoRota:GetCooldownRemaining(spellName)
		return cd > 0 and cd <= (seconds or 5)
	end,
	
	-- Combat conditions
	in_combat = function()
		return UnitAffectingCombat("player")
	end,
	
	stealthed = function()
		return RoRota:HasPlayerBuff("Stealth")
	end,
	
	-- Group conditions
	in_group = function()
		return GetNumPartyMembers() > 0
	end,
	
	in_raid = function()
		return GetNumRaidMembers() > 0
	end,
	
	-- Casting conditions
	target_casting = function(spellName)
		if not RoRota or not RoRota.IsUnitCasting then return false end
		return RoRota:IsUnitCasting("target", spellName)
	end,
	
	target_not_casting = function(spellName)
		if not RoRota or not RoRota.IsUnitCasting then return true end
		return not RoRota:IsUnitCasting("target", spellName)
	end,
	
	-- Equipment conditions
	equipped = function(weaponType)
		return CheckWeaponType(weaponType)
	end,
	
	-- Immunity conditions
	noimmunity = function(immunityType)
		if not immunityType or not UnitExists("target") then return true end
		if not RoRota or not RoRota.IsTargetImmune then return true end
		local iType = string.lower(immunityType)
		if iType == "bleed" then
			return not RoRota:IsTargetImmune("Rupture")
		elseif iType == "stun" then
			return not RoRota:IsTargetImmune("Kidney Shot")
		elseif iType == "incapacitate" or iType == "incap" then
			return not RoRota:IsTargetImmune("Gouge")
		end
		return true
	end,
	
	-- Distance conditions
	distance = function(operator, yards)
		if not RoRota or not RoRota.GetTargetDistance then return false end
		local distance = RoRota:GetTargetDistance()
		if not distance then return false end
		if operator == "<" then return distance < yards
		elseif operator == ">" then return distance > yards
		elseif operator == "<=" then return distance <= yards
		elseif operator == ">=" then return distance >= yards
		elseif operator == "=" then return distance == yards
		end
		return false
	end,
	
	meleerange = function()
		if not RoRota or not RoRota.IsTargetInMeleeRange then return false end
		return RoRota:IsTargetInMeleeRange()
	end,
}

-- Evaluate a single condition (parser method)
function RoRotaConditionParser:Evaluate(conditionType, arg1, arg2, arg3, arg4, arg5)
	local evaluator = self.evaluators[conditionType]
	if not evaluator then
		return false
	end
	
	local success, result = pcall(evaluator, arg1, arg2, arg3, arg4, arg5)
	if not success then
		return false
	end
	
	return result
end

-- Backward compatibility wrapper
function RoRota.Conditions:Evaluate(conditionType, arg1, arg2, arg3, arg4, arg5)
	return RoRotaConditionParser:Evaluate(conditionType, arg1, arg2, arg3, arg4, arg5)
end

-- Evaluate multiple conditions with AND logic (parser method)
function RoRotaConditionParser:EvaluateAll(conditions)
	if not conditions or table.getn(conditions) == 0 then
		return true
	end
	
	for _, condition in ipairs(conditions) do
		local condType = condition[1]
		local args = {}
		for i = 2, table.getn(condition) do
			table.insert(args, condition[i])
		end
		
		if not self:Evaluate(condType, unpack(args)) then
			return false
		end
	end
	
	return true
end

-- Evaluate multiple conditions with OR logic (parser method)
function RoRotaConditionParser:EvaluateAny(conditions)
	if not conditions or table.getn(conditions) == 0 then
		return false
	end
	
	for _, condition in ipairs(conditions) do
		local condType = condition[1]
		local args = {}
		for i = 2, table.getn(condition) do
			table.insert(args, condition[i])
		end
		
		if self:Evaluate(condType, unpack(args)) then
			return true
		end
	end
	
	return false
end

-- Backward compatibility wrappers
function RoRota.Conditions:EvaluateAll(conditions)
	return RoRotaConditionParser:EvaluateAll(conditions)
end

function RoRota.Conditions:EvaluateAny(conditions)
	return RoRotaConditionParser:EvaluateAny(conditions)
end

-- Parse multi-line conditions (cached) - parser method
function RoRotaConditionParser:ParseConditionLines(condStr)
	if not condStr or condStr == "" then return nil end
	
	-- Check cache
	if conditionParseCache[condStr] then
		return conditionParseCache[condStr]
	end
	
	local lines = {}
	for line in string.gfind(condStr, "([^\n]+)") do
		local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
		if trimmed ~= "" then table.insert(lines, trimmed) end
	end
	
	local result = table.getn(lines) > 0 and lines or nil
	
	-- Cache result (with size limit)
	if conditionParseCacheSize < MAX_PARSE_CACHE_SIZE then
		conditionParseCache[condStr] = result
		conditionParseCacheSize = conditionParseCacheSize + 1
	end
	
	return result
end

-- Backward compatibility wrapper
function RoRota.Conditions:ParseConditionLines(condStr)
	return RoRotaConditionParser:ParseConditionLines(condStr)
end

-- Parse single line: [cond1,cond2] override1=val - parser method
function RoRotaConditionParser:ParseConditionLine(line)
	local condBlock, overrides = string.match(line, "^%[([^%]]+)%]%s*(.*)$")
	if not condBlock then condBlock, overrides = line, "" end
	local conditions = {}
	for cond in string.gfind(condBlock, "([^,]+)") do
		local trimmed = string.gsub(cond, "^%s*(.-)%s*$", "%1")
		if trimmed ~= "" then table.insert(conditions, trimmed) end
	end
	local overrideTable = {}
	if overrides and overrides ~= "" then
		for override in string.gfind(overrides, "([^,]+)") do
			local key, val = string.match(override, "^%s*([^=]+)=(.+)%s*$")
			if key and val then overrideTable[key] = tonumber(val) or val end
		end
	end
	return conditions, overrideTable
end

-- Backward compatibility wrapper
function RoRota.Conditions:ParseConditionLine(line)
	return RoRotaConditionParser:ParseConditionLine(line)
end

-- Evaluate single condition - parser method
function RoRotaConditionParser:EvaluateCondition(cond)
	local condType, value = string.match(cond, "^([^:]+):(.+)$")
	if not condType then condType, value = cond, nil end
	-- Player buffs
	if condType == "pbuff" or condType == "pnobuff" then
		local isNegated = (condType == "pnobuff")
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasBuff = RoRota:HasPlayerBuff(name)
			if isNegated then return not hasBuff end
			if not hasBuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetBuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasBuff = RoRota:HasPlayerBuff(value)
			if RoRota.Debug and RoRota.Debug.enabled then
				RoRota.Debug:Log(string.format("[COND] HasPlayerBuff(%s) = %s", value, tostring(hasBuff)))
			end
			if isNegated then return not hasBuff else return hasBuff end
		end
	-- Player debuffs
	elseif condType == "pdebuff" or condType == "pnodebuff" then
		local isNegated = (condType == "pnodebuff")
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasDebuff = RoRota:HasPlayerDebuff(name)
			if isNegated then return not hasDebuff end
			if not hasDebuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetPlayerDebuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasDebuff = RoRota:HasPlayerDebuff(value)
			if isNegated then return not hasDebuff else return hasDebuff end
		end
	-- Target buffs
	elseif condType == "tbuff" or condType == "tnobuff" then
		local isNegated = (condType == "tnobuff")
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasBuff = RoRota:HasTargetBuff(name)
			if isNegated then return not hasBuff end
			if not hasBuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetTargetBuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasBuff = RoRota:HasTargetBuff(value)
			if isNegated then return not hasBuff else return hasBuff end
		end
	-- Target debuffs
	elseif condType == "tdebuff" or condType == "tnodebuff" then
		local isNegated = (condType == "tnodebuff")
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasDebuff = RoRota:HasTargetDebuff(name)
			if isNegated then return not hasDebuff end
			if not hasDebuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetDebuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasDebuff = RoRota:HasTargetDebuff(value)
			if RoRota.Debug and RoRota.Debug.enabled then
				RoRota.Debug:Log(string.format("[COND] HasTargetDebuff(%s) = %s, isNegated = %s", value, tostring(hasDebuff), tostring(isNegated)))
			end
			if isNegated then return not hasDebuff else return hasDebuff end
		end
	elseif condType == "type" or condType == "notype" then
		local classification = UnitClassification("target")
		local match = (string.lower(value) == "boss" and classification == "worldboss") or (string.lower(value) == "worldboss" and classification == "worldboss") or (string.lower(value) == "elite" and (classification == "elite" or classification == "rareelite"))
		if condType == "type" then
			return match
		else
			return not match
		end
	elseif condType == "combo" then
		local cp = GetComboPoints("player", "target")
		local op, num = string.match(value, "^([<>=]+)#?(%d+)$")
		if op and num then
			num = tonumber(num)
			if op == ">" then return cp > num
			elseif op == "<" then return cp < num
			elseif op == ">=" then return cp >= num
			elseif op == "<=" then return cp <= num
			elseif op == "=" then return cp == num end
		end
	-- Player HP
	elseif condType == "php" then
		local hp = RoRota.Cache and RoRota.Cache.healthPercent or 100
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if op and num then
			num = tonumber(num)
			if op == ">" then return hp > num
			elseif op == "<" then return hp < num
			elseif op == ">=" then return hp >= num
			elseif op == "<=" then return hp <= num end
		end
	-- Target HP
	elseif condType == "thp" then
		local hp = RoRota.Cache and RoRota.Cache.targetHealthPercent or 100
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if op and num then
			num = tonumber(num)
			if op == ">" then return hp > num
			elseif op == "<" then return hp < num
			elseif op == ">=" then return hp >= num
			elseif op == "<=" then return hp <= num end
		end
	-- Energy
	elseif condType == "energy" then
		local energy = RoRota.Cache and RoRota.Cache.energy or UnitMana("player")
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if op and num then
			num = tonumber(num)
			if op == ">" then return energy > num
			elseif op == "<" then return energy < num
			elseif op == ">=" then return energy >= num
			elseif op == "<=" then return energy <= num
			elseif op == "=" then return energy == num end
		end
	elseif condType == "equipped" then
		if not value then return false end
		return CheckWeaponType(value)
	elseif condType == "noimmunity" then
		if not value or not UnitExists("target") then return true end
		if not RoRota or not RoRota.IsTargetImmune then return true end
		local iType = string.lower(value)
		if iType == "bleed" then
			return not RoRota:IsTargetImmune("Rupture")
		elseif iType == "stun" then
			return not RoRota:IsTargetImmune("Kidney Shot")
		elseif iType == "incapacitate" or iType == "incap" then
			return not RoRota:IsTargetImmune("Gouge")
		end
		return true
	elseif condType == "distance" then
		if not value then return false end
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if not op or not num then return false end
		if not RoRota or not RoRota.GetTargetDistance then return false end
		local distance = RoRota:GetTargetDistance()
		if not distance then return false end
		num = tonumber(num)
		if op == ">" then return distance > num
		elseif op == "<" then return distance < num
		elseif op == ">=" then return distance >= num
		elseif op == "<=" then return distance <= num
		elseif op == "=" then return distance == num
		end
		return false
	elseif condType == "meleerange" then
		if not RoRota or not RoRota.IsTargetInMeleeRange then return false end
		return RoRota:IsTargetInMeleeRange()
	elseif condType == "mod" then
		if not value then
			return IsAltKeyDown() or IsControlKeyDown() or IsShiftKeyDown()
		else
			local modType = string.lower(value)
			if modType == "alt" then return IsAltKeyDown()
			elseif modType == "ctrl" or modType == "control" then return IsControlKeyDown()
			elseif modType == "shift" then return IsShiftKeyDown()
			end
		end
		return false
	elseif condType == "nomod" then
		return not IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown()
	end
	return true
end

-- Backward compatibility wrapper
function RoRota.Conditions:EvaluateCondition(cond)
	return RoRotaConditionParser:EvaluateCondition(cond)
end

-- Check ability conditions with multi-line support - parser method
function RoRotaConditionParser:CheckAbilityConditions(abilityName, config)
	if not config then return true, {} end
	if not config.conditions or config.conditions == "" then return true, config end
	local lines = self:ParseConditionLines(config.conditions)
	if not lines then return true, config end
	if RoRota.Debug and RoRota.Debug.enabled then
		RoRota.Debug:Log(string.format("[COND] Checking %s: %s", abilityName, config.conditions))
	end
	for _, line in ipairs(lines) do
		local conditions, overrides = self:ParseConditionLine(line)
		local allMatch = true
		for _, cond in ipairs(conditions) do
			local result = self:EvaluateCondition(cond)
			if RoRota.Debug and RoRota.Debug.enabled then
				RoRota.Debug:Log(string.format("[COND] %s -> %s = %s", abilityName, cond, tostring(result)))
			end
			if not result then
				allMatch = false
				break
			end
		end
		if allMatch then
			if RoRota.Debug and RoRota.Debug.enabled then
				RoRota.Debug:Log(string.format("[COND] %s PASSED", abilityName))
			end
			local mergedConfig = {}
			for k, v in pairs(config) do mergedConfig[k] = v end
			for k, v in pairs(overrides) do mergedConfig[k] = v end
			return true, mergedConfig
		end
	end
	if RoRota.Debug and RoRota.Debug.enabled then
		RoRota.Debug:Log(string.format("[COND] %s FAILED", abilityName))
	end
	return false, config
end

-- Backward compatibility wrapper
function RoRota.Conditions:CheckAbilityConditions(abilityName, config)
	return RoRotaConditionParser:CheckAbilityConditions(abilityName, config)
end

-- Get list of available condition types (for GUI) - parser method
function RoRotaConditionParser:GetAvailableConditions()
	local conditions = {}
	for condType in pairs(self.evaluators) do
		table.insert(conditions, condType)
	end
	table.sort(conditions)
	return conditions
end

-- Backward compatibility wrapper
function RoRota.Conditions:GetAvailableConditions()
	return RoRotaConditionParser:GetAvailableConditions()
end

-- Validate condition syntax - parser method
function RoRotaConditionParser:Validate(conditionString)
	if not conditionString or conditionString == "" then
		return {valid = true, error = nil}
	end
	
	-- Check basic syntax: [type:value]
	local condType, value = string.match(conditionString, "^%[([^:]+):(.+)%]$")
	if not condType then
		return {valid = false, error = "Invalid syntax. Expected [type:value]"}
	end
	
	-- Check if type exists in evaluators
	if not self.evaluators[condType] then
		return {valid = false, error = "Unknown condition type: " .. condType}
	end
	
	-- Type-specific validation
	if condType == "combo" or condType == "cp" then
		local op, num = string.match(value, "^([<>=]+)#?(%d+)$")
		if not op or not num then
			return {valid = false, error = "Invalid combo point syntax. Expected [cp:>=3] or [cp:5]"}
		end
		num = tonumber(num)
		if num < 0 or num > 5 then
			return {valid = false, error = "Combo points must be 0-5"}
		end
	elseif condType == "energy" then
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if not op or not num then
			return {valid = false, error = "Invalid energy syntax. Expected [energy:>=40]"}
		end
		num = tonumber(num)
		if num < 0 or num > 100 then
			return {valid = false, error = "Energy must be 0-100"}
		end
	elseif condType == "php" or condType == "thp" then
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if not op or not num then
			return {valid = false, error = "Invalid health syntax. Expected [php:<30]"}
		end
		num = tonumber(num)
		if num < 0 or num > 100 then
			return {valid = false, error = "Health must be 0-100"}
		end
	end
	
	return {valid = true, error = nil}
end

-- Backward compatibility wrapper
function RoRota.Conditions:Validate(conditionString)
	return RoRotaConditionParser:Validate(conditionString)
end

RoRota.conditions = true
