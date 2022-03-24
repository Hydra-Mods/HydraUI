local AddonName, Namespace = ...
local HydraUI, GUI, Language, Assets, Settings, Defaults = Namespace:get()
local oUF = Namespace.oUF
local R, G, B

-- Custom colors; The commented colors are 10% darker, I like it better on lighter textures
Defaults["color-death-knight"] = "C41F3B" -- 7F222D
Defaults["color-demon-hunter"] = "A330C9" -- 922BB4
Defaults["color-druid"] = "FF7D0A" -- E56F08
Defaults["color-hunter"] = "ABD473" -- 98BD66
Defaults["color-mage"] = "40C7EB" -- 38B2D2
Defaults["color-monk"] = "00FF96" -- 00E586
Defaults["color-paladin"] = "F58CBA" -- DB7DA7
Defaults["color-priest"] = "FFFFFF" -- E5E5E5
Defaults["color-rogue"] = "FFF569" -- E5DB5D
Defaults["color-shaman"] = "0070DE" -- 0046C6
Defaults["color-warlock"] = "8787ED" -- 6969B8
Defaults["color-warrior"] = "C79C6E" -- B28B62

-- Power Types
Defaults["color-mana"] = "477CB2" -- 0000FF for the default mana color
Defaults["color-rage"] = "E53935" -- FF0000 ^
Defaults["color-energy"] = "FFEB3B" -- FFFF00 ^
Defaults["color-focus"] = "FF7F3F"
Defaults["color-fuel"] = "008C7F"
Defaults["color-insanity"] = "6600CC"
Defaults["color-holy-power"] = "F2E599"
Defaults["color-fury"] = "C842FC"
Defaults["color-runic-power"] = "00D1FF"
Defaults["color-chi"] = "B5FFEA"
Defaults["color-maelstrom"] = "007FFF"
Defaults["color-lunar-power"] = "4C84E5"
Defaults["color-arcane-charges"] = "1E88E5"
Defaults["color-ammo-slot"] = "CC9900"
Defaults["color-soul-shards"] = "D35832" -- 7F518C for the default soul shards color
Defaults["color-runes"] = "9905CC" -- 7F7F7F ^
Defaults["color-combo-points"] = "FFF468"

-- Reactions
Defaults["color-reaction-1"] = "BF4400" -- Hated
Defaults["color-reaction-2"] = "BF4400" -- Hostile
Defaults["color-reaction-3"] = "BF4400" -- Unfriendly
Defaults["color-reaction-4"] = "E5B200" -- Neutral
Defaults["color-reaction-5"] = "009919" -- Friendly
Defaults["color-reaction-6"] = "009919" -- Honored
Defaults["color-reaction-7"] = "009919" -- Revered
Defaults["color-reaction-8"] = "009919" -- Exalted

-- Zone PVP Types
Defaults["color-sanctuary"] = "68CCEF"
Defaults["color-arena"] = "FF1919"
Defaults["color-hostile"] = "FF1919"
Defaults["color-combat"] = "FF1919"
Defaults["color-friendly"] = "19FF19"
Defaults["color-contested"] = "FFB200"
Defaults["color-other"] = "FFECC1"

-- Debuff Types
Defaults["color-curse"] = "9900FF"
Defaults["color-disease"] = "996600"
Defaults["color-magic"] = "3399FF"
Defaults["color-poison"] = "009900"
Defaults["color-none"] = "000000"

-- Combo Points
Defaults["color-combo-1"] = "FF6666"
Defaults["color-combo-2"] = "FFB266"
Defaults["color-combo-3"] = "FFFF66"
Defaults["color-combo-4"] = "B2FF66"
Defaults["color-combo-5"] = "66FF66"
Defaults["color-combo-6"] = "66FF66"
Defaults["color-combo-charged"] = "64B5F6"

-- Stagger
Defaults["color-stagger-1"] = "66FF66"
Defaults["color-stagger-2"] = "FFFF66"
Defaults["color-stagger-3"] = "FF6666"

-- Casting
Defaults["color-casting-start"] = "4C9900"
Defaults["color-casting-stopped"] = "F39C12"
Defaults["color-casting-interrupted"] = "D35400"
Defaults["color-casting-uninterruptible"] = "FF4444"
Defaults["color-casting-success"] = "4C9900" -- NYI

-- Mirror Timers
Defaults["color-mirror-exhaustion"] = "FFE500"
Defaults["color-mirror-breath"] = "007FFF"
Defaults["color-mirror-death"] = "FFB200"
Defaults["color-mirror-feign-death"] = "FFB200"

