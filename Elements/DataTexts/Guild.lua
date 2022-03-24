local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local IsInGuild = IsInGuild
local GuildRoster = C_GuildInfo.GuildRoster
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local select = select
local format = format
local match = string.match
local Label = GUILD

local MaxCharacters = 30

local StatusLabels = {
	[1] = "|cFFFFFF33" .. CHAT_FLAG_AFK .. "|r",
	[2] = "|cFFFF6666" .. CHAT_FLAG_DND .. "|r",
}

local OnUpdate = function(self, elapsed)
	self.Elapsed = self.Elapsed + elapsed

	if (self.Elapsed > 10) then
		GuildRoster()

		self.Elapsed = 0
	end
end

local OnEnter = function(self)
	if (not IsInGuild()) then
		return
	end
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	self:SetTooltip()
	
	GuildRoster()
	
	local GuildName = GetGuildInfo("player")
	local NumTotal, NumOnline, NumOnlineAndMobile = GetNumGuildMembers()
	local GuildMessage = GetGuildRosterMOTD()
	local Name, Rank, RankIndex, Level, ClassName, Zone, Note, OfficerNote, Online, Status, Class
	local Color, LevelColor
	
	GameTooltip:AddDoubleLine(GuildName, format("%s/%s", NumOnlineAndMobile, NumTotal), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddLine(" ")
	
	if (GuildMessage and GuildMessage ~= "") then
		GameTooltip:AddLine(GUILD_MOTD_LABEL2)
		GameTooltip:AddLine(GuildMessage, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
	end
	
	local Limit = NumTotal > MaxCharacters and MaxCharacters or NumTotal
	local Count = 0
	
	for i = 1, NumTotal do
		if (Count == Limit) then
			break
		end
		
		Name, Rank, RankIndex, Level, ClassName, Zone, Note, OfficerNote, Online, Status, Class = GetGuildRosterInfo(i)
		
		if (Name and Online) then
			Name = match(Name, "(%S+)-%S+")
			Color = RAID_CLASS_COLORS[Class].colorStr
			LevelColor = GetQuestDifficultyColor(Level)
			LevelColor = HydraUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
			
			if StatusLabels[Status] then
				Name = format("|cFF%s%s |c%s%s|r %s", LevelColor, Level, Color, Name, StatusLabels[Status])
			else
				Name = format("|cFF%s%s |c%s%s|r", LevelColor, Level, Color, Name)
			end
			
			if IsModifierKeyDown() then
				GameTooltip:AddDoubleLine(Name, Rank, nil, nil, nil, 1, 1, 1)
			else
				if (Zone == GetRealZoneText()) then
					Zone = format("|cFF33FF33%s|r", Zone)
				end
				
				GameTooltip:AddDoubleLine(Name, Zone or UNKNOWN, nil, nil, nil, 1, 1, 1)
			end
			
			Count = Count + 1
		end
	end
	
	if (NumOnlineAndMobile > MaxCharacters) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(NumOnlineAndMobile - MaxCharacters .. Language[" more characters not shown"], 1, 1, 1)
	end
	
	self.TooltipShown = true
	
	if (not self:GetScript("OnUpdate")) then
		self.Elapsed = 0
		self:SetScript("OnUpdate", OnUpdate)
	end
	
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self.TooltipShown = false
	
	if self:GetScript("OnUpdate") then
		self:SetScript("OnUpdate", nil)
	end
end

local Update = function(self, event)
	if (not IsInGuild()) then
		self.Text:SetText(Language["No Guild"])
		
		return
	end
	
	if (event == "MODIFIER_STATE_CHANGED") then
		GameTooltip:ClearLines()
		OnEnter(self)
	else
		if self.TooltipShown then
			GameTooltip:ClearLines()
			OnEnter(self)
		else
			GuildRoster()
		end
		
		self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], select(3, GetNumGuildMembers()))
	end
end

local OnMouseUp = function()
	if InCombatLockdown() then
		return print(ERR_NOT_IN_COMBAT)
	end
	
	ToggleCommunitiesFrame()
end

local OnEnable = function(self)
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_GUILD_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnUpdate", nil)

	if self.Elapsed then
		self.Elapsed = 0
	end
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Guild", OnEnable, OnDisable, Update)