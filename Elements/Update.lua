local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

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

function Update:PLAYER_ENTERING_WORLD()
	if IsInGuild() then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	else
		self:RegisterEvent("GUILD_ROSTER_UPDATE")
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
	
	if (not HydraUI.IsMainline) then
		SendAddonMessage("HydraUI-Version", AddOnVersion, "YELL")
	end
end

function Update:GUILD_ROSTER_UPDATE(update)
	if (not update and not IsInGuild()) then
		return
	end
	
	SendAddonMessage("HydraUI-Version", AddOnVersion, "GUILD")
	
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
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

function Update:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (sender == User or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (AddOnVersion > message) then -- We have a higher version, share it
		SendAddonMessage("HydraUI-Version", AddOnVersion, "WHISPER", sender)
	elseif (message > AddOnVersion) then -- We're behind!
		HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, UpdateOnMouseUp, true)
		
		-- Store this higher version and tell anyone else who asks
		AddOnVersion = message
		
		self:PLAYER_ENTERING_WORLD() -- Tell others that we found a new version
	end
end

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

Update:RegisterEvent("VARIABLES_LOADED")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("HydraUI-Version")