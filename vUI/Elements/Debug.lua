local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

if 1 == 1 then return end

local Debug = vUI:NewModule("Debug")

local format = format
local select = select
local GetZoneText = GetZoneText
local GetMinimapZoneText = GetMinimapZoneText

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
		return "Windows"
	elseif IsMacClient() then
		return "Mac"
	else -- IsLinuxClient
		return "Linux"
	end
end

local GetQuests = function()
	local NumQuests = select(2, C_QuestLog.GetNumQuestLogEntries())
	local MaxQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
	
	return format("%s / %s", NumQuests, MaxQuests)
end

local GetSpecName = function()
	local Name = select(2, GetSpecializationInfo(GetSpecialization()))
	
	return Name
end

GUI:AddWidgets(Language["General"], Language["Debug"], function(left, right)
	left:CreateHeader(Language["UI Information"])
	left:CreateDoubleLine(Language["Game Version"], GetBuildInfo())
	left:CreateDoubleLine(Language["Client"], GetClient())
	left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	left:CreateDoubleLine(Language["Screen Size"], format("%sx%s", GetPhysicalScreenSize()))
	left:CreateDoubleLine(Language["Fullscreen"], "")
	left:CreateDoubleLine(Language["Profile"], vUI:GetActiveProfileName())
	left:CreateDoubleLine(Language["Profile Count"], vUI:GetProfileCount())
	left:CreateDoubleLine(Language["UI Style"], Settings["ui-style"])
	left:CreateDoubleLine(Language["Locale"], vUI.UserLocale)
	left:CreateDoubleLine(Language["Display Errors"], "")
	
	right:CreateHeader(Language["User Information"])
	right:CreateDoubleLine(Language["Level"], UnitLevel("player"))
	right:CreateDoubleLine(Language["Race"], vUI.UserRace)
	right:CreateDoubleLine(Language["Class"], UnitClass("player"))
	right:CreateDoubleLine(Language["Spec"], "")
	right:CreateDoubleLine(Language["Realm"], vUI.UserRealm)
	right:CreateDoubleLine(Language["Zone"], GetZoneText())
	right:CreateDoubleLine(Language["Sub Zone"], GetMinimapZoneText())
	right:CreateDoubleLine(Language["Quests"], GetQuests())
	right:CreateHeader(Language["AddOns Information"])
	right:CreateDoubleLine(Language["Total AddOns"], GetNumAddOns())
	right:CreateDoubleLine(Language["Loaded AddOns"], GetNumLoadedAddOns())
	right:CreateDoubleLine(Language["Loaded Plugins"], "")
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
	GUI:GetWidgetByWindow(Language["Debug"], "loaded-plugins").Right:SetText(#vUI.Plugins)
	
	if (UnitLevel("player") > 59) then
		self:RegisterEvent("PLAYER_LEVEL_UP")
	end
	
	self:SetScript("OnEvent", self.OnEvent)
end