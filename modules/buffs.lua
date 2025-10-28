--[[ buffs ]]--
-- Read-only buff and debuff queries.
-- Scans player buffs and target debuffs with duration tracking.
--
-- Key functions:
--   HasPlayerBuff(name) - Check if player has buff
--   HasTargetDebuff(name) - Check if target has debuff
--   GetBuffTimeRemaining(name) - Get buff duration remaining
--   GetDebuffTimeRemaining(name) - Get debuff duration remaining

if not RoRota then return end
if RoRota.buffs then return end

function RoRota:HasPlayerBuff(buffName)
    -- Create tooltip if it doesn't exist
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local i = 1
    while UnitBuff("player", i) do
        local texture = UnitBuff("player", i)
        if texture then
            -- Check texture path first (fast)
            if string.find(texture, buffName) then
                return true
            end
            -- Check actual buff name via tooltip (slower but accurate)
            RoRotaBuffTooltip:ClearLines()
            RoRotaBuffTooltip:SetUnitBuff("player", i)
            local tooltipText = RoRotaBuffTooltipTextLeft1:GetText()
            if tooltipText and string.find(tooltipText, buffName) then
                return true
            end
        end
        i = i + 1
        if i > 40 then break end
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

function RoRota:TargetHasImmunityBuff()
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.immunityBuffs then
        return false
    end
    
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local i = 1
    while UnitBuff("target", i) do
        local texture = UnitBuff("target", i)
        if texture then
            RoRotaBuffTooltip:ClearLines()
            RoRotaBuffTooltip:SetUnitBuff("target", i)
            local tooltipText = RoRotaBuffTooltipTextLeft1:GetText()
            if tooltipText and RoRotaDB.immunityBuffs[tooltipText] then
                return true
            end
        end
        i = i + 1
        if i > 32 then break end
    end
    
    return false
end

-- mark module as loaded
RoRota.buffs = true
