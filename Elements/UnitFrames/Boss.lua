local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-boss-enable"] = true
Defaults["unitframes-boss-width"] = 240
Defaults["unitframes-boss-health-height"] = 28
Defaults["unitframes-boss-health-reverse"] = false
Defaults["unitframes-boss-health-color"] = "CLASS"
Defaults["unitframes-boss-health-smooth"] = true
Defaults["unitframes-boss-health-left"] = "[LevelColor][Level][Plus]|r [Name(30)]"
Defaults["unitframes-boss-health-right"] = "[HealthPercent]"
Defaults["unitframes-boss-power-height"] = 16
Defaults["unitframes-boss-power-reverse"] = false
Defaults["unitframes-boss-power-color"] = "POWER"
Defaults["unitframes-boss-power-smooth"] = true
Defaults["unitframes-boss-power-smooth"] = true
Defaults["unitframes-boss-power-left"] = "[HealthValues:Short]"
Defaults["unitframes-boss-power-right"] = "[PowerValues:Short]"
Defaults["unitframes-boss-buffs"] = true
Defaults["unitframes-boss-buff-size"] = 47
Defaults["unitframes-boss-debuff-size"] = 47

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["boss"] = function(self, unit)
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
	Health:SetMinMaxValues(0, 1)
	Health:SetValue(1)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))

	local HealBar = CreateFrame("StatusBar", nil, Health)
	HealBar:SetWidth(Settings["unitframes-boss-width"])
	HealBar:SetHeight(Settings["unitframes-boss-health-height"])
	HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["unitframes-boss-width"])
		AbsorbsBar:SetHeight(Settings["unitframes-boss-health-height"])
		AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		self.AbsorbsBar = AbsorbsBar
	end

	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetAllPoints(Health)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG.multiplier = 0.2

	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")

	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")

	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")

	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])

	-- Attributes
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}

	UF:SetHealthAttributes(Health, Settings["unitframes-boss-health-color"])

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
	HydraUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerLeft:SetPoint("LEFT", Power, 3, 0)
	PowerLeft:SetJustifyH("LEFT")

	local PowerRight = Power:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	PowerRight:SetPoint("RIGHT", Power, -3, 0)
	PowerRight:SetJustifyH("RIGHT")

	-- Attributes
	Power.frequentUpdates = true
	Power.colorReaction = true
	Power.Smooth = true

	UF:SetPowerAttributes(Power, Settings["unitframes-boss-power-color"])

	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], Settings["unitframes-boss-buff-size"])
	Buffs:SetPoint("RIGHT", self, "LEFT", -2, 0)
	Buffs.size = Settings["unitframes-boss-buff-size"]
	Buffs.spacing = 2
	Buffs.num = 3
	Buffs.initialAnchor = "TOPRIGHT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "LEFT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = UF.PostCreateIcon
	Buffs.PostUpdateIcon = UF.PostUpdateIcon

	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["unitframes-player-width"], Settings["unitframes-boss-debuff-size"])
	Debuffs:SetPoint("LEFT", self, "RIGHT", 2, 0)
	Debuffs.size = Settings["unitframes-boss-debuff-size"]
	Debuffs.spacing = 2
	Debuffs.num = 4
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]

    -- Castbar
    local Castbar = CreateFrame("StatusBar", self:GetName() .. " Casting Bar", self)
	Castbar:SetSize(Settings["unitframes-boss-width"] - 28, 22)
	Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -1, -3)
    Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))

	local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
	CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
	CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
    CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	CastbarBG:SetAlpha(0.2)

    local Background = Castbar:CreateTexture(nil, "BACKGROUND")
	Background:SetPoint("TOPLEFT", Castbar, -1, 1)
    Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
    Background:SetTexture(Assets:GetTexture("Blank"))
    Background:SetVertexColor(0, 0, 0)

    local Time = Castbar:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Time:SetPoint("RIGHT", Castbar, -3, 0)
	Time:SetJustifyH("RIGHT")

    local Text = Castbar:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	Text:SetPoint("LEFT", Castbar, 3, 0)
	Text:SetSize(250 * 0.7, Settings["unitframes-font-size"])
	Text:SetJustifyH("LEFT")

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
	Castbar.PostCastStart = UF.PostCastStart
	Castbar.PostCastStop = UF.PostCastStop
	Castbar.PostCastFail = UF.PostCastFail
	Castbar.PostCastInterruptible = UF.PostCastInterruptible

	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-boss-health-left"])
	self:Tag(HealthRight, Settings["unitframes-boss-health-right"])
	self:Tag(PowerLeft, Settings["unitframes-boss-power-left"])
	self:Tag(PowerRight, Settings["unitframes-boss-power-right"])

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

local UpdateWidth = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i]:SetWidth(value)
		end
	end
end

local UpdateHealthHeight = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i].Health:SetHeight(value)
			HydraUI.UnitFrames["boss"..i]:SetHeight(value + Settings["unitframes-boss-power-height"] + 3)
		end
	end
end

