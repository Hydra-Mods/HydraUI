local HydraUI, Language, Assets, Settings = select(2, ...):get()

local tonumber = tonumber
local IsInGuild = IsInGuild
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local AddOnVersion = HydraUI.UIVersion
local AddOnNum = tonumber(HydraUI.UIVersion)
local User = HydraUI.UserName .. "-" .. HydraUI.UserRealm
local SendAddonMessage = C_ChatInfo.SendAddonMessage
local tinsert = table.insert
local tremove = table.remove

local Update = HydraUI:NewModule("Update")
Update.SentHome = false
Update.SentInst = false
Update.Timer = 5

local Tables = {}
local Queue = {}

local Throttle = HydraUI:GetModule("Throttle")

function Update:QueueChannel(channel, target)
	local Data
	
	if (#Tables == 0) then
		Data = {channel, target}
	else
		Data = tremove(Tables, 1)
		Data[1] = channel
		Data[2] = target
	end
	
	tinsert(Queue, Data)
	
	if (not self:GetScript("OnUpdate")) then
		self:SetScript("OnUpdate", self.OnUpdate)
	end
end

function Update:OnUpdate(elapsed)
	self.Timer = self.Timer - elapsed
	
	if (self.Timer < 0) then
		local Data = tremove(Queue, 1)
		
		SendAddonMessage("HydraUI-Version", AddOnVersion, Data[1], Data[2])
		
		tinsert(Tables, Data)
		
		self.Timer = 5
		
		if (#Queue == 0) then
			self:SetScript("OnUpdate", nil)
		end
	end
end

function Update:PLAYER_ENTERING_WORLD()
	if (not HydraUI.IsMainline) then
		self:QueueChannel("YELL")
		Throttle:Start("vrsn", 10)
	end
	
	self:GROUP_ROSTER_UPDATE()
end

function Update:GUILD_ROSTER_UPDATE()
	if IsInGuild() then
		self:QueueChannel("GUILD")
		
		self:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

function Update:GROUP_ROSTER_UPDATE()
	local Home = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME)
	local Instance = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)
	
	if (Home == 0 and self.SentHome) then
		self.SentHome = false
	elseif (Instance == 0 and self.SentInst) then
		self.SentInst = false
	end
	
	if (Instance > 0 and not self.SentInst) then
		self:QueueChannel("INSTANCE_CHAT")
		self.SentInst = true
	elseif (Home > 0 and not self.SentHome) then
		self:QueueChannel(IsInRaid(LE_PARTY_CATEGORY_HOME) and "RAID" or IsInGroup(LE_PARTY_CATEGORY_HOME) and "PARTY")
		self.SentHome = true
	end
end

function Update:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if (sender == User or prefix ~= "HydraUI-Version") then
		return
	end
	
	message = tonumber(message)
	
	if (AddOnNum > message) then -- We have a higher version, share it
		self:QueueChannel(channel)
	elseif (message > AddOnNum) then -- We're behind!
		HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])
		print(Language["Join the Discord community for support and feedback https://discord.gg/XefDFa6nJR"])
		
		HydraUI:GetModule("GUI"):CreateUpdateAlert()
		
		AddOnNum = message
		AddOnVersion = tostring(message)
	end
end

function Update:ZONE_CHANGED_NEW_AREA()
	if UnitOnTaxi("player") then
		local Zone = GetZoneText()
		
		if (Zone ~= self.Zone and not Throttle:IsThrottled("vrsn")) then
			self:QueueChannel("YELL")
			self.Zone = Zone
			Throttle:Start("vrsn", 10)
		end
	end
end

function Update:ZONE_CHANGED()
	if UnitOnTaxi("player") then
		local Zone = GetZoneText()
		
		if (Zone ~= self.Zone and not Throttle:IsThrottled("vrsn")) then
			self:QueueChannel("YELL")
			self.Zone = Zone
			Throttle:Start("vrsn", 10)
		end
	end
end

function Update:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

if not HydraUI.IsMainline then
	Update:RegisterEvent("ZONE_CHANGED")
	Update:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

Update:RegisterEvent("GUILD_ROSTER_UPDATE")
Update:RegisterEvent("PLAYER_ENTERING_WORLD")
Update:RegisterEvent("GROUP_ROSTER_UPDATE")
Update:RegisterEvent("CHAT_MSG_ADDON")
Update:SetScript("OnEvent", Update.OnEvent)

C_ChatInfo.RegisterAddonMessagePrefix("HydraUI-Version")