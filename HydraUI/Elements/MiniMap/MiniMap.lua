local HydraUI, GUI, Language, Assets, Settings = select(2, ...):get()

local Map = HydraUI:NewModule("Minimap")

function Map:Disable(object)
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

function Map:Style()
	-- Backdrop
	self:SetPoint("TOPRIGHT", HydraUI.UIParent, -12, -12)
	self:SetSize((Settings["minimap-size"] + 8), ((Settings["minimap-show-top"] == true and 22 or 0) + (Settings["minimap-show-bottom"] == true and 22 or 0) + 8 + Settings["minimap-size"]))
	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	
	-- Top Info
	self.TopFrame = CreateFrame("Frame", "HydraUIMinimapTop", self, "BackdropTemplate")
	self.TopFrame:SetHeight(20)
	self.TopFrame:SetPoint("TOPLEFT", self, 3, -3)
	self.TopFrame:SetPoint("TOPRIGHT", self, -3, -3)
	self.TopFrame:SetBackdrop(HydraUI.BackdropAndBorder)
	self.TopFrame:SetBackdropColor(0, 0, 0, 0)
	self.TopFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.TopFrame.Tex = self.TopFrame:CreateTexture(nil, "ARTWORK")
	self.TopFrame.Tex:SetPoint("TOPLEFT", self.TopFrame, 1, -1)
	self.TopFrame.Tex:SetPoint("BOTTOMRIGHT", self.TopFrame, -1, 1)
	self.TopFrame.Tex:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.TopFrame.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	-- Bottom Info
	self.BottomFrame = CreateFrame("Frame", "HydraUIMinimapBottom", self, "BackdropTemplate")
	self.BottomFrame:SetHeight(20)
	self.BottomFrame:SetPoint("BOTTOMLEFT", self, 3, 3)
	self.BottomFrame:SetPoint("BOTTOMRIGHT", self, -3, 3)
	self.BottomFrame:SetBackdrop(HydraUI.BackdropAndBorder)
	self.BottomFrame:SetBackdropColor(0, 0, 0, 0)
	self.BottomFrame:SetBackdropBorderColor(0, 0, 0)
	
	self.BottomFrame.Tex = self.BottomFrame:CreateTexture(nil, "ARTWORK")
	self.BottomFrame.Tex:SetPoint("TOPLEFT", self.BottomFrame, 1, -1)
	self.BottomFrame.Tex:SetPoint("BOTTOMRIGHT", self.BottomFrame, -1, 1)
	self.BottomFrame.Tex:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.BottomFrame.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	-- Style minimap
	Minimap:SetMaskTexture(Assets:GetTexture("Blank"))
	Minimap:SetParent(self)
	Minimap:ClearAllPoints()
	Minimap:SetSize(Settings["minimap-size"], Settings["minimap-size"])
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	
	Minimap.BG = Minimap:CreateTexture(nil, "BACKGROUND")
	Minimap.BG:SetTexture(Assets:GetTexture("Blank"))
	Minimap.BG:SetVertexColor(0, 0, 0)
	Minimap.BG:SetPoint("TOPLEFT", Minimap, -1, 1)
	Minimap.BG:SetPoint("BOTTOMRIGHT", Minimap, 1, -1)
	
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPRIGHT", -4, 12)
	
	MiniMapMailIcon:SetSize(32, 32)
	MiniMapMailIcon:SetTexture(Assets:GetTexture("Mail 2"))
	MiniMapMailIcon:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	MinimapNorthTag:SetTexture(nil)
	
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, 0, -2)
	
	MiniMapTrackingBackground:SetTexture(nil)
	MiniMapTrackingBorder:SetTexture(nil)
	MiniMapTrackingShine:SetTexture(nil)
	
	self.Tracking = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	self.Tracking:SetSize(20, 20)
	self.Tracking:SetPoint("TOPLEFT", Minimap, 2, -2)
	self.Tracking:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Tracking:SetBackdropColor(0, 0, 0)
	self.Tracking:SetBackdropBorderColor(0, 0, 0)
	
	self.Tracking.Tex = self.Tracking:CreateTexture(nil, "ARTWORK")
	self.Tracking.Tex:SetPoint("TOPLEFT", self.Tracking, 1, -1)
	self.Tracking.Tex:SetPoint("BOTTOMRIGHT", self.Tracking, -1, 1)
	self.Tracking.Tex:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Tracking.Tex:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	MiniMapTracking:SetParent(self.Tracking)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("CENTER", self.Tracking, 0, 0)
	
	MiniMapTrackingIcon:SetSize(18, 18)
	MiniMapTrackingIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	MiniMapTrackingIcon:SetPoint("CENTER", self.Tracking)
	
	self:Disable(MinimapCluster)
	self:Disable(MinimapBorder)
	self:Disable(MinimapBorderTop)
	self:Disable(MinimapZoomIn)
	self:Disable(MinimapZoomOut)
	self:Disable(MinimapNorthTag)
	self:Disable(MiniMapWorldMapButton)
	self:Disable(MiniMapMailBorder)
	self:Disable(GameTimeFrame)
	self:Disable(TimeManagerClockButton)
	
	if Settings["minimap-show-top"] and not Settings["minimap-show-bottom"] then
		Minimap:SetPoint("BOTTOM", Map, 0, 4)
	elseif Settings["minimap-show-bottom"] and not Settings["minimap-show-top"] then
		Minimap:SetPoint("TOP", Map, 0, -4)
	else
		Minimap:SetPoint("CENTER", Map, 0, 0)
	end
	
	if (not Settings["minimap-show-top"]) then
		self.TopFrame:Hide()
	end
	
	if (not Settings["minimap-show-bottom"]) then
		self.BottomFrame:Hide()
	end
	
	HydraUI:CreateMover(self)
