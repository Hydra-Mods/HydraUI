local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Auras = HydraUI:NewModule("Auras")

-- Big thank you to Tukz for allowing me to derive my aura code from Tukui

local select = select
local unpack = unpack
local UnitAura = UnitAura
local GetTime = GetTime
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemQuality = GetInventoryItemQuality
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

local DebuffColors = HydraUI.DebuffColors

-- Default settings values
Defaults["auras-enable"] = true
Defaults["auras-size"] = 30
Defaults["auras-spacing"] = 2
Defaults["auras-row-spacing"] = 16
Defaults["auras-per-row"] = 12

Defaults["auras-orienation"] = "HORIZONTAL"
Defaults["auras-font"] = "Roboto"
Defaults["auras-font-size"] = 12
Defaults["auras-font-flags"] = ""

Defaults["auras-count-color"] = "FFFFFF"
Defaults["auras-count-xoffset"] = 10
Defaults["auras-count-yoffset"] = -8
Defaults["auras-count-align"] = "RIGHT"

Defaults["auras-duration-color"] = "FFFFFF"
Defaults["auras-duration-xoffset"] = 0
Defaults["auras-duration-yoffset"] = -24
Defaults["auras-duration-align"] = "CENTER"

Auras.Headers = {}

local OnUpdate = function(button, elapsed)
	local TimeLeft
	
	if button.Enchant then
		local Expiration = select(button.Enchant, GetWeaponEnchantInfo())
		
		if Expiration then
			TimeLeft = Expiration / 1e3
		else
			TimeLeft = 0
		end
	else
		TimeLeft = button.TimeLeft - elapsed
	end
	
	button.TimeLeft = TimeLeft
	
	if (TimeLeft <= 0) then
		button.TimeLeft = nil
		button.Duration:SetText("")
		
		if button.Enchant then
			button.Dur = nil
		end
		
		button:SetScript("OnUpdate", nil)
	else
		button.Duration:SetText(HydraUI:FormatTime(TimeLeft))
	end
end

local UpdateTempEnchant = function(button, slot)
	local Enchant = (slot == 16 and 2) or 6
	local Expiration = select(Enchant, GetWeaponEnchantInfo())
	local Icon = GetInventoryItemTexture("player", slot)
	--[[local Quality = GetInventoryItemQuality("player", slot)
	
	if Quality then
		local Color = ITEM_QUALITY_COLORS[Quality]
		
		button.Backdrop:SetBackdropBorderColor(Color.r, Color.g, Color.b)
	else
		button.Backdrop:SetBackdropBorderColor(0, 0, 0)
	end]]
	
	button.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	if Expiration then
		if (not button.Dur) then
			button.Dur = Expiration / 1e3
		end
		
		button.Enchant = Enchant
		button:SetScript("OnUpdate", OnUpdate)
	else
		button.Dur = nil
		button.Enchant = nil
		button.TimeLeft = nil
		button:SetScript("OnUpdate", nil)
	end
	
	if Icon then
		button:SetAlpha(1)
		button.Icon:SetTexture(Icon)
	else
		button:SetAlpha(0)
	end
end

local OnAttributeChanged = function(button, attribute, index)
	if (attribute == "index") then
		Auras:UpdateAura(button, index)
	elseif (attribute == "target-slot") then
		UpdateTempEnchant(button, index)
	end
end

HydraUIAuraOnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:SetFrameLevel(self:GetFrameLevel() + 2)
	
	if self:GetAttribute("index") then
		GameTooltip:SetUnitAura(PlayerFrame.unit, self:GetID(), self.Filter)
	elseif self:GetAttribute("target-slot") then
		GameTooltip:SetInventoryItem("player", self:GetID())
	end
end

