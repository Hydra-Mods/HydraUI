local HydraUI, Language, Assets, Settings = select(2, ...):get()

local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local Label = HONOR

local OnEnter = function(self)
	self:SetTooltip()

	local HK = GetPVPSessionStats()
	local Rank = UnitPVPRank("player")

	if (Rank > 0) then
		local Name, Number = GetPVPRankInfo(Rank, "player")

		GameTooltip:AddDoubleLine(Name, format("%s %s", RANK, Number), 1, 1, 1, 1, 1, 1)
	end

	if (HK > 0) then
		if (Rank > 0) then
			GameTooltip:AddLine(" ")
		end

		GameTooltip:AddLine(HONOR_TODAY)
		GameTooltip:AddDoubleLine(HONORABLE_KILLS, HydraUI:Comma(HK), 1, 1, 1, 1, 1, 1)
	end

	HK = GetPVPLifetimeStats()

	if (HK > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(HONOR_LIFETIME)
		GameTooltip:AddDoubleLine(HONORABLE_KILLS, HydraUI:Comma(HK), 1, 1, 1, 1, 1, 1)
	end

	-- GetCurrentArenaSeason()


	--[[
		if IsInArenaTeam() then -- Inside OnEnable
			self:RegisterEvent("ARENA_TEAM_ROSTER_UPDATE")

			ArenaTeamRoster(1)
			ArenaTeamRoster(2)
			ArenaTeamRoster(3)
		end

		-- Inside tooltip
		local name, rank, level, class, online, played, win, seasonPlayed, seasonWin, personalRating = GetArenaTeamRosterInfo(teamindex, playerid); teamindex=1-3, playerid=1-5
	--]]

	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	if HydraUI.IsClassic then
		ToggleCharacter("HonorFrame")
	elseif HydraUI.IsWrath then
		TogglePVPFrame()
	else
		ToggleCharacter("PVPFrame")
	end
end

local Update = function(self)
	local Info = GetCurrencyInfo(1901)

	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s |r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, Info.quantity)
end

local OnEnable = function(self)
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)

	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)

	self.Text:SetText("")
end

HydraUI:AddDataText("Honor", OnEnable, OnDisable, Update)