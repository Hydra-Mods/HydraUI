local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

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
Defaults["unitframes-pet-health-left"] = "[HappinessColor][Name10]"
Defaults["unitframes-pet-health-right"] = "[HealthPercent]"
Defaults["unitframes-pet-buffs"] = true
Defaults["unitframes-pet-buff-size"] = 20
Defaults["unitframes-pet-buff-pos"] = "BOTTOM"
Defaults["unitframes-pet-debuffs"] = true
Defaults["unitframes-pet-debuff-size"] = 20
Defaults["unitframes-pet-debuff-pos"] = "BOTTOM"
Defaults["pet-enable"] = true

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["pet"] = function(self, unit)
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
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetWidth(Settings["unitframes-pet-width"])
	HealBar:SetHeight(Settings["unitframes-pet-health-height"])
	HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	HealBar:SetReverseFill(Settings["unitframes-pet-health-reverse"])
	
	if Settings["unitframes-pet-health-reverse"] then
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
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
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
	
	--[[ Defaults["unitframes-pet-buffs"] = true
		Defaults["unitframes-pet-buff-size"] = 20
		Defaults["unitframes-pet-buff-pos"] = "BOTTOM"]]
		
	if Settings["unitframes-pet-buffs"] then
		local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
		Buffs:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-buff-size"])
		Buffs.size = Settings["unitframes-pet-buff-size"]
		Buffs.spacing = 2
		Buffs.num = 5
		Buffs.tooltipAnchor = "ANCHOR_TOP"
		Buffs.PostCreateIcon = UF.PostCreateIcon
		Buffs.PostUpdateIcon = UF.PostUpdateIcon
		Buffs.showType = true
		
		if (Settings["unitframes-pet-buff-pos"] == "TOP") then
			Buffs:SetPoint("BOTTOM", self, "TOP", 0, 2)
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-x"] = "RIGHT"
			Buffs["growth-y"] = "UP"
		else
			Buffs:SetPoint("TOP", self, "BOTTOM", 0, -2)
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-x"] = "RIGHT"
			Buffs["growth-y"] = "DOWN"
		end
		
		self.Buffs = Buffs
	end
	
	if Settings["unitframes-pet-debuffs"] then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		Debuffs:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-debuff-size"])
		Debuffs.size = Settings["unitframes-pet-debuff-size"]
		Debuffs.spacing = 2
		Debuffs.num = 5
		Debuffs.tooltipAnchor = "ANCHOR_TOP"
		Debuffs.PostCreateIcon = UF.PostCreateIcon
		Debuffs.PostUpdateIcon = UF.PostUpdateIcon
		Debuffs.showType = true
		
		if (Settings["unitframes-pet-debuff-pos"] == "TOP") then
			if self.Buffs then
				if (Settings["unitframes-pet-buff-pos"] == "TOP") then
					Debuffs:SetPoint("BOTTOM", self.Buffs or self, "TOP", 0, 2)
				else
					Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 2)
				end
			else
				Debuffs:SetPoint("BOTTOM", self, "TOP", 0, 2)
			end
			
			Debuffs.initialAnchor = "TOPRIGHT"
			Debuffs["growth-x"] = "LEFT"
			Debuffs["growth-y"] = "UP"
		else
			if self.Buffs then
				if (Settings["unitframes-pet-buff-pos"] == "BOTTOM") then
					Debuffs:SetPoint("TOP", self.Buffs or self, "BOTTOM", 0, -2)
				else
					Debuffs:SetPoint("TOP", self, "BOTTOM", 0, -2)
				end
			else
				Debuffs:SetPoint("TOP", self, "BOTTOM", 0, -2)
			end
			
			Debuffs.initialAnchor = "TOPRIGHT"
			Debuffs["growth-x"] = "LEFT"
			Debuffs["growth-y"] = "DOWN"
		end
		
		self.Debuffs = Debuffs
	end
	
	self:Tag(HealthLeft, Settings["unitframes-pet-health-left"])
	self:Tag(HealthRight, Settings["unitframes-pet-health-right"])
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
	
	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthLeft = HealthLeft
	self.Power = Power
	self.Power.bg = PowerBG
end

local UpdatePetWidth = function(value)
	if HydraUI.UnitFrames["pet"] then
		HydraUI.UnitFrames["pet"]:SetWidth(value)
	end
end

local UpdatePetHealthHeight = function(value)
	if HydraUI.UnitFrames["pet"] then
		HydraUI.UnitFrames["pet"].Health:SetHeight(value)
		HydraUI.UnitFrames["pet"]:SetHeight(value + Settings["unitframes-pet-power-height"] + 3)
	end
end