-- Other
Defaults["color-tapped"] = "A6A6A6"
Defaults["color-disconnected"] = "A6A6A6"

HydraUI.ClassColors = {}
HydraUI.ReactionColors = {}
HydraUI.ZoneColors = {}
HydraUI.PowerColors = {}
HydraUI.DebuffColors = {}
HydraUI.ComboPoints = {}

function HydraUI:SetColorEntry(t, key, hex)
	R, G, B = self:HexToRGB(hex)
	
	if (not t[key]) then
		t[key] = {}
	end
	
	t[key][1] = R
	t[key][2] = G
	t[key][3] = B
	t[key]["Hex"] = hex
end

function HydraUI:UpdateClassColors()
	self:SetColorEntry(self.ClassColors, "DEATHKNIGHT", Settings["color-death-knight"])
	self:SetColorEntry(self.ClassColors, "DEMONHUNTER", Settings["color-demon-hunter"])
	self:SetColorEntry(self.ClassColors, "DRUID", Settings["color-druid"])
	self:SetColorEntry(self.ClassColors, "HUNTER", Settings["color-hunter"])
	self:SetColorEntry(self.ClassColors, "MAGE", Settings["color-mage"])
	self:SetColorEntry(self.ClassColors, "MONK", Settings["color-monk"])
	self:SetColorEntry(self.ClassColors, "PALADIN", Settings["color-paladin"])
	self:SetColorEntry(self.ClassColors, "PRIEST", Settings["color-priest"])
	self:SetColorEntry(self.ClassColors, "ROGUE", Settings["color-rogue"])
	self:SetColorEntry(self.ClassColors, "SHAMAN", Settings["color-shaman"])
	self:SetColorEntry(self.ClassColors, "WARLOCK", Settings["color-warlock"])
	self:SetColorEntry(self.ClassColors, "WARRIOR", Settings["color-warrior"])
end

function HydraUI:UpdateReactionColors()
	self:SetColorEntry(self.ReactionColors, 1, Settings["color-reaction-1"])
	self:SetColorEntry(self.ReactionColors, 2, Settings["color-reaction-2"])
	self:SetColorEntry(self.ReactionColors, 3, Settings["color-reaction-3"])
	self:SetColorEntry(self.ReactionColors, 4, Settings["color-reaction-4"])
	self:SetColorEntry(self.ReactionColors, 5, Settings["color-reaction-5"])
	self:SetColorEntry(self.ReactionColors, 6, Settings["color-reaction-6"])
	self:SetColorEntry(self.ReactionColors, 7, Settings["color-reaction-7"])
	self:SetColorEntry(self.ReactionColors, 8, Settings["color-reaction-8"])
end

function HydraUI:UpdateZoneColors()
	self:SetColorEntry(self.ZoneColors, "sanctuary", Settings["color-sanctuary"])
	self:SetColorEntry(self.ZoneColors, "arena", Settings["color-arena"])
	self:SetColorEntry(self.ZoneColors, "hostile", Settings["color-hostile"])
	self:SetColorEntry(self.ZoneColors, "combat", Settings["color-combat"])
	self:SetColorEntry(self.ZoneColors, "friendly", Settings["color-friendly"])
	self:SetColorEntry(self.ZoneColors, "contested", Settings["color-contested"])
	self:SetColorEntry(self.ZoneColors, "other", Settings["color-other"])
end

function HydraUI:UpdatePowerColors()
	self:SetColorEntry(self.PowerColors, "MANA", Settings["color-mana"])
	self:SetColorEntry(self.PowerColors, "RAGE", Settings["color-rage"])
	self:SetColorEntry(self.PowerColors, "ENERGY", Settings["color-energy"])
	self:SetColorEntry(self.PowerColors, "COMBO_POINTS", Settings["color-combo-points"])
	self:SetColorEntry(self.PowerColors, "FOCUS", Settings["color-focus"])
	self:SetColorEntry(self.PowerColors, "SOUL_SHARDS", Settings["color-soul-shards"])
	self:SetColorEntry(self.PowerColors, "INSANITY", Settings["color-insanity"])
	self:SetColorEntry(self.PowerColors, "FURY", Settings["color-fury"])
	self:SetColorEntry(self.PowerColors, "PAIN", Settings["color-pain"])
	self:SetColorEntry(self.PowerColors, "CHI", Settings["color-chi"])
	self:SetColorEntry(self.PowerColors, "MAELSTROM", Settings["color-maelstrom"])
	self:SetColorEntry(self.PowerColors, "ARCANE_CHARGES", Settings["color-arcane-charges"])
	self:SetColorEntry(self.PowerColors, "HOLY_POWER", Settings["color-holy-power"])
	self:SetColorEntry(self.PowerColors, "LUNAR_POWER", Settings["color-lunar-power"])
	self:SetColorEntry(self.PowerColors, "RUNIC_POWER", Settings["color-runic-power"])
	self:SetColorEntry(self.PowerColors, "RUNES", Settings["color-runes"])
	self:SetColorEntry(self.PowerColors, "FUEL", Settings["color-fuel"])
	self:SetColorEntry(self.PowerColors, "AMMO_SLOT", Settings["color-ammo-slot"])
