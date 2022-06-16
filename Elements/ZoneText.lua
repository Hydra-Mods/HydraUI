local HydraUI, Language, Assets, Settings = select(2, ...):get()

local ZT = HydraUI:NewModule("Zone Text")

local GetZoneText = GetZoneText
local GetSubZoneText = GetSubZoneText
local GetZonePVPInfo = GetZonePVPInfo
local SANCTUARY_TERRITORY = SANCTUARY_TERRITORY
local FREE_FOR_ALL_TERRITORY = FREE_FOR_ALL_TERRITORY
local FACTION_CONTROLLED_TERRITORY = FACTION_CONTROLLED_TERRITORY
local CONTESTED_TERRITORY = CONTESTED_TERRITORY
local COMBAT_ZONE = COMBAT_ZONE

local PVPText = {
	sanctuary = SANCTUARY_TERRITORY,
	arena = FREE_FOR_ALL_TERRITORY,
	contested = CONTESTED_TERRITORY,
	combat = COMBAT_ZONE,
}

local PVPTextFormat = {
	friendly = 1,
	hostile = 1,
}

function ZT:OnEvent(event)
	local Zone = GetZoneText()
	local SubZone = GetSubZoneText()
	local PVPType, IsSubZonePVP, Faction = GetZonePVPInfo()
	local Color = HydraUI.ZoneColors[PVPType or "other"]
	
	self.ZoneText:SetText("")
	self.SubZoneText:SetText("")
	self.PVPText:SetText("")
	
	self.ZoneText:SetTextColor(Color[1], Color[2], Color[3])
	self.SubZoneText:SetTextColor(Color[1], Color[2], Color[3])
	self.PVPText:SetTextColor(Color[1], Color[2], Color[3])
	
	if (event == "ZONE_CHANGED_NEW_AREA" or Zone ~= self.CurrentZone) and (PVPType and PVPType ~= "") then
		if PVPText[PVPType] then
			self.PVPText:SetText(PVPText[PVPType])
		elseif (PVPTextFormat[PVPType] and Faction and Faction ~= "") then
			self.PVPText:SetFormattedText(FACTION_CONTROLLED_TERRITORY, Faction)
		end
	end
	
	if (Zone and Zone ~= self.CurrentZone or SubZone == "") then
		self.ZoneText:SetText(Zone)
		self.CurrentZone = Zone
	end
	
	self.SubZoneText:SetText(SubZone)
	
	if self.Group:IsPlaying() then
		self.Group:Stop()
	end
	
	self.Group:Play()
end

function ZT:CreateFontObjects()
	local ZoneFrame = CreateFrame("Frame", nil, HydraUI.UIParent)
	ZoneFrame:SetSize(32, 32)
	ZoneFrame:SetPoint("TOP", HydraUI.UIParent, 0, -220)
	ZoneFrame:SetAlpha(0)
	-- Make a mover too? :thinking:
	
	local ZoneText = ZoneFrame:CreateFontString(nil, "OVERLAY")
	ZoneText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 32, "OUTLINE")
	ZoneText:SetPoint("CENTER", ZoneFrame, 0, 0)
	
	local SubZoneText = ZoneFrame:CreateFontString(nil, "OVERLAY")
	SubZoneText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 26, "OUTLINE")
	SubZoneText:SetPoint("TOP", ZoneText, "BOTTOM", 0, 0)
	
	local PVPText = ZoneFrame:CreateFontString(nil, "OVERLAY")
	PVPText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 26, "OUTLINE")
	PVPText:SetPoint("TOP", SubZoneText, "BOTTOM", 0, 0)
	
	local Group = CreateAnimationGroup(ZoneFrame)
	
	local ZoneFadeIn = Group:CreateAnimation("fade")
	ZoneFadeIn:SetEasing("in")
	ZoneFadeIn:SetDuration(0.4)
	ZoneFadeIn:SetOrder(1)
	ZoneFadeIn:SetChange(1)
	
	local ZoneSleep = Group:CreateAnimation("sleep")
	ZoneSleep:SetDuration(2.5)
	ZoneSleep:SetOrder(2)
	
	local ZoneFadeOut = Group:CreateAnimation("fade")
	ZoneFadeOut:SetEasing("out")
	ZoneFadeOut:SetDuration(0.75)
	ZoneFadeOut:SetChange(0)
	ZoneFadeOut:SetOrder(3)
	
	self.ZoneText = ZoneText
	self.SubZoneText = SubZoneText
	self.PVPText = PVPText
	self.Group = Group
end

function ZT:Load()
	-- Kill default zone texts
	if ZoneTextFrame then
		ZoneTextFrame:UnregisterAllEvents()
		ZoneTextFrame:SetScript("OnEvent", nil)
		ZoneTextFrame:SetScript("OnUpdate", nil)
	end
	
	self:CreateFontObjects()
	
	self.CurrentZone = nil -- nil instead of GetZoneText() so the first OnEvent call shows pvp info
	
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:SetScript("OnEvent", self.OnEvent)
end