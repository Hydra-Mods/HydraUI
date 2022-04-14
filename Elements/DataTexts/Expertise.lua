local HydraUI, Language, Assets, Settings = select(2, ...):get()

local GetExpertisePercent = GetExpertisePercent
local Label = STAT_EXPERTISE

local OnEnter = function(self)
	self:SetTooltip()
	
	local Expertise, OffhandExpertise = GetExpertise()
	local Speed, OffhandSpeed = UnitAttackSpeed("player")
	local Text
	
	if OffhandSpeed then
		Text = Expertise .. " / " .. OffhandExpertise
	else
		Text = Expertise
	end
	
	GameTooltip:AddLine(Label .. " " .. Text)
	GameTooltip:AddLine(" ")
	
	local Percent, OffhandPercent = GetExpertisePercent()
	Percent = format("%.2f%%", Percent)
	
	if OffhandSpeed then
		Text = Percent .. " / " .. format("%.2f%%", OffhandPercent)
	else
		Text = Percent
	end
	
	GameTooltip:AddLine(format(CR_EXPERTISE_TOOLTIP, Text, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE)), 1, 1, 1)
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], GetExpertisePercent() .. "%")
end

local OnEnable = function(self)
	self:RegisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	
	self:Update(nil, "player")
end

local OnDisable = function(self)
	self:UnregisterEvent("UNIT_STATS")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText(Label, OnEnable, OnDisable, Update)