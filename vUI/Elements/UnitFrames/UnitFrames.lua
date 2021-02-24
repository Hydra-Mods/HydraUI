local addon, ns = ...
local vUI, GUI, Language, Assets, Settings, Defaults = ns:get()

local unpack = unpack
local select = select
local format = string.format
local match = string.match
local floor = math.floor
local sub = string.sub
local find = string.find
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitName = UnitName
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsGhost = UnitIsGhost
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitLevel = UnitLevel
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitReaction = UnitReaction
local UnitIsEnemy = UnitIsEnemy
local UnitIsAFK = UnitIsAFK
local IsResting = IsResting
local UnitAura = UnitAura
local GetTime = GetTime

local oUF = ns.oUF or oUF
local Events = oUF.Tags.Events
local Methods = oUF.Tags.Methods
local Name, Duration, Expiration, Caster, SpellID, _

Defaults["unitframes-enable"] = true
Defaults["unitframes-only-player-debuffs"] = false
Defaults["unitframes-show-player-buffs"] = true
Defaults["unitframes-show-target-buffs"] = true
Defaults["unitframes-show-druid-mana"] = true
Defaults["unitframes-font"] = "Roboto"
Defaults["unitframes-font-size"] = 12
Defaults["unitframes-font-flags"] = ""

local UF = vUI:NewModule("Unit Frames")

vUI.UnitFrames = {}
vUI.StyleFuncs = {}

local Classes = {
	["rare"] = Language["Rare"],
	["elite"] = Language["Elite"],
	["rareelite"] = Language["Rare Elite"],
	--["worldboss"] = Language["Boss"],
}

local ShortClasses = {
	["rare"] = Language[" R"],
	["elite"] = Language["+"],
	["rareelite"] = Language[" R+"],
	--["worldboss"] = Language[" B"],
}

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

local GetColor = function(p, r1, g1, b1, r2, g2, b2)
	return r1 + (r2 - r1) * p, g1 + (g2 - g1) * p, b1 + (b2 - b1) * p
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

