local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local UnitLevel = UnitLevel
local Label = Language["Level"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self)
	local Level = UnitLevel("player")
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Level)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", Update)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_LEVEL_UP")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

DT:SetType("Level", OnEnable, OnDisable, Update)