local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local match = string.match
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local UnitInBattleground = UnitInBattleground
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local MyFaction = UnitFactionGroup("player")

local AddOnVersion = tonumber(HydraUI.UIVersion)

local Update = HydraUI:NewModule("Update")

--[[local WhatsNew = {
	[1.01] = {
		"Alert frames",
		"Version check module",
	},
}
]]

-- display a simple "What's new" list.
local WhatsNewOnMouseUp = function()
	
end

local UpdateOnMouseUp = function()
	HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])
	print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
end

function Update:FRIENDLIST_UPDATE()
	local Info, PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline, RealmName, Faction, WoWProjectID, _
	
	for i = 1, BNGetNumFriends() do
		local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline = BNGetFriendInfo(i)
		
		if (Client == "WoW") then
			_, CharacterName, Client, RealmName, _, Faction, _, _, _, _, _, _, _, _, IsOnline, _, _, _, _, _, WoWProjectID = BNGetGameAccountInfo((BNetIDGameAccount or PresenceID))
			
			if (WoWProjectID == 5) and IsOnline then
				BNSendGameData(BNetIDGameAccount, "HydraUI-Version", AddOnVersion)
			end
		end
	end
	
	for i = 1, C_FriendList.GetNumFriends() do
		Info = C_FriendList.GetFriendInfoByIndex(i)
		
		if Info.connected then
			SendAddonMessage("HydraUI-Version", AddOnVersion, "WHISPER", Info.name)
		end
	end
	
	Info = nil
	
	self:UnregisterEvent("FRIENDLIST_UPDATE")
end

function Update:PLAYER_ENTERING_WORLD()
	--[[if self.NewVersion then
		HydraUI:SendAlert("What's new?", "Click here to learn more", nil, WhatsNewOnMouseUp, true)
		
		self.NewVersion = false
	end]]
	
	if IsInGuild() then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	end
	
	if UnitInBattleground("player") then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "BATTLEGROUND")
	elseif (IsInRaid() and UnitExists("raid1")) then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "RAID")
	elseif (IsInGroup() and UnitExists("party1")) then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "PARTY")
	end
	
	SendAddonMessage("HydraUI-Version", AddOnVersion, "YELL")
	
	C_FriendList.ShowFriends()
end

function Update:CHAT_MSG_CHANNEL_NOTICE(event, action, name, language, channel, name2, flags, id)
	if (action == "YOU_CHANGED" and id == 1) then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "YELL")
	end
end

function Update:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	end
end

function Update:GROUP_ROSTER_UPDATE()
	if UnitInBattleground("player") then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "BATTLEGROUND")
	elseif IsInRaid() and UnitExists("raid1") then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "RAID")
	elseif IsInGroup() and UnitExists("party1") then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "PARTY")
	end
end

function Update:VARIABLES_LOADED(event)
	HydraUI:BindSavedVariable("HydraUIData", "Data")
	
	if (not HydraUI.Data.Version) then
		HydraUI.Data.Version = AddOnVersion
	end
	
	local StoredVersion = HydraUI.Data.Version
	
	--[[ You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if (WhatsNew[AddOnVersion] and Settings["ui-display-whats-new"]) then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end]]
	
	-- Store a new version if needed.
	if (StoredVersion ~= AddOnVersion) then
		HydraUI.Data.Version = AddOnVersion
	end
	
	self:UnregisterEvent(event)
end

function Update:BN_CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	if (prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (AddOnVersion > message) then -- We have a higher version, share it
		BNSendGameData(sender, "HydraUI-Version", AddOnVersion)
	elseif (message > AddOnVersion) then -- We're behind!
		HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
		
		-- Store this higher version and tell anyone else who asks
		AddOnVersion = message
		
		self:RegisterEvent("FRIENDLIST_UPDATE")
		self:PLAYER_ENTERING_WORLD() -- Tell others that we found a new version
	end
end

function Update:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	sender = match(sender, "(%S+)-%S+")
	
	if (sender == HydraUI.UserName or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (channel == "WHISPER") then
		if (message > AddOnVersion) then
			HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	else
		if (AddOnVersion > message) then -- We have a higher version, share it
			SendAddonMessage("HydraUI-Version", AddOnVersion, "WHISPER", sender)
		elseif (message > AddOnVersion) then -- We're behind!
			HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
			
			self:RegisterEvent("FRIENDLIST_UPDATE")
			self:PLAYER_ENTERING_WORLD() -- Tell others that we found a new version
		end
	end
end

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end

Update:RegisterEvent("VARIABLES_LOADED")
Update:RegisterEvent("FRIENDLIST_UPDATE")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GUILD_ROSTER_UPDATE")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("HydraUI-Version")