--[[ defensive ]]--
-- Defensive decision module.
-- Returns defensive ability or nil based on survival conditions.
--
-- Key function:
--   GetDefensiveAbility() - Returns Vanish/Feint/Riposte/Surprise Attack or nil
--
-- Checks: HP thresholds, threat, parry/dodge events

if not RoRota then return end
if RoRota.defensive then return end

function RoRota:GetDefensiveAbility(config, state, cache)
	config = config or (self.db and self.db.profile and self.db.profile.defensive) or {}
	state = state or self.State or {}
	cache = cache or self.Cache or {}
	local defensive = config
	
	-- Health potion at low HP
	local playerHP = cache.healthPercent or 100
	if defensive.useHealthPotion and self.UseHealthPotion then
		if self:UseHealthPotion() then
			return nil
		end
	end
	
	-- Vanish at low HP (check current HP, not cached)
	if defensive.useVanish then
		local currentHP = (UnitHealth("player") / UnitHealthMax("player")) * 100
		if currentHP <= (defensive.vanishHP or 0) then
			if self:HasSpell("Vanish") and not self:IsOnCooldown("Vanish", true) then
				return "Vanish"
			end
		end
	end
	
	-- Feint (group/raid only)
	if defensive.useFeint and self:IsInGroupOrRaid() and self:HasSpell("Feint") and self:HasEnoughEnergy("Feint") and not self:IsOnCooldown("Feint", true) then
		local shouldFeint = false
		if defensive.feintMode == "Always" then
			shouldFeint = true
		elseif defensive.feintMode == "WhenTargeted" and self:IsPlayerTargeted() then
			shouldFeint = true
		elseif defensive.feintMode == "HighThreat" then
			local threat = self:GetThreatSituation()
			if threat >= 2 then
				shouldFeint = true
			end
		end
		if shouldFeint then
			return "Feint"
		end
	end
	
	return nil
end

RoRota.defensive = true
