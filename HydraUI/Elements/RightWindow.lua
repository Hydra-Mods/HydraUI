local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Window = HydraUI:NewModule("Right Window")
local DT = HydraUI:GetModule("DataText")

function Window:CreateSingleWindow()
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	self.Bottom = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Bottom:SetSize(Settings["right-window-width"], 28)
	self.Bottom:SetPoint("BOTTOMRIGHT", HydraUI.UIParent, -13, 13)
	self.Bottom:SetBackdrop(HydraUI.Backdrop)
	self.Bottom:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Bottom:SetBackdropBorderColor(0, 0, 0)
	self.Bottom:SetFrameStrata("BACKGROUND")
	
	self.BottomFrame = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.BottomFrame:SetSize(Settings["right-window-width"] - 6, 22)
	self.BottomFrame:SetPoint("BOTTOM", self.Bottom, "BOTTOM", 0, 3)
	self.BottomFrame:SetBackdrop(HydraUI.BackdropAndBorder)
	self.BottomFrame:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BottomFrame:SetBackdropBorderColor(0, 0, 0)
	self.BottomFrame:SetFrameStrata("LOW")
	
	self.BottomFrame.Texture = self.BottomFrame:CreateTexture(nil, "OVERLAY")
	self.BottomFrame.Texture:SetPoint("TOPLEFT", self.BottomFrame, 1, -1)
	self.BottomFrame.Texture:SetPoint("BOTTOMRIGHT", self.BottomFrame, -1, 1)
	self.BottomFrame.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.BottomFrame.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.Left = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Left:SetSize(4, Settings["right-window-height"])
	self.Left:SetPoint("BOTTOMLEFT", self.Bottom, 0, 0)
	self.Left:SetBackdrop(HydraUI.Backdrop)
	self.Left:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Left:SetBackdropBorderColor(0, 0, 0)
	self.Left:SetFrameStrata("BACKGROUND")
	
	self.Right = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Right:SetSize(4, Settings["right-window-height"])
	self.Right:SetPoint("BOTTOMRIGHT", self.Bottom, 0, 0)
	self.Right:SetBackdrop(HydraUI.Backdrop)
	self.Right:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Right:SetBackdropBorderColor(0, 0, 0)
	self.Right:SetFrameStrata("BACKGROUND")
	
	self.Top = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Top:SetSize(Settings["right-window-width"], 26)
	self.Top:SetPoint("BOTTOMLEFT", self.Left, "TOPLEFT", 0, 0)
	self.Top:SetBackdrop(HydraUI.Backdrop)
	self.Top:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Top:SetBackdropBorderColor(0, 0, 0)
	self.Top:SetFrameStrata("BACKGROUND")
	
	self.Backdrop = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Backdrop:SetPoint("BOTTOMLEFT", self.Left, 0, 0)
	self.Backdrop:SetPoint("TOPRIGHT", self.Top, 0, 1)
	self.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Backdrop:SetBackdropColor(R, G, B, (Settings["right-window-opacity"] / 100))
	self.Backdrop:SetBackdropBorderColor(0, 0, 0)
	self.Backdrop:SetFrameStrata("BACKGROUND")
	
	self.TopBar = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.TopBar:SetSize(Settings["right-window-width"], 22)
	self.TopBar:SetPoint("TOPLEFT", self.Top, 3, -2)
	self.TopBar:SetPoint("TOPRIGHT", self.Top, -3, -2)
	self.TopBar:SetBackdrop(HydraUI.BackdropAndBorder)
	self.TopBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.TopBar:SetBackdropBorderColor(0, 0, 0)
	self.TopBar:SetFrameStrata("BACKGROUND")
	self.TopBar:SetFrameLevel(1)
	
	self.TopBar.Texture = self.TopBar:CreateTexture(nil, "OVERLAY")
	self.TopBar.Texture:SetPoint("TOPLEFT", self.TopBar, 1, -1)
	self.TopBar.Texture:SetPoint("BOTTOMRIGHT", self.TopBar, -1, 1)
	self.TopBar.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.TopBar.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.OuterOutline = CreateFrame("Frame", "HydraUIMetersFrame", self.Bottom, "BackdropTemplate")
	self.OuterOutline:SetPoint("TOPLEFT", self.Top, 0, 1)
	self.OuterOutline:SetPoint("BOTTOMRIGHT", self.Bottom, 0, 0)
	self.OuterOutline:SetBackdrop(HydraUI.Outline)
	self.OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	self.InnerOutline = CreateFrame("Frame", nil, self.Bottom, "BackdropTemplate")
	self.InnerOutline:SetPoint("TOPLEFT", self.Left, "TOPRIGHT", -1, 0)
	self.InnerOutline:SetPoint("BOTTOMRIGHT", self.BottomFrame, "TOPRIGHT", 0, 2)
	self.InnerOutline:SetBackdrop(HydraUI.Outline)
	self.InnerOutline:SetBackdropBorderColor(0, 0, 0)