HydraUISkinAura = function(button)
	button:RegisterForClicks("RightButtonUp")
	
	local Backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
	Backdrop:SetAllPoints(button)
	Backdrop:SetFrameLevel(button:GetFrameLevel() - 2)
	Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	Backdrop:SetBackdropColor(0, 0, 0, 0)
	Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	local Icon = button:CreateTexture(nil, "BORDER")
	Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	Icon:ClearAllPoints()
	Icon:SetPoint("TOPLEFT", button, 1, -1)
	Icon:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	local Count = button:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Count, Settings["auras-font"], Settings["auras-font-size"], Settings["auras-font-flags"])
	Count:SetTextColor(HydraUI:HexToRGB(Settings["auras-count-color"]))
	Count:SetPoint("CENTER", button, Settings["auras-count-xoffset"], Settings["auras-count-yoffset"])
	Count:SetJustifyH(Settings["auras-count-align"])
	
	local Duration = button:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Duration, Settings["auras-font"], Settings["auras-font-size"], Settings["auras-font-flags"])
	Duration:SetTextColor(HydraUI:HexToRGB(Settings["auras-duration-color"]))
	Duration:SetPoint("CENTER", button, Settings["auras-duration-xoffset"], Settings["auras-duration-yoffset"])
	Duration:SetJustifyH(Settings["auras-duration-align"])
	
	button:SetScript("OnAttributeChanged", OnAttributeChanged)
	
	button.Icon = Icon
	button.Count = Count
	button.Duration = Duration
	button.Backdrop = Backdrop
	button.Filter = button:GetParent():GetAttribute("filter")
end

function Auras:UpdateAura(button, index)
	local Name, Texture, Count, DType, Duration, ExpirationTime, Caster, IsStealable, ShouldConsolidate, SpellID, CanApplyAura, IsBossDebuff = UnitAura(button:GetParent():GetAttribute("unit"), index, button.Filter) -- button:GetID()
	
	if (not Name) then
		return
	end
	
	if (Duration > 0 and ExpirationTime) then
		local TimeLeft = ExpirationTime - GetTime()
		
		if (not button.TimeLeft) then
			button.TimeLeft = TimeLeft
			button:SetScript("OnUpdate", OnUpdate)
		else
			button.TimeLeft = TimeLeft
		end
		
		button.Dur = Duration
	else
		button.TimeLeft = nil
		button.Dur = nil
		button.Duration:SetText("")
		button:SetScript("OnUpdate", nil)
	end
	
	if (Count > 1) then
		button.Count:SetText(Count)
	else
		button.Count:SetText("")
	end
	
	if (button.Filter == "HARMFUL" and DType) then
		local Color = DebuffColors[DType] or DebuffColors.none
		
		button.Backdrop:SetBackdropBorderColor(unpack(Color))
	end
	
	button.Icon:SetTexture(Texture)
end

