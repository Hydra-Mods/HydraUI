local vUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local Testing = {
	--["Zeraphine:Mal'Ganis"] = 1,
	["Neonsol:Mal'Ganis"] = 1,
	--["Venio:Mal'Ganis"] = 1,
	--["Nitrite:Mal'Ganis"] = 1,
	["Revival:Mal'Ganis"] = 1,
	["Zaeta:Mal'Ganis"] = 1,
	["Psyaviah:Mal'Ganis"] = 1,
	["Artemis:Mal'Ganis"] = 1,
	["Amnistia:Mal'Ganis"] = 1,
	["Psyaviah:Sargeras"] = 1,
}

if (not Testing[vUI.UserProfileKey]) then
	return
end

local FRAME_WIDTH = 390
local FRAME_HEIGHT = 128
local BAR_HEIGHT = 22

local DT = vUI:GetModule("DataText")

local CreateMetersPanels = function()
	local R, G, B = vUI:HexToRGB(Settings["ui-window-main-color"])
	
	local MeterBGBottom = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBGBottom:SetSize(FRAME_WIDTH, BAR_HEIGHT + 6)
	MeterBGBottom:SetPoint("BOTTOMRIGHT", vUI.UIParent, -13, 13)
	MeterBGBottom:SetBackdrop(vUI.Backdrop)
	MeterBGBottom:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	MeterBGBottom:SetBackdropBorderColor(0, 0, 0)
	MeterBGBottom:SetFrameStrata("LOW")
	
	local MeterBGBottomFrame = CreateFrame("Frame", "vUIMeterBGBottom", vUI.UIParent)
	MeterBGBottomFrame:SetSize(FRAME_WIDTH - 6, BAR_HEIGHT)
	MeterBGBottomFrame:SetPoint("BOTTOM", MeterBGBottom, "BOTTOM", 0, 3)
	MeterBGBottomFrame:SetBackdrop(vUI.BackdropAndBorder)
	MeterBGBottomFrame:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	MeterBGBottomFrame:SetBackdropBorderColor(0, 0, 0)
	MeterBGBottomFrame:SetFrameStrata("MEDIUM")
	
	MeterBGBottomFrame.Texture = MeterBGBottomFrame:CreateTexture(nil, "OVERLAY")
	MeterBGBottomFrame.Texture:SetPoint("TOPLEFT", MeterBGBottomFrame, 1, -1)
	MeterBGBottomFrame.Texture:SetPoint("BOTTOMRIGHT", MeterBGBottomFrame, -1, 1)
	MeterBGBottomFrame.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	MeterBGBottomFrame.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local MeterBGLeft = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBGLeft:SetSize(4, FRAME_HEIGHT)
	MeterBGLeft:SetPoint("BOTTOMLEFT", MeterBGBottom, 0, 0)
	MeterBGLeft:SetBackdrop(vUI.Backdrop)
	MeterBGLeft:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	MeterBGLeft:SetBackdropBorderColor(0, 0, 0)
	MeterBGLeft:SetFrameStrata("LOW")
	
	local MeterBGRight = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBGRight:SetSize(4, FRAME_HEIGHT)
	MeterBGRight:SetPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	MeterBGRight:SetBackdrop(vUI.Backdrop)
	MeterBGRight:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	MeterBGRight:SetBackdropBorderColor(0, 0, 0)
	MeterBGRight:SetFrameStrata("LOW")
	
	local MeterBGTop = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBGTop:SetSize(FRAME_WIDTH, BAR_HEIGHT + 4)
	MeterBGTop:SetPoint("BOTTOMLEFT", MeterBGLeft, "TOPLEFT", 0, 0)
	MeterBGTop:SetBackdrop(vUI.Backdrop)
	MeterBGTop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	MeterBGTop:SetBackdropBorderColor(0, 0, 0)
	MeterBGTop:SetFrameStrata("LOW")
	
	local MeterBG = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBG:SetPoint("BOTTOMLEFT", MeterBGLeft, 0, 0)
	MeterBG:SetPoint("TOPRIGHT", MeterBGTop, 0, 0)
	MeterBG:SetBackdrop(vUI.BackdropAndBorder)
	MeterBG:SetBackdropColor(R, G, B, (Settings["chat-bg-opacity"] / 100))
	MeterBG:SetBackdropBorderColor(0, 0, 0)
	MeterBG:SetFrameStrata("BACKGROUND")
	
	local TopLeft = CreateFrame("Frame", nil, vUI.UIParent)
	TopLeft:SetSize((FRAME_WIDTH / 2) - 4, BAR_HEIGHT)
	TopLeft:SetPoint("TOPLEFT", MeterBGTop, 3, -2)
	TopLeft:SetBackdrop(vUI.BackdropAndBorder)
	TopLeft:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	TopLeft:SetBackdropBorderColor(0, 0, 0)
	TopLeft:SetFrameStrata("LOW")
	
	TopLeft.Texture = TopLeft:CreateTexture(nil, "OVERLAY")
	TopLeft.Texture:SetPoint("TOPLEFT", TopLeft, 1, -1)
	TopLeft.Texture:SetPoint("BOTTOMRIGHT", TopLeft, -1, 1)
	TopLeft.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TopLeft.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	local TopRight = CreateFrame("Frame", nil, vUI.UIParent)
	TopRight:SetSize((FRAME_WIDTH / 2) - 4, BAR_HEIGHT)
	TopRight:SetPoint("TOPRIGHT", MeterBGTop, -3, -2)
	TopRight:SetBackdrop(vUI.BackdropAndBorder)
	TopRight:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	TopRight:SetBackdropBorderColor(0, 0, 0)
	TopRight:SetFrameStrata("LOW")
	
	TopRight.Texture = TopRight:CreateTexture(nil, "OVERLAY")
	TopRight.Texture:SetPoint("TOPLEFT", TopRight, 1, -1)
	TopRight.Texture:SetPoint("BOTTOMRIGHT", TopRight, -1, 1)
	TopRight.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	TopRight.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	local MeterBGMiddle = CreateFrame("Frame", nil, vUI.UIParent)
	MeterBGMiddle:SetPoint("TOP", MeterBGTop, "BOTTOM", 0, 0)
	MeterBGMiddle:SetPoint("BOTTOM", MeterBGBottom, "TOP", 0, 0)
	MeterBGMiddle:SetWidth(4)
	MeterBGMiddle:SetBackdrop(vUI.Backdrop)
	MeterBGMiddle:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	MeterBGMiddle:SetBackdropBorderColor(0, 0, 0)
	MeterBGMiddle:SetFrameStrata("LOW")
	
	local OuterOutline = CreateFrame("Frame", "vUIMetersFrame", MeterBGBottom)
	OuterOutline:SetPoint("TOPLEFT", MeterBGTop, 0, 1)
	OuterOutline:SetPoint("BOTTOMRIGHT", MeterBGBottom, 0, 0)
	OuterOutline:SetBackdrop(vUI.Outline)
	OuterOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerLeftOutline = CreateFrame("Frame", nil, MeterBGBottom)
	InnerLeftOutline:SetPoint("TOPLEFT", MeterBGLeft, "TOPRIGHT", -1, 0)
	InnerLeftOutline:SetPoint("BOTTOMRIGHT", MeterBGMiddle, "BOTTOMLEFT", 1, -1)
	InnerLeftOutline:SetBackdrop(vUI.Outline)
	InnerLeftOutline:SetBackdropBorderColor(0, 0, 0)
	
	local InnerRightOutline = CreateFrame("Frame", nil, MeterBGBottom)
	InnerRightOutline:SetPoint("TOPRIGHT", MeterBGRight, "TOPLEFT", 1, 0)
	InnerRightOutline:SetPoint("BOTTOMLEFT", MeterBGMiddle, "BOTTOMRIGHT", -1, -1)
	InnerRightOutline:SetBackdrop(vUI.Outline)
	InnerRightOutline:SetBackdropBorderColor(0, 0, 0)
	
	-- Weird spot for this to live, right now.
	local Width = MeterBGBottomFrame:GetWidth() / 3
	local Height = MeterBGBottomFrame:GetHeight()
	
	local BottomLeft = DT:NewAnchor("Window-Left", MeterBGBottomFrame)
	BottomLeft:SetSize(Width, Height)
	BottomLeft:SetPoint("LEFT", MeterBGBottomFrame, 0, 0)
	
	local BottomMiddle = DT:NewAnchor("Window-Middle", MeterBGBottomFrame)
	BottomMiddle:SetSize(Width, Height)
	BottomMiddle:SetPoint("LEFT", BottomLeft, "RIGHT", 0, 0)
	
	local BottomRight = DT:NewAnchor("Window-Right", MeterBGBottomFrame)
	BottomRight:SetSize(Width, Height)
	BottomRight:SetPoint("LEFT", BottomMiddle, "RIGHT", 0, 0)
	
	DT:SetDataText("Window-Left", Settings["data-text-extra-left"])
	DT:SetDataText("Window-Middle", Settings["data-text-extra-middle"])
	DT:SetDataText("Window-Right", Settings["data-text-extra-right"])
