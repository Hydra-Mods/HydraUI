local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local floor = floor
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local Label = HONOR

local OnEnter = function(self)
	self:SetTooltip()
	
	local Honor = UnitHonor("player")
	local MaxHonor = UnitHonorMax("player")
	local HonorLevel = UnitHonorLevel("player")
	local NextRewardLevel = C_PvP.GetNextHonorLevelForReward(HonorLevel)
	local RewardInfo = C_PvP.GetHonorRewardInfo(NextRewardLevel)
	local Percent = floor((Honor / MaxHonor * 100 + 0.05) * 10) / 10
	local Remaining = MaxHonor - Honor
	local RemainingPercent = floor((Remaining / MaxHonor * 100 + 0.05) * 10) / 10
	local Kills = GetPVPLifetimeStats()
	
	GameTooltip:AddLine(format(HONOR_LEVEL_TOOLTIP, HonorLevel))
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Current honor"])
	GameTooltip:AddDoubleLine(format("%s / %s", HydraUI:Comma(Honor), HydraUI:Comma(MaxHonor)), format("%s%%", Percent), 1, 1, 1, 1, 1, 1)
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Remaining honor"])
	GameTooltip:AddDoubleLine(format("%s", HydraUI:Comma(Remaining)), format("%s%%", RemainingPercent), 1, 1, 1, 1, 1, 1)
	
	if (Kills > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(HONORABLE_KILLS)
		GameTooltip:AddLine(HydraUI:Comma(Kills), 1, 1, 1)
	end
	
	if RewardInfo then
		local RewardText = select(11, GetAchievementInfo(RewardInfo.achievementRewardedID))
		
		if RewardText:match("%S") then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(NextRewardLevel))
			GameTooltip:AddLine(RewardText, 1, 1, 1)
		end
	end
	
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	PVEFrame_ToggleFrame("PVPUIFrame", "HonorFrame")
end

local Update = function(self, event, unit)
	if (unit and unit ~= "player") then
		return
	end
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s / %s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], UnitHonor("player"), UnitHonorMax("player"))
end

local OnEnable = function(self)
	self:RegisterUnitEvent("HONOR_XP_UPDATE", "player")
	self:RegisterEvent("HONOR_LEVEL_UPDATE")
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

HydraUI:AddDataText("Honor", OnEnable, OnDisable, Update)