end

function Window:CreateDoubleWindow()
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	self.Bottom = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Bottom:SetSize(Settings["right-window-width"], 28)
	self.Bottom:SetPoint("BOTTOMRIGHT", HydraUI.UIParent, -13, 13)
	self.Bottom:SetBackdrop(HydraUI.Backdrop)
	self.Bottom:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Bottom:SetBackdropBorderColor(0, 0, 0)
	self.Bottom:SetFrameStrata("BACKGROUND")
	self.Bottom:SetFrameLevel(2)
	
	self.BottomFrame = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.BottomFrame:SetSize(Settings["right-window-width"] - 6, 22)
	self.BottomFrame:SetPoint("BOTTOM", self.Bottom, "BOTTOM", 0, 3)
	self.BottomFrame:SetBackdrop(HydraUI.BackdropAndBorder)
	self.BottomFrame:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.BottomFrame:SetBackdropBorderColor(0, 0, 0)
	self.BottomFrame:SetFrameStrata("LOW")
	
	self.BottomFrame.Texture = self.BottomFrame:CreateTexture(nil, "OVERLAY")
	self.BottomFrame.Texture:SetPoint("TOPLEFT", self.BottomFrame, 1, -1)
	self.BottomFrame.Texture:SetPoint("BOTTOMRIGHT", self.BottomFrame, -1, 1)
	self.BottomFrame.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.BottomFrame.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.Left = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Left:SetSize(4, Settings["right-window-height"])
	self.Left:SetPoint("BOTTOMLEFT", self.Bottom, 0, 0)
	self.Left:SetBackdrop(HydraUI.Backdrop)
	self.Left:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Left:SetBackdropBorderColor(0, 0, 0)
	self.Left:SetFrameStrata("BACKGROUND")
	self.Left:SetFrameLevel(2)
	
	self.Right = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Right:SetSize(4, Settings["right-window-height"])
	self.Right:SetPoint("BOTTOMRIGHT", self.Bottom, 0, 0)
	self.Right:SetBackdrop(HydraUI.Backdrop)
	self.Right:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Right:SetBackdropBorderColor(0, 0, 0)
	self.Right:SetFrameStrata("BACKGROUND")
	self.Right:SetFrameLevel(2)
	
	self.Top = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Top:SetSize(Settings["right-window-width"], 26)
	self.Top:SetPoint("BOTTOMLEFT", self.Left, "TOPLEFT", 0, 0)
	self.Top:SetBackdrop(HydraUI.Backdrop)
	self.Top:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.Top:SetBackdropBorderColor(0, 0, 0)
	self.Top:SetFrameStrata("BACKGROUND")
	self.Top:SetFrameLevel(2)
	
	self.Backdrop = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.Backdrop:SetPoint("BOTTOMLEFT", self.Left, 0, 0)
	self.Backdrop:SetPoint("TOPRIGHT", self.Top, 0, 1)
	self.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Backdrop:SetBackdropColor(R, G, B, (Settings["right-window-opacity"] / 100))
	self.Backdrop:SetBackdropBorderColor(0, 0, 0)
	self.Backdrop:SetFrameStrata("BACKGROUND")
	self.Backdrop:SetFrameLevel(1)
	
	self.TopLeft = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.TopLeft:SetSize((Settings["right-window-width"] / 2) - 4, 22)
	self.TopLeft:SetPoint("TOPLEFT", self.Top, 3, -2)
	self.TopLeft:SetBackdrop(HydraUI.BackdropAndBorder)
	self.TopLeft:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.TopLeft:SetBackdropBorderColor(0, 0, 0)
	self.TopLeft:SetFrameStrata("BACKGROUND")
	self.TopLeft:SetFrameLevel(2)
	
	self.TopLeft.Texture = self.TopLeft:CreateTexture(nil, "OVERLAY")
	self.TopLeft.Texture:SetPoint("TOPLEFT", self.TopLeft, 1, -1)
	self.TopLeft.Texture:SetPoint("BOTTOMRIGHT", self.TopLeft, -1, 1)
	self.TopLeft.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.TopLeft.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.TopRight = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.TopRight:SetSize((Settings["right-window-width"] / 2) - 4, 22)
	self.TopRight:SetPoint("TOPRIGHT", self.Top, -3, -2)
	self.TopRight:SetBackdrop(HydraUI.BackdropAndBorder)
	self.TopRight:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.TopRight:SetBackdropBorderColor(0, 0, 0)
	self.TopRight:SetFrameStrata("BACKGROUND")
	self.TopRight:SetFrameLevel(2)
	
	self.TopRight.Texture = self.TopRight:CreateTexture(nil, "OVERLAY")
	self.TopRight.Texture:SetPoint("TOPLEFT", self.TopRight, 1, -1)
	self.TopRight.Texture:SetPoint("BOTTOMRIGHT", self.TopRight, -1, 1)
	self.TopRight.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.TopRight.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	self.BackdropMiddle = CreateFrame("Frame", nil, HydraUI.UIParent, "BackdropTemplate")
	self.BackdropMiddle:SetPoint("TOP", self.Top, "BOTTOM", 0, 0)
	self.BackdropMiddle:SetPoint("BOTTOM", self.Bottom, "TOP", 0, 0)
	self.BackdropMiddle:SetWidth(4)
	self.BackdropMiddle:SetBackdrop(HydraUI.Backdrop)
	self.BackdropMiddle:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.BackdropMiddle:SetBackdropBorderColor(0, 0, 0)
	self.BackdropMiddle:SetFrameStrata("BACKGROUND")
	self.BackdropMiddle:SetFrameLevel(2)
	
	self.OuterOutline = CreateFrame("Frame", "HydraUIMetersFrame", self.Bottom, "BackdropTemplate")
	self.OuterOutline:SetPoint("TOPLEFT", self.Top, 0, 1)
	self.OuterOutline:SetPoint("BOTTOMRIGHT", self.Bottom, 0, 0)
	self.OuterOutline:SetBackdrop(HydraUI.Outline)
	self.OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	self.InnerLeftOutline = CreateFrame("Frame", nil, self.Bottom, "BackdropTemplate")
	self.InnerLeftOutline:SetPoint("TOPLEFT", self.Left, "TOPRIGHT", -1, 0)
	self.InnerLeftOutline:SetPoint("BOTTOMRIGHT", self.BackdropMiddle, "BOTTOMLEFT", 1, -1)
	self.InnerLeftOutline:SetBackdrop(HydraUI.Outline)
	self.InnerLeftOutline:SetBackdropBorderColor(0, 0, 0)
	
	self.InnerRightOutline = CreateFrame("Frame", nil, self.Bottom, "BackdropTemplate")
	self.InnerRightOutline:SetPoint("TOPRIGHT", self.Right, "TOPLEFT", 1, 0)
	self.InnerRightOutline:SetPoint("BOTTOMLEFT", self.BackdropMiddle, "BOTTOMRIGHT", -1, -1)
	self.InnerRightOutline:SetBackdrop(HydraUI.Outline)
	self.InnerRightOutline:SetBackdropBorderColor(0, 0, 0)
