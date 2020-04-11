local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local DT = vUI:GetModule("DataText")

local GetNumFriends = C_FriendList.GetNumFriends
local GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo
local GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetQuestDifficultyColor = GetQuestDifficultyColor
local pairs = pairs
local Label = Language["Friends"]

local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, LastOnline, IsAFK, IsDND

local ClientToName = {
	["App"] = Language["B.Net"],
	["BSAp"] = Language["B.Net"],
	["DST2"] = Language["Destiny 2"],
	["D3"] = Language["Diablo 3"],
	["Hero"] = Language["Heroes of the Storm"],
	["Pro"] = Language["Overwatch"],
	["S1"] = Language["StarCraft: Remastered"],
	["S2"] = Language["StarCraft 2"],
	["VIPR"] = Language["Call of Duty: Black Ops 4"],
	["ODIN"] = Language["Call of Duty: Modern Warfare"],
	["WoW"] = Language["World of Warcraft"],
	["WTCG"] = Language["Hearthstone"],
}

local ProjectIDToName = {
	[1] = Language["Battle for Azeroth"],
	[2] = Language["Classic"],
}

local GetClass = function(class)
	for Token, Localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if (Localized == class) then
			return Token
		end
	end
end

local ClientInfo = {}

ClientInfo["App"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["BSAp"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["DST2"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["D3"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["Hero"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["Pro"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["S1"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["S2"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["VIPR"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["ODIN"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

ClientInfo["WoW"] = function(name, info)
	Class = GetClass(info.gameAccountInfo.className)
	
	local ClassColor = vUI.ClassColors[Class]
	ClassColor = vUI:RGBToHex(ClassColor[1], ClassColor[2], ClassColor[3])
	
	local LevelColor = GetQuestDifficultyColor(info.gameAccountInfo.characterLevel)
	LevelColor = vUI:RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
	
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	local NameInfo = format("%s |cFFFFFFFF(|cFF%s%s|r |cFF%s%s|r|cFFFFFFFF)|r", name, LevelColor, info.gameAccountInfo.characterLevel, ClassColor, info.gameAccountInfo.characterName)
	
	return NameInfo, ProjectIDToName[info.gameAccountInfo.wowProjectID]
end

ClientInfo["WTCG"] = function(name, info)
	if info.gameAccountInfo.isGameAFK then
		name = format("|cFF9E9E9E%s|r", name)
	elseif info.gameAccountInfo.isGameBusy then
		name = format("|cFFF44336%s|r", name)
	else
		name = format("|cFF00FFF6%s|r", name)
	end
	
	return name, ClientToName[info.gameAccountInfo.clientProgram]
end

local GetClientInformation = function(client, name, info)
	if ClientInfo[client] then
		local Left, Right = ClientInfo[client](name, info)
		
		return Left, Right
	end
end

local OnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	
	local NumFriends = GetNumFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local Name
	
	-- B.Net friends
	for i = 1, NumBNFriends do
		local Info = GetFriendAccountInfo(i)
		
		if Info then
			local Left, Right = GetClientInformation(Info.gameAccountInfo.clientProgram, Info.accountName, Info)
			
			if Right then
				GameTooltip:AddDoubleLine(Left, Right)
			else
				GameTooltip:AddLine(Left)
			end
		end
	end
	
	--[[ Regular friends
	for i = 1, NumFriends do
		local FriendInfo = GetFriendInfoByIndex(i)
		
		if FriendInfo.connected then
			GameTooltip:AddDoubleLine(FriendInfo.name, FriendInfo.level)
		end
	end]]
	
	GameTooltip:Show()
	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	ToggleFriendsFrame(1)
end

local Update = function(self)
	local NumOnline = GetNumOnlineFriends()
	local NumBNFriends, NumBNOnline = BNGetNumFriends()
	local Online = NumOnline + NumBNOnline
	
	self.Text:SetFormattedText("|cff%s%s:|r |cff%s%s|r", Settings["data-text-label-color"], Label, Settings["data-text-value-color"], Online)
	
	--self:PlayFlash()
end

local OnEnable = function(self)
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:SetScript("OnMouseUp", OnMouseUp)
	
	C_FriendList.ShowFriends()
	
	self:Update()
end

local OnDisable = function(self)
	self:UnregisterEvent("FRIENDLIST_UPDATE")
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
	
	self.Text:SetText("")
end

DT:SetType("Friends", OnEnable, OnDisable, Update)