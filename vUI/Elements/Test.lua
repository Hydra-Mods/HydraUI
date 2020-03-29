local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

local floor = floor
local format = format
local match = string.match
local tostring = tostring
local select = select
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local UseContainerItem = UseContainerItem
local GetItemInfo = GetItemInfo
local PickupMerchantItem = PickupMerchantItem
local GetFramerate = GetFramerate

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
	local MaxQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
	
	return format("%s / %s", NumQuests, MaxQuests)
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Debug"], nil, "zzzDebug")
	
	Left:CreateHeader(Language["UI Information"])
	Left:CreateDoubleLine(Language["UI Version"], vUI.UIVersion)
	Left:CreateDoubleLine(Language["Game Version"], vUI.GameVersion)
	Left:CreateDoubleLine(Language["Client"], GetClient())
	Left:CreateDoubleLine(Language["UI Scale"], Settings["ui-scale"])
	Left:CreateDoubleLine(Language["Suggested Scale"], vUI:GetSuggestedScale())
	Left:CreateDoubleLine(Language["Resolution"], vUI.ScreenResolution)
	Left:CreateDoubleLine(Language["Fullscreen"], vUI.IsFullScreen)
	Left:CreateDoubleLine(Language["Profile"], vUI:GetActiveProfileName())
	Left:CreateDoubleLine(Language["UI Style"], Settings["ui-style"])
	Left:CreateDoubleLine(Language["Locale"], vUI.UserLocale)
	--Left:CreateDoubleLine(Language["Language"], Settings["ui-language"])
	Left:CreateDoubleLine(Language["Display Errors"], GetCVar("scriptErrors"))
	
	Right:CreateHeader(Language["User Information"])
	Right:CreateDoubleLine(Language["Name"], vUI.UserName)
	Right:CreateDoubleLine(Language["Level"], UnitLevel("player"))
	Right:CreateDoubleLine(Language["Race"], vUI.UserRace)
	Right:CreateDoubleLine(Language["Class"], vUI.UserClassName)
	Right:CreateDoubleLine(Language["Realm"], vUI.UserRealm)
	Right:CreateDoubleLine(Language["Zone"], GetZoneText())
	Right:CreateDoubleLine(Language["Sub Zone"], GetMinimapZoneText())
	Right:CreateDoubleLine(Language["Quests"], GetQuests())
	
	Right:CreateHeader(Language["AddOns Information"])
	Right:CreateDoubleLine(Language["Total AddOns"], GetNumAddOns())
	Right:CreateDoubleLine(Language["Loaded AddOns"], GetNumLoadedAddOns())
end)

local UpdateDebugInfo = CreateFrame("Frame")

function UpdateDebugInfo:DISPLAY_SIZE_CHANGED()
	vUI:UpdateScreenHeight()
	
	GUI:GetWidgetByWindow(Language["Debug"], "suggested-scale").Right:SetText(vUI:GetSuggestedScale())
	GUI:GetWidgetByWindow(Language["Debug"], "resolution").Right:SetText(vUI.ScreenResolution)
	GUI:GetWidgetByWindow(Language["Debug"], "fullscreen").Right:SetText(vUI.IsFullScreen)
end

function UpdateDebugInfo:UI_SCALE_CHANGED()
	vUI:UpdateScreenHeight()
	
	GUI:GetWidgetByWindow(Language["Debug"], "suggested-scale").Right:SetText(vUI:GetSuggestedScale())
end

function UpdateDebugInfo:ZONE_CHANGED()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function UpdateDebugInfo:ZONE_CHANGED_INDOORS()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function UpdateDebugInfo:ZONE_CHANGED_NEW_AREA()
	GUI:GetWidgetByWindow(Language["Debug"], "zone").Right:SetText(GetZoneText())
	GUI:GetWidgetByWindow(Language["Debug"], "sub-zone").Right:SetText(GetMinimapZoneText())
