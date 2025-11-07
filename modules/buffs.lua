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
                local englishKey = RoRota:FromLocale(tooltipName)
                if englishKey ~= tooltipName then
                    cache[englishKey] = {texture, stacks, duration, timeLeft}
                end
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
                local englishKey = RoRota:FromLocale(tooltipName)
                if englishKey ~= tooltipName then
                    cache[englishKey] = {texture, stacks, duration, timeLeft}
                end
            end
        end
        i = i + 1
        if i > 32 then break end
    end
end

function RoRota:CheckSpecificBuff(unit, buffName)
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local cache = self.BuffCache.player
    local i = 1
    while UnitBuff(unit, i) do
        RoRotaBuffTooltip:ClearLines()
        RoRotaBuffTooltip:SetUnitBuff(unit, i)
        local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
        if tooltipName == buffName or RoRota:FromLocale(tooltipName) == buffName then
            local texture, stacks, debuffType, duration, timeLeft = UnitBuff(unit, i)
            cache[buffName] = {texture, stacks, duration, timeLeft}
            return true
        end
        i = i + 1
        if i > 32 then break end
    end
    cache[buffName] = nil
    return false
end

function RoRota:CheckSpecificDebuff(unit, debuffName)
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local cache = self.BuffCache.target
    local i = 1
    while UnitDebuff(unit, i) do
        RoRotaBuffTooltip:ClearLines()
        RoRotaBuffTooltip:SetUnitDebuff(unit, i)
        local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
        if tooltipName == debuffName or RoRota:FromLocale(tooltipName) == debuffName then
            local texture, stacks, debuffType, duration, timeLeft = UnitDebuff(unit, i)
            cache[debuffName] = {texture, stacks, duration, timeLeft}
            return true
        end
        i = i + 1
        if i > 32 then break end
    end
    cache[debuffName] = nil
    return false
end

function RoRota:UpdateBuffCache()
    local now = GetTime()
    if now - self.BuffCache.lastUpdate < self.BuffCache.throttle then
        return false
    end
    
    self.BuffCache.lastUpdate = now
    
    -- Selective scanning: only check what we need
    -- Most finishers tracked via UNIT_CASTEVENT
    
    -- Always check Stealth (opener + vanish detection)
    self:CheckSpecificBuff("player", "Stealth")
    
    -- Check Blade Flurry (for canceling)
    self:CheckSpecificBuff("player", "Blade Flurry")
    
    -- Check Cold Blood if CB Eviscerate enabled
    if self.db and self.db.profile and self.db.profile.abilities then
        if self.db.profile.abilities.ColdBloodEviscerate and self.db.profile.abilities.ColdBloodEviscerate.enabled then
            self:CheckSpecificBuff("player", "Cold Blood")
        end
    end
    
    -- Check target debuffs only if abilities enabled
    if UnitExists("target") then
        if self.db and self.db.profile and self.db.profile.abilities then
            if self.db.profile.abilities.Hemorrhage and self.db.profile.abilities.Hemorrhage.enabled then
                self:CheckSpecificDebuff("target", "Hemorrhage")
            end
        end
        
        if self.db and self.db.profile and self.db.profile.ttk and self.db.profile.ttk.enabled then
            self:CheckSpecificDebuff("target", "Garrote")
        end
    end
    
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
    
    if self.CombatLog then
        local remaining = self.CombatLog:GetBuffTimeRemaining(buffName)
        if remaining > 0 then return remaining end
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
    
    if self.CombatLog then
        local remaining = self.CombatLog:GetDebuffTimeRemaining(debuffName)
        if remaining > 0 then return remaining end
    end
    
    if debuffName == "Rupture" then
        if UnitExists("target") and UnitName("target") == self.ruptureTarget then
            if not self.ruptureExpiry or self.ruptureExpiry == 0 then return 0 end
            return math.max(0, self.ruptureExpiry - GetTime())
        end
    elseif debuffName == "Expose Armor" then
        if UnitExists("target") and UnitName("target") == self.exposeArmorTarget then
            if not self.exposeArmorExpiry or self.exposeArmorExpiry == 0 then return 0 end
            return math.max(0, self.exposeArmorExpiry - GetTime())
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
                local englishKey = RoRota:FromLocale(tooltipName)
                if englishKey ~= tooltipName then
                    cache[englishKey] = {texture, stacks, duration, timeLeft}
                end
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
    
    if not RoRotaBuffTooltip then
        CreateFrame("GameTooltip", "RoRotaBuffTooltip", nil, "GameTooltipTemplate")
        RoRotaBuffTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    
    local rogueDebuffs = {
        ["Noxious Assault"] = true,
        ["Rupture"] = true,
        ["Garrote"] = true,
        ["Expose Armor"] = true,
        ["Hemorrhage"] = true,
    }
    
    -- Only scan target buffs when checking immunity
    local i = 1
    while UnitBuff("target", i) do
        RoRotaBuffTooltip:ClearLines()
        RoRotaBuffTooltip:SetUnitBuff("target", i)
        local tooltipName = RoRotaBuffTooltipTextLeft1:GetText()
        if tooltipName then
            local englishKey = RoRota:FromLocale(tooltipName)
            if RoRotaDB.immunityBuffs[tooltipName] or RoRotaDB.immunityBuffs[englishKey] then
                if not rogueDebuffs[tooltipName] and not rogueDebuffs[englishKey] then
                    return true
                end
            end
        end
        i = i + 1
        if i > 32 then break end
    end
    
    return false
end

-- mark module as loaded
RoRota.buffs = true
