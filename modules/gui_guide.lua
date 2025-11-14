-- RoRota Guide Display Module
-- Shows the guide in a scrollable window

if not RoRota then return end

local guideText = [[
|cFFFFD700RoRota Guide|r

|cFFFFFF00How Rotation Works|r
The addon uses a priority system from top to bottom:
1. Interrupt - Kick/Gouge/Kidney Shot
2. Defensive - Vanish/Feint/Riposte/Evasion
3. Cooldowns - Cold Blood/AR/Sprint/Prep (off-GCD)
4. Opener - Stealth openers
5. Finishers - SnD/Envenom/Rupture/Evis/etc
6. Builders - SS/BS/Hemo/Noxious Assault

For each priority level, the addon checks every ENABLED ability
from top to bottom. If the ability's conditions are met, it casts
that ability and stops. If conditions fail, it moves to the next
ability. If no ability in that priority level can be cast, it moves
to the next priority level.

|cFFFFFF00Condition Syntax|r
Player Buffs: pbuff:Name, pnobuff:Name
Player Debuffs: pdebuff:Name, pnodebuff:Name
Target Buffs: tbuff:Name, tnobuff:Name
Target Debuffs: tdebuff:Name, tnodebuff:Name
Health: php<50, php>80, thp<30, thp>50
Target Type: type:boss, type:elite, type:worldboss, notype:elite
Combo Points: combo>3, combo=5, combo<2
Equipped: equipped:dagger, equipped:sword, equipped:mace
Immunity: noimmunity:bleed, noimmunity:stun, noimmunity:incap

Examples:
  pbuff:Cold Blood - Player has Cold Blood buff
  pnobuff:Sprint - Player does NOT have Sprint
  tdebuff:Rupture<5 - Rupture expires in <5 sec
  php<40 - Player health below 40%
  thp>80 - Target health above 80%
  type:elite - Target is elite or rare elite
  equipped:dagger - Main hand is a dagger

|cFFFFFF00Extra Conditions|r
Extra conditions let you override ability settings based on
situations. They work LINE BY LINE from top to bottom.

How it works:
1. Addon reads first line
2. Checks ALL conditions in [brackets] (comma-separated)
3. If ALL conditions are TRUE, applies overrides after brackets
4. If ANY condition is FALSE, moves to next line
5. Stops at first matching line

Format: [condition1,condition2]setting=value,setting2=value2

Overridable values:
- enabled (0 or 1) - Enable/disable ability
- minCP (1-5) - Minimum combo points
- maxCP (1-5) - Maximum combo points
- refreshThreshold (seconds) - Refresh buff/debuff at X sec
- targetMinHP (0-100) - Only use if target HP above %
- targetMaxHP (0-100) - Only use if target HP below %

Examples:

Slice and Dice - don't refresh on dying targets:
  [thp<30]refreshThreshold=0
Meaning: If target below 30% HP, don't refresh SnD.

Envenom - use at lower CP on bosses:
  [type:boss]minCP=4
Meaning: On bosses, use Envenom at 4+ CP instead of
waiting for 5 CP.

Rupture - only on high HP targets:
  [thp<40]enabled=0
Meaning: Don't use Rupture if target below 40% HP.

Evasion - only when low health:
  [php<30]enabled=1
Meaning: Only use Evasion when below 30% health.

Cold Blood - save for Ambush on elites:
  [type:elite,pnobuff:Stealth]enabled=0
Meaning: Don't use Cold Blood on elites unless stealthed.

|cFFFFFF00Immunity System|r
Immune Targets: Mob names immune to abilities
Immunity Buffs: Buffs that grant immunity
Immunity Debuffs: Debuffs that grant immunity

|cFFFFFF00Debug Commands|r
/rr debug on - Normal debug (casts only)
/rr debug full - Full debug (verbose)
/rr debug off - Disable
/rr preview - Toggle preview window
/rr state - Show current state

|cFFFFFF00Tips|r
- One button press per GCD is enough, don't spam
- Use extra conditions to make rotation smarter
- Create profiles for different specs/playstyles
- Use immunity lists to avoid wasting abilities

|cFFFFFF00Credits|r
Author: feeder5
Version: 0.9.0
GitHub: github.com/thefeeder5/RoRota-TWOW
]]

function RoRota:ShowGuide()
	if self.guideFrame and self.guideFrame:IsVisible() then
		self.guideFrame:Hide()
		return
	end
	
	if not self.guideFrame then
		local f = CreateFrame("Frame", "RoRotaGuideFrame", UIParent)
		f:SetWidth(600)
		f:SetHeight(500)
		f:SetPoint("CENTER", UIParent, "CENTER")
		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = {left = 11, right = 12, top = 12, bottom = 11}
		})
		f:SetMovable(true)
		f:EnableMouse(true)
		f:RegisterForDrag("LeftButton")
		f:SetScript("OnDragStart", function() this:StartMoving() end)
		f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
		table.insert(UISpecialFrames, "RoRotaGuideFrame")
		
		local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		title:SetPoint("TOP", 0, -20)
		title:SetText("RoRota Guide")
		
		local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", -5, -5)
		
		local scroll = CreateFrame("ScrollFrame", "RoRotaGuideScroll", f, "UIPanelScrollFrameTemplate")
		scroll:SetPoint("TOPLEFT", 20, -45)
		scroll:SetPoint("BOTTOMRIGHT", -35, 15)
		
		local content = CreateFrame("Frame", nil, scroll)
		content:SetWidth(510)
		content:SetHeight(1)
		scroll:SetScrollChild(content)
		
		local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		text:SetPoint("TOPLEFT", 5, -5)
		text:SetWidth(500)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("TOP")
		text:SetText(guideText)
		
		content:SetHeight(text:GetHeight() + 10)
		
		self.guideFrame = f
	end
	
	self.guideFrame:Show()
end
