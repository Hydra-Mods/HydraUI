local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local GetAverageItemLevel = GetAverageItemLevel
local Label = STAT_AVERAGE_ITEM_LEVEL

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local Average, Equipped, PVP = GetAverageItemLevel()
	
	if (Equipped ~= Average) then
		GameTooltip:AddLine(format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(Average) .. " " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, Equipped), 1, 1, 1)
	else
		GameTooltip:AddLine(format(PAPERDOLLFRAME_TOOLTIP_FORMAT, Label), 1, 1, 1)
	end
	
	GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL_TOOLTIP)
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	local Average, Equipped = GetAverageItemLevel()
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%d|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Equipped)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

vUI:AddDataText(Label, OnEnable, OnDisable, Update)