function Auras:Load()
	if (not Settings["auras-enable"]) then
		return
	end
	
	local Header
	
	self.Buffs = CreateFrame("Frame", "HydraUI Buffs", HydraUI.UIParent)
	self.Buffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * 3) + (Settings["auras-row-spacing"] * (3 - 1))))
	self.Buffs:SetPoint("TOPRIGHT", HydraUI.UIParent, "TOPRIGHT", -(Settings["minimap-size"] + 22), -12)
	
	self.Debuffs = CreateFrame("Frame", "HydraUI Debuffs", HydraUI.UIParent)
	self.Debuffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * 2) + Settings["auras-row-spacing"]))
	self.Debuffs:SetPoint("TOPRIGHT", self.Buffs, "BOTTOMRIGHT", 0, -2)
	
	local Template = format("HydraUIAuraTemplate%s", Settings["auras-size"])
	
	for i = 1, 2 do
		Header = CreateFrame("Frame", (i == 1 and "HydraUI Buffs" or "HydraUI Debuffs"), HydraUI.UIParent, "SecureAuraHeaderTemplate")
		Header:SetClampedToScreen(true)
		Header:SetMovable(true)
		Header:SetAttribute("minWidth", Settings["auras-per-row"] * (Settings["auras-size"] + Settings["auras-spacing"]))
		Header:SetAttribute("minHeight", Settings["auras-size"])
		Header:SetAttribute("wrapAfter", Settings["auras-per-row"])
		Header:SetAttribute("wrapYOffset", -(Settings["auras-size"] + Settings["auras-row-spacing"])) -- -51
		Header:SetAttribute("xOffset", -(Settings["auras-size"] + Settings["auras-spacing"]))
		Header:SetAttribute("template", Template)
		Header:SetAttribute("weaponTemplate", Template)
		Header:SetAttribute("filter", i == 1 and "HELPFUL" or "HARMFUL")
		Header:SetSize(Settings["auras-size"], Settings["auras-size"])
		Header:SetFrameStrata("BACKGROUND")
		
		RegisterAttributeDriver(Header, "unit", "[vehicleui] vehicle; player")
		
		table.insert(self.Headers, Header)
	end
	
	local Buffs = self.Headers[1]
	Buffs:SetAttribute("includeWeapons", 1)
	Buffs:SetPoint("TOPRIGHT", self.Buffs, 0, 0)
	Buffs:Show()
	
	local Debuffs = self.Headers[2]
	Debuffs:SetPoint("TOPRIGHT", self.Debuffs, 0, 0)
	Debuffs:Show()
	
	-- Update auras
	for i = 1, 2 do
		local Child = self.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child  do
			self:UpdateAura(Child, Child:GetID())
			
			Index = Index + 1
			Child = Header:GetAttribute("child" .. Index)
		end
	end
	
	-- Hide Blizzard auras
	BuffFrame:Hide()
	BuffFrame:UnregisterAllEvents()
	BuffFrame:SetScript("OnUpdate", nil)
	
	TemporaryEnchantFrame:Hide()
	TemporaryEnchantFrame:UnregisterAllEvents()
	TemporaryEnchantFrame:SetScript("OnUpdate", nil)
	
	HydraUI:CreateMover(self.Buffs)
	HydraUI:CreateMover(self.Debuffs)
end

local UpdateAuraSpacing = function(value)
	Auras.Buffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * value), ((Settings["auras-size"] * 3) + (Settings["auras-row-spacing"] * (3 - 1))))
	Auras.Debuffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * value), ((Settings["auras-size"] * 2) + Settings["auras-row-spacing"]))
	
	for i = 1, 2 do
		Auras.Headers[i]:SetAttribute("minWidth", Settings["auras-per-row"] * (Settings["auras-size"] + value))
		Auras.Headers[i]:SetAttribute("xOffset", -(Settings["auras-size"] + value))
	end
end

local UpdateAuraRowSpacing = function(value)
	Auras.Buffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * 3) + (value * (3 - 1))))
	Auras.Debuffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * 2) + value))
	
	for i = 1, 2 do
		Auras.Headers[i]:SetAttribute("wrapYOffset", -(Settings["auras-size"] + value))
	end
end

local UpdateAurasPerRow = function(value)
	Auras.Buffs:SetSize((value * Settings["auras-size"] + value * Settings["auras-spacing"]), ((Settings["auras-size"] * 3) + (Settings["auras-row-spacing"] * (3 - 1))))
	Auras.Debuffs:SetSize((value * Settings["auras-size"] + value * Settings["auras-spacing"]), ((Settings["auras-size"] * 2) + Settings["auras-row-spacing"]))
	
	for i = 1, 2 do
		Auras.Headers[i]:SetAttribute("minWidth", value * (Settings["auras-size"] + Settings["auras-spacing"]))
		Auras.Headers[i]:SetAttribute("wrapAfter", value)
	end
end

