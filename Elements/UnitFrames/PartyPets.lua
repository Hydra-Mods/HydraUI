local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["party-pets-enable"] = true
Defaults["party-pets-width"] = 78
Defaults["party-pets-health-height"] = 22
Defaults["party-pets-health-reverse"] = false
Defaults["party-pets-health-color"] = "CLASS"
Defaults["party-pets-health-orientation"] = "HORIZONTAL"
Defaults["party-pets-health-smooth"] = true
Defaults["party-pets-power-height"] = 0 -- NYI

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["partypet"] = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)

	-- Threat
	local Threat = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Threat:SetPoint("TOPLEFT", -1, 1)
	Threat:SetPoint("BOTTOMRIGHT", 1, -1)
	Threat:SetBackdrop(HydraUI.Outline)
	Threat.PostUpdate = UF.ThreatPostUpdate

	self.ThreatIndicator = Threat

	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["party-pets-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["party-pets-health-reverse"])
	Health:SetOrientation(Settings["party-pets-health-orientation"])

	local HealBar = CreateFrame("StatusBar", nil, Health)
	HealBar:SetWidth(Settings["party-width"])
	HealBar:SetHeight(Settings["party-pets-health-height"])
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)

	if Settings["party-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["party-width"])
		AbsorbsBar:SetHeight(Settings["party-health-height"])
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		if Settings["party-health-reverse"] then
			AbsorbsBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end

		self.AbsorbsBar = AbsorbsBar
	end

	local HealthBG = Health:CreateTexture(nil, "BORDER")
	HealthBG:SetAllPoints()
	HealthBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealthBG.multiplier = 0.2

	local HealthMiddle = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthMiddle, Settings["party-font"], Settings["party-font-size"], Settings["party-font-flags"])
	HealthMiddle:SetPoint("CENTER", Health, 0, 0)
	HealthMiddle:SetJustifyH("CENTER")

	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true

	UF:SetHealthAttributes(Health, Settings["party-pets-health-color"])

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
	self.HealthMiddle = HealthMiddle
	self.RaidTargetIndicator = RaidTarget
end

local UpdateHealthTexture = function(value)
	if HydraUI.UnitFrames["partypet"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["partypet"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["partypet"]:GetChildren())

			if Unit then
				Unit.Health:SetStatusBarTexture(Assets:GetTetxure(value))
				Unit.Health.bg:SetStatusBarTexture(Assets:GetTetxure(value))
				Unit.Health.HealBar:SetStatusBarTexture(Assets:GetTetxure(value))

				if Unit.AbsorbsBar then
					Unit.AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(value))
				end
			end
		end
	end
end

local UpdatePowerTexture = function(value)
	if HydraUI.UnitFrames["partypet"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["partypet"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["partypet"]:GetChildren())

			if Unit then
				Unit.Power:SetStatusBarTexture(Assets:GetTexture(value))
				Unit.Power.bg:SetTexture(Assets:GetTexture(value))
			end
		end
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Party Pets"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("party-pets-enable", Settings["party-pets-enable"], Language["Enable Party Pet Frames"], Language["Enable the party pet frames module"], ReloadUI):RequiresReload(true)

	right:CreateHeader(Language["Party Pets Size"])
	right:CreateSlider("party-pets-width", Settings["party-pets-width"], 40, 200, 1, Language["Width"], Language["Set the width of party pet unit frames"], ReloadUI, nil):RequiresReload(true)

	--[[Defaults["party-pets-enable"] = true
	Defaults["party-pets-width"] = 78
	Defaults["party-pets-health-height"] = 22
	Defaults["party-pets-health-reverse"] = false
	Defaults["party-pets-health-color"] = "CLASS"
	Defaults["party-pets-health-orientation"] = "HORIZONTAL"
	Defaults["party-pets-health-smooth"] = true
	Defaults["party-pets-power-height"] = 0 -- NYI]]
end)