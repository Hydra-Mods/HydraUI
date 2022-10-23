local HydraUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local GetSpeed = GetSpeed
local Label = STAT_SPEED

local OnMouseUp = function()
	if InCombatLockdown() then
		return print(ERR_NOT_IN_COMBAT)
	end

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
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, GetSpeed())
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)

	self:Update()
end

local OnDisable = function(self)
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)

	self.Text:SetText("")
end

HydraUI:AddDataText("Speed", OnEnable, OnDisable, Update)