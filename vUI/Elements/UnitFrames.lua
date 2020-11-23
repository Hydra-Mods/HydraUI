local addon, ns = ...
local vUI, GUI, Language, Assets, Settings = ns:get()

local unpack = unpack
local select = select
local format = string.format
local match = string.match
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
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitReaction = UnitReaction
local UnitIsEnemy = UnitIsEnemy
local IsResting = IsResting
local UnitAura = UnitAura
local GetTime = GetTime

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods
local Name, Duration, Expiration, Caster, SpellID, _

vUI.UnitFrames = {}

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
	[GetSpellInfo(57724)] = true, -- Sated
	[GetSpellInfo(288293)] = true, -- Temporal Displacement
	[GetSpellInfo(206150)] = true, -- Challenger's Might
	[GetSpellInfo(206151)] = true, -- Challenger's Burden
}

local CustomFilter = function(self, unit, icon, name, texture, count, dtype, duration, timeLeft, caster)
	if ((self.onlyShowPlayer and icon.isPlayer) or (not self.onlyShowPlayer and name)) and (not Ignore[name]) then
		return true
	end
end

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
end

local SetHealthAttributes = function(health, value)
	if (value == "CLASS") then
		health.colorClass = true
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "REACTION") then
		health.colorClass = false
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "CUSTOM") then
		health.colorClass = false
		health.colorReaction = false
		health.colorHealth = true
	end
end

local SetPowerAttributes = function(power, value)
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
Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	end
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Level"] = function(unit)
	local Level = UnitEffectiveLevel(unit)
	
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

