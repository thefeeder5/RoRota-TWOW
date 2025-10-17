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

function RoRota:GetDefensiveAbility()
	local defensive = self.db.profile.defensive or {}
	local state = self.State or {}
	
	-- Vanish at low HP
	local playerHP = state.healthPercent or self:GetPlayerHealthPercent()
	if defensive.useVanish and playerHP <= (defensive.vanishHP or 0) then
		if self:HasSpell("Vanish") and not self:IsOnCooldown("Vanish") then
			return "Vanish"
		end
	end
	
	-- Feint (group/raid only)
	if defensive.useFeint and self:IsInGroupOrRaid() and self:HasSpell("Feint") and self:HasEnoughEnergy("Feint") and not self:IsOnCooldown("Feint") then
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