end

function Window:AddDataTexts()
	local Width = self.BottomFrame:GetWidth() / 3
	local Height = self.BottomFrame:GetHeight()
	
	local Left = DT:NewAnchor("Window-Left", self.BottomFrame)
	Left:SetSize(Width, Height)
	Left:SetPoint("LEFT", self.BottomFrame, 0, 0)
	
	local Middle = DT:NewAnchor("Window-Middle", self.BottomFrame)
	Middle:SetSize(Width, Height)
	Middle:SetPoint("LEFT", Left, "RIGHT", 0, 0)
	
	local Right = DT:NewAnchor("Window-Right", self.BottomFrame)
	Right:SetSize(Width, Height)
	Right:SetPoint("LEFT", Middle, "RIGHT", 0, 0)
	
	DT:SetDataText("Window-Left", Settings["data-text-extra-left"])
	DT:SetDataText("Window-Middle", Settings["data-text-extra-middle"])
	DT:SetDataText("Window-Right", Settings["data-text-extra-right"])
end

function Window:UpdateDataTexts()
	local Width = self.BottomFrame:GetWidth() / 3
	
	local Left = DT:GetAnchor("Window-Left")
	Left:SetWidth(Width)
	Left:ClearAllPoints()
	Left:SetPoint("LEFT", self.BottomFrame, 0, 0)
	
	local Middle = DT:GetAnchor("Window-Middle")
	Middle:SetWidth(Width)
	Middle:ClearAllPoints()
	Middle:SetPoint("LEFT", Left, "RIGHT", 0, 0)
	
	local Right = DT:GetAnchor("Window-Right")
	Right:SetWidth(Width)
	Right:ClearAllPoints()
	Right:SetPoint("LEFT", Middle, "RIGHT", 0, 0)
