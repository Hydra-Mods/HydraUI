local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local CR_HASTE_MELEE = CR_HASTE_MELEE
local GetHaste = GetHaste
local Label = STAT_HASTE

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	GameTooltip:AddLine(format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE), 1, 1, 1)
	
	local Tooltip
	
	if _G["STAT_HASTE_" .. vUI.UserClass .. "_TOOLTIP"] then
		Tooltip = _G["STAT_HASTE_" .. vUI.UserClass .. "_TOOLTIP"]
	else
		Tooltip = STAT_HASTE_TOOLTIP
	end
	
	Tooltip = Tooltip .. format(STAT_HASTE_BASE_TOOLTIP, vUI:Comma(GetCombatRating(CR_HASTE_MELEE)), vUI:Comma(GetCombatRatingBonus(CR_HASTE_MELEE)))
	
	GameTooltip:AddLine(Tooltip)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%.2f%%|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], GetHaste())
end

local OnEnable = function(self)
	self:RegisterUnitEvent("UNIT_STATS", "player")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("HONOR_XP_UPDATE")
	self:UnregisterEvent("HONOR_LEVEL_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText(Label, OnEnable, OnDisable, Update)