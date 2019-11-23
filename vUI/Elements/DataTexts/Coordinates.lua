local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local floor = floor

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 0.5) then
		local MapID = GetBestMapForUnit("player")
		local Position = GetPlayerMapPosition(MapID, "player")
		local X, Y = Position:GetXY()
		
		X = X * 100
		Y = Y * 100
		
		self.Text:SetFormattedText("%.2f, %.2f", X, Y)
		
		self.Elapsed = 0
	end
end

local OnEnable = function(self)
	self.Elapsed = 0
	self:SetScript("OnUpdate", Update)
	self:Update(1)
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	self.Elapsed = 0
	
	self.Text:SetText("")
end

DT:SetType("Coordinates", OnEnable, OnDisable, Update)