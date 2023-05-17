local addon, ns = ...
local HydraUI, Language, Assets, Settings, Defaults = ns:get()

local oUF = ns.oUF or oUF

local select = select
local find = string.find
local GetTime = GetTime
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local Class, Colors, _

Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-player-debuffs"] = true
Defaults["unitframes-show-target-buffs"] = true
Defaults["unitframes-show-target-debuffs"] = true
Defaults["unitframes-show-druid-mana"] = true
Defaults["unitframes-font"] = "Roboto"
Defaults["unitframes-font-size"] = 12
Defaults["unitframes-font-flags"] = ""
Defaults["unitframes-display-aura-timers"] = true

local UF = HydraUI:NewModule("Unit Frames")

HydraUI.UnitFrames = {}
HydraUI.StyleFuncs = {}

local Hider = CreateFrame("Frame", nil, HydraUI.UIParent, "SecureHandlerStateTemplate")
Hider:Hide()

local Ignore = {}

if HydraUI.IsMainline then
	Ignore[GetSpellInfo(57724)] = true -- Sated
	Ignore[GetSpellInfo(288293)] = true -- Temporal Displacement
	Ignore[GetSpellInfo(206150)] = true -- Challenger's Might
	Ignore[GetSpellInfo(206151)] = true -- Challenger's Burden
end

local CustomFilter = function(self, unit, icon, name, texture, count, dtype, duration, timeLeft, caster)
	if ((self.onlyShowPlayer and icon.isPlayer) or (not self.onlyShowPlayer and name)) and (not Ignore[name]) then
		return true
	end
end

function UF:SetHealthAttributes(health, value)
	if (value == "CLASS") then
		health.colorClass = true
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "REACTION") then
		health.colorClass = false
		health.colorReaction = true
		health.colorHealth = false
	elseif (value == "BLIZZARD") then
		health.colorClass = false
		health.colorReaction = false
		health.colorSelection = true
	elseif (value == "THREAT") then
		health.colorClass = true
		health.colorReaction = true
		health.colorSelection = false
		health.colorThreat = true
	elseif (value == "CUSTOM") then
		health.colorClass = false
		health.colorReaction = false
		health.colorHealth = true
	end
end

function UF:SetPowerAttributes(power, value)
	if (value == "POWER") then
		power.colorPower = true
		power.colorClass = false
		power.colorReaction = false
	elseif (value == "REACTION") then
		power.colorPower = false
		power.colorClass = false
		power.colorReaction = true
	elseif (value == "CLASS") then
		power.colorPower = false
		power.colorClass = true
		power.colorReaction = true
	end
end

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela

	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())

		if (Now > 0) then
			self.Time:SetText(HydraUI:AuraFormatTime(Now))
		else
			self:SetScript("OnUpdate", nil)
			self.Time:Hide()
		end

		if (Now <= 0) then
			self:SetScript("OnUpdate", nil)
			self.Time:Hide()
		end

		self.ela = 0
	end
end

UF.ThreatPostUpdate = function(self, unit, status, r, g, b)
	if (status and status > 0) then
		self:SetBackdropBorderColor(r, g, b)
	end
end

UF.NPThreatPostUpdate = function(self, unit, status, r, g, b)
	if (status and status > 0) then
		self.Top:SetVertexColor(r, g, b)
		self.Bottom:SetVertexColor(r, g, b)
	end
end

if HydraUI.IsClassic then
	local LCD = LibStub("LibClassicDurations")
	local UnitAura = UnitAura

	LCD:Register("HydraUI")

	UF.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local Name, _, _, _, Duration, Expiration, Caster, _, _, SpellID = UnitAura(unit, index, button.filter)
		local DurationNew, ExpirationNew = LCD:GetAuraDurationByUnit(unit, SpellID, Caster, Name)

		if (Duration == 0 and DurationNew) then
			Duration = DurationNew
			Expiration = ExpirationNew
		end

		button.Expiration = Expiration

		if button.cd then
			if (Duration and Duration > 0) then
				button.cd:SetCooldown(Expiration - Duration, Duration)
				button.cd:Show()
			else
				button.cd:Hide()
			end
		end

		if debuffType then
			local Color = self.__owner.colors.debuff[debuffType]

			button.DebuffType:SetBackdropBorderColor(Color[1], Color[2], Color[3])
			button.DebuffType:Show()
		else
			button.DebuffType:Hide()
		end

		if ((button.filter == "HARMFUL") and (not button.isPlayer) and debuffType) then
			button.icon:SetDesaturated(true)
		else
			button.icon:SetDesaturated(false)
		end

		if (Expiration and Expiration ~= 0) then
			button:SetScript("OnUpdate", AuraOnUpdate)
			button.Time:Show()
		else
			button.Time:Hide()
		end
	end
