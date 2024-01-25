local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

Defaults["raid-enable"] = true
Defaults["raid-tank-enable"] = true
Defaults["raid-width"] = 78
Defaults["raid-in-range"] = 100
Defaults["raid-out-of-range"] = 50
Defaults["raid-health-height"] = 42
Defaults["raid-health-reverse"] = false
Defaults["raid-health-color"] = "CLASS"
Defaults["raid-health-orientation"] = "HORIZONTAL"
Defaults["raid-health-top"] = "[Name(10)]"
Defaults["raid-health-bottom"] = "[HealthDeficit:Short]"
Defaults["raid-health-smooth"] = true
Defaults["raid-power-enable"] = false
Defaults["raid-power-height"] = 2
Defaults["raid-power-reverse"] = false
Defaults["raid-power-color"] = "POWER"
Defaults["raid-power-smooth"] = true
Defaults["raid-x-offset"] = 2
Defaults["raid-y-offset"] = -2
Defaults["raid-units-per-column"] = 5
Defaults["raid-max-columns"] = 8
Defaults["raid-column-spacing"] = 2
Defaults["raid-point"] = "LEFT"
Defaults["raid-column-anchor"] = "TOP"
Defaults["raid-sorting-method"] = "GROUP"
Defaults["raid-show-solo"] = false
Defaults["raid-font"] = "Roboto"
Defaults["raid-font-size"] = 12
Defaults["raid-font-flags"] = ""
Defaults.RaidHealthTexture = "HydraUI 4"
Defaults.RaidPowerTexture = "HydraUI 4"
--
Defaults["raid-tank-enable"] = true
Defaults["raid-tank-width"] = 78
Defaults["raid-tank-in-range"] = 100
Defaults["raid-tanks-out-of-range"] = 50
Defaults["raid-tanks-health-height"] = 42
Defaults["raid-tanks-health-reverse"] = false
Defaults["raid-tanks-health-color"] = "CLASS"
Defaults["raid-tanks-health-orientation"] = "HORIZONTAL"
Defaults["raid-tanks-health-top"] = "[Name(10)]"
Defaults["raid-tanks-health-bottom"] = "[HealthDeficit:Short]"
Defaults["raid-tanks-health-smooth"] = true
Defaults["raid-tanks-power-enable"] = false
Defaults["raid-tanks-power-height"] = 2
Defaults["raid-tanks-power-reverse"] = false
Defaults["raid-tanks-power-color"] = "POWER"
Defaults["raid-tanks-power-smooth"] = true
Defaults["raid-tanks-x-offset"] = 2
Defaults["raid-tanks-y-offset"] = -2
Defaults["raid-tanks-units-per-column"] = 5
Defaults["raid-tanks-max-columns"] = 8
Defaults["raid-tanks-column-spacing"] = 2
Defaults["raid-tanks-point"] = "LEFT"
Defaults["raid-tanks-column-anchor"] = "TOP"
Defaults["raid-tanks-sorting-method"] = "GROUP"
Defaults["raid-tanks-show-solo"] = false
Defaults["raid-tanks-font"] = "Roboto"
Defaults["raid-tanks-font-size"] = 12
Defaults["raid-tanks-font-flags"] = ""
Defaults.RaidHealthTexture = "HydraUI 4"
Defaults.RaidPowerTexture = "HydraUI 4"
--

local UF = HydraUI:GetModule("Unit Frames")

local RaidDebuffFilter = function(self, unit, icon, name, texture, count, dtype, duration, timeLeft, caster, stealable, nameplateshow, id, canapply, boss, player)
	if boss or (count and count > 0) or (duration > 0 and timeLeft and not player and not canapply) then
		return true
	end
end

