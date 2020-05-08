local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

local DT = vUI:NewModule("DataText")

DT.Anchors = {}
DT.Types = {}
DT.List = {}

local ShouldFlash = function(anchor)
	if (anchor.Text:GetText() ~= anchor.LastValue) then
		return true
	end
end

local PlayFlash = function(anchor)
	if anchor:ShouldFlash() and (not anchor.Fade:IsPlaying()) then
		anchor:SaveValue()
		anchor.Fade:Play()
	end
end

local SaveValue = function(anchor)
	anchor.LastValue = anchor.Text:GetText()
end

local SetTooltip = function(anchor)
	if Settings["data-text-hover-tooltips"] then
		local X, Y = anchor:GetCenter()
		local Position = (Y > vUI.UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
		
		GameTooltip:SetOwner(anchor, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		
		if (Position == "TOP") then
			GameTooltip:SetPoint("TOP", anchor, "BOTTOM", 0, -8)
		else
			GameTooltip:SetPoint("BOTTOM", anchor, "TOP", 0, 8)
		end
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, anchor)
	end
end

function DT:NewAnchor(name, parent)
	if self.Anchors[name] then
		return
	end
	
	if (not parent) then
		parent = vUI.UIParent
	end
	
	local Anchor = CreateFrame("Frame", nil, parent)
	Anchor:SetSize(120, 20)
	Anchor:SetFrameLevel(parent:GetFrameLevel() + 1)
	Anchor:SetFrameStrata(parent:GetFrameStrata())
	Anchor:SetBackdrop(vUI.Backdrop)
	Anchor:SetBackdropColor(0, 0, 0, 0)
	
	Anchor.Name = name
	Anchor.PlayFlash = PlayFlash
	Anchor.ShouldFlash = ShouldFlash
	Anchor.SaveValue = SaveValue
	Anchor.SetTooltip = SetTooltip
	
	Anchor.Highlight = Anchor:CreateTexture(nil, "ARTWORK")
	Anchor.Highlight:SetPoint("BOTTOMLEFT", Anchor, 20, 0)
	Anchor.Highlight:SetPoint("BOTTOMRIGHT", Anchor, -20, 0)
	Anchor.Highlight:SetHeight(14)
	Anchor.Highlight:SetTexture(Assets:GetTexture("RenHorizonUp"))
	Anchor.Highlight:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	Anchor.Highlight:SetAlpha(0)
	
	Anchor.Fade = CreateAnimationGroup(Anchor.Highlight)
	
	Anchor.FadeIn = Anchor.Fade:CreateAnimation("Fade")
	Anchor.FadeIn:SetEasing("inout")
	Anchor.FadeIn:SetDuration(0.15)
	Anchor.FadeIn:SetChange(0.5)
	
	Anchor.FadeOut = Anchor.Fade:CreateAnimation("Fade")
	Anchor.FadeOut:SetOrder(2)
	Anchor.FadeOut:SetEasing("inout")
	Anchor.FadeOut:SetDuration(0.6)
	Anchor.FadeOut:SetChange(0)
	
	Anchor.Text = Anchor:CreateFontString(nil, "ARTWORK")
	vUI:SetFontInfo(Anchor.Text, Settings["data-text-font"], Settings["data-text-font-size"], Settings["data-text-font-flags"])
	Anchor.Text:SetPoint("CENTER", Anchor, "CENTER", 0, 0)
	Anchor.Text:SetJustifyH("CENTER")
	
	self.Anchors[name] = Anchor
	
	return Anchor
end

function DT:GetAnchor(name)
	if self.Anchors[name] then
		return self.Anchors[name]
	end
end

function DT:SetDataText(anchor, name)
	if ((not self.Anchors[anchor]) or (not self.Types[name])) then
		return
	end
	
	local Anchor = self.Anchors[anchor]
	local Type = self.Types[name]
	
	if Anchor.Disable then
		Anchor:Disable()
	end
	
	Anchor.Enable = Type.Enable
	Anchor.Disable = Type.Disable
	Anchor.Update = Type.Update
	
	Anchor:Enable()
end

function DT:SetTooltipsEnabled(value)
	for Name, Anchor in pairs(self.Anchors) do
		if (Anchor:HasScript("OnEnter")) then
			Anchor:EnableMouse(value)
		end
	end
end

function DT:UpdateAllAnchors()
	for Name, Anchor in pairs(self.Anchors) do
		Anchor:Update(999, "player")
	end
end

function DT:Load()
	if Settings["chat-enable"] then
		local Width = vUIChatFrameBottom:GetWidth() / 3
		local Height = vUIChatFrameBottom:GetHeight()
		
		local ChatLeft = self:NewAnchor("Chat-Left", vUIChatFrameBottom)
		ChatLeft:SetSize(Width, Height)
		ChatLeft:SetPoint("LEFT", vUIChatFrameBottom, 0, 0)
		
		local ChatMiddle = self:NewAnchor("Chat-Middle", vUIChatFrameBottom)
		ChatMiddle:SetSize(Width, Height)
		ChatMiddle:SetPoint("LEFT", ChatLeft, "RIGHT", 0, 0)
		
		local ChatRight = self:NewAnchor("Chat-Right", vUIChatFrameBottom)
		ChatRight:SetSize(Width, Height)
		ChatRight:SetPoint("LEFT", ChatMiddle, "RIGHT", 0, 0)
		
		self:SetDataText("Chat-Left", Settings["data-text-chat-left"])
		self:SetDataText("Chat-Middle", Settings["data-text-chat-middle"])
		self:SetDataText("Chat-Right", Settings["data-text-chat-right"])
	end
	
	if Settings["minimap-enable"] then
		local MinimapTop = self:NewAnchor("Minimap-Top", vUIMinimapTop)
		MinimapTop:SetSize(vUIMinimapTop:GetSize())
		MinimapTop:SetPoint("CENTER", vUIMinimapTop, 0, 0)
		
		local MinimapBottom = self:NewAnchor("Minimap-Bottom", vUIMinimapBottom)
		MinimapBottom:SetSize(vUIMinimapBottom:GetSize())
		MinimapBottom:SetPoint("CENTER", vUIMinimapBottom, 0, 0)
		
		self:SetDataText("Minimap-Top", Settings["data-text-minimap-top"])
		self:SetDataText("Minimap-Bottom", Settings["data-text-minimap-bottom"])
	end
	
	self:SetTooltipsEnabled(Settings["data-text-enable-tooltips"])
	
	SetCVar("timeMgrUseMilitaryTime", Settings["data-text-24-hour"])
end

function vUI:AddDataText(name, enable, disable, update)
	if DT.Types[name] then
		return
	end
	
	DT.Types[name] = {Enable = enable, Disable = disable, Update = update}
	DT.List[name] = name
end

local UpdateLeftText = function(value)
	DT:SetDataText("Chat-Left", value)
end

local UpdateMiddleText = function(value)
	DT:SetDataText("Chat-Middle", value)
end

local UpdateRightText = function(value)
	DT:SetDataText("Chat-Right", value)
end

local UpdateMinimapTopText = function(value)
	if Settings["minimap-enable"] then
		DT:SetDataText("Minimap-Top", value)
	end
end

local UpdateMinimapBottomText = function(value)
	if Settings["minimap-enable"] then
		DT:SetDataText("Minimap-Bottom", value)
	end
end

local UpdateFont = function()
	for Name, Anchor in pairs(DT.Anchors) do
		vUI:SetFontInfo(Anchor.Text, Settings["data-text-font"], Settings["data-text-font-size"], Settings["data-text-font-flags"])
	end
end

local UpdateEnableTooltips = function(value)
	DT:SetTooltipsEnabled(value)
end

local ResetOnAccept = function()
	vUI:GetModule("Gold"):Reset()
end

local ResetGold = function()
	vUI:DisplayPopup(Language["Attention"], Language["Are you sure you would like to reset all stored gold information?"], Language["Accept"], ResetOnAccept, Language["Cancel"])
end

local UpdateTimeFormat = function(value)
	SetCVar("timeMgrUseMilitaryTime", value)
	DT:UpdateAllAnchors()
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Data Texts"])
	
	Left:CreateHeader(Language["Chat Frame Texts"])
	Left:CreateDropdown("data-text-chat-left", Settings["data-text-chat-left"], DT.List, Language["Set Left Text"], Language["Set the information to be displayed in the left data text anchor"], UpdateLeftText)
	Left:CreateDropdown("data-text-chat-middle", Settings["data-text-chat-middle"], DT.List, Language["Set Middle Text"], Language["Set the information to be displayed in the middle data text anchor"], UpdateMiddleText)
	Left:CreateDropdown("data-text-chat-right", Settings["data-text-chat-right"], DT.List, Language["Set Right Text"], Language["Set the information to be displayed in the right data text anchor"], UpdateRightText)
	
	Left:CreateHeader(Language["Mini Map Texts"])
	Left:CreateDropdown("data-text-minimap-top", Settings["data-text-minimap-top"], DT.List, Language["Set Top Text"], Language["Set the information to be displayed in the top mini map data text anchor"], UpdateMinimapTopText)
	Left:CreateDropdown("data-text-minimap-bottom", Settings["data-text-minimap-bottom"], DT.List, Language["Set Bottom Text"], Language["Set the information to be displayed in the bottom mini map data text anchor"], UpdateMinimapBottomText)
	
	Right:CreateHeader(Language["Font"])
	Right:CreateDropdown("data-text-font", Settings["data-text-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the data texts"], UpdateFont, "Font")
	Right:CreateSlider("data-text-font-size", Settings["data-text-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the data texts"], UpdateFont)
	Right:CreateDropdown("data-text-font-flags", Settings["data-text-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the data texts"], UpdateFont)
	
	Right:CreateHeader(Language["Colors"])
	Right:CreateColorSelection("data-text-label-color", Settings["data-text-label-color"], Language["Label Color"], Language["Set the text color of data text labels"], function() DT:UpdateAllAnchors() end)
	Right:CreateColorSelection("data-text-value-color", Settings["data-text-value-color"], Language["Value Color"], Language["Set the text color of data text values"], function() DT:UpdateAllAnchors() end)
	
	Right:CreateHeader(Language["Styling"])
	Right:CreateSwitch("data-text-enable-tooltips", Settings["data-text-enable-tooltips"], Language["Enable Tooltips"], Language["Display tooltip information when hovering over data texts"], UpdateEnableTooltips)
	Right:CreateSwitch("data-text-hover-tooltips", Settings["data-text-hover-tooltips"], Language["Hover Tooltips"], Language["Display tooltip information directly by the data text instead of at the default tooltip location"])
	Right:CreateSwitch("data-text-24-hour", Settings["data-text-24-hour"], Language["Enable 24 Hour Time"], Language["Display time in a 24 hour format"], UpdateTimeFormat)
	
	Right:CreateHeader(Language["Gold"])
	Right:CreateButton(Language["Reset"], Language["Reset Gold"], Language["Reset stored information for each characters gold"], ResetGold)
	
	--Left:CreateHeader(Language["Misc."])
	--Left:CreateSlider("data-text-max-lines", Settings["data-text-max-lines"], 5, 50, 1, "Max Lines", "Set the maximum number of players shown in the guild or friends data text tooltips")
end)