local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local GetSpeed = GetSpeed
local Label = STAT_SPEED

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Speed = GetSpeed()
	
	GameTooltip:AddLine(Label, 1, 1, 1)
	GameTooltip:AddLine(format(CR_SPEED_TOOLTIP, HydraUI:Comma(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)), nil, nil, nil, true)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], GetSpeed())
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:SetScript("OnUpdate", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Speed", OnEnable, OnDisable, Update)