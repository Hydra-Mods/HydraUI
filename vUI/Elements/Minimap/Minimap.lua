local vUI, GUI, Language, Media, Settings = select(2, ...):get()

local MM = vUI:NewModule("Minimap")

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

local OnMouseWheel = function(self, delta)
	if (delta > 0) then
		MinimapZoomIn:Click()
	elseif (delta < 0) then
		MinimapZoomOut:Click()
	end
end

function MM:Style()
	-- Backdrop
	self:SetScaledPoint("TOPRIGHT", UIParent, -12, -12)
	self:SetScaledSize((Settings["minimap-size"] + 8), (44 + 8 + Settings["minimap-size"]))
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Top Info
	self.TopFrame = CreateFrame("Frame", "vUIMinimapTop", self)
	self.TopFrame:SetScaledHeight(20)
	self.TopFrame:SetScaledPoint("TOPLEFT", self, 3, -3)
	self.TopFrame:SetScaledPoint("TOPRIGHT", self, -3, -3)
	self.TopFrame:SetBackdrop(vUI.BackdropAndBorder)
	self.TopFrame:SetBackdropColor(0, 0, 0, 0)
	self.TopFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.TopFrame.Tex = self.TopFrame:CreateTexture(nil, "ARTWORK")
	self.TopFrame.Tex:SetPoint("TOPLEFT", self.TopFrame, 1, -1)
	self.TopFrame.Tex:SetPoint("BOTTOMRIGHT", self.TopFrame, -1, 1)
	self.TopFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.TopFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	-- Bottom Info
	self.BottomFrame = CreateFrame("Frame", "vUIMinimapBottom", self)
	self.BottomFrame:SetScaledHeight(20)
	self.BottomFrame:SetScaledPoint("BOTTOMLEFT", self, 3, 3)
	self.BottomFrame:SetScaledPoint("BOTTOMRIGHT", self, -3, 3)
	self.BottomFrame:SetBackdrop(vUI.BackdropAndBorder)
	self.BottomFrame:SetBackdropColor(0, 0, 0, 0)
	self.BottomFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.BottomFrame.Tex = self.BottomFrame:CreateTexture(nil, "ARTWORK")
	self.BottomFrame.Tex:SetPoint("TOPLEFT", self.BottomFrame, 1, -1)
	self.BottomFrame.Tex:SetPoint("BOTTOMRIGHT", self.BottomFrame, -1, 1)
	self.BottomFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.BottomFrame.Tex:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	-- Style minimap
	Minimap:SetMaskTexture(Media:GetTexture("Blank"))
	Minimap:SetParent(self)
	Minimap:ClearAllPoints()
	Minimap:SetScaledPoint("TOP", self.TopFrame, "BOTTOM", 0, -3)
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
	
	vUI:GetModule("Move"):Add(self)
end

function MM:Load()
	if (not Settings["minimap-enable"]) then
		return
	end
	
	self:Style()
	
	function GetMinimapShape()
		return "SQUARE"
	end
end

local UpdateMinimapSize = function(value)
	MM:SetScaledSize((value + 8), (44 + 8 + value))
	
	Minimap:SetScaledSize(value, value)
	Minimap:SetZoom(Minimap:GetZoom() + 1)
	Minimap:SetZoom(Minimap:GetZoom() - 1)
	Minimap:UpdateBlips()
end

GUI:AddOptions(function(self)
	local Left = self:CreateWindow(Language["Minimap"])
	
	Left:CreateHeader(Language["Enable"])
	Left:CreateSwitch("minimap-enable", Settings["minimap-enable"], Language["Enable Minimap Module"], Language["Enable the vUI Minimap module"], ReloadUI):RequiresReload(true)
	
	Left:CreateHeader(Language["Styling"])
	Left:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, Language["Minimap Size"], Language["Set the size of the Minimap"], UpdateMinimapSize)
end)