Events["Health"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["Health"] = function(unit)
	return vUI:ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["HealthPercent"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return 0
	else
		return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["HealthValues"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["HealthValues"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
end

Events["HealthDeficit"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["HealthDeficit"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current
	
	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. vUI:ShortValue(Deficit)
	end
end

Events["GroupStatus"] = "UNIT_HEALTH UNIT_CONNECTION UNIT_FLAGS PLAYER_ENTERING_WORLD"
Methods["GroupStatus"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
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

Events["HealthColor"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["HealthColor"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Current and Max > 0) then
		return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.17, 0.77, 0.4))
	else
		return "|cFF" .. vUI:RGBToHex(0.18, 0.8, 0.443)
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return vUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerValues"] = "UNIT_POWER_FREQUENT PLAYER_ENTERING_WORLD"
Methods["PowerValues"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)
	
	if (Max ~= 0) then
		return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
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
	
	if vUI.PowerColors[PowerToken] then
		return format("|cFF%s", vUI.PowerColors[PowerToken].Hex)
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
			local Color = vUI.ClassColors[Class]
			
			if Color then
				return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			local Color = vUI.ReactionColors[Reaction]
			
			if Color then
				return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

Events["Reaction"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = vUI.ReactionColors[Reaction]
		
		if Color then
			return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

local GetQuestDifficultyColor = GetQuestDifficultyColor

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["LevelColor"] = function(unit)
	local Level = UnitLevel(unit)
	local Color = GetQuestDifficultyColor(Level)
	
	return "|cFF" .. vUI:RGBToHex(Color.r, Color.g, Color.b)
	--return vUI:UnitDifficultyColor(unit)
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
			self.Time:SetText(vUI:FormatTime(Now))
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

local PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
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
		local color = vUI.DebuffColors[debuffType] or vUI.DebuffColors.none
	
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

local PostCreateIcon = function(unit, button)
	button:SetBackdrop(vUI.BackdropAndBorder)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0, 0)
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	vUI:SetFontInfo(button.count, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(button.Time, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	button.Time:SetPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.count:SetParent(button.overlayFrame)
	button.Time:SetParent(button.overlayFrame)
	
	button.ela = 0
end

local BuffsSetPosition = function(element, from, to)
	local SizeX = element.size + (element['spacing-x'] or element.spacing)
	local SizeY = element.size + (element['spacing-y'] or element.spacing)
	local Anchor = element.initialAnchor or "BOTTOMLEFT"
	local GrowthX = (element['growth-x'] == "LEFT" and -1) or 1
	local GrowthY = (element['growth-y'] == "DOWN" and -1) or 1
	local Columns = floor(element:GetWidth() / SizeX + 0.5)
	local Rows = floor(to / Columns)
	local Button
	
	for i = from, to do
		Button = element[i]
		
		if (not Button or not Button:IsShown()) then
			break
		end
		
		local Column = (i - 1) % Columns
		local Row = floor((i - 1) / Columns)
		
		Button:ClearAllPoints()
		Button:SetPoint(Anchor, element, Anchor, Column * SizeX * GrowthX, Row * SizeY * GrowthY)
	end
	
	if (Rows > 0) then
		element:SetHeight(element.size * Rows + ((Rows - 1) * element.spacing))
	else
		element:SetHeight(element.size)
	end
end

local PostCastStart = function(self, unit, name)
	if self.notInterruptible then
		self:SetStatusBarColor(vUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	else
		self:SetStatusBarColor(vUI:HexToRGB(Settings["color-casting-start"]))
	end
end

local NamePlateCallback = function(self)
	if (not self) then
		return
	end
	
	if Settings["nameplates-display-debuffs"] then
		self:EnableElement("Auras")
	else
		self:DisableElement("Auras")
	end
	
	if Settings["nameplates-enable-target-indicator"] then
		self:EnableElement("TargetIndicator")
		
		if (Settings["nameplates-target-indicator-size"] == "SMALL") then
			self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
			self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
		elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
			self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
			self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
		elseif (Settings["nameplates-target-indicator-size"] == "HUGE") then
			self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Huge"))
			self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Huge"))
		end
	else
		self:DisableElement("TargetIndicator")
	end
	
	if Settings["nameplates-enable-castbar"] then
		self:EnableElement("Castbar")
	else
		self:DisableElement("Castbar")
	end
	
	if self.Debuffs then
		self.Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	end
	
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self.Castbar:SetHeight(Settings["nameplates-castbar-height"])
	
	vUI:SetFontInfo(self.Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Castbar.Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Castbar.Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
end

local StyleNamePlate = function(self, unit)
	self:SetScale(Settings["ui-scale"])
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self:SetPoint("CENTER", 0, 0)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.colors.debuff = vUI.DebuffColors
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:EnableMouse(false)
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = Health:CreateTexture(nil, "BACKGROUND")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("LEFT", Health, "RIGHT", 5, 0)
	
	local Top = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Top:SetPoint("CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopLeft:SetPoint("LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopRight:SetPoint("RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local Bottom = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Bottom:SetPoint("CENTER", Health, "BOTTOM", 0, -3)
	Bottom:SetJustifyH("CENTER")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomRight:SetPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomLeft:SetPoint("LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	--[[local InsideCenter = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(InsideCenter, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	InsideCenter:SetPoint("CENTER", Health, 0, 0)
	InsideCenter:SetJustifyH("CENTER")]]
	
	Health.Smooth = Settings["nameplates-health-smooth"]
	Health.colorTapping = true
	Health.colorDisconnected = true
	
	SetHealthAttributes(Health, Settings["nameplates-health-color"])
	
	local Threat = CreateFrame("Frame", nil, Health)
	Threat:SetAllPoints(Health)
	Threat:SetFrameLevel(Health:GetFrameLevel() - 1)
	Threat.feedbackUnit = "player"
	
	Threat.Top = Threat:CreateTexture(nil, "BORDER")
	Threat.Top:SetHeight(6)
	Threat.Top:SetPoint("BOTTOMLEFT", Threat, "TOPLEFT", 8, 1)
	Threat.Top:SetPoint("BOTTOMRIGHT", Threat, "TOPRIGHT", -8, 1)
	Threat.Top:SetTexture(Assets:GetHighlight("RenHorizonUp"))
	Threat.Top:SetAlpha(0.8)
	
	Threat.Bottom = Threat:CreateTexture(nil, "BORDER")
	Threat.Bottom:SetHeight(6)
	Threat.Bottom:SetPoint("TOPLEFT", Threat, "BOTTOMLEFT", 8, -1)
	Threat.Bottom:SetPoint("TOPRIGHT", Threat, "BOTTOMRIGHT", -8, -1)
	Threat.Bottom:SetTexture(Assets:GetHighlight("RenHorizonDown"))
	Threat.Bottom:SetAlpha(0.8)
	
	-- Buffs
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(30, 30)
	Buffs:SetPoint("BOTTOM", self, "TOP", 0, 36)
	Buffs.size = 30
	Buffs.spacing = 0
	Buffs.num = 1
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	Buffs.showType = true
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["nameplates-width"], 26)
	Debuffs:SetPoint("BOTTOM", Health, "TOP", 0, 14)
	Debuffs.size = 26
	Debuffs.spacing = 2
	Debuffs.num = 5
	Debuffs.numRow = 4
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	Debuffs.showType = true
	Debuffs.disableMouse = true
	Debuffs.CustomFilter = CustomFilter
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetSize(Settings["nameplates-width"] - 2, Settings["nameplates-castbar-height"])
	Castbar:SetPoint("TOP", Health, "BOTTOM", 0, -4)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
	Background:SetPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Time:SetPoint("RIGHT", Castbar, "BOTTOMRIGHT", -4, -3)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Text:SetPoint("LEFT", Castbar, "BOTTOMLEFT", 4, -3)
	Text:SetWidth(Settings["nameplates-width"] / 2 + 4)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetSize(Settings["nameplates-height"] + 12 + 2, Settings["nameplates-height"] + 12 + 2)
    Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Assets:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.7
	Castbar.PostCastStart = PostCastStart
	Castbar.PostChannelStart = PostCastStart
	
	--[[ Elite icon
	local EliteIndicator = Health:CreateTexture(nil, "OVERLAY")
    EliteIndicator:SetSize(16, 16)
    EliteIndicator:SetPoint("RIGHT", Health, "LEFT", -1, 0)
    EliteIndicator:SetTexture(Assets:GetTexture("Small Star"))
    EliteIndicator:Hide()]]
	
	-- Target
	local TargetIndicator = CreateFrame("Frame", nil, self)
	TargetIndicator:SetPoint("TOPLEFT", Health, 0, 0)
	TargetIndicator:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	TargetIndicator:Hide()
	
	TargetIndicator.Left = TargetIndicator:CreateTexture(nil, "ARTWORK")
	TargetIndicator.Left:SetSize(16, 16)
	TargetIndicator.Left:SetPoint("RIGHT", TargetIndicator, "LEFT", 2, 0)
	TargetIndicator.Left:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	TargetIndicator.Right = TargetIndicator:CreateTexture(nil, "ARTWORK")
	TargetIndicator.Right:SetSize(16, 16)
	TargetIndicator.Right:SetPoint("LEFT", TargetIndicator, "RIGHT", -3, 0)
	TargetIndicator.Right:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	if (Settings["nameplates-target-indicator-size"] == "SMALL") then
		TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
		TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
	elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
		TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
		TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
	elseif (Settings["nameplates-target-indicator-size"] == "HUGE") then
		TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Huge"))
		TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Huge"))
	end
	
	self:Tag(Top, Settings["nameplates-top-text"])
	self:Tag(TopLeft, Settings["nameplates-topleft-text"])
	self:Tag(TopRight, Settings["nameplates-topright-text"])
	self:Tag(Bottom, Settings["nameplates-bottom-text"])
	self:Tag(BottomRight, Settings["nameplates-bottomright-text"])
	self:Tag(BottomLeft, Settings["nameplates-bottomleft-text"])
	
	self.Health = Health
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.Top = Top
	self.TopLeft = TopLeft
	self.TopRight = TopRight
	self.Bottom = Bottom
	self.BottomRight = BottomRight
	self.BottomLeft = BottomLeft
	self.Health.bg = HealthBG
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.EliteIndicator = EliteIndicator
	self.TargetIndicator = TargetIndicator
	self.ThreatIndicator = Threat
	self.RaidTargetIndicator = RaidTargetIndicator
end

local UnitFrameOnEnter = function(self)
	UnitFrame_OnEnter(self)
	
	if self.Hover then
		self.AnimIn:Play()
	end
end

local UnitFrameOnLeave = function(self)
	UnitFrame_OnLeave(self)
	
	if self.Hover then
		self.AnimOut:Play()
	end
end

local CreateMouseover = function(self)
	self.Hover = CreateFrame("Frame", nil, self.Health)
	self.Hover:SetAllPoints()
	self.Hover:SetFrameLevel(self:GetFrameLevel() + 10)
	self.Hover:SetAlpha(0)
	
	self.HoverTop = self.Hover:CreateTexture(nil, "OVERLAY")
	self.HoverTop:SetPoint("TOPLEFT", self.Hover, 10, -1)
	self.HoverTop:SetPoint("TOPRIGHT", self.Hover, -10, -1)
	self.HoverTop:SetHeight(12)
	self.HoverTop:SetTexture(Assets:GetHighlight("RenHorizonDown"))
	self.HoverTop:SetVertexColor(1, 1, 1)
	
	self.Anim = CreateAnimationGroup(self.Hover)
	
	self.AnimIn = self.Anim:CreateAnimation("Fade")
	self.AnimIn:SetEasing("in")
	self.AnimIn:SetDuration(0.1)
	self.AnimIn:SetChange(0.08)
	
	self.AnimOut = self.Anim:CreateAnimation("Fade")
	self.AnimOut:SetEasing("out")
	self.AnimOut:SetDuration(0.15)
	self.AnimOut:SetChange(0)
end

local StylePlayer = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.AuraParent = self
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-player-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-player-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetSize(20, 20)
	Combat:SetPoint("CENTER", Health)
	
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Leader:Hide()
	
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-player-health-color"])
	
	if Settings["unitframes-player-enable-power"] then
		local Power = CreateFrame("StatusBar", nil, self)
		Power:SetPoint("BOTTOMLEFT", self, 1, 1)
		Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
		Power:SetHeight(Settings["unitframes-player-power-height"])
		Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		Power:SetReverseFill(Settings["unitframes-player-power-reverse"])
		
		local PowerBG = Power:CreateTexture(nil, "BORDER")
		PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
		PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
		PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		PowerBG:SetAlpha(0.2)
		
		local PowerRight = Power:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerRight:SetPoint("RIGHT", Power, -3, 0)
		PowerRight:SetJustifyH("RIGHT")
		
		local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerLeft:SetPoint("LEFT", Power, 3, 0)
		PowerLeft:SetJustifyH("LEFT")
		
		-- Position and size
		local mainBar = CreateFrame("StatusBar", nil, Power)
		mainBar:SetReverseFill(true)
		mainBar:SetPoint("TOP")
		mainBar:SetPoint("BOTTOM")
		mainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT")
		mainBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		mainBar:SetStatusBarColor(0.8, 0.1, 0.1)
		mainBar:SetWidth(200)
		
		-- Register with oUF
		self.PowerPrediction = {
			mainBar = mainBar,
		}
		
		-- Attributes
		Power.frequentUpdates = true
		Power.Smooth = true
		
		SetPowerAttributes(Power, Settings["unitframes-player-power-color"])
		
		self:Tag(PowerLeft, Settings["unitframes-player-power-left"])
		self:Tag(PowerRight, Settings["unitframes-player-power-right"])
		
		self.Power = Power
		self.Power.bg = PowerBG
		self.PowerLeft = PowerLeft
		self.PowerRight = PowerRight
	end
	
    -- Castbar
	if Settings["unitframes-player-enable-castbar"] then
		local Castbar = CreateFrame("StatusBar", "vUI Casting Bar", self)
		Castbar:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])
		Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		
		local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
		CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
		CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
		CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		CastbarBG:SetAlpha(0.2)
		
		-- Add a background
		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetPoint("TOPLEFT", Castbar, -1, 1)
		Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
		Background:SetTexture(Assets:GetTexture("Blank"))
		Background:SetVertexColor(0, 0, 0)
		
		-- Add a timer
		local Time = Castbar:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Time:SetPoint("RIGHT", Castbar, -3, 0)
		Time:SetJustifyH("RIGHT")
		
		-- Add spell text
		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Text:SetPoint("LEFT", Castbar, 3, 0)
		Text:SetSize(Settings["unitframes-player-cast-width"] * 0.7, Settings["unitframes-font-size"])
		Text:SetJustifyH("LEFT")
		
		-- Add spell icon
		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
		Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
		IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
		IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
		IconBG:SetTexture(Assets:GetTexture("Blank"))
		IconBG:SetVertexColor(0, 0, 0)
		
		-- Add safezone
		local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
		SafeZone:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
		
		-- Register it with oUF
		Castbar.bg = CastbarBG
		Castbar.Time = Time
		Castbar.Text = Text
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar.showTradeSkills = true
		Castbar.timeToHold = 0.7
		
		self.Castbar = Castbar
	end
	
	if Settings["unitframes-player-enable-resource"] then
		if (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
			local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self, "BackdropTemplate")
			ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			ComboPoints:SetSize(Settings["unitframes-player-width"], 10)
			ComboPoints:SetBackdrop(vUI.Backdrop)
			ComboPoints:SetBackdropColor(0, 0, 0)
			ComboPoints:SetBackdropBorderColor(0, 0, 0)
			
			local Max = (vUI.UserClass == "ROGUE" and 6 or 5)
			local Width = (Settings["unitframes-player-width"] / Max)
			
			for i = 1, Max do
				ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
				ComboPoints[i]:SetSize(Width, 8)
				ComboPoints[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ComboPoints[i]:SetStatusBarColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
				
				ComboPoints[i].bg = ComboPoints:CreateTexture(nil, "BORDER")
				ComboPoints[i].bg:SetAllPoints(ComboPoints[i])
				ComboPoints[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ComboPoints[i].bg:SetVertexColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
				ComboPoints[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					ComboPoints[i]:SetPoint("LEFT", ComboPoints, 1, 0)
				else
					ComboPoints[i]:SetPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
					ComboPoints[i]:SetWidth(Width - 2)
				end
			end
			
			self.ClassPower = ComboPoints
			self.AuraParent = ComboPoints
		elseif (vUI.UserClass == "WARLOCK") then
			local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self, "BackdropTemplate")
			SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			SoulShards:SetSize(Settings["unitframes-player-width"], 10)
			SoulShards:SetBackdrop(vUI.Backdrop)
			SoulShards:SetBackdropColor(0, 0, 0)
			SoulShards:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 5)
			
			for i = 1, 5 do
				SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "SoulShard" .. i, SoulShards)
				SoulShards[i]:SetSize(Width, 8)
				SoulShards[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				SoulShards[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-soul-shards"]))
				
				SoulShards[i].bg = SoulShards:CreateTexture(nil, "BORDER")
				SoulShards[i].bg:SetAllPoints(SoulShards[i])
				SoulShards[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				SoulShards[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-soul-shards"]))
				SoulShards[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					SoulShards[i]:SetPoint("LEFT", SoulShards, 1, 0)
				else
					SoulShards[i]:SetPoint("TOPLEFT", SoulShards[i-1], "TOPRIGHT", 1, 0)
					SoulShards[i]:SetWidth(Width - 2)
				end
			end
			
			self.ClassPower = SoulShards
			self.AuraParent = SoulShards
		elseif (vUI.UserClass == "MAGE") then
			local ArcaneCharges = CreateFrame("Frame", self:GetName() .. "ArcaneCharges", self, "BackdropTemplate")
			ArcaneCharges:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			ArcaneCharges:SetSize(Settings["unitframes-player-width"], 10)
			ArcaneCharges:SetBackdrop(vUI.Backdrop)
			ArcaneCharges:SetBackdropColor(0, 0, 0)
			ArcaneCharges:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 4)
			
			for i = 1, 4 do
				ArcaneCharges[i] = CreateFrame("StatusBar", self:GetName() .. "ArcaneCharge" .. i, ArcaneCharges)
				ArcaneCharges[i]:SetSize(Width, 8)
				ArcaneCharges[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ArcaneCharges[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-arcane-charges"]))
				
				ArcaneCharges[i].bg = ArcaneCharges:CreateTexture(nil, "BORDER")
				ArcaneCharges[i].bg:SetAllPoints(ArcaneCharges[i])
				ArcaneCharges[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ArcaneCharges[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-arcane-charges"]))
				ArcaneCharges[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					ArcaneCharges[i]:SetPoint("LEFT", ArcaneCharges, 1, 0)
				else
					ArcaneCharges[i]:SetPoint("TOPLEFT", ArcaneCharges[i-1], "TOPRIGHT", 1, 0)
					ArcaneCharges[i]:SetWidth(Width - 2)
				end
			end
			
			self.ClassPower = ArcaneCharges
			self.AuraParent = ArcaneCharges
		elseif (vUI.UserClass == "MONK") then
			local Chi = CreateFrame("Frame", self:GetName() .. "Chi", self, "BackdropTemplate")
			Chi:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			Chi:SetSize(Settings["unitframes-player-width"], 10)
			Chi:SetBackdrop(vUI.Backdrop)
			Chi:SetBackdropColor(0, 0, 0)
			Chi:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 6)
			
			for i = 1, 6 do
				Chi[i] = CreateFrame("StatusBar", self:GetName() .. "Chi" .. i, Chi)
				Chi[i]:SetSize(Width, 8)
				Chi[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Chi[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-chi"]))
				
				Chi[i].bg = Chi:CreateTexture(nil, "BORDER")
				Chi[i].bg:SetAllPoints(Chi[i])
				Chi[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Chi[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-chi"]))
				Chi[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					Chi[i]:SetPoint("LEFT", Chi, 1, 0)
				else
					Chi[i]:SetPoint("TOPLEFT", Chi[i-1], "TOPRIGHT", 1, 0)
					Chi[i]:SetWidth(Width - 2)
				end
			end
			
			self.ClassPower = Chi
			self.AuraParent = Chi
		elseif (vUI.UserClass == "DEATHKNIGHT") then
			local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self, "BackdropTemplate")
			Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			Runes:SetSize(Settings["unitframes-player-width"], 10)
			Runes:SetBackdrop(vUI.Backdrop)
			Runes:SetBackdropColor(0, 0, 0)
			Runes:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 6)
			
			for i = 1, 6 do
				Runes[i] = CreateFrame("StatusBar", self:GetName() .. "Rune" .. i, Runes)
				Runes[i]:SetSize(Width, 8)
				Runes[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Runes[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-runes"]))
				Runes[i].Duration = 0
				
				Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
				Runes[i].bg:SetAllPoints(Runes[i])
				Runes[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Runes[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-runes"]))
				Runes[i].bg:SetAlpha(0.2)
				
				Runes[i].Shine = Runes[i]:CreateTexture(nil, "ARTWORK")
				Runes[i].Shine:SetAllPoints(Runes[i])
				Runes[i].Shine:SetTexture(Assets:GetTexture("pHishTex28"))
				Runes[i].Shine:SetVertexColor(0.8, 0.8, 0.8)
				Runes[i].Shine:SetAlpha(0)
				Runes[i].Shine:SetDrawLayer("ARTWORK", 7)
				
				Runes[i].ReadyAnim = CreateAnimationGroup(Runes[i].Shine)
				
				Runes[i].ReadyAnim.In = Runes[i].ReadyAnim:CreateAnimation("Fade")
				Runes[i].ReadyAnim.In:SetOrder(1)
				Runes[i].ReadyAnim.In:SetEasing("in")
				Runes[i].ReadyAnim.In:SetDuration(0.2)
				Runes[i].ReadyAnim.In:SetChange(0.5)
				
				Runes[i].ReadyAnim.Out = Runes[i].ReadyAnim:CreateAnimation("Fade")
				Runes[i].ReadyAnim.Out:SetOrder(2)
				Runes[i].ReadyAnim.Out:SetEasing("out")
				Runes[i].ReadyAnim.Out:SetDuration(0.2)
				Runes[i].ReadyAnim.Out:SetChange(0)
				
				if ((i % 2) == 0) then
					Runes[i]:SetWidth(Width + 1)
				end
				
				if (i == 1) then
					Runes[i]:SetPoint("LEFT", Runes, 1, 0)
				else
					Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
					Runes[i]:SetWidth(Width - 2)
				end
			end
			
			self.Runes = Runes
			self.AuraParent = Runes
		elseif (vUI.UserClass == "PALADIN") then
			local HolyPower = CreateFrame("Frame", self:GetName() .. "HolyPower", self, "BackdropTemplate")
			HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			HolyPower:SetSize(Settings["unitframes-player-width"], 10)
			HolyPower:SetBackdrop(vUI.Backdrop)
			HolyPower:SetBackdropColor(0, 0, 0)
			HolyPower:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 5)
			
			for i = 1, 5 do
				HolyPower[i] = CreateFrame("StatusBar", self:GetName() .. "HolyPower" .. i, HolyPower)
				HolyPower[i]:SetSize(Width, 8)
				HolyPower[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				HolyPower[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-holy-power"]))
				
				HolyPower[i].bg = HolyPower:CreateTexture(nil, "BORDER")
				HolyPower[i].bg:SetAllPoints(HolyPower[i])
				HolyPower[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				HolyPower[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-holy-power"]))
				HolyPower[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					HolyPower[i]:SetPoint("LEFT", HolyPower, 1, 0)
				else
					HolyPower[i]:SetPoint("TOPLEFT", HolyPower[i-1], "TOPRIGHT", 1, 0)
					HolyPower[i]:SetWidth(Width - 2)
				end
			end
			
			self.ClassPower = HolyPower
			self.AuraParent = HolyPower
		end
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], 28)
	Buffs:SetPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 40
	Buffs.initialAnchor = "TOPLEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	--Buffs.SetPosition = BuffsSetPosition
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["unitframes-player-width"], 28)
	Debuffs:SetPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("CENTER", Health, 0, 0)
	
	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-player-health-left"])
	self:Tag(HealthRight, Settings["unitframes-player-health-right"])
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	--self.RaidTargetIndicator = RaidTarget
	self.ResurrectIndicator = Resurrect
	self.LeaderIndicator = Leader
end

local StyleTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.colors.debuff = vUI.DebuffColors
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-target-health-height"])
	Health:SetFrameLevel(5)
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-target-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-target-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["unitframes-target-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-target-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerLeft:SetPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerRight:SetPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-target-power-color"])
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], 28)
	Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 16
	Buffs.initialAnchor = "TOPLEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["unitframes-player-width"], 28)
	--vUI:SetPoint(Debuffs, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	Debuffs:SetPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
    -- Castbar
	if Settings["unitframes-target-enable-castbar"] then
		local Castbar = CreateFrame("StatusBar", "vUI Target Casting Bar", self)
		Castbar:SetSize(Settings["unitframes-target-cast-width"], Settings["unitframes-target-cast-height"])
		Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		
		local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
		CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
		CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
		CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		CastbarBG:SetAlpha(0.2)
		
		-- Add a background
		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetPoint("TOPLEFT", Castbar, -1, 1)
		Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
		Background:SetTexture(Assets:GetTexture("Blank"))
		Background:SetVertexColor(0, 0, 0)
		
		-- Add a timer
		local Time = Castbar:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Time:SetPoint("RIGHT", Castbar, -3, 0)
		Time:SetJustifyH("RIGHT")
		
		-- Add spell text
		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Text:SetPoint("LEFT", Castbar, 3, 0)
		Text:SetSize(Settings["unitframes-target-cast-width"] * 0.7, Settings["unitframes-font-size"])
		Text:SetJustifyH("LEFT")
		
		-- Add spell icon
		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(Settings["unitframes-target-cast-height"], Settings["unitframes-target-cast-height"])
		Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
		IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
		IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
		IconBG:SetTexture(Assets:GetTexture("Blank"))
		IconBG:SetVertexColor(0, 0, 0)
		
		Castbar.bg = CastbarBG
		Castbar.Time = Time
		Castbar.Text = Text
		Castbar.Icon = Icon
		Castbar.showTradeSkills = true
		Castbar.timeToHold = 0.3
		Castbar.PostCastStart = PostCastStart
		Castbar.PostChannelStart = PostCastStart
		
		self.Castbar = Castbar
	end
	
	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-target-health-left"])
	self:Tag(HealthRight, Settings["unitframes-target-health-right"])
	self:Tag(PowerLeft, Settings["unitframes-target-power-left"])
	self:Tag(PowerRight, Settings["unitframes-target-power-right"])
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.RaidTargetIndicator = RaidTarget
end

local StyleTargetTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-targettarget-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-targettarget-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-targettarget-health-color"])
	
	-- Power Bar
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["unitframes-targettarget-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-targettarget-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-targettarget-power-color"])
	
	self:Tag(HealthLeft, Settings["unitframes-targettarget-health-left"])
	self:Tag(HealthRight, Settings["unitframes-targettarget-health-right"])
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.RaidTargetIndicator = RaidTargetIndicator
end

local StylePet = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-pet-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-pet-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-pet-health-color"])
	
	-- Power Bar
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["unitframes-pet-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-pet-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-pet-power-color"])
	
	self:Tag(HealthLeft, Settings["unitframes-pet-health-left"])
	self:Tag(HealthRight, Settings["unitframes-pet-health-right"])
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.Power = Power
	self.Power.bg = PowerBG
end

local StyleFocus = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-focus-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-focus-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-focus-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["unitframes-focus-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-focus-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-focus-power-color"])
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetSize(Settings["unitframes-focus-width"] - 30, 24)
    Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -1, -3)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Time:SetPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Text:SetPoint("LEFT", Castbar, 3, 0)
	Text:SetSize(250 * 0.7, Settings["unitframes-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetSize(24, 24)
    Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Assets:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
	SafeZone:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
	
    -- Register it with oUF
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.SafeZone = SafeZone
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.7
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(((Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3) * 3) + 4, Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
	Buffs:SetPoint("LEFT", self, "RIGHT", 2, 0)
	Buffs.size = Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3
	Buffs.spacing = 2
	Buffs.num = 3
	Buffs.initialAnchor = "LEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	--Buffs.SetPosition = BuffsSetPosition
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(((Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3) * 3) + 4, Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
	Debuffs:SetPoint("LEFT", Buffs, "RIGHT", 2, 0)
	Debuffs.size = Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3
	Debuffs.spacing = 2
	Debuffs.num = 3
	Debuffs.initialAnchor = "LEFT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-focus-debuffs"]
	Debuffs.showType = true
	
	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-focus-health-left"])
	self:Tag(HealthRight, Settings["unitframes-focus-health-right"])
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Castbar = Castbar
	self.Buffs = Buffs
	self.Debuffs = Debuffs
end

local Offsets = {
	TOPLEFT = {6, 0},
	TOPRIGHT = {-6, 0},
	BOTTOMLEFT = {6, 0},
	BOTTOMRIGHT = {-6, 0},
	LEFT = {6, 0},
	RIGHT = {-6, 0},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

local BuffIDs = {
	["DRUID"] = {
		{774, "TOPLEFT", {0.8, 0.4, 0.8}},      -- Rejuvenation
		{155777, "LEFT", {0.8, 0.4, 0.8}},      -- Germination
		{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},    -- Regrowth
		{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}},  -- Wild Growth
		{102342, "RIGHT", {0.8, 0.2, 0.2}},     -- Ironbark
		{102351, "TOP", {0.84, 0.92, 0.77}},    -- Cenarion Ward
	},
	
	["MONK"] = {
		{119611, "TOPLEFT", {0.32, 0.89, 0.74}},  -- Renewing Mist
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},	  -- Life Cocoon
		{124682, "BOTTOMLEFT", {0.9, 0.8, 0.48}}, -- Enveloping Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}},   -- Zen Sphere
		{115175, "LEFT", {0.24, 0.87, 0.49}},     -- Soothing Mist
	},
	
	["PALADIN"] = {
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Light
		{156910, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Faith
		{200025, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Virtue
		{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},-- Blessing of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},	-- Blessing of Freedom
		--{1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true},	-- Blessing of Salvation
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},	-- Blessing of Sacrifice
		--{223306, "TOPLEFT", {0.81, 0.85, 0.1}},	    -- Bestow Faith
	},
	
	["PRIEST"] = {
		{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},  -- Prayer of Mending
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},     -- Renew
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
		{194384, "TOPRIGHT", {1, 0, 0}},          -- Atonement
		
		{33206, "BOTTOMLEFT", {237/255, 233/255, 221/255}}, -- Pain Suppression
		{121536, "BOTTOMRIGHT", {251/255, 193/255, 8/255}}, -- Angelic Feather
	},
	
	["SHAMAN"] = {
		{61295, "TOPLEFT", {0.7, 0.3, 0.7}},      -- Riptide
		{204288, "TOPRIGHT", {0.73, 0.61, 0.33}}, -- Earth Shield
	},
}

local PostCreateAuraWatchIcon = function(auras, icon)
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

local StyleParty = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["party-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["party-health-reverse"])
	Health:SetOrientation(Settings["party-health-orientation"])
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthDead = Health:CreateTexture(nil, "OVERLAY")
	HealthDead:SetAllPoints(Health)
	HealthDead:SetTexture(Assets:GetTexture("RenHorizonUp"))
	HealthDead:SetVertexColor(0.8, 0.8, 0.8)
	HealthDead:SetAlpha(0)
	HealthDead:SetDrawLayer("OVERLAY", 7)
	
	Health.DeadAnim = CreateAnimationGroup(HealthDead)
	
	Health.DeadAnim.In = Health.DeadAnim:CreateAnimation("Fade")
	Health.DeadAnim.In:SetOrder(1)
	Health.DeadAnim.In:SetEasing("in")
	Health.DeadAnim.In:SetDuration(0.15)
	Health.DeadAnim.In:SetChange(0.6)
	
	Health.DeadAnim.Out = Health.DeadAnim:CreateAnimation("Fade")
	Health.DeadAnim.Out:SetOrder(2)
	Health.DeadAnim.Out:SetEasing("out")
	Health.DeadAnim.Out:SetDuration(0.3)
	Health.DeadAnim.Out:SetChange(0)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthMiddle, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthMiddle:SetPoint("CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	local HealthBottom = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthBottom, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthBottom:SetPoint("BOTTOM", Health, 0, 1)
	HealthBottom:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	SetHealthAttributes(Health, Settings["party-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["party-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["party-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	SetPowerAttributes(Power, Settings["party-power-color"])
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(76, 19)
	Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Debuffs.size = 19
	Debuffs.num = 4
	Debuffs.spacing = 2
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.CustomFilter = CustomFilter
	Debuffs.showType = true
	
	if BuffIDs[vUI.UserClass] then
		local Auras = CreateFrame("Frame", nil, Health)
		Auras:SetPoint("TOPLEFT", Health, 2, -2)
		Auras:SetPoint("BOTTOMRIGHT", Health, -2, 2)
		Auras:SetFrameLevel(10)
		Auras:SetFrameStrata("HIGH")
		Auras.presentAlpha = 1
		Auras.missingAlpha = 0
		Auras.strictMatching = true
		Auras.icons = {}
		Auras.PostCreateIcon = PostCreateAuraWatchIcon
		
		for key, spell in pairs(BuffIDs[vUI.UserClass]) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon.strictMatching = true
			Icon:SetSize(8, 8)
			Icon:SetPoint(spell[2], 0, 0)
			
			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(Assets:GetTexture("Blank"))
			
			local BG = Icon:CreateTexture(nil, "BORDER")
			BG:SetPoint("TOPLEFT", Icon, -1, 1)
			BG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
			BG:SetTexture(Assets:GetTexture("Blank"))
			BG:SetVertexColor(0, 0, 0)
			
			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end
			
			local Count = Icon:CreateFontString(nil, "OVERLAY")
			vUI:SetFontInfo(Count, Settings["party-font"], 10)
			Count:SetPoint("CENTER", unpack(Offsets[spell[2]]))
			Icon.count = Count
			
			Auras.icons[spell[1]] = Icon
		end
		
		self.AuraWatch = Auras
	end
	
	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Leader:Hide()
	
	-- Assist
    local Assist = Health:CreateTexture(nil, "OVERLAY")
    Assist:SetSize(16, 16)
    Assist:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Assist:SetTexture(Assets:GetTexture("Assist"))
    Assist:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Assist:Hide()
	
	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, 'OVERLAY')
	ReadyCheck:SetSize(16, 16)
    ReadyCheck:SetPoint("CENTER", Health, 0, 0)
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("CENTER", Health, 0, 0)
	
	-- Role
	local RoleIndicator = Health:CreateTexture(nil, "OVERLAY")
	RoleIndicator:SetSize(16, 16)
	RoleIndicator:SetPoint("TOP", self, 0, -2)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, Health, "BackdropTemplate")
	Dispel:SetSize(20, 20)
	Dispel:SetPoint("CENTER", Health, 0, 0)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	vUI:SetFontInfo(Dispel.count, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	Dispel.count:SetPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Assets:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)
	
	self:Tag(HealthMiddle, "[Name8]")
	self:Tag(HealthBottom, "[HealthDeficit]")
	
	self.Range = {
		insideAlpha = Settings["party-in-range"] / 100,
		outsideAlpha = Settings["party-out-of-range"] / 100,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.HealthMiddle = HealthMiddle
	self.HealthBottom = HealthBottom
	self.ReadyCheck = ReadyCheck
	self.Debuffs = Debuffs
	self.Dispel = Dispel
	self.LeaderIndicator = Leader
	self.AssistantIndicator = Assist
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
	self.RaidTargetIndicator = RaidTarget
	self.GroupRoleIndicator = RoleIndicator
end

local StylePartyPet = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["party-pets-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["party-pets-health-reverse"])
	Health:SetOrientation(Settings["party-pets-health-orientation"])
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthMiddle, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthMiddle:SetPoint("CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	SetHealthAttributes(Health, Settings["party-pets-health-color"])
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	-- Tags
	self:Tag(HealthMiddle, "[Name10]")
	
	self.Range = {
		insideAlpha = Settings["party-in-range"] / 100,
		outsideAlpha = Settings["party-out-of-range"] / 100,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.HealthMiddle = HealthMiddle
	self.RaidTargetIndicator = RaidTarget
end

local StyleRaid = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["raid-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["raid-health-reverse"])
	Health:SetOrientation(Settings["raid-health-orientation"])
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["raid-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["raid-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-color"]))
	Power:SetReverseFill(Settings["raid-power-reverse"])
	Power:SetOrientation(Settings["raid-power-orientation"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-color"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	SetPowerAttributes(Power, Settings["raid-power-color"])
	
	-- Resurrect
	local ResurrectIndicator = Health:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(16, 16)
	ResurrectIndicator:SetSize(16, 16)
	ResurrectIndicator:SetPoint("CENTER", Health, 0, 0)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Dispel:SetSize(20, 20)
	Dispel:SetPoint("CENTER", Health)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	vUI:SetFontInfo(Dispel.count, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	Dispel.count:SetPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	Dispel.count:SetShadowColor(0, 0, 0)
	Dispel.count:SetShadowOffset(1.25, -1.25)
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Assets:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)
	
	-- Tags
	self:Tag(HealthLeft, "[Name5]")
	self:Tag(HealthRight, "[HealthDeficit]")
	
	self.Range = {
		insideAlpha = Settings["raid-in-range"] / 100,
		outsideAlpha = Settings["raid-out-of-range"] / 100,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Power = Power
	self.Power.bg = PowerBG
	self.Dispel = Dispel
	self.ResurrectIndicator = ResurrectIndicator
end

local StyleBoss = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-boss-health-height"])
	Health:SetFrameLevel(5)
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-boss-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["unitframes-boss-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerLeft:SetPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerRight:SetPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-boss-power-color"])
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], 28)
	Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 8
	Buffs.initialAnchor = "TOPLEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["unitframes-player-width"], 28)
	Debuffs:SetPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 8
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", self:GetName() .. " Casting Bar", self)
	Castbar:SetSize(250, 22)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
	Background:SetPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Time:SetPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Text:SetPoint("LEFT", Castbar, 3, 0)
	Text:SetSize(250 * 0.7, Settings["unitframes-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetSize(22, 22)
	Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Assets:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	Castbar.PostCastStart = PostCastStart
	Castbar.PostChannelStart = PostCastStart
	
	-- Tags
	self:Tag(HealthLeft, "[LevelColor][Level][Plus]|r [Name30]")
	self:Tag(HealthRight, "[HealthPercent]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[PowerValues]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	self.RaidTargetIndicator = RaidTarget
end

local Style = function(self, unit)
	if (unit == "player") then
		StylePlayer(self, unit)
	elseif (unit == "target") then
		StyleTarget(self, unit)
	elseif (unit == "targettarget") then
		StyleTargetTarget(self, unit)
	elseif (unit == "pet") then
		StylePet(self, unit)
	elseif (unit == "focus") then
		StyleFocus(self, unit)
	elseif (find(unit, "raid") and Settings["raid-enable"]) then
		StyleRaid(self, unit)
	elseif (find(unit, "partypet") and Settings["party-enable"] and Settings["party-pets-enable"]) then
		StylePartyPet(self, unit)
	elseif (find(unit, "party") and not find(unit, "pet") and Settings["party-enable"]) then
		StyleParty(self, unit)
	elseif (find(unit, "nameplate") and Settings["nameplates-enable"]) then
		StyleNamePlate(self, unit)
	elseif find(unit, "boss%d") then
		StyleBoss(self, unit)
	end
end

local UpdateShowPlayerBuffs = function(value)
	if vUI.UnitFrames["player"] then
		if value then
			vUI.UnitFrames["player"]:EnableElement("Auras")
			vUI.UnitFrames["player"]:UpdateAllElements("ForceUpdate")
		else
			vUI.UnitFrames["player"]:DisableElement("Auras")
		end
	end
end

local UpdateShowTargetBuffs = function(value)
	if vUI.UnitFrames["target"] then
		if value then
			vUI.UnitFrames["target"]:EnableElement("Auras")
			vUI.UnitFrames["target"]:UpdateAllElements("ForceUpdate")
		else
			vUI.UnitFrames["target"]:DisableElement("Auras")
		end
	end
end

local UpdateRaidSortingMethod = function(value)
	if (value == "CLASS") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "CLASS")
	elseif (value == "ROLE") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "ASSIGNEDROLE")
	elseif (value == "NAME") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", nil)
	elseif (value == "MTMA") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "ROLE")
	else -- GROUP
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "INDEX")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "GROUP")
	end
end

local NamePlateCVars = {
    nameplateGlobalScale = 1,
    NamePlateHorizontalScale = 1,
    NamePlateVerticalScale = 1,
    nameplateLargerScale = 1,
    nameplateMaxScale = 1,
    nameplateMinScale = 1,
    nameplateSelectedScale = 1,
    nameplateSelfScale = 1,
}

local UF = vUI:NewModule("Unit Frames")

oUF:RegisterStyle("vUI", Style)

UF:RegisterEvent("PLAYER_LOGIN")
UF:RegisterEvent("PLAYER_ENTERING_WORLD")
UF:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
		if Settings["unitframes-enable"] then
			local Player = oUF:Spawn("player", "vUI Player")
			
			if Settings["unitframes-player-enable-power"] then
				Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
			else
				Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + 2)
			end
			
			Player:SetPoint("TOPRIGHT", vUI.UIParent, "CENTER", -68, -281)
			Player:SetParent(vUI.UIParent)
			
			local Target = oUF:Spawn("target", "vUI Target")
			Target:SetSize(Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
			Target:SetPoint("TOPLEFT", vUI.UIParent, "CENTER", 68, -281)
			Target:SetParent(vUI.UIParent)
			
			local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
			TargetTarget:SetSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"] + Settings["unitframes-targettarget-power-height"] + 3)
			TargetTarget:SetPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -2)
			TargetTarget:SetParent(vUI.UIParent)
			
			local Pet = oUF:Spawn("pet", "vUI Pet")
			Pet:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"] + Settings["unitframes-pet-power-height"] + 3)
			Pet:SetPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -2)
			Pet:SetParent(vUI.UIParent)
			
			local Focus = oUF:Spawn("focus", "vUI Focus")
			Focus:SetSize(Settings["unitframes-focus-width"], Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
			Focus:SetPoint("RIGHT", vUI.UIParent, "CENTER", -68, 304)
			Focus:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["player"] = Player
			vUI.UnitFrames["target"] = Target
			vUI.UnitFrames["targettarget"] = TargetTarget
			vUI.UnitFrames["pet"] = Pet
			vUI.UnitFrames["focus"] = Focus
			
			UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
			UpdateShowTargetBuffs(Settings["unitframes-show-target-buffs"])
			
			vUI:CreateMover(Player)
			vUI:CreateMover(Target)
			vUI:CreateMover(TargetTarget)
			vUI:CreateMover(Pet)
			vUI:CreateMover(Focus)
			
			if Settings["unitframes-player-enable-castbar"] then
				Player.Castbar:SetPoint("BOTTOM", vUI.UIParent, 0, 118)
				vUI:CreateMover(Player.Castbar, 2)
			end
			
			if Settings["unitframes-target-enable-castbar"] then
				Target.Castbar:SetPoint("BOTTOM", vUI.UIParent, 0, 146)
				vUI:CreateMover(Target.Castbar, 2)
			end
		end
		
		if Settings["unitframes-boss-enable"] then
			for i = 1, 5 do
				local Boss = oUF:Spawn("boss" .. i, "vUI Boss " .. i)
				Boss:SetSize(Settings["unitframes-boss-width"], Settings["unitframes-boss-health-height"] + Settings["unitframes-boss-power-height"] + 3)
				Boss:SetParent(vUI.UIParent)
				
				if (i == 1) then
					Boss:SetPoint("LEFT", vUI.UIParent, 300, 200)
				else
					Boss:SetPoint("TOP", vUI.UnitFrames["boss" .. (i-1)], "BOTTOM", 0, -2)
				end
				
				vUI:CreateMover(Boss)
				
				vUI.UnitFrames["boss" .. i] = Boss
			end
		end
		
		if Settings["party-enable"] then
			local Party = oUF:SpawnHeader("vUI Party", nil, "party,solo",
				"initial-width", Settings["party-width"],
				"initial-height", (Settings["party-health-height"] + Settings["party-power-height"] + 3),
				"showSolo", false,
				"showPlayer", true,
				"showParty", true,
				"showRaid", false,
				"xoffset", Settings["party-x-offset"],
				"yOffset", Settings["party-y-offset"],
				"point", Settings["party-point"],
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)
			
			self.PartyAnchor = CreateFrame("Frame", "vUI Party Anchor", vUI.UIParent)
			self.PartyAnchor:SetSize((5 * Settings["party-width"] + (4 * Settings["party-x-offset"])), (Settings["party-health-height"] + Settings["party-power-height"]) + 3)
			self.PartyAnchor:SetPoint("BOTTOMLEFT", vUIChatFrameTop, "TOPLEFT", -3, 5)
			
			Party:SetPoint("BOTTOMLEFT", self.PartyAnchor, 0, 0)
			Party:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["party"] = Party
			
			vUI:CreateMover(self.PartyAnchor)
			
			if Settings["party-pets-enable"] then
				local PartyPet = oUF:SpawnHeader("vUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
					"initial-width", Settings["party-pets-width"],
					"initial-height", (Settings["party-pets-health-height"] + Settings["party-pets-power-height"] + 3),
					"showSolo", false,
					"showPlayer", false,
					"showParty", true,
					"showRaid", false,
					"xoffset", Settings["party-x-offset"],
					"yOffset", Settings["party-y-offset"],
					"point", Settings["party-point"],
					"oUF-initialConfigFunction", [[
						local Header = self:GetParent()
						
						self:SetWidth(Header:GetAttribute("initial-width"))
						self:SetHeight(Header:GetAttribute("initial-height"))
					]]
				)
				
				PartyPet:SetPoint("BOTTOMLEFT", Party, "TOPLEFT", 0, 2)
				PartyPet:SetParent(vUI.UIParent)
			end
		end
		
		if Settings["raid-enable"] then
			local Raid = oUF:SpawnHeader("vUI Raid", nil, "raid,solo",
				"initial-width", Settings["raid-width"],
				"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
				"showSolo", false,
				"showPlayer", true,
				"showParty", false,
				"showRaid", true,
				"point", Settings["raid-point"],
				"xoffset", Settings["raid-x-offset"],
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
			
			self.RaidAnchor = CreateFrame("Frame", "vUI Raid Anchor", vUI.UIParent)
			self.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
			self.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
			self.RaidAnchor:SetPoint("BOTTOMLEFT", vUIChatFrameTop, "TOPLEFT", -3, 5)
			
			local Hider = CreateFrame("Frame", nil, vUI.UIParent, "SecureHandlerStateTemplate")
			Hider:Hide()
			
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer:SetParent(Hider)
				
				--CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameManager:SetParent(Hider)
			end
			
			Raid:SetPoint("TOPLEFT", self.RaidAnchor, 0, 0)
			Raid:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["raid"] = Raid
			
			UpdateRaidSortingMethod(Settings["raid-sorting-method"])
			
			vUI:CreateMover(self.RaidAnchor)
		end
		
		if Settings["nameplates-enable"] then
			oUF:SpawnNamePlates(nil, NamePlateCallback, NamePlateCVars)
		end
	else
		UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
		UpdateShowTargetBuffs(Settings["unitframes-show-target-buffs"])
	end
end)

local UpdateOnlyPlayerDebuffs = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Debuffs.onlyShowPlayer = value
	end
end

local UpdatePlayerWidth = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame:SetWidth(value)
		
		-- Auras
		Frame.Buffs:SetWidth(value)
		Frame.Debuffs:SetWidth(value)
		
		-- Combo points
		if Frame.ComboPoints then
			Frame.ComboPoints:SetWidth(value)
			
			local Width = (value / 5)
			
			for i = 1, 5 do
				Frame.ComboPoints[i]:SetWidth(Width)
				
				if (i ~= 1) then
					Frame.ComboPoints[i]:SetWidth(Width - 2)
				end
			end
		end
	end
end

local UpdatePlayerHealthHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Health:SetHeight(value)
		Frame:SetHeight(value + Settings["unitframes-player-power-height"] + 3)
	end
end

local UpdatePlayerPowerHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-player-health-height"] + value + 3)
	end
end

local UpdatePlayerCastBarSize = function()
	if _G["vUI Casting Bar"] then
		_G["vUI Casting Bar"]:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])
		_G["vUI Casting Bar"].Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
	end
end

local UpdateTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame:SetWidth(value)
		
		-- Auras
		Frame.Buffs:SetWidth(value)
		Frame.Debuffs:SetWidth(value)
	end
end

local UpdateTargetHealthHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame.Health:SetHeight(value)
		Frame:SetHeight(value + Settings["unitframes-target-power-height"] + 3)
	end
end

local UpdateTargetPowerHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-target-health-height"] + value + 3)
	end
end

local UpdateTargetCastBarSize = function()
	if _G["vUI Target Casting Bar"] then
		_G["vUI Target Casting Bar"]:SetSize(Settings["unitframes-target-cast-width"], Settings["unitframes-target-cast-height"])
		_G["vUI Target Casting Bar"].Icon:SetSize(Settings["unitframes-target-cast-height"], Settings["unitframes-target-cast-height"])
	end
end

local UpdateTargetTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["targettarget"]:SetWidth(value)
	end
end

local UpdateTargetTargetHealthHeight = function(value)
	if vUI.UnitFrames["targettarget"] then
		vUI.UnitFrames["targettarget"].Health:SetHeight(value)
		vUI.UnitFrames["targettarget"]:SetHeight(value + Settings["unitframes-targettarget-power-height"] + 3)
	end
end

local UpdateTargetTargetPowerHeight = function(value)
	if vUI.UnitFrames["targettarget"] then
		local Frame = vUI.UnitFrames["targettarget"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-targettarget-health-height"] + value + 3)
	end
end

local UpdatePetWidth = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"]:SetWidth(value)
	end
end

local UpdatePetHealthHeight = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"].Health:SetHeight(value)
		vUI.UnitFrames["pet"]:SetHeight(value + Settings["unitframes-pet-power-height"] + 3)
	end
end

local UpdatePetPowerHeight = function(value)
	if vUI.UnitFrames["pet"] then
		local Frame = vUI.UnitFrames["pet"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-pet-health-height"] + value + 3)
	end
end

local UpdateFocusWidth = function(value)
	if vUI.UnitFrames["focus"] then
		vUI.UnitFrames["focus"]:SetWidth(value)
	end
end

local UpdateFocusHealthHeight = function(value)
	if vUI.UnitFrames["focus"] then
		vUI.UnitFrames["focus"].Health:SetHeight(value)
		vUI.UnitFrames["focus"]:SetHeight(value + Settings["unitframes-focus-power-height"] + 3)
	end
end

local UpdateFocusPowerHeight = function(value)
	if vUI.UnitFrames["focus"] then
		local Frame = vUI.UnitFrames["focus"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-focus-health-height"] + value + 3)
	end
end

local UpdatePlayerHealthFill = function(value)
	if vUI.UnitFrames["player"] then
		vUI.UnitFrames["player"].Health:SetReverseFill(value)
	end
end

local UpdatePlayerPowerFill = function(value)
	if vUI.UnitFrames["player"] then
		vUI.UnitFrames["player"].Power:SetReverseFill(value)
	end
end

local UpdateTargetHealthFill = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Health:SetReverseFill(value)
	end
end

local UpdateTargetPowerFill = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Power:SetReverseFill(value)
	end
end

local UpdateTargetTargetHealthFill = function(value)
	if vUI.UnitFrames["targettarget"] then
		vUI.UnitFrames["targettarget"].Health:SetReverseFill(value)
	end
end

local UpdateTargetTargetPowerFill = function(value)
	if vUI.UnitFrames["targettarget"] then
		vUI.UnitFrames["targettarget"].Power:SetReverseFill(value)
	end
end

local UpdatePetHealthFill = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"].Health:SetReverseFill(value)
	end
end

local UpdatePetPowerFill = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"].Power:SetReverseFill(value)
	end
end

local UpdateFocusHealthFill = function(value)
	if vUI.UnitFrames["focus"] then
		vUI.UnitFrames["focus"].Health:SetReverseFill(value)
	end
end

local UpdateFocusPowerFill = function(value)
	if vUI.UnitFrames["focus"] then
		vUI.UnitFrames["focus"].Power:SetReverseFill(value)
	end
end

local UpdatePlayerHealthColor = function(value)
	if vUI.UnitFrames["player"] then
		local Health = vUI.UnitFrames["player"].Health
		
		SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdatePlayerPowerColor = function(value)
	if vUI.UnitFrames["player"] then
		local Power = vUI.UnitFrames["player"].Power
		
		SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdateTargetHealthColor = function(value)
	if vUI.UnitFrames["target"] then
		local Health = vUI.UnitFrames["target"].Health
		
		SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdateTargetPowerColor = function(value)
	if vUI.UnitFrames["target"] then
		local Power = vUI.UnitFrames["target"].Power
		
		SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdateTargetTargetHealthColor = function(value)
	if vUI.UnitFrames["targettarget"] then
		local Health = vUI.UnitFrames["targettarget"].Health
		
		SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdateTargetTargetPowerColor = function(value)
	if vUI.UnitFrames["targettarget"] then
		local Power = vUI.UnitFrames["targettarget"].Power
		
		SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdatePetHealthColor = function(value)
	if vUI.UnitFrames["pet"] then
		local Health = vUI.UnitFrames["pet"].Health
		
		SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdatePetPowerColor = function(value)
	if vUI.UnitFrames["pet"] then
		local Power = vUI.UnitFrames["pet"].Power
		
		SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdateFocusHealthColor = function(value)
	if vUI.UnitFrames["focus"] then
		local Health = vUI.UnitFrames["focus"].Health
		
		SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdateFocusPowerColor = function(value)
	if vUI.UnitFrames["focus"] then
		local Power = vUI.UnitFrames["focus"].Power
		
		SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

GUI:AddSettings(Language["General"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the unit frames module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("unitframes-font", Settings["unitframes-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the unit frames"], nil, "Font")
	left:CreateSlider("unitframes-font-size", Settings["unitframes-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the unit frames"])
	left:CreateDropdown("unitframes-font-flags", Settings["unitframes-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the unit frames"])
end)

GUI:AddSettings(Language["General"], Language["Player"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."], ReloadUI):RequiresReload(true)
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateShowPlayerBuffs)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePlayerHealthFill)
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdatePlayerHealthHeight)
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePlayerHealthColor)
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar", UpdatePlayerPowerHeight)
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePlayerPowerColor)
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Cast Bar"])
	right:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"], ReloadUI):RequiresReload(true)
	right:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"], UpdatePlayerCastBarSize)
	right:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"], UpdatePlayerCastBarSize)
end)

GUI:AddSettings(Language["General"], Language["Target"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-target-width", Settings["unitframes-target-width"], 120, 320, 1, "Width", "Set the width of the target unit frame", UpdateTargetWidth)
	left:CreateSwitch("unitframes-show-target-buffs", Settings["unitframes-show-target-buffs"], Language["Show Target Buffs"], Language["Show yauras above the target unit frame"], UpdateShowTargetBuffs)
	left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed on the target"], UpdateOnlyPlayerDebuffs)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-target-health-reverse", Settings["unitframes-target-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateTargetHealthFill)
	left:CreateSlider("unitframes-target-health-height", Settings["unitframes-target-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the target health bar", UpdateTargetHealthHeight)
	left:CreateDropdown("unitframes-target-health-color", Settings["unitframes-target-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Color"], Language["Set the color of the health bar"], UpdateTargetHealthColor)
	left:CreateInput("unitframes-target-health-left", Settings["unitframes-target-health-left"], Language["Left Health Text"], Language["Set the text on the left of the target health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-target-health-right", Settings["unitframes-target-health-right"], Language["Right Health Text"], Language["Set the text on the right of the target health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-target-power-reverse", Settings["unitframes-target-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateTargetPowerFill)
	right:CreateSlider("unitframes-target-power-height", Settings["unitframes-target-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the target power bar", UpdateTargetPowerHeight)
	right:CreateDropdown("unitframes-target-power-color", Settings["unitframes-target-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateTargetPowerColor)
	right:CreateInput("unitframes-target-power-left", Settings["unitframes-target-power-left"], Language["Left Power Text"], Language["Set the text on the left of the target power bar"], ReloadUI):RequiresReload(true)
	right:CreateInput("unitframes-target-power-right", Settings["unitframes-target-power-right"], Language["Right Power Text"], Language["Set the text on the right of the target power bar"], ReloadUI):RequiresReload(true)
	right:CreateInput("unitframes-target-power-right", Settings["unitframes-target-power-right"], Language["Right Power Text"], Language["Set the text on the right of the target power bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Cast Bar"])
	right:CreateSwitch("unitframes-target-enable-castbar", Settings["unitframes-target-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the target cast bar"], ReloadUI):RequiresReload(true)
	
	right:CreateSlider("unitframes-target-cast-width", Settings["unitframes-target-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the target cast bar"], UpdateTargetCastBarSize)
	right:CreateSlider("unitframes-target-cast-height", Settings["unitframes-target-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the target cast bar"], UpdateTargetCastBarSize)
end)

GUI:AddSettings(Language["General"], Language["Target of Target"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-targettarget-width", Settings["unitframes-targettarget-width"], 60, 320, 1, "Width", "Set the width of the target's target unit frame", UpdateTargetTargetWidth)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-targettarget-health-reverse", Settings["unitframes-targettarget-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateTargetTargetHealthFill)
	left:CreateSlider("unitframes-targettarget-health-height", Settings["unitframes-targettarget-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the target of target health bar", UpdateTargetTargetHealthHeight)
	left:CreateDropdown("unitframes-targettarget-health-color", Settings["unitframes-targettarget-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateTargetTargetHealthColor)
	left:CreateInput("unitframes-targettarget-health-left", Settings["unitframes-targettarget-health-left"], Language["Left Health Text"], Language["Set the text on the left of the target of target health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-targettarget-health-right", Settings["unitframes-targettarget-health-right"], Language["Right Health Text"], Language["Set the text on the right of the target of target health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-targettarget-power-reverse", Settings["unitframes-targettarget-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateTargetTargetPowerFill)
	right:CreateSlider("unitframes-targettarget-power-height", Settings["unitframes-targettarget-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the target of target power bar", UpdateTargetTargetPowerHeight)
	right:CreateDropdown("unitframes-targettarget-power-color", Settings["unitframes-targettarget-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateTargetTargetPowerColor)
end)

GUI:AddSettings(Language["General"], Language["Pet"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-pet-width", Settings["unitframes-pet-width"], 60, 320, 1, "Width", "Set the width of the pet unit frame", UpdatePetWidth)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-pet-health-reverse", Settings["unitframes-pet-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePetHealthFill)
	left:CreateSlider("unitframes-pet-health-height", Settings["unitframes-pet-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the pet health bar", UpdatePetHealthHeight)
	left:CreateDropdown("unitframes-pet-health-color", Settings["unitframes-pet-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePetHealthColor)
	left:CreateInput("unitframes-pet-health-left", Settings["unitframes-pet-health-left"], Language["Left Health Text"], Language["Set the text on the left of the pet health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-pet-health-right", Settings["unitframes-pet-health-right"], Language["Right Health Text"], Language["Set the text on the right of the pet health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-pet-power-reverse", Settings["unitframes-pet-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePetPowerFill)
	right:CreateSlider("unitframes-pet-power-height", Settings["unitframes-pet-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the pet power bar", UpdatePetPowerHeight)
	right:CreateDropdown("unitframes-pet-power-color", Settings["unitframes-pet-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePetPowerColor)
end)

GUI:AddSettings(Language["General"], Language["Focus"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-focus-width", Settings["unitframes-focus-width"], 60, 320, 1, "Width", "Set the width of the focus unit frame", UpdateFocusWidth)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-focus-health-reverse", Settings["unitframes-focus-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateFocusHealthFill)
	left:CreateSlider("unitframes-focus-health-height", Settings["unitframes-focus-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the focus health bar", UpdateFocusHealthHeight)
	left:CreateDropdown("unitframes-focus-health-color", Settings["unitframes-focus-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateFocusHealthColor)
	left:CreateInput("unitframes-focus-health-left", Settings["unitframes-focus-health-left"], Language["Left Health Text"], Language["Set the text on the left of the focus health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-focus-health-right", Settings["unitframes-focus-health-right"], Language["Right Health Text"], Language["Set the text on the right of the focus health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-focus-power-reverse", Settings["unitframes-focus-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateFocusPowerFill)
	right:CreateSlider("unitframes-focus-power-height", Settings["unitframes-focus-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the focus power bar", UpdateFocusPowerHeight)
	right:CreateDropdown("unitframes-focus-power-color", Settings["unitframes-focus-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateFocusPowerColor)
end)

GUI:AddSettings(Language["General"], Language["Bosses"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Bosses"])
	left:CreateSwitch("unitframes-boss-enable", Settings["unitframes-boss-enable"], Language["Enable Boss Frames"], Language["Enable the boss unit frames"], ReloadUI):RequiresReload(true)
end)

local UpdatePartyWidth = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit:SetWidth(value)
			end
		end
	end
end

local UpdatePartyHealthHeight = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit:SetHeight(value + Settings["party-power-height"] + 3)
				Unit.Health:SetHeight(value)
			end
		end
	end
end

local UpdatePartyHealthColor = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				SetHealthAttributes(Unit.Health, value)
				
				Unit.Health:ForceUpdate()
			end
		end
	end
end

local UpdatePartyPowerHeight = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit:SetHeight(value + Settings["party-health-height"] + 3)
				Unit.Power:SetHeight(value)
			end
		end
	end
end

local UpdatePartyHealthOrientation = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit.Health:SetOrientation(value)
			end
		end
	end
end

local UpdatePartyHealthReverseFill = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit.Health:SetReverseFill(value)
			end
		end
	end
end

local UpdatePartyPowerReverseFill = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				Unit.Power:SetReverseFill(value)
			end
		end
	end
end

local UpdatePartyPowerColor = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				SetPowerAttributes(Unit.Power, value)
				
				Unit.Power:ForceUpdate()
			end
		end
	end
end

local UpdatePartyShowDebuffs = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				if value then
					Unit:EnableElement("Debuffs")
				else
					Unit:DisableElement("Debuffs")
				end
			end
		end
	end
end

local UpdatePartyShowRole = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				if value then
					Unit:EnableElement("GroupRoleIndicator")
				else
					Unit:DisableElement("GroupRoleIndicator")
				end
			end
		end
	end
end

local UpdatePartyXOffset = function(value)
	vUI.UnitFrames["party"]:SetAttribute("xoffset", value)
end

local UpdatePartyYOffset = function(value)
	vUI.UnitFrames["party"]:SetAttribute("yoffset", value)
end

local UpdatePartyAnchor = function(value)
	vUI.UnitFrames["party"]:SetAttribute("point", value)
end

GUI:AddSettings(Language["General"], Language["Party"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("party-enable", Settings["party-enable"], Language["Enable Party Module"], Language["Enable the party frames module"], ReloadUI):RequiresReload(true)
	left:CreateSwitch("party-pets-enable", Settings["party-pets-enable"], Language["Enable Party Pet Frames"], Language["Enable the party pet frames module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Party Size"])
	left:CreateSlider("party-width", Settings["party-width"], 40, 200, 1, Language["Width"], Language["Set the width of the party frames"], UpdatePartyWidth)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("party-font", Settings["party-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the party frames"], nil, "Font")
	left:CreateSlider("party-font-size", Settings["party-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the party frames"])
	left:CreateDropdown("party-font-flags", Settings["party-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the party frames"])
	
	right:CreateHeader(Language["Health"])
	right:CreateSlider("party-health-height", Settings["party-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of party health bars"], UpdatePartyHealthHeight)
	right:CreateDropdown("party-health-color", Settings["party-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePartyHealthColor)
	right:CreateDropdown("party-health-orientation", Settings["party-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"], UpdatePartyHealthOrientation)
	right:CreateSwitch("party-health-reverse", Settings["party-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePartyHealthReverseFill)
	
	right:CreateHeader(Language["Power"])
	right:CreateSlider("party-power-height", Settings["party-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of party power bars"], UpdatePartyPowerHeight)
	right:CreateDropdown("party-power-color", Settings["party-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePartyPowerColor)
	right:CreateSwitch("party-power-reverse", Settings["party-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePartyPowerReverseFill)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("party-show-debuffs", Settings["party-show-debuffs"], Language["Enable Debuffs"], Language["Display debuffs on party members"], UpdatePartyShowDebuffs)
	left:CreateSwitch("party-show-role", Settings["party-show-role"], Language["Enable Role Icons"], Language["Display role icons on party members"], UpdatePartyShowRole)
	
	left:CreateHeader(Language["Range Opacity"])
	left:CreateSlider("party-in-range", Settings["party-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of party members within range of you"])
	left:CreateSlider("party-out-of-range", Settings["party-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of party members out of your range"])
	
	left:CreateHeader(Language["Attributes"])
	left:CreateSlider("party-x-offset", Settings["party-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of party units from eachother"], UpdatePartyXOffset)
	left:CreateSlider("party-y-offset", Settings["party-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of party units from eachother"], UpdatePartyYOffset)
	left:CreateDropdown("party-point", Settings["party-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new party members will anchor to previous ones"], UpdatePartyAnchor)
	
	right:CreateHeader(Language["Party Pets Size"])
	right:CreateSlider("party-pets-width", Settings["party-pets-width"], 40, 200, 1, Language["Width"], Language["Set the width of party pet unit frames"], ReloadUI, nil):RequiresReload(true)
end)

local UpdateRaidAnchorSize = function()
	UF.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
	UF.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
end

local UpdateRaidWidth = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit:SetWidth(value)
			end
		end
		
		UpdateRaidAnchorSize()
	end
end

local UpdateRaidHealthHeight = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit:SetHeight(value + Settings["raid-power-height"] + 3)
				Unit.Health:SetHeight(value)
			end
		end
		
		UpdateRaidAnchorSize()
	end
end

local UpdateRaidHealthColor = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				SetHealthAttributes(Unit.Health, value)
				
				Unit.Health:ForceUpdate()
			end
		end
	end
end

local UpdateRaidHealthOrientation = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit.Health:SetOrientation(value)
			end
		end
	end
end

local UpdateRaidHealthReverseFill = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit.Health:SetReverseFill(value)
			end
		end
	end
end

local UpdateRaidPowerHeight = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit:SetHeight(value + Settings["raid-health-height"] + 3)
				Unit.Power:SetHeight(value)
			end
		end
		
		UpdateRaidAnchorSize()
	end
end

local UpdateRaidPowerReverseFill = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				Unit.Power:SetReverseFill(value)
			end
		end
	end
end

local UpdateRaidPowerColor = function(value)
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
			if Unit then
				SetPowerAttributes(Unit.Power, value)
				
				Unit.Power:ForceUpdate()
			end
		end
	end
end

local UpdateRaidXOffset = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("xoffset", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidYOffset = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("yoffset", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidUnitsPerColumn = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("unitsPerColumn", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidMaxColumns = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("maxColumns", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidColumnSpacing = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("columnSpacing", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidColumnAnchor = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("columnAnchorPoint", value)
	
	UpdateRaidAnchorSize()
end

local UpdateRaidPoint = function(value)
	vUI.UnitFrames["raid"]:SetAttribute("point", value)
	
	UpdateRaidAnchorSize()
end

GUI:AddSettings(Language["General"], Language["Raid"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("raid-enable", Settings["raid-enable"], Language["Enable Raid Module"], Language["Enable the raid frames module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Raid Size"])
	left:CreateSlider("raid-width", Settings["raid-width"], 40, 200, 1, Language["Width"], Language["Set the width of the raid frames"], UpdateRaidWidth, nil)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("raid-font", Settings["raid-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the raid frames"], nil, "Font")
	left:CreateSlider("raid-font-size", Settings["raid-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the raid frames"])
	left:CreateDropdown("raid-font-flags", Settings["raid-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the raid frames"])
	
	right:CreateHeader(Language["Health"])
	right:CreateSlider("raid-health-height", Settings["raid-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of raid health bars"], UpdateRaidHealthHeight)
	right:CreateDropdown("raid-health-color", Settings["raid-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateRaidHealthColor)
	right:CreateDropdown("raid-health-orientation", Settings["raid-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"], UpdateRaidHealthOrientation)
	right:CreateSwitch("raid-health-reverse", Settings["raid-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateRaidHealthReverseFill)
	
	right:CreateHeader(Language["Power"])
	right:CreateSlider("raid-power-height", Settings["raid-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of raid power bars"], UpdateRaidPowerHeight)
	right:CreateDropdown("raid-power-color", Settings["raid-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateRaidPowerColor)
	right:CreateSwitch("raid-power-reverse", Settings["raid-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateRaidPowerReverseFill)
	
	left:CreateHeader(Language["Range Opacity"])
	left:CreateSlider("raid-in-range", Settings["raid-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of raid members within range of you"])
	left:CreateSlider("raid-out-of-range", Settings["raid-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of raid members out of your range"])
	
	left:CreateHeader(Language["Attributes"])
	left:CreateSlider("raid-x-offset", Settings["raid-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of raid units from eachother"], UpdateRaidXOffset)
	left:CreateSlider("raid-y-offset", Settings["raid-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of raid units from eachother"], UpdateRaidYOffset)
	left:CreateSlider("raid-units-per-column", Settings["raid-units-per-column"], 1, 40, 1, Language["Units Per Column"], Language["Set the maximum number of units per column"], UpdateRaidUnitsPerColumn)
	left:CreateSlider("raid-max-columns", Settings["raid-max-columns"], 1, 40, 1, Language["Max Columns"], Language["Set the maximum number of visible columns of raid units"], UpdateRaidMaxColumns)
	left:CreateSlider("raid-column-spacing", Settings["raid-column-spacing"], -10, 10, 1, Language["Column Spacing"], Language["Set the spacing between columns of raid units"], UpdateRaidColumnSpacing)
	left:CreateDropdown("raid-sorting-method", Settings["raid-sorting-method"], {[Language["Group"]] = "GROUP", [Language["Name"]] = "NAME", [Language["Class"]] = "CLASS", [Language["Role"]] = "ROLE", [Language["Main Tank"]] = "MTMA"}, Language["Sorting Method"], Language["Set how the raid units are sorted"], UpdateRaidSortingMethod)
	left:CreateDropdown("raid-point", Settings["raid-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new raid frames will connect to previous ones"], UpdateRaidPoint)
	left:CreateDropdown("raid-column-anchor", Settings["raid-column-anchor"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["New Column Anchor"], Language["Set where new columns should anchor to"], ReloadUI):RequiresReload(true)
end)

local NamePlatesUpdateEnableDebuffs = function(self, value)
	if value then
		self:EnableElement("Auras")
	else
		self:DisableElement("Auras")
	end
end

local UpdateNamePlatesEnableDebuffs = function(value)
	oUF:RunForAllNamePlates(NamePlatesUpdateEnableDebuffs, value)
end

local NamePlatesUpdateShowPlayerDebuffs = function(self)
	if self.Debuffs then
		self.Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	end
end

local UpdateNamePlatesShowPlayerDebuffs = function(value)
	oUF:RunForAllNamePlates(NamePlatesUpdateShowPlayerDebuffs, value)
end

local NamePlateSetWidth = function(self)
	self:SetWidth(Settings["nameplates-width"])
end

local UpdateNamePlatesWidth = function()
	oUF:RunForAllNamePlates(NamePlateSetWidth)
end

local NamePlateSetHeight = function(self)
	self:SetHeight(Settings["nameplates-height"])
end

local UpdateNamePlatesHeight = function()
	oUF:RunForAllNamePlates(NamePlateSetHeight)
end

local NamePlateSetHealthColor = function(self)
	SetHealthAttributes(self.Health, Settings["nameplates-health-color"])
end

local UpdateNamePlatesHealthColor = function()
	oUF:RunForAllNamePlates(NamePlateSetHealthColor)
end

local NamePlateSetTargetHightlight = function(self, value)
	if value then
		self:EnableElement("TargetIndicator")
	else
		self:DisableElement("TargetIndicator")
	end
end

local UpdateNamePlatesTargetHighlight = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetHightlight, value)
end

local NamePlateSetFont = function(self)
	vUI:SetFontInfo(self.Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Castbar.Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetFontInfo(self.Castbar.Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
end

local UpdateNamePlatesFont = function()
	oUF:RunForAllNamePlates(NamePlateSetFont)
end

local NamePlateEnableCastBars = function(self, value)
	if value then
		self:EnableElement("Castbar")
	else
		self:DisableElement("Castbar")
	end
end

local UpdateNamePlatesEnableCastBars = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetHightlight, value)
end

local NamePlateSetCastBarsHeight = function(self, value)
	self.Castbar:SetHeight(value)
end

local UpdateNamePlatesCastBarsHeight = function(value)
	oUF:RunForAllNamePlates(NamePlateSetCastBarsHeight, value)
end

local NamePlateSetTargetIndicatorSize = function(self, value)
	if (value == "SMALL") then
		self.TargetIndicator.left:SetTexture(Assets:GetTexture("Arrow Left"))
		self.TargetIndicator.right:SetTexture(Assets:GetTexture("Arrow Right"))
	elseif (value == "LARGE") then
		self.TargetIndicator.left:SetTexture(Assets:GetTexture("Arrow Left Large"))
		self.TargetIndicator.right:SetTexture(Assets:GetTexture("Arrow Right Large"))
	elseif (value == "HUGE") then
		self.TargetIndicator.left:SetTexture(Assets:GetTexture("Arrow Left Huge"))
		self.TargetIndicator.right:SetTexture(Assets:GetTexture("Arrow Right Huge"))
	end
end

local UpdateNamePlatesTargetIndicatorSize = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetIndicatorSize, value)
end

GUI:AddSettings(Language["General"], Language["Name Plates"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates"], Language["Enable the vUI name plates module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("nameplates-font", Settings["nameplates-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the name plates"], UpdateNamePlatesFont, "Font")
	left:CreateSlider("nameplates-font-size", Settings["nameplates-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the name plates"], UpdateNamePlatesFont)
	left:CreateDropdown("nameplates-font-flags", Settings["nameplates-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the name plates"], UpdateNamePlatesFont)
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates", UpdateNamePlatesWidth)
	left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates", UpdateNamePlatesHeight)
	left:CreateDropdown("nameplates-health-color", Settings["nameplates-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateNamePlatesHealthColor)
	left:CreateSwitch("nameplates-health-smooth", Settings["nameplates-health-smooth"], Language["Enable Smooth Progress"], Language["Set the health bar to animate changes smoothly"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Debuffs"])
	left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Debuffs"], Language["Display your debuffs above enemy name plates"], UpdateNamePlatesEnableDebuffs)
	left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed"], UpdateNamePlatesShowPlayerDebuffs)
	
	right:CreateHeader(Language["Information"])
	right:CreateInput("nameplates-top-text", Settings["nameplates-top-text"], Language["Top Text"], "")
	right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	right:CreateInput("nameplates-bottom-text", Settings["nameplates-bottom-text"], Language["Bottom Text"], "")
	right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	right:CreateHeader(Language["Casting Bar"])
	right:CreateSwitch("nameplates-enable-castbar", Settings["nameplates-enable-castbar"], Language["Enable Casting Bar"], Language["Enable the casting bar the name plates"], UpdateNamePlatesEnableCastBars)
	right:CreateSlider("nameplates-castbar-height", Settings["nameplates-castbar-height"], 3, 28, 1, Language["Set Height"], Language["Set the height of name plate casting bars"], UpdateNamePlatesCastBarsHeight)
	
	right:CreateHeader(Language["Target Indicator"])
	right:CreateSwitch("nameplates-enable-target-indicator", Settings["nameplates-enable-target-indicator"], Language["Enable Target Indicator"], Language["Display an indication on the targetted unit name plate"], UpdateNamePlatesTargetHighlight)
	right:CreateDropdown("nameplates-target-indicator-size", Settings["nameplates-target-indicator-size"], {[Language["Small"]] = "SMALL", [Language["Large"]] = "LARGE", [Language["Huge"]] = "HUGE"}, Language["Indicator Size"], Language["Select the size of the target indicator"], UpdateNamePlatesTargetIndicatorSize)
end)

--/run vUIFakeRaid()
vUIFakeRaid = function(num)
	local Header = _G["vUI Raid"]
	local Index = num and num - 1 or 24
	
	if Header then
		if (Header:GetAttribute("startingIndex") ~= -Index) then
			Header:SetAttribute("startingIndex", -Index)
		end
		
		for i = 1, select("#", Header:GetChildren()) do
			local Frame = select(i, Header:GetChildren())
			
			Frame.unit = "player"
			UnregisterUnitWatch(Frame)
			RegisterUnitWatch(Frame, true)
			Frame:Show()
		end
	end
end

--/run vUIFakeParty()
vUIFakeParty = function(num)
	local Header = _G["vUI Party"]
	local Index = num and num - 1 or 4
	
	if Header then
		if (Header:GetAttribute("startingIndex") ~= -Index) then
			Header:SetAttribute("startingIndex", -Index)
		end
		
		for i = 1, select("#", Header:GetChildren()) do
			local Frame = select(i, Header:GetChildren())
			
			Frame.unit = "player"
			UnregisterUnitWatch(Frame)
			RegisterUnitWatch(Frame, true)
			Frame:Show()
		end
	end
end