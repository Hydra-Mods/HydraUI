local addon, ns = ...
local HydraUI, GUI, Language, Assets, Settings, Defaults = ns:get()

Defaults["nameplates-enable"] = true
Defaults["nameplates-width"] = 138
Defaults["nameplates-height"] = 14
Defaults["nameplates-font"] = "Roboto"
Defaults["nameplates-font-size"] = 12
Defaults["nameplates-font-flags"] = ""
Defaults["nameplates-cc-health"] = false
Defaults["nameplates-top-text"] = ""
Defaults["nameplates-topleft-text"] = "[LevelColor][Level][Plus][ColorStop] [Name20]"
Defaults["nameplates-topright-text"] = ""
Defaults["nameplates-bottom-text"] = ""
Defaults["nameplates-bottomleft-text"] = ""
Defaults["nameplates-bottomright-text"] = "[HealthPercent]"
Defaults["nameplates-display-debuffs"] = true
Defaults["nameplates-only-player-debuffs"] = true
Defaults["nameplates-health-color"] = "CLASS"
Defaults["nameplates-health-smooth"] = true
Defaults["nameplates-enable-elite-indicator"] = true
Defaults["nameplates-enable-target-indicator"] = true
Defaults["nameplates-target-indicator-size"] = "SMALL"
Defaults["nameplates-enable-castbar"] = true
Defaults["nameplates-castbar-height"] = 12
Defaults["nameplates-castbar-enable-icon"] = true
Defaults["nameplates-selected-alpha"] = 100
Defaults["nameplates-unselected-alpha"] = 40
Defaults["nameplates-enable-auras"] = true
Defaults["nameplates-buffs-direction"] = "LTR"
Defaults["nameplates-debuffs-direction"] = "RTL"

