--[[ buffs ]]--
-- Buff and debuff scanning functions.
-- Handles player buffs, target debuffs, and duration tracking.

-- return instantly if already loaded
if RoRota.buffs then return end

function RoRota:HasPlayerBuff(buffName)
    for i = 1, 32 do
        local name = UnitBuff("player", i)
        if not name then break end
        if string.find(name, buffName) then
            return true
        end
    end
    return false
end

function RoRota:HasTargetDebuff(debuffName)
    if not RoRotaTooltip then
        CreateFrame("GameTooltip", "RoRotaTooltip", nil, "GameTooltipTemplate")
        RoRotaTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    for i = 1, 32 do
        if not UnitDebuff("target", i) then break end
        RoRotaTooltip:SetUnitDebuff("target", i)
        local tooltipText = RoRotaTooltipTextLeft1:GetText()
        if tooltipText and string.find(tooltipText, debuffName) then
            return true
        end
    end
    return false
end

function RoRota:GetBuffTimeRemaining(buffName)
    if not RoRotaTooltip then
        CreateFrame("GameTooltip", "RoRotaTooltip", nil, "GameTooltipTemplate")
        RoRotaTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    for i = 1, 32 do
        if not UnitBuff("player", i) then break end
        RoRotaTooltip:SetUnitBuff("player", i)
        local tooltipText = RoRotaTooltipTextLeft1:GetText()
        if tooltipText and string.find(tooltipText, buffName) then
            local texture, stacks, debuffType, duration, timeLeft = UnitBuff("player", i)
            if timeLeft and timeLeft > 0 then
                return timeLeft
            end
            -- fallback: manual timer tracking
            if buffName == "Slice and Dice" then
                if not RoRota.sndExpiry or RoRota.sndExpiry == 0 then return 0 end
                return math.max(0, RoRota.sndExpiry - GetTime())
            elseif buffName == "Envenom" then
                if not RoRota.envenomExpiry or RoRota.envenomExpiry == 0 then return 0 end
                return math.max(0, RoRota.envenomExpiry - GetTime())
            end
            return 30
        end
    end
    return 0
end

function RoRota:GetDebuffTimeRemaining(debuffName)
    if not UnitExists("target") then return 0 end
    
    if not RoRotaTooltip then
        CreateFrame("GameTooltip", "RoRotaTooltip", nil, "GameTooltipTemplate")
        RoRotaTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    -- check if debuff exists
    local debuffExists = false
    for i = 1, 32 do
        local texture, stacks, debuffType, duration, timeLeft = UnitDebuff("target", i)
        if not texture then break end
        RoRotaTooltip:ClearLines()
        RoRotaTooltip:SetUnitDebuff("target", i)
        local tooltipText = RoRotaTooltipTextLeft1:GetText()
        if tooltipText and string.find(tooltipText, debuffName) then
            debuffExists = true
            -- SuperWoW provides timeLeft, use it if available
            if timeLeft and timeLeft > 0 then
                return timeLeft
            end
            break
        end
    end
    
    -- use manual timers (set when abilities are cast)
    if debuffExists then
        local targetName = UnitName("target")
        if debuffName == "Rupture" and RoRota.ruptureTarget == targetName and RoRota.ruptureExpiry then
            return math.max(0, RoRota.ruptureExpiry - GetTime())
        elseif debuffName == "Expose Armor" and RoRota.exposeArmorTarget == targetName and RoRota.exposeArmorExpiry then
            return math.max(0, RoRota.exposeArmorExpiry - GetTime())
        end
        -- debuff exists but no timer, return high value to prevent recasting
        -- EA is always 30s, Rupture varies by CP (assume max duration)
        if debuffName == "Expose Armor" then
            return 30
        elseif debuffName == "Rupture" then
            return 22  -- max duration at 5 CP
        end
        return 30
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
