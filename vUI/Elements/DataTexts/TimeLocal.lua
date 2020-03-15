local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GameTime_GetLocalTime = GameTime_GetLocalTime

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 10) then
		self.Text:SetText(GameTime_GetLocalTime(true))
		
		self.Elapsed = 0
	end
end

local OnEnable = function(self)
	self:SetScript("OnUpdate", Update)
	
	self.Elapsed = 0
	
	self:Update(11)
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	
	self.Elapsed = 0
	
	self.Text:SetText("")
end

DT:SetType("Time - Local", OnEnable, OnDisable, Update)