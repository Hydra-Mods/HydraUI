local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["unitframes-player-width"] = 238
Defaults["unitframes-player-health-height"] = 32
Defaults["unitframes-player-health-reverse"] = false
Defaults["unitframes-player-health-color"] = "CLASS"
Defaults["unitframes-player-health-smooth"] = true
Defaults["unitframes-player-power-height"] = 15
Defaults["unitframes-player-power-reverse"] = false
Defaults["unitframes-player-power-color"] = "POWER"
Defaults["unitframes-player-power-smooth"] = true
Defaults["unitframes-player-health-left"] = ""
Defaults["unitframes-player-health-right"] = "[HealthPercent]"
Defaults["unitframes-player-power-left"] = "[HealthValues]"
Defaults["unitframes-player-power-right"] = "[PowerValues]"
Defaults["unitframes-player-enable-power"] = true
Defaults["unitframes-player-enable-resource"] = true
Defaults["unitframes-player-cast-width"] = 250
Defaults["unitframes-player-cast-height"] = 24
Defaults["unitframes-player-enable-castbar"] = true
Defaults["player-enable-portrait"] = false
Defaults["player-enable-pvp-indicator"] = true

local UF = vUI:GetModule("Unit Frames")

vUI.StyleFuncs["player"] = function(self, unit)
	-- General
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetAllPoints()
	Backdrop:SetTexture(Assets:GetTexture("Blank"))
	Backdrop:SetVertexColor(0, 0, 0)
	
	self.AuraParent = self
	
	-- Health Bar
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOPLEFT", self, 1, -1)
	Health:SetPoint("TOPRIGHT", self, -1, -1)
	Health:SetHeight(Settings["unitframes-player-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["unitframes-player-health-reverse"])
	
	local AbsorbsBar = CreateFrame("StatusBar", nil, self)
	AbsorbsBar:SetWidth(Settings["unitframes-player-width"])
	AbsorbsBar:SetHeight(Settings["unitframes-player-health-height"])
	AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
	AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)
	
	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetWidth(Settings["unitframes-player-width"])
	HealBar:SetHeight(Settings["unitframes-player-health-height"])
	HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
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
	
    -- 3D Portrait
    local Portrait = CreateFrame("PlayerModel", nil, self)
    Portrait:SetSize(55, Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 1)
    Portrait:SetPoint("RIGHT", self, "LEFT", -3, 0)
	
	Portrait.BG = Portrait:CreateTexture(nil, "BACKGROUND")
	Portrait.BG:SetPoint("TOPLEFT", Portrait, -1, 1)
	Portrait.BG:SetPoint("BOTTOMRIGHT", Portrait, 1, -1)
	Portrait.BG:SetTexture(Assets:GetTexture(Settings["Blank"]))
	Portrait.BG:SetVertexColor(0, 0, 0)
	
	--[[Portrait.BG2 = Portrait:CreateTexture(nil, "BORDER")
	Portrait.BG2:SetPoint("TOPLEFT", Portrait, 0, 0)
	Portrait.BG2:SetPoint("BOTTOMRIGHT", Portrait, 0, 0)
	Portrait.BG2:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Portrait.BG2:SetAlpha(0.2)]]
	
    self.Portrait = Portrait
	
	local Combat = Health:CreateTexture(nil, "OVERLAY")
	Combat:SetSize(20, 20)
	Combat:SetPoint("CENTER", Health)
	
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(vUI:HexToRGB("FFEB3B"))
    Leader:Hide()
	
    -- PVP indicator
    local PvPIndicator = Health:CreateTexture(nil, "ARTWORK", nil, 1)
    PvPIndicator:SetSize(30, 30)
    PvPIndicator:SetPoint("RIGHT", Health, "LEFT", -4, -2)
	
	PvPIndicator.Badge = Health:CreateTexture(nil, "ARTWORK")
	PvPIndicator.Badge:SetSize(50, 52)
    PvPIndicator.Badge:SetPoint("CENTER", PvPIndicator, "CENTER")
	
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")
	
	local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
	
	-- Attributes
	Health.frequentUpdates = true
	Health.Smooth = true
	self.colors.health = {R, G, B}
	UF:SetHealthAttributes(Health, Settings["unitframes-player-health-color"])
	
	if Settings["unitframes-player-enable-power"] then
		local Power = CreateFrame("StatusBar", nil, self)
		Power:SetPoint("BOTTOMLEFT", self, 1, 1)
		Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
		Power:SetHeight(Settings["unitframes-player-power-height"])
		Power:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		Power:SetReverseFill(Settings["unitframes-player-power-reverse"])
		
		local PowerBG = Power:CreateTexture(nil, "BORDER")
		PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
		PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
		PowerBG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		PowerBG:SetAlpha(0.2)
		
		local PowerRight = Power:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(PowerRight, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerRight:SetPoint("RIGHT", Power, -3, 0)
		PowerRight:SetJustifyH("RIGHT")
		
		local PowerLeft = Power:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(PowerLeft, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		PowerLeft:SetPoint("LEFT", Power, 3, 0)
		PowerLeft:SetJustifyH("LEFT")
		
		-- Heal prediction
		local MainBar = CreateFrame("StatusBar", nil, Power)
		MainBar:SetReverseFill(true)
		MainBar:SetPoint("TOP")
		MainBar:SetPoint("BOTTOM")
		MainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT")
		MainBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		MainBar:SetStatusBarColor(0.8, 0.1, 0.1)
		MainBar:SetWidth(200)
		
		-- Register with oUF
		self.PowerPrediction = {
			mainBar = MainBar,
		}
		
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
	end
	
    -- Castbar
	if Settings["unitframes-player-enable-castbar"] then
		local Castbar = CreateFrame("StatusBar", "vUI Casting Bar", self)
		Castbar:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])
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
		vUI:SetFontInfo(Time, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Time:SetPoint("RIGHT", Castbar, -3, 0)
		Time:SetJustifyH("RIGHT")
		
		-- Add spell text
		local Text = Castbar:CreateFontString(nil, "OVERLAY")
		vUI:SetFontInfo(Text, Settings["unitframes-font"], Settings["unitframes-font-size"], Settings["unitframes-font-flags"])
		Text:SetPoint("LEFT", Castbar, 3, 0)
		Text:SetSize(Settings["unitframes-player-cast-width"] * 0.7, Settings["unitframes-font-size"])
		Text:SetJustifyH("LEFT")
		
		-- Add spell icon
		local Icon = Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
		Icon:SetPoint("TOPRIGHT", Castbar, "TOPLEFT", -4, 0)
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		local IconBG = Castbar:CreateTexture(nil, "BACKGROUND")
		IconBG:SetPoint("TOPLEFT", Icon, -1, 1)
		IconBG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
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
		
		self.Castbar = Castbar
	end
	
	if Settings["unitframes-player-enable-resource"] then
		if (vUI.UserClass == "ROGUE" or vUI.UserClass == "DRUID") then
			local ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self, "BackdropTemplate")
			ComboPoints:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			ComboPoints:SetSize(Settings["unitframes-player-width"], 10)
			ComboPoints:SetBackdrop(vUI.Backdrop)
			ComboPoints:SetBackdropColor(0, 0, 0)
			ComboPoints:SetBackdropBorderColor(0, 0, 0)
			
			local Max = (vUI.UserClass == "ROGUE" and 6 or 5)
			local Width = (Settings["unitframes-player-width"] / Max) - 1
			
			for i = 1, Max do
				ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoint" .. i, ComboPoints)
				ComboPoints[i]:SetSize(Width, 8)
				ComboPoints[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ComboPoints[i]:SetStatusBarColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
				ComboPoints[i]:SetWidth(i == 1 and Width - 1 or Width)
				
				ComboPoints[i].bg = ComboPoints[i]:CreateTexture(nil, "BORDER")
				ComboPoints[i].bg:SetAllPoints(ComboPoints[i])
				ComboPoints[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ComboPoints[i].bg:SetVertexColor(vUI.ComboPoints[i][1], vUI.ComboPoints[i][2], vUI.ComboPoints[i][3])
				ComboPoints[i].bg:SetAlpha(0.3)
				
				ComboPoints[i].Charged = CreateFrame("Frame", nil, ComboPoints[i], "BackdropTemplate")
				ComboPoints[i].Charged:SetPoint("TOPLEFT", 0, 0)
				ComboPoints[i].Charged:SetPoint("BOTTOMRIGHT", 0, 0)
				ComboPoints[i].Charged:SetBackdrop(vUI.Outline)
				ComboPoints[i].Charged:SetBackdropBorderColor(vUI:HexToRGB("F5F5F5"))
				ComboPoints[i].Charged:Hide()
				
				ComboPoints[i].ChargedInside = ComboPoints[i].Charged:CreateTexture(nil, "ARTWORK")
				ComboPoints[i].ChargedInside:SetPoint("TOPLEFT", ComboPoints[i], 1, -1)
				ComboPoints[i].ChargedInside:SetPoint("BOTTOMRIGHT", ComboPoints[i], -1, 1)
				ComboPoints[i].ChargedInside:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ComboPoints[i].ChargedInside:SetVertexColor(vUI:HexToRGB(Settings["color-combo-charged"]))
				
				ComboPoints[i].Charged.Anim = CreateAnimationGroup(ComboPoints[i].Charged)
				
				ComboPoints[i].Charged.In = ComboPoints[i].Charged.Anim:CreateAnimation("Fade")
				ComboPoints[i].Charged.In:SetEasing("in")
				ComboPoints[i].Charged.In:SetDuration(0.2)
				ComboPoints[i].Charged.In:SetChange(1)
				
				ComboPoints[i].Charged.Out = ComboPoints[i].Charged.Anim:CreateAnimation("Fade")
				ComboPoints[i].Charged.Out:SetEasing("out")
				ComboPoints[i].Charged.Out:SetDuration(0.2)
				ComboPoints[i].Charged.Out:SetChange(0)
				ComboPoints[i].Charged.Out:SetScript("OnFinished", function(self)
					self.Parent:Hide()
				end)
				
				if (i == 1) then
					ComboPoints[i]:SetPoint("LEFT", ComboPoints, 1, 0)
				else
					ComboPoints[i]:SetPoint("TOPLEFT", ComboPoints[i-1], "TOPRIGHT", 1, 0)
				end
			end
			
			self.ComboPoints = ComboPoints
			self.AuraParent = ComboPoints
		elseif (vUI.UserClass == "WARLOCK") then
			local SoulShards = CreateFrame("Frame", self:GetName() .. "SoulShards", self, "BackdropTemplate")
			SoulShards:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			SoulShards:SetSize(Settings["unitframes-player-width"], 10)
			SoulShards:SetBackdrop(vUI.Backdrop)
			SoulShards:SetBackdropColor(0, 0, 0)
			SoulShards:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 5) - 1
			
			for i = 1, 5 do
				SoulShards[i] = CreateFrame("StatusBar", self:GetName() .. "SoulShard" .. i, SoulShards)
				SoulShards[i]:SetSize(Width, 8)
				SoulShards[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				SoulShards[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-soul-shards"]))
				SoulShards[i]:SetWidth(i == 1 and Width - 1 or Width)
				
				SoulShards[i].bg = SoulShards:CreateTexture(nil, "BORDER")
				SoulShards[i].bg:SetAllPoints(SoulShards[i])
				SoulShards[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				SoulShards[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-soul-shards"]))
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
		elseif (vUI.UserClass == "MAGE") then
			local ArcaneCharges = CreateFrame("Frame", self:GetName() .. "ArcaneCharges", self, "BackdropTemplate")
			ArcaneCharges:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			ArcaneCharges:SetSize(Settings["unitframes-player-width"], 10)
			ArcaneCharges:SetBackdrop(vUI.Backdrop)
			ArcaneCharges:SetBackdropColor(0, 0, 0)
			ArcaneCharges:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 4)
			
			for i = 1, 4 do
				ArcaneCharges[i] = CreateFrame("StatusBar", self:GetName() .. "ArcaneCharge" .. i, ArcaneCharges)
				ArcaneCharges[i]:SetSize(Width, 8)
				ArcaneCharges[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ArcaneCharges[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-arcane-charges"]))
				ArcaneCharges[i]:SetWidth(i == 1 and Width - 1 or Width)
				
				ArcaneCharges[i].bg = ArcaneCharges:CreateTexture(nil, "BORDER")
				ArcaneCharges[i].bg:SetAllPoints(ArcaneCharges[i])
				ArcaneCharges[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				ArcaneCharges[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-arcane-charges"]))
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
		elseif (vUI.UserClass == "MONK") then
			local Chi = CreateFrame("Frame", self:GetName() .. "Chi", self, "BackdropTemplate")
			Chi:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			Chi:SetSize(Settings["unitframes-player-width"], 10)
			Chi:SetBackdrop(vUI.Backdrop)
			Chi:SetBackdropColor(0, 0, 0)
			Chi:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 6) - 1
			
			for i = 1, 6 do
				Chi[i] = CreateFrame("StatusBar", self:GetName() .. "Chi" .. i, Chi)
				Chi[i]:SetSize(Width, 8)
				Chi[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Chi[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-chi"]))
				Chi[i]:SetWidth(i == 1 and Width - 1 or Width)
				
				Chi[i].bg = Chi:CreateTexture(nil, "BORDER")
				Chi[i].bg:SetAllPoints(Chi[i])
				Chi[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Chi[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-chi"]))
				Chi[i].bg:SetAlpha(0.3)
				
				if (i == 1) then
					Chi[i]:SetPoint("LEFT", Chi, 1, 0)
				else
					Chi[i]:SetPoint("TOPLEFT", Chi[i-1], "TOPRIGHT", 1, 0)
				end
			end
			
			local Stagger = CreateFrame("StatusBar", nil, self)
			Stagger:SetSize(Settings["unitframes-player-width"] - 2, 8)
			Stagger:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 1, 0)
			Stagger:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			Stagger:Hide()
			
			Stagger.bg = Stagger:CreateTexture(nil, "ARTWORK")
			Stagger.bg:SetAllPoints()
			Stagger.bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			Stagger.bg.multiplier = 0.3
			
			Stagger.Backdrop = Stagger:CreateTexture(nil, "BACKGROUND")
			Stagger.Backdrop:SetPoint("TOPLEFT", Stagger, -1, 1)
			Stagger.Backdrop:SetPoint("BOTTOMRIGHT", Stagger, 1, -1)
			Stagger.Backdrop:SetColorTexture(0, 0, 0)
			
			self.Stagger = Stagger
			self.ClassPower = Chi
			self.Chi = Chi
			self.AuraParent = Chi
		elseif (vUI.UserClass == "DEATHKNIGHT") then
			local Runes = CreateFrame("Frame", self:GetName() .. "Runes", self, "BackdropTemplate")
			Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			Runes:SetSize(Settings["unitframes-player-width"], 10)
			Runes:SetBackdrop(vUI.Backdrop)
			Runes:SetBackdropColor(0, 0, 0)
			Runes:SetBackdropBorderColor(0, 0, 0)
			Runes.sortOrder = "asc" -- desc
			
			local Width = (Settings["unitframes-player-width"] / 6) - 1
			
			for i = 1, 6 do
				Runes[i] = CreateFrame("StatusBar", self:GetName() .. "Rune" .. i, Runes)
				Runes[i]:SetSize(Width, 8)
				Runes[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				Runes[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-runes"]))
				Runes[i]:SetWidth(i == 1 and Width - 1 or Width)
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
				
				if (i == 1) then
					Runes[i]:SetPoint("LEFT", Runes, 1, 0)
				else
					Runes[i]:SetPoint("TOPLEFT", Runes[i-1], "TOPRIGHT", 1, 0)
				end
			end
			
			self.Runes = Runes
			self.AuraParent = Runes
		elseif (vUI.UserClass == "PALADIN") then
			local HolyPower = CreateFrame("Frame", self:GetName() .. "HolyPower", self, "BackdropTemplate")
			HolyPower:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -1)
			HolyPower:SetSize(Settings["unitframes-player-width"], 10)
			HolyPower:SetBackdrop(vUI.Backdrop)
			HolyPower:SetBackdropColor(0, 0, 0)
			HolyPower:SetBackdropBorderColor(0, 0, 0)
			
			local Width = (Settings["unitframes-player-width"] / 5) - 1
			
			for i = 1, 5 do
				HolyPower[i] = CreateFrame("StatusBar", self:GetName() .. "HolyPower" .. i, HolyPower)
				HolyPower[i]:SetSize(Width, 8)
				HolyPower[i]:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				HolyPower[i]:SetStatusBarColor(vUI:HexToRGB(Settings["color-holy-power"]))
				HolyPower[i]:SetWidth(i == 1 and Width - 1 or Width)
				
				HolyPower[i].bg = HolyPower:CreateTexture(nil, "BORDER")
				HolyPower[i].bg:SetAllPoints(HolyPower[i])
				HolyPower[i].bg:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
				HolyPower[i].bg:SetVertexColor(vUI:HexToRGB(Settings["color-holy-power"]))
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
		end
	end
	
	-- Auras
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	Buffs:SetSize(Settings["unitframes-player-width"], 28)
	Buffs:SetPoint("BOTTOMLEFT", self.AuraParent, "TOPLEFT", 0, 2)
	Buffs.size = 28
	Buffs.spacing = 2
	Buffs.num = 40
	Buffs.initialAnchor = "TOPLEFT"
	Buffs.tooltipAnchor = "ANCHOR_TOP"
	Buffs["growth-x"] = "RIGHT"
	Buffs["growth-y"] = "UP"
	Buffs.PostCreateIcon = UF.PostCreateIcon
	Buffs.PostUpdateIcon = UF.PostUpdateIcon
	--Buffs.SetPosition = BuffsSetPosition
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
	
	-- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("CENTER", Health, 0, 0)
	
	-- Tags
	self:Tag(HealthLeft, Settings["unitframes-player-health-left"])
	self:Tag(HealthRight, Settings["unitframes-player-health-right"])
	
	self.Health = Health
	self.Health.bg = HealthBG
	self.AbsorbsBar = AbsorbsBar
	self.HealBar = HealBar
	self.HealthLeft = HealthLeft
	self.HealthRight = HealthRight
	self.CombatIndicator = Combat
	self.Buffs = Buffs
	self.Debuffs = Debuffs
	--self.RaidTargetIndicator = RaidTarget
	self.PvPIndicator = PvPIndicator
	self.ResurrectIndicator = Resurrect
	self.LeaderIndicator = Leader
end

local UpdateOnlyPlayerDebuffs = function(value)
	if vUI.UnitFrames["target"] then
		vUI.UnitFrames["target"].Debuffs.onlyShowPlayer = value
	end
end

local UpdatePlayerWidth = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame:SetWidth(value)
		
		-- Auras
		Frame.Buffs:SetWidth(value)
		Frame.Debuffs:SetWidth(value)
		
		-- Combo points
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
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Health:SetHeight(value)
		Frame:SetHeight(value + Settings["unitframes-player-power-height"] + 3)
	end
end

local UpdatePlayerHealthFill = function(value)
	if vUI.UnitFrames["player"] then
		vUI.UnitFrames["player"].Health:SetReverseFill(value)
	end
end

local UpdatePlayerPowerHeight = function(value)
	if vUI.UnitFrames["player"] then
		local Frame = vUI.UnitFrames["player"]
		
		Frame.Power:SetHeight(value)
		Frame:SetHeight(Settings["unitframes-player-health-height"] + value + 3)
	end
end

local UpdatePlayerPowerFill = function(value)
	if vUI.UnitFrames["player"] then
		vUI.UnitFrames["player"].Power:SetReverseFill(value)
	end
end

local UpdatePlayerCastBarSize = function()
	if _G["vUI Casting Bar"] then
		_G["vUI Casting Bar"]:SetSize(Settings["unitframes-player-cast-width"], Settings["unitframes-player-cast-height"])
		_G["vUI Casting Bar"].Icon:SetSize(Settings["unitframes-player-cast-height"], Settings["unitframes-player-cast-height"])
	end
end

local UpdatePlayerHealthColor = function(value)
	if vUI.UnitFrames["player"] then
		local Health = vUI.UnitFrames["player"].Health
		
		UF:SetHealthAttributes(Health, value)
		
		Health:ForceUpdate()
	end
end

local UpdatePlayerPowerColor = function(value)
	if vUI.UnitFrames["player"] then
		local Power = vUI.UnitFrames["player"].Power
		
		UF:SetPowerAttributes(Power, value)
		
		Power:ForceUpdate()
	end
end

local UpdatePlayerEnablePortrait = function(value)
	if vUI.UnitFrames["player"] then
		if value then
			vUI.UnitFrames["player"]:EnableElement("Portrait")
		else
			vUI.UnitFrames["player"]:DisableElement("Portrait")
		end
		
		vUI.UnitFrames["player"].Portrait:ForceUpdate()
	end
end

local UpdatePlayerEnablePVPIndicator = function(value)
	if vUI.UnitFrames["player"] then
		if value then
			vUI.UnitFrames["player"]:EnableElement("PvPIndicator")
			vUI.UnitFrames["player"].PvPIndicator:ForceUpdate()
		else
			vUI.UnitFrames["player"]:DisableElement("PvPIndicator")
			vUI.UnitFrames["player"].PvPIndicator:Hide()
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Player"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."], ReloadUI):RequiresReload(true)
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"], UpdateShowPlayerBuffs)
	left:CreateSwitch("player-enable-portrait", Settings["player-enable-portrait"], Language["Enable Portrait"], Language["Display the player unit portrait"], UpdatePlayerEnablePortrait)
	left:CreateSwitch("player-enable-pvp-indicator", Settings["player-enable-pvp-indicator"], Language["Enable PVP Indicator"], Language["Display the pvp indicator"], UpdatePlayerEnablePVPIndicator)
	
	left:CreateHeader(Language["Health"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdatePlayerHealthFill)
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar", UpdatePlayerHealthHeight)
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdatePlayerHealthColor)
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"], ReloadUI):RequiresReload(true)
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar", UpdatePlayerPowerHeight)
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdatePlayerPowerColor)
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"], ReloadUI):RequiresReload(true)
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Cast Bar"])
	right:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"], ReloadUI):RequiresReload(true)
	right:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"], UpdatePlayerCastBarSize)
	right:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"], UpdatePlayerCastBarSize)
end)