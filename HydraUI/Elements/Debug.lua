local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Debug = HydraUI:NewModule("Debug")

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

local GetSpecInfo = function()
	local MainSpec
	local PointsTotal = ""
	local HighestPoints = 0
	local Name, PointsSpent, _
	
	for i = 1, 5 do -- Default UI uses 5 here for some reason? Just going to roll with it right now even though it makes no sense to me
		Name, _, PointsSpent = GetTalentTabInfo(i)
		
		if Name then
			if (PointsSpent > HighestPoints) then
				MainSpec = Name
				HighestPoints = PointsSpent
			end
			
			PointsTotal = PointsTotal == "" and PointsSpent or PointsTotal .. "/" .. PointsSpent
		end
	end
	
	return MainSpec and format("%s (%s)", MainSpec, PointsTotal) or NOT_APPLICABLE
end

local OnShow = function()
	GUI:GetWidget("dgb-show-errors").Right:SetText(GetCVar("scriptErrors") == "1" and Language["Enabled"] or Language["Disabled"])
	GUI:GetWidget("dgb-fullscreen").Right:SetText(GetCVar("gxMaximize") == "1" and Language["Enabled"] or Language["Disabled"])
	GUI:GetWidget("dgb-spec").Right:SetText(GetSpecInfo())
	
	Debug:RegisterEvent("ZONE_CHANGED")
	Debug:RegisterEvent("ZONE_CHANGED_INDOORS")
	Debug:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Debug:RegisterEvent("DISPLAY_SIZE_CHANGED")
	Debug:RegisterEvent("UI_SCALE_CHANGED")
	Debug:RegisterEvent("QUEST_LOG_UPDATE")
	Debug:RegisterEvent("CVAR_UPDATE")
	Debug:RegisterEvent("CHARACTER_POINTS_CHANGED")
	
	if (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]) then
		Debug:RegisterEvent("PLAYER_LEVEL_UP")
	end
	
	Debug:SetScript("OnEvent", Debug.OnEvent)
end

local OnHide = function()
	Debug:UnregisterAllEvents()
end

GUI:AddWidgets(Language["Info"], Language["Debug"], function(left, right)
	left:HookScript("OnShow", OnShow)
	left:HookScript("OnHide", OnHide)
	
	left:CreateHeader(Language["UI Information"])
	left:CreateDoubleLine("dgb-game-version", Language["Game Version"], GetBuildInfo())
	left:CreateDoubleLine("dgb-client", Language["Client"], GetClient())
	left:CreateDoubleLine("dgb-ui-scale", Language["UI Scale"], Settings["ui-scale"])
	left:CreateDoubleLine("dgb-suggested-scale", Language["Suggested Scale"], HydraUI:GetSuggestedScale())
	left:CreateDoubleLine("dgb-reso", Language["Resolution"], HydraUI.ScreenResolution)
	left:CreateDoubleLine("dgb-screen-size", Language["Screen Size"], format("%sx%s", GetPhysicalScreenSize()))
	left:CreateDoubleLine("dgb-fullscreen", Language["Fullscreen"], "")
	left:CreateDoubleLine("dgb-profile", Language["Profile"], HydraUI:GetActiveProfileName())
	left:CreateDoubleLine("dgb-profile-count", Language["Profile Count"], HydraUI:GetProfileCount())
	left:CreateDoubleLine("dgb-ui-style", Language["UI Style"], Settings["ui-style"])
	left:CreateDoubleLine("dgb-locale", Language["Locale"], HydraUI.UserLocale)
	left:CreateDoubleLine("dgb-show-errors", Language["Display Errors"], "")
	
	right:CreateHeader(Language["User Information"])
	right:CreateDoubleLine("dgb-level", Language["Level"], UnitLevel("player"))
	right:CreateDoubleLine("dgb-race", Language["Race"], HydraUI.UserRace)
	right:CreateDoubleLine("dgb-class", Language["Class"], UnitClass("player"))
	right:CreateDoubleLine("dgb-spec", Language["Spec"], "")
	right:CreateDoubleLine("dgb-realm", Language["Realm"], HydraUI.UserRealm)
	right:CreateDoubleLine("dgb-zone", Language["Zone"], GetZoneText())
	right:CreateDoubleLine("dgb-subzone", Language["Sub Zone"], GetMinimapZoneText())
	right:CreateDoubleLine("dgb-quests", Language["Quests"], GetQuests())
	
	right:CreateHeader(Language["AddOns Information"])
	right:CreateDoubleLine("dgb-total-addons", Language["Total AddOns"], GetNumAddOns())
	right:CreateDoubleLine("dgb-loaded-addons", Language["Loaded AddOns"], GetNumLoadedAddOns())
	right:CreateDoubleLine("dgb-loaded-plugins", Language["Loaded Plugins"], #HydraUI.Plugins)
end)

function Debug:DISPLAY_SIZE_CHANGED()
	HydraUI:UpdateScreenSize()
	
	GUI:GetWidget("dgb-suggested-scale").Right:SetText(HydraUI:GetSuggestedScale())
	GUI:GetWidget("dgb-reso").Right:SetText(HydraUI.ScreenResolution)
	GUI:GetWidget("dgb-fullscreen").Right:SetText(GetCVar("gxMaximize") == "1" and Language["Enabled"] or Language["Disabled"])
end

function Debug:UI_SCALE_CHANGED()
	HydraUI:UpdateScreenSize()
	
	GUI:GetWidget("dgb-suggested-scale").Right:SetText(HydraUI:GetSuggestedScale())
end

function Debug:ZONE_CHANGED()
	GUI:GetWidget("dgb-zone").Right:SetText(GetZoneText())
	GUI:GetWidget("dgb-subzone").Right:SetText(GetMinimapZoneText())
end

function Debug:ZONE_CHANGED_INDOORS()
	GUI:GetWidget("dgb-zone").Right:SetText(GetZoneText())
	GUI:GetWidget("dgb-subzone").Right:SetText(GetMinimapZoneText())
end

function Debug:ZONE_CHANGED_NEW_AREA()
	GUI:GetWidget("dgb-zone").Right:SetText(GetZoneText())
	GUI:GetWidget("dgb-subzone").Right:SetText(GetMinimapZoneText())
end

function Debug:PLAYER_LEVEL_UP()
	GUI:GetWidget("dgb-level").Right:SetText(UnitLevel("player"))
end

function Debug:QUEST_LOG_UPDATE()
	GUI:GetWidget("dgb-quests").Right:SetText(GetQuests())
end

function Debug:ADDON_LOADED()
	GUI:GetWidget("dgb-loaded-addons").Right:SetText(GetLoadedAddOns())
end

function Debug:CVAR_UPDATE(cvar)
	if (cvar == "scriptErrors") then
		GUI:GetWidget("dgb-show-errors").Right:SetText(GetCVar("scriptErrors") == "1" and Language["Enabled"] or Language["Disabled"])
	end
end

function Debug:CHARACTER_POINTS_CHANGED()
	GUI:GetWidget("dgb-spec").Right:SetText(GetSpecInfo())
end

function Debug:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end