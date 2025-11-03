--[[ buffs ]]--
-- Cached buff and debuff queries.
-- Single scan per frame, indexed lookups for all checks.
--
-- Key functions:
--   UpdateBuffCache() - Scan all buffs/debuffs once (throttled)
--   HasPlayerBuff(name) - Check if player has buff (cached)
--   HasTargetDebuff(name) - Check if target has debuff (cached)
--   GetBuffTimeRemaining(name) - Get buff duration remaining (cached)
--   GetDebuffTimeRemaining(name) - Get debuff duration remaining (cached)

if not RoRota then return end
if RoRota.buffs then return end

RoRota.BuffCache = {
    player = {},
    target = {},
    lastUpdate = 0,
    throttle = 0.05,
}

function RoRota:ScanPlayerBuffs()
    local cache = self.BuffCache.player
    for k in pairs(cache) do cache[k] = nil end
    
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local i = 1
    while UnitBuff("player", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitBuff("player", i)
        if texture then
            local name = string.match(texture, "Interface\\Icons\\(.+)")
            if name then
                cache[name] = {texture, stacks, duration, timeLeft}
            end
            
            RoRotaBuffTooltip:ClearLines()
            RoRotaBuffTooltip:SetUnitBuff("player", i)
            local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
            if tooltipName then
                cache[tooltipName] = {texture, stacks, duration, timeLeft}
            end
        end
        i = i + 1
        if i > 32 then break end
    end
end

function RoRota:ScanTargetDebuffs()
    local cache = self.BuffCache.target
    for k in pairs(cache) do cache[k] = nil end
    
    if not UnitExists("target") then return end
    
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local i = 1
    while UnitDebuff("target", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitDebuff("target", i)
        if texture then
            local name = string.match(texture, "Interface\\Icons\\(.+)")
            if name then
                cache[name] = {texture, stacks, duration, timeLeft}
            end
            
            RoRotaBuffTooltip:ClearLines()
            RoRotaBuffTooltip:SetUnitDebuff("target", i)
            local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
            if tooltipName then
                cache[tooltipName] = {texture, stacks, duration, timeLeft}
            end
        end
        i = i + 1
        if i > 32 then break end
    end
end

function RoRota:UpdateBuffCache()
    local now = GetTime()
    if now - self.BuffCache.lastUpdate < self.BuffCache.throttle then
        return false
    end
    
    self.BuffCache.lastUpdate = now
    self:ScanPlayerBuffs()
    self:ScanTargetDebuffs()
    self:ScanTargetBuffs()
    return true
end

function RoRota:HasPlayerBuff(buffName)
    local now = GetTime()
    if now - self.BuffCache.lastUpdate > 0.1 then
        self:UpdateBuffCache()
    end
    return self.BuffCache.player[buffName] ~= nil
end

function RoRota:HasTargetDebuff(debuffName)
    local now = GetTime()
    if now - self.BuffCache.lastUpdate > 0.1 then
        self:UpdateBuffCache()
    end
    return self.BuffCache.target[debuffName] ~= nil
end

function RoRota:GetBuffTimeRemaining(buffName)
    local buff = self.BuffCache.player[buffName]
    if buff and buff[4] then
        return buff[4]
    end
    
    if buffName == "Slice and Dice" then
        if not self.sndExpiry or self.sndExpiry == 0 then return 0 end
        return math.max(0, self.sndExpiry - GetTime())
    elseif buffName == "Envenom" then
        if not self.envenomExpiry or self.envenomExpiry == 0 then return 0 end
        return math.max(0, self.envenomExpiry - GetTime())
    end
    return 0
end

function RoRota:GetDebuffTimeRemaining(debuffName)
    local debuff = self.BuffCache.target[debuffName]
    if debuff and debuff[4] then
        return debuff[4]
    end
    
    if debuffName == "Rupture" then
        if UnitExists("target") and UnitName("target") == self.ruptureTarget then
            if not self.ruptureExpiry or self.ruptureExpiry == 0 then return 0 end
            return math.max(0, self.ruptureExpiry - GetTime())
        end
    end
    return 0
end

function RoRota:ScanTargetBuffs()
    local cache = self.BuffCache.targetBuffs or {}
    self.BuffCache.targetBuffs = cache
    for k in pairs(cache) do cache[k] = nil end
    
    if not UnitExists("target") then return end
    
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local i = 1
    while UnitBuff("target", i) do
        local texture, stacks, debuffType, duration, timeLeft = UnitBuff("target", i)
        if texture then
            local name = string.match(texture, "Interface\\Icons\\(.+)")
            if name then
                cache[name] = {texture, stacks, duration, timeLeft}
            end
            
            RoRotaBuffTooltip:ClearLines()
            RoRotaBuffTooltip:SetUnitBuff("target", i)
            local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
            if tooltipName then
                cache[tooltipName] = {texture, stacks, duration, timeLeft}
            end
        end
        i = i + 1
        if i > 32 then break end
    end
end

function RoRota:TargetHasImmunityBuff()
    if not UnitExists("target") or not RoRotaDB or not RoRotaDB.immunityBuffs then
        return false
    end
    
    local cache = self.BuffCache.targetBuffs or {}
    for buffName in pairs(RoRotaDB.immunityBuffs) do
        if cache[buffName] then
            return true
        end
    end
    
    return false
end

-- mark module as loaded
RoRota.buffs = true
