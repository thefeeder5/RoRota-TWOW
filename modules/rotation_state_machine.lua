--[[ rotation_state_machine ]]--
-- Explicit state machine for rotation execution.
-- States: IDLE → PLANNING → CASTING → GCD
-- Respects off-GCD abilities (Vanish, Riposte, etc) and consumables
--
-- Key functions:
--   Update() - Process current state and check transitions
--   Transition(newState) - Change state with handlers
--   CastAbility(ability, isOffGCD) - Cast with optional off-GCD flag

if not RoRota then return end
if RoRota.rotation_state_machine then return end

RoRotaStateMachine = {
	state = "IDLE",
	lastStateChange = 0,
	gcdEnd = 0,
	
	-- Off-GCD abilities (don't trigger GCD)
	offGCDAbilities = {
		["Vanish"] = true,
		["Feint"] = true,
		["Riposte"] = true,
		["Surprise Attack"] = true,
		["Cold Blood"] = true,
		["Adrenaline Rush"] = true,
		["Sprint"] = true,
		["Preparation"] = true,
		["Kick"] = true,
	},
	
	states = {
		IDLE = {
			enter = function() end,
			update = function() return RoRotaStateMachine:CheckTransitionFromIdle() end,
			exit = function() end,
		},
		PLANNING = {
			enter = function() end,
			update = function() return RoRotaStateMachine:CheckTransitionFromPlanning() end,
			exit = function() end,
		},
		GCD = {
			enter = function() RoRotaStateMachine.gcdEnd = GetTime() + 1.0 end,
			update = function() return RoRotaStateMachine:CheckTransitionFromGCD() end,
			exit = function() end,
		},
	},
}

function RoRotaStateMachine:Transition(newState)
	if not self.states[newState] then
		return false
	end
	
	-- Exit current state
	if self.states[self.state] and self.states[self.state].exit then
		self.states[self.state].exit()
	end
	
	-- Change state
	self.state = newState
	self.lastStateChange = GetTime()
	
	-- Enter new state
	if self.states[newState] and self.states[newState].enter then
		self.states[newState].enter()
	end
	
	return true
end

function RoRotaStateMachine:Update()
	if not self.states[self.state] then
		self:Transition("IDLE")
		return
	end
	
	-- Call state update handler
	if self.states[self.state].update then
		self.states[self.state].update()
	end
end

function RoRotaStateMachine:CheckTransitionFromIdle()
	-- IDLE → PLANNING: when in combat with target
	if UnitAffectingCombat("player") and UnitExists("target") and not UnitIsDead("target") then
		self:Transition("PLANNING")
	end
end

function RoRotaStateMachine:CheckTransitionFromPlanning()
	-- PLANNING → IDLE: no target or out of combat
	if not UnitAffectingCombat("player") or not UnitExists("target") or UnitIsDead("target") then
		self:Transition("IDLE")
	end
end

function RoRotaStateMachine:CheckTransitionFromGCD()
	-- GCD → PLANNING: GCD expired
	if GetTime() >= self.gcdEnd then
		self:Transition("PLANNING")
	end
	
	-- GCD → IDLE: out of combat
	if not UnitAffectingCombat("player") then
		self:Transition("IDLE")
	end
end

function RoRotaStateMachine:GetState()
	return self.state
end

function RoRotaStateMachine:IsOnGCD()
	return self.state == "GCD" and GetTime() < self.gcdEnd
end

function RoRotaStateMachine:CanCast()
	return self.state == "PLANNING" or self.state == "IDLE"
end

function RoRotaStateMachine:CastAbility(ability, isOffGCD)
	-- Check if ability is off-GCD
	local offGCD = isOffGCD or self.offGCDAbilities[ability] or false
	
	if offGCD then
		-- Off-GCD ability: don't trigger GCD, stay in current state
		return true
	else
		-- On-GCD ability: trigger GCD
		self:Transition("GCD")
		return true
	end
end

function RoRotaStateMachine:RegisterOffGCDAbility(abilityName)
	self.offGCDAbilities[abilityName] = true
end

RoRota.rotation_state_machine = true