local UpdateAuraFont = function()
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			HydraUI:SetFontInfo(Child.Count, Settings["auras-font"], Settings["auras-font-size"], Settings["auras-font-flags"])
			HydraUI:SetFontInfo(Child.Duration, Settings["auras-font"], Settings["auras-font-size"], Settings["auras-font-flags"])
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateCountColor = function(value)
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Count:SetTextColor(HydraUI:HexToRGB(value))
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateDurationColor = function(value)
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Duration:SetTextColor(HydraUI:HexToRGB(value))
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateCountPosition = function()
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Count:ClearAllPoints()
			Child.Count:SetPoint("CENTER", Child, Settings["auras-count-xoffset"], Settings["auras-count-yoffset"])
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateDurationPosition = function()
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Duration:ClearAllPoints()
			Child.Duration:SetPoint("CENTER", Child, Settings["auras-duration-xoffset"], Settings["auras-duration-yoffset"])
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateDurationAlignment = function(value)
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Duration:SetJustifyH(value)
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

local UpdateCountAlignment = function(value)
	for i = 1, 2 do
		local Child = Auras.Headers[i]:GetAttribute("child1")
		local Index = 1
		
		while Child do
			Child.Count:SetJustifyH(value)
			
			Index = Index + 1
			Child = Auras.Headers[i]:GetAttribute("child" .. Index)
		end
	end
end

GUI:AddWidgets(Language["General"], Language["Auras"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], Language["Enable the HydraUI auras module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("auras-size", Settings["auras-size"], 20, 50, 2, Language["Size"], Language["Set the size of auras"], ReloadUI):RequiresReload(true)
	left:CreateSlider("auras-spacing", Settings["auras-spacing"], 0, 10, 1, Language["Spacing"], Language["Set the spacing between auras"], UpdateAuraSpacing)
	left:CreateSlider("auras-row-spacing", Settings["auras-row-spacing"], 0, 30, 1, Language["Row Spacing"], Language["Set the vertical spacing between aura rows"], UpdateAuraRowSpacing)
	left:CreateSlider("auras-per-row", Settings["auras-per-row"], 8, 16, 1, Language["Auras Per Row"], Language["Set the number of auras per row"], UpdateAurasPerRow)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("auras-font", Settings["auras-font"], Assets:GetFontList(), Language["Font"], "Set the font of the auras", UpdateAuraFont, "Font")
	left:CreateSlider("auras-font-size", Settings["auras-font-size"], 8, 32, 1, "Font Size", "Set the font size of the auras", UpdateAuraFont)
	left:CreateDropdown("auras-font-flags", Settings["auras-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], "Set the font flags of the auras", UpdateAuraFont)
	
	right:CreateHeader(Language["Duration Font"])
	right:CreateSlider("auras-duration-xoffset", Settings["auras-duration-xoffset"], -30, 30, 1, Language["X Offset"], Language["Set the x-axis offset of the duration text"], UpdateDurationPosition)
	right:CreateSlider("auras-duration-yoffset", Settings["auras-duration-yoffset"], -30, 30, 1, Language["Y Offset"], Language["Set the y-axis offset of the duration text"], UpdateDurationPosition)
	right:CreateDropdown("auras-duration-align", Settings["auras-duration-align"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Center"]] = "CENTER"}, Language["Font Alignment"], Language["Set the alignment direction of the font"], UpdateDurationAlignment)
	right:CreateColorSelection("auras-duration-color", Settings["auras-duration-color"], Language["Color"], Language["Set the color of the aura duration"], UpdateDurationColor)
	
	right:CreateHeader(Language["Count Font"])
	right:CreateSlider("auras-count-xoffset", Settings["auras-count-xoffset"], -30, 30, 1, Language["X Offset"], Language["Set the x-axis offset of the count text"], UpdateCountPosition)
	right:CreateSlider("auras-count-yoffset", Settings["auras-count-yoffset"], -30, 30, 1, Language["Y Offset"], Language["Set the y-axis offset of the count text"], UpdateCountPosition)
	right:CreateDropdown("auras-count-align", Settings["auras-count-align"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Center"]] = "CENTER"}, Language["Font Alignment"], Language["Set the alignment direction of the font"], UpdateCountAlignment)
	right:CreateColorSelection("auras-count-color", Settings["auras-count-color"], Language["Color"], Language["Set the color of the aura count"], UpdateCountColor)
end)