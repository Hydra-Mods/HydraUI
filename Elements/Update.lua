local HydraUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local CT = ChatThrottleLib
local AddOnVersion = HydraUI.UIVersion
local AddOnNum = tonumber(HydraUI.UIVersion)
local User = HydraUI.UserName .. "-" .. HydraUI.UserRealm
local SendAddonMessage = C_ChatInfo.SendAddonMessage

local Update = HydraUI:NewModule("Update")

Update.Queue = {}

function Update:OnMouseUp()
	HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])
	print(Language["Join the Discord community for support and feedback https://discord.gg/XefDFa6nJR"])
end

function Update:QueueMessage(channel, target)
	table.insert(self.Queue, {channel, target})
	
	if (#self.Queue > 0) then
		self.Timer = 4 -- Adjust if I need to
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end

function Update:OnUpdate(elapsed)
	self.Timer = self.Timer - elapsed
	
	if (self.Timer < 0) then
		local Args = table.remove(self.Queue, 1)
		
		SendAddonMessage("HydraUI-Version", AddOnVersion, Args[1], Args[2])
		
		self.Timer = 4
	end
	
	if (#self.Queue == 0) then
		self:SetScript("OnUpdate", nil)
	end
end

function Update:PLAYER_ENTERING_WORLD()
	if IsInGuild() then
		self:QueueMessage("GUILD")
	else
		self:RegisterEvent("GUILD_ROSTER_UPDATE")
	end
	
	if IsInRaid() then
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueMessage("INSTANCE")
		else
			self:QueueMessage("RAID")
		end
	end
	
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueMessage("INSTANCE")
		else
			self:QueueMessage("PARTY")
		end
	end
	
	if (not HydraUI.IsMainline) then
		self:QueueMessage("YELL")
	end
end

function Update:GUILD_ROSTER_UPDATE(update)
	if (not IsInGuild() or not update) then
		return
	end
	
	self:QueueMessage("GUILD")
	
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
end

function Update:GROUP_ROSTER_UPDATE()
	if IsInRaid() then
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueMessage("INSTANCE")
		else
			self:QueueMessage("RAID")
		end
	end
	
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueMessage("INSTANCE")
		else
			self:QueueMessage("PARTY")
		end
	end
end

function Update:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (sender == User or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (AddOnNum > message) then -- We have a higher version, share it
		self:QueueMessage("WHISPER", sender)
	elseif (message > AddOnNum) then -- We're behind!
		HydraUI:SendAlert(Language["New Version!"], format(Language["Update to version |cFF%s%s|r"], Settings["ui-header-font-color"], message), nil, self.OnMouseUp, true)
		
		-- Store this higher version and tell anyone else who asks
		AddOnNum = message
		AddOnVersion = tostring(message)
		
		self:PLAYER_ENTERING_WORLD() -- Tell others that we found a new version
	end
end

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("HydraUI-Version")