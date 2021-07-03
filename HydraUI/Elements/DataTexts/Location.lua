local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo

local OnEnter = function(self)
	self:SetTooltip()
	
	local ZoneText = GetRealZoneText()
	local SubZoneText = GetMinimapZoneText()
	local PVPType, IsFFA, Faction = GetZonePVPInfo()
	local Color = HydraUI.ZoneColors[PVPType or "other"]
	local Label
	
	if (ZoneText ~= SubZoneText) then
		Label = format("%s - %s", SubZoneText, ZoneText)
	else
		Label = ZoneText
	end
	
	GameTooltip:AddLine(Label, Color[1], Color[2], Color[3])
	
	if (PVPType == "friendly" or PVPType == "hostile") then
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, Faction), Color[1], Color[2], Color[3])
	elseif (PVPType == "sanctuary") then
		GameTooltip:AddLine(SANCTUARY_TERRITORY, Color[1], Color[2], Color[3])
	elseif IsFFA then
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, Color[1], Color[2], Color[3])
	else
		GameTooltip:AddLine(CONTESTED_TERRITORY, Color[1], Color[2], Color[3])
	end
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
	self.TooltipShown = false
end

local Update = function(self)
	local Color = HydraUI.ZoneColors[GetZonePVPInfo() or "other"]
	
	self.Text:SetText(GetMinimapZoneText())
	self.Text:SetTextColor(Color[1], Color[2], Color[3])
	
	if self.TooltipShown then
		GameTooltip:ClearLines()
		OnEnter(self)
	end
end

local OnEnable = function(self)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
	self.Text:SetTextColor(1, 1, 1)
end

HydraUI:AddDataText("Location", OnEnable, OnDisable, Update)