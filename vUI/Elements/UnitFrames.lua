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
	["Sated"] = true,
	["Temporal Displacement"] = true,
	["Challenger's Burden"] = true,
}

local CustomFilter = function(icons, unit, icon, name, texture, count, dtype, duration, timeLeft, caster)
	if (not Ignore[name]) then
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

Events["Health"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["Health"] = function(unit)
	return vUI:ShortValue(UnitHealth(unit))
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
	
	return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
end

Events["HealthDeficit"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
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

Events["GroupStatus"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION UNIT_FLAGS PLAYER_ENTERING_WORLD"
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

Events["HealthColor"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
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
				return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			local Color = vUI.ReactionColors[Reaction]
			
			if Color then
				return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
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
			return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
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
		vUI:SetPoint(Parent.Buffs, "BOTTOMLEFT", Parent.ComboPoints, "TOPLEFT", 0, 2)
	else
		vUI:SetPoint(Parent.Buffs, "BOTTOMLEFT", Parent, "TOPLEFT", 0, 2)
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
	
	if (vUI.DebuffColors[debuffType] and button.filter == "HARMFUL") then
		button:SetBackdropColor(unpack(vUI.DebuffColors[debuffType]))
	else
		button:SetBackdropColor(unpack(vUI.DebuffColors["none"]))
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
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	vUI:SetPoint(button.cd, "TOPLEFT", button, 1, -1)
	vUI:SetPoint(button.cd, "BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	
	vUI:SetPoint(button.icon, "TOPLEFT", 1, -1)
	vUI:SetPoint(button.icon, "BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	vUI:SetPoint(button.count, "BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	vUI:SetFontInfo(button.count, Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(button.Time, Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	vUI:SetPoint(button.Time, "TOPLEFT", 2, -2)
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
		vUI:SetPoint(Button, Anchor, element, Anchor, Column * SizeX * GrowthX, Row * SizeY * GrowthY)
	end
	
	if (Rows > 0) then
		vUI:SetHeight(element, element.size * Rows + ((Rows - 1) * element.spacing))
	else
		vUI:SetHeight(element, element.size)
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
	
	vUI:SetSize(self, Settings["nameplates-width"], Settings["nameplates-height"])
	vUI:SetHeight(self.Castbar, Settings["nameplates-castbar-height"])
	
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
	vUI:SetSize(self, Settings["nameplates-width"], Settings["nameplates-height"])
	vUI:SetPoint(self, "CENTER", 0, 0)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("LEFT", Health, "RIGHT", 5, 0)
	
	local Top = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(Top, "CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(TopLeft, "LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(TopRight, "RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local Bottom = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(Bottom, "CENTER", Health, "BOTTOM", 0, -3)
	Bottom:SetJustifyH("CENTER")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(BottomRight, "RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(BottomLeft, "LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	--[[local InsideCenter = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(InsideCenter, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(InsideCenter, "CENTER", Health, 0, 0)
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
	vUI:SetHeight(Threat.Top, 6)
	vUI:SetPoint(Threat.Top, "BOTTOMLEFT", Threat, "TOPLEFT", 8, 1)
	vUI:SetPoint(Threat.Top, "BOTTOMRIGHT", Threat, "TOPRIGHT", -8, 1)
	Threat.Top:SetTexture(Assets:GetHighlight("RenHorizonUp"))
	Threat.Top:SetAlpha(0.8)
	
	Threat.Bottom = Threat:CreateTexture(nil, "BORDER")
	vUI:SetHeight(Threat.Bottom, 6)
	vUI:SetPoint(Threat.Bottom, "TOPLEFT", Threat, "BOTTOMLEFT", 8, -1)
	vUI:SetPoint(Threat.Bottom, "TOPRIGHT", Threat, "BOTTOMRIGHT", -8, -1)
	Threat.Bottom:SetTexture(Assets:GetHighlight("RenHorizonDown"))
	Threat.Bottom:SetAlpha(0.8)
	
	-- Buffs
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	vUI:SetSize(Buffs, 30, 30)
	vUI:SetPoint(Buffs, "BOTTOM", self, "TOP", 0, 36)
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
	vUI:SetSize(Debuffs, Settings["nameplates-width"], 26)
	vUI:SetPoint(Debuffs, "BOTTOM", Health, "TOP", 0, 14)
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
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    vUI:SetSize(Castbar, Settings["nameplates-width"] - 2, Settings["nameplates-castbar-height"])
	vUI:SetPoint(Castbar, "TOP", Health, "BOTTOM", 0, -4)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(CastbarBG, "TOPLEFT", Castbar, 0, 0)
	vUI:SetPoint(CastbarBG, "BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(Background, "TOPLEFT", Castbar, -1, 1)
    vUI:SetPoint(Background, "BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(Time, "RIGHT", Castbar, "BOTTOMRIGHT", -4, -3)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	vUI:SetPoint(Text, "LEFT", Castbar, "BOTTOMLEFT", 4, -3)
	vUI:SetWidth(Text, Settings["nameplates-width"] / 2 + 4)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    vUI:SetSize(Icon, Settings["nameplates-height"] + 12 + 2, Settings["nameplates-height"] + 12 + 2)
    vUI:SetPoint(Icon, "BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(IconBG, "TOPLEFT", Icon, -1, 1)
    vUI:SetPoint(IconBG, "BOTTOMRIGHT", Icon, 1, -1)
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
	vUI:SetPoint(TargetIndicator, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(TargetIndicator, "BOTTOMRIGHT", Health, 0, 0)
	TargetIndicator:Hide()
	
	TargetIndicator.Left = TargetIndicator:CreateTexture(nil, "ARTWORK")
	vUI:SetSize(TargetIndicator.Left, 16, 16)
	vUI:SetPoint(TargetIndicator.Left, "RIGHT", TargetIndicator, "LEFT", 2, 0)
	TargetIndicator.Left:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	TargetIndicator.Right = TargetIndicator:CreateTexture(nil, "ARTWORK")
	vUI:SetSize(TargetIndicator.Right, 16, 16)
	vUI:SetPoint(TargetIndicator.Right, "LEFT", TargetIndicator, "RIGHT", -3, 0)
	TargetIndicator.Right:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	if (Settings["nameplates-target-indicator-size"] == "SMALL") then
		TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
		TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
	elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
		TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
		TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
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
	vUI:SetPoint(self.HoverTop, "TOPLEFT", self.Hover, 10, -1)
	vUI:SetPoint(self.HoverTop, "TOPRIGHT", self.Hover, -10, -1)
	vUI:SetHeight(self.HoverTop, 12)
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
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	self.AuraParent = self
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["unitframes-player-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(Combat, 20, 20)
	vUI:SetPoint(Combat, "CENTER", Health)
	
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Leader:Hide()
	
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(RaidTarget, 16, 16)
	vUI:SetPoint(RaidTarget, "CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["unitframes-player-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["unitframes-player-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-player-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerRight, "RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerLeft, "LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	-- Position and size
    local mainBar = CreateFrame("StatusBar", nil, Power)
    mainBar:SetReverseFill(true)
    mainBar:SetPoint("TOP")
    mainBar:SetPoint("BOTTOM")
    mainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT")
    mainBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
    mainBar:SetStatusBarColor(0.8, 0.1, 0.1)
    vUI:SetWidth(mainBar, 200)
	
    -- Register with oUF
    self.PowerPrediction = {
        mainBar = mainBar,
    }
	
	-- Attributes
	Power.frequentUpdates = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-player-power-color"])
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Casting Bar", self)
    vUI:SetSize(Castbar, 250, 24)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(CastbarBG, "TOPLEFT", Castbar, 0, 0)
	vUI:SetPoint(CastbarBG, "BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(Background, "TOPLEFT", Castbar, -1, 1)
    vUI:SetPoint(Background, "BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Time, "RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Text, "LEFT", Castbar, 3, 0)
	vUI:SetSize(Text, 250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    vUI:SetSize(Icon, 24, 24)
    vUI:SetPoint(Icon, "TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(IconBG, "TOPLEFT", Icon, -1, 1)
    vUI:SetPoint(IconBG, "BOTTOMRIGHT", Icon, 1, -1)
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
	
	if (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
		local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self)
		vUI:SetPoint(ComboPoints, "BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		vUI:SetSize(ComboPoints, Settings["unitframes-player-width"], 10)
		ComboPoints:SetBackdrop(vUI.Backdrop)
		ComboPoints:SetBackdropColor(0, 0, 0)
		ComboPoints:SetBackdropBorderColor(0, 0, 0)
		
		local Max = (vUI.UserClass == "ROGUE" and 6 or 5)
		local Width = (Settings["unitframes-player-width"] / Max)
		
		for i = 1, Max do
			ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
			vUI:SetSize(ComboPoints[i], Width, 8)
			ComboPoints[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			ComboPoints[i]:SetStatusBarColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
			
			ComboPoints[i].bg = ComboPoints:CreateTexture(nil, "BORDER")
			ComboPoints[i].bg:SetAllPoints(ComboPoints[i])
			ComboPoints[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			ComboPoints[i].bg:SetVertexColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
			ComboPoints[i].bg:SetAlpha(0.3)
			
			if (i == 1) then
				vUI:SetPoint(ComboPoints[i], "LEFT", ComboPoints, 1, 0)
			else
				vUI:SetPoint(ComboPoints[i], "TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
				vUI:SetWidth(ComboPoints[i], Width - 2)
			end
		end
		
		self.ClassPower = ComboPoints
		self.AuraParent = ComboPoints
	elseif (vUI.UserClass == "WARLOCK") then
		local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self)
		vUI:SetPoint(SoulShards, "BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		vUI:SetSize(SoulShards, Settings["unitframes-player-width"], 10)
		SoulShards:SetBackdrop(vUI.Backdrop)
		SoulShards:SetBackdropColor(0, 0, 0)
		SoulShards:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (Settings["unitframes-player-width"] / 5)
		
		for i = 1, 5 do
			SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "SoulShard" .. i, SoulShards)
			vUI:SetSize(SoulShards[i], Width, 8)
			SoulShards[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			SoulShards[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-soul-shards"]))
			
			SoulShards[i].bg = SoulShards:CreateTexture(nil, "BORDER")
			SoulShards[i].bg:SetAllPoints(SoulShards[i])
			SoulShards[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			SoulShards[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-soul-shards"]))
			SoulShards[i].bg:SetAlpha(0.3)
			
			if (i == 1) then
				vUI:SetPoint(SoulShards[i], "LEFT", SoulShards, 1, 0)
			else
				vUI:SetPoint(SoulShards[i], "TOPLEFT", SoulShards[i-1], "TOPRIGHT", 1, 0)
				vUI:SetWidth(SoulShards[i], Width - 2)
			end
		end
		
		self.ClassPower = SoulShards
		self.AuraParent = SoulShards
	elseif (vUI.UserClass == "MONK") then
		local Chi = CreateFrame("Frame", self:GetName() .. "Chi", self)
		vUI:SetPoint(Chi, "BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		vUI:SetSize(Chi, Settings["unitframes-player-width"], 10)
		Chi:SetBackdrop(vUI.Backdrop)
		Chi:SetBackdropColor(0, 0, 0)
		Chi:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (Settings["unitframes-player-width"] / 5)
		
		for i = 1, 5 do
			Chi[i] = CreateFrame("StatusBar", self:GetName() .. "Chi" .. i, Chi)
			vUI:SetSize(Chi[i], Width, 8)
			Chi[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			Chi[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-chi"]))
			
			Chi[i].bg = Chi:CreateTexture(nil, "BORDER")
			Chi[i].bg:SetAllPoints(Chi[i])
			Chi[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			Chi[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-chi"]))
			Chi[i].bg:SetAlpha(0.3)
			
			if (i == 1) then
				vUI:SetPoint(Chi[i], "LEFT", Chi, 1, 0)
			else
				vUI:SetPoint(Chi[i], "TOPLEFT", Chi[i-1], "TOPRIGHT", 1, 0)
				vUI:SetWidth(Chi[i], Width - 2)
			end
		end
		
		self.ClassPower = Chi
		self.AuraParent = Chi
	elseif (vUI.UserClass == "DEATHKNIGHT") then
		local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self)
		vUI:SetPoint(Runes, "BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		vUI:SetSize(Runes, Settings["unitframes-player-width"], 10)
		Runes:SetBackdrop(vUI.Backdrop)
		Runes:SetBackdropColor(0, 0, 0)
		Runes:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (230 / 6)
		
		for i = 1, 6 do
			Runes[i] = CreateFrame("StatusBar", self:GetName() .. "Rune" .. i, Runes)
			vUI:SetSize(Runes[i], Width, 8)
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
				vUI:SetWidth(Runes[i], Width + 1)
			end
			
			if (i == 1) then
				vUI:SetPoint(Runes[i], "LEFT", Runes, 1, 0)
			else
				vUI:SetPoint(Runes[i], "TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
			end
		end
		
		self.Runes = Runes
		self.AuraParent = Runes
	elseif (vUI.UserClass == "PALADIN") then
		local HolyPower = CreateFrame("Frame", self:GetName() .. "HolyPower", self)
		vUI:SetPoint(HolyPower, "BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		vUI:SetSize(HolyPower, Settings["unitframes-player-width"], 10)
		HolyPower:SetBackdrop(vUI.Backdrop)
		HolyPower:SetBackdropColor(0, 0, 0)
		HolyPower:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (Settings["unitframes-player-width"] / 5)
		
		for i = 1, 5 do
			HolyPower[i] = CreateFrame("StatusBar", self:GetName() .. "HolyPower" .. i, HolyPower)
			vUI:SetSize(HolyPower[i], Width, 8)
			HolyPower[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			HolyPower[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-holy-power"]))
			
			HolyPower[i].bg = HolyPower:CreateTexture(nil, "BORDER")
			HolyPower[i].bg:SetAllPoints(HolyPower[i])
			HolyPower[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			HolyPower[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-holy-power"]))
			HolyPower[i].bg:SetAlpha(0.3)
			
			if (i == 1) then
				vUI:SetPoint(HolyPower[i], "LEFT", HolyPower, 1, 0)
			else
				vUI:SetPoint(HolyPower[i], "TOPLEFT", HolyPower[i-1], "TOPRIGHT", 1, 0)
				vUI:SetWidth(HolyPower[i], Width - 2)
			end
		end
		
		self.ClassPower = HolyPower
		self.AuraParent = HolyPower
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	vUI:SetSize(Buffs, Settings["unitframes-player-width"], 28)
	vUI:SetPoint(Buffs, "BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 40
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	--Buffs.SetPosition = BuffsSetPosition
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	vUI:SetSize(Debuffs, Settings["unitframes-player-width"], 28)
	vUI:SetPoint(Debuffs, "BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(Resurrect, 16, 16)
	vUI:SetPoint(Resurrect, "CENTER", Health, 0, 0)
	
	-- Tags
	self:Tag(HealthRight, "[HealthPercent]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[PowerValues]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.PowerLeft = PowerLeft
	self.PowerRight = PowerRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.RaidTargetIndicator = RaidTarget
	self.ResurrectIndicator = Resurrect
	self.LeaderIndicator = Leader
end

local StyleTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	self.colors.debuff = vUI.DebuffColors
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["unitframes-target-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	vUI:SetSize(RaidTarget, 16, 16)
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
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["unitframes-target-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-target-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerLeft, "LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerRight, "RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-target-power-color"])
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	vUI:SetSize(Buffs, Settings["unitframes-player-width"], 28)
	vUI:SetPoint(Buffs, "BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 16
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	vUI:SetSize(Debuffs, Settings["unitframes-player-width"], 28)
	vUI:SetWidth(Debuffs, Settings["unitframes-player-width"])
	--vUI:SetPoint(Debuffs, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	vUI:SetPoint(Debuffs, "BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Target Casting Bar", self)
    vUI:SetSize(Castbar, 250, 22)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(CastbarBG, "TOPLEFT", Castbar, 0, 0)
	vUI:SetPoint(CastbarBG, "BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(Background, "TOPLEFT", Castbar, -1, 1)
    vUI:SetPoint(Background, "BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Time, "RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Text, "LEFT", Castbar, 3, 0)
	vUI:SetSize(Text, 250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    vUI:SetSize(Icon, 22, 22)
    vUI:SetPoint(Icon, "TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(IconBG, "TOPLEFT", Icon, -1, 1)
    vUI:SetPoint(IconBG, "BOTTOMRIGHT", Icon, 1, -1)
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
	self.Castbar = Castbar
	self.RaidTargetIndicator = RaidTarget
end

local StyleTargetTarget = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["unitframes-targettarget-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
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
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["unitframes-targettarget-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-targettarget-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-targettarget-power-color"])
	
	self:Tag(HealthLeft, "[Name10]")
	self:Tag(HealthRight, "[HealthPercent]")
	
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
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["unitframes-pet-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
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
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["unitframes-pet-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["unitframes-pet-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-pet-power-color"])
	
	self:Tag(HealthLeft, "[Name10]")
	self:Tag(HealthRight, "[HealthPercent]")
	
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
	},
	
	["MONK"] = {
		{119611, "TOPLEFT", {0.32, 0.89, 0.74}},	 -- Renewing Mist
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},	 -- Life Cocoon
		{124682, "BOTTOMLEFT", {0.9, 0.8, 0.48}}, -- Enveloping Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}},  -- Zen Sphere
		{115175, "LEFT", {0.24, 0.87, 0.49}},  -- Soothing Mist
	},
	
	["PALADIN"] = {
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Light
		{156910, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Faith
		{200025, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Virtue
		{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},-- Blessing of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},	-- Blessing of Freedom
		--{1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true},	-- Blessing of Salvation
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},	-- Blessing of Sacrifice
		--{223306, "TOPLEFT", {0.81, 0.85, 0.1}},	        -- Bestow Faith
	},
	
	["PRIEST"] = {
		{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},  -- Prayer of Mending
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},     -- Renew
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
		{194384, "TOPRIGHT", {1, 0, 0}},          -- Atonement
		
		{33206, "BOTTOMLEFT", {237/255, 233/255, 221/255}},        -- Pain Suppression
		{121536, "BOTTOMRIGHT", {251/255, 193/255, 8/255}},        -- Angelic Feather
	},
	
	["SHAMAN"] = {
		{61295, "TOPLEFT", {0.7, 0.3, 0.7}},       -- Riptide
	},
}

local PostCreateAuraWatchIcon = function(auras, icon)
	vUI:SetPoint(icon.icon, "TOPLEFT", 1, -1)
	vUI:SetPoint(icon.icon, "BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.icon:SetDrawLayer("ARTWORK")
	
	icon.bg = icon:CreateTexture(nil, "BORDER")
	vUI:SetPoint(icon.bg, "TOPLEFT", icon, -1, 1)
	vUI:SetPoint(icon.bg, "BOTTOMRIGHT", icon, 1, -1)
	icon.bg:SetTexture(0, 0, 0)
	
	icon.overlay:SetTexture()
end

local StyleParty = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	self:SetBackdrop(vUI.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["party-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["party-health-reverse"])
	Health:SetOrientation(Settings["party-health-orientation"])
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
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
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthMiddle, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthMiddle, "CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	local HealthBottom = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthBottom, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthBottom, "BOTTOM", Health, 0, 1)
	HealthBottom:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	SetHealthAttributes(Health, Settings["party-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["party-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Power:SetReverseFill(Settings["party-power-reverse"])
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	SetPowerAttributes(Power, Settings["party-power-color"])
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	vUI:SetSize(Debuffs, 76, 19)
	vUI:SetPoint(Debuffs, "BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Debuffs.size = 19
	Debuffs.num = 4
	Debuffs.spacing = 2
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.CustomFilter = CustomFilter
	Debuffs.showType = true
	
	if BuffIDs[vUI.UserClass] then
		local Auras = CreateFrame("Frame", nil, Health)
		vUI:SetPoint(Auras, "TOPLEFT", Health, 2, -2)
		vUI:SetPoint(Auras, "BOTTOMRIGHT", Health, -2, 2)
		Auras:SetFrameLevel(10)
		Auras:SetFrameStrata("HIGH")
		Auras.presentAlpha = 1
		Auras.missingAlpha = 0
		Auras.strictMatching = true
		Auras.icons = {}
		Auras.PostCreateIcon = PostCreateAuraWatchIcon
		
		local Buffs = {}
		
		for key, value in pairs(BuffIDs[vUI.UserClass]) do
			tinsert(Buffs, value)
		end
		
		for key, spell in pairs(Buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon.strictMatching = true
			vUI:SetSize(Icon, 8, 8)
			Icon:SetPoint(spell[2], 0, 0)
			
			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(Assets:GetTexture("Blank"))
			
			local BG = Icon:CreateTexture(nil, "BORDER")
			vUI:SetPoint(BG, "TOPLEFT", Icon, -1, 1)
			vUI:SetPoint(BG, "BOTTOMRIGHT", Icon, 1, -1)
			BG:SetTexture(Assets:GetTexture("Blank"))
			BG:SetVertexColor(0, 0, 0)
			
			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end
			
			local Count = Icon:CreateFontString(nil, "OVERLAY")
			vUI:SetFontInfo(Count, Settings["ui-widget-font"], 10)
			vUI:SetPoint(Count, "CENTER", unpack(Offsets[spell[2]]))
			Icon.count = Count
			
			Auras.icons[spell[1]] = Icon
		end
		
		self.AuraWatch = Auras
	end
	
	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    vUI:SetPoint(Leader, "LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Leader:Hide()
	
	-- Assist
    local Assist = Health:CreateTexture(nil, "OVERLAY")
    Assist:SetSize(16, 16)
    vUI:SetPoint(Assist, "LEFT", Health, "TOPLEFT", 3, 0)
    Assist:SetTexture(Assets:GetTexture("Assist"))
    Assist:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Assist:Hide()
	
	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, 'OVERLAY')
    vUI:SetSize(ReadyCheck, 16, 16)
    vUI:SetPoint(ReadyCheck, "CENTER", Health, 0, 0)
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(RaidTarget, 16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(Resurrect, 16, 16)
	vUI:SetPoint(Resurrect, "CENTER", Health, 0, 0)
	
	-- Role
	local RoleIndicator = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(RoleIndicator, 16, 16)
	vUI:SetPoint(RoleIndicator, "TOP", self, 0, -2)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, Health)
	vUI:SetSize(Dispel, 20)
	vUI:SetPoint(Dispel, "CENTER", Health, 0, 0)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	vUI:SetPoint(Dispel.icon, "TOPLEFT", Dispel, 1, -1)
	vUI:SetPoint(Dispel.icon, "BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	vUI:SetPoint(Dispel.cd, "TOPLEFT", Dispel, 1, -1)
	vUI:SetPoint(Dispel.cd, "BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	vUI:SetFontInfo(Dispel.count, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Dispel.count, "BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	vUI:SetPoint(Dispel.bg, "TOPLEFT", Dispel, -1, 1)
	vUI:SetPoint(Dispel.bg, "BOTTOMRIGHT", Dispel, 1, -1)
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
	
	self:SetBackdrop(vUI.Backdrop)
	self:SetBackdropColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["party-pets-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthMiddle, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthMiddle, "CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	SetHealthAttributes(Health, Settings["party-pets-health-color"])
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	vUI:SetSize(RaidTarget, 16, 16)
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
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["raid-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	SetHealthAttributes(Health, Settings["raid-health-color"])
	
	local Power = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["raid-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-color"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-color"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	SetPowerAttributes(Power, Settings["raid-power-color"])
	
	-- Resurrect
	local ResurrectIndicator = Health:CreateTexture(nil, "OVERLAY")
	vUI:SetSize(ResurrectIndicator, 16, 16)
	vUI:SetPoint(ResurrectIndicator, "CENTER", Health, 0, 0)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, self)
	vUI:SetSize(Dispel, 20)
	vUI:SetPoint(Dispel, "CENTER", Health)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	vUI:SetPoint(Dispel.icon, "TOPLEFT", Dispel, 1, -1)
	vUI:SetPoint(Dispel.icon, "BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	vUI:SetPoint(Dispel.cd, "TOPLEFT", Dispel, 1, -1)
	vUI:SetPoint(Dispel.cd, "BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	vUI:SetFontInfo(Dispel.count, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Dispel.count, "BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	Dispel.count:SetShadowColor(0, 0, 0)
	Dispel.count:SetShadowOffset(1.25, -1.25)
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	vUI:SetPoint(Dispel.bg, "TOPLEFT", Dispel, -1, 1)
	vUI:SetPoint(Dispel.bg, "BOTTOMRIGHT", Dispel, 1, -1)
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
	
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	vUI:SetPoint(Health, "TOPLEFT", self, 1, -1)
	vUI:SetPoint(Health, "TOPRIGHT", self, -1, -1)
	vUI:SetHeight(Health, Settings["unitframes-boss-health-height"])
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
	vUI:SetPoint(HealthBG, "TOPLEFT", Health, 0, 0)
	vUI:SetPoint(HealthBG, "BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthLeft, "LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(HealthRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(HealthRight, "RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	vUI:SetSize(RaidTarget, 16, 16)
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
	vUI:SetPoint(Power, "BOTTOMLEFT", self, 1, 1)
	vUI:SetPoint(Power, "BOTTOMRIGHT", self, -1, 1)
	vUI:SetHeight(Power, Settings["unitframes-boss-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	vUI:SetPoint(PowerBG, "TOPLEFT", Power, 0, 0)
	vUI:SetPoint(PowerBG, "BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerLeft, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerLeft, "LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(PowerRight, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(PowerRight, "RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	SetPowerAttributes(Power, Settings["unitframes-boss-power-color"])
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	vUI:SetSize(Buffs, Settings["unitframes-player-width"], 28)
	vUI:SetPoint(Buffs, "BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 8
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	Buffs.showType = true
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	vUI:SetSize(Debuffs, Settings["unitframes-player-width"], 28)
	vUI:SetWidth(Debuffs, Settings["unitframes-player-width"])
	vUI:SetPoint(Debuffs, "BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 8
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", self:GetName() .. " Casting Bar", self)
    vUI:SetSize(Castbar, 250, 22)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(CastbarBG, "TOPLEFT", Castbar, 0, 0)
	vUI:SetPoint(CastbarBG, "BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(Background, "TOPLEFT", Castbar, -1, 1)
    vUI:SetPoint(Background, "BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Time, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Time, "RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	vUI:SetPoint(Text, "LEFT", Castbar, 3, 0)
	vUI:SetSize(Text, 250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    vUI:SetSize(Icon, 22, 22)
    vUI:SetPoint(Icon, "TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    vUI:SetPoint(IconBG, "TOPLEFT", Icon, -1, 1)
    vUI:SetPoint(IconBG, "BOTTOMRIGHT", Icon, 1, -1)
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
			vUI:SetSize(Player, Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
			vUI:SetPoint(Player, "RIGHT", UIParent, "CENTER", -68, -304)
			
			local Target = oUF:Spawn("target", "vUI Target")
			vUI:SetSize(Target, Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
			vUI:SetPoint(Target, "LEFT", UIParent, "CENTER", 68, -304)
			
			local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
			vUI:SetSize(TargetTarget, Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"] + Settings["unitframes-targettarget-power-height"] + 3)
			vUI:SetPoint(TargetTarget, "TOPRIGHT", Target, "BOTTOMRIGHT", 0, -2)
			
			local Pet = oUF:Spawn("pet", "vUI Pet")
			vUI:SetSize(Pet, Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"] + Settings["unitframes-pet-power-height"] + 3)
			vUI:SetPoint(Pet, "TOPLEFT", Player, "BOTTOMLEFT", 0, -2)
			
			vUI.UnitFrames["player"] = Player
			vUI.UnitFrames["target"] = Target
			vUI.UnitFrames["targettarget"] = TargetTarget
			vUI.UnitFrames["pet"] = Pet
			
			UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
			
			vUI:CreateMover(Player)
			vUI:CreateMover(Target)
			vUI:CreateMover(TargetTarget)
			vUI:CreateMover(Pet)
			
			vUI:SetPoint(Player.Castbar, "BOTTOM", UIParent, 0, 118)
			vUI:SetPoint(Target.Castbar, "BOTTOM", UIParent, 0, 146)
			
			vUI:CreateMover(Player.Castbar, 2)
			vUI:CreateMover(Target.Castbar, 2)
		end
		
		if Settings["unitframes-boss-enable"] then
			for i = 1, 5 do
				local Boss = oUF:Spawn("boss" .. i, "vUI Boss " .. i)
				vUI:SetSize(Boss, Settings["unitframes-boss-width"], Settings["unitframes-boss-health-height"] + Settings["unitframes-boss-power-height"] + 3)
				
				if (i == 1) then
					vUI:SetPoint(Boss, "LEFT", UIParent, 300, 200)
				else
					vUI:SetPoint(Boss, "TOP", vUI.UnitFrames["boss" .. (i-1)], "BOTTOM", 0, -2)
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
				"xoffset", 2,
				"yOffset", 0,
				"point", "LEFT",
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)
			
			self.PartyAnchor = CreateFrame("Frame", "vUI Party Anchor", UIParent)
			vUI:SetSize(self.PartyAnchor, (5 * Settings["party-width"] + (4 * 2)), (Settings["party-health-height"] + Settings["party-power-height"]) + 3)
			vUI:SetPoint(self.PartyAnchor, "BOTTOMLEFT", vUIChatFrameTop, "TOPLEFT", -3, 5)
			
			vUI:SetPoint(Party, "BOTTOMLEFT", self.PartyAnchor, 0, 0)
			
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
					"xoffset", 2,
					"yOffset", 0,
					"point", "LEFT",
					"oUF-initialConfigFunction", [[
						local Header = self:GetParent()
						
						self:SetWidth(Header:GetAttribute("initial-width"))
						self:SetHeight(Header:GetAttribute("initial-height"))
					]]
				)
				
				vUI:SetPoint(PartyPet, "BOTTOMLEFT", Party, "TOPLEFT", 0, 2)
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
				"xoffset", 2,
				"yOffset", -2,
				"groupFilter", "1,2,3,4,5,6,7,8",
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"maxColumns", ceil(40 / 10),
				"unitsPerColumn", 10,
				"columnSpacing", 2,
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)
			
			self.RaidAnchor = CreateFrame("Frame", "vUI Raid Anchor", UIParent)
			vUI:SetSize(self.RaidAnchor, (4 * (Settings["raid-health-height"] + Settings["raid-power-height"] + 3) + 4 * 2), ((Settings["raid-health-height"] + Settings["raid-power-height"]) * 10) + (2 * (10 - 1)))
			vUI:SetPoint(self.RaidAnchor, "TOPLEFT", UIParent, 10, -10)
			
			local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			Hider:Hide()
			
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer:SetParent(Hider)
				
				--CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameManager:SetParent(Hider)
			end
			
			vUI:SetPoint(Raid, "TOPLEFT", self.RaidAnchor, 0, 0)
			
			vUI.UnitFrames["raid"] = Raid
			
			vUI:CreateMover(self.RaidAnchor)
		end
		
		if Settings["nameplates-enable"] then
			oUF:SpawnNamePlates(nil, NamePlateCallback, NamePlateCVars)
		end
	else
		UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
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
		
		vUI:SetWidth(Frame, value)
		
		-- Auras
		vUI:SetWidth(Frame.Buffs, value)
		vUI:SetWidth(Frame.Debuffs, value)
		
		-- Combo points
		if Frame.ComboPoints then
			vUI:SetWidth(Frame.ComboPoints, value)
			
			local Width = (value / 5)
			
			for i = 1, 5 do
				vUI:SetWidth(Frame.ComboPoints[i], Width)
				
				if (i ~= 1) then
					vUI:SetWidth(Frame.ComboPoints[i], Width - 2)
				end
			end
		end
	end
end

local UpdatePlayerHealthHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		vUI:SetHeight(Frame.Health, value)
		vUI:SetHeight(Frame, value + Settings["unitframes-player-power-height"] + 3)
	end
end

local UpdatePlayerPowerHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		vUI:SetHeight(Frame.Power, value)
		vUI:SetHeight(Frame, Settings["unitframes-player-health-height"] + value + 3)
	end
end

local UpdateTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		vUI:SetWidth(Frame, value)
		
		-- Auras
		vUI:SetWidth(Frame.Buffs, value)
		vUI:SetWidth(Frame.Debuffs, value)
	end
end

local UpdateTargetHealthHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		vUI:SetHeight(Frame.Health, value)
		vUI:SetHeight(Frame, value + Settings["unitframes-target-power-height"] + 3)
	end
end

local UpdateTargetPowerHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		vUI:SetHeight(Frame.Power, value)
		vUI:SetHeight(Frame, Settings["unitframes-target-health-height"] + value + 3)
	end
end

local UpdateTargetTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		vUI:SetWidth(vUI.UnitFrames["targettarget"], value)
	end
end

local UpdateTargetTargetHealthHeight = function(value)
	if vUI.UnitFrames["targettarget"] then
		vUI:SetHeight(vUI.UnitFrames["targettarget"].Health, value)
		vUI:SetHeight(vUI.UnitFrames["targettarget"], value + Settings["unitframes-targettarget-power-height"] + 3)
	end
end

local UpdateTargetTargetPowerHeight = function(value)
	if vUI.UnitFrames["targettarget"] then
		local Frame = vUI.UnitFrames["targettarget"]
		
		vUI:SetHeight(Frame.Power, value)
		
		vUI:SetHeight(Frame, Settings["unitframes-targettarget-health-height"] + value + 3)
	end
end

local UpdatePetWidth = function(value)
	if vUI.UnitFrames["pet"] then
		vUI:SetWidth(vUI.UnitFrames["pet"], value)
	end
end

local UpdatePetHealthHeight = function(value)
	if vUI.UnitFrames["pet"] then
		vUI:SetHeight(vUI.UnitFrames["pet"].Health, value)
		vUI:SetHeight(vUI.UnitFrames["pet"], value + Settings["unitframes-pet-power-height"] + 3)
	end
end

local UpdatePetPowerHeight = function(value)
	if vUI.UnitFrames["pet"] then
		local Frame = vUI.UnitFrames["pet"]
		
		vUI:SetHeight(Frame.Power, value)
		
		vUI:SetHeight(Frame, Settings["unitframes-pet-health-height"] + value + 3)
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

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the unit frames module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Player"])
	Left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	Left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdatePlayerHealthHeight)
	Left:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar", UpdatePlayerPowerHeight)
	Left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePlayerHealthColor)
	Left:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePlayerPowerColor)
	Left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateShowPlayerBuffs)
	Left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed on the target"], UpdateOnlyPlayerDebuffs)
	Left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePlayerHealthFill)
	Left:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	Right:CreateHeader(Language["Target"])
	Right:CreateSlider("unitframes-target-width", Settings["unitframes-target-width"], 120, 320, 1, "Width", "Set the width of the target unit frame", UpdateTargetWidth)
	Right:CreateSlider("unitframes-target-health-height", Settings["unitframes-target-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the target health bar", UpdateTargetHealthHeight)
	Right:CreateSlider("unitframes-target-power-height", Settings["unitframes-target-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the target power bar", UpdateTargetPowerHeight)
	Right:CreateDropdown("unitframes-target-health-color", Settings["unitframes-target-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Color"], Language["Set the color of the health bar"], UpdateTargetHealthColor)
	Right:CreateDropdown("unitframes-target-power-color", Settings["unitframes-target-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateTargetPowerColor)
	Right:CreateSwitch("unitframes-target-health-reverse", Settings["unitframes-target-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateTargetHealthFill)
	Right:CreateSwitch("unitframes-target-power-reverse", Settings["unitframes-target-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateTargetPowerFill)
	
	Left:CreateHeader(Language["Target of Target"])
	Left:CreateSlider("unitframes-targettarget-width", Settings["unitframes-targettarget-width"], 60, 320, 1, "Width", "Set the width of the target's target unit frame", UpdateTargetTargetWidth)
	Left:CreateSlider("unitframes-targettarget-health-height", Settings["unitframes-targettarget-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the target of target health bar", UpdateTargetTargetHealthHeight)
	Left:CreateSlider("unitframes-targettarget-power-height", Settings["unitframes-targettarget-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the target of target power bar", UpdateTargetTargetPowerHeight)
	Left:CreateDropdown("unitframes-targettarget-health-color", Settings["unitframes-targettarget-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateTargetTargetHealthColor)
	Left:CreateDropdown("unitframes-targettarget-power-color", Settings["unitframes-targettarget-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateTargetTargetPowerColor)
	Left:CreateSwitch("unitframes-targettarget-health-reverse", Settings["unitframes-targettarget-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateTargetTargetHealthFill)
	Left:CreateSwitch("unitframes-targettarget-power-reverse", Settings["unitframes-targettarget-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateTargetTargetPowerFill)
	
	Right:CreateHeader(Language["Pet"])
	Right:CreateSlider("unitframes-pet-width", Settings["unitframes-pet-width"], 60, 320, 1, "Width", "Set the width of the pet unit frame", UpdatePetWidth)
	Right:CreateSlider("unitframes-pet-health-height", Settings["unitframes-pet-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the pet health bar", UpdatePetHealthHeight)
	Right:CreateSlider("unitframes-pet-power-height", Settings["unitframes-pet-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the pet power bar", UpdatePetPowerHeight)
	Right:CreateDropdown("unitframes-pet-health-color", Settings["unitframes-pet-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePetHealthColor)
	Right:CreateDropdown("unitframes-pet-power-color", Settings["unitframes-pet-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePetPowerColor)
	Right:CreateSwitch("unitframes-pet-health-reverse", Settings["unitframes-pet-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePetHealthFill)
	Right:CreateSwitch("unitframes-pet-power-reverse", Settings["unitframes-pet-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePetPowerFill)
end)

local UpdatePartyWidth = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
			if Unit then
				vUI:SetWidth(Unit, value)
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
				vUI:SetHeight(Unit, value + Settings["party-power-height"] + 3)
				vUI:SetHeight(Unit.Health, value)
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
				vUI:SetHeight(Unit, value + Settings["party-health-height"] + 3)
				vUI:SetHeight(Unit.Power, value)
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

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Party"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("party-enable", Settings["party-enable"], Language["Enable Party Module"], Language["Enable the party frames module"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("party-pets-enable", Settings["party-pets-enable"], Language["Enable Party Pet Frames"], Language["Enable the party pet frames module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Party Size"])
	Left:CreateSlider("party-width", Settings["party-width"], 40, 200, 1, Language["Width"], Language["Set the width of the party unit frame"], UpdatePartyWidth)
	Left:CreateSlider("party-health-height", Settings["party-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of party health bars"], UpdatePartyHealthHeight)
	Left:CreateSlider("party-power-height", Settings["party-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of party power bars"], UpdatePartyPowerHeight)
	
	Left:CreateHeader(Language["Health"])
	Left:CreateDropdown("party-health-color", Settings["party-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePartyHealthColor)
	Left:CreateDropdown("party-health-orientation", Settings["party-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"], UpdatePartyHealthOrientation)
	Left:CreateSwitch("party-health-reverse", Settings["party-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePartyHealthReverseFill)
	
	Left:CreateHeader(Language["Power"])
	Left:CreateDropdown("party-power-color", Settings["party-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePartyPowerColor)
	Left:CreateSwitch("party-power-reverse", Settings["party-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePartyPowerReverseFill)
	
	Right:CreateHeader(Language["Styling"])
	Right:CreateSwitch("party-show-debuffs", Settings["party-show-debuffs"], Language["Enable Debuffs"], Language["Display debuffs on party members"], UpdatePartyShowDebuffs)
	Right:CreateSwitch("party-show-role", Settings["party-show-role"], Language["Enable Role Icons"], Language["Display role icons on party members"], UpdatePartyShowRole)
	
	Right:CreateHeader(Language["Range Opacity"])
	Right:CreateSlider("party-in-range", Settings["party-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of party members within range of you"])
	Right:CreateSlider("party-out-of-range", Settings["party-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of party members out of your range"])
	
	Right:CreateHeader(Language["Party Pets Size"])
	Right:CreateSlider("party-pets-width", Settings["party-pets-width"], 40, 200, 1, Language["Width"], Language["Set the width of party pet unit frames"], ReloadUI, nil):RequiresReload(true)
	--Defaults["party-pets-health-height"] = 0 -- NYI
	--Defaults["party-pets-power-height"] = 22
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Raid"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("raid-enable", Settings["raid-enable"], Language["Enable Raid Module"], Language["Enable the raid frames module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Raid Size"])
	Left:CreateSlider("raid-width", Settings["raid-width"], 40, 200, 1, "Width", "Set the width of the raid frames", ReloadUI, nil):RequiresReload(true)
	Left:CreateSlider("raid-health-height", Settings["raid-health-height"], 10, 60, 1, "Health Height", "Set the height of raid health bars", ReloadUI, nil):RequiresReload(true)
	Left:CreateSlider("raid-power-height", Settings["raid-power-height"], 2, 30, 1, "Power Height", "Set the height of raid power bars", ReloadUI, nil):RequiresReload(true)
	
	Right:CreateHeader(Language["Range Opacity"])
	Right:CreateSlider("raid-in-range", Settings["raid-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of raid members within range of you"])
	Right:CreateSlider("raid-out-of-range", Settings["raid-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of raid members out of your range"])
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
	vUI:SetHeight(self.Castbar, value)
end

local UpdateNamePlatesCastBarsHeight = function(value)
	oUF:RunForAllNamePlates(NamePlateSetCastBarsHeight, value)
end

local NamePlateSetTargetIndicatorSize = function(self, value)
	if (value == "SMALL") then
		self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
		self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
	elseif (value == "LARGE") then
		self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
		self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
	end
end

local UpdateNamePlatesTargetIndicatorSize = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetIndicatorSize, value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Name Plates"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates"], Language["Enable the vUI name plates module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Font"])
	Left:CreateDropdown("nameplates-font", Settings["nameplates-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the name plates"], UpdateNamePlatesFont, "Font")
	Left:CreateSlider("nameplates-font-size", Settings["nameplates-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the name plates"], UpdateNamePlatesFont)
	Left:CreateDropdown("nameplates-font-flags", Settings["nameplates-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the name plates"], UpdateNamePlatesFont)
	
	Left:CreateHeader(Language["Health"])
	Left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates", UpdateNamePlatesWidth)
	Left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates", UpdateNamePlatesHeight)
	Left:CreateDropdown("nameplates-health-color", Settings["nameplates-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateNamePlatesHealthColor)
	Left:CreateSwitch("nameplates-health-smooth", Settings["nameplates-health-smooth"], Language["Enable Smooth Progress"], Language["Set the health bar to animate changes smoothly"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Debuffs"])
	Left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Debuffs"], Language["Display your debuffs above enemy name plates"], UpdateNamePlatesEnableDebuffs)
	Left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed"], UpdateNamePlatesShowPlayerDebuffs)
	
	Right:CreateHeader(Language["Information"])
	Right:CreateInput("nameplates-top-text", Settings["nameplates-top-text"], Language["Top Text"], "")
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	Right:CreateInput("nameplates-bottom-text", Settings["nameplates-bottom-text"], Language["Bottom Text"], "")
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	Right:CreateHeader(Language["Casting Bar"])
	Right:CreateSwitch("nameplates-enable-castbar", Settings["nameplates-enable-castbar"], Language["Enable Casting Bar"], Language["Enable the casting bar the name plates"], UpdateNamePlatesEnableCastBars)
	Right:CreateSlider("nameplates-castbar-height", Settings["nameplates-castbar-height"], 3, 28, 1, Language["Set Height"], Language["Set the height of name plate casting bars"], UpdateNamePlatesCastBarsHeight)
	
	Right:CreateHeader(Language["Target Indicator"])
	Right:CreateSwitch("nameplates-enable-target-indicator", Settings["nameplates-enable-target-indicator"], Language["Enable Target Indicator"], Language["Display an indication on the targetted unit name plate"], UpdateNamePlatesTargetHighlight)
	Right:CreateDropdown("nameplates-target-indicator-size", Settings["nameplates-target-indicator-size"], {["Small"] = "SMALL", ["Large"] = "LARGE"}, Language["Indicator Size"], Language["Select the size of the target indicator"], UpdateNamePlatesTargetIndicatorSize)
end)

--[[/run FakeGroup()
FakeGroup = function()
	local Header = _G["vUI Raid"]
	
	if Header then
		if (Header:GetAttribute("startingIndex") ~= -19) then
			Header:SetAttribute("startingIndex", -19)
		end
		
		for i = 1, select("#", Header:GetChildren()) do
			local Frame = select(i, Header:GetChildren())
			
			Frame.unit = "player"
			UnregisterUnitWatch(Frame)
			RegisterUnitWatch(Frame, true)
			Frame:Show()
		end
	end
end]]