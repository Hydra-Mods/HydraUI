local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local match = string.match
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local UnitInBattleground = UnitInBattleground
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

-- Use a button in GUI to request newer versions? -- Put a pretty hard throttle on the button too so it can't be smashed.
-- vUI:print("If any version data is recieved, you will be prompted.")

local AddOnVersion = tonumber(vUI.UIVersion)

local Update = vUI:NewModule("Update")

--[[local WhatsNew = {
	[1.01] = {
		"Alert frames",
		"Version check module",
	},
}
]]

-- Make a frame to display a simple "What's new" list.
local WhatsNewOnMouseUp = function()
	
end

-- To be implemented. Add something here like a link or whatever to update.
local UpdateOnMouseUp = function()
	vUI:print(Language["You can get an updated version of vUI here at https://www.curseforge.com/wow/addons/vui or by using the Twitch desktop app"])
end

function Update:PLAYER_ENTERING_WORLD(event)
	--[[if self.NewVersion then
		vUI:SendAlert("What's new?", "Click here to learn more", nil, WhatsNewOnMouseUp, true)
		
		self.NewVersion = false
	end]]
	
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
	
	if IsInRaid() then
		SendAddonMessage("vUI-Version", AddOnVersion, "RAID")
	elseif IsInGroup() then
		SendAddonMessage("vUI-Version", AddOnVersion, "PARTY")
	end
	
	if IsInInstance() then
		SendAddonMessage("vUI-Version", AddOnVersion, "INSTANCE_CHAT")
	end
	
	SendAddonMessage("vUI-Version", AddOnVersion, "CHANNEL", 1)
	SendAddonMessage("vUI-Version", AddOnVersion, "CHANNEL", 2)
end

function Update:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		SendAddonMessage("vUI-Version", AddOnVersion, "GUILD")
	end
end

-- /run vUIData.Version = 1 -- Leaving this here for a while so I can reset version manually for testing.
function Update:VARIABLES_LOADED(event)
	if (not vUIData) then
		vUIData = {}
	end
	
	if (not vUIData.Version) then
		vUIData.Version = AddOnVersion
	end
	
	local StoredVersion = vUIData.Version
	
	--[[ You installed a newer version! Yay you. Yes, you.
	if (AddOnVersion > StoredVersion) then
		if (WhatsNew[AddOnVersion] and Settings["ui-display-whats-new"]) then
			self.NewVersion = true -- Let PEW take over from here.
		end
	end]]
	
	-- Store a new version if needed.
	if (StoredVersion ~= AddOnVersion) then
		vUIData.Version = AddOnVersion
	end
	
	self:UnregisterEvent(event)
end

function Update:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	sender = match(sender, "(%S+)-%S+")
	
	if (sender == vUI.UserName or prefix ~= "vUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (channel == "WHISPER") then
		if (message > AddOnVersion) then
			--vUI:SendAlert("New Version", format("Update to version |cFF%s%s|r!", Settings["ui-header-font-color"], Version), nil, UpdateOnMouseUp, true)
			vUI:print(format(Language["Update to version |cFF%s%s|r! www.curseforge.com/wow/addons/vui"], Settings["ui-header-font-color"], message))
			print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
			
			-- Store this higher version and tell anyone else who asks
			AddOnVersion = message
		end
	else
		if (AddOnVersion > message) then -- We have a higher version, share it
			SendAddonMessage("vUI-Version", AddOnVersion, "WHISPER", sender)
		elseif (message > AddOnVersion) then -- We're behind!
			vUI:print(format(Language["Update to version |cFF%s%s|r! www.curseforge.com/wow/addons/vui"], Settings["ui-header-font-color"], message))
			print(Language["Join the Discord community for support and feedback https://discord.gg/XGYDaBF"])
			
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
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("vUI-Version")