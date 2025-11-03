--[[ damage ]]--
-- Pure damage calculation functions.
-- Calculates finisher damage with all modifiers (talents, buffs, AP).
--
-- Key functions:
--   GetAttackPower() - Get current AP
--   CanKillWithEviscerate(cp) - Check if Eviscerate will kill target
--   WouldOverkill(ability, cp) - Check if ability would overkill

if not RoRota then return end
if RoRota.damage then return end

function RoRota:GetAttackPower()
    local base, posBuff, negBuff = UnitAttackPower("player")
    return base + posBuff + negBuff
end

function RoRota:WouldOverkill(spellName, cp)
    if not self.db.profile.overkillPrevention then return false end
    local targetHP = self.Cache and self.Cache.targetHealth or 0
    local damage = 0
    local ap = self:GetAttackPower()
    
    if spellName == "Eviscerate" then
        local rank = self:GetSpellRank("Eviscerate")
        if rank then
            local rankData = RoRotaConstants.EVISCERATE_DAMAGE[rank]
            local baseDmg = rankData and rankData[cp] or 0
            local apBonus = ap * (RoRotaConstants.EVISCERATE_AP_COEF[cp] or 0)
            local talentMod = self:GetImprovedEviscerateMod()
            local relentlessMod = self:GetRelentlessStrikesMod()
            local tasteForBloodMod = self:GetTasteForBloodMod()
            local aggressionMod = self:GetAggressionMod()
            damage = (baseDmg + apBonus) * RoRotaConstants.ARMOR_MITIGATION * talentMod * relentlessMod * tasteForBloodMod * aggressionMod
        end
    elseif spellName == "Rupture" then
        local rank = self:GetSpellRank("Rupture")
        if rank then
            local rankData = RoRotaConstants.RUPTURE_DAMAGE[rank]
            local baseDmg = rankData and rankData[cp] or 0
            local apBonus = ap * (RoRotaConstants.RUPTURE_AP_COEF[cp] or 0)
            local serratedMod = self:GetSerratedBladesMod()
            local totalDmg = (baseDmg + apBonus) * serratedMod
            local duration = 6 + (cp * 2)
            local tickCount = duration / 2
            damage = totalDmg * ((tickCount - 2) / tickCount)
        end
    end
    
    return damage > targetHP
end

function RoRota:CanKillWithEviscerate(cp)
    local targetHP = self.Cache and self.Cache.targetHealth or 0
    local rank = self:GetSpellRank("Eviscerate")
    if not rank then return false end
    local rankData = RoRotaConstants.EVISCERATE_DAMAGE[rank]
    if not rankData then return false end
    local baseDmg = rankData[cp]
    if not baseDmg then return false end
    local ap = self:GetAttackPower()
    local apBonus = ap * (RoRotaConstants.EVISCERATE_AP_COEF[cp] or 0)
    -- apply all damage modifiers
    local talentMod = self:GetImprovedEviscerateMod()
    local relentlessMod = self:GetRelentlessStrikesMod()
    local tasteForBloodMod = self:GetTasteForBloodMod()
    local aggressionMod = self:GetAggressionMod()
    local coldBloodMod = self:HasPlayerBuff("Cold Blood") and 2.0 or 1.0
    local damage = (baseDmg + apBonus) * RoRotaConstants.ARMOR_MITIGATION * talentMod * relentlessMod * tasteForBloodMod * aggressionMod * coldBloodMod
    return damage >= targetHP
end

-- mark module as loaded
RoRota.damage = true