-- Tags
Events["Status"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD UNIT_FLAGS"
Methods["Status"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. DEFAULT_AFK_MESSAGE .. "|r"
	end
	
	return ""
end

Events["Level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED PLAYER_ENTERING_WORLD"
Methods["Level"] = function(unit)
	local Level = UnitEffectiveLevel(unit)
	
	if (Level == -1) then
		if UnitIsPlayer(unit) then
			return "??"
		else
			return Language["Boss"]
		end
	else
		return Level
	end
end

Events["LevelPlus"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED PLAYER_ENTERING_WORLD"
Methods["LevelPlus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if (Class == "worldboss") then
		return "Boss"
	else
		local Plus = Methods["Plus"](unit)
		local Level = Methods["Level"](unit)
		
		if Plus then
			return Level .. Plus
		else
			return Level
		end
	end
end

Events["Classification"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED PLAYER_ENTERING_WORLD"
Methods["Classification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if Classes[Class] then
		return Classes[Class]
	end
end

Events["ShortClassification"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED PLAYER_ENTERING_WORLD"
Methods["ShortClassification"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Plus"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED PLAYER_ENTERING_WORLD"
Methods["Plus"] = function(unit)
	local Class = UnitClassification(unit)
	
	if ShortClasses[Class] then
		return ShortClasses[Class]
	end
end

Events["Resting"] = "PLAYER_UPDATE_RESTING PLAYER_ENTERING_WORLD"
Methods["Resting"] = function(unit)
	if (unit == "player" and IsResting()) then
		return "zZz"
	end
end

Events["Health"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["Health"] = function(unit)
	return vUI:ShortValue(UnitHealth(unit))
end

Events["HealthPercent"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["HealthPercent"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Max == 0) then
		return 0
	else
		return floor((Current / Max * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["HealthValues"] = "UNIT_HEALTH UNIT_CONNECTION PLAYER_ENTERING_WORLD"
Methods["HealthValues"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
end

Events["HealthDeficit"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD UNIT_FLAGS UNIT_CONNECTION"
Methods["HealthDeficit"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. DEFAULT_AFK_MESSAGE .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Deficit = Max - Current
	
	if ((Deficit ~= 0) or (Current ~= Max)) then
		return "-" .. vUI:ShortValue(Deficit)
	end
end

Events["GroupStatus"] = "UNIT_HEALTH UNIT_CONNECTION UNIT_FLAGS PLAYER_ENTERING_WORLD"
Methods["GroupStatus"] = function(unit)
	if UnitIsDead(unit) then
		return "|cFFEE4D4D" .. Language["Dead"] .. "|r"
	elseif UnitIsGhost(unit) then
		return "|cFFEEEEEE" .. Language["Ghost"] .. "|r"
	elseif (not UnitIsConnected(unit)) then
		return "|cFFEEEEEE" .. Language["Offline"] .. "|r"
	elseif UnitIsAFK(unit) then
		return "|cFFEEEEEE" .. DEFAULT_AFK_MESSAGE .. "|r"
	end
	
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	local Color = Methods["HealthColor"](unit)
	
	if (Max == 0) then
		return Color .. "0|r"
	else
		return Color .. floor(Current / Max * 100 + 0.5) .. "|r"
	end
end

Events["HealthColor"] = "UNIT_HEALTH PLAYER_ENTERING_WORLD"
Methods["HealthColor"] = function(unit)
	local Current = UnitHealth(unit)
	local Max = UnitHealthMax(unit)
	
	if (Current and Max > 0) then
		return "|cFF" .. vUI:RGBToHex(GetColor(Current / Max, 0.905, 0.298, 0.235, 0.17, 0.77, 0.4))
	else
		return "|cFF" .. vUI:RGBToHex(0.18, 0.8, 0.443)
	end
end

Events["Power"] = "UNIT_POWER_FREQUENT UNIT_POWER_UPDATE PLAYER_ENTERING_WORLD"
Methods["Power"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return vUI:ShortValue(UnitPower(unit))
	end
end

Events["PowerValues"] = "UNIT_POWER_FREQUENT UNIT_POWER_UPDATE PLAYER_ENTERING_WORLD"
Methods["PowerValues"] = function(unit)
	local Current = UnitPower(unit)
	local Max = UnitPowerMax(unit)
	
	if (Max ~= 0) then
		return vUI:ShortValue(Current) .. " / " .. vUI:ShortValue(Max)
	end
end

Events["PowerPercent"] = "UNIT_POWER_FREQUENT UNIT_POWER_UPDATE PLAYER_ENTERING_WORLD"
Methods["PowerPercent"] = function(unit)
	if (UnitPower(unit) ~= 0) then
		return floor((UnitPower(unit) / UnitPowerMax(unit) * 100 + 0.05) * 10) / 10 .. "%"
	end
end

Events["PowerColor"] = "UNIT_POWER_FREQUENT UNIT_POWER_UPDATE PLAYER_ENTERING_WORLD"
Methods["PowerColor"] = function(unit)
	local PowerType, PowerToken = UnitPowerType(unit)
	
	if vUI.PowerColors[PowerToken] then
		return format("|cFF%s", vUI.PowerColors[PowerToken].Hex)
	else
		return "|cFFFFFF"
	end
end

Events["Name4"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name4"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 4)
	end
end

Events["Name5"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name5"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 5)
	end
end

Events["Name8"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name8"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 8)
	end
end

Events["Name10"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name10"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 10)
	end
end

Events["Name14"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name14"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 14)
	end
end

Events["Name15"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name15"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 15)
	end
end

Events["Name20"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name20"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 20)
	end
end

Events["Name30"] = "UNIT_NAME_UPDATE UNIT_PET PLAYER_ENTERING_WORLD"
Methods["Name30"] = function(unit)
	local Name = UnitName(unit)
	
	if Name then
		return sub(Name, 1, 30)
	end
end

Events["NameColor"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED"
Methods["NameColor"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		
		if Class then
			local Color = vUI.ClassColors[Class]
			
			if Color then
				return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	else
		local Reaction = UnitReaction(unit, "player")
		
		if Reaction then
			local Color = vUI.ReactionColors[Reaction]
			
			if Color then
				return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
			end
		end
	end
end

Events["Reaction"] = "UNIT_NAME_UPDATE PLAYER_ENTERING_WORLD UNIT_CLASSIFICATION_CHANGED"
Methods["Reaction"] = function(unit)
	local Reaction = UnitReaction(unit, "player")
	
	if Reaction then
		local Color = vUI.ReactionColors[Reaction]
		
		if Color then
			return "|cFF"..vUI:RGBToHex(Color[1], Color[2], Color[3])
		end
	end
end

Events["LevelColor"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_ENTERING_WORLD"
Methods["LevelColor"] = function(unit)
	local Level = UnitLevel(unit)
	local Color = GetQuestDifficultyColor(Level)
	
	return "|cFF" .. vUI:RGBToHex(Color.r, Color.g, Color.b)
end

Events["RaidGroup"] = "GROUP_ROSTER_UPDATE PLAYER_ENTERING_WORLD"
Methods["RaidGroup"] = function(unit)
	local name = UnitName(unit)
	local gname, grank, group
	
	for i = 1, MAX_RAID_MEMBERS do
		gname, grank, group = GetRaidRosterInfo(i)
		
		if (not gname) then
			break
		end
		
		if (gname == name) then
			return group
		end
	end
end

local AuraOnUpdate = function(self, ela)
	self.ela = self.ela + ela
	
	if (self.ela > 0.1) then
		local Now = (self.Expiration - GetTime())
		
		if (Now > 0) then
			self.Time:SetText(vUI:AuraFormatTime(Now))
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
		local color = vUI.DebuffColors[debuffType] or vUI.DebuffColors.none
	
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

UF.PostCreateIcon = function(unit, button)
	button:SetBackdrop(vUI.BackdropAndBorder)
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
	vUI:SetFontInfo(button.count, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	
	button.overlayFrame = CreateFrame("Frame", nil, button)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)	 
	
	button.Time = button:CreateFontString(nil, "OVERLAY")
	vUI:SetFontInfo(button.Time, Settings["unitframes-font"], Settings["unitframes-font-size"], "OUTLINE")
	button.Time:SetPoint("TOPLEFT", 2, -2)
	button.Time:SetJustifyH("LEFT")
	
	button.count:SetParent(button.overlayFrame)
	button.Time:SetParent(button.overlayFrame)
	
	button.ela = 0
end

UF.PostCastStart = function(self)
	if self.notInterruptible then
		self:SetStatusBarColor(vUI:HexToRGB(Settings["color-casting-uninterruptible"]))
	else
		self:SetStatusBarColor(vUI:HexToRGB(Settings["color-casting-start"]))
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
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
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
	if vUI.StyleFuncs[unit] then
		vUI.StyleFuncs[unit](self, unit)
	elseif (find(unit, "raid") and Settings["raid-enable"]) then
		vUI.StyleFuncs["raid"](self, unit)
	elseif (find(unit, "partypet") and Settings["party-enable"] and Settings["party-pets-enable"]) then
		vUI.StyleFuncs["partypet"](self, unit)
	elseif (find(unit, "party") and not find(unit, "pet") and Settings["party-enable"]) then
		vUI.StyleFuncs["party"](self, unit)
	elseif (find(unit, "nameplate") and Settings["nameplates-enable"]) then
		vUI.StyleFuncs["nameplate"](self, unit)
	elseif find(unit, "boss%d") then
		vUI.StyleFuncs["boss"](self, unit)
	end
end

local UpdateShowPlayerBuffs = function(value)
	if vUI.UnitFrames["player"] then
		if value then
			vUI.UnitFrames["player"]:EnableElement("Auras")
			vUI.UnitFrames["player"]:UpdateAllElements("ForceUpdate")
		else
			vUI.UnitFrames["player"]:DisableElement("Auras")
		end
	end
end

local UpdateShowTargetBuffs = function(value)
	if vUI.UnitFrames["target"] then
		if value then
			vUI.UnitFrames["target"]:EnableElement("Auras")
			vUI.UnitFrames["target"]:UpdateAllElements("ForceUpdate")
		else
			vUI.UnitFrames["target"]:DisableElement("Auras")
		end
	end
end

local UpdateRaidSortingMethod = function(value)
	if (value == "CLASS") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "DEATHKNIGHT,DEMONHUNTER,DRUID,HUNTER,MAGE,MONK,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "CLASS")
	elseif (value == "ROLE") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "ASSIGNEDROLE")
	elseif (value == "NAME") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", nil)
	elseif (value == "MTMA") then
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "MAINTANK,MAINASSIST,NONE")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "NAME")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "ROLE")
	else -- GROUP
		vUI.UnitFrames["raid"]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
		vUI.UnitFrames["raid"]:SetAttribute("sortMethod", "INDEX")
		vUI.UnitFrames["raid"]:SetAttribute("groupBy", "GROUP")
	end
end

local UpdatePartyShowRole = function(value)
	if vUI.UnitFrames["party"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["party"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["party"]:GetChildren())
			
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
	if vUI.UnitFrames["raid"] then
		local Unit
		
		for i = 1, vUI.UnitFrames["raid"]:GetNumChildren() do
			Unit = select(i, vUI.UnitFrames["raid"]:GetChildren())
			
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

oUF:RegisterStyle("vUI", Style)

UF:RegisterEvent("PLAYER_LOGIN")
UF:RegisterEvent("PLAYER_ENTERING_WORLD")
UF:SetScript("OnEvent", function(self, event)
	if (event == "PLAYER_LOGIN") then
		if Settings["unitframes-enable"] then
			local Player = oUF:Spawn("player", "vUI Player")
			
			if Settings["unitframes-player-enable-power"] then
				Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + Settings["unitframes-player-power-height"] + 3)
			else
				Player:SetSize(Settings["unitframes-player-width"], Settings["unitframes-player-health-height"] + 2)
			end
			
			Player:SetPoint("TOPRIGHT", vUI.UIParent, "CENTER", -68, -281)
			Player:SetParent(vUI.UIParent)
			
			if Settings["player-enable-portrait"] then
				Player:EnableElement("Portrait")
			else
				Player:DisableElement("Portrait")
			end
			
			if (not Settings["player-enable-pvp-indicator"]) then
				Player:DisableElement("PvPIndicator")
				Player.PvPIndicator:Hide()
			end
			
			local Target = oUF:Spawn("target", "vUI Target")
			Target:SetSize(Settings["unitframes-target-width"], Settings["unitframes-target-health-height"] + Settings["unitframes-target-power-height"] + 3)
			Target:SetPoint("TOPLEFT", vUI.UIParent, "CENTER", 68, -281)
			Target:SetParent(vUI.UIParent)
			
			if Settings["target-enable-portrait"] then
				Target:EnableElement("Portrait")
			else
				Target:DisableElement("Portrait")
			end
			
			local TargetTarget = oUF:Spawn("targettarget", "vUI Target Target")
			TargetTarget:SetSize(Settings["unitframes-targettarget-width"], Settings["unitframes-targettarget-health-height"] + Settings["unitframes-targettarget-power-height"] + 3)
			TargetTarget:SetPoint("TOPRIGHT", Target, "BOTTOMRIGHT", 0, -2)
			TargetTarget:SetParent(vUI.UIParent)
			
			local Pet = oUF:Spawn("pet", "vUI Pet")
			Pet:SetSize(Settings["unitframes-pet-width"], Settings["unitframes-pet-health-height"] + Settings["unitframes-pet-power-height"] + 3)
			Pet:SetPoint("TOPLEFT", Player, "BOTTOMLEFT", 0, -2)
			Pet:SetParent(vUI.UIParent)
			
			local Focus = oUF:Spawn("focus", "vUI Focus")
			Focus:SetSize(Settings["unitframes-focus-width"], Settings["unitframes-focus-health-height"] + Settings["unitframes-focus-power-height"] + 3)
			Focus:SetPoint("RIGHT", vUI.UIParent, "CENTER", -68, 304)
			Focus:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["player"] = Player
			vUI.UnitFrames["target"] = Target
			vUI.UnitFrames["targettarget"] = TargetTarget
			vUI.UnitFrames["pet"] = Pet
			vUI.UnitFrames["focus"] = Focus
			
			UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
			UpdateShowTargetBuffs(Settings["unitframes-show-target-buffs"])
			
			vUI:CreateMover(Player)
			vUI:CreateMover(Target)
			vUI:CreateMover(TargetTarget)
			vUI:CreateMover(Pet)
			vUI:CreateMover(Focus)
			
			if Settings["unitframes-player-enable-castbar"] then
				Player.Castbar:SetPoint("BOTTOM", vUI.UIParent, 0, 118)
				vUI:CreateMover(Player.Castbar, 2)
			end
			
			if Settings["unitframes-target-enable-castbar"] then
				Target.Castbar:SetPoint("BOTTOM", vUI.UIParent, 0, 146)
				vUI:CreateMover(Target.Castbar, 2)
			end
		end
		
		if Settings["unitframes-boss-enable"] then
			for i = 1, 5 do
				local Boss = oUF:Spawn("boss" .. i, "vUI Boss " .. i)
				Boss:SetSize(Settings["unitframes-boss-width"], Settings["unitframes-boss-health-height"] + Settings["unitframes-boss-power-height"] + 3)
				Boss:SetParent(vUI.UIParent)
				
				if (i == 1) then
					Boss:SetPoint("LEFT", vUI.UIParent, 300, 200)
				else
					Boss:SetPoint("TOP", vUI.UnitFrames["boss" .. (i-1)], "BOTTOM", 0, -28) -- -2
				end
				
				vUI:CreateMover(Boss)
				
				vUI.UnitFrames["boss" .. i] = Boss
			end
		end
		
		if Settings["party-enable"] then
			local Point = "LEFT"
			local X = Settings["party-spacing"]
			local Y = 0
			
			if (Settings["party-orientation"] == "VERTICAL") then
				Point = "BOTTOM"
				X = 0
				Y = Settings["party-spacing"]
			end
			
			local Party = oUF:SpawnHeader("vUI Party", nil, "party,solo",
				"initial-width", Settings["party-width"],
				"initial-height", (Settings["party-health-height"] + Settings["party-power-height"] + 3),
				"showSolo", false,
				"showPlayer", true,
				"showParty", true,
				"showRaid", false,
				"xoffset", X,
				"yOffset", Y,
				"point", Point,
				"oUF-initialConfigFunction", [[
					local Header = self:GetParent()
					
					self:SetWidth(Header:GetAttribute("initial-width"))
					self:SetHeight(Header:GetAttribute("initial-height"))
				]]
			)
			
			self.PartyAnchor = CreateFrame("Frame", "vUI Party Anchor", vUI.UIParent)
			self.PartyAnchor:SetSize((5 * Settings["party-width"] + (4 * Settings["party-spacing"])), (Settings["party-health-height"] + Settings["party-power-height"]) + 3)
			self.PartyAnchor:SetPoint("BOTTOMLEFT", vUIChatFrameTop, "TOPLEFT", -3, 5)
			
			Party:SetPoint("BOTTOMLEFT", self.PartyAnchor, 0, 0)
			Party:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["party"] = Party
			
			--UpdatePartyShowRole(Settings["party-show-role"])
			
			vUI:CreateMover(self.PartyAnchor)
			
			if Settings["party-pets-enable"] then
				local PartyPet = oUF:SpawnHeader("vUI Party Pets", "SecureGroupPetHeaderTemplate", "party,solo",
					"initial-width", Settings["party-pets-width"],
					"initial-height", (Settings["party-pets-health-height"] + Settings["party-pets-power-height"] + 3),
					"showSolo", false,
					"showPlayer", false,
					"showParty", true,
					"showRaid", false,
					"xoffset", X,
					"yOffset", Y,
					"point", Point,
					"oUF-initialConfigFunction", [[
						local Header = self:GetParent()
						
						self:SetWidth(Header:GetAttribute("initial-width"))
						self:SetHeight(Header:GetAttribute("initial-height"))
					]]
				)
				
				PartyPet:SetPoint("TOPLEFT", Party, "BOTTOMLEFT", 0, -2)
				PartyPet:SetParent(vUI.UIParent)
			end
		end
		
		if Settings["raid-enable"] then
			local Raid = oUF:SpawnHeader("vUI Raid", nil, "raid,solo",
				"initial-width", Settings["raid-width"],
				"initial-height", (Settings["raid-health-height"] + Settings["raid-power-height"] + 3),
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
			
			self.RaidAnchor = CreateFrame("Frame", "vUI Raid Anchor", vUI.UIParent)
			self.RaidAnchor:SetWidth((floor(40 / Settings["raid-max-columns"]) * Settings["raid-width"] + (floor(40 / Settings["raid-max-columns"]) * Settings["raid-x-offset"] - 2)))
			self.RaidAnchor:SetHeight((Settings["raid-health-height"] + Settings["raid-power-height"]) * (Settings["raid-max-columns"] + (Settings["raid-y-offset"])) - 1)
			self.RaidAnchor:SetPoint("BOTTOMLEFT", vUIChatFrameTop, "TOPLEFT", -3, 5)
			
			local Hider = CreateFrame("Frame", nil, vUI.UIParent, "SecureHandlerStateTemplate")
			Hider:Hide()
			
			if CompactRaidFrameContainer then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer:SetParent(Hider)
				
				--CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameManager:SetParent(Hider)
			end
			
			Raid:SetPoint("TOPLEFT", self.RaidAnchor, 0, 0)
			Raid:SetParent(vUI.UIParent)
			
			vUI.UnitFrames["raid"] = Raid
			
			UpdateRaidSortingMethod(Settings["raid-sorting-method"])
			
			vUI:CreateMover(self.RaidAnchor)
		end
		
		if Settings["nameplates-enable"] then
			UF.NamePlateCVars.nameplateSelectedAlpha = (Settings["nameplates-selected-alpha"] / 100)
			UF.NamePlateCVars.nameplateMinAlpha = (Settings["nameplates-unselected-alpha"] / 100)
			UF.NamePlateCVars.nameplateMaxAlpha = (Settings["nameplates-unselected-alpha"] / 100)
			
			oUF:SpawnNamePlates(nil, UF.NamePlateCallback, UF.NamePlateCVars)
		end
	else
		UpdateShowPlayerBuffs(Settings["unitframes-show-player-buffs"])
		UpdateShowTargetBuffs(Settings["unitframes-show-target-buffs"])
	end
end)

GUI:AddWidgets(Language["General"], Language["Unit Frames"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the unit frames module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("unitframes-font", Settings["unitframes-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the unit frames"], nil, "Font")
	left:CreateSlider("unitframes-font-size", Settings["unitframes-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the unit frames"])
	left:CreateDropdown("unitframes-font-flags", Settings["unitframes-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the unit frames"])
end)

--/run vUIFakeBosses()
vUIFakeBosses = function()
	local Boss
	
	for i = 1, 5 do
		Boss = vUI.UnitFrames["boss"..i]
		
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