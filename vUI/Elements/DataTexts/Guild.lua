local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local IsInGuild = IsInGuild
local GuildRoster = GuildRoster
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local select = select
local format = format
local match = string.match
local Label = Language["Guild"]

local MaxCharacters = 30

local StatusLabels = {
	[1] = Language["|cFFFFFF33AFK|r"],
	[2] = Language["|cFFFF6666DND|r"],
}

local OnEnter = function(self)
	if (not IsInGuild()) then
		return
	end
	
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	GuildRoster()
	
	local GuildName = GetGuildInfo("player")
	local NumTotal, NumOnline, NumOnlineAndMobile = GetNumGuildMembers()
	--local GuildMessage = GetGuildRosterMOTD()
	local Name, Rank, RankIndex, Level, ClassName, Zone, Note, OfficerNote, Online, Status, Class
	local Color, LevelColor
	
	GameTooltip:AddDoubleLine(GuildName, format("%s/%s", NumOnlineAndMobile, NumTotal))
	GameTooltip:AddLine(" ")
	
	--[[if (GuildMessage and GuildMessage ~= "") then
		GameTooltip:AddLine(GuildMessage)
		GameTooltip:AddLine(" ")
	end]]
	
	local Limit = NumOnlineAndMobile > MaxCharacters and MaxCharacters or NumOnlineAndMobile
	
	for i = 1, Limit do
		Name, Rank, RankIndex, Level, ClassName, Zone, Note, OfficerNote, Online, Status, Class = GetGuildRosterInfo(i)
		
		if Name then
			Name = match(Name, "(%S+)-%S+")
			Color = RAID_CLASS_COLORS[Class].colorStr
			LevelColor = GetQuestDifficultyColor(Level)
			LevelColor = vUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
			
			if StatusLabels[Status] then
				Name = format("|cFF%s%s |c%s%s|r [%s]", LevelColor, Level, Color, Name, StatusLabels[Status])
			else
				Name = format("|cFF%s%s |c%s%s|r", LevelColor, Level, Color, Name)
			end
			
			if IsModifierKeyDown() then
				GameTooltip:AddDoubleLine(Name, Rank)
			else
				GameTooltip:AddDoubleLine(Name, Zone)
			end
		end
	end
	
	if (NumOnlineAndMobile > MaxCharacters) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(NumOnlineAndMobile - MaxCharacters .. Language[" more characters not shown"])
	end
	
	self.TooltipShown = true
	
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self.TooltipShown = false
end

local OnMouseUp = function()
	ToggleFriendsFrame(3)
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
		
		self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], select(3, GetNumGuildMembers()))
		
		--self:PlayFlash()
	end
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
	
	self.Text:SetText("")
end

DT:SetType("Guild", OnEnable, OnDisable, Update)