local HydraUI, Language, Assets, Settings = select(2, ...):get()

local OnMouseUp = function()
	ToggleCharacter("ReputationFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if (not Name) then
		return
	end
	
	GameTooltip:AddLine(Name)
	GameTooltip:AddLine(" ")
	
	Max = Max - Min
	Value = Value - Min
	
	local Remaining = Max - Value
	local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10
	
	GameTooltip:AddLine(Language["Current reputation"])
	GameTooltip:AddDoubleLine(format("%s / %s", HydraUI:Comma(Value), HydraUI:Comma(Max)), format("%s%%", floor((Value / Max * 100 + 0.05) * 10) / 10), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining reputation"])
	GameTooltip:AddDoubleLine(format("%s", HydraUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Faction standing"])
	GameTooltip:AddLine(_G["FACTION_STANDING_LABEL" .. StandingID], 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local Name, StandingID, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	
	if Name then
		Max = Max - Min
		Value = Value - Min
		
		self.Text:SetText(format("|cff%s%s%%|r", HydraUI.ValueColor, floor((Value / Max * 100 + 0.05) * 10) / 10 ))
	else
		self.Text:SetText("")
	end
end

local OnEnable = function(self)
	self:RegisterEvent("UPDATE_FACTION")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("UPDATE_FACTION")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText(REPUTATION, OnEnable, OnDisable, Update)