end

function HydraUI:UpdateDebuffColors()
	self:SetColorEntry(self.DebuffColors, "Curse", Settings["color-curse"])
	self:SetColorEntry(self.DebuffColors, "Disease", Settings["color-disease"])
	self:SetColorEntry(self.DebuffColors, "Magic", Settings["color-magic"])
	self:SetColorEntry(self.DebuffColors, "Poison", Settings["color-poison"])
	self:SetColorEntry(self.DebuffColors, "none", Settings["color-none"])
end

function HydraUI:UpdateComboColors()
	self:SetColorEntry(self.ComboPoints, 1, Settings["color-combo-1"])
	self:SetColorEntry(self.ComboPoints, 2, Settings["color-combo-2"])
	self:SetColorEntry(self.ComboPoints, 3, Settings["color-combo-3"])
	self:SetColorEntry(self.ComboPoints, 4, Settings["color-combo-4"])
	self:SetColorEntry(self.ComboPoints, 5, Settings["color-combo-5"])
	self:SetColorEntry(self.ComboPoints, 6, Settings["color-combo-6"])
end

function HydraUI:UpdateColors()
	self:UpdateClassColors()
	self:UpdateReactionColors()
	self:UpdateZoneColors()
	self:UpdatePowerColors()
	self:UpdateDebuffColors()
	self:UpdateComboColors()
end

