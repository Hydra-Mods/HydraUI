local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Debug = vUI:NewModule("Debug")

local format = format
local select = select
local GetZoneText = GetZoneText
local GetMinimapZoneText = GetMinimapZoneText
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept

local GetNumLoadedAddOns = function()
	local NumLoaded = 0
	
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			NumLoaded = NumLoaded + 1
		end
	end
	
	return NumLoaded
end

local GetClient = function()
	if IsWindowsClient() then
		return Language["Windows"]
	elseif IsMacClient() then
		return Language["Mac"]
	else -- IsLinuxClient
		return Language["Linux"]
	end
end

local GetQuests = function()
	local NumQuests = select(2, GetNumQuestLogEntries())
	local MaxQuests = GetMaxNumQuestsCanAccept()
	
	return format("%s / %s", NumQuests, MaxQuests)
end

local GetSpecName = function()
	local Name = select(2, GetSpecializationInfo(GetSpecialization()))
	
	return Name
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Debug"], nil, "zzzDebug")
	
	Left:CreateHeader(Language["UI Information"])
	Left:CreateDoubleLine(Language["Game Version"], GetBuildInfo())
	Left:CreateDoubleLine(Language["Client"], GetClient())
	Left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	Left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	Left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	Left:CreateDoubleLine(Language["Screen Size"], format("%sx%s", GetPhysicalScreenSize()))
	Left:CreateDoubleLine(Language["Fullscreen"], "")
	Left:CreateDoubleLine(Language["Profile"], vUI:GetActiveProfileName())
	Left:CreateDoubleLine(Language["UI Style"], Settings["ui-style"])
	Left:CreateDoubleLine(Language["Locale"], vUI.UserLocale)
	Left:CreateDoubleLine(Language["Display Errors"], "")
	
	Right:CreateHeader(Language["User Information"])
	Right:CreateDoubleLine(Language["Level"], UnitLevel("player"))
	Right:CreateDoubleLine(Language["Race"], vUI.UserRace)
	Right:CreateDoubleLine(Language["Class"], UnitClass("player"))
	Right:CreateDoubleLine(Language["Spec"], "")
	Right:CreateDoubleLine(Language["Realm"], vUI.UserRealm)
	Right:CreateDoubleLine(Language["Zone"], GetZoneText())
	Right:CreateDoubleLine(Language["Sub Zone"], GetMinimapZoneText())
	Right:CreateDoubleLine(Language["Quests"], GetQuests())
	Right:CreateHeader(Language["AddOns Information"])
	Right:CreateDoubleLine(Language["Total AddOns"], GetNumAddOns())
	Right:CreateDoubleLine(Language["Loaded AddOns"], GetNumLoadedAddOns())
	Right:CreateDoubleLine(Language["Loaded Plugins"], #vUI.Plugins)
end)

function Debug:DISPLAY_SIZE_CHANGED()
	vUI:UpdateScreenSize()
	
	GUI:GetWidgetByWindow(Language["Debug"], "suggested-scale").Right:SetText(vUI:GetSuggestedScale())
	GUI:GetWidgetByWindow(Language["Debug"], "resolution").Right:SetText(vUI.ScreenResolution)
	GUI:GetWidgetByWindow(Language["Debug"], "fullscreen").Right:SetText(GetCVar("gxMaximize") == "1" and Language["Enabled"] or Language["Disabled"])
end

function Debug:UI_SCALE_CHANGED()
	vUI:UpdateScreenSize()
	
	GUI:GetWidgetByWindow(Language["Debug"], "suggested-scale").Right:SetText(vUI:GetSuggestedScale())
end

function Debug:ZONE_CHANGED()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function Debug:ZONE_CHANGED_INDOORS()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function Debug:ZONE_CHANGED_NEW_AREA()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function Debug:PLAYER_LEVEL_UP()
	GUI:GetWidgetByWindow(Language["Debug"], "level").Right:SetText(UnitLevel("player"))
end

function Debug:QUEST_LOG_UPDATE()
	GUI:GetWidgetByWindow(Language["Debug"], "quests").Right:SetText(GetQuests())
end

function Debug:ADDON_LOADED()
	GUI:GetWidgetByWindow(Language["Debug"], "loaded").Right:SetText(GetLoadedAddOns())
end

function Debug:CVAR_UPDATE(cvar)
	if (cvar == "scriptErrors") then
		GUI:GetWidgetByWindow(Language["Debug"], "display-errors").Right:SetText(GetCVar("scriptErrors") == "1" and Language["Enabled"] or Language["Disabled"])
	end
end

function Debug:ACTIVE_TALENT_GROUP_CHANGED()
	GUI:GetWidgetByWindow(Language["Debug"], "spec").Right:SetText(GetSpecName())
end

function Debug:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

function Debug:Load()
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("CVAR_UPDATE")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	-- Unavailable until PEW
	GUI:GetWidgetByWindow(Language["Debug"], "display-errors").Right:SetText(GetCVar("scriptErrors") == "1" and Language["Enabled"] or Language["Disabled"])
	GUI:GetWidgetByWindow(Language["Debug"], "fullscreen").Right:SetText(GetCVar("gxMaximize") == "1" and Language["Enabled"] or Language["Disabled"])
	GUI:GetWidgetByWindow(Language["Debug"], "spec").Right:SetText(GetSpecName())
	
	if (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]) then
		self:RegisterEvent("PLAYER_LEVEL_UP")
	end
	
	self:SetScript("OnEvent", self.OnEvent)
end