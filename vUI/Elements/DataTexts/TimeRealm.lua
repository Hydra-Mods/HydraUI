local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GameTime_GetGameTime = GameTime_GetGameTime

local OnMouseUp = function(self, button)
	if (button == "LeftButton") then
		TimeManager_Toggle()
	else
		ToggleCalendar()
	end
end

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local HomeLatency, WorldLatency = select(3, GetNetStats())
	local Framerate = floor(GetFramerate())
	local LocalTime = GameTime_GetLocalTime(true)
	
	GameTooltip:AddLine(Language["Local Time:"], 1, 0.7, 0)
	GameTooltip:AddLine(LocalTime, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Latency:"], 1, 0.7, 0)
	GameTooltip:AddLine(format(Language["%s ms (home)"], HomeLatency), 1, 1, 1)
	GameTooltip:AddLine(format(Language["%s ms (world)"], WorldLatency), 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Framerate:"], 1, 0.7, 0)
	GameTooltip:AddLine(Framerate .. " fps", 1, 1, 1)

	GameTooltip:Show()
end

local Update = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed
	
	if (self.Elapsed > 10) then
		self.Text:SetText(GameTime_GetGameTime(true))
		
		self.Elapsed = 0
	end
end

local OnEnable = function(self)
	self:SetScript("OnUpdate", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self.Elapsed = 0
	
	self:Update(11)
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Elapsed = 0
	
	self.Text:SetText("")
end

DT:SetType("Time - Realm", OnEnable, OnDisable, Update)