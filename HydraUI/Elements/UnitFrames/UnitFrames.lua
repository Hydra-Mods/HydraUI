local addon, ns = ...
local HydraUI, GUI, Language, Assets, Settings, Defaults = ns:get()

local unpack = unpack
local select = select
local format = string.format
local floor = math.floor
local sub = string.sub
local find = string.find
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
local UnitIsAFK = UnitIsAFK
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitEffectiveLevel = UnitEffectiveLevel
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitReaction = UnitReaction
local IsResting = IsResting
local UnitAura = UnitAura
local GetTime = GetTime

local DEAD = DEAD
local CHAT_MSG_AFK = CHAT_MSG_AFK
local PLAYER_OFFLINE = PLAYER_OFFLINE

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods
local Name, Duration, Expiration, Caster, SpellID, _
local TestPartyIndex = 0
local TestRaidIndex = 0

Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-target-buffs"] = true
Defaults["unitframes-show-druid-mana"] = true
Defaults["unitframes-font"] = "Roboto"
Defaults["unitframes-font-size"] = 12
Defaults["unitframes-font-flags"] = ""
Defaults["unitframes-display-aura-timers"] = true

local UF = HydraUI:NewModule("Unit Frames")

HydraUI.UnitFrames = {}
HydraUI.StyleFuncs = {}

local Hider = CreateFrame("Frame", nil, HydraUI.UIParent, "SecureHandlerStateTemplate")
Hider:Hide()

local HappinessLevels = {
	[1] = Language["Unhappy"],
	[2] = Language["Content"],
	[3] = Language["Happy"]
}

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

local Ignore = {

}

local CustomFilter = function(self, unit, icon, name, texture, count, dtype, duration, timeLeft, caster)
	if ((self.onlyShowPlayer and icon.isPlayer) or (not self.onlyShowPlayer and name)) and (not Ignore[name]) then
		return true
	end
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

function UF:SetHealthAttributes(health, value)
	if (value == "CLASS") then
		health.colorClass = true
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "REACTION") then
		health.colorClass = false
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "BLIZZARD") then
		health.colorClass = false
		health.colorReaction = false
		health.colorSelection = true
	elseif (value == "THREAT") then
		health.colorClass = true
		health.colorReaction = true
		health.colorSelection = false
		health.colorThreat = true
	elseif (value == "CUSTOM") then
		health.colorClass = false
		health.colorReaction = false
		health.colorHealth = true
	end
end

function UF:SetPowerAttributes(power, value)
	if (value == "POWER") then
		power.colorPower = true
		power.colorClass = false
		power.colorReaction = false
	elseif (value == "REACTION") then
		power.colorPower = false
		power.colorClass = false
		power.colorReaction = true
	elseif (value == "CLASS") then
		power.colorPower = false
		power.colorClass = true
		power.colorReaction = true
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

Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD PLAYER_FLAGS_CHANGED PLAYER_UPDATE_RESTING"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. CHAT_MSG_AFK .. "|r"
	else
		return Methods["Resting"](unit)
	end
	
	return ""
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
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

