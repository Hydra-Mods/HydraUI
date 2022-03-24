local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

if 1 == 1 then return end

local tonumber = tonumber
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local AddOnVersion = tonumber(HydraUI.UIVersion)
local User = HydraUI.UserName .. "-" .. HydraUI.UserRealm

local Update = HydraUI:NewModule("Update")

local UpdateOnMouseUp = function()
	HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])
	print(Language["Join the Discord community for support and feedback https://discord.gg/XefDFa6nJR"])
end

function Update:FRIENDLIST_UPDATE()
	if HydraUI.IsMainline then
		for i = 1, BNGetNumFriends() do
			local Info = C_BattleNet.GetFriendAccountInfo(i)
			
			if (Info and Info.gameAccountInfo.clientProgram == "WoW" and Info.gameAccountInfo.wowProjectID == 1) then
				BNSendGameData(Info.gameAccountInfo.gameAccountID, "HydraUI-Version", AddOnVersion)
			end
		end
	else
		for i = 1, BNGetNumFriends() do
			local PresenceID, AccountName, BattleTag, IsBattleTagPresence, CharacterName, BNetIDGameAccount, Client, IsOnline = BNGetFriendInfo(i)
			
			if (Client == "WoW") then
				_, CharacterName, Client, RealmName, _, Faction, _, _, _, _, _, _, _, _, IsOnline, _, _, _, _, _, WoWProjectID = BNGetGameAccountInfo((BNetIDGameAccount or PresenceID))
				
				if (WoWProjectID == 5) and IsOnline then
					BNSendGameData(BNetIDGameAccount, "HydraUI-Version", AddOnVersion)
				end
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
	if IsInGuild() then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	end
	
	if IsInRaid() then
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			SendAddonMessage("HydraUI-Version", AddOnVersion, "INSTANCE")
		else
			SendAddonMessage("HydraUI-Version", AddOnVersion, "RAID")
		end
	end
	
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			SendAddonMessage("HydraUI-Version", AddOnVersion, "INSTANCE")
		else
			SendAddonMessage("HydraUI-Version", AddOnVersion, "PARTY")
		end
	end
	
	C_FriendList.ShowFriends()
	
	self:GUILD_ROSTER_UPDATE(true)
end

function Update:GUILD_ROSTER_UPDATE(update)
	if (not update) then
		return
	end

	if IsInGuild() then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	end
end

function Update:GROUP_ROSTER_UPDATE()
	if IsInRaid() then
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			SendAddonMessage("HydraUI-Version", AddOnVersion, "INSTANCE")
		else
			SendAddonMessage("HydraUI-Version", AddOnVersion, "RAID")
		end
	end
	
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			SendAddonMessage("HydraUI-Version", AddOnVersion, "INSTANCE")
		else
			SendAddonMessage("HydraUI-Version", AddOnVersion, "PARTY")
		end
	end
end

function Update:VARIABLES_LOADED()
	HydraUI:BindSavedVariable("HydraUIData", "Data")
	
	if (not HydraUI.Data.Version) or (HydraUI.Data.Version and HydraUI.Data.Version ~= AddOnVersion) then -- Create version, or store a new version if needed.
		HydraUI.Data.Version = AddOnVersion
	end
	
	local StoredVersion = HydraUI.Data.Version
	
	--[[ You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if (WhatsNew[AddOnVersion] and Settings["ui-display-whats-new"]) then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end]]
	
	self:UnregisterEvent("VARIABLES_LOADED")
end

function Update:BN_CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (channel == "WHISPER") then
		if (message > AddOnVersion) then
			HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
			
			self:RegisterEvent("FRIENDLIST_UPDATE")
			self:PLAYER_ENTERING_WORLD() -- Tell others that we found a new version
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

function Update:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (sender == HydraUI.UserName or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
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

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

Update:RegisterEvent("FRIENDLIST_UPDATE")
Update:RegisterEvent("VARIABLES_LOADED")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GUILD_ROSTER_UPDATE")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:RegisterEvent("BN_CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("HydraUI-Version")