local oUF = ns.oUF or oUF
local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["nameplate"] = function(self, unit)
	self:SetScale(Settings["ui-scale"])
	self:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	self:SetPoint("CENTER", 0, 0)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.colors.debuff = HydraUI.DebuffColors
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:EnableMouse(false)
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetWidth(Settings["nameplates-width"])
	AbsorbsBar:SetHeight(Settings["nameplates-height"])
	AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetWidth(Settings["nameplates-width"])
	HealBar:SetHeight(Settings["nameplates-height"])
	HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
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
	HydraUI:SetFontInfo(Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Top:SetPoint("CENTER", Health, "TOP", 0, 3)
	Top:SetJustifyH("CENTER")
	
	local TopLeft = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopLeft:SetPoint("LEFT", Health, "TOPLEFT", 4, 3)
	TopLeft:SetJustifyH("LEFT")
	
	local TopRight = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	TopRight:SetPoint("RIGHT", Health, "TOPRIGHT", -4, 3)
	TopRight:SetJustifyH("RIGHT")
	
	local Bottom = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Bottom:SetPoint("CENTER", Health, "BOTTOM", 0, -3)
	Bottom:SetJustifyH("CENTER")
	
	local BottomRight = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomRight:SetPoint("RIGHT", Health, "BOTTOMRIGHT", -4, -3)
	BottomRight:SetJustifyH("RIGHT")
	
	local BottomLeft = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	BottomLeft:SetPoint("LEFT", Health, "BOTTOMLEFT", 4, -3)
	BottomLeft:SetJustifyH("LEFT")
	
	--[[local InsideCenter = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(InsideCenter, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	InsideCenter:SetPoint("CENTER", Health, 0, 0)
	InsideCenter:SetJustifyH("CENTER")]]
	
	Health.Smooth = Settings["nameplates-health-smooth"]
	Health.colorTapping = true
	Health.colorDisconnected = true
	
	UF:SetHealthAttributes(Health, Settings["nameplates-health-color"])
	
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
	if Settings["nameplates-enable-auras"] then
		local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
		Buffs:SetSize(Settings["nameplates-width"], 26)
		Buffs:SetPoint("BOTTOM", self, "TOP", 0, 10)
		Buffs.size = 26
		Buffs.spacing = 2
		Buffs.num = 5
		Buffs.PostCreateIcon = UF.PostCreateIcon
		Buffs.PostUpdateIcon = UF.PostUpdateIcon
		Buffs.showType = true
		
		if (Settings["nameplates-buffs-direction"] == "LTR") then
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-x"] = "RIGHT"
			Buffs["growth-y"] = "UP"
		else
			Buffs.initialAnchor = "TOPRIGHT"
			Buffs["growth-x"] = "LEFT"
			Buffs["growth-y"] = "UP"
		end
		
		self.Buffs = Buffs
	end
	
	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["nameplates-width"], 26)
	Debuffs.size = 26
	Debuffs.spacing = 2
	Debuffs.num = 5
	Debuffs.numRow = 4
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
	Debuffs.showType = true
	Debuffs.disableMouse = true
	
	if (Settings["nameplates-debuffs-direction"] == "LTR") then
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
	else
		Debuffs.initialAnchor = "TOPRIGHT"
		Debuffs["growth-x"] = "LEFT"
		Debuffs["growth-y"] = "UP"
	end
	
	if Settings["nameplates-enable-auras"] then
		Debuffs:SetPoint("BOTTOM", self.Buffs, "TOP", 0, 2)
	else
		Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 10)
	end
	
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
	HydraUI:SetFontInfo(Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	Time:SetPoint("RIGHT", Castbar, "BOTTOMRIGHT", -4, -3)
	Time:SetJustifyH("RIGHT")
	
    -- Add spell text
    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
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
	Castbar.PostCastStart = UF.PostCastStart
	Castbar.PostChannelStart = UF.PostCastStart
	Castbar.PostCastInterruptible = UF.PostCastStart
	
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
	TargetIndicator.Left:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	TargetIndicator.Right = TargetIndicator:CreateTexture(nil, "ARTWORK")
	TargetIndicator.Right:SetSize(16, 16)
	TargetIndicator.Right:SetPoint("LEFT", TargetIndicator, "RIGHT", -3, 0)
	TargetIndicator.Right:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
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
	self.Debuffs = Debuffs
	self.Castbar = Castbar
	--self.EliteIndicator = EliteIndicator
	self.TargetIndicator = TargetIndicator
	self.ThreatIndicator = Threat
	self.RaidTargetIndicator = RaidTargetIndicator
end

UF.NamePlateCVars = {
    nameplateGlobalScale = 1,
    NamePlateHorizontalScale = 1,
    NamePlateVerticalScale = 1,
    nameplateLargerScale = 1,
    nameplateMaxScale = 1,
    nameplateMinScale = 1,
    nameplateSelectedScale = 1,
    nameplateSelfScale = 1,
}

UF.NamePlateCallback = function(plate)
	if (not plate) then
		return
	end
	
	if Settings["nameplates-display-debuffs"] then
		plate:EnableElement("Auras")
	else
		plate:DisableElement("Auras")
	end
	
	if Settings["nameplates-enable-target-indicator"] then
		plate:EnableElement("TargetIndicator")
		
		if (Settings["nameplates-target-indicator-size"] == "SMALL") then
			plate.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
			plate.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
		elseif (Settings["nameplates-target-indicator-size"] == "LARGE") then
			plate.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
			plate.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
		elseif (Settings["nameplates-target-indicator-size"] == "HUGE") then
			plate.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Huge"))
			plate.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Huge"))
		end
	else
		plate:DisableElement("TargetIndicator")
	end
	
	if Settings["nameplates-enable-castbar"] then
		plate:EnableElement("Castbar")
	else
		plate:DisableElement("Castbar")
	end
	
	if plate.Buffs then
		if (Settings["nameplates-buffs-direction"] == "LTR") then
			plate.Buffs.initialAnchor = "TOPLEFT"
			plate.Buffs["growth-x"] = "RIGHT"
			plate.Buffs["growth-y"] = "UP"
		else
			plate.Buffs.initialAnchor = "TOPRIGHT"
			plate.Buffs["growth-x"] = "LEFT"
			plate.Buffs["growth-y"] = "UP"
		end
	end
	
	if plate.Debuffs then
		plate.Debuffs.onlyShowPlayer = Settings["nameplates-only-player-debuffs"]
		
		if (Settings["nameplates-debuffs-direction"] == "LTR") then
			plate.Debuffs.initialAnchor = "TOPLEFT"
			plate.Debuffs["growth-x"] = "RIGHT"
			plate.Debuffs["growth-y"] = "UP"
		else
			plate.Debuffs.initialAnchor = "TOPRIGHT"
			plate.Debuffs["growth-x"] = "LEFT"
			plate.Debuffs["growth-y"] = "UP"
		end
	end
	
	plate:SetSize(Settings["nameplates-width"], Settings["nameplates-height"])
	plate.Castbar:SetHeight(Settings["nameplates-castbar-height"])
	
	HydraUI:SetFontInfo(plate.Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.Castbar.Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(plate.Castbar.Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
end

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
	UF:SetHealthAttributes(self.Health, Settings["nameplates-health-color"])
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
	HydraUI:SetFontInfo(self.Top, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.TopLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.TopRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.Bottom, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.BottomRight, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.BottomLeft, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.Castbar.Time, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
	HydraUI:SetFontInfo(self.Castbar.Text, Settings["nameplates-font"], Settings["nameplates-font-size"], Settings["nameplates-font-flags"])
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
		self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left"))
		self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right"))
	elseif (value == "LARGE") then
		self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Large"))
		self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Large"))
	elseif (value == "HUGE") then
		self.TargetIndicator.Left:SetTexture(Assets:GetTexture("Arrow Left Huge"))
		self.TargetIndicator.Right:SetTexture(Assets:GetTexture("Arrow Right Huge"))
	end
end

local UpdateNamePlatesTargetIndicatorSize = function(value)
	oUF:RunForAllNamePlates(NamePlateSetTargetIndicatorSize, value)
end

local UpdateNamePlateSelectedAlpha = function(value)
	C_CVar.SetCVar("nameplateSelectedAlpha", value / 100)
end
	
local UpdateNamePlateUnselectedAlpha = function(value)
	C_CVar.SetCVar("nameplateMinAlpha", value / 100)
	C_CVar.SetCVar("nameplateMaxAlpha", value / 100)
end

local NamePlateSetBuffDirection = function(self, value)
	if (Settings["nameplates-buffs-direction"] == "LTR") then
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "UP"
	else
		self.Buffs.initialAnchor = "TOPRIGHT"
		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "UP"
	end
end

local UpdateNamePlatesBuffDirection = function(value)
	oUF:RunForAllNamePlates(NamePlateSetBuffDirection, value)
end

local NamePlateSetDebuffDirection = function(self, value)
	if (Settings["nameplates-debuffs-direction"] == "LTR") then
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
	else
		self.Debuffs.initialAnchor = "TOPRIGHT"
		self.Debuffs["growth-x"] = "LEFT"
		self.Debuffs["growth-y"] = "UP"
	end
end

local UpdateNamePlatesDebuffDirection = function(value)
	oUF:RunForAllNamePlates(NamePlateSetDebuffDirection, value)
end

GUI:AddWidgets(Language["General"], Language["Name Plates"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates"], Language["Enable the HydraUI name plates module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("nameplates-font", Settings["nameplates-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the name plates"], UpdateNamePlatesFont, "Font")
	left:CreateSlider("nameplates-font-size", Settings["nameplates-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the name plates"], UpdateNamePlatesFont)
	left:CreateDropdown("nameplates-font-flags", Settings["nameplates-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the name plates"], UpdateNamePlatesFont)
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates", UpdateNamePlatesWidth)
	left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates", UpdateNamePlatesHeight)
	left:CreateDropdown("nameplates-health-color", Settings["nameplates-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM", [Language["Blizzard"]] = "BLIZZARD", [Language["Threat"]] = "THREAT"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateNamePlatesHealthColor)
	left:CreateSwitch("nameplates-health-smooth", Settings["nameplates-health-smooth"], Language["Enable Smooth Progress"], Language["Set the health bar to animate changes smoothly"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Buffs"])
	left:CreateSwitch("nameplates-enable-auras", Settings["nameplates-enable-auras"], Language["Enable Buffs"], Language["Display buffs above nameplates"], ReloadUI):RequiresReload(true)
	left:CreateDropdown("nameplates-buffs-direction", Settings["nameplates-buffs-direction"], {[Language["Left to Right"]] = "LTR", [Language["Right to Left"]] = "RTL"}, Language["Buff Direction"], Language["Set which direction the buffs will grow towards"], UpdateNamePlatesBuffDirection)
	
	left:CreateHeader(Language["Debuffs"])
	left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Debuffs"], Language["Display your debuffs above enemy name plates"], UpdateNamePlatesEnableDebuffs)
	left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed"], UpdateNamePlatesShowPlayerDebuffs)
	left:CreateDropdown("nameplates-debuffs-direction", Settings["nameplates-debuffs-direction"], {[Language["Left to Right"]] = "LTR", [Language["Right to Left"]] = "RTL"}, Language["Debuff Direction"], Language["Set which direction the debuffs will grow towards"], UpdateNamePlatesDebuffDirection)
	
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
	
	right:CreateHeader(Language["Opacity"])
	right:CreateSlider("nameplates-selected-alpha", Settings["nameplates-selected-alpha"], 1, 100, 5, Language["Selected Opacity"], Language["Set the opacity of the selected name plate"], UpdateNamePlateSelectedAlpha)
	right:CreateSlider("nameplates-unselected-alpha", Settings["nameplates-unselected-alpha"], 0, 100, 5, Language["Unselected Opacity"], Language["Set the opacity of unselected name plates"], UpdateNamePlateUnselectedAlpha)
end)