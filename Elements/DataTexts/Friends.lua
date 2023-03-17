local HydraUI, Language, Assets, Settings = select(2, ...):get()

local GetNumFriends = C_FriendList.GetNumFriends
local GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local BNGetNumFriends = BNGetNumFriends
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetQuestDifficultyColor = GetQuestDifficultyColor
local next = next
local Label = TUTORIAL_TITLE22
local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND
local ClientInfo = {}
local FriendList = {}

local ClientToName = {
	App = Language["B.Net"],
	BSAp = Language["B.Net"],
	DST2 = Language["Destiny 2"],
	D3 = Language["Diablo 3"],
	Hero = Language["Heroes of the Storm"],
	OSI = "Diablo II: Resurrected",
	Pro = Language["Overwatch 2"],
	S1 = Language["StarCraft: Remastered"],
	S2 = Language["StarCraft 2"],
	VIPR = Language["Call of Duty: Black Ops 4"],
	ODIN = Language["Call of Duty: Modern Warfare"],
	WoW = CINEMATIC_NAME_1,
	WTCG = Language["Hearthstone"],
	ANBS = "Diablo Immortal",
	AUKS = Language["Call of Duty: MWII"],
}

local ProjectIDToName = {
	[1] = EXPANSION_NAME9,
	[2] = EXPANSION_NAME0,
	[5] = EXPANSION_NAME1,
	[11] = EXPANSION_NAME2,
}

local GetClass = function(class)
	for Token, Localized in next, LOCALIZED_CLASS_NAMES_MALE do
		if (Localized == class) then
			return Token
		end
	end
end

