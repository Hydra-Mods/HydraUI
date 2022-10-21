local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Label = MAIL_LABEL

local OnEnter = function(self)
	self:SetTooltip()
	
	local One, Two, Three = GetLatestThreeSenders()
	
	if One then
		GameTooltip:AddLine(HAVE_MAIL_FROM)
		
		GameTooltip:AddLine(One, 1, 1, 1)
		GameTooltip:AddLine(Two, 1, 1, 1)
		GameTooltip:AddLine(Three, 1, 1, 1)
		
		GameTooltip:Show()
	end
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self, event)
	local One, Two, Three = GetLatestThreeSenders()
	local Result = 0
	
	if One then
		Result = Result + 1
	end
	
	if Two then
		Result = Result + 1
	end
	
	if Three then
		Result = Result + 1
	end
	
	if (HasNewMail() and Result == 0) then
		Result = Result + 1
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, Result)
end

local OnEnable = function(self)
	self:RegisterEvent("UPDATE_PENDING_MAIL")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update("player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UPDATE_PENDING_MAIL")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText(Label, OnEnable, OnDisable, Update)