end

local UpdateMinimapSize = function(value)
	Map:SetSize((value + 8), ((Settings["minimap-show-top"] == true and 22 or 0) + (Settings["minimap-show-bottom"] == true and 22 or 0) + 8 + value))
	
	Minimap:SetSize(value, value)
	Minimap:SetZoom(Minimap:GetZoom() + 1)
	Minimap:SetZoom(Minimap:GetZoom() - 1)
	Minimap:UpdateBlips()
	Minimap:ClearAllPoints()
	
	if Settings["minimap-show-top"] and not Settings["minimap-show-bottom"] then
		Minimap:SetPoint("BOTTOM", Map, 0, 4)
	elseif Settings["minimap-show-bottom"] and not Settings["minimap-show-top"] then
		Minimap:SetPoint("TOP", Map, 0, -4)
	else
		Minimap:SetPoint("CENTER", Map, 0, 0)
	end
end

local UpdateShowTopBar = function(value)
	local Anchor = HydraUI:GetModule("DataText"):GetAnchor("Minimap-Top")
	
	if value then
		Map.TopFrame:Show()
		
		if Anchor.Enable then
			Anchor:Enable()
		end
	else
		Map.TopFrame:Hide()
		
		if Anchor.Disable then
			Anchor:Disable()
		end
	end
	
	UpdateMinimapSize(Settings["minimap-size"])
end

local UpdateShowBottomBar = function(value)
	local Anchor = HydraUI:GetModule("DataText"):GetAnchor("Minimap-Bottom")
	
	if value then
		Map.BottomFrame:Show()
		
		if Anchor.Enable then
			Anchor:Enable()
		end
	else
		Map.BottomFrame:Hide()
		
		if Anchor.Disable then
			Anchor:Disable()
		end
	end
	
	UpdateMinimapSize(Settings["minimap-size"])
end

function Map:Load()
	if (not Settings["minimap-enable"]) then
		return
	end
	
	self:Style()
	
	function GetMinimapShape()
		return "SQUARE"
	end
end

GUI:AddWidgets(Language["General"], Language["Minimap"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("minimap-enable", Settings["minimap-enable"], Language["Enable Mini Map Module"], Language["Enable the HydraUI mini map module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, Language["Mini Map Size"], Language["Set the size of the mini map"], UpdateMinimapSize)
	left:CreateSwitch("minimap-show-top", Settings["minimap-show-top"], Language["Enable Top Bar"], Language["Enable the data text bar on top of the mini map"], UpdateShowTopBar)
	left:CreateSwitch("minimap-show-bottom", Settings["minimap-show-bottom"], Language["Enable Bottom Bar"], Language["Enable the data text bar on the bottom of the mini map"], UpdateShowBottomBar)
end)