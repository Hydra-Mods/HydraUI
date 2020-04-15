local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local Auras = vUI:NewModule("Auras")

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
	button:SetBackdrop(vUI.BackdropAndBorder)
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0)
	
	vUI:SetFontInfo(button.duration, Settings["ui-widget-font"], Settings["ui-font-size"])
	button.duration:ClearAllPoints()
	vUI:SetPoint(button.duration, "TOP", button, "BOTTOM", 0, -3)
	button.duration.SetFontObject = function() end
	button.duration.ClearAllPoints = function() end
	
	vUI:SetFontInfo(button.count, Settings["ui-widget-font"], Settings["ui-font-size"])
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
			Enchant:SetBackdrop(vUI.BackdropAndBorder)
			Enchant:SetBackdropColor(0, 0, 0)
			
			local Quality = GetInventoryItemQuality("player", ItemMap[i])
			
			if Quality then
				local Color = ITEM_QUALITY_COLORS[Quality]
				
				Enchant:SetBackdropBorderColor(unpack(Color))
			else
				Enchant:SetBackdropBorderColor(0, 0, 0)
			end
			
			vUI:SetFontInfo(Enchant.duration, Settings["ui-widget-font"], Settings["ui-font-size"])
			Enchant.duration:ClearAllPoints()
			vUI:SetPoint(Enchant.duration, "TOP", Enchant, "BOTTOM", 0, -4)
			Enchant.duration.SetFontObject = function() end
			
			vUI:SetFontInfo(Enchant.count, Settings["ui-widget-font"], Settings["ui-font-size"])
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
				vUI:SetPoint(Aura, "TOPRIGHT", PreviousAura, "TOPLEFT", -2, 0)
			else
				vUI:SetPoint(Aura, "TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
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
			vUI:SetPoint(Aura, "TOP", RowAnchor, "BOTTOM", 0, -Settings["auras-row-spacing"])
			
			RowAnchor = Aura
			NumRows = NumRows + 1
		elseif (Index == 1) then
			vUI:SetPoint(Aura, "TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
			
			RowAnchor = Aura
			NumRows = 1
		else
			if (NumAuras == 1) then
				if PreviousAura then
					vUI:SetPoint(Aura, "TOPRIGHT", PreviousAura, "TOPLEFT", -2, 0)
				else
					vUI:SetPoint(Aura, "TOPRIGHT", Auras.Buffs, "TOPRIGHT", 0, 0)
				end
			else
				vUI:SetPoint(Aura, "RIGHT", PreviousAura, "LEFT", -2, 0)
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
		vUI:SetPoint(Aura, "TOP", _G[name .. (index - Settings["auras-per-row"])], "BOTTOM", 0, -Settings["auras-row-spacing"])
	elseif (index == 1) then
		if (Rows < 2) then
			Aura.offsetY = 1 * ((2 * Settings["auras-spacing"]) + Settings["auras-size"]) -- Make the default UI happy
		else
			Aura.offsetY = Rows * (Settings["auras-spacing"] + Settings["auras-size"])
		end
		
		vUI:SetPoint(Aura, "TOPRIGHT", Auras.Debuffs, "TOPRIGHT", 0, 0)
	else
		vUI:SetPoint(Aura, "RIGHT", _G[name..(index - 1)], "LEFT", -5, 0)
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
	
	vUI:SetSize(Button, Settings["auras-size"])
	
	Name, Texture, Count, DebuffType = UnitAura("player", index, Filter)
	
	if (Name and DebuffType and Filter == "HARMFUL") then
		Button:SetBackdropBorderColor(unpack(vUI.DebuffColors[DebuffType]))
	else
		Button:SetBackdropBorderColor(0, 0, 0)
	end
end

function Auras:Load()
	if (not Settings["auras-enable"]) then
		return
	end
	
	self:Hook("AuraButton_Update")
	self:Hook("BuffFrame_UpdateAllBuffAnchors")
	self:Hook("DebuffButton_UpdateAnchors")
	self:Hook("TemporaryEnchantFrame_Update")
	
	local BuffRows = ceil(BUFF_MAX_DISPLAY / Settings["auras-per-row"])
	local DebuffRows = ceil(DEBUFF_MAX_DISPLAY / Settings["auras-per-row"])
	
	self.Buffs = CreateFrame("Frame", "vUI Buffs", UIParent)
	vUI:SetSize(self.Buffs, (Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * BuffRows) + (Settings["auras-row-spacing"] * (BuffRows - 1))))
	vUI:SetPoint(self.Buffs, "TOPRIGHT", UIParent, "TOPRIGHT", -(Settings["minimap-size"] + 22), -12)
	
	self.Debuffs = CreateFrame("Frame", "vUI Debuffs", UIParent)
	vUI:SetSize(self.Debuffs, (Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * DebuffRows) + Settings["auras-row-spacing"]))
	vUI:SetPoint(self.Debuffs, "TOPRIGHT", self.Buffs, "BOTTOMRIGHT", 0, -2)
	
	vUI:CreateMover(self.Buffs)
	vUI:CreateMover(self.Debuffs)
	
	SkinTempEnchants()
	
	BuffFrame_Update()
end

local UpdateSizes = function()
	-- Resize movers
	local BuffRows = ceil(BUFF_MAX_DISPLAY / Settings["auras-per-row"])
	local DebuffRows = ceil(DEBUFF_MAX_DISPLAY / Settings["auras-per-row"])
	
	vUI:SetSize(Auras.Buffs, (Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * BuffRows) + (Settings["auras-row-spacing"] * (BuffRows - 1))))
	vUI:SetSize(Auras.Debuffs, (Settings["auras-per-row"] * Settings["auras-size"] + Settings["auras-per-row"] * Settings["auras-spacing"]), ((Settings["auras-size"] * DebuffRows) + Settings["auras-row-spacing"]))
	
	BuffFrame_Update()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Auras"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], Language["Enable the vUI auras module"], ReloadUI):RequiresReload(true)
	Right:CreateHeader(Language["Styling"])
	Right:CreateSlider("auras-size", Settings["auras-size"], 20, 40, 1, Language["Size"], Language["Set the size of auras"], UpdateSizes)
	Right:CreateSlider("auras-spacing", Settings["auras-spacing"], 0, 10, 1, Language["Spacing"], Language["Set the spacing between auras"], UpdateSizes)
	Right:CreateSlider("auras-row-spacing", Settings["auras-row-spacing"], 0, 30, 1, Language["Row Spacing"], Language["Set the vertical spacing between aura rows"], UpdateSizes)
	Right:CreateSlider("auras-per-row", Settings["auras-per-row"], 8, 16, 1, Language["Display Per Row"], Language["Set the number of auras per row"], UpdateSizes)
end)