HydraUI.StyleFuncs["raid"] = function(self, unit)
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
	Health:SetHeight(Settings["raid-health-height"])
	Health:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	Health:SetReverseFill(Settings["raid-health-reverse"])
	Health:SetOrientation(Settings["raid-health-orientation"])

	local HealBar = CreateFrame("StatusBar", nil, Health)
	HealBar:SetWidth(Settings["raid-width"])
	HealBar:SetHeight(Settings["raid-health-height"])
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)

	if Settings["raid-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["raid-width"])
		AbsorbsBar:SetHeight(Settings["raid-health-height"])
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		if Settings["raid-health-reverse"] then
			AbsorbsBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end

		self.AbsorbsBar = AbsorbsBar
	end

	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetAllPoints(Health)
	HealthBG:SetTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	HealthBG.multiplier = 0.2

	local HealthDead = Health:CreateTexture(nil, "OVERLAY")
	HealthDead:SetAllPoints(Health)
	HealthDead:SetTexture(Assets:GetTexture("RenHorizonUp"))
	HealthDead:SetVertexColor(0.8, 0.8, 0.8)
	HealthDead:SetAlpha(0)
	HealthDead:SetDrawLayer("OVERLAY", 7)

	Health.DeadAnim = LibMotion:CreateAnimationGroup()

	Health.DeadAnim.In = LibMotion:CreateAnimation(HealthDead, "Fade")
	Health.DeadAnim.In:SetEasing("in")
	Health.DeadAnim.In:SetDuration(0.15)
	Health.DeadAnim.In:SetChange(0.6)
	Health.DeadAnim.In:SetGroup(Health.DeadAnim)
	Health.DeadAnim.In:SetOrder(1)

	Health.DeadAnim.Out = LibMotion:CreateAnimation(HealthDead, "Fade")
	Health.DeadAnim.Out:SetEasing("out")
	Health.DeadAnim.Out:SetDuration(0.3)
	Health.DeadAnim.Out:SetChange(0)
	Health.DeadAnim.Out:SetGroup(Health.DeadAnim)
	Health.DeadAnim.Out:SetOrder(2)

	local HealthName = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthName, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	HealthName:SetPoint("BOTTOM", Health, "CENTER", 0, 1)
	HealthName:SetJustifyH("CENTER")

	local HealthBottom = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthBottom, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	HealthBottom:SetPoint("TOP", Health, "CENTER", 0, -1)
	HealthBottom:SetJustifyH("CENTER")

	-- Attributes
	Health.colorDisconnected = true
	Health.Smooth = true

	UF:SetHealthAttributes(Health, Settings["raid-health-color"])

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["raid-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings.RaidPowerTexture))
	Power:SetReverseFill(Settings["raid-power-reverse"])

	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings.RaidPowerTexture))
	PowerBG:SetAlpha(0.2)

	-- Attributes
	Power.frequentUpdates = true

	UF:SetPowerAttributes(Power, Settings["raid-power-color"])

	if UF.BuffIDs[HydraUI.UserClass] then
		local Auras = CreateFrame("Frame", nil, Health)
		Auras:SetPoint("TOPLEFT", Health, 2, -2)
		Auras:SetPoint("BOTTOMRIGHT", Health, -2, 2)
		Auras:SetFrameLevel(10)
		Auras:SetFrameStrata("HIGH")
		Auras.presentAlpha = 1
		Auras.missingAlpha = 0
		Auras.strictMatching = true
		Auras.icons = {}
		Auras.PostCreateIcon = UF.PostCreateAuraWatchIcon

		for key, spell in next, UF.BuffIDs[HydraUI.UserClass] do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon.strictMatching = true
			Icon:SetSize(8, 8)
			Icon:SetPoint(spell[2], 0, 0)

			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(Assets:GetTexture("Blank"))

			local BG = Icon:CreateTexture(nil, "BORDER")
			BG:SetPoint("TOPLEFT", Icon, -1, 1)
			BG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
			BG:SetTexture(Assets:GetTexture("Blank"))
			BG:SetVertexColor(0, 0, 0)

			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			HydraUI:SetFontInfo(Count, Settings["raid-font"], 10)
			Count:SetPoint("CENTER", unpack(UF.AuraOffsets[spell[2]]))
			Icon.count = Count

			Auras.icons[spell[1]] = Icon
		end

		self.AuraWatch = Auras
	end

	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", Health)
	Debuffs:SetSize(24, 24)
	Debuffs:SetPoint("BOTTOM", self, 0, 2)
	Debuffs.size = 24
	Debuffs.num = 1
	Debuffs.spacing = 0
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "DOWN"
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.CustomFilter = RaidDebuffFilter
	self.Debuffs = Debuffs

	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(HydraUI:HexToRGB("FFEB3B"))
    Leader:Hide()

	-- Assist
    local Assist = Health:CreateTexture(nil, "OVERLAY")
    Assist:SetSize(16, 16)
    Assist:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Assist:SetTexture(Assets:GetTexture("Assist"))
    Assist:SetVertexColor(HydraUI:HexToRGB("FFEB3B"))
    Assist:Hide()
	
	-- MT/MA
	local RaidRoleIndicator = Health:CreateTexture(nil, "OVERLAY")
	RaidRoleIndicator:SetSize(16, 16)
	RaidRoleIndicator:SetPoint("LEFT", Health, "TOPLEFT", 21, 0)

	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetSize(16, 16)
    ReadyCheck:SetPoint("LEFT", Health, 2, 0)

    -- Phase
    local PhaseIndicator = CreateFrame("Frame", nil, Health)
    PhaseIndicator:SetSize(16, 16)
    PhaseIndicator:SetPoint("LEFT", Health, 2, 0)
    PhaseIndicator:EnableMouse(true)

	PhaseIndicator.Icon = PhaseIndicator:CreateTexture(nil, "OVERLAY")
	PhaseIndicator.Icon:SetAllPoints()

	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")

    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("LEFT", Health, 2, 0)

	-- Role
	local RoleIndicator = Health:CreateTexture(nil, "OVERLAY")
	RoleIndicator:SetSize(16, 16)
	RoleIndicator:SetPoint("LEFT", Health, 2, 0)

	-- Dispels
	local Dispel = CreateFrame("Frame", nil, Health, "BackdropTemplate")
	Dispel:SetSize(20, 20)
	Dispel:SetPoint("CENTER", Health, 0, 0)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(HydraUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)

	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)

	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)

	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK")
	HydraUI:SetFontInfo(Dispel.count, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	Dispel.count:SetPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	Dispel.count:SetDrawLayer("ARTWORK", 7)

	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Assets:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)

	self:Tag(HealthName, Settings["raid-health-top"])
	self:Tag(HealthBottom, Settings["raid-health-bottom"])

	self.Range = {
		insideAlpha = Settings["raid-in-range"] / 100,
		outsideAlpha = Settings["raid-out-of-range"] / 100,
	}

	self.Health = Health
	self.Health.bg = HealthBG
	self.HealBar = HealBar
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthName = HealthName
	self.HealthBottom = HealthBottom
	self.Dispel = Dispel
	self.LeaderIndicator = Leader
	self.AssistantIndicator = Assist
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
	self.RaidTargetIndicator = RaidTarget
	self.GroupRoleIndicator = RoleIndicator
	self.RaidRoleIndicator = RaidRoleIndicator
	self.PhaseIndicator = PhaseIndicator
