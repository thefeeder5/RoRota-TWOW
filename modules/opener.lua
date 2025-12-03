--[[ opener ]]--
-- Opener decision module.
-- Returns stealth opener ability or nil.
--
-- Key function:
--   GetOpenerAbility() - Returns opener or nil (stealth only)
--
-- Handles: Pick Pocket, Cold Blood, failsafe, immunity

if not RoRota then return end
if RoRota.opener then return end

-- Module state
local opener_attempts = 0
local pick_pocket_used = false
local cold_blood_ready = false
local last_target = nil
local vanish_opener_mode = false

-- Check if ability meets weapon requirements
local function MeetsWeaponRequirement(abilityName)
	if abilityName == "Ambush" or abilityName == "Backstab" then
		local mhLink = GetInventoryItemLink("player", 16)
		if not mhLink then return false end
		local _, _, _, _, _, _, itemSubType = GetItemInfo(mhLink)
		if not itemSubType then return false end
		return string.find(string.lower(itemSubType), "dagger")
	end
	return true
end

-- Check if opener can be used (weapon + immunity)
local function CanUseOpener(self, abilityName)
	if not abilityName then return false end
	if not MeetsWeaponRequirement(abilityName) then return false end
	if self:IsTargetImmune(abilityName) then return false end
	return true
end

function RoRota:GetOpenerAbility(config, state, cache)
	config = config or (self.db and self.db.profile and self.db.profile.opener) or {}
	state = state or self.State or {}
	cache = cache or self.Cache or {}
	local isStealthed = self:HasPlayerBuff("Stealth")
	if not isStealthed then
		-- Reset opener state when leaving stealth
		state.openerAttempts = 0
		state.pickPocketUsed = false
		state.coldBloodReady = false
		return nil
	end
	
	local openerCfg = config
	local targetName = UnitName("target")
	
	-- Reset state on target switch
	if targetName ~= state.lastOpenerTarget then
		state.openerAttempts = 0
		state.pickPocketUsed = false
		state.coldBloodReady = false
		state.lastOpenerTarget = targetName
	end
	
	-- Pick Pocket (off-GCD, cast with opener)
	if openerCfg.pickPocket and not state.pickPocketUsed and self:HasSpell("Pick Pocket") then
		if not self:TargetHasNoPockets() then
			state.pickPocketUsed = true
			CastSpellByName(self:T("Pick Pocket"))
			-- Continue to opener selection
		end
	end
	
	-- Get opener priority list (Vanish or normal stealth)
	local priority
	if state.vanishOpenerMode then
		-- Use Vanish opener priority
		local vanishCfg = self.db.profile.vanishOpener or {}
		priority = vanishCfg.priority
		if not priority or table.getn(priority) == 0 then
			-- Fallback to normal opener priority if Vanish priority not configured
			priority = openerCfg.priority
		end
	else
		-- Use normal stealth opener priority
		priority = openerCfg.priority
	end
	
	-- Legacy support: convert old config to priority list
	if not priority or table.getn(priority) == 0 then
		priority = {}
		if openerCfg.ability then
			table.insert(priority, {ability = openerCfg.ability, conditions = ""})
		end
		if openerCfg.secondaryAbility then
			table.insert(priority, {ability = openerCfg.secondaryAbility, conditions = ""})
		end
	end
	
	-- Apply failsafe: skip openers based on attempt count
	local failsafeThreshold = openerCfg.failsafeAttempts or -1
	local startIndex = 1
	if failsafeThreshold > 0 and (state.openerAttempts or 0) >= failsafeThreshold then
		startIndex = math.min((state.openerAttempts or 0) + 1, table.getn(priority))
	end
	
	-- Try each opener in priority order (starting from failsafe index)
	local selectedOpener = nil
	for i = startIndex, table.getn(priority) do
		local openerEntry = priority[i]
		local ability = openerEntry.ability
		local conditions = openerEntry.conditions or ""
		
		-- Resolve "Main Builder" placeholder
		if ability == "Main Builder" then
			ability = self.db.profile.mainBuilder or "Sinister Strike"
		end
		
		-- Check implicit requirements (weapon + immunity)
		if CanUseOpener(self, ability) then
			-- Check explicit conditions (optional overrides)
			if conditions == "" then
				selectedOpener = ability
				break
			else
				-- Evaluate conditions using condition system
				if self.Conditions and self.Conditions.CheckAbilityConditions then
					local passed = self.Conditions:CheckAbilityConditions(ability, {conditions = conditions})
					if passed then
						selectedOpener = ability
						break
					end
				else
					-- Fallback if condition system not loaded
					selectedOpener = ability
					break
					end
			end
			end
		end
	
	-- No valid opener found
	if not selectedOpener then
		-- Fallback to builder if enabled
		if openerCfg.useBuilderFallback then
			return nil  -- Let rotation use builder
		else
			return nil
		end
	end
	
	-- Cold Blood before Ambush
	local cbCfg = self.db.profile.cooldowns and self.db.profile.cooldowns.coldBlood
	if not state.coldBloodReady and cbCfg and cbCfg.enabled and selectedOpener == "Ambush" and self:HasSpell("Cold Blood") and not self:IsOnCooldown("Cold Blood") and not self:HasPlayerBuff("Cold Blood") then
		local conditions = cbCfg.conditions or ""
		if conditions == "" or (self.Conditions and self.Conditions:CheckAbilityConditions("Cold Blood", {conditions = conditions})) then
			state.coldBloodReady = true
			return "Cold Blood"
		end
	end
	
	-- Cast selected opener
	state.coldBloodReady = false
	state.vanishOpenerMode = false  -- Reset Vanish mode after opener
	return selectedOpener
end

function RoRota:OnOpenerPositionError()
	if not self.State then self.State = {} end
	self.State.openerAttempts = (self.State.openerAttempts or 0) + 1
end

function RoRota:ResetOpenerState()
	if not self.State then self.State = {} end
	self.State.openerAttempts = 0
	self.State.pickPocketUsed = false
	self.State.coldBloodReady = false
	self.State.lastOpenerTarget = nil
	self.State.vanishOpenerMode = false
end

function RoRota:SetVanishOpenerMode()
	if not self.State then self.State = {} end
	self.State.vanishOpenerMode = true
end

function RoRota:GetOpenerFailsafeInfo()
	if not self.State then self.State = {} end
	return {
		attempts = self.State.openerAttempts or 0,
		threshold = self.db.profile.opener and self.db.profile.opener.failsafeAttempts or -1
	}
end

RoRota.opener = true
