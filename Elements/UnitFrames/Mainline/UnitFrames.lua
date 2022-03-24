local addon, ns = ...
local HydraUI, GUI, Language, Assets, Settings, Defaults = ns:get()

local oUF = ns.oUF or oUF
local Name, Duration, Expiration, Caster, SpellID, _

local unpack = unpack
local select = select
local find = string.find
local UnitAura = UnitAura
local GetTime = GetTime

Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-target-buffs"] = true
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

local Ignore = {
	[GetSpellInfo(57724)] = true, -- Sated
	[GetSpellInfo(288293)] = true, -- Temporal Displacement
	[GetSpellInfo(206150)] = true, -- Challenger's Might
	[GetSpellInfo(206151)] = true, -- Challenger's Burden
}

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

UF.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
	local Name, _, _, _, Duration, Expiration, Caster, _, _, SpellID = UnitAura(unit, index, button.filter)
	
	button.Duration = Duration
	button.Expiration = Expiration
	
	if button.cd then
		if (Duration and Duration > 0) then
			button.cd:SetCooldown(Expiration - Duration, Duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end
	
	if ((button.filter == "HARMFUL") and (not button.isPlayer) and debuffType) then
		button.icon:SetDesaturated(true)
		button:SetBackdropColor(0, 0, 0)
	elseif (button.filter == "HELPFUL") then
		button.icon:SetDesaturated(false)
		button:SetBackdropColor(0, 0, 0)
	else
		local color = HydraUI.DebuffColors[debuffType] or HydraUI.DebuffColors.none
	
		button.icon:SetDesaturated(false)
		button:SetBackdropColor(unpack(color))
	end
	
	if (Expiration and Expiration ~= 0) then
		button:SetScript("OnUpdate", AuraOnUpdate)
		button.Time:Show()
	else
		button.Time:Hide()
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
	
	button:SetBackdrop(HydraUI.BackdropAndBorder)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0, 0)
	button:SetFrameLevel(6)
	
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, -1, 1)
	button.cd:SetHideCountdownNumbers(true)
	button.cd:SetReverse(true)
	
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("ARTWORK")
	
	button.count:SetPoint("BOTTOMRIGHT", 1, 2)
	button.count:SetJustifyH("RIGHT")
	HydraUI:SetFontInfo(button.count, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(button.Time, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	button.Time:SetPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.count:SetParent(button.overlayFrame)

	if Settings["unitframes-display-aura-timers"] then
		button.Time:SetParent(button.overlayFrame)
	else
		button.Time:SetParent(Hider)
	end
	
	button.ela = 0
end

UF.PostCastStart = function(self)
	if self.notInterruptible then
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	else
		self:SetStatusBarColor(HydraUI:HexToRGB(Settings["color-casting-start"]))
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

UF.BuffIDs = {
	["DRUID"] = {
		{774, "TOPLEFT", {0.8, 0.4, 0.8}},      -- Rejuvenation
		{155777, "LEFT", {0.8, 0.4, 0.8}},      -- Germination
		{8936, "TOPRIGHT", {0.2, 0.8, 0.2}},    -- Regrowth
		{33763, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}},  -- Wild Growth
		{102342, "RIGHT", {0.8, 0.2, 0.2}},     -- Ironbark
		{102351, "BOTTOM", {0.84, 0.92, 0.77}},    -- Cenarion Ward
		{102352, "BOTTOM", {0.84, 0.92, 0.77}},    -- Cenarion Ward (Heal)
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
		
		{33206, "BOTTOMLEFT", {237/255, 233/255, 221/255}}, -- Pain Suppression
		{121536, "BOTTOMRIGHT", {251/255, 193/255, 8/255}}, -- Angelic Feather
	},
	
	["SHAMAN"] = {
		{61295, "TOPLEFT", {0.7, 0.3, 0.7}},   -- Riptide
		{974, "TOPRIGHT", {0.73, 0.61, 0.33}}, -- Earth Shield
	},
}

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
				
				--Unit:UpdateAllElements("ForceUpdate")
			end
		end
	end
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
		
		if (not Settings["player-enable-pvp-indicator"]) then
			Player:DisableElement("PvPIndicator")
			Player.PvPIndicator:Hide()
		end
		
		if Settings["unitframes-show-player-buffs"] then
			Player:EnableElement("Auras")
		else
			Player:DisableElement("Auras")
		end
		
		if Settings["unitframes-player-enable-castbar"] then
			Player.Castbar:SetPoint("BOTTOM", HydraUI.UIParent, 0, 118)
			HydraUI:CreateMover(Player.Castbar, 2)
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
			Target:EnableElement("Auras")
		else
			Target:DisableElement("Auras")
		end
		
		if Settings["unitframes-target-enable-castbar"] then
			Target.Castbar:SetPoint("BOTTOM", HydraUI.UIParent, 0, 146)
			HydraUI:CreateMover(Target.Castbar, 2)
		end
		
		HydraUI.UnitFrames["target"] = Target
		HydraUI:CreateMover(Target)
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
		
		HydraUI.UnitFrames["focus"] = Focus
		HydraUI:CreateMover(Focus)
	end
	
	if Settings["unitframes-boss-enable"] then
		for i = 1, 5 do
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
			"showSolo", false,
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
				"initial-height", (Settings["party-pets-health-height"] + Settings["party-pets-power-height"] + 3),
				"showSolo", false,
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

			if (Settings["party-point"] == "LEFT") then
				PartyPet:SetPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "RIGHT") then
				PartyPet:SetPoint("TOPRIGHT", Party, "BOTTOMRIGHT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "TOP") then
				PartyPet:SetPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, - Settings["party-spacing"])
			elseif (Settings["party-point"] == "BOTTOM") then
				PartyPet:SetPoint("BOTTOMLEFT", Party, "TOPLEFT", 0, Settings["party-spacing"])
			end

			PartyPet:SetParent(HydraUI.UIParent)

			HydraUI.UnitFrames["party-pets"] = PartyPet
		end
	end
	
	if Settings["raid-enable"] then
		local Raid = oUF:SpawnHeader("HydraUI Raid", nil, "raid,solo",
			"initial-width", Settings["raid-width"],
			"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
			"isTesting", false,
			"showSolo", false,
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
		
		self.RaidAnchor = CreateFrame("Frame", "HydraUI Raid Anchor", HydraUI.UIParent)
		self.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
		self.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
		self.RaidAnchor:SetPoint("BOTTOMLEFT", HydraUIChatFrameTop, "TOPLEFT", -3, 5)
		
		if CompactRaidFrameContainer then
			CompactRaidFrameContainer:UnregisterAllEvents()
			CompactRaidFrameContainer:SetParent(Hider)
			
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(Hider)
		end
		
		Raid:SetPoint("TOPLEFT", self.RaidAnchor, 0, 0)
		Raid:SetParent(HydraUI.UIParent)
		
		HydraUI.UnitFrames["raid"] = Raid
		
		UpdateRaidSortingMethod(Settings["raid-sorting-method"])
		
		HydraUI:CreateMover(self.RaidAnchor)
	end
	
	if Settings["nameplates-enable"] then
		UF.NamePlateCVars.nameplateSelectedAlpha = (Settings["nameplates-selected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMinAlpha = (Settings["nameplates-unselected-alpha"] / 100)
		UF.NamePlateCVars.nameplateMaxAlpha = (Settings["nameplates-unselected-alpha"] / 100)
		
		oUF:SpawnNamePlates(nil, UF.NamePlateCallback, UF.NamePlateCVars)
	end
end

GUI:AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
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
	
	for i = 1, 5 do
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