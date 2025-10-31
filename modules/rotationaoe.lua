--[[ rotationaoe ]]--
-- AoE rotation logic with Blade Flurry

if not RoRota then return end

-- AoE rotation entry point
function RoRotaRunAOERotation()
	-- Enable Blade Flurry if not active
	if not RoRota:HasPlayerBuff("Blade Flurry") then
		if RoRota:HasSpell("Blade Flurry") and not RoRota:IsOnCooldown("Blade Flurry") then
			CastSpellByName("Blade Flurry")
			return
		end
	end
	
	local profile = RoRota.db and RoRota.db.profile
	if not profile or not profile.aoe then return end
	
	-- 1. Interrupt (if enabled)
	if profile.aoe.useInterrupts then
		local ability = RoRota.GetInterruptAbility and RoRota:GetInterruptAbility()
		if ability then
			CastSpellByName(ability)
			RoRota.targetCasting = false
			return
		end
	end
	
	-- 2. Defensive (if enabled)
	if profile.aoe.useDefensive then
		local ability = RoRota.GetDefensiveAbility and RoRota:GetDefensiveAbility()
		if ability then
			CastSpellByName(ability)
			return
		end
	end
	
	-- 3. AoE rotation
	local cp = GetComboPoints("player", "target")
	local energy = UnitMana("player")
	
	local aoeBuilder = profile.aoe.builder or "Sinister Strike"
	local aoeFinisher = profile.aoe.finisher or "Eviscerate"
	local finisherMinCP = profile.aoe.finisherMinCP or 5
	local useSnD = profile.aoe.useSnD
	local sndMaxCP = profile.aoe.sndMaxCP or 5
	
	-- Check SnD first if enabled
	if useSnD and RoRota:HasSpell("Slice and Dice") and cp <= sndMaxCP then
		local sndTimeLeft = RoRota:GetBuffTimeRemaining("Slice and Dice") or 0
		local refreshThreshold = profile.finisherRefreshThreshold or 2
		
		if sndTimeLeft <= refreshThreshold then
			local sndCost = RoRota:GetEnergyCost("Slice and Dice") or 20
			if energy >= sndCost then
				CastSpellByName("Slice and Dice")
				local duration = 9 + (cp * 3)
				RoRota.sndExpiry = GetTime() + duration
				return
			end
		end
	end
	
	-- Use damage finisher
	if cp >= finisherMinCP then
		local finisherCost = RoRota:GetEnergyCost(aoeFinisher) or 30
		if energy >= finisherCost then
			CastSpellByName(aoeFinisher)
			return
		end
	else
		local builderCost = RoRota:GetEnergyCost(aoeBuilder) or 40
		if energy >= builderCost then
			CastSpellByName(aoeBuilder)
			return
		end
	end
end
