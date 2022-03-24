local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-target-width"] = 238
Defaults["unitframes-target-health-height"] = 32
Defaults["unitframes-target-health-reverse"] = false
Defaults["unitframes-target-health-color"] = "CLASS"
Defaults["unitframes-target-health-smooth"] = true
Defaults["unitframes-target-power-height"] = 15
Defaults["unitframes-target-power-reverse"] = false
Defaults["unitframes-target-power-color"] = "POWER"
Defaults["unitframes-target-power-smooth"] = true
Defaults["unitframes-target-health-left"] = "[LevelColor][Level][Plus][ColorStop] [Name30]"
Defaults["unitframes-target-health-right"] = "[HealthPercent]"
Defaults["unitframes-target-power-left"] = "[HealthValues:Short]"
Defaults["unitframes-target-power-right"] = "[PowerValues:Short]"
Defaults["unitframes-target-cast-width"] = 250
Defaults["unitframes-target-cast-height"] = 22
Defaults["unitframes-target-enable-castbar"] = true
Defaults["target-enable-portrait"] = false
Defaults["target-portrait-style"] = "3D"
Defaults["target-enable"] = true

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["target"] = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.colors.debuff = HydraUI.DebuffColors
	
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
	AbsorbsBar:SetWidth(Settings["unitframes-target-width"])
	AbsorbsBar:SetHeight(Settings["unitframes-target-health-height"])
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetWidth(Settings["unitframes-target-width"])
	HealBar:SetHeight(Settings["unitframes-target-health-height"])
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	
	if Settings["unitframes-target-health-reverse"] then
		AbsorbsBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end
	
	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetPoint("TOPLEFT", Health, 0, 0)
	HealthBG:SetPoint("BOTTOMRIGHT", Health, 0, 0)
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG:SetAlpha(0.2)
	
	local HealthLeft = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthLeft:SetPoint("LEFT", Health, 3, 0)
	HealthLeft:SetJustifyH("LEFT")
	
	local HealthRight = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
	HealthRight:SetPoint("RIGHT", Health, -3, 0)
	HealthRight:SetJustifyH("RIGHT")
	
    -- Portrait
	local Portrait

	if (Settings["target-portrait-style"] == "2D") then
		Portrait = self:CreateTexture(nil, "OVERLAY")
		Portrait:SetTexCoord(0.12, 0.88, 0.12, 0.88)
	else
		Portrait = CreateFrame("PlayerModel", nil, self)
	end
	
    Portrait:SetSize(55, Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 1)
    Portrait:SetPoint("LEFT", self, "RIGHT", 3, 0)
	
	Portrait.BG = self:CreateTexture(nil, "BACKGROUND")
	Portrait.BG:SetPoint("TOPLEFT", Portrait, -1, 1)
	Portrait.BG:SetPoint("BOTTOMRIGHT", Portrait, 1, -1)
	Portrait.BG:SetTexture(Assets:GetTexture(Settings["Blank"]))
	Portrait.BG:SetVertexColor(0, 0, 0)
	
	if (not Settings["target-enable-portrait"]) then
		Portrait.BG:Hide()
	end
	
    self.Portrait = Portrait
	
	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	self.colors.health = {R, G, B}
	
	UF:SetHealthAttributes(Health, Settings["unitframes-target-health-color"])
	
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
	
	UF:SetPowerAttributes(Power, Settings["unitframes-target-power-color"])
	
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
	Buffs.PostCreateIcon = UF.PostCreateIcon
	Buffs.PostUpdateIcon = UF.PostUpdateIcon
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
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]
	Debuffs.showType = true
	
    -- Castbar
	if Settings["unitframes-target-enable-castbar"] then
		local Castbar = CreateFrame("StatusBar", "HydraUI Target Casting Bar", self)
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
		HydraUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Time:SetPoint("RIGHT", Castbar, -3, 0)
		Time:SetJustifyH("RIGHT")
		
		-- Add spell text
		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		HydraUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
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
		Castbar.PostCastStart = UF.PostCastStart
		Castbar.PostChannelStart = UF.PostCastStart
		Castbar.PostCastInterruptible = UF.PostCastStart
		
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

local UpdateTargetWidth = function(value)
	if HydraUI.UnitFrames["target"] then
		local Frame = HydraUI.UnitFrames["target"]
		
		Frame:SetWidth(value)
		
		-- Auras
		Frame.Buffs:SetWidth(value)
		Frame.Debuffs:SetWidth(value)
	end
end

local UpdateTargetHealthHeight = function(value)
	if HydraUI.UnitFrames["target"] then
		local Frame = HydraUI.UnitFrames["target"]
		
		Frame.Health:SetHeight(value)
		Frame:SetHeight(value + Settings["unitframes-target-power-height"] + 3)
	end
