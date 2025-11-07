--[[ locale ]]--
-- Translation helper for multi-language support

if not RoRota then return end
if RoRota.locale then return end

local L = AceLibrary("AceLocale-2.2"):new("RoRota")
local reverseMap = {}

-- Translate English key to localized name
function RoRota:T(englishName)
	return L[englishName] or englishName
end

-- Build reverse lookup table (localized -> English)
function RoRota:BuildReverseMap()
	for key, value in pairs(L) do
		if type(value) == "string" and value ~= key then
			reverseMap[value] = key
		end
	end
end

-- Reverse lookup: localized name to English key
function RoRota:FromLocale(localizedName)
	return reverseMap[localizedName] or localizedName
end

RoRota.locale = true
