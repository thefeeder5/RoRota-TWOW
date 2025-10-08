--[[ talents ]]--
-- Talent modifier functions for damage calculations.
-- Returns multipliers based on talent ranks.

-- return instantly if already loaded
if RoRota.talents then return end

function RoRota:GetImprovedEviscerateMod()
    local _, _, _, _, rank = GetTalentInfo(1, 1)
    if rank == 1 then return 1.05
    elseif rank == 2 then return 1.10
    elseif rank == 3 then return 1.15
    end
    return 1.0
end

function RoRota:GetRelentlessStrikesMod()
    local i = 1
    while UnitBuff("player", i) do
        local texture, stacks = UnitBuff("player", i)
        if texture and string.find(texture, "Relentless Strikes") then
            return 1.0 + (stacks or 1) * 0.05
        end
        i = i + 1
    end
    return 1.0
end

function RoRota:GetTasteForBloodMod()
    local _, _, _, _, talentRank = GetTalentInfo(1, 10)
    if talentRank == 0 then return 1.0 end
    local dmgPerCP = talentRank * 0.01
    local i = 1
    while UnitBuff("player", i) do
        local texture, stacks = UnitBuff("player", i)
        if texture and string.find(texture, "Taste for Blood") then
            return 1.0 + (stacks or 0) * dmgPerCP
        end
        i = i + 1
    end
    return 1.0
end

function RoRota:GetAggressionMod()
    local _, _, _, _, rank = GetTalentInfo(2, 17)
    if rank == 1 then return 1.03
    elseif rank == 2 then return 1.06
    elseif rank == 3 then return 1.10
    end
    return 1.0
end

function RoRota:GetSerratedBladesMod()
    local _, _, _, _, rank = GetTalentInfo(3, 6)
    if rank == 1 then return 1.10
    elseif rank == 2 then return 1.20
    elseif rank == 3 then return 1.30
    end
    return 1.0
end

function RoRota:HasAdrenalineRush()
    return self:HasPlayerBuff("Adrenaline Rush")
end

-- mark module as loaded
RoRota.talents = true
