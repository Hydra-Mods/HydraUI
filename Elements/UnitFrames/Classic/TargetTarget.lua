local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-targettarget-width"] = 110
Defaults["unitframes-targettarget-health-height"] = 26 
Defaults["unitframes-targettarget-health-reverse"] = false
Defaults["unitframes-targettarget-health-color"] = "CLASS"
Defaults["unitframes-targettarget-health-smooth"] = true
Defaults["unitframes-targettarget-enable-power"] = true
Defaults["unitframes-targettarget-power-height"] = 3
Defaults["unitframes-targettarget-power-reverse"] = false
Defaults["unitframes-targettarget-power-color"] = "POWER"
Defaults["unitframes-targettarget-power-smooth"] = true
Defaults["unitframes-targettarget-health-left"] = "[Name10]"
Defaults["unitframes-targettarget-health-right"] = "[HealthPercent]"
Defaults["unitframes-targettarget-debuffs"] = true
Defaults["unitframes-targettarget-debuff-size"] = 20
Defaults["unitframes-targettarget-debuff-pos"] = "BOTTOM"
Defaults["tot-enable"] = true

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["targettarget"] = function(self, unit)
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetWidth(Settings["unitframes-targettarget-width"])
	HealBar:SetHeight(Settings["unitframes-targettarget-health-height"])
	HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	HealBar:SetReverseFill(Settings["unitframes-targettarget-health-reverse"])
	
	if Settings["unitframes-targettarget-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
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
	
	-- Target Icon
	local RaidTargetIndicator = Health:CreateTexture(nil, 'OVERLAY')
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	
	UF:SetHealthAttributes(Health, Settings["unitframes-targettarget-health-color"])
	
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
	
	UF:SetPowerAttributes(Power, Settings["unitframes-targettarget-power-color"])
	
	if Settings["unitframes-targettarget-debuffs"] then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-debuff-size"])
		Debuffs.size = Settings["unitframes-targettarget-debuff-size"]
		Debuffs.spacing = 2
		Debuffs.num = 5
		Debuffs.tooltipAnchor = "ANCHOR_TOP"
		Debuffs.PostCreateIcon = UF.PostCreateIcon
		Debuffs.PostUpdateIcon = UF.PostUpdateIcon
		Debuffs.showType = true

		if (Settings["unitframes-targettarget-debuff-pos"] == "TOP") then
			Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 2)
			Debuffs.initialAnchor = "TOPRIGHT"
			Debuffs["growth-x"] = "LEFT"
			Debuffs["growth-y"] = "DOWN"
		else
			Debuffs:SetPoint("TOP", self, "BOTTOM", 0, -2)
			Debuffs.initialAnchor = "TOPRIGHT"
			Debuffs["growth-x"] = "LEFT"
			Debuffs["growth-y"] = "DOWN"
		end

		self.Debuffs = Debuffs
	end
	
	self:Tag(HealthLeft, Settings["unitframes-targettarget-health-left"])
	self:Tag(HealthRight, Settings["unitframes-targettarget-health-right"])
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.RaidTargetIndicator = RaidTargetIndicator
end

local UpdateTargetTargetWidth = function(value)
	if HydraUI.UnitFrames["target"] then
		HydraUI.UnitFrames["targettarget"]:SetWidth(value)
	end
end

local UpdateTargetTargetHealthHeight = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		HydraUI.UnitFrames["targettarget"].Health:SetHeight(value)
		HydraUI.UnitFrames["targettarget"]:SetHeight(value + Settings["unitframes-targettarget-power-height"] + 3)
	end
end

local UpdateTargetTargetPowerHeight = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		local Frame = HydraUI.UnitFrames["targettarget"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-targettarget-health-height"] + value + 3)
	end
end

local UpdateTargetTargetHealthColor = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		local Health = HydraUI.UnitFrames["targettarget"].Health
		
		UF:SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdateTargetTargetHealthFill = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		local Unit = HydraUI.UnitFrames["targettarget"]
		
		Unit.Health:SetReverseFill(value)
		Unit.HealBar:SetReverseFill(value)
		
		Unit.HealBar:ClearAllPoints()
		
		if value then
			Unit.HealBar:SetPoint("RIGHT", Unit.Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			Unit.HealBar:SetPoint("LEFT", Unit.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end
	end
end

local UpdateTargetTargetPowerColor = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		local Power = HydraUI.UnitFrames["targettarget"].Power
		
		UF:SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdateTargetTargetPowerFill = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		HydraUI.UnitFrames["targettarget"].Power:SetReverseFill(value)
	end
end

local UpdateEnableDebuffs = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		if value then
			HydraUI.UnitFrames["targettarget"]:EnableElement("Debuffs")
		else
			HydraUI.UnitFrames["targettarget"]:DisableElement("Debuffs")
		end
	end
end

local UpdateDebuffSize = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		HydraUI.UnitFrames["targettarget"].Debuffs.size = value
		HydraUI.UnitFrames["targettarget"].Debuffs:SetSize(Settings["unitframes-targettarget-width"], value)
		HydraUI.UnitFrames["targettarget"].Debuffs:ForceUpdate()
	end
end

local UpdateDebuffPosition = function(value)
	if HydraUI.UnitFrames["targettarget"] then
		local Unit = HydraUI.UnitFrames["targettarget"]

		Unit.Debuffs:ClearAllPoints()

		if (value == "TOP") then
			Unit.Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 2)
			Unit.Debuffs["growth-x"] = "LEFT"
			Unit.Debuffs["growth-y"] = "UP"
		else
			Unit.Debuffs:SetPoint("TOP", self, "BOTTOM", 0, -2)
			Unit.Debuffs["growth-x"] = "LEFT"
			Unit.Debuffs["growth-y"] = "DOWN"
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Target of Target"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("tot-enable", Settings["tot-enable"], Language["Enable Target Target"], Language["Enable the target of target unit frame"], ReloadUI):RequiresReload(true)
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
	
	right:CreateHeader(Language["Debuffs"])
	right:CreateSwitch("unitframes-targettarget-debuffs", Settings["unitframes-targettarget-debuffs"], Language["Enable Debuffs"], Language["Enable debuffs on the unit frame"], UpdateEnableDebuffs)
	right:CreateSlider("unitframes-targettarget-debuff-size", Settings["unitframes-targettarget-debuff-size"], 10, 30, 1, "Debuff Size", "Set the size of the debuff icons", UpdateDebuffSize)
	right:CreateDropdown("unitframes-targettarget-debuff-pos", Settings["unitframes-targettarget-debuff-pos"], {[Language["Bottom"]] = "BOTTOM", [Language["Top"]] = "TOP"}, Language["Set Position"], Language["Set the position of the debuffs"], UpdateDebuffPosition)
end)