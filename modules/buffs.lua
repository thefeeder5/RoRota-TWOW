--[[ buffs ]]--
-- Buff and debuff scanning functions.
-- Handles player buffs, target debuffs, and duration tracking.

-- return instantly if already loaded
if RoRota.buffs then return end

function RoRota:HasPlayerBuff(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local name = UnitBuff("player", i)
        if name and string.find(name, buffName) then
            return true
        end
        i = i + 1
    end
    return false
end

function RoRota:HasTargetDebuff(debuffName)
    local i = 1
    while UnitDebuff("target", i) do
        local name = UnitDebuff("target", i)
        if name and string.find(name, debuffName) then
            return true
        end
        i = i + 1
    end
    return false
end

function RoRota:GetBuffTimeRemaining(buffName)
    local i = 1
    while UnitBuff("player", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitBuff("player", i)
        if texture and string.find(texture, buffName) and timeLeft then
            return timeLeft
        end
        i = i + 1
    end
    -- fallback: manual timer tracking
    if buffName == "Slice and Dice" then
        if not RoRota.sndExpiry or RoRota.sndExpiry == 0 then return 0 end
        return math.max(0, RoRota.sndExpiry - GetTime())
    elseif buffName == "Envenom" then
        if not RoRota.envenomExpiry or RoRota.envenomExpiry == 0 then return 0 end
        return math.max(0, RoRota.envenomExpiry - GetTime())
    end
    return 0
end

function RoRota:GetDebuffTimeRemaining(debuffName)
    local i = 1
    while UnitDebuff("target", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitDebuff("target", i)
        if texture and string.find(texture, debuffName) and timeLeft then
            return timeLeft
        end
        i = i + 1
    end
    -- fallback: manual timer tracking (only for Rupture, target-specific)
    if debuffName == "Rupture" then
        if UnitExists("target") and UnitName("target") == RoRota.ruptureTarget then
            if not RoRota.ruptureExpiry or RoRota.ruptureExpiry == 0 then return 0 end
            return math.max(0, RoRota.ruptureExpiry - GetTime())
        end
    end
    return 0
end

function RoRota:CanUseRiposte()
    return self:HasPlayerBuff("Riposte")
end

function RoRota:CanUseSurpriseAttack()
    return self:HasPlayerBuff("Surprise Attack")
end

-- mark module as loaded
RoRota.buffs = true
