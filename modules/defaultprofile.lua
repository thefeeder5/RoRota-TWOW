-- RoRota Default Profile Module
-- Default profile configuration for new characters

RoRotaDefaultProfile = {
	abilities = {
		SliceAndDice = {enabled = true, minCP = 1, maxCP = 2, targetMinHP = 10, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, refreshThreshold = 2, conditions = ""},
		Eviscerate = {enabled = true, targetMinHP = 0, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, smartEviscerate = true, useColdBlood = false, coldBloodMinCP = 4},
		SinisterStrike = {enabled = true},
		NoxiousAssault = {enabled = false},
		Envenom = {enabled = false, minCP = 1, maxCP = 2, targetMinHP = 10, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, refreshThreshold = 2, conditions = ""},
		Rupture = {enabled = false, minCP = 1, maxCP = 5, targetMinHP = 15, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, refreshThreshold = 2, conditions = ""},
		ExposeArmor = {enabled = false, minCP = 5, maxCP = 5, targetMinHP = 0, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, refreshThreshold = 2, conditions = ""},
		ColdBloodEviscerate = {enabled = false, minCP = 4, maxCP = 5, targetMinHP = 0, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false},
		ShadowOfDeath = {enabled = false, minCP = 5, maxCP = 5, targetMinHP = 0, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, refreshThreshold = 2, conditions = ""},
		KidneyShot = {enabled = false, minCP = 1, maxCP = 5, targetMinHP = 0, targetMaxHP = 100, useFlatHP = false, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, conditions = ""},
		Flourish = {enabled = false, minCP = 1, maxCP = 2, playerMinHP = 0, playerMaxHP = 100, onlyElites = false, refreshThreshold = 2, conditions = ""},
		MarkForDeath = {enabled = false, targetMinHP = 0, targetMaxHP = 100, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, conditions = ""},
		Hemorrhage = {enabled = false, targetMinHP = 0, targetMaxHP = 100, targetMinHPFlat = 0, targetMaxHPFlat = 9999999, onlyElites = false, onlyWhenMissing = false, conditions = ""},
		Backstab = {enabled = false, failsafeAttempts = 3},
	},
	mainBuilder = "Sinister Strike",
	secondaryBuilder = "Sinister Strike",
	builderFailsafe = 3,
	smartBuilders = false,
	buffPriority = "Slice and Dice",
	opener = {
		-- Legacy support (converted to priority list on load)
		ability = "Ambush",
		secondaryAbility = "Sinister Strike",
		failsafeAttempts = 3,
		pickPocket = false,
		useColdBlood = false,
		sapFailAction = "None",
		-- New priority system
		priority = {
			{ability = "Ambush", conditions = ""},
			{ability = "Garrote", conditions = ""},
			{ability = "Cheap Shot", conditions = ""},
		},
		useBuilderFallback = true,  -- Use builder if all openers fail
		equipmentSet = nil,  -- Equipment set to swap to before stealth opener
	},
	interrupt = {
		useKick = true,
		useDeadlyThrow = false,
		useGouge = false,
		useKidneyShot = false,
		kidneyMaxCP = 2,
		filterMode = "Interrupt All (Ignore List)",
		filterList = {},
		history = {},
	},
	finisherPriority = {"Slice and Dice", "Flourish", "Envenom", "Rupture", "Expose Armor", "Shadow of Death", "Kidney Shot", "Cold Blood Eviscerate"},
	smartRupture = true,
	finisherRefreshThreshold = 2,  -- refresh finishers when <= X seconds remaining (0-3s)
	previewDepth = 1,  -- show 1-3 abilities in preview window
	defensive = {
		useVanish = false,
		vanishHP = 20,
		vanishConditions = "",
		useGhostlyStrike = false,
		ghostlyTargetMaxHP = 30,
		ghostlyPlayerMinHP = 1,
		ghostlyPlayerMaxHP = 90,
		ghostlyTargetedOnly = false,
		ghostlyConditions = "",
		useFeint = false,
		feintMode = "Always",
		useRiposte = false,
		riposteTargetMinHP = 0,
		riposteTargetMaxHP = 100,
		riposteConditions = "",
		useSurpriseAttack = false,
		surpriseTargetMinHP = 0,
		surpriseTargetMaxHP = 100,
		surpriseConditions = "",
		useHealthPotion = false,
		healthPotionHP = 30,
		evasion = {enabled = false, hpThreshold = 30},
	},
	cooldowns = {
		coldBlood = {enabled = false},
		sprint = {enabled = false},
		adrenalineRush = {enabled = false},
		bladeFlurry = {enabled = false},
	},
	poisons = {
		enabled = true,
		timeThreshold = 180,
		chargesThreshold = 10,
		autoApply = false,
		applyInCombat = false,
		mainHandPoison = "None",
		offHandPoison = "None",
	},
	ttk = {
		enabled = true,
		excludeBosses = false,
	},
	aoe = {
		useInterrupts = true,
		useDefensive = true,
		builder = "Sinister Strike",
		finisher = "Eviscerate",
		finisherMinCP = 5,
		useSnD = true,
		sndMaxCP = 5,
	},
	equipmentSets = {},
	vanishOpener = {
		priority = {
			{ability = "Ambush", conditions = ""},
			{ability = "Garrote", conditions = ""},
		},
		useBuilderFallback = true,
		equipmentSet = nil,  -- Equipment set to swap to after Vanish
	},
	profileSwitching = {
		enabled = false,
		solo = "Default",
		group = "Default",
		raid = "Default",
	},
	preview = {enabled = false},
	notifications = {
		addonMessages = true,
		interruptAnnounce = "None",
	},
	consumables = {
		thistleTea = {enabled = false, energyThreshold = 20},
	},
}
