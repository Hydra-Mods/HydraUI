local HydraUI, Language, Assets, Settings = select(2, ...):get()

local Message = BONUS_OBJECTIVE_EXPERIENCE_FORMAT

local OnMouseUp = function()
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	self:SetTooltip()

	local Rested = GetXPExhaustion()
	local XP = UnitXP("player")
	local Max = UnitXPMax("player")

	local Percent = floor((XP / Max * 100 + 0.05) * 10) / 10
	local Remaining = Max - XP
	local RemainingPercent = floor((Remaining / Max * 100 + 0.05) * 10) / 10

	GameTooltip:AddLine(LEVEL .. " " .. UnitLevel("player"))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Current Experience"])
	GameTooltip:AddDoubleLine(format("%s / %s", HydraUI:Comma(XP), HydraUI:Comma(Max)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining Experience"])
	GameTooltip:AddDoubleLine(format("%s", HydraUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)

	if Rested then
		local RestedPercent = floor((Rested / Max * 100 + 0.05) * 10) / 10

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Language["Rested Experience"])
		GameTooltip:AddDoubleLine(HydraUI:Comma(Rested), format("%s%%", RestedPercent), 1, 1, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Update = function(self)
	if (UnitLevel("player") == MAX_PLAYER_LEVEL) then
		self:Disable()
		self.Text:SetText(GUILD_RECRUITMENT_MAXLEVEL)

		return
	end

    local XP = UnitXP("player")
    local MaxXP = UnitXPMax("player")
	local Value = "|cff" .. HydraUI.ValueColor .. floor((XP / MaxXP * 100 + 0.05) * 10) / 10 .. "%|r"

	self.Text:SetFormattedText(Message, Value)
end

local OnEnable = function(self)
	self:RegisterEvent("PLAYER_XP_UPDATE")
	self:RegisterEvent("PLAYER_UPDATE_RESTING")
	self:RegisterEvent("UPDATE_EXHAUSTION")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)

	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("PLAYER_XP_UPDATE")
	self:UnregisterEvent("PLAYER_UPDATE_RESTING")
	self:UnregisterEvent("UPDATE_EXHAUSTION")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")

	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)

	self.Text:SetText("")
end

HydraUI:AddDataText(POWER_TYPE_EXPERIENCE, OnEnable, OnDisable, Update)