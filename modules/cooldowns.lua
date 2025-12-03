--[[ cooldowns ]]--
-- Cooldown management module.
-- Returns cooldown ability or nil.

if not RoRota then return end
if RoRota.cooldowns then return end

function RoRota:GetCooldownAbility(config, state, cache)
    config = config or (self.db and self.db.profile and self.db.profile.cooldowns) or {}
    state = state or self.State or {}
    cache = cache or self.Cache or {}
    if not config then return nil end
    
    local cp = cache.comboPoints or GetComboPoints("player", "target")
    local energy = cache.energy or UnitMana("player")
    
    -- Cold Blood (before high CP finisher)
    if config.coldBlood and config.coldBlood.enabled then
        local minCP = config.coldBlood.minCP or 5
        if cp >= minCP and self:HasSpell("Cold Blood") and not self:IsOnCooldown("Cold Blood") and not self:HasPlayerBuff("Cold Blood") then
            local conditions = config.coldBlood.conditions or ""
            if conditions == "" or (self.Conditions and self.Conditions:CheckAbilityConditions("Cold Blood", {conditions = conditions})) then
                return "Cold Blood"
            end
        end
    end
    
    -- Adrenaline Rush (energy boost)
    if config.adrenalineRush and config.adrenalineRush.enabled then
        local minEnergy = config.adrenalineRush.minEnergy or 20
        if energy <= minEnergy and self:HasSpell("Adrenaline Rush") and not self:IsOnCooldown("Adrenaline Rush") and not self:HasPlayerBuff("Adrenaline Rush") then
            local conditions = config.adrenalineRush.conditions or ""
            if conditions == "" or (self.Conditions and self.Conditions:CheckAbilityConditions("Adrenaline Rush", {conditions = conditions})) then
                return "Adrenaline Rush"
            end
        end
    end
    
    -- Sprint (movement)
    if config.sprint and config.sprint.enabled then
        if self:HasSpell("Sprint") and not self:IsOnCooldown("Sprint") and not self:HasPlayerBuff("Sprint") then
            local conditions = config.sprint.conditions or ""
            if conditions ~= "" and self.Conditions and self.Conditions:CheckAbilityConditions("Sprint", {conditions = conditions}) then
                return "Sprint"
            end
        end
    end
    
    -- Preparation (cooldown reset)
    if config.preparation and config.preparation.enabled then
        if self:HasSpell("Preparation") and not self:IsOnCooldown("Preparation") then
            local conditions = config.preparation.conditions or ""
            if conditions ~= "" and self.Conditions and self.Conditions:CheckAbilityConditions("Preparation", {conditions = conditions}) then
                return "Preparation"
            end
        end
    end
    
    return nil
end

RoRota.cooldowns = true
