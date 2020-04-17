local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local floor = floor
local FPSLabel = "FPS"
local MSLabel = "MS"

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 1) then
		self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s|r |cff%s%s:|r |cff%s%s|r", Settings["data-text-label-color"], FPSLabel, Settings["data-text-value-color"], floor(GetFramerate()), Settings["data-text-label-color"], MSLabel, Settings["data-text-value-color"], select(4, GetNetStats()))
		
		self.Elapsed = 0
	end
end

local OnEnable = function(self)
	self:SetScript("OnUpdate", Update)
	
	self.Elapsed = 0
	
	self:Update(2)
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	
	self.Elapsed = 0
	
	self.Text:SetText("")
end

vUI:AddDataText("System", OnEnable, OnDisable, Update)