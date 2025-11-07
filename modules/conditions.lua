--[[ conditions ]]--
-- Centralized condition evaluation system
-- Provides reusable condition checks for rotation logic

if not RoRota then return end
if RoRota.conditions then return end

RoRota.Conditions = {}

-- Condition evaluators (return true/false)
local evaluators = {
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
		return RoRota:IsUnitCasting("target", spellName)
	end,
	
	target_not_casting = function(spellName)
		return not RoRota:IsUnitCasting("target", spellName)
	end,
}

-- Evaluate a single condition
function RoRota.Conditions:Evaluate(conditionType, arg1, arg2, arg3, arg4, arg5)
	local evaluator = evaluators[conditionType]
	if not evaluator then
		return false
	end
	
	local success, result = pcall(evaluator, arg1, arg2, arg3, arg4, arg5)
	if not success then
		return false
	end
	
	return result
end

-- Evaluate multiple conditions with AND logic
function RoRota.Conditions:EvaluateAll(conditions)
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

-- Evaluate multiple conditions with OR logic
function RoRota.Conditions:EvaluateAny(conditions)
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

-- Parse multi-line conditions
function RoRota.Conditions:ParseConditionLines(condStr)
	if not condStr or condStr == "" then return nil end
	local lines = {}
	for line in string.gfind(condStr, "([^\n]+)") do
		local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
		if trimmed ~= "" then table.insert(lines, trimmed) end
	end
	return table.getn(lines) > 0 and lines or nil
end

-- Parse single line: [cond1,cond2] override1=val
function RoRota.Conditions:ParseConditionLine(line)
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

-- Evaluate single condition
function RoRota.Conditions:EvaluateCondition(cond)
	local condType, value = string.match(cond, "^([^:]+):(.+)$")
	if not condType then condType, value = cond, nil end
	-- DEBUG: condType and value
	if condType == "buff" or condType == "nobuff" then
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasBuff = RoRota:HasPlayerBuff(name)
			if condType == "nobuff" then return not hasBuff end
			if not hasBuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetBuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasBuff = RoRota:HasPlayerBuff(value)
			return condType == "buff" and hasBuff or not hasBuff
		end
	elseif condType == "debuff" or condType == "nodebuff" then
		if not value then return true end
		local name, op, num = string.match(value, "^(.+)([<>=]+)#?(%d+)$")
		if name then
			local hasDebuff = RoRota:HasTargetDebuff(name)
			if condType == "nodebuff" then return not hasDebuff end
			if not hasDebuff then return false end
			if not string.find(value, "#") then
				local time = RoRota:GetDebuffTimeRemaining(name)
				if op == "<" then return time < tonumber(num)
				elseif op == ">" then return time > tonumber(num) end
			end
			return true
		else
			local hasDebuff = RoRota:HasTargetDebuff(value)
			return condType == "debuff" and hasDebuff or not hasDebuff
		end
	elseif condType == "type" or condType == "notype" then
		local classification = UnitClassification("target")
		local match = (string.lower(value) == "boss" and classification == "worldboss") or (string.lower(value) == "worldboss" and classification == "worldboss") or (string.lower(value) == "elite" and (classification == "elite" or classification == "rareelite"))
		return condType == "type" and match or not match
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
	elseif condType == "hp" then
		local hp = RoRota.Cache and RoRota.Cache.targetHealthPercent or 100
		local op, num = string.match(value, "^([<>=]+)(%d+)$")
		if op and num then
			num = tonumber(num)
			if op == ">" then return hp > num
			elseif op == "<" then return hp < num
			elseif op == ">=" then return hp >= num
			elseif op == "<=" then return hp <= num end
		end
	end
	return true
end

-- Check ability conditions with multi-line support
function RoRota.Conditions:CheckAbilityConditions(abilityName, config)
	if not config or not config.conditions or config.conditions == "" then return true, config end
	local lines = self:ParseConditionLines(config.conditions)
	if not lines then return true, config end
	-- DEBUG: Checking conditions
	for _, line in ipairs(lines) do
		local conditions, overrides = self:ParseConditionLine(line)
		local allMatch = true
		for _, cond in ipairs(conditions) do
			local result = self:EvaluateCondition(cond)
			if not result then
				allMatch = false
				break
			end
		end
		if allMatch then
			local mergedConfig = {}
			for k, v in pairs(config) do mergedConfig[k] = v end
			for k, v in pairs(overrides) do mergedConfig[k] = v end
			return true, mergedConfig
		end
	end
	return false, config
end

-- Get list of available condition types (for GUI)
function RoRota.Conditions:GetAvailableConditions()
	local conditions = {}
	for condType in pairs(evaluators) do
		table.insert(conditions, condType)
	end
	table.sort(conditions)
	return conditions
end

RoRota.conditions = true