end

local UpdateTargetHealthFill = function(value)
	if HydraUI.UnitFrames["target"] then
		local Unit = HydraUI.UnitFrames["target"]
		
		Unit.Health:SetReverseFill(value)
		Unit.AbsorbsBar:SetReverseFill(value)
		Unit.HealBar:SetReverseFill(value)
		
		Unit.AbsorbsBar:ClearAllPoints()
		Unit.HealBar:ClearAllPoints()
		
		if value then
			Unit.AbsorbsBar:SetPoint("RIGHT", Unit.Health:GetStatusBarTexture(), "LEFT", 0, 0)
			Unit.HealBar:SetPoint("RIGHT", Unit.Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			Unit.AbsorbsBar:SetPoint("LEFT", Unit.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
			Unit.HealBar:SetPoint("LEFT", Unit.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end
	end
end

local UpdateTargetPowerHeight = function(value)
	if HydraUI.UnitFrames["target"] then
		local Frame = HydraUI.UnitFrames["target"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-target-health-height"] + value + 3)
	end
end

local UpdateTargetPowerFill = function(value)
	if HydraUI.UnitFrames["target"] then
		HydraUI.UnitFrames["target"].Power:SetReverseFill(value)
	end
end

local UpdateTargetHealthColor = function(value)
	if HydraUI.UnitFrames["target"] then
		local Health = HydraUI.UnitFrames["target"].Health
		
		UF:SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdateTargetPowerColor = function(value)
	if HydraUI.UnitFrames["target"] then
		local Power = HydraUI.UnitFrames["target"].Power
		
		UF:SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdateTargetCastBarSize = function()
	if _G["HydraUI Target Casting Bar"] then
		_G["HydraUI Target Casting Bar"]:SetSize(Settings["unitframes-target-cast-width"], Settings["unitframes-target-cast-height"])
		_G["HydraUI Target Casting Bar"].Icon:SetSize(Settings["unitframes-target-cast-height"], Settings["unitframes-target-cast-height"])
	end
end

local UpdateTargetEnablePortrait = function(value)
	if HydraUI.UnitFrames["target"] then
		if value then
			HydraUI.UnitFrames["target"]:EnableElement("Portrait")
			HydraUI.UnitFrames["target"].Portrait.BG:Show()
		else
			HydraUI.UnitFrames["target"]:DisableElement("Portrait")
			HydraUI.UnitFrames["target"].Portrait.BG:Hide()
		end
		
		HydraUI.UnitFrames["target"].Portrait:ForceUpdate()
	end
end

local UpdateShowTargetBuffs = function(value)
	if HydraUI.UnitFrames["target"] then
		if value then
			HydraUI.UnitFrames["target"]:EnableElement("Auras")
			HydraUI.UnitFrames["target"]:UpdateAllElements("ForceUpdate")
		else
			HydraUI.UnitFrames["target"]:DisableElement("Auras")
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Target"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("target-enable", Settings["target-enable"], Language["Enable Target"], Language["Enable the target unit frame"], ReloadUI):RequiresReload(true)
	left:CreateSlider("unitframes-target-width", Settings["unitframes-target-width"], 120, 320, 1, "Width", "Set the width of the target unit frame", UpdateTargetWidth)
	left:CreateSwitch("unitframes-show-target-buffs", Settings["unitframes-show-target-buffs"], Language["Show Target Buffs"], Language["Show yauras above the target unit frame"], UpdateShowTargetBuffs)
	left:CreateSwitch("unitframes-only-player-debuffs", Settings["unitframes-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed on the target"], UpdateOnlyPlayerDebuffs)
	left:CreateSwitch("target-enable-portrait", Settings["target-enable-portrait"], Language["Enable Portrait"], Language["Display the target unit portrait"], UpdateTargetEnablePortrait)
	left:CreateDropdown("target-portrait-style", Settings["target-portrait-style"], {[Language["2D"]] = "2D", [Language["3D"]] = "3D"}, Language["Set Portrait Style"], Language["Set the style of the portrait"], ReloadUI):RequiresReload(true)
	
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
	
	right:CreateHeader(Language["Cast Bar"])
	right:CreateSwitch("unitframes-target-enable-castbar", Settings["unitframes-target-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the target cast bar"], ReloadUI):RequiresReload(true)
	
	right:CreateSlider("unitframes-target-cast-width", Settings["unitframes-target-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the target cast bar"], UpdateTargetCastBarSize)
	right:CreateSlider("unitframes-target-cast-height", Settings["unitframes-target-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the target cast bar"], UpdateTargetCastBarSize)
end)