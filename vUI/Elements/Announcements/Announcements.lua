local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

local Announcements = vUI:NewModule("Announcements")
local EventType, SourceGUID, DestName, CastID, CastName, SpellID, SpellName
local InterruptMessage = ACTION_SPELL_INTERRUPT .. " %s's %s"
local DispelledMessage = ACTION_SPELL_DISPEL .. " %s's %s"
local StolenMessage = ACTION_SPELL_STOLEN .. " %s's %s"
local CastMessage = Language["casts %s on %s."]
local CastingMessage = Language["casting %s on %s."]
local UNKNOWN = UNKNOWN
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local SendChatMessage = SendChatMessage
local UnitIsFriend = UnitIsFriend
local UnitInRaid = UnitInRaid
local UnitInParty = UnitInParty
local UnitExists = UnitExists
local UnitName = UnitName
local GetNumGroupMembers = GetNumGroupMembers
local format = format
local MyGUID = UnitGUID("player")
local PetGUID = ""
local _

local Channel

Announcements.Spells = {
	
}

function Announcements:GetChannelToSend()
	if (Settings["announcements-channel"] == "SELF") then
		return
	elseif (Settings["announcements-channel"] == "GROUP") then
		if UnitInRaid("player") then
			return "RAID"
		elseif UnitInParty("player") then
			return "PARTY"
		end
	elseif (Settings["announcements-channel"] == "SAY") then
		return "SAY"
	else
		return "EMOTE"
	end
end

Announcements.Events = {
	["SPELL_INTERRUPT"] = function(target, id, spell)
		Channel = Announcements:GetChannelToSend()
		
		if Channel then
			SendChatMessage(format(InterruptMessage, target, spell), Channel)
		else
			print(format(InterruptMessage, target, spell))
		end
	end,
	
	--[[["SPELL_DISPEL"] = function(target, id, spell)
		if (not UnitIsFriend("player", target)) then
			SendChatMessage(format(DispelledMessage, target, spell), "EMOTE")
		end
	end,]]
	
	["SPELL_STOLEN"] = function(target, id, spell)
		Channel = Announcements:GetChannelToSend()
		
		if Channel then
			SendChatMessage(format(StolenMessage, target, spell), Channel)
		else
			print(format(StolenMessage, target, spell))
		end
	end,
}

function Announcements:COMBAT_LOG_EVENT_UNFILTERED()
	_, EventType, _, SourceGUID, _, _, _, _, DestName, _, _, _, _, _, SpellID, SpellName = CombatLogGetCurrentEventInfo()
	
	if (not self.Events[EventType]) then
		return
	end
	
	if (SourceGUID == MyGUID or SourceGUID == PetGUID) then
		self.Events[EventType](DestName, SpellID, SpellName)
	end
end

function Announcements:GROUP_ROSTER_UPDATE()
	if (GetNumGroupMembers() > 0) then
		if (not self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED")) then
			self:UNIT_PET("player")
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	elseif self:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function Announcements:UNIT_PET(owner)
	if (owner ~= "player") then
		return
	end
	
	if (UnitExists("pet") and UnitName("pet") ~= UNKNOWN) then
		PetGUID = UnitGUID("pet")
	end
end

function Announcements:OnEvent(event, arg)
	self[event](self, arg)
end

function Announcements:Load()
	if (not Settings["announcements-enable"]) then
		return
	end
	
	self:GROUP_ROSTER_UPDATE()
	self:UNIT_PET("player")
	
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:SetScript("OnEvent", self.OnEvent)
end