end

--tank
HydraUI.StyleFuncs["tank"] = function(self, unit)
	-- General
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
	Health:SetHeight(Settings["raid-tanks-health-height"])
	Health:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	Health:SetReverseFill(Settings["raid-tanks-health-reverse"])
	Health:SetOrientation(Settings["raid-tanks-health-orientation"])

	local HealBar = CreateFrame("StatusBar", nil, Health)
	HealBar:SetWidth(Settings["raid-tanks-width"])
	HealBar:SetHeight(Settings["raid-tanks-health-height"])
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)

	if Settings["raid-tanks-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["raid-tanks-width"])
		AbsorbsBar:SetHeight(Settings["raid-tanks-health-height"])
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings.RaidHealthTexture))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		if Settings["raid-tanks-health-reverse"] then
			AbsorbsBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
		else
			AbsorbsBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		end

		self.AbsorbsBar = AbsorbsBar
	end

	local HealthBG = self:CreateTexture(nil, "BORDER")
	HealthBG:SetAllPoints(Health)
	HealthBG:SetTexture(Assets:GetTexture(Settings.RaidHealthTexture))
	HealthBG.multiplier = 0.2

	local HealthDead = Health:CreateTexture(nil, "OVERLAY")
	HealthDead:SetAllPoints(Health)
	HealthDead:SetTexture(Assets:GetTexture("RenHorizonUp"))
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

	local HealthName = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthName, Settings["raid-tanks-font"], Settings["raid-tanks-font-size"], Settings["raid-tanks-font-flags"])
	HealthName:SetPoint("BOTTOM", Health, "CENTER", 0, 1)
	HealthName:SetJustifyH("CENTER")

	local HealthBottom = Health:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(HealthBottom, Settings["raid-tanks-font"], Settings["raid-tanks-font-size"], Settings["raid-tanks-font-flags"])
	HealthBottom:SetPoint("TOP", Health, "CENTER", 0, -1)
	HealthBottom:SetJustifyH("CENTER")

	-- Attributes
	Health.colorDisconnected = true
	Health.Smooth = true

	UF:SetHealthAttributes(Health, Settings["raid-tanks-health-color"])

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetPoint("BOTTOMLEFT", self, 1, 1)
	Power:SetPoint("BOTTOMRIGHT", self, -1, 1)
	Power:SetHeight(Settings["raid-tanks-power-height"])
	Power:SetStatusBarTexture(Assets:GetTexture(Settings.RaidPowerTexture))
	Power:SetReverseFill(Settings["raid-tanks-power-reverse"])

	local PowerBG = Power:CreateTexture(nil, "BORDER")
	PowerBG:SetPoint("TOPLEFT", Power, 0, 0)
	PowerBG:SetPoint("BOTTOMRIGHT", Power, 0, 0)
	PowerBG:SetTexture(Assets:GetTexture(Settings.RaidPowerTexture))
	PowerBG:SetAlpha(0.2)

	-- Attributes
	Power.frequentUpdates = true

	UF:SetPowerAttributes(Power, Settings["raid-tanks-power-color"])

	if UF.BuffIDs[HydraUI.UserClass] then
		local Auras = CreateFrame("Frame", nil, Health)
		Auras:SetPoint("TOPLEFT", Health, 2, -2)
		Auras:SetPoint("BOTTOMRIGHT", Health, -2, 2)
		Auras:SetFrameLevel(10)
		Auras:SetFrameStrata("HIGH")
		Auras.presentAlpha = 1
		Auras.missingAlpha = 0
		Auras.strictMatching = true
		Auras.icons = {}
		Auras.PostCreateIcon = UF.PostCreateAuraWatchIcon

		for key, spell in next, UF.BuffIDs[HydraUI.UserClass] do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon.strictMatching = true
			Icon:SetSize(8, 8)
			Icon:SetPoint(spell[2], 0, 0)

			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(Assets:GetTexture("Blank"))

			local BG = Icon:CreateTexture(nil, "BORDER")
			BG:SetPoint("TOPLEFT", Icon, -1, 1)
			BG:SetPoint("BOTTOMRIGHT", Icon, 1, -1)
			BG:SetTexture(Assets:GetTexture("Blank"))
			BG:SetVertexColor(0, 0, 0)

			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			HydraUI:SetFontInfo(Count, Settings["raid-tanks-font"], 10)
			Count:SetPoint("CENTER", unpack(UF.AuraOffsets[spell[2]]))
			Icon.count = Count

			Auras.icons[spell[1]] = Icon
		end

		self.AuraWatch = Auras
	end

	-- Debuffs
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", Health)
	Debuffs:SetSize(24, 24)
	Debuffs:SetPoint("BOTTOM", self, 0, 2)
	Debuffs.size = 24
	Debuffs.num = 1
	Debuffs.spacing = 0
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs.tooltipAnchor = "ANCHOR_TOP"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "DOWN"
	Debuffs.PostCreateIcon = UF.PostCreateIcon
	Debuffs.PostUpdateIcon = UF.PostUpdateIcon
	Debuffs.CustomFilter = RaidDebuffFilter
	self.Debuffs = Debuffs

	-- Leader
    local Leader = Health:CreateTexture(nil, "OVERLAY")
    Leader:SetSize(16, 16)
    Leader:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Leader:SetTexture(Assets:GetTexture("Leader"))
    Leader:SetVertexColor(HydraUI:HexToRGB("FFEB3B"))
    Leader:Hide()

	-- Assist
    local Assist = Health:CreateTexture(nil, "OVERLAY")
    Assist:SetSize(16, 16)
    Assist:SetPoint("LEFT", Health, "TOPLEFT", 3, 0)
    Assist:SetTexture(Assets:GetTexture("Assist"))
    Assist:SetVertexColor(HydraUI:HexToRGB("FFEB3B"))
    Assist:Hide()

	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetSize(16, 16)
    ReadyCheck:SetPoint("LEFT", Health, 2, 0)

    -- Phase
    local PhaseIndicator = CreateFrame("Frame", nil, Health)
    PhaseIndicator:SetSize(16, 16)
    PhaseIndicator:SetPoint("LEFT", Health, 2, 0)
    PhaseIndicator:EnableMouse(true)

	PhaseIndicator.Icon = PhaseIndicator:CreateTexture(nil, "OVERLAY")
	PhaseIndicator.Icon:SetAllPoints()

	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, "OVERLAY")
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")

    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("LEFT", Health, 2, 0)

	-- Role
	local RoleIndicator = Health:CreateTexture(nil, "OVERLAY")
	RoleIndicator:SetSize(16, 16)
	RoleIndicator:SetPoint("LEFT", Health, 2, 0)

	-- Dispels
	local Dispel = CreateFrame("Frame", nil, Health, "BackdropTemplate")
	Dispel:SetSize(20, 20)
	Dispel:SetPoint("CENTER", Health, 0, 0)
	Dispel:SetFrameLevel(Health:GetFrameLevel() + 20)
	Dispel:SetBackdrop(HydraUI.BackdropAndBorder)
	Dispel:SetBackdropColor(0, 0, 0)

	Dispel.icon = Dispel:CreateTexture(nil, "ARTWORK")
	Dispel.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	Dispel.icon:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.icon:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)

	Dispel.cd = CreateFrame("Cooldown", nil, Dispel, "CooldownFrameTemplate")
	Dispel.cd:SetPoint("TOPLEFT", Dispel, 1, -1)
	Dispel.cd:SetPoint("BOTTOMRIGHT", Dispel, -1, 1)
	Dispel.cd:SetHideCountdownNumbers(true)
	Dispel.cd:SetDrawEdge(false)

	Dispel.count = Dispel.cd:CreateFontString(nil, "ARTWORK")
	HydraUI:SetFontInfo(Dispel.count, Settings["raid-tanks-font"], Settings["raid-tanks-font-size"], Settings["raid-tanks-font-flags"])
	Dispel.count:SetPoint("BOTTOMRIGHT", Dispel, "BOTTOMRIGHT", -3, 3)
	Dispel.count:SetTextColor(1, 1, 1)
	Dispel.count:SetJustifyH("RIGHT")
	Dispel.count:SetDrawLayer("ARTWORK", 7)

	Dispel.bg = Dispel:CreateTexture(nil, "BACKGROUND")
	Dispel.bg:SetPoint("TOPLEFT", Dispel, -1, 1)
	Dispel.bg:SetPoint("BOTTOMRIGHT", Dispel, 1, -1)
	Dispel.bg:SetTexture(Assets:GetTexture("Blank"))
	Dispel.bg:SetVertexColor(0, 0, 0)

	self:Tag(HealthName, Settings["raid-tanks-health-top"])
	self:Tag(HealthBottom, Settings["raid-tanks-health-bottom"])

	self.Range = {
		insideAlpha = Settings["raid-tanks-in-range"] / 100,
		outsideAlpha = Settings["raid-tanks-out-of-range"] / 100,
	}

	self.Health = Health
	self.Health.bg = HealthBG
	self.HealBar = HealBar
	self.Power = Power
	self.Power.bg = PowerBG
	self.HealthName = HealthName
	self.HealthBottom = HealthBottom
	self.Dispel = Dispel
	self.LeaderIndicator = Leader
	self.AssistantIndicator = Assist
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
	self.RaidTargetIndicator = RaidTarget
	self.GroupRoleIndicator = RoleIndicator
	self.RaidRoleIndicator = RaidRoleIndicator
	self.PhaseIndicator = PhaseIndicator
