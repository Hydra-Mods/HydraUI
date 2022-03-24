local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local TH = HydraUI:NewModule("Talking Head")

Defaults["hide-th"] = true

local CloseOnEnter = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B"))
end

local CloseOnLeave = function(self)
	self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
end

local CloseOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	TalkingHeadFrame_CloseImmediately()
end

local CloseOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

TH.Hide = CreateFrame("Frame")
TH.Hide:Hide()

function TH:ApplyStyle()
	HydraUI:SetFontInfo(TalkingHeadFrame.NameFrame.Name, Settings["ui-font"], 22, Settings["ui-font-flags"])
	HydraUI:SetFontInfo(TalkingHeadFrame.TextFrame.Text, Settings["ui-font"], 16, Settings["ui-font-flags"])
	
	TalkingHeadFrame.BackgroundFrame.TextBackground:SetAtlas(nil)
	TalkingHeadFrame.BackgroundFrame.TextBackground.SetAtlas = function() end
	
	TalkingHeadFrame.PortraitFrame.Portrait:SetAtlas(nil)
	TalkingHeadFrame.PortraitFrame.Portrait.SetAtlas = function() end
	
	TalkingHeadFrame.MainFrame.Model.PortraitBg:SetAtlas(nil)
	TalkingHeadFrame.MainFrame.Model.PortraitBg.SetAtlas = function() end
	
	TalkingHeadFrame.MainFrame.CloseButton:Hide()
	
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	TalkingHeadFrame.BG = CreateFrame("Frame", nil, TalkingHeadFrame, "BackdropTemplate")
	TalkingHeadFrame.BG:SetPoint("TOPLEFT", 16, -16)
	TalkingHeadFrame.BG:SetPoint("BOTTOMRIGHT", -16, 16)
	TalkingHeadFrame.BG:SetBackdrop(HydraUI.BackdropAndBorder)
	TalkingHeadFrame.BG:SetBackdropBorderColor(0, 0, 0)
	TalkingHeadFrame.BG:SetBackdropColor(R, G, B, 0.7)
	TalkingHeadFrame.BG:SetFrameStrata("BACKGROUND")
	
	TalkingHeadFrame.ModelBG = TalkingHeadFrame.MainFrame.Model:CreateTexture(nil, "BACKDROP")
	TalkingHeadFrame.ModelBG:SetPoint("TOPLEFT", TalkingHeadFrame.MainFrame.Model, 0, 0)
	TalkingHeadFrame.ModelBG:SetPoint("BOTTOMRIGHT", TalkingHeadFrame.MainFrame.Model, 0, 0)
	TalkingHeadFrame.ModelBG:SetTexture(Assets:GetTexture("Ferous"))
	TalkingHeadFrame.ModelBG:SetVertexColor(HydraUI:HexToRGB(Settings["ui-main-color"]))
	
	TalkingHeadFrame.Outline = CreateFrame("Frame", nil, TalkingHeadFrame.MainFrame.Model, "BackdropTemplate")
	TalkingHeadFrame.Outline:SetPoint("TOPLEFT", 0, 0)
	TalkingHeadFrame.Outline:SetPoint("BOTTOMRIGHT", 0, 0)
	TalkingHeadFrame.Outline:SetBackdrop(HydraUI.Outline)
	TalkingHeadFrame.Outline:SetBackdropBorderColor(0, 0, 0)
	
	for i = 1, TalkingHeadFrame.PortraitFrame:GetNumRegions() do
		local Region = select(i, TalkingHeadFrame.PortraitFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:Hide()
			Region:SetTexture(nil)
		end
	end
	
	for i = 1, TalkingHeadFrame.MainFrame:GetNumRegions() do
		local Region = select(i, TalkingHeadFrame.MainFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:Hide()
			Region:SetTexture(nil)
		end
	end
	
	for i = 1, TalkingHeadFrame:GetNumRegions() do
		local Region = select(i, TalkingHeadFrame:GetRegions())
		
		if (Region:GetObjectType() == "Texture") then
			Region:Hide()
			Region:SetTexture(nil)
		end
	end
	
	-- Close button
	local CloseButton = CreateFrame("Frame", nil, TalkingHeadFrame, "BackdropTemplate")
	CloseButton:SetSize(20, 20)
	CloseButton:SetPoint("TOPRIGHT", TalkingHeadFrame, -24, -24)
	CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	CloseButton:SetBackdropColor(0, 0, 0, 0)
	CloseButton:SetBackdropBorderColor(0, 0, 0)
	CloseButton:SetScript("OnEnter", CloseOnEnter)
	CloseButton:SetScript("OnLeave", CloseOnLeave)
	CloseButton:SetScript("OnMouseUp", CloseOnMouseUp)
	CloseButton:SetScript("OnMouseDown", CloseOnMouseDown)
	
	CloseButton.Texture = CloseButton:CreateTexture(nil, "ARTWORK")
	CloseButton.Texture:SetPoint("TOPLEFT", CloseButton, 1, -1)
	CloseButton.Texture:SetPoint("BOTTOMRIGHT", CloseButton, -1, 1)
	CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	CloseButton.Cross = CloseButton:CreateTexture(nil, "OVERLAY")
	CloseButton.Cross:SetPoint("CENTER", CloseButton, 0, 0)
	CloseButton.Cross:SetSize(16, 16)
	CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	TalkingHeadFrame:SetMovable(true)
	TalkingHeadFrame:SetClampedToScreen(true)
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint("CENTER", self.Mover, 0, 0)
end

function TH:OnEvent(event, addon)
	if (addon == "Blizzard_TalkingHeadUI") then
		for i = 1, #AlertFrame.alertFrameSubSystems do
			if (AlertFrame.alertFrameSubSystems[i].anchorFrame == TalkingHeadFrame) then
				tremove(AlertFrame.alertFrameSubSystems, i)
			end
		end
		
		TalkingHeadFrame.ignoreFramePositionManager = true
		
		if Settings["hide-th"] then
			TalkingHeadFrame:SetParent(self.Hide)
		else
			self:ApplyStyle()
		end
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function TH:Load()
	self:RegisterEvent("ADDON_LOADED")
	self:SetScript("OnEvent", self.OnEvent)
	
	self.Mover = CreateFrame("Frame", "HydraUI Talking Head", HydraUIParent)
	self.Mover:SetSize(570, 155)
	self.Mover:SetPoint("TOP", HydraUIParent, 0, -100)
	
	HydraUI:CreateMover(self.Mover)
end

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	right:CreateHeader(Language["Talking Head"])
	right:CreateSwitch("hide-th", Settings["hide-th"], Language["Hide Talking Head Frame"], Language["Hide the talking head frame, and stop it from showing."], ReloadUI):RequiresReload(true)
end)