Events["LevelPlus"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
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

Events["Classification"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Classification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if Classes[Class] then
		return Classes[Class]
	end
end

Events["ShortClassification"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["ShortClassification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Plus"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Plus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Resting"] = "PLAYER_UPDATE_RESTING PLAYER_ENTERING_WORLD"
Methods["Resting"] = function(unit)
	if (unit == "player" and IsResting()) then
		return "zZz"
	end
end

Events["Health"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Health"] = function(unit)
	local Current = UnitHealth(unit)
	
	return Current
end

Events["Health:Short"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Health:Short"] = function(unit)
	local Current = UnitHealth(unit)
	
	return HydraUI:ShortValue(Current)
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["HealthPercent"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return 0
	else
		return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["HealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["HealthValues"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	return Current .. " / " .. Max
end

Events["HealthValues:Short"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["HealthValues:Short"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	return HydraUI:ShortValue(Current) .. " / " .. HydraUI:ShortValue(Max)
end

Events["HealthDeficit"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD PLAYER_FLAGS_CHANGED UNIT_CONNECTION"
Methods["HealthDeficit"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. CHAT_MSG_AFK .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current
	
	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. Deficit
	end
end

Events["HealthDeficit:Short"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD PLAYER_FLAGS_CHANGED UNIT_CONNECTION"
Methods["HealthDeficit:Short"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. CHAT_MSG_AFK .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current
	
	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. HydraUI:ShortValue(Deficit)
	end
end

Events["GroupStatus"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION PLAYER_FLAGS_CHANGED PLAYER_ENTERING_WORLD"
Methods["GroupStatus"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. DEAD .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. PLAYER_OFFLINE .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. CHAT_MSG_AFK .. "|r"
	end
	
	local Color = Methods["HealthColor"](unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return Color .. "0|r"
	else
		return Color .. floor(Current / Max * 100 + 0.5) .. "|r"
	end
end

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["HealthColor"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Current and Max > 0) then
		return "|cFF" .. HydraUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.17, 0.77, 0.4))
	else
		return "|cFF" .. HydraUI:RGBToHex(0.18, 0.8, 0.443)
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return UnitPower(unit)
	end
end

Events["Power:Short"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Power:Short"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return HydraUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerValues"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerValues"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)
	
	if (Max ~= 0) then
		return Current .. " / " .. Max
	end
end

Events["PowerValues:Short"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerValues:Short"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)
	
	if (Max ~= 0) then
		return HydraUI:ShortValue(Current) .. " / " .. HydraUI:ShortValue(Max)
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["PowerColor"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerColor"] = function(unit)
	local PowerType, PowerToken = UnitPowerType(unit)
	
	if HydraUI.PowerColors[PowerToken] then
		return format("|cFF%s", HydraUI.PowerColors[PowerToken].Hex)
	else
		return "|cFFFFFF"
	end
end

Events["Name4"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name4"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 4)
	end
end

Events["Name5"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 5)
	end
end

Events["Name8"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 8)
	end
end

Events["Name10"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 10)
	end
end

Events["Name14"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 14)
	end
end

Events["Name15"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 15)
	end
end

Events["Name20"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 20)
	end
end

Events["Name30"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name30"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 30)
	end
end

Events["NameColor"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED"
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

Events["Reaction"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = HydraUI.ReactionColors[Reaction]
		
		if Color then
			return "|cFF"..HydraUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["LevelColor"] = function(unit)
	local Level = UnitLevel(unit)
	local Color = GetQuestDifficultyColor(Level)
	
	return "|cFF" .. HydraUI:RGBToHex(Color.r, Color.g, Color.b)
end

Events["PartyIndex"] = "GROUP_ROSTER_UPDATE PLAYER_ENTERING_WORLD"
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

Events["RaidIndex"] = "GROUP_ROSTER_UPDATE PLAYER_ENTERING_WORLD"
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

Events["RaidGroup"] = "GROUP_ROSTER_UPDATE PLAYER_ENTERING_WORLD"
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

Events["PetColor"] = "UNIT_HAPPINESS UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD UNIT_PET"
Methods["PetColor"] = function(unit)
	if (HydraUI.UserClass == "HUNTER") then
		return Methods["HappinessColor"](unit)
	else
		return Methods["Reaction"](unit)
	end
end

Events["PetHappiness"] = "UNIT_HAPPINESS PLAYER_ENTERING_WORLD UNIT_PET"
Methods["PetHappiness"] = function(unit)
	if (unit == "pet") then
		local Happiness = GetPetHappiness()
		
		if Happiness then
			return HappinessLevels[Happiness]
		end
	end
end

Events["HappinessColor"] = "UNIT_HAPPINESS PLAYER_ENTERING_WORLD"
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

local ComboPointsUpdateShapeshiftForm = function(self, form)
	local Parent = self:GetParent()
	
	Parent.Buffs:ClearAllPoints()
	
	if (form == 3) then
		Parent.Buffs:SetPoint("BOTTOMLEFT", Parent.ComboPoints, "TOPLEFT", 0, 2)
	else
		Parent.Buffs:SetPoint("BOTTOMLEFT", Parent, "TOPLEFT", 0, 2)
	end
end

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela
	
	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())
		
		if (Now > 0) then
			self.Time:SetText(HydraUI:FormatTime(Now))
		else
			self:SetScript("OnUpdate", nil)
			--self.Time:Hide()
		end
		
		if (Now <= 0) then
			self:SetScript("OnUpdate", nil)
			self.Time:Hide()
		end
		
		self.ela = 0
	end
end

UF.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
	local Name, _, _, _, Duration, Expiration, Caster, _, _, SpellID = UnitAura(unit, index, button.filter)
	
	button.Duration = Duration
	button.Expiration = Expiration
	
	if button.cd then
		if (Duration and Duration > 0) then
			button.cd:SetCooldown(Expiration - Duration, Duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end
	
	if ((button.filter == "HARMFUL") and (not button.isPlayer) and debuffType) then
		button.icon:SetDesaturated(true)
		button:SetBackdropColor(0, 0, 0)
	elseif (button.filter == "HELPFUL") then
		button.icon:SetDesaturated(false)
		button:SetBackdropColor(0, 0, 0)
	else
		local color = HydraUI.DebuffColors[debuffType] or HydraUI.DebuffColors.none
	
		button.icon:SetDesaturated(false)
		button:SetBackdropColor(unpack(color))
	end
	
	if (Expiration and Expiration ~= 0) then
		button:SetScript("OnUpdate", AuraOnUpdate)
		button.Time:Show()
	else
		button.Time:Hide()
	end
end

local CancelAuraOnMouseUp = function(aura, button)
	if ((button ~= "RightButton") or InCombatLockdown()) then
		return
	end
	
	CancelUnitBuff("player", aura.ID)
end

UF.PostCreateIcon = function(unit, button)
	local ID = button:GetName():match("%d+")
	
	if ID then
		button.ID = tonumber(ID)
		button:SetScript("OnMouseUp", CancelAuraOnMouseUp)
	end
	
	button:SetBackdrop(HydraUI.BackdropAndBorder)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	button.cd:SetReverse(true)
	
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	HydraUI:SetFontInfo(button.count, Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(button.Time, Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	button.Time:SetPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.count:SetParent(button.overlayFrame)
	
	if Settings["unitframes-display-aura-timers"] then
		button.Time:SetParent(button.overlayFrame)
	else
		button.Time:SetParent(Hider)
	end
	
	button.ela = 0
end

UF.PostCastStart = function(self)
	if self.notInterruptible then
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	else
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
	end
end

UF.AuraOffsets = {
	TOPLEFT = {6, 0},
	TOPRIGHT = {-6, 0},
	BOTTOMLEFT = {6, 0},
	BOTTOMRIGHT = {-6, 0},
	LEFT = {6, 0},
	RIGHT = {-6, 0},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

UF.BuffIDs = {
	["DRUID"] = {
		-- Regrowth
		{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{8938, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{8939, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{8940, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{8941, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{9750, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{9856, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{9857, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{9858, "TOPRIGHT", {0.2, 0.8, 0.2}},
		{26980, "TOPRIGHT", {0.2, 0.8, 0.2}},
		
		-- Rejuvenation
		{774, "TOPLEFT", {0.8, 0.4, 0.8}},
		{1058, "TOPLEFT", {0.8, 0.4, 0.8}},
		{1430, "TOPLEFT", {0.8, 0.4, 0.8}},
		{2090, "TOPLEFT", {0.8, 0.4, 0.8}},
		{2091, "TOPLEFT", {0.8, 0.4, 0.8}},
		{3627, "TOPLEFT", {0.8, 0.4, 0.8}},
		{8910, "TOPLEFT", {0.8, 0.4, 0.8}},
		{9839, "TOPLEFT", {0.8, 0.4, 0.8}},
		{9840, "TOPLEFT", {0.8, 0.4, 0.8}},
		{9841, "TOPLEFT", {0.8, 0.4, 0.8}},
		{25299, "TOPLEFT", {0.8, 0.4, 0.8}},
		{26981, "TOPLEFT", {0.8, 0.4, 0.8}},
		{26982, "TOPLEFT", {0.8, 0.4, 0.8}},
		
		-- Lifebloom
		{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}},
	},
	
	["PALADIN"] = {
		-- Blessing of Freedom
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},
		
		-- Blessing of Protection
		{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
		{5599, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
		{10278, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
		
		-- Blessing of Sacrifice
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
		{20729, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
		{27147, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
		{27148, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
	},
	
	["PRIEST"] = {
		-- Power Word: Shield
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{592, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{600, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{3747, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{6065, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{6066, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{10898, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{10899, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{10900, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{10901, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{25217, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		{25218, "TOPLEFT", {0.81, 0.85, 0.1}, true},
		
		-- Renew
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{6074, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{6075, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{6076, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{6077, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{6078, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{10927, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{10928, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{10929, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{25315, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{25221, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		{25222, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
	},
	
	["SHAMAN"] = {
		-- Earth Shield
		{974, "TOPRIGHT", {0.73, 0.61, 0.33}},
		{32593, "TOPRIGHT", {0.73, 0.61, 0.33}},
		{32594, "TOPRIGHT", {0.73, 0.61, 0.33}},
	},
}

UF.PostCreateAuraWatchIcon = function(auras, icon)
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.icon:SetDrawLayer("ARTWORK")
	
	icon.bg = icon:CreateTexture(nil, "BORDER")
	icon.bg:SetPoint("TOPLEFT", icon, -1, 1)
	icon.bg:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	icon.bg:SetTexture(0, 0, 0)
	
	icon.overlay:SetTexture()
end

local UpdatePartyShowRole = function(value)
	if HydraUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, HydraUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				if value then
					Unit:EnableElement("GroupRoleIndicator")
				else
					Unit:DisableElement("GroupRoleIndicator")
				end
				
				Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
end

local Style = function(self, unit)
	if HydraUI.StyleFuncs[unit] then
		HydraUI.StyleFuncs[unit](self, unit)
	elseif (find(unit, "raid") and Settings["raid-enable"]) then
		HydraUI.StyleFuncs["raid"](self, unit)
	elseif (find(unit, "partypet") and Settings["party-enable"] and Settings["party-pets-enable"]) then
		HydraUI.StyleFuncs["partypet"](self, unit)
	elseif (find(unit, "party") and not find(unit, "pet") and Settings["party-enable"]) then
		HydraUI.StyleFuncs["party"](self, unit)
	elseif (find(unit, "nameplate") and Settings["nameplates-enable"]) then
		HydraUI.StyleFuncs["nameplate"](self, unit)
	elseif find(unit, "boss%d") then
		HydraUI.StyleFuncs["boss"](self, unit)
	end
end

local UpdateRaidSortingMethod = function(value)
	if (value == "CLASS") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "CLASS")
	elseif (value == "ROLE") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "ASSIGNEDROLE")
	elseif (value == "NAME") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", nil)
	elseif (value == "MTMA") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "ROLE")
	else -- GROUP
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "INDEX")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "GROUP")
	end
end

local UpdatePartyShowRole = function(value)
	if HydraUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, HydraUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				if value then
					Unit:EnableElement("GroupRoleIndicator")
				else
					Unit:DisableElement("GroupRoleIndicator")
				end
				
				--Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
end

local UpdateRaidShowPower = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				if value then
					Unit:EnableElement("Power")
					Unit:SetHeight(Settings["party-health-height"] + Settings["party-power-height"] + 3)
				else
					Unit:DisableElement("Power")
					Unit:SetHeight(Settings["party-health-height"] + 2)
				end
				
				Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
end

oUF:RegisterStyle("HydraUI", Style)

function UF:Load()
	if Settings["player-enable"] then
		local Player = oUF:Spawn("player", "HydraUI Player")
		
		if Settings["unitframes-player-enable-power"] and (not Settings["player-move-power"]) then
			Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
		else
			Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + 2)
		end
		
		Player:SetPoint("TOPRIGHT", HydraUI.UIParent, "CENTER", -68, -281)
		Player:SetParent(HydraUI.UIParent)
		
		if Settings["player-enable-portrait"] then
			Player:EnableElement("Portrait")
		else
			Player:DisableElement("Portrait")
		end
		
		if Settings["unitframes-show-player-buffs"] then
			Player:EnableElement("Auras")
		else
			Player:DisableElement("Auras")
		end
		
		if Settings["unitframes-player-enable-castbar"] then
			Player.Castbar:SetPoint("BOTTOM", HydraUI.UIParent, 0, 118)
			HydraUI:CreateMover(Player.Castbar, 2)
		end
		
		HydraUI.UnitFrames["player"] = Player
		HydraUI:CreateMover(Player)
		
		Player:UpdateAllElements("ForceUpdate")
	end
	
	if Settings["target-enable"] then
		local Target = oUF:Spawn("target", "HydraUI Target")
		Target:SetSize(Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
		Target:SetPoint("TOPLEFT", HydraUI.UIParent, "CENTER", 68, -281)
		Target:SetParent(HydraUI.UIParent)
		
		if Settings["target-enable-portrait"] then
			Target:EnableElement("Portrait")
		else
			Target:DisableElement("Portrait")
		end
		
		if Settings["unitframes-show-target-buffs"] then
			Target:EnableElement("Auras")
		else
			Target:DisableElement("Auras")
		end
		
		if Settings["unitframes-target-enable-castbar"] then
			Target.Castbar:SetPoint("BOTTOM", HydraUI.UIParent, 0, 146)
			HydraUI:CreateMover(Target.Castbar, 2)
		end
		
		HydraUI.UnitFrames["target"] = Target
		HydraUI:CreateMover(Target)
	end
	
	if Settings["tot-enable"] then
		local TargetTarget = oUF:Spawn("targettarget", "HydraUI Target Target")
		TargetTarget:SetSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"] + Settings["unitframes-targettarget-power-height"] + 3)
		TargetTarget:SetParent(HydraUI.UIParent)
		
		if Settings["target-enable"] then
			TargetTarget:SetPoint("TOPRIGHT", HydraUI.UnitFrames["target"], "BOTTOMRIGHT", 0, -2)
		else
			TargetTarget:SetPoint("TOPRIGHT", HydraUI.UIParent, "CENTER", 68, -341)
		end
		
		HydraUI.UnitFrames["targettarget"] = TargetTarget
		HydraUI:CreateMover(TargetTarget)
	end
	
	if Settings["pet-enable"] then
		local Pet = oUF:Spawn("pet", "HydraUI Pet")
		Pet:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"] + Settings["unitframes-pet-power-height"] + 3)
		Pet:SetParent(HydraUI.UIParent)
		
		if Settings["player-enable"] then
			Pet:SetPoint("TOPLEFT", HydraUI.UnitFrames["player"], "BOTTOMLEFT", 0, -2)
		else
			Pet:SetPoint("TOPLEFT", HydraUI.UIParent, "CENTER", -68, -341)
		end
		
		HydraUI.UnitFrames["pet"] = Pet
		HydraUI:CreateMover(Pet)
	end
	
	if Settings["focus-enable"] then
		local Focus = oUF:Spawn("focus", "HydraUI Focus")
		Focus:SetSize(Settings["unitframes-focus-width"], Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
		Focus:SetPoint("RIGHT", HydraUI.UIParent, "CENTER", -68, 304)
		Focus:SetParent(HydraUI.UIParent)
		
		HydraUI.UnitFrames["focus"] = Focus
		HydraUI:CreateMover(Focus)
	end
	
	if Settings["unitframes-boss-enable"] then
		for i = 1, 5 do
			local Boss = oUF:Spawn("boss" .. i, "HydraUI Boss " .. i)
			Boss:SetSize(Settings["unitframes-boss-width"], Settings["unitframes-boss-health-height"] + Settings["unitframes-boss-power-height"] + 3)
			Boss:SetParent(HydraUI.UIParent)
			
			if (i == 1) then
				Boss:SetPoint("LEFT", HydraUI.UIParent, 300, 200)
			else
				Boss:SetPoint("TOP", HydraUI.UnitFrames["boss" .. (i-1)], "BOTTOM", 0, -28) -- -2
			end
			
			HydraUI:CreateMover(Boss)
			
			HydraUI.UnitFrames["boss" .. i] = Boss
		end
	end
	
	if Settings["party-enable"] then
		local XOffset = 0
		local YOffset = 0
		
		if (Settings["party-point"] == "LEFT") then
			XOffset = Settings["party-spacing"]
			YOffset = 0
		elseif (Settings["party-point"] == "RIGHT") then
			XOffset = - Settings["party-spacing"]
			YOffset = 0
		elseif (Settings["party-point"] == "TOP") then
			XOffset = 0
			YOffset = - Settings["party-spacing"]
		elseif (Settings["party-point"] == "BOTTOM") then
			XOffset = 0
			YOffset = Settings["party-spacing"]
		end
		
		local Party = oUF:SpawnHeader("HydraUI Party", nil, "party,solo",
			"initial-width", Settings["party-width"],
			"initial-height", (Settings["party-health-height"] + Settings["party-power-height"] + 3),
			"isTesting", false,
			"showSolo", false,
			"showPlayer", true,
			"showParty", true,
			"showRaid", false,
			"xOffset", XOffset,
			"yOffset", YOffset,
			"point", Settings["party-point"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()
				
				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
		)
		
		self.PartyAnchor = CreateFrame("Frame", "HydraUI Party Anchor", HydraUI.UIParent)
		self.PartyAnchor:SetSize((5 * Settings["party-width"] + (4 * Settings["party-spacing"])), (Settings["party-health-height"] + Settings["party-power-height"]) + 3)
		self.PartyAnchor:SetPoint("BOTTOMLEFT", HydraUIChatFrameTop, "TOPLEFT", -3, 5)
		
		Party:SetPoint("BOTTOMLEFT", self.PartyAnchor, 0, 0)
		Party:SetParent(HydraUI.UIParent)
		
		HydraUI.UnitFrames["party"] = Party
		
		--UpdatePartyShowRole(Settings["party-show-role"])
		
		HydraUI:CreateMover(self.PartyAnchor)
		
		if Settings["party-pets-enable"] then
			local XOffset = 0
			local YOffset = 0
			
			if (Settings["party-point"] == "LEFT") then
				XOffset = Settings["party-spacing"]
				YOffset = 0
			elseif (Settings["party-point"] == "RIGHT") then
				XOffset = - Settings["party-spacing"]
				YOffset = 0
			elseif (Settings["party-point"] == "TOP") then
				XOffset = 0
				YOffset = - Settings["party-spacing"]
			elseif (Settings["party-point"] == "BOTTOM") then
				XOffset = 0
				YOffset = Settings["party-spacing"]
			end

			local PartyPet = oUF:SpawnHeader("HydraUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
				"initial-width", Settings["party-pets-width"],
				"initial-height", (Settings["party-pets-health-height"] + Settings["party-pets-power-height"] + 3),
				"showSolo", false,
				"showPlayer", false,
				"showParty", true,
				"showRaid", false,
				"xOffset", XOffset,
				"yOffset", YOffset,
				"point", Settings["party-point"],
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)

			if (Settings["party-point"] == "LEFT") then
				PartyPet:SetPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "RIGHT") then
				PartyPet:SetPoint("TOPRIGHT", Party, "BOTTOMRIGHT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "TOP") then
				PartyPet:SetPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "BOTTOM") then
				PartyPet:SetPoint("BOTTOMLEFT", Party, "TOPLEFT", 0, Settings["party-spacing"])
			end

			PartyPet:SetParent(HydraUI.UIParent)

			HydraUI.UnitFrames["party-pets"] = PartyPet
		end
	end
	
	if Settings["raid-enable"] then
		local Raid = oUF:SpawnHeader("HydraUI Raid", nil, "raid,solo",
			"initial-width", Settings["raid-width"],
			"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
			"isTesting", false,
			"showSolo", false,
			"showPlayer", true,
			"showParty", false,
			"showRaid", true,
			"point", Settings["raid-point"],
			"xOffset", Settings["raid-x-offset"],
			"yOffset", Settings["raid-y-offset"],
			"maxColumns", Settings["raid-max-columns"],
			"unitsPerColumn", Settings["raid-units-per-column"],
			"columnSpacing", Settings["raid-column-spacing"],
			"columnAnchorPoint", Settings["raid-column-anchor"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()
				
				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
		)
		
		self.RaidAnchor = CreateFrame("Frame", "HydraUI Raid Anchor", HydraUI.UIParent)
		self.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
		self.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
		self.RaidAnchor:SetPoint("BOTTOMLEFT", HydraUIChatFrameTop, "TOPLEFT", -3, 5)
		
		if CompactRaidFrameContainer then
			CompactRaidFrameContainer:UnregisterAllEvents()
			CompactRaidFrameContainer:SetParent(Hider)
			
			--CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(Hider)
		end
		
		Raid:SetPoint("TOPLEFT", self.RaidAnchor, 0, 0)
		Raid:SetParent(HydraUI.UIParent)
		
		HydraUI.UnitFrames["raid"] = Raid
		
		UpdateRaidSortingMethod(Settings["raid-sorting-method"])
		
		HydraUI:CreateMover(self.RaidAnchor)
	end
	
	if Settings["nameplates-enable"] then
		UF.NamePlateCVars.nameplateSelectedAlpha = (Settings["nameplates-selected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMinAlpha = (Settings["nameplates-unselected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMaxAlpha = (Settings["nameplates-unselected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMaxDistance = 41
		
		oUF:SpawnNamePlates(nil, UF.NamePlateCallback, UF.NamePlateCVars)
	end
end

GUI:AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("unitframes-font", Settings["unitframes-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the unit frames"], nil, "Font")
	left:CreateSlider("unitframes-font-size", Settings["unitframes-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the unit frames"])
	left:CreateDropdown("unitframes-font-flags", Settings["unitframes-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the unit frames"])
	
	right:CreateHeader(Language["Auras"])
	right:CreateSwitch("unitframes-display-aura-timers", Settings["unitframes-display-aura-timers"], Language["Display Aura Timers"], Language["Display the timer on unit frame auras"], ReloadUI):RequiresReload(true)
end)

--/run HydraUIFakeBosses()
HydraUIFakeBosses = function()
	local Boss
	
	for i = 1, 5 do
		Boss = HydraUI.UnitFrames["boss"..i]
		
		if (not Boss:IsShown()) then
			Boss.unit = "player"
			UnregisterUnitWatch(Boss)
			RegisterUnitWatch(Boss, true)
			Boss:Show()
		else
			Boss.unit = nil
			UnregisterUnitWatch(Boss)
			Boss:Hide()
		end
	end
end