end


HydraUI.StyleFuncs["raidpet"] = function(self, unit)
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
	Health:SetHeight(Settings["raid-pets-health-height"])
	Health:SetFrameLevel(5)
	Health:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Health:SetReverseFill(Settings["raid-pets-health-reverse"])
	Health:SetOrientation(Settings["raid-pets-health-orientation"])

	local HealBar = CreateFrame("StatusBar", nil, self)
	HealBar:SetAllPoints(Health)
	HealBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	HealBar:SetStatusBarColor(0, 0.48, 0)
	HealBar:SetFrameLevel(Health:GetFrameLevel() - 1)

	if Settings["raid-health-reverse"] then
		HealBar:SetPoint("RIGHT", Health:GetStatusBarTexture(), "LEFT", 0, 0)
	else
		HealBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	if HydraUI.IsMainline then
		local AbsorbsBar = CreateFrame("StatusBar", nil, Health)
		AbsorbsBar:SetWidth(Settings["raid-width"])
		AbsorbsBar:SetHeight(Settings["raid-pets-health-height"])
		AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		AbsorbsBar:SetStatusBarColor(0, 0.66, 1)
		AbsorbsBar:SetFrameLevel(Health:GetFrameLevel() - 2)

		if Settings["raid-health-reverse"] then
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
	HydraUI:SetFontInfo(HealthMiddle, Settings["raid-font"], Settings["raid-font-size"], Settings["raid-font-flags"])
	HealthMiddle:SetPoint("CENTER", Health, 0, 0)
	HealthMiddle:SetJustifyH("CENTER")

	-- Attributes
	Health.frequentUpdates = true
	Health.colorDisconnected = true
	Health.Smooth = true

	UF:SetHealthAttributes(Health, Settings["raid-pets-health-color"])

	-- Target Icon
	local RaidTarget = Health:CreateTexture(nil, 'OVERLAY')
	RaidTarget:SetSize(16, 16)
	RaidTarget:SetPoint("CENTER", Health, "TOP")

	-- Ready Check
    local ReadyCheck = Health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetSize(16, 16)
    ReadyCheck:SetPoint("LEFT", Health, 2, 0)

    -- Phase
    local PhaseIndicator = CreateFrame("Frame", nil, Health)
    PhaseIndicator:SetSize(16, 16)
    PhaseIndicator:SetPoint("TOPRIGHT", Health, 0, 0)
    PhaseIndicator:EnableMouse(true)

	PhaseIndicator.Icon = PhaseIndicator:CreateTexture(nil, "OVERLAY")
	PhaseIndicator.Icon:SetAllPoints()

    -- Resurrect
	local Resurrect = Health:CreateTexture(nil, "OVERLAY")
	Resurrect:SetSize(16, 16)
	Resurrect:SetPoint("LEFT", Health, 2, 0)

	-- Tags
	self:Tag(HealthMiddle, "[Name10]")

	self.Range = {
		insideAlpha = Settings["raid-in-range"] / 100,
		outsideAlpha = Settings["raid-out-of-range"] / 100,
	}

	self.Health = Health
	self.HealBar = HealBar
	self.Health.bg = HealthBG
	self.HealthMiddle = HealthMiddle
	self.ReadyCheckIndicator = ReadyCheck
	self.ResurrectIndicator = Resurrect
	self.RaidTargetIndicator = RaidTarget
	self.PhaseIndicator = PhaseIndicator
