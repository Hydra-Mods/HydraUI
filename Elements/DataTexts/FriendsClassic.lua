local HydraUI, Language, Assets, Settings = select(2, ...):get()

local GetNumFriends = C_FriendList.GetNumFriends
local GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetQuestDifficultyColor = GetQuestDifficultyColor
local next = next
local Label = TUTORIAL_TITLE22
local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND
local ClientInfo = {}
local FriendList = {}

local ClientToName = {
	["App"] = Language["B.Net"],
	["BSAp"] = Language["B.Net"],
	["DST2"] = Language["Destiny 2"],
	["D3"] = Language["Diablo 3"],
	["Hero"] = Language["Heroes of the Storm"],
	["OSI"] = "Diablo II: Resurrected",
	["Pro"] = Language["Overwatch"],
	["S1"] = Language["StarCraft: Remastered"],
	["S2"] = Language["StarCraft 2"],
	["VIPR"] = Language["Call of Duty: Black Ops 4"],
	["ODIN"] = Language["Call of Duty: Modern Warfare"],
	["WoW"] = CINEMATIC_NAME_1,
	["WTCG"] = Language["Hearthstone"],
	["ANBS"] = "Diablo Immortal",
}

local ProjectIDToName = {
	[1] = Language["Shadowlands"],
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

ClientInfo["App"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name
end

ClientInfo["ANBS"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["BSAp"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["DST2"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["D3"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["Hero"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["Pro"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["S1"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["S2"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["VIPR"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["ODIN"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["OSI"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

ClientInfo["WoW"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if (not Class:find("%S")) then
		Class = "DEMONHUNTER"
	else
		Class = GetClass(Class)
	end
	
	local ClassColor = HydraUI.ClassColors[Class]
	
	ClassColor = HydraUI:RGBToHex(ClassColor[1], ClassColor[2], ClassColor[3])
	
	local LevelColor = GetQuestDifficultyColor(Level)
	LevelColor = HydraUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
	
	if IsAFK then
		name = format("|cFF00FFF6(%s)|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6(%s)|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6(%s)|r", name)
	end
	
	local NameInfo = format("|cFF%s%s|r |cFF%s%s|r|cFFFFFFFF|r %s", LevelColor, Level, ClassColor, CharacterName, name)
	
	if (Area == GetRealZoneText()) then
		Area = format("|cFF33FF33%s|r", Area)
	end
	
	return ProjectIDToName[WoWProjectID], NameInfo, Area
end

ClientInfo["WTCG"] = function(name, id)
	local HasFocus, CharacterName, Client, RealmName, RealmID, Faction, Race, Class, Blank, Area, Level, RichPresence, CustomMessage, CustomMessageTime, IsOnline, GameAccountID, BNetAccountID, IsAFK, IsBusy, GUID, WoWProjectID, IsWoWMobile = BNGetGameAccountInfo(id)
	
	if IsAFK then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_AFK)
	elseif IsBusy then
		name = format("|cFF00FFF6%s|r |cFFFFFF33%s|r", name, CHAT_FLAG_DND)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return ClientToName[Client], name, RichPresence
end

local GetClientInformation = function(client, name, id)
	if ClientInfo[client] then
		local RealClient, Left, Right = ClientInfo[client](name, id)
		
		return RealClient, Left, Right
	end
end

local OnEnter = function(self)
	self:SetTooltip()
	
	local NumFriends = GetNumFriends()
	local NumFriendsOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local FriendInfo
	local Name
	local NumClients = 0
	local ClientCount = 0
	
	GameTooltip:AddDoubleLine(Label, format("%s/%s", NumBNOnline + NumFriendsOnline, NumFriends + NumBNFriends), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddLine(" ")
	
	-- B.Net friends
	for i = 1, NumBNFriends do
		local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND = BNGetFriendInfo(i)
		local RealClient, Left, Right = GetClientInformation(Client, AccountName, (BNetIDGameAccount or PresenceID))
		
		if RealClient then
			if (not FriendList[RealClient]) then
				FriendList[RealClient] = {}
				NumClients = NumClients + 1
			end
			
			tinsert(FriendList[RealClient], {Left, Right})
		end
	end
	
	-- Regular friends
	local ID = 2
	
	if HydraUI.IsTBC then
		ID = 5
	end
	
	for i = 1, NumFriends do
		FriendInfo = GetFriendInfoByIndex(i)
		
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
				Name = format("|cFF9E9E9E%s|r", FriendInfo.name)
			elseif FriendInfo.dnd then
				Name = format("|cFFF44336%s|r", FriendInfo.name)
			else
				Name = FriendInfo.name
			end
			
			local NameInfo = format("|cFFFFFFFF|cFF%s%s|r |cFF%s%s|r|cFFFFFFFF|r", LevelColor, FriendInfo.level, ClassColor, Name)
			
			if (not FriendList[ProjectIDToName[ID]]) then
				FriendList[ProjectIDToName[ID]] = {}
				NumClients = NumClients + 1
			end
			
			tinsert(FriendList[ProjectIDToName[ID]], {NameInfo, FriendInfo.area})
		end
	end
	
	for client, info in next, FriendList do
		GameTooltip:AddLine(client)
		ClientCount = ClientCount + 1
		
		for i = 1, #info do
			if info[i][2] then
				GameTooltip:AddDoubleLine(info[i][1], info[i][2], nil, nil, nil, 1, 1, 1)
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
end

local OnLeave = function()
	GameTooltip:Hide()
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
	
	self.Text:SetFormattedText("|cFF%s%s:|r |cFF%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Online)
end

local OnEnable = function(self)
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	self:RegisterEvent("BN_INFO_CHANGED")
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
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

HydraUI:AddDataText("Friends", OnEnable, OnDisable, Update)