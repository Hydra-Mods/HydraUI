local addon, ns = ...
local vUI, GUI, Language, Media, Settings = ns:get()

local unpack = unpack
local select = select
local format = string.format
local match = string.match
local floor = math.floor
local sub = string.sub
local find = string.find
local UnitName = UnitName
local UnitPower = UnitPower
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitReaction = UnitReaction
local IsResting = IsResting
local UnitAura = UnitAura
local GetTime = GetTime
local Huge = math.huge

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods
local Name, Duration, Expiration, Caster, SpellID, _

vUI.UnitFrames = {}

local Classes = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	["worldboss"] = Language["Boss"],
}

local ShortClasses = {
	["rare"] = Language[" R"],
	["elite"] = Language["+"],
	["rareelite"] = Language[" R+"],
	["worldboss"] = Language[" B"],
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

-- Tags
Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return Language["Dead"]
	elseif UnitIsGhost(unit) then
		return Language["Ghost"]
	elseif (not UnitIsConnected(unit)) then
		return Language["Offline"]
	end
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["Level"] = function(unit)
	local Level = UnitLevel(unit)
	
	if (Level == -1) then
		return "??"
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
	
	return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
end

Events["HealthPercent"] = "UNIT_HEALTH_FREQUENT PLAYER_ENTERING_WORLD"
Methods["HealthPercent"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return 0
	else
		return floor(Current / Max * 100 + 0.5)
	end
end

Events["HealthValues"] = "UNIT_HEALTH_FREQUENT UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["HealthValues"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFD64545" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
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
		return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.18, 0.8, 0.443))
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
		return Current .. " / " .. Max
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

Events["Reaction"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = vUI.ReactionColors[Reaction]
		
		if Color then
			return "|cff"..vUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["LevelColor"] = function(unit)
	return vUI:UnitDifficultyColor(unit)
end

local ComboPointsUpdateShapeshiftForm = function(self, form)
	local Parent = self:GetParent()
	
	Parent.Buffs:ClearAllPoints()
	
	if (form == 3) then
		Parent.Buffs:SetScaledPoint("BOTTOMLEFT", Parent.ComboPoints, "TOPLEFT", 0, 2)
	else
		Parent.Buffs:SetScaledPoint("BOTTOMLEFT", Parent, "TOPLEFT", 0, 2)
	end
end

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela
	
	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())
		
		--if (Now > 0 and Now ~= Huge) then
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
	button:SetBackdrop(vUI.Backdrop)
	button:SetBackdropColor(0, 0, 0)
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetScaledPoint("TOPLEFT", button, 1, -1)
	button.cd:SetScaledPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	
	button.icon:SetScaledPoint("TOPLEFT", 1, -1)
	button.icon:SetScaledPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetScaledPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	button.Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"], "OUTLINE")
	button.Time:SetScaledPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.overlay:SetParent(button.overlayFrame)
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
		Button:SetScaledPoint(Anchor, element, Anchor, Column * SizeX * GrowthX, Row * SizeY * GrowthY)
	end
	
	if (Rows > 0) then
		element:SetScaledHeight(element.size * Rows + ((Rows - 1) * element.spacing))
	else
		element:SetScaledHeight(element.size)
	end
end

local PostCastStart = function(self, unit, name)
	if self.notInterruptible then
		self:SetStatusBarColorHex(Settings["color-casting-uninterruptible"])
	else
		self:SetStatusBarColorHex(Settings["color-casting-start"])
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
			self.TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left"))
			self.TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right"))
		elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
			self.TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left Large"))
			self.TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right Large"))
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
	
	self:SetScaledSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self.Castbar:SetScaledHeight(Settings["nameplates-castbar-height"])
	
	self.TopLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.TopRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.BottomRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.BottomLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.Castbar.Time:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.Castbar.Text:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	
	self.Health.colorTapping = Settings["nameplates-color-by-tapped"]
	self.Health.colorClass = Settings["nameplates-color-by-class"]
	self.Health.colorReaction = Settings["nameplates-color-by-reaction"]
end

