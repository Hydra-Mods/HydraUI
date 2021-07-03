local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Gold = HydraUI:GetModule("Gold")

local GetMoney = GetMoney

local OnEnter = function(self)
	self:SetTooltip()
	
	local TrashValue = select(2, HydraUI:GetTrashValue())
	local ServerInfo, ServerTotalGold = Gold:GetServerInfo()
	local Change = Gold:GetSessionStats()
	
	GameTooltip:AddLine(HydraUI.UserRealm)
	GameTooltip:AddLine(" ")
	
	if (#ServerInfo > 1) then
		GameTooltip:AddDoubleLine(Language["Total"], HydraUI:CopperToGold(ServerTotalGold), 1, 0.82, 0, 1, 1, 1)
		GameTooltip:AddLine(" ")
	end
	
	for i = 1, #ServerInfo do
		GameTooltip:AddDoubleLine(ServerInfo[i][1], HydraUI:CopperToGold(ServerInfo[i][2]), 1, 1, 1, 1, 1, 1)
	end
	
	if (Change ~= 0) then
		GameTooltip:AddLine(" ")
		
		if (Change > 0) then
			GameTooltip:AddDoubleLine(Language["Session:"], HydraUI:CopperToGold(Change), 1, 1, 1, 0.4, 1, 0.4)
		else
			GameTooltip:AddDoubleLine(Language["Session:"], HydraUI:CopperToGold(Change * -1), 1, 1, 1, 1, 0.4, 0.4)
		end
	end
	
	if (TrashValue > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(Language["|cFF9D9D9D[Poor quality]|r item value:"], HydraUI:CopperToGold(TrashValue), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s|r", Settings["data-text-label-color"], HydraUI:CopperToGold(GetMoney()))
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", ToggleAllBags)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_MONEY")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Gold", OnEnable, OnDisable, Update)