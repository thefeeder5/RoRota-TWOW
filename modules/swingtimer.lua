--[[ swingtimer ]]--
-- Weapon swing timer tracking.
-- Tracks swing timing to avoid clipping auto-attacks with builders.
--
-- Key function:
--   CanUseBuilder() - Returns true if safe to use builder
--
-- Features: MH swing detection, latency compensation, queue window

if not RoRota then return end
if RoRota.swingtimer then return end

RoRota.SwingTimer = RoRota.SwingTimer or {}

-- state
local last_mh_swing = 0
local mh_speed = 0
local QUEUE_WINDOW = 0.1

-- get main hand weapon speed
local function GetMHSpeed()
    local speed = UnitAttackSpeed("player")
    return speed or 2.0
end

-- check if we're in optimal builder window
function RoRota.SwingTimer:CanUseBuilder()
    if last_mh_swing == 0 then return true end
    
    local now = GetTime()
    local _, _, latency = GetNetStats()
    latency = (latency or 0) / 1000
    
    mh_speed = GetMHSpeed()
    local next_swing = last_mh_swing + mh_speed
    local time_until_swing = next_swing - now
    
    -- allow if we're far from next swing (won't clip) OR in queue window
    if time_until_swing > 1.5 then
        return true
    end
    
    -- in queue window before swing
    local cast_window_start = next_swing - latency - QUEUE_WINDOW
    return now >= cast_window_start
end

-- combat log event handler
local function OnEvent()
    -- detect player melee hits (main hand)
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        if string.find(arg1, "You hit") or string.find(arg1, "You crit") then
            last_mh_swing = GetTime()
        end
    end
end

-- register combat log event
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
frame:SetScript("OnEvent", OnEvent)

RoRota.swingtimer = true
