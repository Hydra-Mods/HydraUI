local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-player-width"] = 240
Defaults["unitframes-player-health-height"] = 32
Defaults["unitframes-player-health-reverse"] = false
Defaults["unitframes-player-health-color"] = "CLASS"
Defaults["unitframes-player-health-smooth"] = true
Defaults["unitframes-player-power-height"] = 15
Defaults["unitframes-player-power-reverse"] = false
Defaults["unitframes-player-power-color"] = "POWER"
Defaults["unitframes-player-power-smooth"] = true
Defaults["unitframes-player-health-left"] = "[LevelColor][Level][Plus][ColorStop] [Name(30)] [Resting]"
Defaults["unitframes-player-health-right"] = "[HealthPercent]"
Defaults["unitframes-player-power-left"] = "[HealthValues:Short]"
Defaults["unitframes-player-power-right"] = "[PowerValues:Short]"
Defaults["unitframes-player-enable-power"] = true
Defaults["unitframes-player-enable-resource"] = true
Defaults["unitframes-player-cast-width"] = 250
Defaults["unitframes-player-cast-height"] = 24
Defaults["unitframes-player-cast-classcolor"] = true
Defaults["unitframes-player-enable-castbar"] = true
Defaults["unitframes-show-mana-timer"] = true
Defaults["unitframes-show-energy-timer"] = true
Defaults["player-enable-portrait"] = false
Defaults["player-portrait-style"] = "3D"
Defaults["player-overlay-alpha"] = 30
Defaults["player-enable-pvp"] = true
Defaults["player-resource-height"] = 8
Defaults["player-move-resource"] = false
Defaults["player-move-power"] = false
Defaults["player-enable"] = true
Defaults.PlayerBuffSize = 28
Defaults.PlayerBuffSpacing = 2
Defaults.PlayerDebuffSize = 28
Defaults.PlayerDebuffSpacing = 2
Defaults.PlayerHealthTexture = "HydraUI 4"
Defaults.PlayerPowerTexture = "HydraUI 4"
Defaults.PlayerResourceTexture = "HydraUI 4"

-- Can do textures for health/power/castbar/player resources. That's only 4 settings, and only player needs the resources setting

local UF = HydraUI:GetModule("Unit Frames")

