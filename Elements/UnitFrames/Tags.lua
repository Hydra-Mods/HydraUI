local addon, ns = ...
local HydraUI, Language, Assets, Settings = ns:get()

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods

local format = string.format
local floor = math.floor
local sub = string.sub
local len = string.len
local byte = string.byte
local tonumber = tonumber
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitClassification = UnitClassification
local UnitReaction = UnitReaction
local UnitIsEnemy = UnitIsEnemy
local UnitIsAFK = UnitIsAFK
local IsResting = IsResting
local GetPetHappiness = GetPetHappiness

local DEAD = DEAD
local PLAYER_OFFLINE = PLAYER_OFFLINE
local AFK = HydraUI.IsMainline and DEFAULT_AFK_MESSAGE or CHAT_MSG_AFK
local HealthEvent = HydraUI.IsMainline and "UNIT_HEALTH " or "UNIT_HEALTH_FREQUENT "

local TestPartyIndex = 0
local TestRaidIndex = 0

local Classes = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	--["worldboss"] = Language["Boss"],
}

local ShortClasses = {
	["rare"] = Language[" R"],
	["elite"] = Language["+"],
	["rareelite"] = Language[" R+"],
	--["worldboss"] = Language[" B"],
}

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local UTF8Sub = function(str, stop) -- utf8 sub derived from tukui
	if (not str) then
		return str
	end

	local Bytes = len(str)

	if (Bytes <= stop) then
		return str
	else
		local Len, Pos = 0, 1

		while (Pos <= Bytes) do
			Len = Len + 1

			local c = byte(str, Pos)

			if (c > 0 and c <= 127) then
				Pos = Pos + 1
			elseif (c >= 192 and c <= 223) then
				Pos = Pos + 2
			elseif (c >= 224 and c <= 239) then
				Pos = Pos + 3
			elseif (c >= 240 and c <= 247) then
				Pos = Pos + 4
			end

			if (Len == stop) then
				break
			end
		end

		if (Len == stop and Pos <= Bytes) then
			return sub(str, 1, Pos - 1) .. ".."
		else
			return str
		end
	end
end

-- Tags
Events["ColorStop"] = "PLAYER_ENTERING_WORLD"
Methods["ColorStop"] = function()
	return "|r"
end

Events["Resting"] = "PLAYER_UPDATE_RESTING"
Methods["Resting"] = function(unit)
	if (unit == "player" and IsResting()) then
		return "zZz"
	end
end

Events["Status"] = HealthEvent .. "UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. AFK .. "|r"
	end

	return ""
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
Methods["Level"] = function(unit)
	local Level = UnitLevel(unit)

	if (Level == -1) then
		if UnitIsPlayer(unit) then
			return "??"
		else
			return Language["Boss"]
		end
	else
		return Level
	end
end