end

local UpdateRaidAnchorSize = function()
	UF.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
	UF.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
end

local UpdateTankAnchorSize = function()
	UF.RaidAnchor:SetWidth((floor(40 / Settings["raid-tanks-max-columns"]) * Settings["raid-tanks-width"] + (floor(40 / Settings["raid-tanks-max-columns"]) * Settings["raid-tanks-x-offset"] - 2)))
	UF.RaidAnchor:SetHeight((Settings["raid-tanks-health-height"] + Settings["raid-tanks-power-height"]) * (Settings["raid-tanks-max-columns"] + (Settings["raid-tanks-y-offset"])) - 1)
end

local UpdateRaidPetAnchorSize = function()
	UF.RaidPetAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
	UF.RaidPetAnchor:SetHeight(Settings["raid-pets-health-height"] * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
end

local UpdateRaidWidth = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				Unit:SetWidth(value)
			end
		end

		UpdateRaidAnchorSize()
	end
end

local UpdateRaidHealthHeight = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				Unit:SetHeight(value + Settings["raid-power-height"] + 3)
				Unit.Health:SetHeight(value)
			end
		end

		UpdateRaidAnchorSize()
	end
end

local UpdateRaidHealthColor = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				UF:SetHealthAttributes(Unit.Health, value)

				Unit.Health:ForceUpdate()
			end
		end
	end
end

local UpdateRaidHealthOrientation = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				Unit.Health:SetOrientation(value)
			end
		end
	end
end

local UpdateRaidHealthReverseFill = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
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
end

local UpdateEnableRaidPower = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				if value then
					Unit:EnableElement("Power")
					Unit:SetHeight(Settings["raid-health-height"] + Settings["raid-power-height"] + 3)
				else
					Unit:DisableElement("Power")
					Unit:SetHeight(Settings["raid-health-height"] + 2)
				end
			end
		end
	end
end

local UpdateRaidPowerHeight = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				Unit:SetHeight(value + Settings["raid-health-height"] + 3)
				Unit.Power:SetHeight(value)
			end
		end

		UpdateRaidAnchorSize()
	end
end

local UpdateRaidPowerReverseFill = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				Unit.Power:SetReverseFill(value)
			end
		end
	end
end

local UpdateRaidPowerColor = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				UF:SetPowerAttributes(Unit.Power, value)

				Unit.Power:ForceUpdate()
			end
		end
	end
end

local UpdateRaidXOffset = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("xoffset", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidYOffset = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("yoffset", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidUnitsPerColumn = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("unitsPerColumn", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidMaxColumns = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("maxColumns", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidColumnSpacing = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("columnSpacing", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidColumnAnchor = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("columnAnchorPoint", value)

	UpdateRaidAnchorSize()
end

local UpdateRaidPoint = function(value)
	HydraUI.UnitFrames["raid"]:SetAttribute("point", value)

	UpdateRaidAnchorSize()
end

--
local UpdateTankWidth = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				Unit:SetWidth(value)
			end
		end

		UpdateTankAnchorSize()
	end
end

local UpdateTankHealthHeight = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				Unit:SetHeight(value + Settings["raid-tanks-power-height"] + 3)
				Unit.Health:SetHeight(value)
			end
		end

		UpdateTankAnchorSize()
	end
end

local UpdateTankHealthColor = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				UF:SetHealthAttributes(Unit.Health, value)

				Unit.Health:ForceUpdate()
			end
		end
	end
end

local UpdateTankHealthOrientation = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				Unit.Health:SetOrientation(value)
			end
		end
	end
end

local UpdateTankHealthReverseFill = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
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
end

local UpdateEnableRaidPower = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				if value then
					Unit:EnableElement("Power")
					Unit:SetHeight(Settings["raid-tanks-health-height"] + Settings["raid-tanks-power-height"] + 3)
				else
					Unit:DisableElement("Power")
					Unit:SetHeight(Settings["raid-tanks-health-height"] + 2)
				end
			end
		end
	end
end

local UpdateTankPowerHeight = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				Unit:SetHeight(value + Settings["raid-tanks-health-height"] + 3)
				Unit.Power:SetHeight(value)
			end
		end

		UpdateTankAnchorSize()
	end
end

local UpdateTankPowerReverseFill = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				Unit.Power:SetReverseFill(value)
			end
		end
	end
end

local UpdateTankPowerColor = function(value)
	if HydraUI.UnitFrames["Tank"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["Tank"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["Tank"]:GetChildren())

			if Unit then
				UF:SetPowerAttributes(Unit.Power, value)

				Unit.Power:ForceUpdate()
			end
		end
	end
end

local UpdateTankXOffset = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("xoffset", value)

	UpdateTankAnchorSize()
end

local UpdateTankYOffset = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("yoffset", value)

	UpdateTankAnchorSize()
end

local UpdateTankUnitsPerColumn = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("unitsPerColumn", value)

	UpdateTankAnchorSize()
end

local UpdateTankMaxColumns = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("maxColumns", value)

	UpdateTankAnchorSize()
end

local UpdateTankColumnSpacing = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("columnSpacing", value)

	UpdateTankAnchorSize()
end

local UpdateTankColumnAnchor = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("columnAnchorPoint", value)

	UpdateTankAnchorSize()
end

local UpdateTankPoint = function(value)
	HydraUI.UnitFrames["Tank"]:SetAttribute("point", value)

	UpdateTankAnchorSize()
end

--


local UpdateRaidSortingMethod = function(value)
	if (value == "CLASS") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "CLASS")
	elseif (value == "ROLE") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "ASSIGNEDROLE")
	elseif (value == "NAME") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", nil)
	elseif (value == "MTMA") then
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "ROLE")
	else -- GROUP
		HydraUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		HydraUI.UnitFrames["raid"]:SetAttribute("sortMethod", "INDEX")
		HydraUI.UnitFrames["raid"]:SetAttribute("groupBy", "GROUP")
	end
	HydraUI.UnitFrames["tank"]:SetAttribute("groupFilter", "MAINTANK")
end

local Testing = false

local TestRaid = function()
	local Header = _G["HydraUI Raid"]
	local Pets = _G["HydraUI Raid Pets"]

	if Testing then
		if Header then
			Header:SetAttribute("isTesting", false)

			if (Header:GetAttribute("startingIndex") ~= -24) then
				Header:SetAttribute("startingIndex", -24)
			end

			for i = 1, select("#", Header:GetChildren()) do
				local Frame = select(i, Header:GetChildren())

				UnregisterUnitWatch(Frame)
				Frame:Hide()
			end
		end

		if Pets then
			Pets:SetAttribute("isTesting", false)

			if (Pets:GetAttribute("startingIndex") ~= -24) then
				Pets:SetAttribute("startingIndex", -24)
			end

			for i = 1, select("#", Pets:GetChildren()) do
				local Frame = select(i, Pets:GetChildren())

				UnregisterUnitWatch(Frame)
				Frame:Hide()
			end
		end

		Testing = false
	else
		if Header then
			Header:SetAttribute("isTesting", true)

			if (Header:GetAttribute("startingIndex") ~= -24) then
				Header:SetAttribute("startingIndex", -24)
			end

			for i = 1, select("#", Header:GetChildren()) do
				local Frame = select(i, Header:GetChildren())

				Frame.unit = "player"
				UnregisterUnitWatch(Frame)
				RegisterUnitWatch(Frame, true)
				Frame:Show()
			end
		end

		if Pets then
			Pets:SetAttribute("isTesting", true)

			if (Pets:GetAttribute("startingIndex") ~= -24) then
				Pets:SetAttribute("startingIndex", -24)
			end

			for i = 1, select("#", Pets:GetChildren()) do
				local Frame = select(i, Pets:GetChildren())

				Frame.unit = UnitExists("pet") and "pet" or "player"
				UnregisterUnitWatch(Frame)
				RegisterUnitWatch(Frame, true)
				Frame:Show()
			end
		end

		Testing = true
	end
end

local UpdateShowSolo = function(value)
	_G["HydraUI Raid"]:SetAttribute("showSolo", value)
end

local UpdateHealthTexture = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			Unit.Health:SetStatusBarTexture(Assets:GetTexture(value))
			Unit.Health.bg:SetTexture(Assets:GetTexture(value))
			Unit.HealBar:SetStatusBarTexture(Assets:GetTexture(value))

			if Unit.AbsorbsBar then
				Unit.AbsorbsBar:SetStatusBarTexture(Assets:GetTexture(value))
			end
		end
	end
end

local UpdatePowerTexture = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			Unit.Power:SetStatusBarTexture(Assets:GetTexture(value))
			Unit.Power.bg:SetTexture(Assets:GetTexture(value))
		end
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Raid"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("raid-enable", Settings["raid-enable"], Language["Enable Raid Module"], Language["Enable the raid frames module"], ReloadUI):RequiresReload(true)
	--left:CreateSwitch("raid-tank-enable", Settings["raid-tank-enable"], Language["Enable Raid Tank Frames"], Language["Enable the Raid tank frames module"], ReloadUI):RequiresReload(true)

	left:CreateHeader(Language["Raid Size"])
	left:CreateSlider("raid-width", Settings["raid-width"], 40, 200, 1, Language["Width"], Language["Set the width of the raid frames"], UpdateRaidWidth, nil)

	left:CreateHeader(Language["Font"])
	left:CreateDropdown("raid-font", Settings["raid-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the raid frames"], nil, "Font")
	left:CreateSlider("raid-font-size", Settings["raid-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the raid frames"])
	left:CreateDropdown("raid-font-flags", Settings["raid-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the raid frames"])

	right:CreateHeader(Language["Test Raid Frames"])
	right:CreateButton("", Language["Test"], Language["Test Raid"], Language["Test the raid frames"], TestRaid)

	right:CreateHeader(Language["Health"])
	right:CreateSlider("raid-health-height", Settings["raid-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of raid health bars"], UpdateRaidHealthHeight)
	right:CreateDropdown("raid-health-color", Settings["raid-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateRaidHealthColor)
	right:CreateDropdown("raid-health-orientation", Settings["raid-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"], UpdateRaidHealthOrientation)
	right:CreateSwitch("raid-health-reverse", Settings["raid-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateRaidHealthReverseFill)
	right:CreateDropdown("RaidHealthTexture", Settings.RaidHealthTexture, Assets:GetTextureList(), Language["Health Texture"], "", UpdateHealthTexture, "Texture")

	right:CreateHeader(Language["Power"])
	right:CreateSwitch("raid-power-enable", Settings["raid-power-enable"], Language["Enable Power Bar"], Language["Enable the power bar"], UpdateEnableRaidPower)
	right:CreateSwitch("raid-power-reverse", Settings["raid-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateRaidPowerReverseFill)
	right:CreateSlider("raid-power-height", Settings["raid-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of raid power bars"], UpdateRaidPowerHeight)
	right:CreateDropdown("raid-power-color", Settings["raid-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateRaidPowerColor)
	right:CreateDropdown("RaidPowerTexture", Settings.RaidPowerTexture, Assets:GetTextureList(), Language["Power Texture"], "", UpdatePowerTexture, "Texture")

	right:CreateHeader(Language["Text"])
	right:CreateInput("raid-health-top", Settings["raid-health-top"], Language["Top Text"], Language["Set the text on the top of the raid frame"], ReloadUI):RequiresReload(true)
	right:CreateInput("raid-health-bottom", Settings["raid-health-bottom"], Language["Bottom Text"], Language["Set the text on the bottom of the raid frame"], ReloadUI):RequiresReload(true)

	left:CreateHeader(Language["Range Opacity"])
	left:CreateSlider("raid-in-range", Settings["raid-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of raid members within range of you"])
	left:CreateSlider("raid-out-of-range", Settings["raid-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of raid members out of your range"])

	left:CreateHeader(Language["Attributes"])
	left:CreateSwitch("raid-show-solo", Settings["raid-show-solo"], Language["Show Solo"], Language["Display the raid frames while not in a group"], UpdateShowSolo)
	left:CreateSlider("raid-x-offset", Settings["raid-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of raid units from eachother"], UpdateRaidXOffset)
	left:CreateSlider("raid-y-offset", Settings["raid-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of raid units from eachother"], UpdateRaidYOffset)
	left:CreateSlider("raid-units-per-column", Settings["raid-units-per-column"], 1, 40, 1, Language["Units Per Column"], Language["Set the maximum number of units per column"], UpdateRaidUnitsPerColumn)
	left:CreateSlider("raid-max-columns", Settings["raid-max-columns"], 1, 40, 1, Language["Max Columns"], Language["Set the maximum number of visible columns of raid units"], UpdateRaidMaxColumns)
	left:CreateSlider("raid-column-spacing", Settings["raid-column-spacing"], -10, 10, 1, Language["Column Spacing"], Language["Set the spacing between columns of raid units"], UpdateRaidColumnSpacing)
	left:CreateDropdown("raid-sorting-method", Settings["raid-sorting-method"], {[Language["Group"]] = "GROUP", [Language["Name"]] = "NAME", [Language["Class"]] = "CLASS", [Language["Role"]] = "ROLE", [Language["Main Tank"]] = "MTMA"}, Language["Sorting Method"], Language["Set how the raid units are sorted"], UpdateRaidSortingMethod)
	left:CreateDropdown("raid-point", Settings["raid-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new raid frames will connect to previous ones"], UpdateRaidPoint)
	left:CreateDropdown("raid-column-anchor", Settings["raid-column-anchor"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["New Column Anchor"], Language["Set where new columns should anchor to"], ReloadUI):RequiresReload(true)
end)
HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Tank"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("raid-tank-enable", Settings["raid-tank-enable"], Language["Enable Raid Tank Frames"], Language["Enable the Raid tank frames module"], ReloadUI):RequiresReload(true)
end)	


--
--HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Tank"], Language["Unit Frames"], function(left, right)
--	left:CreateHeader(Language["Enable"])
--	left:CreateSwitch("raid-tank-enable", Settings["raid-tank-enable"], Language["Enable Raid Tank Frames"], Language["Enable the Raid tank frames module"], ReloadUI):RequiresReload(true)
	
--	left:CreateHeader(Language["Raid Size"])
--	left:CreateSlider("raid-tanks-width", Settings["raid-tanks-width"], 40, 200, 1, Language["Width"], Language["Set the width of the raid frames"], UpdateTankWidth, nil)

--	left:CreateHeader(Language["Font"])
--	left:CreateDropdown("raid-tanks-font", Settings["raid-tanks-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the raid frames"], nil, "Font")
--	left:CreateSlider("raid-tanks-font-size", Settings["raid-tanks-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the raid frames"])
--	left:CreateDropdown("raid-tanks-font-flags", Settings["raid-tanks-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the raid frames"])

	--right:CreateHeader(Language["Test Raid Frames"])
	--right:CreateButton("", Language["Test"], Language["Test Raid"], Language["Test the raid frames"], TestRaid)

--	right:CreateHeader(Language["Health"])
--	right:CreateSlider("raid-tanks-health-height", Settings["raid-tanks-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of raid health bars"], UpdateTankHealthHeight)
--	right:CreateDropdown("raid-tanks-health-color", Settings["raid-tanks-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"], UpdateTankHealthColor)
--	right:CreateDropdown("raid-tanks-health-orientation", Settings["raid-tanks-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"], UpdateTankHealthOrientation)
--	right:CreateSwitch("raid-tanks-health-reverse", Settings["raid-tanks-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"], UpdateTankHealthReverseFill)
--	right:CreateDropdown("RaidHealthTexture", Settings.RaidHealthTexture, Assets:GetTextureList(), Language["Health Texture"], "", UpdateHealthTexture, "Texture")

--	right:CreateHeader(Language["Power"])
--	right:CreateSwitch("raid-tanks-power-enable", Settings["raid-tanks-power-enable"], Language["Enable Power Bar"], Language["Enable the power bar"], UpdateEnableRaidPower)
--	right:CreateSwitch("raid-tanks-power-reverse", Settings["raid-tanks-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdateTankPowerReverseFill)
--	right:CreateSlider("raid-tanks-power-height", Settings["raid-tanks-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of raid power bars"], UpdateTankPowerHeight)
	--right:CreateDropdown("raid-tanks-power-color", Settings["raid-tanks-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"], UpdateTankPowerColor)
--	right:CreateDropdown("RaidPowerTexture", Settings.RaidPowerTexture, Assets:GetTextureList(), Language["Power Texture"], "", UpdatePowerTexture, "Texture")

--	right:CreateHeader(Language["Text"])
--	right:CreateInput("raid-tanks-health-top", Settings["raid-tanks-health-top"], Language["Top Text"], Language["Set the text on the top of the raid frame"], ReloadUI):RequiresReload(true)
--	right:CreateInput("raid-tanks-health-bottom", Settings["raid-tanks-health-bottom"], Language["Bottom Text"], Language["Set the text on the bottom of the raid frame"], ReloadUI):RequiresReload(true)

--	left:CreateHeader(Language["Range Opacity"])
--	left:CreateSlider("raid-tanks-in-range", Settings["raid-tanks-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of raid members within range of you"])
--	left:CreateSlider("raid-tanks-out-of-range", Settings["raid-tanks-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of raid members out of your range"])

--	left:CreateHeader(Language["Attributes"])
	--left:CreateSwitch("raid-tanks-show-solo", Settings["raid-tanks-show-solo"], Language["Show Solo"], Language["Display the raid frames while not in a group"], UpdateShowSolo)
--	left:CreateSlider("raid-tanks-x-offset", Settings["raid-tanks-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of raid units from eachother"], UpdateTankXOffset)
--	left:CreateSlider("raid-tanks-y-offset", Settings["raid-tanks-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of raid units from eachother"], UpdateTankYOffset)
--	left:CreateSlider("raid-tanks-units-per-column", Settings["raid-tanks-units-per-column"], 1, 40, 1, Language["Units Per Column"], Language["Set the maximum number of units per column"], UpdateTankUnitsPerColumn)
--	left:CreateSlider("raid-tanks-max-columns", Settings["raid-tanks-max-columns"], 1, 40, 1, Language["Max Columns"], Language["Set the maximum number of visible columns of raid units"], UpdateTankMaxColumns)
--	left:CreateSlider("raid-tanks-column-spacing", Settings["raid-tanks-column-spacing"], -10, 10, 1, Language["Column Spacing"], Language["Set the spacing between columns of raid units"], UpdateTankColumnSpacing)
	--left:CreateDropdown("raid-tanks-sorting-method", Settings["raid-tanks-sorting-method"], {[Language["Group"]] = "GROUP", [Language["Name"]] = "NAME", [Language["Class"]] = "CLASS", [Language["Role"]] = "ROLE", [Language["Main Tank"]] = "MTMA"}, Language["Sorting Method"], Language["Set how the raid units are sorted"], UpdateTankSortingMethod)
--	left:CreateDropdown("raid-tanks-point", Settings["raid-tanks-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new raid frames will connect to previous ones"], UpdateTankPoint)
--	left:CreateDropdown("raid-tanks-column-anchor", Settings["raid-tanks-column-anchor"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["New Column Anchor"], Language["Set where new columns should anchor to"], ReloadUI):RequiresReload(true)
--end)
--]]