HydraUI.StyleFuncs["player"] = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self.AuraParent = self

	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)

	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-player-health-height"])
	Health:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerHealthTexture))
	Health:SetReverseFill(Settings["unitframes-player-health-reverse"])

	local HealBar = CreateFrame("StatusBar", nil, Health)
	HealBar:SetWidth(Settings["unitframes-player-width"])
	HealBar:SetHeight(Settings["unitframes-player-health-height"])
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerHealthTexture))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)
	HealBar:SetReverseFill(Settings["unitframes-player-health-reverse"])

	if Settings["unitframes-player-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["unitframes-player-width"])
		AbsorbsBar:SetHeight(Settings["unitframes-player-health-height"])
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerHealthTexture))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetReverseFill(Settings["unitframes-player-health-reverse"])
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		if Settings["unitframes-player-health-reverse"] then
			AbsorbsBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end

		self.AbsorbsBar = AbsorbsBar
	end

	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetAllPoints(Health)
	HealthBG:SetTexture(Assets:GetTexture(Settings.PlayerHealthTexture))
	HealthBG.multiplier = 0.2

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

	if (Settings["player-portrait-style"] == "2D") then
		Portrait = self:CreateTexture(nil, "OVERLAY")
		Portrait:SetTexCoord(0.12, 0.88, 0.12, 0.88)
		Portrait:SetSize(55, Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 1)
    	Portrait:SetPoint("RIGHT", self, "LEFT", -3, 0)

		Portrait.BG = self:CreateTexture(nil, "BACKGROUND")
		Portrait.BG:SetPoint("TOPLEFT", Portrait, -1, 1)
		Portrait.BG:SetPoint("BOTTOMRIGHT", Portrait, 1, -1)
		Portrait.BG:SetTexture(Assets:GetTexture(Settings["Blank"]))
		Portrait.BG:SetVertexColor(0, 0, 0)
	elseif (Settings["player-portrait-style"] == "OVERLAY") then
		Portrait = CreateFrame("PlayerModel", nil, self)
		Portrait:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] )
		Portrait:SetPoint("CENTER", Health, 0, 0)
		Portrait:SetAlpha(Settings["player-overlay-alpha"] / 100)
	else
		Portrait = CreateFrame("PlayerModel", nil, self)
		Portrait:SetSize(55, Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 1)
    	Portrait:SetPoint("RIGHT", self, "LEFT", -3, 0)

		Portrait.BG = self:CreateTexture(nil, "BACKGROUND")
		Portrait.BG:SetPoint("TOPLEFT", Portrait, -1, 1)
		Portrait.BG:SetPoint("BOTTOMRIGHT", Portrait, 1, -1)
		Portrait.BG:SetTexture(Assets:GetTexture(Settings["Blank"]))
		Portrait.BG:SetVertexColor(0, 0, 0)
	end

	if (Portrait.BG and not Settings["player-enable-portrait"]) then
		Portrait.BG:Hide()
	end

    self.Portrait = Portrait

	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetSize(20, 20)
	Combat:SetPoint("CENTER", Health)

    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(HydraUI:HexToRGB("FFEB3B"))
    Leader:Hide()

    -- PVP indicator
	local PvPIndicator = Health:CreateTexture(nil, "ARTWORK", nil, 1)

	if HydraUI.IsMainline then
		PvPIndicator:SetSize(30, 30)
		PvPIndicator:SetPoint("RIGHT", Health, "LEFT", -4, -2)

		PvPIndicator.Badge = Health:CreateTexture(nil, "ARTWORK")
		PvPIndicator.Badge:SetSize(50, 52)
		PvPIndicator.Badge:SetPoint("CENTER", PvPIndicator, "CENTER")
	else
		PvPIndicator:SetSize(32, 32)
		PvPIndicator:SetPoint("CENTER", Health, 5, -6)
	end

	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")

	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])

	-- Attributes
	Health.Smooth = true
	self.colors.health = {R, G, B}
	UF:SetHealthAttributes(Health, Settings["unitframes-player-health-color"])

	if Settings["unitframes-player-enable-power"] then
		local Power = CreateFrame("StatusBar", nil, self)
		local PowerAnchor = CreateFrame("Frame", "HydraUI Player Power", HydraUI.UIParent)
		PowerAnchor:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-power-height"])
		PowerAnchor:SetPoint("CENTER", HydraUI.UIParent, 0, -133)
		HydraUI:CreateMover(PowerAnchor)

		if Settings["player-move-power"] then
			Power:SetPoint("BOTTOMLEFT", PowerAnchor, 1, 1)
			Power:SetPoint("BOTTOMRIGHT", PowerAnchor, -1, 1)
		else
			Power:SetPoint("BOTTOMLEFT", self, 1, 1)
			Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
		end

		Power:SetHeight(Settings["unitframes-player-power-height"])
		Power:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerPowerTexture))
		Power:SetReverseFill(Settings["unitframes-player-power-reverse"])

		local PowerBG = Power:CreateTexture(nil, "BORDER")
		PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
		PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
		PowerBG:SetTexture(Assets:GetTexture(Settings.PlayerPowerTexture))
		PowerBG:SetAlpha(0.2)

		local Backdrop = Power:CreateTexture(nil, "BACKGROUND")
		Backdrop:SetPoint("TOPLEFT", -1, 1)
		Backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
		Backdrop:SetTexture(Assets:GetTexture("Blank"))
		Backdrop:SetVertexColor(0, 0, 0)

		local PowerRight = Power:CreateFontString(nil, "OVERLAY")
		HydraUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerRight:SetPoint("RIGHT", Power, -3, 0)
		PowerRight:SetJustifyH("RIGHT")

		local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
		HydraUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerLeft:SetPoint("LEFT", Power, 3, 0)
		PowerLeft:SetJustifyH("LEFT")

		--[[ AdditionalPower
		local AdditionalPower = CreateFrame("StatusBar", nil, self)
		AdditionalPower:SetAllPoints(Power)
		AdditionalPower:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		AdditionalPower:SetReverseFill(Settings["unitframes-player-power-reverse"])]]

		-- Mana regen
		if (Settings["unitframes-show-mana-timer"] and not HydraUI.IsMainline) then
			local ManaTimer = CreateFrame("StatusBar", nil, Power)
			ManaTimer:SetAllPoints(Power)
			ManaTimer:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerPowerTexture))
			ManaTimer:SetStatusBarColor(0, 0, 0, 0)
			ManaTimer:Hide()

			ManaTimer.Spark = ManaTimer:CreateTexture(nil, "ARTWORK")
			ManaTimer.Spark:SetSize(3, Settings["unitframes-player-power-height"])
			ManaTimer.Spark:SetPoint("LEFT", ManaTimer:GetStatusBarTexture(), "RIGHT", -1, 0)
			ManaTimer.Spark:SetTexture(Assets:GetTexture("Blank"))
			ManaTimer.Spark:SetVertexColor(1, 1, 1, 0.2)

			ManaTimer.Spark2 = ManaTimer:CreateTexture(nil, "ARTWORK")
			ManaTimer.Spark2:SetSize(1, Settings["unitframes-player-power-height"])
			ManaTimer.Spark2:SetPoint("CENTER", ManaTimer.Spark, 0, 0)
			ManaTimer.Spark2:SetTexture(Assets:GetTexture("Blank"))
			ManaTimer.Spark2:SetVertexColor(1, 1, 1, 0.8)

			self.ManaTimer = ManaTimer
		end

		-- Energy ticks
		if (Settings["unitframes-show-energy-timer"] and (HydraUI.IsClassic or HydraUI.IsTBC)) then
			local EnergyTick = CreateFrame("StatusBar", nil, Power)
			EnergyTick:SetAllPoints(Power)
			EnergyTick:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerPowerTexture))
			EnergyTick:SetStatusBarColor(0, 0, 0, 0)
			EnergyTick:Hide()

			EnergyTick.Spark = EnergyTick:CreateTexture(nil, "ARTWORK")
			EnergyTick.Spark:SetSize(3, Settings["unitframes-player-power-height"])
			EnergyTick.Spark:SetPoint("LEFT", EnergyTick:GetStatusBarTexture(), "RIGHT", -1, 0)
			EnergyTick.Spark:SetTexture(Assets:GetTexture("Blank"))
			EnergyTick.Spark:SetVertexColor(1, 1, 1, 0.2)

			EnergyTick.Spark2 = EnergyTick:CreateTexture(nil, "ARTWORK")
			EnergyTick.Spark2:SetSize(1, Settings["unitframes-player-power-height"])
			EnergyTick.Spark2:SetPoint("CENTER", EnergyTick.Spark, 0, 0)
			EnergyTick.Spark2:SetTexture(Assets:GetTexture("Blank"))
			EnergyTick.Spark2:SetVertexColor(1, 1, 1, 0.8)

			self.EnergyTick = EnergyTick
		end

		-- Power prediction
		if HydraUI.IsMainline then
			local MainBar = CreateFrame("StatusBar", nil, Power)
			MainBar:SetReverseFill(true)
			MainBar:SetPoint("TOPLEFT")
			MainBar:SetPoint("BOTTOMRIGHT")
			MainBar:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerPowerTexture))
			MainBar:SetStatusBarColor(0.8, 0.1, 0.1)
			--MainBar:SetReverseFill(Settings["unitframes-player-power-reverse"])

			self.PowerPrediction = {
				mainBar = MainBar,
			}
		end

		-- Attributes
		Power.frequentUpdates = true
		Power.Smooth = true

		UF:SetPowerAttributes(Power, Settings["unitframes-player-power-color"])

		self:Tag(PowerLeft, Settings["unitframes-player-power-left"])
		self:Tag(PowerRight, Settings["unitframes-player-power-right"])

		self.Power = Power
		self.Power.bg = PowerBG
		self.PowerLeft = PowerLeft
		self.PowerRight = PowerRight
		self.PowerAnchor = PowerAnchor
		--self.AdditionalPower = AdditionalPower
	end

    -- Castbar
	if Settings["unitframes-player-enable-castbar"] then
		local Anchor = CreateFrame("Frame", "HydraUI Casting Bar", self)
		Anchor:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])

		local Castbar = CreateFrame("StatusBar", nil, self)
		Castbar:SetSize(Settings["unitframes-player-cast-width"] - Settings["unitframes-player-cast-height"] - 1, Settings["unitframes-player-cast-height"])
		Castbar:SetPoint("RIGHT", Anchor, 0, 0)
		Castbar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))

		local CastbarBG = Castbar:CreateTexture(nil, "ARTWORK")
		CastbarBG:SetPoint("TOPLEFT", Castbar, 0, 0)
		CastbarBG:SetPoint("BOTTOMRIGHT", Castbar, 0, 0)
		CastbarBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		CastbarBG:SetAlpha(0.2)

		local Background = Castbar:CreateTexture(nil, "BACKGROUND")
		Background:SetPoint("TOPLEFT", Castbar, -(Settings["unitframes-player-cast-height"] + 2), 1)
		Background:SetPoint("BOTTOMRIGHT", Castbar, 1, -1)
		Background:SetTexture(Assets:GetTexture("Blank"))
		Background:SetVertexColor(0, 0, 0)

		local Time = Castbar:CreateFontString(nil, "OVERLAY")
		HydraUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Time:SetPoint("RIGHT", Castbar, -5, 0)
		Time:SetJustifyH("RIGHT")

		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		HydraUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Text:SetPoint("LEFT", Castbar, 5, 0)
		Text:SetSize(Settings["unitframes-player-cast-width"] * 0.7, Settings["unitframes-font-size"])
		Text:SetJustifyH("LEFT")

		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
		Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -1, 0)
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		local SafeZone = Castbar:CreateTexture(nil, "ARTWORK")
		SafeZone:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		SafeZone:SetVertexColor(0.9, 0.15, 0.15, 0.75)

		Castbar.bg = CastbarBG
		Castbar.Time = Time
		Castbar.Text = Text
		Castbar.Icon = Icon
		Castbar.SafeZone = SafeZone
		Castbar.showTradeSkills = true
		Castbar.timeToHold = 0.7
		Castbar.ClassColor = Settings["unitframes-player-cast-classcolor"]
		Castbar.PostCastStart = UF.PostCastStart
		Castbar.PostCastStop = UF.PostCastStop
		Castbar.PostCastFail = UF.PostCastFail
		Castbar.PostCastInterruptible = UF.PostCastInterruptible

		self.Castbar = Castbar
		self.CastAnchor = Anchor
	end

	if Settings["unitframes-player-enable-resource"] then
		local ResourceAnchor = CreateFrame("Frame", "HydraUI Class Resource", HydraUI.UIParent)
		ResourceAnchor:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
		ResourceAnchor:SetPoint("CENTER", HydraUI.UIParent, 0, -120)
		HydraUI:CreateMover(ResourceAnchor)

		if (HydraUI.UserClass == "ROGUE" or HydraUI.UserClass == "DRUID") then
			local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self, "BackdropTemplate")
			ComboPoints:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			ComboPoints:SetBackdrop(HydraUI.Backdrop)
			ComboPoints:SetBackdropColor(0, 0, 0)
			ComboPoints:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				ComboPoints:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Max = HydraUI.UserClass == "DRUID" and 5 or (not HydraUI.IsMainline and 5 or 7)
			local Width = (Settings["unitframes-player-width"] / Max) - 1

			for i = 1, Max do
				ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
				ComboPoints[i]:SetSize(Width, Settings["player-resource-height"])
				ComboPoints[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				ComboPoints[i]:SetStatusBarColor(HydraUI.ComboPoints[i][1], HydraUI.ComboPoints[i][2], HydraUI.ComboPoints[i][3])
				ComboPoints[i]:SetWidth(i == 1 and Width - 1 or Width)

				ComboPoints[i].BG = ComboPoints:CreateTexture(nil, "BORDER")
				ComboPoints[i].BG:SetAllPoints(ComboPoints[i])
				ComboPoints[i].BG:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				ComboPoints[i].BG:SetVertexColor(HydraUI.ComboPoints[i][1], HydraUI.ComboPoints[i][2], HydraUI.ComboPoints[i][3])
				ComboPoints[i].BG:SetAlpha(0.3)

				if HydraUI.IsMainline then
					ComboPoints[i].Charged = ComboPoints[i]:CreateTexture(nil, "ARTWORK")
					ComboPoints[i].Charged:SetAllPoints()
					ComboPoints[i].Charged:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
					ComboPoints[i].Charged:SetVertexColor(HydraUI:HexToRGB(Settings["color-combo-charged"]))
					ComboPoints[i].Charged:Hide()
				end

				if (i == 1) then
					ComboPoints[i]:SetPoint("LEFT", ComboPoints, 1, 0)
				else
					ComboPoints[i]:SetPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.ComboPoints = ComboPoints
			self.AuraParent = ComboPoints
		elseif (HydraUI.UserClass == "WARLOCK" and HydraUI.IsMainline) then
			local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self, "BackdropTemplate")
			SoulShards:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			SoulShards:SetBackdrop(HydraUI.Backdrop)
			SoulShards:SetBackdropColor(0, 0, 0)
			SoulShards:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				SoulShards:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 5) - 1

			for i = 1, 5 do
				SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "SoulShard" .. i, SoulShards)
				SoulShards[i]:SetSize(Width, Settings["player-resource-height"])
				SoulShards[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				SoulShards[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-soul-shards"]))
				SoulShards[i]:SetWidth(i == 1 and Width - 1 or Width)

				SoulShards[i].bg = SoulShards:CreateTexture(nil, "BORDER")
				SoulShards[i].bg:SetAllPoints(SoulShards[i])
				SoulShards[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				SoulShards[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-soul-shards"]))
				SoulShards[i].bg:SetAlpha(0.3)

				if (i == 1) then
					SoulShards[i]:SetPoint("LEFT", SoulShards, 1, 0)
				else
					SoulShards[i]:SetPoint("TOPLEFT", SoulShards[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.ClassPower = SoulShards
			self.SoulShards = SoulShards
			self.AuraParent = SoulShards
		elseif (HydraUI.UserClass == "MAGE" and HydraUI.IsMainline) then
			local ArcaneCharges = CreateFrame("Frame", self:GetName() .. "ArcaneCharges", self, "BackdropTemplate")
			ArcaneCharges:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			ArcaneCharges:SetBackdrop(HydraUI.Backdrop)
			ArcaneCharges:SetBackdropColor(0, 0, 0)
			ArcaneCharges:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				ArcaneCharges:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				ArcaneCharges:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 4) - 1

			for i = 1, 4 do
				ArcaneCharges[i] = CreateFrame("StatusBar", self:GetName() .. "ArcaneCharge" .. i, ArcaneCharges)
				ArcaneCharges[i]:SetSize(Width, Settings["player-resource-height"])
				ArcaneCharges[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				ArcaneCharges[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-arcane-charges"]))
				ArcaneCharges[i]:SetWidth(i == 1 and Width - 1 or Width)

				ArcaneCharges[i].bg = ArcaneCharges:CreateTexture(nil, "BORDER")
				ArcaneCharges[i].bg:SetAllPoints(ArcaneCharges[i])
				ArcaneCharges[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				ArcaneCharges[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-arcane-charges"]))
				ArcaneCharges[i].bg:SetAlpha(0.3)

				if (i == 1) then
					ArcaneCharges[i]:SetPoint("LEFT", ArcaneCharges, 1, 0)
				else
					ArcaneCharges[i]:SetPoint("TOPLEFT", ArcaneCharges[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.ClassPower = ArcaneCharges
			self.ArcaneCharges = ArcaneCharges
			self.AuraParent = ArcaneCharges
		elseif (HydraUI.UserClass == "MONK") then
			local Chi = CreateFrame("Frame", self:GetName() .. "Chi", self, "BackdropTemplate")
			Chi:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			Chi:SetBackdrop(HydraUI.Backdrop)
			Chi:SetBackdropColor(0, 0, 0)
			Chi:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				Chi:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				Chi:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 6) - 1

			for i = 1, 6 do
				Chi[i] = CreateFrame("StatusBar", self:GetName() .. "Chi" .. i, Chi)
				Chi[i]:SetSize(Width, Settings["player-resource-height"])
				Chi[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Chi[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-chi"]))
				Chi[i]:SetWidth(i == 1 and Width - 1 or Width)

				Chi[i].bg = Chi:CreateTexture(nil, "BORDER")
				Chi[i].bg:SetAllPoints(Chi[i])
				Chi[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Chi[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-chi"]))
				Chi[i].bg:SetAlpha(0.3)

				if (i == 1) then
					Chi[i]:SetPoint("LEFT", Chi, 1, 0)
				else
					Chi[i]:SetPoint("TOPLEFT", Chi[i-1], "TOPRIGHT", 1, 0)
				end
			end

			local Stagger = CreateFrame("StatusBar", nil, self)
			Stagger:SetSize(Settings["unitframes-player-width"] - 2, Settings["player-resource-height"])
			Stagger:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
			Stagger:Hide()

			if Settings["player-move-resource"] then
				Stagger:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				Stagger:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 0)
			end

			Stagger.bg = Stagger:CreateTexture(nil, "ARTWORK")
			Stagger.bg:SetAllPoints()
			Stagger.bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
			Stagger.bg.multiplier = 0.3

			Stagger.Backdrop = Stagger:CreateTexture(nil, "BACKGROUND")
			Stagger.Backdrop:SetPoint("TOPLEFT", Stagger, -1, 1)
			Stagger.Backdrop:SetPoint("BOTTOMRIGHT", Stagger, 1, -1)
			Stagger.Backdrop:SetColorTexture(0, 0, 0)

			self.Stagger = Stagger
			self.ClassPower = Chi
			self.Chi = Chi
			self.AuraParent = Chi
		elseif (HydraUI.UserClass == "DEATHKNIGHT") then
			local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self, "BackdropTemplate")
			Runes:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			Runes:SetBackdrop(HydraUI.Backdrop)
			Runes:SetBackdropColor(0, 0, 0)
			Runes:SetBackdropBorderColor(0, 0, 0)
			Runes.sortOrder = "asc" -- desc

			if Settings["player-move-resource"] then
				Runes:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 6) - 1

			for i = 1, 6 do
				Runes[i] = CreateFrame("StatusBar", self:GetName() .. "Rune" .. i, Runes)
				Runes[i]:SetSize(Width, Settings["player-resource-height"])
				Runes[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Runes[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-runes"]))
				Runes[i]:SetWidth(i == 1 and Width - 1 or Width)
				Runes[i].Duration = 0

				Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
				Runes[i].bg:SetAllPoints(Runes[i])
				Runes[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Runes[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-runes"]))
				Runes[i].bg:SetAlpha(0.2)

				Runes[i].Shine = Runes[i]:CreateTexture(nil, "ARTWORK")
				Runes[i].Shine:SetAllPoints(Runes[i])
				Runes[i].Shine:SetTexture(Assets:GetTexture("pHishTex28"))
				Runes[i].Shine:SetVertexColor(0.8, 0.8, 0.8)
				Runes[i].Shine:SetAlpha(0)
				Runes[i].Shine:SetDrawLayer("ARTWORK", 7)

				Runes[i].ReadyAnim = LibMotion:CreateAnimationGroup()

				Runes[i].ReadyAnim.In = LibMotion:CreateAnimation(Runes[i].Shine, "Fade")
				Runes[i].ReadyAnim.In:SetGroup(Runes[i].ReadyAnim)
				Runes[i].ReadyAnim.In:SetOrder(1)
				Runes[i].ReadyAnim.In:SetEasing("in")
				Runes[i].ReadyAnim.In:SetDuration(0.2)
				Runes[i].ReadyAnim.In:SetChange(0.5)

				Runes[i].ReadyAnim.Out = LibMotion:CreateAnimation(Runes[i].Shine, "Fade")
				Runes[i].ReadyAnim.Out:SetGroup(Runes[i].ReadyAnim)
				Runes[i].ReadyAnim.Out:SetOrder(2)
				Runes[i].ReadyAnim.Out:SetEasing("out")
				Runes[i].ReadyAnim.Out:SetDuration(0.2)
				Runes[i].ReadyAnim.Out:SetChange(0)

				if (i == 1) then
					Runes[i]:SetPoint("LEFT", Runes, 1, 0)
				else
					Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.Runes = Runes
			self.AuraParent = Runes
		elseif (HydraUI.UserClass == "PALADIN" and HydraUI.IsMainline) then
			local HolyPower = CreateFrame("Frame", self:GetName() .. "HolyPower", self, "BackdropTemplate")
			HolyPower:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			HolyPower:SetBackdrop(HydraUI.Backdrop)
			HolyPower:SetBackdropColor(0, 0, 0)
			HolyPower:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				HolyPower:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 5) - 1

			for i = 1, 5 do
				HolyPower[i] = CreateFrame("StatusBar", self:GetName() .. "HolyPower" .. i, HolyPower)
				HolyPower[i]:SetSize(Width, Settings["player-resource-height"])
				HolyPower[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				HolyPower[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-holy-power"]))
				HolyPower[i]:SetWidth(i == 1 and Width - 1 or Width)

				HolyPower[i].bg = HolyPower:CreateTexture(nil, "BORDER")
				HolyPower[i].bg:SetAllPoints(HolyPower[i])
				HolyPower[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				HolyPower[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-holy-power"]))
				HolyPower[i].bg:SetAlpha(0.3)

				if (i == 1) then
					HolyPower[i]:SetPoint("LEFT", HolyPower, 1, 0)
				else
					HolyPower[i]:SetPoint("TOPLEFT", HolyPower[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.ClassPower = HolyPower
			self.HolyPower = HolyPower
			self.AuraParent = HolyPower
		elseif (HydraUI.UserClass == "SHAMAN") and (not HydraUI.IsMainline) then
			local haveTotem, name = GetTotemInfo(1)
			if haveTotem then
				local Totems = CreateFrame("Frame", self:GetName() .. "Totems", self, "BackdropTemplate")
				Totems:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
				Totems:SetBackdrop(HydraUI.Backdrop)
				Totems:SetBackdropColor(0, 0, 0)
				Totems:SetBackdropBorderColor(0, 0, 0)
				Totems.PostUpdate = UF.PostUpdateTotems

				if Settings["player-move-resource"] then
					Totems:SetPoint("CENTER", ResourceAnchor, 0, 0)
				else
					Totems:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
				end

				--[[local TotemBar = CreateFrame("Frame", "HydraUI Totem Bar", HydraUI.UIParent)
				TotemBar:SetSize(40 * 4 + 5, 40 + 2)
				TotemBar:SetPoint("CENTER", HydraUI.UIParent, 0, -120)
				TotemBar:SetMovable("CENTER", HydraUI.UIParent, 0, -120)
				--HydraUI:CreateMover(TotemBar)
				TotemBar:EnableMouse(true)
				TotemBar:RegisterForDrag("LeftButton")
				TotemBar:SetUserPlaced(true)
				TotemBar:SetScript("OnDragStart", TotemBar.StartMoving)
				TotemBar:SetScript("OnDragStop", TotemBar.StopMovingOrSizing)

				TotemBar.bg = TotemBar:CreateTexture(nil, "BACKGROUND")
				TotemBar.bg:SetAllPoints()
				TotemBar.bg:SetTexture(Assets:GetTexture("Blank"))
				TotemBar.bg:SetVertexColor(0, 0, 0)]]

				local Width = (Settings["unitframes-player-width"] / 4) - 1

				for i = 1, 4 do
					Totems[i] = CreateFrame("Button", nil, self)
					Totems[i]:SetSize(40, 40)

					--[[Totems[i].bg = Totems:CreateTexture(nil, "BACKGROUND")
					Totems[i].bg:SetAllPoints(Totems[i])
					Totems[i].bg:SetTexture(Assets:GetTexture("Blank"))
					Totems[i].bg:SetVertexColor(HydraUI.TotemColors[i][1], HydraUI.TotemColors[i][2], HydraUI.TotemColors[i][3], 0.3)

					Totems[i].Icon = Totems[i]:CreateTexture(nil, "OVERLAY")
					Totems[i].Icon:SetPoint("TOPLEFT", 0, 0)
					Totems[i].Icon:SetPoint("BOTTOMRIGHT", 0, 0)
					Totems[i].Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

					Totems[i].Cooldown = CreateFrame("Cooldown", nil, Totems[i], "CooldownFrameTemplate")
					Totems[i].Cooldown:SetAllPoints()

					local Cooldown = Totems[i].Cooldown:GetRegions()

					if Cooldown then
						HydraUI:SetFontInfo(Cooldown, Settings["unitframes-font"], 18, Settings["unitframes-font-flags"])
					end]]

					Totems[i].Bar = CreateFrame("StatusBar", self:GetName() .. "Totems" .. i, Totems)
					Totems[i].Bar:SetSize(Width, Settings["player-resource-height"])
					Totems[i].Bar:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
					Totems[i].Bar:SetStatusBarColor(HydraUI.TotemColors[i][1], HydraUI.TotemColors[i][2], HydraUI.TotemColors[i][3])
					Totems[i].Bar:SetWidth(i == 1 and Width - 1 or Width)
					Totems[i].Bar:EnableMouse(true)
					Totems[i].Bar:SetID(i)
					Totems[i].Bar:Hide()

					Totems[i].bg = Totems:CreateTexture(nil, "BORDER")
					Totems[i].bg:SetAllPoints(Totems[i].Bar)
					Totems[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
					Totems[i].bg:SetVertexColor(HydraUI.TotemColors[i][1], HydraUI.TotemColors[i][2], HydraUI.TotemColors[i][3])
					Totems[i].bg:SetAlpha(0.3)

					if (i == 1) then
						--Totems[i]:SetPoint("LEFT", TotemBar, 1, 0)
						Totems[i].Bar:SetPoint("LEFT", Totems, 1, 0)
					else
						--Totems[i]:SetPoint("LEFT", Totems[i-1], "RIGHT", 1, 0)
						Totems[i].Bar:SetPoint("TOPLEFT", Totems[i-1].Bar, "TOPRIGHT", 1, 0)
					end
				end

				self.ClassPower = Totems
				self.Totems = Totems
				self.AuraParent = Totems
			end
			
		elseif (HydraUI.UserClass == "EVOKER") then
			local Essence = CreateFrame("Frame", self:GetName() .. "Essence", self, "BackdropTemplate")
			Essence:SetSize(Settings["unitframes-player-width"], Settings["player-resource-height"] + 2)
			Essence:SetBackdrop(HydraUI.Backdrop)
			Essence:SetBackdropColor(0, 0, 0)
			Essence:SetBackdropBorderColor(0, 0, 0)

			if Settings["player-move-resource"] then
				Essence:SetPoint("CENTER", ResourceAnchor, 0, 0)
			else
				Essence:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			end

			local Width = (Settings["unitframes-player-width"] / 6) - 1

			for i = 1, 6 do
				Essence[i] = CreateFrame("StatusBar", self:GetName() .. "Essence" .. i, Essence)
				Essence[i]:SetSize(Width, Settings["player-resource-height"])
				Essence[i]:SetStatusBarTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Essence[i]:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-essence"]))
				Essence[i]:SetWidth(i == 1 and Width - 1 or Width)

				Essence[i].bg = Essence:CreateTexture(nil, "BORDER")
				Essence[i].bg:SetAllPoints(Essence[i])
				Essence[i].bg:SetTexture(Assets:GetTexture(Settings.PlayerResourceTexture))
				Essence[i].bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-essence"]))
				Essence[i].bg:SetAlpha(0.3)

				if (i == 1) then
					Essence[i]:SetPoint("LEFT", Essence, 1, 0)
				else
					Essence[i]:SetPoint("TOPLEFT", Essence[i-1], "TOPRIGHT", 1, 0)
				end
			end

			self.ClassPower = Essence
			self.Essence = Essence
			self.AuraParent = Essence
		end

		self.ResourceAnchor = ResourceAnchor
	end

	-- Threat
	local Threat = CreateFrame("Frame", nil, self, "BackdropTemplate")

	if Settings["player-move-resource"] then
		Threat:SetPoint("TOPLEFT", -1, 1)
		Threat:SetPoint("BOTTOMRIGHT", 1, -1)
	else
		Threat:SetPoint("TOPLEFT", self.AuraParent, -1, 1)
		Threat:SetPoint("BOTTOMRIGHT", 1, -1)
	end

	Threat:SetBackdrop(HydraUI.Outline)
	Threat.PostUpdate = UF.ThreatPostUpdate

	self.ThreatIndicator = Threat

	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], Settings.PlayerBuffSize)
	Buffs.size = Settings.PlayerBuffSize
	Buffs.spacing = Settings.PlayerBuffSpacing
	Buffs.num = 40
	Buffs.initialAnchor = "BOTTOMLEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = UF.PostCreateIcon
	Buffs.PostUpdateIcon = UF.PostUpdateIcon

	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs:SetSize(Settings["unitframes-player-width"], 28)
	Debuffs.size = Settings.PlayerDebuffSize
	Debuffs.spacing = Settings.PlayerDebuffSpacing
	Debuffs.num = 16
	Debuffs.initialAnchor = "BOTTOMRIGHT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "LEFT"
	Debuffs["growth-y"] = "UP"
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.onlyShowPlayer = Settings["unitframes-only-player-debuffs"]

	if Settings["player-move-resource"] then
		if Settings["unitframes-show-player-buffs"] then
			Buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
			Debuffs:SetPoint("BOTTOM", Buffs, "TOP", 0, 2)

		else
			Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
		end
	else
		if Settings["unitframes-show-player-buffs"] then
			Buffs:SetPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
			Debuffs:SetPoint("BOTTOM", Buffs, "TOP", 0, 2)
		else
			Debuffs:SetPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
		end
	end

	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("CENTER", Health, 0, 0)
	Resurrect:Hide()

	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-player-health-left"])
	self:Tag(HealthRight, Settings["unitframes-player-health-right"])

	self.Health = Health
	self.Health.bg = HealthBG
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	--self.RaidTargetIndicator = RaidTarget
	self.ResurrectIndicator = Resurrect
	self.LeaderIndicator = Leader
	self.PvPIndicator = PvPIndicator
end

local UpdateOnlyPlayerDebuffs = function(value)
	if HydraUI.UnitFrames["target"] then
		HydraUI.UnitFrames["target"].Debuffs.onlyShowPlayer = value
	end
end

local UpdatePlayerWidth = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame:SetWidth(value)

		-- Auras
		Frame.Buffs:SetWidth(value)
		Frame.Debuffs:SetWidth(value)

		if Settings["player-move-power"] then
			return
		end

		if Frame.ComboPoints then
			Frame.ComboPoints:SetWidth(value)

			local Max = UnitPowerMax("player", Enum.PowerType.ComboPoints)
			local Width = (Settings["unitframes-player-width"] / Max) - 1

			for i = 1, Max do
				Frame.ComboPoints[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.SoulShards then
			Frame.SoulShards:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 5) - 1

			for i = 1, 5 do
				Frame.SoulShards[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.ArcanePower then
			Frame.ArcanePower:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 4) - 1

			for i = 1, 4 do
				Frame.ArcanePower[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.Totems then
			Frame.Totems:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 4) - 1

			for i = 1, 4 do
				Frame.Totems[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.Chi then
			Frame.Chi:SetWidth(value)
			Frame.Stagger:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 6) - 1

			for i = 1, 6 do
				Frame.Chi[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.Runes then
			Frame.Runes:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 6) - 1

			for i = 1, 6 do
				Frame.Runes[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		elseif Frame.HolyPower then
			Frame.HolyPower:SetWidth(value)

			local Width = (Settings["unitframes-player-width"] / 5) - 1

			for i = 1, 5 do
				Frame.HolyPower[i]:SetWidth(i == 1 and Width - 1 or Width)
			end
		end
	end
end

local UpdatePlayerHealthHeight = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Health:SetHeight(value)
		Frame:SetHeight(value + Settings["unitframes-player-power-height"] + 3)
	end
end

local UpdatePlayerHealthFill = function(value)
	if HydraUI.UnitFrames["player"] then
		local Unit = HydraUI.UnitFrames["player"]

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

local UpdatePlayerPowerHeight = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Power:SetHeight(value)

		if (not Settings["player-move-power"]) then
			Frame:SetHeight(Settings["unitframes-player-health-height"] + value + 3)
		end
	end
end

local UpdatePlayerPowerFill = function(value)
	if HydraUI.UnitFrames["player"] then
		HydraUI.UnitFrames["player"].Power:SetReverseFill(value)
	end
end

local UpdatePlayerCastBarSize = function()
	if HydraUI.UnitFrames["player"].Castbar then
		HydraUI.UnitFrames["player"].Castbar:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])
		HydraUI.UnitFrames["player"].Castbar.Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
	end
end

local UpdateCastClassColor = function(value)
	if HydraUI.UnitFrames["player"].Castbar then
		HydraUI.UnitFrames["player"].Castbar.ClassColor = value
		HydraUI.UnitFrames["player"].Castbar:ForceUpdate()
	end
end

local UpdatePlayerHealthColor = function(value)
	if HydraUI.UnitFrames["player"] then
		local Health = HydraUI.UnitFrames["player"].Health

		UF:SetHealthAttributes(Health, value)

		Health:ForceUpdate()
	end
end

local UpdatePlayerPowerColor = function(value)
	if HydraUI.UnitFrames["player"] then
		local Power = HydraUI.UnitFrames["player"].Power

		UF:SetPowerAttributes(Power, value)

		Power:ForceUpdate()
	end
end

local UpdatePlayerEnablePortrait = function(value)
	if HydraUI.UnitFrames["player"] then
		if value then
			HydraUI.UnitFrames["player"]:EnableElement("Portrait")

			if HydraUI.UnitFrames["player"].Portrait.BG then
				HydraUI.UnitFrames["player"].Portrait.BG:Show()
			end
		else
			HydraUI.UnitFrames["player"]:DisableElement("Portrait")

			if HydraUI.UnitFrames["player"].Portrait.BG then
				HydraUI.UnitFrames["player"].Portrait.BG:Hide()
			end
		end

		HydraUI.UnitFrames["player"].Portrait:ForceUpdate()
	end
end

local UpdateOverlayAlpha = function(value)
	if HydraUI.UnitFrames["player"] and Settings["player-portrait-style"] == "OVERLAY" then
		HydraUI.UnitFrames["player"].Portrait:SetAlpha(value / 100)
	end
end

local UpdatePlayerEnablePVPIndicator = function(value)
	if HydraUI.UnitFrames["player"] then
		if value then
			HydraUI.UnitFrames["player"]:EnableElement("PvPIndicator")
			HydraUI.UnitFrames["player"].PvPIndicator:ForceUpdate()
		else
			HydraUI.UnitFrames["player"]:DisableElement("PvPIndicator")
			HydraUI.UnitFrames["player"].PvPIndicator:Hide()
		end
	end
end

local UpdateResourceBarHeight = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		if Frame.ComboPoints then
			Frame.ComboPoints:SetHeight(value + 2)

			local Max = UnitPowerMax("player", Enum.PowerType.ComboPoints)

			for i = 1, Max do
				Frame.ComboPoints[i]:SetHeight(value)
			end
		elseif Frame.SoulShards then
			Frame.SoulShards:SetHeight(value + 2)

			for i = 1, 5 do
				Frame.SoulShards[i]:SetHeight(value)
			end
		elseif Frame.ArcanePower then
			Frame.ArcanePower:SetHeight(value + 2)

			for i = 1, 4 do
				Frame.ArcanePower[i]:SetHeight(value)
			end
		elseif Frame.Chi then
			Frame.Chi:SetHeight(value + 2)
			Frame.Stagger:SetHeight(value)

			for i = 1, 6 do
				Frame.Chi[i]:SetHeight(value)
			end
		elseif Frame.Runes then
			Frame.Runes:SetHeight(value + 2)

			for i = 1, 6 do
				Frame.Runes[i]:SetHeight(value)
			end
		elseif Frame.HolyPower then
			Frame.HolyPower:SetHeight(value + 2)

			for i = 1, 5 do
				Frame.HolyPower[i]:SetHeight(value)
			end
		elseif Frame.Totems then
			Frame.Totems:SetHeight(value + 2)

			for i = 1, 4 do
				Frame.Totems[i]:SetHeight(value)
			end
		end
	end
end

local UpdateResourceTexture = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		if Frame.ComboPoints then
			for i = 1, #Frame.ComboPoints do
				Frame.ComboPoints[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.ComboPoints[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.SoulShards then
			for i = 1, 5 do
				Frame.SoulShards[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.SoulShards[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.ArcanePower then
			for i = 1, 4 do
				Frame.ArcanePower[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.ArcanePower[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.Chi then
			Frame.Stagger:SetStatusBarTexture(Assets:GetTexture(value))
			Frame.Stagger.bg:SetTexture(Assets:GetTexture(value))

			for i = 1, 6 do
				Frame.Chi[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.Chi[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.Runes then
			for i = 1, 6 do
				Frame.Runes[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.Runes[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.HolyPower then
			for i = 1, 5 do
				Frame.HolyPower[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.HolyPower[i].bg:SetTexture(Assets:GetTexture(value))
			end
		elseif Frame.Totems then
			for i = 1, 4 do
				Frame.Totems[i]:SetStatusBarTexture(Assets:GetTexture(value))
				Frame.Totems[i].bg:SetTexture(Assets:GetTexture(value))
			end
		end
	end
end

local UpdateBuffSize = function(value)
	if HydraUI.UnitFrames["player"] then
		HydraUI.UnitFrames["player"].Buffs.size = value
		HydraUI.UnitFrames["player"].Buffs:SetSize(Settings["unitframes-player-width"], value)
		HydraUI.UnitFrames["player"].Buffs:ForceUpdate()
	end
end

local UpdateBuffSpacing = function(value)
	if HydraUI.UnitFrames["player"] then
		HydraUI.UnitFrames["player"].Buffs.spacing = value
		HydraUI.UnitFrames["player"].Buffs:ForceUpdate()
	end
end

local UpdateDebuffSize = function(value)
	if HydraUI.UnitFrames["player"] then
		HydraUI.UnitFrames["player"].Debuffs.size = value
		HydraUI.UnitFrames["player"].Debuffs:SetSize(Settings["unitframes-player-width"], value)
		HydraUI.UnitFrames["player"].Debuffs:ForceUpdate()
	end
end

local UpdateDebuffSpacing = function(value)
	if HydraUI.UnitFrames["player"] then
		HydraUI.UnitFrames["player"].Debuffs.spacing = value
		HydraUI.UnitFrames["player"].Debuffs:ForceUpdate()
	end
end

local UpdateDisplayedAuras = function()
	if (not HydraUI.UnitFrames["player"]) then
		return
	end

	local Player = HydraUI.UnitFrames["player"]

	Player.Buffs:ClearAllPoints()
	Player.Debuffs:ClearAllPoints()

	if Settings["player-move-resource"] then
		if Settings["unitframes-show-player-buffs"] then
			Player.Buffs:SetPoint("BOTTOMLEFT", Player, "TOPLEFT", 0, 2)
			Player.Debuffs:SetPoint("BOTTOM", Player.Buffs, "TOP", 0, 2)

		else
			Player.Debuffs:SetPoint("BOTTOMLEFT", Player, "TOPLEFT", 0, 2)
		end
	else
		if Settings["unitframes-show-player-buffs"] then
			Player.Buffs:SetPoint("BOTTOMLEFT", Player.AuraParent, "TOPLEFT", 0, 2)
			Player.Debuffs:SetPoint("BOTTOM", Player.Buffs, "TOP", 0, 2)
		else
			Player.Debuffs:SetPoint("BOTTOMLEFT", Player.AuraParent, "TOPLEFT", 0, 2)
		end
	end

	if Settings["unitframes-show-player-buffs"] then
		Player.Buffs:Show()
	else
		Player.Buffs:Hide()
	end

	if Settings["unitframes-show-player-debuffs"] then
		Player.Debuffs:Show()
	else
		Player.Debuffs:Hide()
	end
end

local UpdateResourcePosition = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Debuffs:ClearAllPoints()
		Frame.ThreatIndicator:ClearAllPoints()

		if value then
			if Settings["unitframes-show-player-buffs"] then
				Frame.Buffs:ClearAllPoints()
				Frame.Buffs:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, 2)
				Frame.Debuffs:SetPoint("BOTTOM", Frame.Buffs, "TOP", 0, 2)
			else
				Frame.Debuffs:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, 2)
			end

			Frame.ThreatIndicator:SetPoint("TOPLEFT", Frame, -1, 1)
			Frame.ThreatIndicator:SetPoint("BOTTOMRIGHT", Frame, 1, -1)
		else
			if Settings["unitframes-show-player-buffs"] then
				Frame.Buffs:ClearAllPoints()
				Frame.Buffs:SetPoint("BOTTOMLEFT", Frame.AuraParent, "TOPLEFT", 0, 2)
				Frame.Debuffs:SetPoint("BOTTOM", Frame.Buffs, "TOP", 0, 2)
			else
				Frame.Debuffs:SetPoint("BOTTOMLEFT", Frame.AuraParent, "TOPLEFT", 0, 2)
			end

			Frame.ThreatIndicator:SetPoint("TOPLEFT", Frame.AuraParent, -1, 1)
			Frame.ThreatIndicator:SetPoint("BOTTOMRIGHT", 1, -1)
		end

		if Frame.ComboPoints then
			Frame.ComboPoints:ClearAllPoints()

			if value then
				Frame.ComboPoints:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.ComboPoints:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.SoulShards then
			Frame.SoulShards:ClearAllPoints()

			if value then
				Frame.SoulShards:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.SoulShards:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.ArcanePower then
			Frame.ArcanePower:ClearAllPoints()

			if value then
				Frame.ArcanePower:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.ArcanePower:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.Chi then
			Frame.Chi:ClearAllPoints()
			Frame.Stagger:ClearAllPoints()

			if value then
				Frame.Chi:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
				Frame.Stagger:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.Chi:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
				Frame.Stagger:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.Runes then
			Frame.Runes:ClearAllPoints()

			if value then
				Frame.Runes:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.Runes:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.HolyPower then
			Frame.HolyPower:ClearAllPoints()

			if value then
				Frame.HolyPower:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.HolyPower:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		elseif Frame.Totems then
			Frame.Totems:ClearAllPoints()

			if value then
				Frame.Totems:SetPoint("CENTER", Frame.ResourceAnchor, 0, 0)
			else
				Frame.Totems:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", 0, -1)
			end
		end
	end
end

local UpdatePowerBarPosition = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Power:ClearAllPoints()

		if value then
			Frame:SetHeight(Settings["unitframes-player-health-height"] + 2)

			Frame.Power:SetPoint("BOTTOMLEFT", Frame.PowerAnchor, 1, 1)
			Frame.Power:SetPoint("BOTTOMRIGHT", Frame.PowerAnchor, -1, 1)
		else
			Frame:SetHeight(Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)

			Frame.Power:SetPoint("BOTTOMLEFT", Frame, 1, 1)
			Frame.Power:SetPoint("BOTTOMRIGHT", Frame, -1, 1)
		end
	end
end

local UpdateHealthTexture = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Health:SetStatusBarTexture(Assets:GetTexture(value))
		Frame.Health.bg:SetTexture(Assets:GetTexture(value))
		Frame.HealBar:SetStatusBarTexture(Assets:GetTexture(value))

		if Frame.AbsorbsBar then
			Frame.AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(value))
		end
	end
end

local UpdatePowerTexture = function(value)
	if HydraUI.UnitFrames["player"] then
		local Frame = HydraUI.UnitFrames["player"]

		Frame.Power:SetStatusBarTexture(Assets:GetTexture(value))
		Frame.Power.bg:SetTexture(Assets:GetTexture(value))

		if Frame.ManaTimer then
			Frame.ManaTimer:SetStatusBarTexture(Assets:GetTexture(value))
		end

		if Frame.EnergyTick then
			Frame.EnergyTick:SetStatusBarTexture(Assets:GetTexture(value))
		end

		if Frame.PowerPrediction then
			Frame.PowerPrediction.mainBar:SetStatusBarTexture(Assets:GetTexture(value))
		end
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Player"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("player-enable", Settings["player-enable"], Language["Enable Player"], Language["Enable the player unit frame"], ReloadUI):RequiresReload(true)
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, Language["Width"], Language["Set the width of the player unit frame"], UpdatePlayerWidth)
	left:CreateSwitch("player-enable-pvp", Settings["player-enable-pvp"], Language["Enable PVP Indicator"], Language["Display the pvp indicator"], UpdatePlayerEnablePVPIndicator)

	if (HydraUI.IsClassic or HydraUI.IsTBC) then
		left:CreateSwitch("unitframes-show-mana-timer", Settings["unitframes-show-mana-timer"], Language["Enable Mana Regen Timer"], Language["Display the time until your full mana regeneration is active"], ReloadUI):RequiresReload(true)
		left:CreateSwitch("unitframes-show-energy-timer", Settings["unitframes-show-energy-timer"], Language["Enable Energy Timer"], Language["Display the time until your next energy tick on the power bar"], ReloadUI):RequiresReload(true)
	end

	left:CreateSwitch("player-enable-portrait", Settings["player-enable-portrait"], Language["Enable Portrait"], Language["Display the player unit portrait"], UpdatePlayerEnablePortrait)
	left:CreateDropdown("player-portrait-style", Settings["player-portrait-style"], {[Language["2D"]] = "2D", [Language["3D"]] = "3D", [Language["Overlay"]] = "OVERLAY"}, Language["Set Portrait Style"], Language["Set the style of the portrait"], ReloadUI):RequiresReload(true)
	left:CreateSlider("player-overlay-alpha", Settings["player-overlay-alpha"], 0, 100, 5, Language["Set Overlay Opacity"], Language["Set the opacity of the portrait overlay"], UpdateOverlayAlpha, nil, "%")

	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePlayerHealthFill)
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdatePlayerHealthHeight)
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePlayerHealthColor)
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"], ReloadUI):RequiresReload(true)
	left:CreateDropdown("PlayerHealthTexture", Settings.PlayerHealthTexture, Assets:GetTextureList(), Language["Health Texture"], "", UpdateHealthTexture, "Texture")

	left:CreateHeader(Language["Buffs"])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateDisplayedAuras)
	left:CreateSlider("PlayerBuffSize", Settings.PlayerBuffSize, 26, 50, 2, "Set Size", "Set the size of the auras", UpdateBuffSize)
	left:CreateSlider("PlayerBuffSpacing", Settings.PlayerBuffSpacing, -1, 4, 1, "Set Spacing", "Set the spacing between the auras", UpdateBuffSpacing)

	left:CreateHeader(Language["Debuffs"])
	left:CreateSwitch("unitframes-show-player-debuffs", Settings["unitframes-show-player-debuffs"], Language["Show Player Debuffs"], Language["Show your debuff auras above the player unit frame"], UpdateDisplayedAuras)
	left:CreateSlider("PlayerDebuffSize", Settings.PlayerDebuffSize, 26, 50, 2, "Set Size", "Set the size of the auras", UpdateDebuffSize)
	left:CreateSlider("PlayerDebuffSpacing", Settings.PlayerDebuffSpacing, -1, 4, 1, "Set Spacing", "Set the spacing between the auras", UpdateDebuffSpacing)

	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	right:CreateSwitch("player-move-power", Settings["player-move-power"], Language["Detach Power"], Language["Detach the power bar from the unit frame"], UpdatePowerBarPosition)
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar", UpdatePlayerPowerHeight)
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePlayerPowerColor)
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateDropdown("PlayerPowerTexture", Settings.PlayerPowerTexture, Assets:GetTextureList(), Language["Power Texture"], "", UpdatePowerTexture, "Texture")

	right:CreateHeader(Language["Cast Bar"])
	right:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"], ReloadUI):RequiresReload(true)
	right:CreateSwitch("unitframes-player-cast-classcolor", Settings["unitframes-player-cast-classcolor"], Language["Enable Class Color"], Language["Use class colors"], UpdateCastClassColor)
	right:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"], UpdatePlayerCastBarSize)
	right:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"], UpdatePlayerCastBarSize)

	right:CreateHeader(Language["Class Resource"])
	right:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resource such as combo points, runes, etc."], ReloadUI):RequiresReload(true)
	right:CreateSwitch("player-move-resource", Settings["player-move-resource"], Language["Detach Class Bar"], Language["Detach the class resource from the unit frame, to be moved by the UI"], UpdateResourcePosition)
	right:CreateSlider("player-resource-height", Settings["player-resource-height"], 4, 30, 1, Language["Set Height"], Language["Set the height of the player resource bar"], UpdateResourceBarHeight)
	right:CreateDropdown("PlayerResourceTexture", Settings.PlayerResourceTexture, Assets:GetTextureList(), Language["Texture"], "", UpdateResourceTexture, "Texture")
end)
