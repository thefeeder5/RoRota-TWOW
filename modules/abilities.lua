--[[ abilities ]]--
-- Spell and ability checking functions.
-- Handles spell availability, energy costs, cooldowns, and spell ranks.

-- return instantly if already loaded
if RoRota.abilities then return end

function RoRota:HasSpell(spellName)
    local i = 1
    while true do
        local spell = GetSpellName(i, BOOKTYPE_SPELL)
        if not spell then break end
        if spell == spellName then return true end
        i = i + 1
    end
    return false
end

function RoRota:GetEnergyCost(spellName)
	local baseCost = RoRotaConstants.ENERGY_COSTS[spellName] or 0
	if not RoRota.TalentCache then return baseCost end
	
	if spellName == "Ghostly Strike" then
		local rank = RoRota.TalentCache.improvedGhostlyStrike
		if rank == 1 then baseCost = baseCost - 3
		elseif rank == 2 then baseCost = baseCost - 6
		elseif rank == 3 then baseCost = baseCost - 10
		end
	elseif spellName == "Hemorrhage" then
		local rank = RoRota.TalentCache.improvedHemorrhage
		if rank == 1 then baseCost = baseCost - 2
		elseif rank == 2 then baseCost = baseCost - 5
		end
	end
	return baseCost
end

function RoRota:HasEnoughEnergy(spellName)
	return UnitMana("player") >= self:GetEnergyCost(spellName)
end

function RoRota:IsOnCooldown(spellIdOrName)
    local success, result1, result2 = pcall(GetSpellCooldown, spellIdOrName)
    -- result1 = start time, result2 = duration
    if success and result1 and result1 > 0 and result2 and result2 > 1.5 then
        return true
    end
    return false
end

function RoRota:GetCooldownRemaining(spellName)
    -- Find spell in spellbook first
    local i = 1
    while true do
        local name = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then
            local start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL)
            if start and start > 0 and duration and duration > 1.5 then
                local remaining = duration - (GetTime() - start)
                return math.max(0, remaining)
            end
            return 0
        end
        i = i + 1
    end
    return 0
end

function RoRota:GetSpellRank(spellName)
    local i = 1
    while true do
        local name, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not name then break end
        if name == spellName then
            if rank and string.find(rank, "Rank ") then
                local r = tonumber(string.sub(rank, 6))
                if r then return r end
            end
        end
        i = i + 1
    end
    return nil
end

-- mark module as loaded
RoRota.abilities = true