end

local Frame = CreateFrame("Frame")

Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(self, event)
	if (not Settings["meters-container-show"]) then
		
	end
	
	CreateMetersPanels()
	
	self:UnregisterEvent(event)
end)

local UpdateLeftText = function(value)
	DT:SetDataText("Window-Left", value)
end

local UpdateMiddleText = function(value)
	DT:SetDataText("Window-Middle", value)
end

local UpdateRightText = function(value)
	DT:SetDataText("Window-Right", value)
end

Defaults["data-text-extra-left"] = "Bag Slots"
Defaults["data-text-extra-middle"] = "Friends"
Defaults["data-text-extra-right"] = "Guild"

GUI:AddOptions(function(self)
	local Left, Right = self:GetWindow(Language["Data Texts"])
	
	Left:CreateHeader(Language["Right Window Texts"])
	Left:CreateDropdown("data-text-extra-left", Settings["data-text-extra-left"], DT.List, Language["Set Left Text"], Language["Set the information to be displayed in the left data text anchor"], UpdateLeftText)
	Left:CreateDropdown("data-text-extra-middle", Settings["data-text-extra-middle"], DT.List, Language["Set Middle Text"], Language["Set the information to be displayed in the middle data text anchor"], UpdateMiddleText)
	Left:CreateDropdown("data-text-extra-right", Settings["data-text-extra-right"], DT.List, Language["Set Right Text"], Language["Set the information to be displayed in the right data text anchor"], UpdateRightText)
end)