local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

local Announcements = vUI:NewModule("Announcements")
local EventType, SourceGUID, DestName, CastID, CastName, SpellID, SpellName
local InterruptMessage = ACTION_SPELL_INTERRUPT .. " %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r."
local DispelledMessage = ACTION_SPELL_DISPEL .. " %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r."
local StolenMessage = ACTION_SPELL_STOLEN .. " %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r."
local CastMessage = "casts \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r on %s."
local CastingMessage = Language["casting %s on %s."]
local UNKNOWN = UNKNOWN
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local SendChatMessage = SendChatMessage
local UnitIsFriend = UnitIsFriend
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
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
		if IsInRaid() then
			return "RAID"
		elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			return "INSTANCE_CHAT"
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
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
		if UnitIsFriend("player", target) then -- Quaking filter
			return
		end
		
		Channel = Announcements:GetChannelToSend()
		
		if Channel then
			SendChatMessage(format(InterruptMessage, target, id, spell), Channel)
		else
			print(format(InterruptMessage, target, id, spell))
		end
	end,
	
	--[[["SPELL_DISPEL"] = function(target, id, spell)
		if (not UnitIsFriend("player", target)) then
			SendChatMessage(format(DispelledMessage, target, id, spell), "EMOTE")
		end
	end,]]
	
	["SPELL_STOLEN"] = function(target, id, spell)
		Channel = Announcements:GetChannelToSend()
		
		if Channel then
			SendChatMessage(format(StolenMessage, target, id, spell), Channel)
		else
			print(format(StolenMessage, target, id, spell))
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