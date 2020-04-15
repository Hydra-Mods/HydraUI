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
	vUI:SetPoint(self, "TOPRIGHT", UIParent, -12, -12)
	vUI:SetSize(self, (Settings["minimap-size"] + 8), (44 + 8 + Settings["minimap-size"]))
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Top Info
	self.TopFrame = CreateFrame("Frame", "vUIMinimapTop", self)
	vUI:SetHeight(self.TopFrame, 20)
	vUI:SetPoint(self.TopFrame, "TOPLEFT", self, 3, -3)
	vUI:SetPoint(self.TopFrame, "TOPRIGHT", self, -3, -3)
	self.TopFrame:SetBackdrop(vUI.BackdropAndBorder)
	self.TopFrame:SetBackdropColor(0, 0, 0, 0)
	self.TopFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.TopFrame.Tex = self.TopFrame:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.TopFrame.Tex, "TOPLEFT", self.TopFrame, 1, -1)
	vUI:SetPoint(self.TopFrame.Tex, "BOTTOMRIGHT", self.TopFrame, -1, 1)
	self.TopFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.TopFrame.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- Bottom Info
	self.BottomFrame = CreateFrame("Frame", "vUIMinimapBottom", self)
	vUI:SetHeight(self.BottomFrame, 20)
	vUI:SetPoint(self.BottomFrame, "BOTTOMLEFT", self, 3, 3)
	vUI:SetPoint(self.BottomFrame, "BOTTOMRIGHT", self, -3, 3)
	self.BottomFrame:SetBackdrop(vUI.BackdropAndBorder)
	self.BottomFrame:SetBackdropColor(0, 0, 0, 0)
	self.BottomFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.BottomFrame.Tex = self.BottomFrame:CreateTexture(nil, "ARTWORK")
	vUI:SetPoint(self.BottomFrame.Tex, "TOPLEFT", self.BottomFrame, 1, -1)
	vUI:SetPoint(self.BottomFrame.Tex, "BOTTOMRIGHT", self.BottomFrame, -1, 1)
	self.BottomFrame.Tex:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.BottomFrame.Tex:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- Style minimap
	Minimap:SetMaskTexture(Media:GetTexture("Blank"))
	Minimap:SetParent(self)
	Minimap:ClearAllPoints()
	vUI:SetPoint(Minimap, "TOP", self.TopFrame, "BOTTOM", 0, -3)
	vUI:SetSize(Minimap, Settings["minimap-size"], Settings["minimap-size"])
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	
	Minimap.BG = Minimap:CreateTexture(nil, "BACKGROUND")
	Minimap.BG:SetTexture(Media:GetTexture("Blank"))
	Minimap.BG:SetVertexColor(0, 0, 0)
	vUI:SetPoint(Minimap.BG, "TOPLEFT", Minimap, -1, 1)
	vUI:SetPoint(Minimap.BG, "BOTTOMRIGHT", Minimap, 1, -1)
	
	MiniMapMailFrame:ClearAllPoints()
	vUI:SetPoint(MiniMapMailFrame, "TOPRIGHT", -4, 12)
	
	vUI:SetSize(MiniMapMailIcon, 32, 32)
	MiniMapMailIcon:SetTexture(Media:GetTexture("Mail 2"))
	MiniMapMailIcon:SetVertexColor(vUI:HexToRGB("EEEEEE"))
	
	MinimapNorthTag:SetTexture(nil)
	
	QueueStatusMinimapButton:ClearAllPoints()
	vUI:SetPoint(QueueStatusMinimapButton, "BOTTOMLEFT", Minimap, 1, 1)
	
	if MiniMapTrackingFrame then
		MiniMapTrackingFrame:ClearAllPoints()
		vUI:SetSize(MiniMapTrackingFrame, 24, 24)
		vUI:SetPoint(MiniMapTrackingFrame, "TOPLEFT", Minimap, 1, -1)
		MiniMapTrackingFrame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
		
		vUI:SetSize(MiniMapTrackingIcon, 18, 18)
		MiniMapTrackingIcon:ClearAllPoints()
		vUI:SetPoint(MiniMapTrackingIcon, "TOPLEFT", MiniMapTrackingFrame, 1, -1)
		vUI:SetPoint(MiniMapTrackingIcon, "BOTTOMRIGHT", MiniMapTrackingFrame, -1, 1)
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
	
	vUI:CreateMover(self)
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
	vUI:SetSize(MM, (value + 8), (44 + 8 + value))
	
	vUI:SetSize(Minimap, value, value)
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