ClientInfo["App"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name
end

ClientInfo["ANBS"] = function(name, id)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["BSAp"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["DST2"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["D3"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["Hero"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["Pro"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["S1"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["S2"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["VIPR"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["AUKS"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["ODIN"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["OSI"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], name, info.gameAccountInfo.richPresence
end

ClientInfo["WoW"] = function(name, info)
	Class = GetClass(info.gameAccountInfo.className)

	local ClassColor = HydraUI.ClassColors[Class]

	if (not ClassColor) then
		return ProjectIDToName[info.gameAccountInfo.wowProjectID], name
	end

	ClassColor = HydraUI:RGBToHex(ClassColor[1], ClassColor[2], ClassColor[3])

	local LevelColor = GetQuestDifficultyColor(info.gameAccountInfo.characterLevel)
	LevelColor = HydraUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)

	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6(%s)|r |cFFFFFF33<%s>|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6(%s)|r |cFFFFFF33<%s>|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6(%s)|r", name)
	end

	local NameInfo = format("|cFF%s%s|r |cFF%s%s|r|cFFFFFFFF|r %s", LevelColor, info.gameAccountInfo.characterLevel, ClassColor, info.gameAccountInfo.characterName, name)
	local Area = info.gameAccountInfo.areaName

	if (Area == GetRealZoneText()) then
		Area = format("|cFF33FF33%s|r", Area)
	end

	return ProjectIDToName[info.gameAccountInfo.wowProjectID], NameInfo, Area
end

ClientInfo["WTCG"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_AFK_MESSAGE)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, DEFAULT_DND_MESSAGE)
	else
		name = format("|cFF00FFF6%s|r", name)
	end

	return ClientToName[info.gameAccountInfo.clientProgram], info.gameAccountInfo.richPresence
end

local GetClientInformation = function(client, name, info)
	if ClientInfo[client] then
		local RealClient, Left, Right = ClientInfo[client](name, info)

		return RealClient, Left, Right
	end
end

local OnEnter = function(self)
	C_FriendList.ShowFriends()

	self:SetTooltip()

	local NumFriends = GetNumFriends()
	local NumFriendsOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local Name
	local NumClients = 0
	local ClientCount = 0
	local MapID = C_Map.GetBestMapForUnit("player")
	local CurrentZone

	if MapID then
		CurrentZone = C_Map.GetMapInfo(MapID).name or GetRealZoneText()
	else
		CurrentZone = GetRealZoneText()
	end

	GameTooltip:AddDoubleLine(Label, format("%s/%s", NumBNOnline + NumFriendsOnline, NumFriends + NumBNFriends))
	GameTooltip:AddLine(" ")

	-- B.Net friends
	for i = 1, NumBNFriends do
		local Info = GetFriendAccountInfo(i)

		if Info then
			local RealClient, Left, Right = GetClientInformation(Info.gameAccountInfo.clientProgram, Info.accountName, Info)

			if RealClient then
				if (not FriendList[RealClient]) then
					FriendList[RealClient] = {}
					NumClients = NumClients + 1
				end

				tinsert(FriendList[RealClient], {Left, Right})
			end
		end
	end

	-- Regular friends
	for i = 1, NumFriends do
		local FriendInfo = GetFriendInfoByIndex(i)

		if FriendInfo.connected then
			local Class = GetClass(FriendInfo.className)

			if (Class == "Unknown") then
				Class = "PRIEST"
			end

			local ClassColor = HydraUI.ClassColors[Class]

			ClassColor = HydraUI:RGBToHex(ClassColor[1], ClassColor[2], ClassColor[3])

			local LevelColor = GetQuestDifficultyColor(FriendInfo.level)
			LevelColor = HydraUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)

			if FriendInfo.afk then
				Name = format("%s |cFFFFFF33%s|r", FriendInfo.name, DEFAULT_AFK_MESSAGE)
			elseif FriendInfo.dnd then
				Name = format("%s |cFFFFFF33%s|r", FriendInfo.name, DEFAULT_DND_MESSAGE)
			else
				Name = FriendInfo.name
			end

			local NameInfo = format("|cFFFFFFFF|cFF%s%s|r |cFF%s%s|r|cFFFFFFFF|r", LevelColor, FriendInfo.level, ClassColor, Name)

			if (not FriendList[ProjectIDToName[1]]) then
				FriendList[ProjectIDToName[1]] = {}
				NumClients = NumClients + 1
			end

			tinsert(FriendList[ProjectIDToName[1]], {NameInfo, FriendInfo.area})
		end
	end

	for client, info in next, FriendList do
		GameTooltip:AddLine(client)
		ClientCount = ClientCount + 1

		for i = 1, #info do
			if info[i][2] then
				if (info[i][2] == CurrentZone) then
					GameTooltip:AddDoubleLine(info[i][1], info[i][2], nil, nil, nil, 0.2, 1, 0.2)
				else
					GameTooltip:AddDoubleLine(info[i][1], info[i][2], nil, nil, nil, 1, 1, 1)
				end
			else
				GameTooltip:AddLine(info[i][1])
			end
		end

		if (ClientCount ~= NumClients) then
			GameTooltip:AddLine(" ")
		end
	end

	GameTooltip:Show()

	wipe(FriendList)

	self.TooltipShown = true
end

local OnLeave = function(self)
	GameTooltip:Hide()
	self.TooltipShown = false
end

local OnMouseUp = function()
	if (not InCombatLockdown()) then
		ToggleFriendsFrame(1)
	end
end

local Update = function(self)
	local NumOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local Online = NumOnline + NumBNOnline

	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, HydraUI.ValueColor, Online)

	if self.TooltipShown then
		OnLeave(self)
		OnEnter(self)
	end
end

local OnEnable = function(self)
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	self:RegisterEvent("BN_INFO_CHANGED")
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	self:RegisterEvent("BN_CONNECTED")
	self:RegisterEvent("BN_DISCONNECTED")
	self:RegisterEvent("WHO_LIST_UPDATE")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)

	C_FriendList.ShowFriends()

	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:UnregisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:UnregisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	self:UnregisterEvent("BN_INFO_CHANGED")
	self:UnregisterEvent("BN_FRIEND_INFO_CHANGED")
	self:UnregisterEvent("BN_CONNECTED")
	self:UnregisterEvent("BN_DISCONNECTED")
	self:UnregisterEvent("WHO_LIST_UPDATE")
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	self:UnregisterEvent("PLAYER_GUILD_UPDATE")
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)

	self.Text:SetText("")
end

HydraUI:AddDataText("Friends", OnEnable, OnDisable, Update)