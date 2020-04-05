local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTime_GetGameTime = GameTime_GetGameTime
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local format = format
local select = select
local floor = floor

local Slots = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18}

local Frame = CreateFrame("Frame", "vUI Minimap", UIParent)

local GetDurability = function()
	local Current, Max
	local Total, Count = 0, 0
	
	for i = 1, #Slots do
		Current, Max = GetInventoryItemDurability(Slots[i])
		
		if Current then
			Total = Total + (Current / Max)
			Count = Count + 1
		end
	end
	
	return format("%s%%", floor(Total / Count * 100 + 0.5))
end

local ZoneUpdate = function(self)
	local Zone = GetMinimapZoneText()
	local PVPType = GetZonePVPInfo()
	local Color = vUI.ZoneColors[PVPType or "other"]
	
	self.Text:SetText(Zone)
	self.Text:SetTextColor(Color[1], Color[2], Color[3])
end

local TimeOnUpdate = function(self, elapsed)
	self.Ela = self.Ela + elapsed
	
	if (self.Ela >= 10) then
		self.Text:SetText(GameTime_GetLocalTime(true))
		
		self.Ela = 0
	end
end

local TimeOnEnter = function(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:ClearLines()
	
	HomeLatency, WorldLatency = select(3, GetNetStats())
	Framerate = floor(GetFramerate())
	ServerTime = GameTime_GetGameTime(true)
	
	GameTooltip:AddLine(Language["Realm Time:"], 1, 0.7, 0)
	GameTooltip:AddLine(ServerTime, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Latency:"], 1, 0.7, 0)
	GameTooltip:AddLine(format(Language["%s ms (home)"], HomeLatency), 1, 1, 1)
	GameTooltip:AddLine(format(Language["%s ms (world)"], WorldLatency), 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Framerate:"], 1, 0.7, 0)
	GameTooltip:AddLine(Framerate .. " fps", 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(Language["Durability:"], 1, 0.7, 0)
	GameTooltip:AddLine(GetDurability(), 1, 1, 1)
	
	GameTooltip:Show()
end

local TimeOnLeave = function()
	GameTooltip:Hide()
end

local TimeOnMouseUp = function(self, button)
	if (button == "LeftButton") then
		TimeManager_Toggle()
	else
		ToggleCalendar()
	end
end

local CreateMinimap = function()
	Frame:SetScaledPoint("TOPRIGHT", UIParent, -12, -12)
	Frame:SetBackdrop(vUI.BackdropAndBorder)
	Frame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Frame:SetBackdropBorderColor(0, 0, 0)
	
	local ZoneFrame = CreateFrame("Frame", "vUIZoneFrame", Frame)
	ZoneFrame:SetScaledHeight(20)
	ZoneFrame:SetScaledPoint("TOPLEFT", Frame, 3, -3)
	ZoneFrame:SetScaledPoint("TOPRIGHT", Frame, -3, -3)
	ZoneFrame:SetBackdrop(vUI.BackdropAndBorder)
	ZoneFrame:SetBackdropColor(0, 0, 0, 0)
	ZoneFrame:SetBackdropBorderColor(0, 0, 0)
	ZoneFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	ZoneFrame:RegisterEvent("ZONE_CHANGED")
	ZoneFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	ZoneFrame:SetScript("OnEvent", ZoneUpdate)
	
	ZoneFrame.Tex = ZoneFrame:CreateTexture(nil, "ARTWORK")
	ZoneFrame.Tex:SetPoint("TOPLEFT", ZoneFrame, 1, -1)
	ZoneFrame.Tex:SetPoint("BOTTOMRIGHT", ZoneFrame, -1, 1)
	ZoneFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ZoneFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ZoneFrame.Text = ZoneFrame:CreateFontString(nil, "OVERLAY", 7)
	ZoneFrame.Text:SetScaledHeight(20)
	ZoneFrame.Text:SetScaledPoint("LEFT", ZoneFrame, 6, 0)
	ZoneFrame.Text:SetScaledPoint("RIGHT", ZoneFrame, -6, 0)
	ZoneFrame.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	ZoneFrame.Text:SetJustifyH("CENTER")
	
	local TimeFrame = CreateFrame("Frame", "vUITimeFrame", Frame)
	TimeFrame:SetScaledHeight(20)
	TimeFrame:SetScaledPoint("BOTTOMLEFT", Frame, 3, 3)
	TimeFrame:SetScaledPoint("BOTTOMRIGHT", Frame, -3, 3)
	TimeFrame:SetBackdrop(vUI.BackdropAndBorder)
	TimeFrame:SetBackdropColor(0, 0, 0, 0)
	TimeFrame:SetBackdropBorderColor(0, 0, 0)
	TimeFrame.Ela = 0
	
	TimeFrame.Tex = TimeFrame:CreateTexture(nil, "ARTWORK")
	TimeFrame.Tex:SetPoint("TOPLEFT", TimeFrame, 1, -1)
	TimeFrame.Tex:SetPoint("BOTTOMRIGHT", TimeFrame, -1, 1)
	TimeFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	TimeFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	TimeFrame.Text = TimeFrame:CreateFontString(nil, "OVERLAY", 7)
	TimeFrame.Text:SetScaledHeight(20)
	TimeFrame.Text:SetScaledPoint("LEFT", TimeFrame, 6, 0)
	TimeFrame.Text:SetScaledPoint("RIGHT", TimeFrame, -6, 0)
	TimeFrame.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	TimeFrame.Text:SetJustifyH("CENTER")
	TimeFrame.Text:SetText(GameTime_GetLocalTime(true))
	
	if Settings["minimap-show-time"] then
		Frame:SetScaledSize((Settings["minimap-size"] + 8), (44 + 8 + Settings["minimap-size"]))
		TimeFrame:SetScript("OnUpdate", TimeOnUpdate)
	else
		Frame:SetScaledSize((Settings["minimap-size"] + 8), (22 + 8 + Settings["minimap-size"]))
		TimeFrame:SetAlpha(0)
	end
	
	vUI:GetModule("Move"):Add(Frame)
	
	TimeFrame:SetScript("OnEnter", TimeOnEnter)
	TimeFrame:SetScript("OnLeave", TimeOnLeave)
	TimeFrame:SetScript("OnMouseUp", TimeOnMouseUp)
	
	ZoneUpdate(ZoneFrame)
end

local OnMouseWheel = function(self, delta)
	if (delta > 0) then
		MinimapZoomIn:Click()
	elseif (delta < 0) then
		MinimapZoomOut:Click()
	end
end

local Kill = function(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	if (object.GetScript and object:GetScript("OnUpdate")) then
		object:SetScript("OnUpdate", nil)
	end
	
	object.Show = function() end
	object:Hide()
end

function GetMinimapShape()
	return "SQUARE"
end

local UpdateMinimapSize = function(value)
	Minimap:SetScaledSize(value, value)
	
	if Settings["minimap-show-time"] then
		_G["vUI Minimap"]:SetScaledSize((value + 8), (44 + 8 + value))
	else
		_G["vUI Minimap"]:SetScaledSize((value + 8), (22 + 8 + value))
	end
	
	Minimap:SetZoom(Minimap:GetZoom() + 1)
	Minimap:SetZoom(Minimap:GetZoom() - 1)
	Minimap:UpdateBlips()
end

local UpdateShowMinimapTime = function(value)
	local Time = vUITimeFrame
	
	if value then
		Frame:SetScaledSize((Settings["minimap-size"] + 8), (44 + 8 + Settings["minimap-size"]))
		
		Time.Ela = 12
		Time:SetScript("OnUpdate", TimeOnUpdate)
		Time:SetAlpha(1)
		
		Time.Text:SetText(GameTime_GetLocalTime(true))
	else
		Frame:SetScaledSize((Settings["minimap-size"] + 8), (22 + 8 + Settings["minimap-size"]))
		
		Time:SetScript("OnUpdate", nil)
		Time:SetAlpha(0)
	end
end

local OnEvent = function(self, event)
	if (not Settings["minimap-enable"]) then
		self:UnregisterEvent(event)
		
		return
	end
	
	CreateMinimap()
	Minimap:SetMaskTexture(Media:GetTexture("Blank"))
	
	Minimap:SetParent(self)
	Minimap:ClearAllPoints()
	Minimap:SetScaledPoint("TOP", vUIZoneFrame, "BOTTOM", 0, -3)
	Minimap:SetScaledSize(Settings["minimap-size"], Settings["minimap-size"])
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	
	Minimap.BG = Minimap:CreateTexture(nil, "BACKGROUND")
	Minimap.BG:SetTexture(Media:GetTexture("Blank"))
	Minimap.BG:SetVertexColor(0, 0, 0)
	Minimap.BG:SetScaledPoint("TOPLEFT", Minimap, -1, 1)
	Minimap.BG:SetScaledPoint("BOTTOMRIGHT", Minimap, 1, -1)
	
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetScaledPoint("TOPRIGHT", -4, 12)
	
	MiniMapMailIcon:SetScaledSize(32, 32)
	MiniMapMailIcon:SetTexture(Media:GetTexture("Mail 2"))
	MiniMapMailIcon:SetVertexColorHex("EEEEEE")
	
	MinimapNorthTag:SetTexture(nil)
	
	if MiniMapTrackingFrame then
		MiniMapTrackingFrame:ClearAllPoints()
		MiniMapTrackingFrame:SetScaledSize(24, 24)
		MiniMapTrackingFrame:SetScaledPoint("TOPLEFT", Minimap, 1, -1)
		MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
		
		MiniMapTrackingIcon:SetScaledSize(18, 18)
		MiniMapTrackingIcon:ClearAllPoints()
		MiniMapTrackingIcon:SetScaledPoint("TOPLEFT", MiniMapTrackingFrame, 1, -1)
		MiniMapTrackingIcon:SetScaledPoint("BOTTOMRIGHT", MiniMapTrackingFrame, -1, 1)
		MiniMapTrackingIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		
		MiniMapTrackingBorder:Hide()
		MiniMapTrackingBorder.Show = function() end
	end
	
	Kill(MinimapCluster)
	Kill(MinimapBorder)
	Kill(MinimapBorderTop)
	Kill(MinimapZoomIn)
	Kill(MinimapZoomOut)
	Kill(MinimapNorthTag)
	Kill(MiniMapWorldMapButton)
	Kill(MiniMapMailBorder)
	Kill(GameTimeFrame)
	Kill(TimeManagerClockButton)
	
	self:UnregisterEvent(event)
end

Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", OnEvent)

GUI:AddOptions(function(self)
	local Left = self:CreateWindow(Language["Minimap"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("minimap-enable", Settings["minimap-enable"], Language["Enable Minimap Module"], "Enable the vUI Minimap module", ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, "Minimap Size", "Set the size of the Minimap", UpdateMinimapSize)

	Left:CreateHeader(Language["Misc"])
	Left:CreateSwitch("minimap-show-time", Settings["minimap-show-time"], Language["Enable Minimap Time"], "Display time on the minimap", UpdateShowMinimapTime)
end)