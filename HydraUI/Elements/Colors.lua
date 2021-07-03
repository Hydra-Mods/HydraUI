local AddonName, Namespace = ...
local HydraUI, GUI, Language, Assets, Settings = Namespace:get()
local oUF = Namespace.oUF
local R, G, B

HydraUI.ClassColors = {}
HydraUI.ReactionColors = {}
HydraUI.ZoneColors = {}
HydraUI.PowerColors = {}
HydraUI.DebuffColors = {}
HydraUI.HappinessColors = {}
HydraUI.ComboPoints = {}
HydraUI.TotemColors = {}

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
	self:SetColorEntry(self.PowerColors, "FOCUS", Settings["color-focus"])
end

function HydraUI:UpdateDebuffColors()
	self:SetColorEntry(self.DebuffColors, "Curse", Settings["color-curse"])
	self:SetColorEntry(self.DebuffColors, "Disease", Settings["color-disease"])
	self:SetColorEntry(self.DebuffColors, "Magic", Settings["color-magic"])
	self:SetColorEntry(self.DebuffColors, "Poison", Settings["color-poison"])
	self:SetColorEntry(self.DebuffColors, "none", Settings["color-none"])
end

function HydraUI:UpdateHappinessColors()
	self:SetColorEntry(self.HappinessColors, 1, Settings["color-happiness-1"])
	self:SetColorEntry(self.HappinessColors, 2, Settings["color-happiness-2"])
	self:SetColorEntry(self.HappinessColors, 3, Settings["color-happiness-3"])
end

function HydraUI:UpdateComboColors()
	self:SetColorEntry(self.ComboPoints, 1, Settings["color-combo-1"])
	self:SetColorEntry(self.ComboPoints, 2, Settings["color-combo-2"])
	self:SetColorEntry(self.ComboPoints, 3, Settings["color-combo-3"])
	self:SetColorEntry(self.ComboPoints, 4, Settings["color-combo-4"])
	self:SetColorEntry(self.ComboPoints, 5, Settings["color-combo-5"])
	self:SetColorEntry(self.ComboPoints, 6, Settings["color-combo-6"])
end

function HydraUI:UpdateTotemColors()
	self:SetColorEntry(self.TotemColors, 1, Settings["color-totem-fire"])
	self:SetColorEntry(self.TotemColors, 2, Settings["color-totem-earth"])
	self:SetColorEntry(self.TotemColors, 3, Settings["color-totem-water"])
	self:SetColorEntry(self.TotemColors, 4, Settings["color-totem-air"])
end

function HydraUI:UpdateColors()
	self:UpdateClassColors()
	self:UpdateReactionColors()
	self:UpdateZoneColors()
	self:UpdatePowerColors()
	self:UpdateDebuffColors()
	self:UpdateHappinessColors()
	self:UpdateComboColors()
	self:UpdateTotemColors()
end

GUI:AddWidgets(Language["General"], Language["Colors"], function(left, right)
	left:CreateHeader(Language["Class Colors"])
	--left:CreateColorSelection("color-death-knight", Settings["color-death-knight"], Language["Death Knight"], "")
	--left:CreateColorSelection("color-demon-hunter", Settings["color-demon-hunter"], Language["Demon Hunter"], "")
	left:CreateColorSelection("color-druid", Settings["color-druid"], Language["Druid"], "")
	left:CreateColorSelection("color-hunter", Settings["color-hunter"], Language["Hunter"], "")
	left:CreateColorSelection("color-mage", Settings["color-mage"], Language["Mage"], "")
	--left:CreateColorSelection("color-monk", Settings["color-monk"], Language["Monk"], "")
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
	
	right:CreateHeader(Language["Pet Happiness Colors"])
	right:CreateColorSelection("color-happiness-3", Settings["color-happiness-3"], Language["Happy"], "")
	right:CreateColorSelection("color-happiness-2", Settings["color-happiness-2"], Language["Content"], "")
	right:CreateColorSelection("color-happiness-1", Settings["color-happiness-1"], Language["Unhappy"], "")
	
	left:CreateHeader(Language["Combo Points Colors"])
	left:CreateColorSelection("color-combo-1", Settings["color-combo-1"], Language["Combo Point 1"], "")
	left:CreateColorSelection("color-combo-2", Settings["color-combo-2"], Language["Combo Point 2"], "")
	left:CreateColorSelection("color-combo-3", Settings["color-combo-3"], Language["Combo Point 3"], "")
	left:CreateColorSelection("color-combo-4", Settings["color-combo-4"], Language["Combo Point 4"], "")
	left:CreateColorSelection("color-combo-5", Settings["color-combo-5"], Language["Combo Point 5"], "")
	
	right:CreateHeader(Language["Misc Colors"])
	right:CreateColorSelection("color-tapped", Settings["color-tapped"], Language["Tagged"], "")
	right:CreateColorSelection("color-disconnected", Settings["color-disconnected"], Language["Disconnected"], "")
	
	left:CreateHeader(Language["Casting"])
	left:CreateColorSelection("color-casting-start", Settings["color-casting-start"], Language["Casting"], "")
	left:CreateColorSelection("color-casting-stopped", Settings["color-casting-stopped"], Language["Stopped"], "")
	left:CreateColorSelection("color-casting-interrupted", Settings["color-casting-interrupted"], Language["Interrupted"], "")
end)