local StyleNamePlate = function(self, unit)
	self:SetScale(Settings["ui-scale"])
	self:SetScaledSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self:SetScaledPoint("CENTER", 0, 0)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(0, 0, 0)
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Health:EnableMouse(false)
	
	local HealthBG = Health:CreateTexture(nil, "BACKGROUND")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("LEFT", Health, "RIGHT", 5, 0)
	
	--[[local Top = Health:CreateFontString(nil, "OVERLAY")
	Top:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Top:SetScaledPoint("CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")]]
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	TopLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopLeft:SetScaledPoint("LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	TopRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopRight:SetScaledPoint("RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	BottomRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomRight:SetScaledPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	BottomLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomLeft:SetScaledPoint("LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	Health.Smooth = true
	Health.colorTapping = Settings["nameplates-color-by-tapped"]
	Health.colorDisconnected = true
	Health.colorClass = Settings["nameplates-color-by-class"]
	Health.colorReaction = Settings["nameplates-color-by-reaction"]
	Health.colorHealth = true
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(Settings["nameplates-width"], 26)
	Debuffs:SetScaledPoint("BOTTOM", Health, "TOP", 0, 18)
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
	Debuffs.disableMouse = true
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", nil, self)
    Castbar:SetScaledSize(Settings["nameplates-width"] - 2, Settings["nameplates-castbar-height"])
	Castbar:SetScaledPoint("TOP", Health, "BOTTOM", 0, -4)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Time:SetScaledPoint("RIGHT", Castbar, "BOTTOMRIGHT", -4, -3)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Text:SetScaledPoint("LEFT", Castbar, "BOTTOMLEFT", 4, -3)
	Text:SetScaledWidth(Settings["nameplates-width"] / 2 + 4)
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(Settings["nameplates-height"] + 12 + 2, Settings["nameplates-height"] + 12 + 2)
    Icon:SetScaledPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	Castbar.PostCastStart = PostCastStart
	Castbar.PostChannelStart = PostCastStart
	
	--[[ Elite icon
	local EliteIndicator = Health:CreateTexture(nil, "OVERLAY")
    EliteIndicator:SetSize(16, 16)
    EliteIndicator:SetPoint("RIGHT", Health, "LEFT", -1, 0)
    EliteIndicator:SetTexture(Media:GetTexture("Small Star"))
    EliteIndicator:Hide()]]
	
	-- Target
	local TargetIndicator = CreateFrame("Frame", nil, self)
	TargetIndicator:SetScaledPoint("TOPLEFT", Health, 0, 0)
	TargetIndicator:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	TargetIndicator:Hide()
	
	TargetIndicator.Left = TargetIndicator:CreateTexture(nil, "ARTWORK")
	TargetIndicator.Left:SetScaledSize(16, 16)
	TargetIndicator.Left:SetScaledPoint("RIGHT", TargetIndicator, "LEFT", 2, 0)
	TargetIndicator.Left:SetVertexColorHex(Settings["ui-widget-color"])
	
	TargetIndicator.Right = TargetIndicator:CreateTexture(nil, "ARTWORK")
	TargetIndicator.Right:SetScaledSize(16, 16)
	TargetIndicator.Right:SetScaledPoint("LEFT", TargetIndicator, "RIGHT", -3, 0)
	TargetIndicator.Right:SetVertexColorHex(Settings["ui-widget-color"])
	
	if (Settings["nameplates-target-indicator-size"] == "SMALL") then
		TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left"))
		TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right"))
	elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
		TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left Large"))
		TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right Large"))
	end
	
	self:Tag(TopLeft, Settings["nameplates-topleft-text"])
	self:Tag(TopRight, Settings["nameplates-topright-text"])
	self:Tag(BottomRight, Settings["nameplates-bottomright-text"])
	self:Tag(BottomLeft, Settings["nameplates-bottomleft-text"])
	
	self.Health = Health
	--self.Top = Top
	self.TopLeft = TopLeft
	self.TopRight = TopRight
	self.BottomRight = BottomRight
	self.BottomLeft = BottomLeft
	self.Health.bg = HealthBG
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.EliteIndicator = EliteIndicator
	self.TargetIndicator = TargetIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(Settings["unitframes-player-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetScaledSize(20, 20)
	Combat:SetScaledPoint("CENTER", Health)
	
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Media:GetTexture("Leader"))
    Leader:SetVertexColorHex("FFEB3B")
    Leader:Hide()
	
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetScaledPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(Settings["unitframes-player-power-height"])
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	PowerRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Casting Bar", self)
    Castbar:SetScaledSize(250, 22)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(22, 22)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
	local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
    IconBG:SetVertexColor(0, 0, 0)
	
    -- Add safezone
    local SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
	SafeZone:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	SafeZone:SetVertexColor(vUI:HexToRGB("C0392B"))
	
    -- Register it with oUF
    Castbar.bg = CastbarBG
    Castbar.Time = Time
    Castbar.Text = Text
    Castbar.Icon = Icon
    Castbar.SafeZone = SafeZone
    Castbar.showTradeSkills = true
    Castbar.timeToHold = 0.3
	
	if (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
		local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self)
		ComboPoints:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		ComboPoints:SetScaledSize(Settings["unitframes-player-width"], 10)
		ComboPoints:SetBackdrop(vUI.Backdrop)
		ComboPoints:SetBackdropColor(0, 0, 0)
		ComboPoints:SetBackdropBorderColor(0, 0, 0)
		ComboPoints.UpdateShapeshiftForm = ComboPointsUpdateShapeshiftForm
		
		local Width = (Settings["unitframes-player-width"] / 5)
		local Color
		
		for i = 1, 5 do
			Color = vUI.ComboPoints[i]
			
			ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
			ComboPoints[i]:SetScaledSize(Width, 8)
			ComboPoints[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			ComboPoints[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			ComboPoints[i]:SetAlpha(0.2)
			
			if (i == 1) then
				ComboPoints[i]:SetScaledPoint("LEFT", ComboPoints, 1, 0)
			else
				ComboPoints[i]:SetScaledPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
				ComboPoints[i]:SetScaledWidth(Width - 2)
			end
		end
		
		self.ComboPoints = ComboPoints
		self.AuraParent = ComboPoints
	elseif (vUI.UserClass == "WARLOCK") then
		local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self)
		SoulShards:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		SoulShards:SetScaledSize(Settings["unitframes-player-width"], 10)
		SoulShards:SetBackdrop(vUI.Backdrop)
		SoulShards:SetBackdropColor(0, 0, 0)
		SoulShards:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (Settings["unitframes-player-width"] / 5)
		
		for i = 1, 5 do
			SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "SoulShard" .. i, SoulShards)
			SoulShards[i]:SetScaledSize(Width - 1, 8)
			SoulShards[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			SoulShards[i]:SetStatusBarColorHex("D35832")
			SoulShards[i]:SetMinMaxValues(0, 1)
			SoulShards[i]:SetValue(0)
			
			SoulShards[i].bg = SoulShards[i]:CreateTexture(nil, "BORDER")
			SoulShards[i].bg:SetAllPoints(SoulShards[i])
			SoulShards[i].bg:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			SoulShards[i].bg:SetVertexColorHex("D35832")
			SoulShards[i].bg:SetAlpha(0.2)
			
			if (i == 1) then
				SoulShards[i]:SetScaledPoint("LEFT", SoulShards, 1, 0)
				SoulShards[i]:SetScaledWidth(Width - 2)
			else
				SoulShards[i]:SetScaledPoint("TOPLEFT", SoulShards[i-1], "TOPRIGHT", 1, 0)
			end
		end
		
		self.SoulShards = SoulShards
		self.AuraParent = SoulShards
	elseif (vUI.UserClass == "DEATHKNIGHT") then
		local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self)
		Runes:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
		Runes:SetScaledSize(Settings["unitframes-player-width"], 10)
		Runes:SetBackdrop(vUI.Backdrop)
		Runes:SetBackdropColor(0, 0, 0)
		Runes:SetBackdropBorderColor(0, 0, 0)
		
		local Width = (230 / 6)
		
		for i = 1, 6 do
			Runes[i] = CreateFrame("StatusBar", self:GetName() .. "Rune" .. i, Runes)
			Runes[i]:SetScaledSize(Width, 8)
			Runes[i]:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Runes[i]:SetStatusBarColorHex(Settings["color-runes"])
			Runes[i].Duration = 0
			
			Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
			Runes[i].bg:SetAllPoints(Runes[i])
			Runes[i].bg:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Runes[i].bg:SetVertexColorHex(Settings["color-runes"])
			Runes[i].bg:SetAlpha(0.2)
			
			Runes[i].Shine = Runes[i]:CreateTexture(nil, "ARTWORK")
			Runes[i].Shine:SetAllPoints(Runes[i])
			Runes[i].Shine:SetTexture(Media:GetTexture("pHishTex28"))
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
				Runes[i]:SetScaledWidth(Width + 1)
			end
			
			if (i == 1) then
				Runes[i]:SetScaledPoint("LEFT", Runes, 1, 0)
			else
				Runes[i]:SetScaledPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
			end
		end
		
		self.Runes = Runes
		self.AuraParent = Runes
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetScaledSize(Settings["unitframes-player-width"], 28)
	Buffs:SetScaledPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 40
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	--Buffs.SetPosition = BuffsSetPosition
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(Settings["unitframes-player-width"], 28)
	--Debuffs:SetScaledPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	Debuffs:SetScaledPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	
	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetScaledSize(16, 16)
	Resurrect:SetScaledPoint("CENTER", Health, 0, 0)
	
	-- Tags
	if Settings["unitframes-player-show-name"] then
		self:Tag(HealthLeft, "[Name15]")
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(PowerLeft, "[HealthValues]")
	self:Tag(PowerRight, "[PowerValues]")
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.PowerValue = PowerValue
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
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(Settings["unitframes-target-health-height"])
	Health:SetFrameLevel(5)
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus]|r [Name30]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[LevelColor][Level][Plus] [NameColor][Name30]")
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(Settings["unitframes-target-power-height"])
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
	PowerLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerLeft:SetScaledPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")
	
	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	PowerRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	PowerRight:SetScaledPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")
	
	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
	else
		Power.colorClass = true
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetScaledSize(Settings["unitframes-player-width"], 28)
	Buffs:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 16
	Buffs.initialAnchor = "TOPLEFT"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = PostCreateIcon
	Buffs.PostUpdateIcon = PostUpdateIcon
	
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetScaledSize(Settings["unitframes-player-width"], 28)
	Debuffs:SetScaledWidth(Settings["unitframes-player-width"])
	--Debuffs:SetScaledPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 31)
	Debuffs:SetScaledPoint("BOTTOM", Buffs, "TOP", 0, 2)
	Debuffs.size = 28
	Debuffs.spacing = 2
	Debuffs.num = 16
	Debuffs.initialAnchor = "TOPRIGHT"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = PostCreateIcon
	Debuffs.PostUpdateIcon = PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	
    -- Castbar
    local Castbar = CreateFrame("StatusBar", "vUI Target Casting Bar", self)
    Castbar:SetScaledSize(250, 22)
    Castbar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetScaledPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetScaledPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)
	
    -- Add a background
    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
    Background:SetScaledPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetScaledPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Media:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)
	
    -- Add a timer
    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	Time:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Time:SetScaledPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetScaledPoint("LEFT", Castbar, 3, 0)
	Text:SetScaledSize(250 * 0.7, Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	
    -- Add spell icon
    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Icon:SetScaledSize(22, 22)
    Icon:SetScaledPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
    Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	
    local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
    IconBG:SetScaledPoint("TOPLEFT", Icon, -1, 1)
    IconBG:SetScaledPoint("BOTTOMRIGHT", Icon, 1, -1)
    IconBG:SetTexture(Media:GetTexture("Blank"))
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
	self:Tag(HealthRight, "[HealthColor][perhp]")
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
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
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
		Health.colorClassPet = true
		
		self:Tag(HealthLeft, "[Name10]")
	else
		Health.colorHealth = true
		
		self:Tag(HealthLeft, "[NameColor][Name10]")
	end
	
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	self:Tag(HealthLeft, "[Reaction][Name10]")
	self:Tag(HealthRight, "[HealthColor][perhp]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(Settings["party-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetAllPoints(Health)
	AbsorbsBar:SetStatusBarTexture(vUI.GlobalTexture)
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthDead = Health:CreateTexture(nil, "OVERLAY")
	HealthDead:SetAllPoints(Health)
	HealthDead:SetTexture(Media:GetTexture("RenHorizonUp"))
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
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	HealthMiddle:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthMiddle:SetScaledPoint("CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Health.colorReaction = true
		Health.colorClass = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(Settings["party-power-height"])
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
	-- Debuffs
	if Settings["party-show-debuffs"] then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetScaledSize(19, 76)
		Debuffs:SetScaledPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0)
		Debuffs.size = 19
		Debuffs.num = 4
		Debuffs.spacing = -1
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = PostCreateIcon
		Debuffs.PostUpdateIcon = PostUpdateIcon
		Debuffs.CustomFilter = CustomFilter
		
		self.Debuffs = Debuffs
	end
	
	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetScaledPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Media:GetTexture("Leader"))
    Leader:SetVertexColorHex("FFEB3B")
    Leader:Hide()
	
	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, 'OVERLAY')
    ReadyCheck:SetScaledSize(16, 16)
    ReadyCheck:SetScaledPoint("CENTER", Health, 0, 0)
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetScaledSize(16, 16)
	Resurrect:SetScaledPoint("CENTER", Health, 0, 0)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, Health)
	Dispel:SetScaledSize(20)
	Dispel:SetScaledPoint("CENTER", Health, 0, 0)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetScaledPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetScaledPoint("BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetScaledPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetScaledPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	Dispel.count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Dispel.count:SetScaledPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetScaledPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetScaledPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Media:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)
	
	-- Tags
	--[[if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[LevelColor][Level]|r [Name10]")
	else
		self:Tag(HealthLeft, "[LevelColor][Level] [NameColor][Name10]")
	end]]
	
	self:Tag(HealthMiddle, "[NameColor][Name10]")
	
	--self:Tag(HealthRight, "[GroupStatus]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
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
	self.ReadyCheck = ReadyCheck
	self.Dispel = Dispel
	self.LeaderIndicator = Leader
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
	self.RaidTargetIndicator = RaidTarget
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(Settings["party-pets-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	HealthMiddle:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthMiddle:SetScaledPoint("CENTER", Health, 0, -1)
	HealthMiddle:SetJustifyH("CENTER")
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	
	if Settings["unitframes-class-color"] then
		Health.colorClass = true
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetScaledSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	-- Tags
	--[[if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[LevelColor][Level]|r [Name10]")
	else
		self:Tag(HealthLeft, "[LevelColor][Level] [Reaction][Name10]")
	end]]
	
	--self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(HealthMiddle, "[Name10]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
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
	Health:SetScaledPoint("TOPLEFT", self, 1, -1)
	Health:SetScaledPoint("TOPRIGHT", self, -1, -1)
	Health:SetScaledHeight(Settings["raid-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetScaledPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetScaledPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HealthLeft:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthLeft:SetScaledPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HealthRight:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	HealthRight:SetScaledPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	if Settings["unitframes-class-color"] then
		Health.colorClass = true
		Health.colorReaction = true
	else
		Health.colorHealth = true
	end
	
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetScaledPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetScaledPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetScaledHeight(Settings["raid-power-height"])
	Power:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-color"]))
	
	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetScaledPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetScaledPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Media:GetTexture(Settings["ui-widget-color"]))
	PowerBG:SetAlpha(0.2)
	
	-- Attributes
	Power.frequentUpdates = true
	
	if Settings["unitframes-class-color"] then
		Power.colorPower = true
		Power.colorReaction = true
	else
		Power.colorClass = true
	end
	
	-- Resurrect
	local ResurrectIndicator = Health:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetScaledSize(16, 16)
	ResurrectIndicator:SetScaledPoint("CENTER", Health, 0, 0)
	
	-- Dispels
	local Dispel = CreateFrame("Frame", nil, self)
	Dispel:SetScaledSize(20)
	Dispel:SetScaledPoint("CENTER", Health)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(vUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)
	
	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetScaledPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetScaledPoint("BOTTOMRIGHT", Dispel, -1, 1)
	
	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetScaledPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetScaledPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)
	
	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK", 7)
	Dispel.count:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Dispel.count:SetScaledPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	Dispel.count:SetShadowColor(0, 0, 0)
	Dispel.count:SetShadowOffset(1.25, -1.25)
	
	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetScaledPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetScaledPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Media:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)
	
	-- Tags
	if Settings["unitframes-class-color"] then
		self:Tag(HealthLeft, "[Name5]")
	else
		self:Tag(HealthLeft, "[NameColor][Name5]")
	end
	
	--self:Tag(HealthRight, "[HealthColor][perhp]")
	self:Tag(HealthRight, "[GroupStatus]")
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
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
	elseif (match(unit, "nameplate") and Settings["nameplates-enable"]) then
		StyleNamePlate(self, unit)
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

local Move = vUI:GetModule("Move")
local UF = vUI:NewModule("Unit Frames")

oUF:RegisterStyle("vUI", Style)

UF:RegisterEvent("PLAYER_LOGIN")
UF:RegisterEvent("PLAYER_ENTERING_WORLD")
UF:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
		if Settings["unitframes-enable"] then
			local Player = oUF:Spawn("player", "vUI Player")
			Player:SetScaledSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
			Player:SetScaledPoint("RIGHT", UIParent, "CENTER", -68, -304)
			
			local Target = oUF:Spawn("target", "vUI Target")
			Target:SetScaledSize(Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
			Target:SetScaledPoint("LEFT", UIParent, "CENTER", 68, -304)
			
			local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
			TargetTarget:SetScaledSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"])
			TargetTarget:SetScaledPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -3)
			
			local Pet = oUF:Spawn("pet", "vUI Pet")
			Pet:SetScaledSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"])
			Pet:SetScaledPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -3)
			
			vUI.UnitFrames["player"] = Player
			vUI.UnitFrames["target"] = Target
			vUI.UnitFrames["targettarget"] = TargetTarget
			vUI.UnitFrames["pet"] = Pet
			
			UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
			
			Move:Add(Player)
			Move:Add(Target)
			Move:Add(TargetTarget)
			Move:Add(Pet)
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
				"yOffset", -2,
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)
			
			Party:SetScaledPoint("LEFT", UIParent, 10, 0)
			
			if Settings["party-pets-enable"] then
				local PartyPet = oUF:SpawnHeader("vUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
					"initial-width", Settings["party-pets-width"],
					"initial-height", (Settings["party-pets-health-height"] + Settings["party-pets-power-height"] + 3),
					"showSolo", false,
					"showPlayer", true,
					"showParty", true,
					"showRaid", false,
					"xoffset", 3,
					"yOffset", -3,
					"oUF-initialConfigFunction", [[
						local Header = self:GetParent()
						
						self:SetWidth(Header:GetAttribute("initial-width"))
						self:SetHeight(Header:GetAttribute("initial-height"))
					]]
				)
				
				PartyPet:SetScaledPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, -2)
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
			self.RaidAnchor:SetScaledSize((4 * (Settings["raid-health-height"] + Settings["raid-power-height"] + 3) + 4 * 2), ((Settings["raid-health-height"] + Settings["raid-power-height"]) * 10) + (2 * (10 - 1)))
			self.RaidAnchor:SetScaledPoint("TOPLEFT", UIParent, 10, -10)
			
			local Hider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			Hider:Hide()
			
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer:SetParent(Hider)
				
				--CompactRaidFrameManager:UnregisterAllEvents()
				--CompactRaidFrameManager:SetParent(Hider)
			end
			
			Raid:SetScaledPoint("TOPLEFT", self.RaidAnchor, 0, 0)
			
			Move:Add(self.RaidAnchor)
		end
		
		if Settings["nameplates-enable"] then
			oUF:SpawnNamePlates(nil, NamePlateCallback, NamePlateCVars)
		end
	else
		UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
	end
end)

