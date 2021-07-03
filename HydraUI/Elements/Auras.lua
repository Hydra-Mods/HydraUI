local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Auras = HydraUI:NewModule("Auras")

-- Default settings values
Defaults["auras-enable"] = true
Defaults["auras-size"] = 30
Defaults["auras-spacing"] = 2
Defaults["auras-row-spacing"] = 16
Defaults["auras-per-row"] = 12

local Name, Texture, Count, DebuffType
local UnitAura = UnitAura
local ceil = math.ceil
local unpack = unpack
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local GetInventoryItemQuality = GetInventoryItemQuality

--BUFF_MIN_ALPHA = 0.5

local ItemMap = {
	[0] = 16, -- Main hand
	[1] = 17, -- Off-hand
	[2] = 18, -- Ranged
}

local SkinAura = function(button, name, index)
	--[[button:SetBackdrop(HydraUI.BackdropAndBorder)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0)]]
	
	HydraUI:SetFontInfo(button.duration, Settings["ui-widget-font"], Settings["ui-font-size"])
	button.duration:ClearAllPoints()
	button.duration:SetPoint("TOP", button, "BOTTOM", 0, -3)
	button.duration.SetFontObject = function() end
	button.duration.ClearAllPoints = function() end
	
	HydraUI:SetFontInfo(button.count, Settings["ui-widget-font"], Settings["ui-font-size"])
	button.count.SetFontObject = function() end
	
	local Icon = _G[name .. index .. "Icon"]
	local Border = _G[name .. index .. "Border"]
	
	if Icon then
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if Border then
		Border:SetTexture(nil)
	end
	
	button.Handled = true
end

Auras.TemporaryEnchantFrame_Update = function()
	local Enchant
	local Index
	
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		Index = i - 1
		Enchant = _G["TempEnchant" .. Index]
		
		if Enchant then
			local Quality = GetInventoryItemQuality("player", ItemMap[i])
			
			if Quality then
				local Color = ITEM_QUALITY_COLORS[Quality]
				
				Enchant:SetBackdropBorderColor(Color.r, Color.g, Color.b)
			else
				Enchant:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
	
	Auras.BuffFrame_UpdateAllBuffAnchors()
end

local SkinTempEnchants = function()
	local Enchant
	local Index
	
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		Index = i - 1
		Enchant = _G["TempEnchant" .. Index]
		
		if Enchant then
			Enchant:SetParent(Auras.Buffs)
			--[[Enchant:SetBackdrop(HydraUI.BackdropAndBorder)
			Enchant:SetBackdropColor(0, 0, 0)
			
			local Quality = GetInventoryItemQuality("player", ItemMap[i])
			
			if Quality then
				local Color = ITEM_QUALITY_COLORS[Quality]
				
				Enchant:SetBackdropBorderColor(unpack(Color))
			else
				Enchant:SetBackdropBorderColor(0, 0, 0)
			end]]
			
			HydraUI:SetFontInfo(Enchant.duration, Settings["ui-widget-font"], Settings["ui-font-size"])
			Enchant.duration:ClearAllPoints()
			Enchant.duration:SetPoint("TOP", Enchant, "BOTTOM", 0, -4)
			Enchant.duration.SetFontObject = function() end
			
			HydraUI:SetFontInfo(Enchant.count, Settings["ui-widget-font"], Settings["ui-font-size"])
			Enchant.count.SetFontObject = function() end
			
			local Icon = _G["TempEnchant" .. Index .. "Icon"]
			local Border = _G["TempEnchant" .. Index .. "Border"]
			
			if Icon then
				Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end
			
			if Border then
				Border:SetTexture(nil)
			end
		end
	end
end

