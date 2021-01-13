local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local AddOnVersion = tonumber(vUI.UIVersion)
local User = vUI.UserName .. "-" .. vUI.UserRealm

local Update = vUI:NewModule("Update")


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

-- To be implemented. Add something here like a link or whatever to update.
local UpdateOnMouseUp = function()
	vUI:print(Language["You can get an updated version of vUI here at https://www.curseforge.com/wow/addons/vui or by using the Twitch desktop app"])
	print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
end

function Update:PLAYER_ENTERING_WORLD()
	--[[if self.NewVersion then
		vUI:SendAlert("What's new?", "Click here to learn more", nil, WhatsNewOnMouseUp, true)
		
		self.NewVersion = false
	end]]
	
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
	
	if IsInRaid() then
		SendAddonMessage("vUI-Version", AddOnVersion, IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE" or "RAID")
	elseif IsInGroup() then
		SendAddonMessage("vUI-Version", AddOnVersion, IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE" or "PARTY")
	end
	
	local Channels = {GetChannelList()}
	
	for i = 1, #Channels, 3 do -- Channels[i], Channels[i+1], Channels[i+2] = ID, Name, Disabled
		SendAddonMessage("vUI-Version", AddOnVersion, "CHANNEL", Channels[i])
	end
end

function Update:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
end

function Update:GROUP_ROSTER_UPDATE()
	--[[if IsInGroup(LE_PARTY_CATEGORY_HOME) then
		if IsInRaid() then
			SendAddonMessage("vUI-Version", AddOnVersion, "RAID")
		elseif IsInGroup() then
			SendAddonMessage("vUI-Version", AddOnVersion, "PARTY")
		end
	end
	
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		SendAddonMessage("vUI-Version", AddOnVersion, "INSTANCE_CHAT")
	end]]
	
	if IsInRaid() then
		SendAddonMessage("vUI-Version", AddOnVersion, IsInRaid(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE" or "RAID")
	elseif IsInGroup() then
		SendAddonMessage("vUI-Version", AddOnVersion, IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE" or "PARTY")
	end
end

function Update:VARIABLES_LOADED(event)
	vUI:BindSavedVariable("vUIData", "Data")
	
	if (not vUI.Data.Version) then
		vUI.Data.Version = AddOnVersion
	end
	
	local StoredVersion = vUI.Data.Version
	
	--[[ You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if (WhatsNew[AddOnVersion] and Settings["ui-display-whats-new"]) then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end]]
	
	-- Store a new version if needed.
	if (StoredVersion ~= AddOnVersion) then
		vUI.Data.Version = AddOnVersion
	end
	
	self:UnregisterEvent(event)
end

function Update:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	if (sender == User or prefix ~= "vUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (channel == "WHISPER") then
		if (message > AddOnVersion) then
			vUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
			--vUI:print(format(Language["Update to version |cFF%s%s|r! www.curseforge.com/wow/addons/vui"], Settings["ui-header-font-color"], message))
			--print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	else
		if (AddOnVersion > message) then -- We have a higher version, share it
			SendAddonMessage("vUI-Version", AddOnVersion, "WHISPER", sender)
		elseif (message > AddOnVersion) then -- We're behind!
			vUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
			--vUI:print(format(Language["Update to version |cFF%s%s|r! www.curseforge.com/wow/addons/vui"], Settings["ui-header-font-color"], message))
			--print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	end
end

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, event, ...)
	end
end

Update:RegisterEvent("VARIABLES_LOADED")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GUILD_ROSTER_UPDATE")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("vUI-Version")