local TogglePlayerName = function(value)
	if value then
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "[Name15]")
		oUF_vUIPlayer:UpdateTags()
	else
		oUF_vUIPlayer:Tag(oUF_vUIPlayer.Name, "")
		oUF_vUIPlayer:UpdateTags()
	end
end

local UpdateOnlyPlayerDebuffs = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Debuffs.onlyShowPlayer = value
	end
end

local UpdatePlayerWidth = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame:SetScaledWidth(value)
		
		-- Auras
		Frame.Buffs:SetScaledWidth(value)
		Frame.Debuffs:SetScaledWidth(value)
		
		-- Combo points
		Frame.ComboPoints:SetScaledWidth(value)
	
		local Width = (value / 5)
		
		for i = 1, 5 do
			Frame.ComboPoints[i]:SetScaledWidth(Width)
			
			if (i ~= 1) then
				Frame.ComboPoints[i]:SetScaledWidth(Width - 2)
			end
		end
	end
end

local UpdatePlayerHealthHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Health:SetScaledHeight(value)
		
		Frame:SetScaledHeight(value + Settings["unitframes-player-power-height"] + 3)
	end
end

local UpdatePlayerPowerHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Power:SetScaledHeight(value)
		
		Frame:SetScaledHeight(Settings["unitframes-player-health-height"] + value + 3)
	end