local UpdatePowerHeight = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i].Power:SetHeight(value)
			HydraUI.UnitFrames["boss"..i]:SetHeight(value + Settings["unitframes-boss-health-height"] + 3)
		end
	end
end

local UpdateHealthColor = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			UF:SetHealthAttributes(HydraUI.UnitFrames["boss"..i].Health, value)
			HydraUI.UnitFrames["boss"..i].Health:ForceUpdate()
		end
	end
end

local UpdateHealthFill = function(value)
	local Unit

	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			Unit = HydraUI.UnitFrames["boss"..i]

			Unit.Health:SetReverseFill(value)
			Unit.HealBar:SetReverseFill(value)
			Unit.HealBar:ClearAllPoints()

			if value then
				Unit.HealBar:SetPoint("RIGHT", Unit.Health:GetStatusBarTexture(), "LEFT", 0, 0)

				if Unit.AbsorbsBar then
					Unit.AbsorbsBar:SetReverseFill(value)
					Unit.AbsorbsBar:ClearAllPoints()
					Unit.AbsorbsBar:SetPoint("RIGHT", Unit.Health:GetStatusBarTexture(), "LEFT", 0, 0)
				end
			else
				Unit.HealBar:SetPoint("LEFT", Unit.Health:GetStatusBarTexture(), "RIGHT", 0, 0)

				if Unit.AbsorbsBar then
					Unit.AbsorbsBar:SetReverseFill(value)
					Unit.AbsorbsBar:ClearAllPoints()
					Unit.AbsorbsBar:SetPoint("LEFT", Unit.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
				end
			end
		end
	end
end

local UpdatePowerColor = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			UF:SetPowerAttributes(HydraUI.UnitFrames["boss"..i].Power, value)
			HydraUI.UnitFrames["boss"..i].Power:ForceUpdate()
		end
	end
end

local UpdatePowerFill = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i].Power:SetReverseFill(value)
		end
	end
end

local UpdateEnableBuffs = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			if value then
				HydraUI.UnitFrames["boss"..i]:EnableElement("Auras")
			else
				HydraUI.UnitFrames["boss"..i]:DisableElement("Auras")
			end
		end
	end
end

local UpdateBuffSize = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i].Buffs.size = value
			HydraUI.UnitFrames["boss"..i].Buffs:SetSize(Settings["unitframes-boss-width"], value)
			HydraUI.UnitFrames["boss"..i].Buffs:ForceUpdate()
		end
	end
end

local UpdateDebuffSize = function(value)
	for i = 1, 8 do
		if HydraUI.UnitFrames["boss"..i] then
			HydraUI.UnitFrames["boss"..i].Debuffs.size = value
			HydraUI.UnitFrames["boss"..i].Debuffs:SetSize(Settings["unitframes-boss-width"], value)
			HydraUI.UnitFrames["boss"..i].Debuffs:ForceUpdate()
		end
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Bosses"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("unitframes-boss-enable", Settings["unitframes-boss-enable"], Language["Enable Boss Frames"], Language["Enable the boss unit frames"], ReloadUI):RequiresReload(true)
	left:CreateSlider("unitframes-boss-width", Settings["unitframes-boss-width"], 60, 320, 1, "Width", "Set the width of the unit frame", UpdateWidth)

	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-boss-health-reverse", Settings["unitframes-boss-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateHealthFill)
	left:CreateSlider("unitframes-boss-health-height", Settings["unitframes-boss-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the health bar", UpdateHealthHeight)
	left:CreateDropdown("unitframes-boss-health-color", Settings["unitframes-boss-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateHealthColor)
	left:CreateInput("unitframes-boss-health-left", Settings["unitframes-boss-health-left"], Language["Left Health Text"], Language["Set the text on the left of the health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-boss-health-right", Settings["unitframes-boss-health-right"], Language["Right Health Text"], Language["Set the text on the right of the health bar"], ReloadUI):RequiresReload(true)

	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-boss-power-reverse", Settings["unitframes-boss-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePowerFill)
	right:CreateSlider("unitframes-boss-power-height", Settings["unitframes-boss-power-height"], 1, 30, 1, "Power Bar Height", "Set the height of the power bar", UpdatePowerHeight)
	right:CreateDropdown("unitframes-boss-power-color", Settings["unitframes-boss-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePowerColor)

	right:CreateHeader(Language["Buffs"])
	right:CreateSwitch("unitframes-boss-buffs", Settings["unitframes-boss-buffs"], Language["Enable buffs"], Language["Enable debuffs on the unit frame"], UpdateEnableBuffs)
	right:CreateSlider("unitframes-boss-buff-size", Settings["unitframes-boss-buff-size"], 10, 50, 1, "Buff Size", "Set the size of the debuff icons", UpdateBuffSize)

	right:CreateHeader(Language["Debuffs"])
	right:CreateSlider("unitframes-boss-debuff-size", Settings["unitframes-boss-debuff-size"], 10, 50, 1, "Debuff Size", "Set the size of the debuff icons", UpdateDebuffSize)
end)