GUI:AddWidgets(Language["General"], Language["Colors"], function(left, right)
	left:CreateHeader(Language["Class Colors"])
	left:CreateColorSelection("color-death-knight", Settings["color-death-knight"], Language["Death Knight"], "")
	left:CreateColorSelection("color-demon-hunter", Settings["color-demon-hunter"], Language["Demon Hunter"], "")
	left:CreateColorSelection("color-druid", Settings["color-druid"], Language["Druid"], "")
	left:CreateColorSelection("color-hunter", Settings["color-hunter"], Language["Hunter"], "")
	left:CreateColorSelection("color-mage", Settings["color-mage"], Language["Mage"], "")
	left:CreateColorSelection("color-monk", Settings["color-monk"], Language["Monk"], "")
	left:CreateColorSelection("color-paladin", Settings["color-paladin"], Language["Paladin"], "")
	left:CreateColorSelection("color-priest", Settings["color-priest"], Language["Priest"], "")
	left:CreateColorSelection("color-rogue", Settings["color-rogue"], Language["Rogue"], "")
	left:CreateColorSelection("color-shaman", Settings["color-shaman"], Language["Shaman"], "")
	left:CreateColorSelection("color-warlock", Settings["color-warlock"], Language["Warlock"], "")
	left:CreateColorSelection("color-warrior", Settings["color-warrior"], Language["Warrior"], "")
	
	right:CreateHeader(Language["Power Colors"])
	right:CreateColorSelection("color-mana", Settings["color-mana"], Language["Mana"], "")
	right:CreateColorSelection("color-rage", Settings["color-rage"], Language["Rage"], "")
	right:CreateColorSelection("color-energy", Settings["color-energy"], Language["Energy"], "")
	right:CreateColorSelection("color-focus", Settings["color-focus"], Language["Focus"], "")
	--right:CreateColorSelection("color-combo-points", Settings["color-combo-points"], Language["Combo Points"], "")
	right:CreateColorSelection("color-soul-shards", Settings["color-soul-shards"], Language["Soul Shards"], "")
	right:CreateColorSelection("color-insanity", Settings["color-insanity"], Language["Insanity"], "")
	right:CreateColorSelection("color-fury", Settings["color-fury"], Language["Fury"], "")
	right:CreateColorSelection("color-chi", Settings["color-chi"], Language["Chi"], "")
	right:CreateColorSelection("color-maelstrom", Settings["color-maelstrom"], Language["Maelstrom"], "")
	right:CreateColorSelection("color-arcane-charges", Settings["color-arcane-charges"], Language["Arcane Charges"], "")
	right:CreateColorSelection("color-holy-power", Settings["color-holy-power"], Language["Holy Power"], "")
	right:CreateColorSelection("color-lunar-power", Settings["color-lunar-power"], Language["Lunar Power"], "")
	right:CreateColorSelection("color-runic-power", Settings["color-runic-power"], Language["Runic Power"], "")
	right:CreateColorSelection("color-runes", Settings["color-runes"], Language["Runes"], "")
	right:CreateColorSelection("color-fuel", Settings["color-fuel"], Language["Fuel"], "")
	right:CreateColorSelection("color-ammo-slot", Settings["color-ammo-slot"], Language["Ammo Slot"], "")
	
	left:CreateHeader(Language["Zone Colors"])
	left:CreateColorSelection("color-sanctuary", Settings["color-sanctuary"], Language["Sanctuary"], "")
	left:CreateColorSelection("color-arena", Settings["color-arena"], Language["Arena"], "")
	left:CreateColorSelection("color-hostile", Settings["color-hostile"], Language["Hostile"], "")
	left:CreateColorSelection("color-combat", Settings["color-combat"], Language["Combat"], "")
	left:CreateColorSelection("color-contested", Settings["color-contested"], Language["Contested"], "")
	left:CreateColorSelection("color-friendly", Settings["color-friendly"], Language["Friendly"], "")
	left:CreateColorSelection("color-other", Settings["color-other"], Language["Other"], "")
	
	right:CreateHeader(Language["Reaction Colors"])
	right:CreateColorSelection("color-reaction-8", Settings["color-reaction-8"], Language["Exalted"], "")
	right:CreateColorSelection("color-reaction-7", Settings["color-reaction-7"], Language["Revered"], "")
	right:CreateColorSelection("color-reaction-6", Settings["color-reaction-6"], Language["Honored"], "")
	right:CreateColorSelection("color-reaction-5", Settings["color-reaction-5"], Language["Friendly"], "")
	right:CreateColorSelection("color-reaction-4", Settings["color-reaction-4"], Language["Neutral"], "")
	right:CreateColorSelection("color-reaction-3", Settings["color-reaction-3"], Language["Unfriendly"], "")
	right:CreateColorSelection("color-reaction-2", Settings["color-reaction-2"], Language["Hostile"], "")
	right:CreateColorSelection("color-reaction-1", Settings["color-reaction-1"], Language["Hated"], "")
	
	right:CreateHeader(Language["Debuff Colors"])
	right:CreateColorSelection("color-curse", Settings["color-curse"], Language["Curse"], "")
	right:CreateColorSelection("color-disease", Settings["color-disease"], Language["Disease"], "")
	right:CreateColorSelection("color-magic", Settings["color-magic"], Language["Magic"], "")
	right:CreateColorSelection("color-poison", Settings["color-poison"], Language["Poison"], "")
	right:CreateColorSelection("color-none", Settings["color-none"], Language["None"], "")
	
	left:CreateHeader(Language["Combo Points Colors"])
	left:CreateColorSelection("color-combo-1", Settings["color-combo-1"], Language["Combo Point 1"], Language["Set the color of combo point 1"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-2", Settings["color-combo-2"], Language["Combo Point 2"], Language["Set the color of combo point 2"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-3", Settings["color-combo-3"], Language["Combo Point 3"], Language["Set the color of combo point 3"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-4", Settings["color-combo-4"], Language["Combo Point 4"], Language["Set the color of combo point 4"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-5", Settings["color-combo-5"], Language["Combo Point 5"], Language["Set the color of combo point 5"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-6", Settings["color-combo-6"], Language["Combo Point 6"], Language["Set the color of combo point 6"], ReloadUI):RequiresReload(true)
	left:CreateColorSelection("color-combo-charged", Settings["color-combo-charged"], Language["Charged Combo Point"], Language["Set the color of the charged combo point provided from the Kyrian Covenant"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Misc Colors"])
	right:CreateColorSelection("color-tapped", Settings["color-tapped"], Language["Tagged"], "")
	right:CreateColorSelection("color-disconnected", Settings["color-disconnected"], Language["Disconnected"], "")
	
	left:CreateHeader(Language["Casting"])
	left:CreateColorSelection("color-casting-start", Settings["color-casting-start"], Language["Casting"], "")
	left:CreateColorSelection("color-casting-stopped", Settings["color-casting-stopped"], Language["Stopped"], "")
	left:CreateColorSelection("color-casting-interrupted", Settings["color-casting-interrupted"], Language["Interrupted"], "")
	left:CreateColorSelection("color-casting-uninterruptible", Settings["color-casting-uninterruptible"], Language["Uninterruptible"], "")
end)