end

local UpdateTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame:SetScaledWidth(value)
		
		-- Auras
		Frame.Buffs:SetScaledWidth(value)
		Frame.Debuffs:SetScaledWidth(value)
	end
end

local UpdateTargetHealthHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame.Health:SetScaledHeight(value)
		
		Frame:SetScaledHeight(value + Settings["unitframes-target-power-height"] + 3)
	end
end

local UpdateTargetPowerHeight = function(value)
	if vUI.UnitFrames["target"] then
		local Frame = vUI.UnitFrames["target"]
		
		Frame.Power:SetScaledHeight(value)
		
		Frame:SetScaledHeight(Settings["unitframes-target-health-height"] + value + 3)
	end
end

local UpdateTargetTargetWidth = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["targettarget"]:SetScaledWidth(value)
	end
end

local UpdateTargetTargetHealthHeight = function(value)
	if vUI.UnitFrames["targettarget"] then
		vUI.UnitFrames["targettarget"]:SetScaledHeight(value)
	end
end

local UpdatePetWidth = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"]:SetScaledWidth(value)
	end
end

local UpdatePetHealthHeight = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"]:SetScaledHeight(value)
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Unit Frames"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the unit frames module"], ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateSwitch("unitframes-class-color", Settings["unitframes-class-color"], Language["Use Class/Reaction Colors"], Language["Color unit frame health by class or reaction"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Player"])
	Left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	Left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 10, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdatePlayerHealthHeight)
	Left:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 10, 30, 1, "Power Bar Height", "Set the height of the player power bar", UpdatePlayerPowerHeight)
	Left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateShowPlayerBuffs)
	Left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will|nbe displayed on the target"], UpdateOnlyPlayerDebuffs)
	
	Right:CreateHeader(Language["Target"])
	Right:CreateSlider("unitframes-target-width", Settings["unitframes-target-width"], 120, 320, 1, "Width", "Set the width of the target unit frame", UpdateTargetWidth)
	Right:CreateSlider("unitframes-target-health-height", Settings["unitframes-target-health-height"], 10, 60, 1, "Health Bar Height", "Set the height of the target health bar", UpdateTargetHealthHeight)
	Right:CreateSlider("unitframes-target-power-height", Settings["unitframes-target-power-height"], 10, 30, 1, "Power Bar Height", "Set the height of the target power bar", UpdateTargetPowerHeight)
	
	Left:CreateHeader(Language["Target Target"])
	Left:CreateSlider("unitframes-targettarget-width", Settings["unitframes-targettarget-width"], 60, 320, 1, "Width", "Set the width of the target's target unit frame", UpdateTargetTargetWidth)
	Left:CreateSlider("unitframes-targettarget-health-height", Settings["unitframes-targettarget-health-height"], 10, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdateTargetTargetHealthHeight)
	
	Right:CreateHeader(Language["Pet"])
	Right:CreateSlider("unitframes-pet-width", Settings["unitframes-pet-width"], 60, 320, 1, "Width", "Set the width of the pet unit frame", UpdatePetWidth)
	Right:CreateSlider("unitframes-pet-health-height", Settings["unitframes-pet-health-height"], 10, 60, 1, "Health Bar Height", "Set the height of the pet health bar", UpdatePetHealthHeight)