Auras.BuffFrame_UpdateAllBuffAnchors = function()
	local Aura
	local PreviousAura
	local NumEnchants = BuffFrame.numEnchants
	local NumAuras = 0
	local NumRows = 0
	local RowAnchor
	local Index
	
	-- Position Temp Enchants
	for i = 1, NUM_TEMP_ENCHANT_FRAMES do
		Aura = _G["TempEnchant" .. (i - 1)]
		
		if Aura then
			Aura:ClearAllPoints()
			
			if PreviousAura then
				Aura:SetPoint("TOPRIGHT", PreviousAura, "TOPLEFT", -2, 0)
			else
				Aura:SetPoint("TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
			end
			
			PreviousAura = Aura
		end
	end
	
	-- Position Buffs
	for i = 1, BUFF_ACTUAL_DISPLAY do
		Aura = _G["BuffButton" .. i]
		
		NumAuras = NumAuras + 1
		Index = NumAuras + NumEnchants
		
		Aura:ClearAllPoints()
		
		if (Index > 1 and (Index % Settings["auras-per-row"] == 1)) then
			Aura:SetPoint("TOP", RowAnchor, "BOTTOM", 0, -Settings["auras-row-spacing"])
			
			RowAnchor = Aura
			NumRows = NumRows + 1
		elseif (Index == 1) then
			Aura:SetPoint("TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
			
			RowAnchor = Aura
			NumRows = 1
		else
			if (NumAuras == 1) then
				if PreviousAura then
					Aura:SetPoint("TOPRIGHT", PreviousAura, "TOPLEFT", -2, 0)
				else
					Aura:SetPoint("TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
				end
			else
				Aura:SetPoint("RIGHT", PreviousAura, "LEFT", -2, 0)
			end
		end
		
		PreviousAura = Aura
	end
end

Auras.DebuffButton_UpdateAnchors = function(name, index)
	local NumAuras = BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants
	local Rows = ceil(NumAuras / BUFFS_PER_ROW)
	local Aura = _G[name .. index]
	
	Aura:ClearAllPoints()
	
	if ((index > 1) and (index % Settings["auras-per-row"] == 1)) then
		Aura:SetPoint("TOP", _G[name .. (index - Settings["auras-per-row"])], "BOTTOM", 0, -Settings["auras-row-spacing"])
	elseif (index == 1) then
		if (Rows < 2) then
			Aura.offsetY = 1 * ((2 * Settings["auras-spacing"]) + Settings["auras-size"]) -- Make the default UI happy
		else
			Aura.offsetY = Rows * (Settings["auras-spacing"] + Settings["auras-size"])
		end
		
		Aura:SetPoint("TOPRIGHT", Auras.Debuffs, "TOPRIGHT", 0, 0)
	else
		Aura:SetPoint("RIGHT", _G[name..(index - 1)], "LEFT", -5, 0)
	end
end

Auras.AuraButton_Update = function(name, index)
	local Button = _G[name .. index]
	local Filter = name == "BuffButton" and "HELPFUL" or "HARMFUL"
	
	if (not Button) then
		return
	end
	
	if (not Button.Handled) then
		SkinAura(Button, name, index)
	end
	
	Button:SetSize(Settings["auras-size"], Settings["auras-size"])
	
	Name, Texture, Count, DebuffType = UnitAura("player", index, Filter)
	
	--[[if (Name and DebuffType and Filter == "HARMFUL") then
		Button:SetBackdropBorderColor(unpack(HydraUI.DebuffColors[DebuffType]))
	else
		Button:SetBackdropBorderColor(0, 0, 0)
	end]]
end

function Auras:Load()
	if (not Settings["auras-enable"]) then
		return
	end
	
	self:Hook("AuraButton_Update")
	self:Hook("BuffFrame_UpdateAllBuffAnchors")
	self:Hook("DebuffButton_UpdateAnchors")
	--self:Hook("TemporaryEnchantFrame_Update")
	
	local BuffRows = ceil(BUFF_MAX_DISPLAY / Settings["auras-per-row"])
	local DebuffRows = ceil(DEBUFF_MAX_DISPLAY / Settings["auras-per-row"])
	
	self.Buffs = CreateFrame("Frame", "HydraUI Buffs", HydraUI.UIParent)
	self.Buffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * BuffRows) + (Settings["auras-row-spacing"] * (BuffRows - 1))))
	self.Buffs:SetPoint("TOPRIGHT", HydraUI.UIParent, "TOPRIGHT", -(Settings["minimap-size"] + 22), -12)
	
	self.Debuffs = CreateFrame("Frame", "HydraUI Debuffs", HydraUI.UIParent)
	self.Debuffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * DebuffRows) + Settings["auras-row-spacing"]))
	self.Debuffs:SetPoint("TOPRIGHT", self.Buffs, "BOTTOMRIGHT", 0, -2)
	
	HydraUI:CreateMover(self.Buffs)
	HydraUI:CreateMover(self.Debuffs)
	
	SkinTempEnchants()
	
	BuffFrame_Update()
end

local UpdateSizes = function()
	-- Resize movers
	local BuffRows = ceil(BUFF_MAX_DISPLAY / Settings["auras-per-row"])
	local DebuffRows = ceil(DEBUFF_MAX_DISPLAY / Settings["auras-per-row"])
	
	Auras.Buffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * BuffRows) + (Settings["auras-row-spacing"] * (BuffRows - 1))))
	Auras.Debuffs:SetSize((Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * DebuffRows) + Settings["auras-row-spacing"]))
	
	BuffFrame_Update()
end

GUI:AddWidgets(Language["General"], Language["Auras"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], Language["Enable the HydraUI auras module"], ReloadUI):RequiresReload(true)
	
	right:CreateHeader(Language["Styling"])
	right:CreateSlider("auras-size", Settings["auras-size"], 20, 40, 1, Language["Size"], Language["Set the size of auras"], UpdateSizes)
	right:CreateSlider("auras-spacing", Settings["auras-spacing"], 0, 10, 1, Language["Spacing"], Language["Set the spacing between auras"], UpdateSizes)
	right:CreateSlider("auras-row-spacing", Settings["auras-row-spacing"], 0, 30, 1, Language["Row Spacing"], Language["Set the vertical spacing between aura rows"], UpdateSizes)
	right:CreateSlider("auras-per-row", Settings["auras-per-row"], 8, 16, 1, Language["Display Per Row"], Language["Set the number of auras per row"], UpdateSizes)
end)