Events["LevelPlus"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
Methods["LevelPlus"] = function(unit)
	local Class = UnitClassification(unit)

	if (Class == "worldboss") then
		return "Boss"
	else
		local Plus = Methods["Plus"](unit)
		local Level = Methods["Level"](unit)

		if Plus then
			return Level .. Plus
		else
			return Level
		end
	end
end

Events["Classification"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
Methods["Classification"] = function(unit)
	local Class = UnitClassification(unit)

	if Classes[Class] then
		return Classes[Class]
	end
end

Events["ShortClassification"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
Methods["ShortClassification"] = function(unit)
	local Class = UnitClassification(unit)

	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Plus"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
Methods["Plus"] = function(unit)
	local Class = UnitClassification(unit)

	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Health"] = HealthEvent .. "UNIT_MAXHEALTH"
Methods["Health"] = UnitHealth

Events["Health:Short"] = HealthEvent .. "UNIT_MAXHEALTH"
Methods["Health:Short"] = function(unit)
	return HydraUI:ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = HealthEvent .. "UNIT_MAXHEALTH"
Methods["HealthPercent"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)

	if (Max == 0) then
		return 0
	else
		return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["HealthValues"] = HealthEvent .. "UNIT_MAXHEALTH UNIT_CONNECTION"
Methods["HealthValues"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)

	return Current .. " / " .. Max
end

Events["HealthValues:Short"] = HealthEvent .. "UNIT_MAXHEALTH UNIT_CONNECTION"
Methods["HealthValues:Short"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)

	return HydraUI:ShortValue(Current) .. " / " .. HydraUI:ShortValue(Max)
end

Events["HealthDeficit"] = HealthEvent .. "UNIT_MAXHEALTH PLAYER_FLAGS_CHANGED UNIT_CONNECTION PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"
Methods["HealthDeficit"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. AFK .. "|r"
	end

	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current

	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. Deficit
	end
end

Events["HealthDeficit:Short"] = HealthEvent .. "UNIT_MAXHEALTH PLAYER_FLAGS_CHANGED UNIT_CONNECTION PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"
Methods["HealthDeficit:Short"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. AFK .. "|r"
	end

	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current

	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. HydraUI:ShortValue(Deficit)
	end
end

Events["GroupStatus"] = HealthEvent .. "UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"
Methods["GroupStatus"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. AFK .. "|r"
	end

	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Color = Methods["HealthColor"](unit)

	if (Max == 0) then
		return Color .. "0|r"
	else
		return Color .. floor(Current / Max * 100 + 0.5) .. "|r"
	end
end

Events["HealthColor"] = HealthEvent .. "UNIT_MAXHEALTH"
Methods["HealthColor"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)

	if (Current and Max > 0) then
		return "|cFF" .. HydraUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.17, 0.77, 0.4))
	else
		return "|cFF" .. HydraUI:RGBToHex(0.18, 0.8, 0.443)
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return UnitPower(unit)
	end
end

Events["Power:Short"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE"
Methods["Power:Short"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return HydraUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerValues"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE"
Methods["PowerValues"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)

	if (Max ~= 0) then
		return Current .. " / " .. Max
	end
end

Events["PowerValues:Short"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE"
Methods["PowerValues:Short"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)

	if (Max ~= 0) then
		return HydraUI:ShortValue(Current) .. " / " .. HydraUI:ShortValue(Max)
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["PowerColor"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_DISPLAYPOWER"
Methods["PowerColor"] = function(unit)
	local PowerType, PowerToken = UnitPowerType(unit)

	if HydraUI.PowerColors[PowerToken] then
		return format("|cFF%s", HydraUI.PowerColors[PowerToken].Hex)
	else
		return "|cFFFFFFFF"
	end
end

Events["Name"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name"] = function(unit, realunit, arg)
	local Name = UnitName(realunit or unit)

	if Name then
		return UTF8Sub(Name, tonumber(arg))
	end
end

-- Deprecated as of April 8th, 2022
Events["Name4"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name4"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 4)
	end
end

Events["Name5"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 5)
	end
end

Events["Name8"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 8)
	end
end

Events["Name10"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 10)
	end
end

Events["Name14"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 14)
	end
end

Events["Name15"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 15)
	end
end

Events["Name20"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 20)
	end
end

Events["Name30"] = "UNIT_NAME_UPDATE UNIT_PET"
Methods["Name30"] = function(unit)
	local Name = UnitName(unit)

	if Name then
		return UTF8Sub(Name, 30)
	end
end

Events["NameColor"] = "UNIT_NAME_UPDATE UNIT_CLASSIFICATION_CHANGED UNIT_FACTION"
Methods["NameColor"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)

		if Class then
			local Color = HydraUI.ClassColors[Class]

			if Color then
				return "|cFF"..HydraUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	else
		local Reaction = UnitReaction(unit, "player")

		if Reaction then
			local Color = HydraUI.ReactionColors[Reaction]

			if Color then
				return "|cFF"..HydraUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

Events["Reaction"] = "UNIT_NAME_UPDATE UNIT_CLASSIFICATION_CHANGED UNIT_FACTION"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")

	if Reaction then
		local Color = HydraUI.ReactionColors[Reaction]

		if Color then
			return "|cFF"..HydraUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
Methods["LevelColor"] = function(unit)
	local Level = UnitLevel(unit)
	local Color = GetQuestDifficultyColor(Level)

	return "|cFF" .. HydraUI:RGBToHex(Color.r, Color.g, Color.b)
end

Events["PetColor"] = "UNIT_HAPPINESS UNIT_LEVEL PLAYER_LEVEL_UP UNIT_PET UNIT_FACTION"
Methods["PetColor"] = function(unit)
	if (HydraUI.UserClass == "HUNTER") then
		return Methods["HappinessColor"](unit)
	else
		return Methods["Reaction"](unit)
	end
end

Events["HappinessColor"] = "UNIT_HAPPINESS UNIT_PET"
Methods["HappinessColor"] = function(unit)
	if (unit == "pet") then
		local Happiness = GetPetHappiness()

		if Happiness then
			local Color = HydraUI.HappinessColors[Happiness]

			if Color then
				return "|cFF"..HydraUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

Events["PartyIndex"] = "GROUP_ROSTER_UPDATE"
Methods["PartyIndex"] = function(unit)
	local Header = _G["HydraUI Party"]

	if Header and Header:GetAttribute("isTesting") then
		if TestPartyIndex >= 5 then
			TestPartyIndex = 0
		end
		TestPartyIndex = TestPartyIndex + 1
		return TestPartyIndex
	end

	if unit == "player" then
		return 1
	end
	if sub(unit, 1, 5) == "party" then
		return tonumber(sub(unit, 6, 6)) + 1
	end
end

Events["RaidIndex"] = "GROUP_ROSTER_UPDATE"
Methods["RaidIndex"] = function(unit)
	local Header = _G["HydraUI Raid"]

	if Header and Header:GetAttribute("isTesting") then
		if TestRaidIndex >= 25 then
			TestRaidIndex = 0
		end
		TestRaidIndex = TestRaidIndex + 1
		return TestRaidIndex
	end

	return UnitInRaid(unit)
end

Events["RaidGroup"] = "GROUP_ROSTER_UPDATE"
Methods["RaidGroup"] = function(unit)
	local Name = UnitName(unit)
	local Unit, Rank, Group

	for i = 1, MAX_RAID_MEMBERS do
		Unit, Rank, Group = GetRaidRosterInfo(i)

		if (not Unit) then
			break
		end

		if (Unit == Name) then
			return Group
		end
	end
end