else
	UF.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		button.Expiration = expiration

		if button.cd then
			if (duration and duration > 0) then
				button.cd:SetCooldown(expiration - duration, duration)
				button.cd:Show()
			else
				button.cd:Hide()
			end
		end

		if (debuffType and debuffType ~= "") then
			local Color = self.__owner.colors.debuff[debuffType]

			button.DebuffType:SetBackdropBorderColor(Color[1], Color[2], Color[3])
			button.DebuffType:Show()
		else
			button.DebuffType:Hide()
		end

		if ((button.filter == "HARMFUL") and (not button.isPlayer) and debuffType) then
			button.icon:SetDesaturated(true)
		else
			button.icon:SetDesaturated(false)
		end

		if (expiration and expiration ~= 0) then
			button:SetScript("OnUpdate", AuraOnUpdate)
			button.Time:Show()
		else
			button.Time:Hide()
		end
	end
end

local CancelAuraOnMouseUp = function(aura, button)
	if ((button ~= "RightButton") or InCombatLockdown()) then
		return
	end

	CancelUnitBuff("player", aura.ID)
end

UF.PostCreateIcon = function(unit, button)
	local ID = button:GetName():match("%d+")

	if ID then
		button.ID = tonumber(ID)
		button:SetScript("OnMouseUp", CancelAuraOnMouseUp)
	end

	button.bg = button:CreateTexture(nil, "BACKGROUND")
	button.bg:SetPoint("TOPLEFT", button, 0, 0)
	button.bg:SetPoint("BOTTOMRIGHT", button, 0, 0)
	button.bg:SetColorTexture(0, 0, 0)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	button.cd:SetReverse(true)

	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	button.count:SetPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	HydraUI:SetFontInfo(button.count, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")

	button.Time = button.cd:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(button.Time, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	button.Time:SetPoint("TOPLEFT", -1, -1)
	button.Time:SetJustifyH("LEFT")

	button.DebuffType = CreateFrame("Frame", nil, button, "BackdropTemplate")
	button.DebuffType:SetPoint("TOPLEFT", 1, -1)
	button.DebuffType:SetPoint("BOTTOMRIGHT", -1, 1)
	button.DebuffType:SetBackdrop(HydraUI.Outline)
	button.DebuffType:SetFrameLevel(button:GetFrameLevel() + 3)

	if (not Settings["unitframes-display-aura-timers"]) then
		button.Time:SetParent(Hider)
	end

	button.ela = 0
end

UF.PostCastStart = function(self, unit)
	if self.notInterruptible then
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
		self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	elseif (self.ClassColor and UnitIsPlayer(unit)) then
		_, Class = UnitClass(unit)

		if Class then
			Colors = HydraUI.ClassColors[Class]

			self:SetStatusBarColor(Colors[1], Colors[2], Colors[3])
			self.bg:SetVertexColor(Colors[1], Colors[2], Colors[3])
		else
			self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
			self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
		end
	else
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
		self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
	end
end

UF.PostCastInterruptible = function(self)
	if self.notInterruptible then
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
		self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	elseif (self.ClassColor and UnitIsPlayer(unit)) then
		_, Class = UnitClass(unit)

		if Class then
			Colors = HydraUI.ClassColors[Class]

			self:SetStatusBarColor(Colors[1], Colors[2], Colors[3])
			self.bg:SetVertexColor(Colors[1], Colors[2], Colors[3])
		else
			self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
			self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
		end
	else
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
		self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
	end
end

UF.PostCastStop = function(self)
	self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-stopped"]))
	self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-stopped"]))
end

UF.PostCastFail = function(self)
	self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-interrupted"]))
	self.bg:SetVertexColor(HydraUI:HexToRGB(Settings["color-casting-interrupted"]))
end

local TotemOnUpdate = function(self, elapsed)
	local Time = self.Duration - (GetTime() - self.Start)

	self:SetValue(Time)

	if (Time < 0) then
		self:SetScript("OnUpdate", nil)
		self:Hide()
	end
end

UF.PostUpdateTotems = function(self, slot, havetotem, name, start, duration, icon)
	if (start and duration > 0) then
		local Bar = self[slot].Bar

		if (not Bar) then
			return
		end

		Bar:SetMinMaxValues(0, duration)
		Bar:SetValue(duration - (GetTime() - start))
		Bar.Duration = duration
		Bar.Start = start
		Bar:Show()

		if not Bar:GetScript("OnUpdate") then
			Bar:SetScript("OnUpdate", TotemOnUpdate)
		end
	else
		local Bar = self[slot].Bar

		if Bar:GetScript("OnUpdate") then
			Bar:SetScript("OnUpdate", nil)
		end

		Bar:Hide()
	end
end

UF.AuraOffsets = {
	TOPLEFT = {6, 0},
	TOPRIGHT = {-6, 0},
	BOTTOMLEFT = {6, 0},
	BOTTOMRIGHT = {-6, 0},
	LEFT = {6, 0},
	RIGHT = {-6, 0},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

if HydraUI.IsMainline then
	UF.BuffIDs = {
		["DRUID"] = {
			{774, "TOPLEFT", {0.8, 0.4, 0.8}},      -- Rejuvenation
			{155777, "LEFT", {0.8, 0.4, 0.8}},      -- Germination
			{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},    -- Regrowth
			{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
			{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}},  -- Wild Growth
			{102342, "RIGHT", {0.8, 0.2, 0.2}},     -- Ironbark
			{102351, "BOTTOM", {0.84, 0.92, 0.77}}, -- Cenarion Ward
			{102352, "BOTTOM", {0.84, 0.92, 0.77}}, -- Cenarion Ward (Heal)
		},

		["MONK"] = {
			{119611, "TOPLEFT", {0.32, 0.89, 0.74}},  -- Renewing Mist
			{116849, "TOPRIGHT", {0.2, 0.8, 0.2}},	  -- Life Cocoon
			{124682, "BOTTOMLEFT", {0.9, 0.8, 0.48}}, -- Enveloping Mist
			{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}},   -- Zen Sphere
			{115175, "LEFT", {0.24, 0.87, 0.49}},     -- Soothing Mist
		},

		["PALADIN"] = {
			{53563, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Light
			{156910, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Faith
			{200025, "TOPRIGHT", {0.7, 0.3, 0.7}},	        -- Beacon of Virtue
			{287280, "BOTTOMLEFT", {0.99, 0.75, 0.36}},	    -- Glimmer of Light
			{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},-- Blessing of Protection
			{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},	-- Blessing of Freedom
			--{1038, "BOTTOMRIGHT", {0.93, 0.75, 0}, true},	-- Blessing of Salvation
			{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},	-- Blessing of Sacrifice
			--{223306, "TOPLEFT", {0.81, 0.85, 0.1}},	    -- Bestow Faith
		},

		["PRIEST"] = {
			{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},  -- Prayer of Mending
			{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},     -- Renew
			{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
			{194384, "TOPRIGHT", {1, 0, 0}},          -- Atonement

			{33206, "BOTTOMLEFT", {0.93, 0.91, 0.87}}, -- Pain Suppression
			{121536, "BOTTOMRIGHT", {0.98, 0.76, 0.03}}, -- Angelic Feather
		},

		["SHAMAN"] = {
			{61295, "TOPLEFT", {0.7, 0.3, 0.7}},   -- Riptide
			{974, "TOPRIGHT", {0.73, 0.61, 0.33}}, -- Earth Shield
		},

		["EVOKER"] = { -- Requires ID's

		}
	}
elseif HydraUI.IsWrath then
	UF.BuffIDs = {
		["DRUID"] = {
			-- Regrowth
			{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8938, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8939, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8940, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8941, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9750, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9856, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9857, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9858, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{26980, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{48442, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- rank 11
			{48443, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- rank 12

			-- Rejuvenation
			{774, "TOPLEFT", {0.8, 0.4, 0.8}},
			{1058, "TOPLEFT", {0.8, 0.4, 0.8}},
			{1430, "TOPLEFT", {0.8, 0.4, 0.8}},
			{2090, "TOPLEFT", {0.8, 0.4, 0.8}},
			{2091, "TOPLEFT", {0.8, 0.4, 0.8}},
			{3627, "TOPLEFT", {0.8, 0.4, 0.8}},
			{8910, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9839, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9840, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9841, "TOPLEFT", {0.8, 0.4, 0.8}},
			{25299, "TOPLEFT", {0.8, 0.4, 0.8}},
			{26981, "TOPLEFT", {0.8, 0.4, 0.8}},
			{26982, "TOPLEFT", {0.8, 0.4, 0.8}},
			{48440, "TOPLEFT", {0.8, 0.4, 0.8}}, -- rank 14
			{48441, "TOPLEFT", {0.8, 0.4, 0.8}}, -- rank 15

			-- Lifebloom
			{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}},
			{48450, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- rank 2
			{48451, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- rank 3
		},

		["PALADIN"] = {
			-- Beacon of Light
			{53563, "TOPRIGHT", {0.81, 0.85, 0.1}, true},

			-- Sacred Shield
			{53601, "TOPLEFT", {0.80, 0.61, 0.11}, true},

			-- Hand of Freedom
			{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},

			-- Hand of Protection
			{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
			{5599, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
			{10278, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},

			-- Hand of Sacrifice
			{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
			{20729, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
			{27147, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
			{27148, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
		},

		["PRIEST"] = {
			-- Prayer of Mending
			{33076, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{351575, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{41637, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{44583, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{44586, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{46045, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{48112, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},
			{48113, "BOTTOMRIGHT", {0.2, 0.7, 0.2}},

			-- Power Word: Shield
			{17, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{592, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{600, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{3747, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{6065, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{6066, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10898, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10899, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10900, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10901, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{25217, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{25218, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{48065, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{48066, "TOPLEFT", {0.81, 0.85, 0.1}, true},

			-- Renew
			{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6074, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6075, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6076, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6077, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6078, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10927, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10928, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10929, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{25315, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{25221, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{25222, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{48067, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{48068, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		},

		["SHAMAN"] = {
			-- Earth Shield
			{974, "TOPRIGHT", {0.73, 0.61, 0.33}},
			{32593, "TOPRIGHT", {0.73, 0.61, 0.33}},
			{32594, "TOPRIGHT", {0.73, 0.61, 0.33}},
			{49283, "TOPRIGHT", {0.73, 0.61, 0.33}},
			{49284, "TOPRIGHT", {0.73, 0.61, 0.33}},
			-- Riptide
			{61295, "TOPLEFT", {0, 0.4, 0.6}},
			{61299, "TOPLEFT", {0, 0.4, 0.6}},
			{61300, "TOPLEFT", {0, 0.4, 0.6}},
			{61301, "TOPLEFT", {0, 0.4, 0.6}},
		},
	}
else -- Classic
	UF.BuffIDs = {
		["DRUID"] = {
			-- Regrowth
			{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8938, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8939, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8940, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{8941, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9750, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9856, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9857, "TOPRIGHT", {0.2, 0.8, 0.2}},
			{9858, "TOPRIGHT", {0.2, 0.8, 0.2}},

			-- Rejuvenation
			{774, "TOPLEFT", {0.8, 0.4, 0.8}},
			{1058, "TOPLEFT", {0.8, 0.4, 0.8}},
			{1430, "TOPLEFT", {0.8, 0.4, 0.8}},
			{2090, "TOPLEFT", {0.8, 0.4, 0.8}},
			{2091, "TOPLEFT", {0.8, 0.4, 0.8}},
			{3627, "TOPLEFT", {0.8, 0.4, 0.8}},
			{8910, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9839, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9840, "TOPLEFT", {0.8, 0.4, 0.8}},
			{9841, "TOPLEFT", {0.8, 0.4, 0.8}},
			{25299, "TOPLEFT", {0.8, 0.4, 0.8}},
		},

		["PALADIN"] = {
			-- Blessing of Freedom
			{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true},

			-- Blessing of Protection
			{1022, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
			{5599, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},
			{10278, "BOTTOMRIGHT", {0.29, 0.45, 0.73}, true},

			-- Blessing of Sacrifice
			{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
			{20729, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true},
		},

		["PRIEST"] = {
			-- Power Word: Shield
			{17, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{592, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{600, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{3747, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{6065, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{6066, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10898, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10899, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10900, "TOPLEFT", {0.81, 0.85, 0.1}, true},
			{10901, "TOPLEFT", {0.81, 0.85, 0.1}, true},

			-- Renew
			{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6074, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6075, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6076, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6077, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{6078, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10927, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10928, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{10929, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
			{25315, "BOTTOMLEFT", {0.4, 0.7, 0.2}},
		},
	}
end

UF.PostCreateAuraWatchIcon = function(auras, icon)
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.icon:SetDrawLayer("ARTWORK")

	icon.bg = icon:CreateTexture(nil, "BORDER")
	icon.bg:SetPoint("TOPLEFT", icon, -1, 1)
	icon.bg:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	icon.bg:SetTexture(0, 0, 0)

	icon.overlay:SetTexture()
end

local UpdatePartyShowRole = function(value)
	if HydraUI.UnitFrames["party"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["party"]:GetChildren())

			if Unit then
				if value then
					Unit:EnableElement("GroupRoleIndicator")
				else
					Unit:DisableElement("GroupRoleIndicator")
				end

				Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
end

local Style = function(self, unit)
	if HydraUI.StyleFuncs[unit] then
		HydraUI.StyleFuncs[unit](self, unit)
	elseif (find(unit, "raid") and Settings["raid-enable"]) then
		HydraUI.StyleFuncs["raid"](self, unit)
	elseif (find(unit, "tank") and Settings["raid-tank-enable"]) then
		HydraUI.StyleFuncs["tank"](self, unit)
	elseif (find(unit, "raidpet") and Settings["raid-pets-enable"]) then
		HydraUI.StyleFuncs["raidpet"](self, unit)
	elseif (find(unit, "partypet") and Settings["party-enable"] and Settings["party-pets-enable"]) then
		HydraUI.StyleFuncs["partypet"](self, unit)
	elseif (find(unit, "party") and not find(unit, "pet") and Settings["party-enable"]) then
		HydraUI.StyleFuncs["party"](self, unit)
	elseif (find(unit, "nameplate") and Settings["nameplates-enable"]) then
		HydraUI.StyleFuncs["nameplate"](self, unit)
	elseif find(unit, "boss%d") then
		HydraUI.StyleFuncs["boss"](self, unit)
	end
end

local UpdateShowPlayerBuffs = function(value)
	if HydraUI.UnitFrames["player"] then
		if value then
			HydraUI.UnitFrames["player"]:EnableElement("Auras")
			HydraUI.UnitFrames["player"]:UpdateAllElements("ForceUpdate")
		else
			HydraUI.UnitFrames["player"]:DisableElement("Auras")
		end
	end
end

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

local UpdateRaidShowPower = function(value)
	if HydraUI.UnitFrames["raid"] then
		local Unit

		for i = 1, HydraUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, HydraUI.UnitFrames["raid"]:GetChildren())

			if Unit then
				if value then
					Unit:EnableElement("Power")
					Unit:SetHeight(Settings["party-health-height"] + Settings["party-power-height"] + 3)
				else
					Unit:DisableElement("Power")
					Unit:SetHeight(Settings["party-health-height"] + 2)
				end

				Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
end

oUF:RegisterStyle("HydraUI", Style)

function UF:Load()
	if Settings["player-enable"] then
		local Player = oUF:Spawn("player", "HydraUI Player")

		if Settings["unitframes-player-enable-power"] and (not Settings["player-move-power"]) then
			Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
		else
			Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + 2)
		end

		Player:SetPoint("TOPRIGHT", HydraUI.UIParent, "CENTER", -68, -281)
		Player:SetParent(HydraUI.UIParent)

		if Settings["player-enable-portrait"] then
			Player:EnableElement("Portrait")
		else
			Player:DisableElement("Portrait")
		end

		if (not Settings["player-enable-pvp"]) then
			Player:DisableElement("PvPIndicator")
			Player.PvPIndicator:Hide()
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

		if Settings["unitframes-player-enable-castbar"] then
			Player.CastAnchor:SetPoint("BOTTOM", HydraUI.UIParent, 0, 118)
			HydraUI:CreateMover(Player.CastAnchor, 2)
		end

		HydraUI.UnitFrames["player"] = Player
		HydraUI:CreateMover(Player)

		Player:UpdateAllElements("ForceUpdate")
	end

	if Settings["target-enable"] then
		local Target = oUF:Spawn("target", "HydraUI Target")
		Target:SetSize(Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
		Target:SetPoint("TOPLEFT", HydraUI.UIParent, "CENTER", 68, -281)
		Target:SetParent(HydraUI.UIParent)

		if Settings["target-enable-portrait"] then
			Target:EnableElement("Portrait")
		else
			Target:DisableElement("Portrait")
		end

		if Settings["unitframes-show-target-buffs"] then
			Target.Buffs:Show()
		else
			Target.Buffs:Hide()
		end

		if Settings["unitframes-show-target-debuffs"] then
			Target.Debuffs:Show()
		else
			Target.Debuffs:Hide()
		end

		if Settings["unitframes-target-enable-castbar"] then
			Target.CastAnchor:SetPoint("BOTTOM", HydraUI.UIParent, 0, 146)
			HydraUI:CreateMover(Target.CastAnchor, 2)
		end

		HydraUI.UnitFrames["target"] = Target
		HydraUI:CreateMover(Target)

		Target:UpdateAllElements("ForceUpdate")
	end

	if Settings["tot-enable"] then
		local TargetTarget = oUF:Spawn("targettarget", "HydraUI Target Target")
		TargetTarget:SetSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"] + Settings["unitframes-targettarget-power-height"] + 3)
		TargetTarget:SetParent(HydraUI.UIParent)

		if Settings["target-enable"] then
			TargetTarget:SetPoint("TOPRIGHT", HydraUI.UnitFrames["target"], "BOTTOMRIGHT", 0, -2)
		else
			TargetTarget:SetPoint("TOPRIGHT", HydraUI.UIParent, "CENTER", 68, -341)
		end

		HydraUI.UnitFrames["targettarget"] = TargetTarget
		HydraUI:CreateMover(TargetTarget)
	end

	if Settings["pet-enable"] then
		local Pet = oUF:Spawn("pet", "HydraUI Pet")
		Pet:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"] + Settings["unitframes-pet-power-height"] + 3)
		Pet:SetParent(HydraUI.UIParent)

		if Settings["player-enable"] then
			Pet:SetPoint("TOPLEFT", HydraUI.UnitFrames["player"], "BOTTOMLEFT", 0, -2)
		else
			Pet:SetPoint("TOPLEFT", HydraUI.UIParent, "CENTER", -68, -341)
		end

		HydraUI.UnitFrames["pet"] = Pet
		HydraUI:CreateMover(Pet)
	end

	if Settings["focus-enable"] then
		local Focus = oUF:Spawn("focus", "HydraUI Focus")
		Focus:SetSize(Settings["unitframes-focus-width"], Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
		Focus:SetPoint("RIGHT", HydraUI.UIParent, "CENTER", -68, 304)
		Focus:SetParent(HydraUI.UIParent)

		if Settings["focus-enable-buffs"] then
			Focus:EnableElement("Auras")
		else
			Focus:DisableElement("Auras")
		end

		HydraUI.UnitFrames["focus"] = Focus
		HydraUI:CreateMover(Focus)
	end

	if Settings["unitframes-boss-enable"] then
		for i = 1, 8 do
			local Boss = oUF:Spawn("boss" .. i, "HydraUI Boss " .. i)
			Boss:SetSize(Settings["unitframes-boss-width"], Settings["unitframes-boss-health-height"] + Settings["unitframes-boss-power-height"] + 3)
			Boss:SetParent(HydraUI.UIParent)

			if (i == 1) then
				Boss:SetPoint("LEFT", HydraUI.UIParent, 300, 200)
			else
				Boss:SetPoint("TOP", HydraUI.UnitFrames["boss" .. (i-1)], "BOTTOM", 0, -28) -- -2
			end

			HydraUI:CreateMover(Boss)

			HydraUI.UnitFrames["boss" .. i] = Boss
		end
	end

	if Settings["party-enable"] then
		local XOffset = 0
		local YOffset = 0

		if (Settings["party-point"] == "LEFT") then
			XOffset = Settings["party-spacing"]
			YOffset = 0
		elseif (Settings["party-point"] == "RIGHT") then
			XOffset = -Settings["party-spacing"]
			YOffset = 0
		elseif (Settings["party-point"] == "TOP") then
			XOffset = 0
			YOffset = -Settings["party-spacing"]
		elseif (Settings["party-point"] == "BOTTOM") then
			XOffset = 0
			YOffset = Settings["party-spacing"]
		end

		local Party = oUF:SpawnHeader("HydraUI Party", nil, "party,solo",
			"initial-width", Settings["party-width"],
			"initial-height", (Settings["party-health-height"] + Settings["party-power-height"] + 3),
			"isTesting", false,
			"showSolo", Settings["party-show-solo"],
			"showPlayer", true,
			"showParty", true,
			"showRaid", false,
			"xOffset", XOffset,
			"yOffset", YOffset,
			"point", Settings["party-point"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()

				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
		)

		self.PartyAnchor = CreateFrame("Frame", "HydraUI Party Anchor", HydraUI.UIParent)
		self.PartyAnchor:SetSize((5 * Settings["party-width"] + (4 * Settings["party-spacing"])), (Settings["party-health-height"] + Settings["party-power-height"]) + 3)
		self.PartyAnchor:SetPoint("BOTTOMLEFT", HydraUIChatFrameTop, "TOPLEFT", -3, 5)

		Party:SetPoint("BOTTOMLEFT", self.PartyAnchor, 0, 0)
		Party:SetParent(HydraUI.UIParent)

		HydraUI.UnitFrames["party"] = Party

		--UpdatePartyShowRole(Settings["party-show-role"])

		HydraUI:CreateMover(self.PartyAnchor)

		if Settings["party-pets-enable"] then
			local XOffset = 0
			local YOffset = 0

			if (Settings["party-point"] == "LEFT") then
				XOffset = Settings["party-spacing"]
				YOffset = 0
			elseif (Settings["party-point"] == "RIGHT") then
				XOffset = - Settings["party-spacing"]
				YOffset = 0
			elseif (Settings["party-point"] == "TOP") then
				XOffset = 0
				YOffset = - Settings["party-spacing"]
			elseif (Settings["party-point"] == "BOTTOM") then
				XOffset = 0
				YOffset = Settings["party-spacing"]
			end

			local PartyPet = oUF:SpawnHeader("HydraUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
				"initial-width", Settings["party-pets-width"],
				"initial-height", (Settings["party-pets-health-height"] + 2),
				"showSolo", Settings["party-show-solo"],
				"showPlayer", false,
				"showParty", true,
				"showRaid", false,
				"xOffset", XOffset,
				"yOffset", YOffset,
				"point", Settings["party-point"],
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()

					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)

			self.PartyPetAnchor = CreateFrame("Frame", "HydraUI Party Pet Anchor", HydraUI.UIParent)
			self.PartyPetAnchor:SetSize((5 * Settings["party-width"] + (4 * Settings["party-spacing"])), Settings["party-pets-health-height"] + 2)
			self.PartyPetAnchor:SetPoint("TOPLEFT", self.PartyAnchor, "BOTTOMLEFT", 0, -2)

			PartyPet:SetPoint("TOPLEFT", self.PartyPetAnchor, 0, 0)
			PartyPet:SetParent(HydraUI.UIParent)

			HydraUI:CreateMover(self.PartyPetAnchor)

			HydraUI.UnitFrames["party-pets"] = PartyPet
		end
	end

	if Settings["raid-enable"] then
		local Raid = oUF:SpawnHeader("HydraUI Raid", nil, "raid,solo",
			"initial-width", Settings["raid-width"],
			"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
			"isTesting", false,
			"showSolo", Settings["raid-show-solo"],
			"showPlayer", true,
			"showParty", false,
			"showRaid", true,
			"point", Settings["raid-point"],
			"xoffset", Settings["raid-x-offset"],
			"yOffset", Settings["raid-y-offset"],
			"maxColumns", Settings["raid-max-columns"],
			"unitsPerColumn", Settings["raid-units-per-column"],
			"columnSpacing", Settings["raid-column-spacing"],
			"columnAnchorPoint", Settings["raid-column-anchor"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()

				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
		)
		local Tank = oUF:SpawnHeader("HydraUI Tanks", nil, "raid,solo",
			"initial-width", Settings["raid-width"],
			"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
			"isTesting", false,
			"showSolo", Settings["raid-show-solo"],
			"showPlayer", true,
			"showParty", false,
			"showRaid", true,
			"point", Settings["raid-point"],
			"xoffset", Settings["raid-x-offset"],
			"yOffset", Settings["raid-y-offset"],
			"maxColumns", Settings["raid-max-columns"],
			"unitsPerColumn", Settings["raid-units-per-column"],
			"columnSpacing", Settings["raid-column-spacing"],
			"columnAnchorPoint", Settings["raid-column-anchor"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()

				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
			)
			
		local UnitHeight = (Settings["raid-health-height"] + Settings["raid-power-height"]) + 1
		local MaxSize = floor(40 / Settings["raid-max-columns"])

		self.RaidAnchor = CreateFrame("Frame", "HydraUI Raid Anchor", HydraUI.UIParent)
		self.RaidAnchor:SetWidth((MaxSize * Settings["raid-width"] + (MaxSize * Settings["raid-x-offset"] - 2)))
		self.RaidAnchor:SetHeight(UnitHeight * (Settings["raid-max-columns"] + 1) + (Settings["raid-y-offset"] * (Settings["raid-max-columns"] - 1)))
		self.RaidAnchor:SetPoint("BOTTOMLEFT", HydraUIChatFrameTop, "TOPLEFT", -3, 10)
		
		self.TankAnchor = CreateFrame("Frame", "HydraUI Tank Anchor", HydraUI.UIParent)
		self.TankAnchor:SetWidth((MaxSize * Settings["raid-width"] + (MaxSize * Settings["raid-x-offset"] - 2)))
		self.TankAnchor:SetHeight(UnitHeight * (Settings["raid-max-columns"] + 1) + (Settings["raid-y-offset"] * (Settings["raid-max-columns"] - 1)))
		self.TankAnchor:SetPoint("BOTTOMLEFT", self.RaidAnchor, "TOPLEFT", -3, 10)


		if CompactRaidFrameContainer then
			CompactRaidFrameContainer:UnregisterAllEvents()
			CompactRaidFrameContainer:SetParent(Hider)

			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(Hider)
		end

		Raid:SetPoint("BOTTOMLEFT", self.RaidAnchor, 0, 0)
		Raid:SetParent(HydraUI.UIParent)
		
		Tank:SetPoint("BOTTOMLEFT", self.TankAnchor, 0, 0)
		Tank:SetParent(HydraUI.UIParent)
		
		HydraUI:CreateMover(self.TankAnchor)
		HydraUI:CreateMover(self.RaidAnchor)

		HydraUI.UnitFrames["raid"] = Raid	
		HydraUI.UnitFrames["tank"] = Tank
		
		UpdateRaidSortingMethod(Settings["raid-sorting-method"])

		if Settings["raid-pets-enable"] then
			local RaidPet = oUF:SpawnHeader("HydraUI Raid Pets", "SecureGroupPetHeaderTemplate", "raid,solo",
			"initial-width", Settings["raid-width"],
			"initial-height", (Settings["raid-pets-health-height"] + 2),
			"isTesting", false,
			"showSolo", Settings["raid-show-solo"],
			"showPlayer", true,
			"showParty", false,
			"showRaid", true,
			"point", Settings["raid-point"],
			"xoffset", Settings["raid-x-offset"],
			"yOffset", Settings["raid-y-offset"],
			"maxColumns", Settings["raid-max-columns"],
			"unitsPerColumn", Settings["raid-units-per-column"],
			"columnSpacing", Settings["raid-column-spacing"],
			"columnAnchorPoint", Settings["raid-column-anchor"],
			"oUF-initialConfigFunction", [[
				local Header = self:GetParent()

				self:SetWidth(Header:GetAttribute("initial-width"))
				self:SetHeight(Header:GetAttribute("initial-height"))
			]]
			)

			self.RaidPetAnchor = CreateFrame("Frame", "HydraUI Raid Pet Anchor", HydraUI.UIParent)
			self.RaidPetAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
			self.RaidPetAnchor:SetHeight(Settings["raid-pets-health-height"] * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
			self.RaidPetAnchor:SetPoint("BOTTOMLEFT", self.RaidAnchor, "TOPLEFT", 0, 0)

			HydraUI:CreateMover(self.RaidPetAnchor)

			RaidPet:SetPoint("TOPLEFT", self.RaidPetAnchor, 0, 0)
			RaidPet:SetParent(HydraUI.UIParent)

			HydraUI.UnitFrames["raid-pets"] = RaidPet
		end
	end

	if Settings["nameplates-enable"] then
		UF.NamePlateCVars.nameplateSelectedAlpha = (Settings["nameplates-selected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMinAlpha = (Settings["nameplates-unselected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMaxAlpha = (Settings["nameplates-unselected-alpha"] / 100)

		oUF:SpawnNamePlates(nil, UF.NamePlateCallback, UF.NamePlateCVars)
	end
end

HydraUI:GetModule("GUI"):AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("unitframes-font", Settings["unitframes-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the unit frames"], nil, "Font")
	left:CreateSlider("unitframes-font-size", Settings["unitframes-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the unit frames"])
	left:CreateDropdown("unitframes-font-flags", Settings["unitframes-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the unit frames"])

	right:CreateHeader(Language["Auras"])
	right:CreateSwitch("unitframes-display-aura-timers", Settings["unitframes-display-aura-timers"], Language["Display Aura Timers"], Language["Display the timer on unit frame auras"], ReloadUI):RequiresReload(true)
end)

--/run HydraUIFakeBosses()
HydraUIFakeBosses = function()
	local Boss

	for i = 1, 8 do
		Boss = HydraUI.UnitFrames["boss"..i]

		if (not Boss:IsShown()) then
			Boss.unit = "player"
			UnregisterUnitWatch(Boss)
			RegisterUnitWatch(Boss, true)
			Boss:Show()
		else
			Boss.unit = nil
			UnregisterUnitWatch(Boss)
			Boss:Hide()
		end
	end
end