end)

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Party"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("party-enable", Settings["party-enable"], Language["Enable Party Module"], Language["Enable the party frames module"], ReloadUI):RequiresReload(true)
	Left:CreateSwitch("party-pets-enable", Settings["party-pets-enable"], Language["Enable Party Pet Frames"], Language["Enable the party pet frames module"], ReloadUI):RequiresReload(true)
	
	Right:CreateHeader(Language["Debuffs"])
	Right:CreateSwitch("party-show-debuffs", Settings["party-show-debuffs"], Language["Enable Debuffs"], "Enable to display debuffs on party members", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Party Size"])
	Left:CreateSlider("party-width", Settings["party-width"], 40, 200, 1, "Width", "Set the width of the pet unit frame", ReloadUI, nil):RequiresReload(true)
	Left:CreateSlider("party-health-height", Settings["party-health-height"], 12, 60, 1, "Health Height", "Set the height of party health bars", ReloadUI, nil):RequiresReload(true)
	Left:CreateSlider("party-power-height", Settings["party-power-height"], 2, 30, 1, "Power Height", "Set the height of party power bars", ReloadUI, nil):RequiresReload(true)
	
	Right:CreateHeader(Language["Party Pets Size"])
	Right:CreateSlider("party-pets-width", Settings["party-pets-width"], 40, 200, 1, "Width", "Set the width of party pet unit frames", ReloadUI, nil):RequiresReload(true)
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
	self.Health.colorTapping = Settings["nameplates-color-by-tapped"]
	self.Health.colorClass = Settings["nameplates-color-by-class"]
	self.Health.colorReaction = Settings["nameplates-color-by-reaction"]
end

local UpdateNamePlateColors = function()
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
	self.TopLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.TopRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.BottomRight:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.BottomLeft:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.Castbar.Time:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	self.Castbar.Text:SetFontInfo(Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
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
	self.Castbar:SetScaledHeight(value)
end

local UpdateNamePlatesCastBarsHeight = function(value)
	oUF:RunForAllNamePlates(NamePlateSetCastBarsHeight, value)
end

local NamePlateSetTargetIndicatorSize = function(self, value)
	if (value == "SMALL") then
		self.TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left"))
		self.TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right"))
	elseif (value == "LARGE") then
		self.TargetIndicator.Left:SetTexture(Media:GetTexture("Arrow Left Large"))
		self.TargetIndicator.Right:SetTexture(Media:GetTexture("Arrow Right Large"))
	end
end

local UpdateNamePlatesTargetIndicatorSize = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetIndicatorSize, value)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Name Plates"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates"], "Enable the vUI name plates module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Name Plates Font"])
	Left:CreateDropdown("nameplates-font", Settings["nameplates-font"], Media:GetFontList(), Language["Font"], "Set the font of the name plates", UpdateNamePlatesFont, "Font")
	Left:CreateSlider("nameplates-font-size", Settings["nameplates-font-size"], 8, 18, 1, "Font Size", "Set the font size of the name plates", UpdateNamePlatesFont)
	Left:CreateDropdown("nameplates-font-flags", Settings["nameplates-font-flags"], Media:GetFlagsList(), Language["Font Flags"], "Set the font flags of the name plates", UpdateNamePlatesFont)
	
	Left:CreateHeader(Language["Sizes"])
	Left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates", UpdateNamePlatesWidth)
	Left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates", UpdateNamePlatesHeight)
	
	Left:CreateHeader(Language["Debuffs"])
	Left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Debuffs"], "Display your debuffs above enemy name plates", UpdateNamePlatesEnableDebuffs)
	Left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], "If enabled, only your own debuffs will be displayed", UpdateNamePlatesShowPlayerDebuffs)
	
	Right:CreateHeader(Language["Health Colors"])
	Right:CreateSwitch("nameplates-color-by-tapped", Settings["nameplates-color-by-tapped"], Language["Use Tapped Colors"], "Color name plate health if the unit is tapped by another player", UpdateNamePlateColors)
	Right:CreateSwitch("nameplates-color-by-class", Settings["nameplates-color-by-class"], Language["Use Class Colors"], "Color name plate health by class", UpdateNamePlateColors)
	Right:CreateSwitch("nameplates-color-by-reaction", Settings["nameplates-color-by-reaction"], Language["Use Reaction Colors"], "Color name plate health by unit reaction", UpdateNamePlateColors)
	
	Right:CreateHeader(Language["Information"])
	Right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	Right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	Right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	Right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	Right:CreateHeader(Language["Casting Bar"])
	Right:CreateSwitch("nameplates-enable-castbar", Settings["nameplates-enable-castbar"], Language["Enable Casting Bar"], "Enable the casting bar the name plates", UpdateNamePlatesEnableCastBars)
	Right:CreateSlider("nameplates-castbar-height", Settings["nameplates-castbar-height"], 3, 28, 1, "Set Height", "Set the height of name plate casting bars", UpdateNamePlatesCastBarsHeight)
	
	Right:CreateHeader(Language["Target Indicator"])
	Right:CreateSwitch("nameplates-enable-target-indicator", Settings["nameplates-enable-target-indicator"], Language["Enable Target Indicator"], "Display an indication on the targetted unit name plate", UpdateNamePlatesTargetHighlight)
	Right:CreateDropdown("nameplates-target-indicator-size", Settings["nameplates-target-indicator-size"], {["Small"] = "SMALL", ["Large"] = "LARGE"}, "Indicator Size", "Select the size of the target indicator", UpdateNamePlatesTargetIndicatorSize)
	
	--[[if (not Settings["nameplates-display-debuffs"]) then
		GUI:GetWidgetByWindow(Language["Name Plates"], "nameplates-only-player-debuffs"):Disable() -- Temporary
	end]]
end)

--[[ /run FakeGroup()
FakeGroup = function()
	local Header = _G["vUI Raid"]
	
	if Header then
		if (Header:GetAttribute("startingIndex") ~= -39) then
			Header:SetAttribute("startingIndex", -39)
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