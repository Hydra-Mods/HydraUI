local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local format = format
local date = date

local SecondsToTime = function(seconds)
	return format("%s:%s", date("%M", seconds), date("%S", seconds))
end

local OnUpdate = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	self.Throttle = self.Throttle + elapsed
	
	if (self.Throttle > 1) then
		self.Text:SetText(format("|cff%s%s|r", Settings["data-text-value-color"], SecondsToTime(self.Elapsed)))
		
		self.Throttle = 0
	end
end

local OnEvent = function(self, event)
	if (event == "PLAYER_REGEN_DISABLED") then
		self.Elapsed = 0
		self.Throttle = 0
		self:SetScript("OnUpdate", OnUpdate)
		self.Text:SetTextColorHex(Settings["ui-widget-color"])
	elseif (event == "PLAYER_REGEN_ENABLED") then
		self:SetScript("OnUpdate", nil)
		self.Text:SetTextColor(1, 1, 1)
	end
end

local OnEnable = function(self)
	self.Elapsed = 0
	self.Throttle = 0
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", OnEvent)
	
	self.Text:SetText(SecondsToTime(self.Elapsed))
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnUpdate", nil)
	
	self.Elapsed = 0
	self.Throttle = 0
	
	self.Text:SetText("")
end

vUI:AddDataText("Combat Time", OnEnable, OnDisable, Update)