local UpdatePetPowerHeight = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Frame = HydraUI.UnitFrames["pet"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-pet-health-height"] + value + 3)
	end
end

local UpdatePetHealthColor = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Health = HydraUI.UnitFrames["pet"].Health
		
		UF:SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdatePetHealthFill = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Unit = HydraUI.UnitFrames["pet"]
		
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

local UpdatePetPowerColor = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Power = HydraUI.UnitFrames["pet"].Power
		
		UF:SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdatePetPowerFill = function(value)
	if HydraUI.UnitFrames["pet"] then
		HydraUI.UnitFrames["pet"].Power:SetReverseFill(value)
	end
end

local UpdateEnableBuffs = function(value)
	if HydraUI.UnitFrames["pet"] then
		if value then
			HydraUI.UnitFrames["pet"]:EnableElement("Buffs")
		else
			HydraUI.UnitFrames["pet"]:DisableElement("Buffs")
		end
	end
end

local UpdateBuffSize = function(value)
	if HydraUI.UnitFrames["pet"] then
		HydraUI.UnitFrames["pet"].Buffs.size = value
		HydraUI.UnitFrames["pet"].Buffs:SetSize(Settings["unitframes-pet-width"], value)
		HydraUI.UnitFrames["pet"].Buffs:ForceUpdate()
	end
end

local UpdateBuffPosition = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Unit = HydraUI.UnitFrames["pet"]

		Unit.Buffs:ClearAllPoints()

		if (value == "TOP") then
			Unit.Buffs:SetPoint("BOTTOM", Unit, "TOP", 0, 2)
			Unit.Buffs["growth-x"] = "LEFT"
			Unit.Buffs["growth-y"] = "UP"
		else
			Unit.Buffs:SetPoint("TOP", Unit, "BOTTOM", 0, -2)
			Unit.Buffs["growth-x"] = "LEFT"
			Unit.Buffs["growth-y"] = "DOWN"
		end
	end
end

local UpdateEnableDebuffs = function(value)
	if HydraUI.UnitFrames["pet"] then
		if value then
			HydraUI.UnitFrames["pet"]:EnableElement("Debuffs")
		else
			HydraUI.UnitFrames["pet"]:DisableElement("Debuffs")
		end
	end
end

local UpdateDebuffSize = function(value)
	if HydraUI.UnitFrames["pet"] then
		HydraUI.UnitFrames["pet"].Debuffs.size = value
		HydraUI.UnitFrames["pet"].Debuffs:SetSize(Settings["unitframes-pet-width"], value)
		HydraUI.UnitFrames["pet"].Debuffs:ForceUpdate()
	end
end

local UpdateDebuffPosition = function(value)
	if HydraUI.UnitFrames["pet"] then
		local Unit = HydraUI.UnitFrames["pet"]

		Unit.Debuffs:ClearAllPoints()

		if (value == "TOP") then
			if Unit.Buffs then
				if (Settings["unitframes-pet-buff-pos"] == "TOP") then
					Unit.Debuffs:SetPoint("BOTTOM", Unit.Buffs or Unit, "TOP", 0, 2)
				else
					Unit.Debuffs:SetPoint("BOTTOM", Unit, "TOP", 0, 2)
				end
			else
				Unit.Debuffs:SetPoint("BOTTOM", Unit, "TOP", 0, 2)
			end
			
			Unit.Debuffs["growth-x"] = "LEFT"
			Unit.Debuffs["growth-y"] = "UP"
		else
			if Unit.Buffs then
				if (Settings["unitframes-pet-buff-pos"] == "BOTTOM") then
					Unit.Debuffs:SetPoint("TOP", Unit.Buffs or Unit, "BOTTOM", 0, -2)
				else
					Unit.Debuffs:SetPoint("TOP", Unit, "BOTTOM", 0, -2)
				end
			else
				Unit.Debuffs:SetPoint("TOP", Unit, "BOTTOM", 0, -2)
			end
			
			Unit.Debuffs:SetPoint("TOP", Unit.Buffs or Unit, "BOTTOM", 0, -2)
			Unit.Debuffs["growth-x"] = "LEFT"
			Unit.Debuffs["growth-y"] = "DOWN"
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Pet"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("pet-enable", Settings["pet-enable"], Language["Enable Pet"], Language["Enable the pet unit frame"], ReloadUI):RequiresReload(true)
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
	
	right:CreateHeader(Language["Buffs"])
	right:CreateSwitch("unitframes-pet-buffs", Settings["unitframes-pet-buffs"], Language["Enable buffs"], Language["Enable debuffs on the unit frame"], UpdateEnableBuffs)
	right:CreateSlider("unitframes-pet-buff-size", Settings["unitframes-pet-buff-size"], 10, 30, 1, "Buff Size", "Set the size of the debuff icons", UpdateBuffSize)
	right:CreateDropdown("unitframes-pet-buff-pos", Settings["unitframes-pet-buff-pos"], {[Language["Bottom"]] = "BOTTOM", [Language["Top"]] = "TOP"}, Language["Set Position"], Language["Set the position of the buffs"], UpdateBuffPosition)
	
	right:CreateHeader(Language["Debuffs"])
	right:CreateSwitch("unitframes-pet-debuffs", Settings["unitframes-pet-debuffs"], Language["Enable Debuffs"], Language["Enable debuffs on the unit frame"], UpdateEnableDebuffs)
	right:CreateSlider("unitframes-pet-debuff-size", Settings["unitframes-pet-debuff-size"], 10, 30, 1, "Debuff Size", "Set the size of the debuff icons", UpdateDebuffSize)
	right:CreateDropdown("unitframes-pet-debuff-pos", Settings["unitframes-pet-debuff-pos"], {[Language["Bottom"]] = "BOTTOM", [Language["Top"]] = "TOP"}, Language["Set Position"], Language["Set the position of the debuffs"], UpdateDebuffPosition)
end)