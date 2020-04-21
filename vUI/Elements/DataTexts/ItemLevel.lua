local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetAverageItemLevel = GetAverageItemLevel
local Label = Language["Item Level"]

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local Average, Equipped, PVP = GetAverageItemLevel()
	
	GameTooltip:AddLine(Label)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(Language["Average:"], format("%.2f", Average), 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["Equipped:"], format("%.2f", Equipped), 1, 1, 1)
	GameTooltip:AddDoubleLine(Language["PVP:"], format("%.2f", PVP), 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local Average, Equipped, PVP = GetAverageItemLevel()
	
	self.Text:SetFormattedText("|cFF%s%s: |cFF%s%.2f|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Equipped)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText(Label, OnEnable, OnDisable, Update)