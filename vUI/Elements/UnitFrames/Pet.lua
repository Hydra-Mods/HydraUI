local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-pet-width"] = 110
Defaults["unitframes-pet-health-height"] = 26
Defaults["unitframes-pet-health-reverse"] = false
Defaults["unitframes-pet-health-color"] = "CLASS"
Defaults["unitframes-pet-health-smooth"] = true
Defaults["unitframes-pet-enable-power"] = true
Defaults["unitframes-pet-power-height"] = 3
Defaults["unitframes-pet-power-reverse"] = false
Defaults["unitframes-pet-power-color"] = "POWER"
Defaults["unitframes-pet-power-smooth"] = true
Defaults["unitframes-pet-health-left"] = "[Name10]"
Defaults["unitframes-pet-health-right"] = "[HealthPercent]"

local UF = vUI:GetModule("Unit Frames")

vUI.StyleFuncs["pet"] = function(self, unit)
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
	
	UF:SetHealthAttributes(Health, Settings["unitframes-pet-health-color"])
	
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
	
	UF:SetPowerAttributes(Power, Settings["unitframes-pet-power-color"])
	
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

local UpdatePetHealthColor = function(value)
	if vUI.UnitFrames["pet"] then
		local Health = vUI.UnitFrames["pet"].Health
		
		UF:SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdatePetHealthFill = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"].Health:SetReverseFill(value)
	end
end

local UpdatePetPowerColor = function(value)
	if vUI.UnitFrames["pet"] then
		local Power = vUI.UnitFrames["pet"].Power
		
		UF:SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdatePetPowerFill = function(value)
	if vUI.UnitFrames["pet"] then
		vUI.UnitFrames["pet"].Power:SetReverseFill(value)
	end
end

GUI:AddWidgets(Language["General"], Language["Pet"], Language["Unit Frames"], function(left, right)
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