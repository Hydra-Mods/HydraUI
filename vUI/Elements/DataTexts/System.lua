local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local floor = floor
local FPSLabel = "FPS"
local MSLabel = "MS"

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 1) then
		self.Text:SetFormattedText("%s: %s %s: %s", FPSLabel, floor(GetFramerate()), MSLabel, select(4, GetNetStats()))
		
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

DT:SetType("System", OnEnable, OnDisable, Update)