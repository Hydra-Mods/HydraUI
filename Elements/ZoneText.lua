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

	self.ZoneText:SetTextColor(Color[1], Color[2], Color[3])
	self.SubZoneText:SetTextColor(Color[1], Color[2], Color[3])
	self.PVPText:SetTextColor(Color[1], Color[2], Color[3])

	if (event == "ZONE_CHANGED_NEW_AREA" or Zone ~= self.CurrentZone) and (PVPType and PVPType ~= "") then
		if PVPText[PVPType] then
			if self.ZoneFrame[3].Group:IsPlaying() then
				self.ZoneFrame[3].Group:Stop()
			end

			self.PVPText:SetText(PVPText[PVPType])

			if (not self.ZoneFrame[3].Group:IsPlaying()) then
				self.ZoneFrame[3].Group:Play()
			end
		elseif (PVPTextFormat[PVPType] and Faction and Faction ~= "") then
			if self.ZoneFrame[3].Group:IsPlaying() then
				self.ZoneFrame[3].Group:Stop()
			end

			self.PVPText:SetFormattedText(FACTION_CONTROLLED_TERRITORY, Faction)

			if (not self.ZoneFrame[3].Group:IsPlaying()) then
				self.ZoneFrame[3].Group:Play()
			end
		end
	end

	if (Zone and Zone ~= self.CurrentZone or SubZone == "") then
		if self.ZoneFrame[1].Group:IsPlaying() then
			self.ZoneFrame[1].Group:Stop()
		end

		self.ZoneText:SetText(Zone)
		self.CurrentZone = Zone

		if (not self.ZoneFrame[1].Group:IsPlaying()) then
			self.ZoneFrame[1].Group:Play()
		end
	end

	if (SubZone ~= Zone) then
		if self.ZoneFrame[2].Group:IsPlaying() then
			self.ZoneFrame[2].Group:Stop()
		end

		self.SubZoneText:SetText(SubZone)

		if (not self.ZoneFrame[2].Group:IsPlaying()) then
			self.ZoneFrame[2].Group:Play()
		end
	end
end

function ZT:CreateFontObjects()
	local ZoneFrame = CreateFrame("Frame", nil, HydraUI.UIParent)
	ZoneFrame:SetSize(32, 32)
	ZoneFrame:SetPoint("TOP", HydraUI.UIParent, 0, -220)

	local SubFrame

	for i = 1, 3 do
		SubFrame = CreateFrame("Frame", nil, HydraUI.UIParent)
		SubFrame:SetSize(32, 32)
		SubFrame:SetPoint("CENTER", ZoneFrame, 0, 0)
		SubFrame:SetAlpha(0)

		SubFrame.Group = LibMotion:CreateAnimationGroup()

		SubFrame.FadeIn = LibMotion:CreateAnimation(SubFrame, "fade")
		SubFrame.FadeIn:SetEasing("in")
		SubFrame.FadeIn:SetDuration(0.4)
		SubFrame.FadeIn:SetEndDelay(2.5)
		SubFrame.FadeIn:SetChange(1)
		SubFrame.FadeIn:SetGroup(SubFrame.Group)

		SubFrame.FadeOut = LibMotion:CreateAnimation(SubFrame, "fade")
		SubFrame.FadeOut:SetEasing("out")
		SubFrame.FadeOut:SetDuration(0.75)
		SubFrame.FadeOut:SetChange(0)
		SubFrame.FadeOut:SetGroup(SubFrame.Group)
		SubFrame.FadeOut:SetOrder(2)
		
		ZoneFrame[i] = SubFrame
	end

	local ZoneText = ZoneFrame[1]:CreateFontString(nil, "OVERLAY")
	ZoneText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 32, "OUTLINE")
	ZoneText:SetPoint("CENTER", ZoneFrame, 0, 0)

	local SubZoneText = ZoneFrame[2]:CreateFontString(nil, "OVERLAY")
	SubZoneText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 26, "OUTLINE")
	SubZoneText:SetPoint("TOP", ZoneText, "BOTTOM", 0, 0)

	local PVPText = ZoneFrame[3]:CreateFontString(nil, "OVERLAY")
	PVPText:SetFont(Assets:GetFont(Settings["ui-widget-font"]), 26, "OUTLINE")
	PVPText:SetPoint("TOP", SubZoneText, "BOTTOM", 0, 0)

	self.ZoneFrame = ZoneFrame
	self.ZoneText = ZoneText
	self.SubZoneText = SubZoneText
	self.PVPText = PVPText
end

function ZT:Load()
	-- Kill default zone texts
	if ZoneTextFrame then
		ZoneTextFrame:UnregisterAllEvents()
		ZoneTextFrame:SetScript("OnEvent", nil)
		ZoneTextFrame:SetScript("OnUpdate", nil)
	end

	self:CreateFontObjects()

	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:SetScript("OnEvent", self.OnEvent)
end