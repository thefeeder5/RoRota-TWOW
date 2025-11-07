--[[ enUS locale ]]--
local L = AceLibrary("AceLocale-2.2"):new("RoRota")

L:RegisterTranslations("enUS", function() return {
	-- Builders
	["Sinister Strike"] = true,
	["Backstab"] = true,
	["Noxious Assault"] = true,
	["Hemorrhage"] = true,
	["Ghostly Strike"] = true,
	["Ambush"] = true,
	["Mutilate"] = true,
	["Gouge"] = true,
	["Riposte"] = true,
	["Surprise Attack"] = true,
	
	-- Finishers
	["Slice and Dice"] = true,
	["Envenom"] = true,
	["Rupture"] = true,
	["Eviscerate"] = true,
	["Expose Armor"] = true,
	["Kidney Shot"] = true,
	["Cheap Shot"] = true,
	["Shadow of Death"] = true,
	
	-- Openers
	["Garrote"] = true,
	["Sap"] = true,
	["Pick Pocket"] = true,
	
	-- Cooldowns
	["Cold Blood"] = true,
	["Blade Flurry"] = true,
	["Adrenaline Rush"] = true,
	["Evasion"] = true,
	["Vanish"] = true,
	["Feint"] = true,
	["Sprint"] = true,
	["Kick"] = true,
	["Mark for Death"] = true,
	
	-- Buffs
	["Stealth"] = true,
	["Taste for Blood"] = true,
	
	-- Poisons
	["Instant Poison"] = true,
	["Deadly Poison"] = true,
	["Wound Poison"] = true,
	["Mind-numbing Poison"] = true,
	["Crippling Poison"] = true,
	["Anesthetic Poison"] = true,
} end)
