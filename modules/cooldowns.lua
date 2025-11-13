--[[ cooldowns ]]--
-- Cooldown management module.
-- Returns cooldown ability or nil.

if not RoRota then return end
if RoRota.cooldowns then return end

function RoRota:GetCooldownAbility()
    local cfg = self.db.profile.cooldowns
    if not cfg then return nil end
    
    local cp = self.Cache and self.Cache.comboPoints or GetComboPoints("player", "target")
    local energy = self.Cache and self.Cache.energy or UnitMana("player")
    
    -- Cold Blood (before high CP finisher)
    if cfg.coldBlood and cfg.coldBlood.enabled then
        local minCP = cfg.coldBlood.minCP or 5
        if cp >= minCP and self:HasSpell("Cold Blood") and not self:IsOnCooldown("Cold Blood") and not self:HasPlayerBuff("Cold Blood") then
            local conditions = cfg.coldBlood.conditions or ""
            if conditions == "" or (self.Conditions and self.Conditions:CheckAbilityConditions("Cold Blood", {conditions = conditions})) then
                return "Cold Blood"
            end
        end
    end
    
    -- Adrenaline Rush (energy boost)
    if cfg.adrenalineRush and cfg.adrenalineRush.enabled then
        local minEnergy = cfg.adrenalineRush.minEnergy or 20
        if energy <= minEnergy and self:HasSpell("Adrenaline Rush") and not self:IsOnCooldown("Adrenaline Rush") and not self:HasPlayerBuff("Adrenaline Rush") then
            local conditions = cfg.adrenalineRush.conditions or ""
            if conditions == "" or (self.Conditions and self.Conditions:CheckAbilityConditions("Adrenaline Rush", {conditions = conditions})) then
                return "Adrenaline Rush"
            end
        end
    end
    
    -- Sprint (movement)
    if cfg.sprint and cfg.sprint.enabled then
        if self:HasSpell("Sprint") and not self:IsOnCooldown("Sprint") and not self:HasPlayerBuff("Sprint") then
            local conditions = cfg.sprint.conditions or ""
            if conditions ~= "" and self.Conditions and self.Conditions:CheckAbilityConditions("Sprint", {conditions = conditions}) then
                return "Sprint"
            end
        end
    end
    
    -- Preparation (cooldown reset)
    if cfg.preparation and cfg.preparation.enabled then
        if self:HasSpell("Preparation") and not self:IsOnCooldown("Preparation") then
            local conditions = cfg.preparation.conditions or ""
            if conditions ~= "" and self.Conditions and self.Conditions:CheckAbilityConditions("Preparation", {conditions = conditions}) then
                return "Preparation"
            end
        end
    end
    
    return nil
end

RoRota.cooldowns = true