end

function UpdateDebugInfo:PLAYER_LEVEL_UP()
	GUI:GetWidgetByWindow(Language["Debug"], "level").Right:SetText(UnitLevel("player"))
end

function UpdateDebugInfo:QUEST_LOG_UPDATE()
	GUI:GetWidgetByWindow(Language["Debug"], "quests").Right:SetText(GetQuests())
end

function UpdateDebugInfo:ADDON_LOADED()
	GUI:GetWidgetByWindow(Language["Debug"], "loaded").Right:SetText(GetLoadedAddOns())
end

function UpdateDebugInfo:PLAYER_ENTERING_WORLD()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	
	if (UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]) then
		self:RegisterEvent("PLAYER_LEVEL_UP")
	end
end

function UpdateDebugInfo:OnEvent(event)
	if self[event] then
		self[event](self)
	end
end

UpdateDebugInfo:RegisterEvent("ZONE_CHANGED")
UpdateDebugInfo:RegisterEvent("ZONE_CHANGED_INDOORS")
UpdateDebugInfo:RegisterEvent("ZONE_CHANGED_NEW_AREA")
UpdateDebugInfo:RegisterEvent("PLAYER_ENTERING_WORLD")
UpdateDebugInfo:SetScript("OnEvent", UpdateDebugInfo.OnEvent)

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateDoubleLine("Tukz", "Elv")
	Left:CreateDoubleLine("nightcracker", "Simpy")
	Left:CreateDoubleLine("Smelly", "Azilroka")
	Left:CreateDoubleLine("Foof", "Eclipse")
	
	Left:CreateHeader(Language["oUF"])
	Left:CreateDoubleLine("Haste", "lightspark")
	Left:CreateDoubleLine("p3lim", "Rainrider")
	
	Right:CreateHeader(Language["LibStub"])
	Right:CreateDoubleLine("Kaelten", "CtlAltDelAmmo")
	Right:CreateDoubleLine("jnwhiteh", "nevcairiel")
	Right:CreateDoubleLine("mikeclueby4", "")
	
	Right:CreateHeader(Language["LibSharedMedia"])
	Right:CreateDoubleLine("Elkano", "funkehdude")
	
	Right:CreateHeader(Language["vUI"])
	Right:CreateLine("Hydra")
end)

local Fonts = vUI:NewModule("Fonts")

_G.STANDARD_TEXT_FONT = Media:GetFont("PT Sans")
_G.UNIT_NAME_FONT = Media:GetFont("PT Sans")
_G.DAMAGE_TEXT_FONT = Media:GetFont("PT Sans")

function Fonts:Load()
	local Font = Media:GetFont(Settings["ui-widget-font"])
	
	UIErrorsFrame:SetFont(Font, 16)
	
	RaidWarningFrameSlot1:SetFont(Font, 16)
	RaidWarningFrameSlot2:SetFont(Font, 16)
	
	AutoFollowStatusText:SetFontInfo(Font, 18)
end

--[[
local IconSize = 40
local IconHeight = floor(IconSize * 0.6)
local IconRatio = (1 - (IconHeight / IconSize)) / 2

local Icon = CreateFrame("Frame", nil, UIParent)
Icon:SetScaledPoint("CENTER")
Icon:SetScaledSize(IconSize, IconHeight)
Icon:SetBackdrop(vUI.Backdrop)
Icon:SetBackdropColor(0, 0, 0)

Icon.t = Icon:CreateTexture(nil, "OVERLAY")
Icon.t:SetScaledPoint("TOPLEFT", Icon, 1, -1)
Icon.t:SetScaledPoint("BOTTOMRIGHT", Icon, -1, 1)
Icon.t:SetTexture("Interface\\ICONS\\spell_warlock_soulburn")
Icon.t:SetTexCoord(0.1, 0.9, 0.1 + IconRatio, 0.9 - IconRatio)]]