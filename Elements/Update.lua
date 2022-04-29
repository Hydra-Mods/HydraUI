local HydraUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid

local AddOnVersion = HydraUI.UIVersion
local AddOnNum = tonumber(HydraUI.UIVersion)
local User = HydraUI.UserName .. "-" .. HydraUI.UserRealm
local SendAddonMessage = C_ChatInfo.SendAddonMessage

local Update = HydraUI:NewModule("Update")
Update.Timer = 3

local Tables = {}
local Queue = {}

function Update:OnMouseUp()
	HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])
	print(Language["Join the Discord community for support and feedback https://discord.gg/XefDFa6nJR"])
end

function Update:QueueChannel(channel, target)
	local Data
	
	if (#Tables == 0) then
		Data = {channel, target}
	else
		Data = tremove(Tables, 1)
		Data[1] = channel
		Data[2] = target
	end
	
	table.insert(Queue, Data)
	
	if (not self:GetScript("OnUpdate")) then
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end

function Update:OnUpdate(elapsed)
	self.Timer = self.Timer - elapsed
	
	if (self.Timer < 0) then
		local Data = table.remove(Queue, 1)
		
		SendAddonMessage("HydraUI-Version", AddOnVersion, Data[1], Data[2])
		
		table.insert(Tables, Data)
		
		self.Timer = 3
		
		if (#Queue == 0) then
			self:SetScript("OnUpdate", nil)
		end
	end
end

function Update:PLAYER_ENTERING_WORLD()
	if IsInGuild() then
		self:QueueChannel("GUILD")
	else
		self:RegisterEvent("GUILD_ROSTER_UPDATE")
	end
	
	if (not HydraUI.IsMainline) then
		self:QueueChannel("YELL")
	end
end

function Update:GUILD_ROSTER_UPDATE(update)
	if (not IsInGuild() or not update) then
		return
	end
	
	self:QueueChannel("GUILD")
	
	self:UnregisterEvent("GUILD_ROSTER_UPDATE")
end

function Update:GROUP_ROSTER_UPDATE() -- Be sure to check that PEW picks this up
	if IsInRaid() then
		if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueChannel("INSTANCE_CHAT")
		else
			self:QueueChannel("RAID")
		end
	end
	
	if IsInGroup() then
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			self:QueueChannel("INSTANCE_CHAT")
		else
			self:QueueChannel("PARTY")
		end
	end
end

function Update:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (sender == User or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (AddOnNum > message) then -- We have a higher version, share it
		self:QueueChannel("WHISPER", sender)
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