end

function Window:Load()
	if (not Settings["right-window-enable"]) then
		return
	end
	
	if (Settings["right-window-size"] == "SINGLE") then
		self:CreateSingleWindow()
	else
		self:CreateDoubleWindow()
	end
	
	self:AddDataTexts()
end

local UpdateLeftText = function(value)
	DT:SetDataText("Window-Left", value)
end

local UpdateMiddleText = function(value)
	DT:SetDataText("Window-Middle", value)
end

local UpdateRightText = function(value)
	DT:SetDataText("Window-Right", value)
end

local UpdateOpacity = function(value)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-window-main-color"])
	
	Window.Backdrop:SetBackdropColor(R, G, B, (Settings["right-window-opacity"] / 100))
end

local UpdateWidth = function(value)
	if (Settings["right-window-size"] == "SINGLE") then
		Window.Bottom:SetWidth(value)
		Window.BottomFrame:SetWidth(value - 6)
		Window.Top:SetWidth(value)
		Window.TopBar:SetWidth(value)
	else
		Window.Bottom:SetWidth(value)
		Window.BottomFrame:SetWidth(value - 6)
		Window.Top:SetWidth(value)
		Window.TopLeft:SetWidth((value / 2) - 4)
		Window.TopRight:SetWidth((value / 2) - 4)
	end
	
	Window:UpdateDataTexts()
end

local UpdateHeight = function(value)
	Window.Left:SetHeight(value)
	Window.Right:SetHeight(value)
end

GUI:AddWidgets(Language["General"], Language["Data Texts"], function(left, right)
	left:CreateHeader(Language["Right Window Texts"])
	left:CreateDropdown("data-text-extra-left", Settings["data-text-extra-left"], DT.List, Language["Set Left Text"], Language["Set the information to be displayed in the left data text anchor"], UpdateLeftText)
	left:CreateDropdown("data-text-extra-middle", Settings["data-text-extra-middle"], DT.List, Language["Set Middle Text"], Language["Set the information to be displayed in the middle data text anchor"], UpdateMiddleText)
	left:CreateDropdown("data-text-extra-right", Settings["data-text-extra-right"], DT.List, Language["Set Right Text"], Language["Set the information to be displayed in the right data text anchor"], UpdateRightText)
end)

GUI:AddWidgets(Language["General"], Language["General"], function(left, right)
	left:CreateHeader(Language["Right Window"])
	left:CreateSwitch("right-window-enable", Settings["right-window-enable"], Language["Enable Right Window"], Language["Enable the right side window, for placing chat or addons into"], ReloadUI):RequiresReload(true)
	left:CreateDropdown("right-window-size", Settings["right-window-size"], {[Language["Single"]] = "SINGLE", [Language["Double"]] = "DOUBLE"}, Language["Set Window Size"], Language["Set the number of windows to be displayed"], ReloadUI):RequiresReload(true)
	left:CreateSlider("right-window-width", Settings["right-window-width"], 300, 650, 1, Language["Window Width"], Language["Set the width of the window"], UpdateWidth)
	left:CreateSlider("right-window-height", Settings["right-window-height"], 40, 350, 1, Language["Window Height"], Language["Set the height of the window"], UpdateHeight)
	left:CreateSlider("right-window-opacity", Settings["right-window-opacity"], 0, 100, 5, Language["Background Opacity"], Language["Set the opacity of the window background"], UpdateOpacity, nil, "%")
end)