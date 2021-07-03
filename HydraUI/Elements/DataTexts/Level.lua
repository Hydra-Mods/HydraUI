local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local UnitLevel = UnitLevel
local Label = Language["Level"]

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], UnitLevel("player"))
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_LEVEL_UP")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Level", OnEnable, OnDisable, Update)