local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local floor = floor
local select = select
local FPSLabel = Language["FPS"]
local MSLabel = Language["MS"]

local OnEnter = function(self)
	self:SetTooltip()
	
	local HomeLatency, WorldLatency = select(3, GetNetStats())
	
	GameTooltip:AddLine(Language["Latency:"], 1, 0.7, 0)
	GameTooltip:AddLine(format(Language["%s ms (home)"], HomeLatency), 1, 1, 1)
	GameTooltip:AddLine(format(Language["%s ms (world)"], WorldLatency), 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 1) then
		self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r |cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], FPSLabel, Settings["data-text-value-color"], floor(GetFramerate()), Settings["data-text-label-color"], MSLabel, Settings["data-text-value-color"], select(4, GetNetStats()))
		
		self.Elapsed = 0
	end
end

local OnEnable = function(self)
	self:SetScript("OnUpdate", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self.Elapsed = 0
	
	self:Update(2)
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Elapsed = 0
	
	self.Text:SetText("")
end

HydraUI:AddDataText("System", OnEnable, OnDisable, Update)