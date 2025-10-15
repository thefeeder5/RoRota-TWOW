--[[ constants ]]--
-- RoRota constants and data tables for abilities, damage calculations, and poisons.
-- This module contains all hardcoded values used throughout the addon.
--
-- Data tables:
--   ENERGY_COSTS           - Energy cost per ability
--   EVISCERATE_DAMAGE      - Base damage by rank and combo points
--   RUPTURE_DAMAGE         - Base damage by rank and combo points
--   EVISCERATE_AP_COEF     - Attack power coefficient by combo points
--   RUPTURE_AP_COEF        - Attack power coefficient by combo points
--   ARMOR_MITIGATION       - Armor reduction multiplier (0.75 = 25% reduction)
--   ABILITY_ICONS          - Icon paths for abilities
--   POISON_SPELL_NAMES     - Poison spell names by type and rank (Turtle WoW)
--   POISON_BUFF_PATTERNS   - Pattern matching for poison weapon buffs

RoRotaConstants = {
	ENERGY_TICK_TIME = 2.0,
	ENERGY_PER_TICK = 20,
	COLD_BLOOD_TEXTURE = "Spell_Ice_Lament",
	ENERGY_COSTS = {
		["Sinister Strike"] = 40, ["Eviscerate"] = 30, ["Backstab"] = 60,
		["Gouge"] = 45, ["Slice and Dice"] = 20, ["Sap"] = 65,
		["Kick"] = 25, ["Garrote"] = 50, ["Ambush"] = 60,
		["Rupture"] = 20, ["Cheap Shot"] = 60, ["Kidney Shot"] = 20,
		["Hemorrhage"] = 40, ["Envenom"] = 20, ["Noxious Assault"] = 45,
		["Pick Pocket"] = 0, ["Ghostly Strike"] = 40, ["Feint"] = 20,
		["Expose Armor"] = 20, ["Riposte"] = 10, ["Surprise Attack"] = 40,
		["Mark for Death"] = 40, ["Cold Blood"] = 0,
	},
	EVISCERATE_DAMAGE = {
		[1] = {[1] = 8, [2] = 13, [3] = 18, [4] = 23, [5] = 28},
		[2] = {[1] = 18, [2] = 29, [3] = 40, [4] = 51, [5] = 62},
		[3] = {[1] = 32, [2] = 51, [3] = 70, [4] = 89, [5] = 108},
		[4] = {[1] = 51, [2] = 82, [3] = 113, [4] = 144, [5] = 175},
		[5] = {[1] = 75, [2] = 120, [3] = 165, [4] = 210, [5] = 255},
		[6] = {[1] = 121, [2] = 198, [3] = 275, [4] = 352, [5] = 429},
		[7] = {[1] = 178, [2] = 288, [3] = 398, [4] = 508, [5] = 618},
		[8] = {[1] = 247, [2] = 398, [3] = 549, [4] = 700, [5] = 851},
		[9] = {[1] = 278, [2] = 448, [3] = 618, [4] = 788, [5] = 958},
	},
	RUPTURE_DAMAGE = {
		[1] = {[1] = 40, [2] = 60, [3] = 84, [4] = 112, [5] = 144},
		[2] = {[1] = 60, [2] = 90, [3] = 126, [4] = 168, [5] = 216},
		[3] = {[1] = 88, [2] = 130, [3] = 180, [4] = 238, [5] = 304},
		[4] = {[1] = 128, [2] = 185, [3] = 252, [4] = 329, [5] = 416},
		[5] = {[1] = 176, [2] = 255, [3] = 348, [4] = 455, [5] = 576},
		[6] = {[1] = 272, [2] = 380, [3] = 504, [4] = 644, [5] = 800},
	},
	EVISCERATE_AP_COEF = {[1] = 0.03, [2] = 0.06, [3] = 0.09, [4] = 0.12, [5] = 0.15},
	RUPTURE_AP_COEF = {[1] = 0.04, [2] = 0.10, [3] = 0.18, [4] = 0.21, [5] = 0.24},
	ARMOR_MITIGATION = 0.75,
	-- Energy regeneration
	ENERGY_PER_TICK = 20,  -- base energy per tick
	ENERGY_TICK_TIME = 2.0,  -- base tick time in seconds
	-- Finisher timing
	FINISHER_REFRESH_THRESHOLD = 2,  -- refresh finishers when <= 2s remaining
	ABILITY_ICONS = {
		["Sinister Strike"] = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
		["Backstab"] = "Interface\\Icons\\Ability_BackStab",
		["Hemorrhage"] = "Interface\\Icons\\Ability_Rogue_Hemorrhage",
		["Noxious Assault"] = "Interface\\Icons\\spell_double_dose_3",
		["Ghostly Strike"] = "Interface\\Icons\\Spell_Shadow_Curse",
		["Eviscerate"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
		["Slice and Dice"] = "Interface\\Icons\\Ability_Rogue_SliceDice",
		["Envenom"] = "Interface\\Icons\\INV_Sword_31",
		["Rupture"] = "Interface\\Icons\\Ability_Rogue_Rupture",
		["Expose Armor"] = "Interface\\Icons\\Ability_Warrior_Riposte",
		["Kick"] = "Interface\\Icons\\Ability_Kick",
		["Gouge"] = "Interface\\Icons\\Ability_Gouge",
		["Kidney Shot"] = "Interface\\Icons\\Ability_Rogue_KidneyShot",
		["Ambush"] = "Interface\\Icons\\Ability_Rogue_Ambush",
		["Garrote"] = "Interface\\Icons\\Ability_Rogue_Garrote",
		["Cheap Shot"] = "Interface\\Icons\\Ability_CheapShot",
		["Vanish"] = "Interface\\Icons\\Ability_Vanish",
		["Feint"] = "Interface\\Icons\\Ability_Rogue_Feint",
		["Riposte"] = "Interface\\Icons\\Ability_Warrior_Challange",
		["Surprise Attack"] = "Interface\\Icons\\Ability_Rogue_SurpriseAttack",
		["Pick Pocket"] = "Interface\\Icons\\INV_Misc_Bag_11",
		["No Target"] = "Interface\\Icons\\INV_Misc_QuestionMark",
		["Pooling Energy"] = "Interface\\Icons\\Spell_Nature_Polymorph",
		["Waiting for Energy"] = "Interface\\Icons\\Spell_Nature_Polymorph",
		["Apply Poison"] = "Interface\\Icons\\Ability_Poisons",
		["Smart Eviscerate"] = "Interface\\Icons\\Ability_Rogue_Eviscerate",
		["Cold Blood"] = "Interface\\Icons\\Spell_Ice_Lament",
	},
	POISON_REAGENTS = {
		["Instant Poison"] = {item = "Dust of Deterioration", count = 1},
		["Deadly Poison"] = {item = "Dust of Decay", count = 1},
		["Wound Poison"] = {item = "Dust of Deterioration", count = 1},
		["Crippling Poison"] = {item = "Essence of Pain", count = 1},
		["Mind-numbing Poison"] = {item = "Essence of Agony", count = 1},
	},
	POISON_TYPES = {
		"Agitating Poison",
		"Corrosive Poison",
		"Crippling Poison",
		"Deadly Poison",
		"Dissolvent Poison",
		"Instant Poison",
		"Mind-numbing Poison",
		"Wound Poison",
	},
	POISON_RANKS = {
		["VI"] = 6, ["V"] = 5, ["IV"] = 4,
		["III"] = 3, ["II"] = 2, ["I"] = 1,
	},
	POISON_NAMES = {
		-- English names (add other languages as needed)
		["enUS"] = {
			["Instant Poison"] = "Instant Poison",
			["Deadly Poison"] = "Deadly Poison",
			["Wound Poison"] = "Wound Poison",
			["Crippling Poison"] = "Crippling Poison",
			["Mind-numbing Poison"] = "Mind%-numbing Poison",
			["Anesthetic Poison"] = "Anesthetic Poison",
		},
	},
	POISON_SPELL_NAMES = {
		["Agitating Poison"] = {"Agitating Poison"},
		["Corrosive Poison"] = {"Corrosive Poison II", "Corrosive Poison"},
		["Crippling Poison"] = {"Crippling Poison II", "Crippling Poison"},
		["Deadly Poison"] = {"Deadly Poison V", "Deadly Poison IV", "Deadly Poison III", "Deadly Poison II", "Deadly Poison"},
		["Dissolvent Poison"] = {"Dissolvent Poison II", "Dissolvent Poison"},
		["Instant Poison"] = {"Instant Poison VI", "Instant Poison V", "Instant Poison IV", "Instant Poison III", "Instant Poison II", "Instant Poison"},
		["Mind-numbing Poison"] = {"Mind-numbing Poison III", "Mind-numbing Poison II", "Mind-numbing Poison"},
		["Wound Poison"] = {"Wound Poison IV", "Wound Poison III", "Wound Poison II", "Wound Poison"},
		["Sharpening Stone"] = {"Dense Sharpening Stone", "Solid Sharpening Stone", "Heavy Sharpening Stone", "Coarse Sharpening Stone", "Rough Sharpening Stone"},
	},
	POISON_BUFF_PATTERNS = {
		["Agitating Poison"] = "^Agitating Poison",
		["Corrosive Poison"] = "^Corrosive Poison",
		["Crippling Poison"] = "^Crippling Poison",
		["Deadly Poison"] = "^Deadly Poison",
		["Dissolvent Poison"] = "^Dissolvent Poison",
		["Instant Poison"] = "^Instant Poison",
		["Mind-numbing Poison"] = "^Mind%-numbing Poison",
		["Wound Poison"] = "^Wound Poison",
	},
	-- Combo point generation per ability (Turtle WoW)
	CP_GENERATION = {
		-- Builders (generate CP)
		["Sinister Strike"] = 1,
		["Backstab"] = 1,
		["Gouge"] = 1,
		["Garrote"] = 1,
		["Ambush"] = 1,
		["Cheap Shot"] = 2,
		["Hemorrhage"] = 1,
		["Noxious Assault"] = 1,
		["Ghostly Strike"] = 1,
		["Surprise Attack"] = 1,
		["Mark for Death"] = 2,
		-- Non-CP abilities
		["Sap"] = 0,
		["Kick"] = 0,
		["Feint"] = 0,
		["Riposte"] = 0,
		["Pick Pocket"] = 0,
		["Vanish"] = 0,
		["Sprint"] = 0,
		["Evasion"] = 0,
	},
	-- Finishers
	FINISHERS = {
		["Eviscerate"] = true,
		["Rupture"] = true,
		["Slice and Dice"] = true,
		["Envenom"] = true,
		["Kidney Shot"] = true,
		["Expose Armor"] = true,
		["Cold Blood Eviscerate"] = true,
	},
	-- CP Talent Info (Turtle WoW)
	-- Talents are scanned dynamically by name, not hardcoded positions
	CP_TALENT_NAMES = {
		"Ruthlessness",
		"Relentless Strikes",
		"Seal Fate",
		"Improved Backstab",
		"Setup",
		"Improved Ambush",
		"Initiative",
		"Mark for Death",
	},
}
