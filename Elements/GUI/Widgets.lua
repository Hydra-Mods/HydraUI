local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- Locals
local type = type
local pairs = pairs
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local match = string.match
local upper = string.upper
local lower = string.lower
local sub = string.sub
local gsub = string.gsub
local find = string.find
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local IsModifierKeyDown = IsModifierKeyDown
local GetMouseFocus = GetMouseFocus

-- Constants
local SPACING = 3
local HEADER_HEIGHT = 20
local HEADER_SPACING = 5
local GROUP_HEIGHT = 80
local GROUP_WIDTH = 270
local WIDGET_HEIGHT = 20
local LABEL_SPACING = 3
local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local LAST_ACTIVE_DROPDOWN

GUI.Ignore = {
	["ui-profile"] = true,
	["profile-copy"] = true,
}

-- Functions
local SetVariable = function(id, value)
	if GUI.Ignore[id] then
		return
	end
	
	local Name = HydraUI:GetActiveProfileName()
	
	if Name then
		HydraUI:SetProfileValue(Name, id, value)
	end
	
	Settings[id] = value
end

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)
	
	return floor(num * Mult + 0.5) / Mult
end

local TrimHex = function(s)
	local Subbed = match(s, "|c%x%x%x%x%x%x%x%x(.-)|r")
	
	return Subbed or s
end

local AnchorOnEnter = function(self)
	if (self.Tooltip and match(self.Tooltip, "%S")) then
		local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-font-color"])
		
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		
		GameTooltip:AddLine(self.Tooltip, R, G, B, true)
		GameTooltip:Show()
	end
end

local AnchorOnLeave = function(self)
	GameTooltip:Hide()
end

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

-- Widgets

-- Line
GUI.Widgets.CreateLine = function(self, id, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Text:SetSize(GROUP_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Text:SetJustifyH("LEFT")
	Anchor.Text:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], tostring(text)))
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Anchor.Text
end

-- Double Line
GUI.Widgets.CreateDoubleLine = function(self, id, left, right)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	
	Anchor.Left = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Left:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Left:SetSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Left, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Left:SetJustifyH("LEFT")
	Anchor.Left:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], tostring(left)))
	
	Anchor.Right = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Right:SetPoint("RIGHT", Anchor, -HEADER_SPACING, 0)
	Anchor.Right:SetSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Right, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Right:SetJustifyH("RIGHT")
	Anchor.Right:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], tostring(right)))
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Anchor.Left
end

-- Message
local CheckString = HydraUI.UIParent:CreateFontString(nil, "OVERLAY")
CheckString:SetWidth(GROUP_WIDTH - 6)
CheckString:SetJustifyH("LEFT")

GUI.Widgets.CreateMessage = function(self, id, text) -- Create as many lines as needed for the message
	HydraUI:SetFontInfo(CheckString, Settings["ui-widget-font"], Settings["ui-font-size"])
	CheckString:SetText(text)
	
	local Line = ""
	local NewLine = ""
	local Indent = 0
	local LineID = 1
	
	for word in string.gmatch(text, "(%S+)") do
		NewLine = Line .. (Indent == 0 and "" or " ") .. word
		
		CheckString:SetText(NewLine)
		
		if (CheckString:GetStringWidth() >= (GROUP_WIDTH - 6)) then
			if find(Line, "(%S+)$") then -- A word needs to be wrapped
				self:CreateLine(format("%s-%s", id, LineID), Line)
				Line = word -- Start a new line with the wrapped word
				Indent = 1
				LineID = LineID + 1
			else
				self:CreateLine(format("%s-%s", id, LineID), NewLine)
				Line = "" -- Start a new line
				Indent = 0
				LineID = LineID + 1
			end
		else
			Line = NewLine
			Indent = 1
			LineID = LineID + 1
		end
	end
	
	self:CreateLine(format("%s-%s", id, LineID), Line)
end

local AnimatedLineOnShow = function(self)
	if (not self.Fade:IsPlaying()) then
		self.Fade:Play()
	end
end

local AnimatedLineOnHide = function(self)
	if self.Fade:IsPlaying() then
		self.Fade:Stop()
	end
end

GUI.Widgets.CreateAnimatedLine = function(self, id, left, right, r, g, b)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	
	Anchor.Left = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Left:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Left:SetSize(GROUP_WIDTH - 8, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Left, Settings["ui-widget-font"], 14)
	Anchor.Left:SetJustifyH("LEFT")
	Anchor.Left:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], left))
	
	Anchor.Parent = CreateFrame("Frame", nil, Anchor)
	Anchor.Parent:SetSize(Anchor.Left:GetStringWidth() + 8, WIDGET_HEIGHT + 4)
	Anchor.Parent:SetPoint("LEFT", Anchor.Left, 0, 0)
	Anchor.Parent:SetAlpha(0.2)
	Anchor.Parent:SetScript("OnShow", AnimatedLineOnShow)
	Anchor.Parent:SetScript("OnHide", AnimatedLineOnHide)
	Anchor.Parent:SetFrameLevel(Anchor:GetFrameLevel() - 1)
	
	Anchor.Top = Anchor.Parent:CreateTexture(nil, "ARTWORK")
	Anchor.Top:SetSize(Anchor.Parent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
	Anchor.Top:SetPoint("TOP", Anchor.Parent, -3, 0)
	Anchor.Top:SetTexture(Assets:GetHighlight("RenHorizonUp"))
	Anchor.Top:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
	
	Anchor.Bottom = Anchor.Parent:CreateTexture(nil, "ARTWORK")
	Anchor.Bottom:SetSize(Anchor.Parent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
	Anchor.Bottom:SetPoint("BOTTOM", Anchor.Parent, -3, 0)
	Anchor.Bottom:SetTexture(Assets:GetHighlight("RenHorizonDown"))
	Anchor.Bottom:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
	
	Anchor.Parent.Fade = CreateAnimationGroup(Anchor.Parent)
	Anchor.Parent.Fade:SetLooping(true)
	
	Anchor.Parent.In = Anchor.Parent.Fade:CreateAnimation("Fade")
	Anchor.Parent.In:SetEasing("in")
	Anchor.Parent.In:SetDuration(1)
	Anchor.Parent.In:SetChange(0.5)
	
	Anchor.Parent.Out = Anchor.Parent.Fade:CreateAnimation("Fade")
	Anchor.Parent.Out:SetEasing("out")
	Anchor.Parent.Out:SetDuration(1)
	Anchor.Parent.Out:SetChange(0.2)
	Anchor.Parent.Out:SetOrder(2)
	
	Anchor.Parent.SIn = Anchor.Parent.Fade:CreateAnimation("Scale")
	Anchor.Parent.SIn:SetEasing("in")
	Anchor.Parent.SIn:SetDuration(0.5)
	Anchor.Parent.SIn:SetChange(0.8)
	
	Anchor.Parent.SOut = Anchor.Parent.Fade:CreateAnimation("Scale")
	Anchor.Parent.SOut:SetEasing("out")
	Anchor.Parent.SOut:SetDuration(0.5)
	Anchor.Parent.SOut:SetChange(1)
	Anchor.Parent.SOut:SetOrder(2)
	
	Anchor.Right = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Right:SetPoint("RIGHT", Anchor, -HEADER_SPACING, 0)
	Anchor.Right:SetSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Right, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Right:SetJustifyH("RIGHT")
	Anchor.Right:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], right))
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Anchor.Text
end

GUI.Widgets.CreateAnimatedDoubleLine = function(self, id, left, right, r, g, b)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	
	Anchor.Left = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Left:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Left:SetSize(GROUP_WIDTH - 8, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Left, Settings["ui-widget-font"], 14)
	Anchor.Left:SetJustifyH("LEFT")
	Anchor.Left:SetText(left)
	
	Anchor.LeftParent = CreateFrame("Frame", nil, Anchor)
	Anchor.LeftParent:SetSize(Anchor.Left:GetStringWidth() + 8, WIDGET_HEIGHT + 4)
	Anchor.LeftParent:SetPoint("LEFT", Anchor.Left, 0, -1)
	Anchor.LeftParent:SetAlpha(0.2)
	Anchor.LeftParent:SetScript("OnShow", AnimatedLineOnShow)
	Anchor.LeftParent:SetScript("OnHide", AnimatedLineOnHide)
	Anchor.LeftParent:SetFrameLevel(Anchor:GetFrameLevel() - 1)
	
	Anchor.TopLeft = Anchor.LeftParent:CreateTexture(nil, "ARTWORK")
	Anchor.TopLeft:SetSize(Anchor.LeftParent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
	Anchor.TopLeft:SetPoint("TOP", Anchor.LeftParent, -3, 0)
	Anchor.TopLeft:SetTexture(Assets:GetHighlight("RenHorizonUp"))
	Anchor.TopLeft:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
	
	Anchor.BottomLeft = Anchor.LeftParent:CreateTexture(nil, "ARTWORK")
	Anchor.BottomLeft:SetSize(Anchor.LeftParent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
	Anchor.BottomLeft:SetPoint("BOTTOM", Anchor.LeftParent, -3, 0)
	Anchor.BottomLeft:SetTexture(Assets:GetHighlight("RenHorizonDown"))
	Anchor.BottomLeft:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
	
	Anchor.LeftParent.Fade = CreateAnimationGroup(Anchor.LeftParent)
	Anchor.LeftParent.Fade:SetLooping(true)
	
	Anchor.LeftParent.In = Anchor.LeftParent.Fade:CreateAnimation("Fade")
	Anchor.LeftParent.In:SetEasing("in")
	Anchor.LeftParent.In:SetDuration(1)
	Anchor.LeftParent.In:SetChange(0.5)
	
	Anchor.LeftParent.Out = Anchor.LeftParent.Fade:CreateAnimation("Fade")
	Anchor.LeftParent.Out:SetEasing("out")
	Anchor.LeftParent.Out:SetDuration(1)
	Anchor.LeftParent.Out:SetChange(0.2)
	Anchor.LeftParent.Out:SetOrder(2)
	
	Anchor.LeftParent.SIn = Anchor.LeftParent.Fade:CreateAnimation("Scale")
	Anchor.LeftParent.SIn:SetEasing("in")
	Anchor.LeftParent.SIn:SetDuration(0.5)
	Anchor.LeftParent.SIn:SetChange(0.8)
	
	Anchor.LeftParent.SOut = Anchor.LeftParent.Fade:CreateAnimation("Scale")
	Anchor.LeftParent.SOut:SetEasing("out")
	Anchor.LeftParent.SOut:SetDuration(0.5)
	Anchor.LeftParent.SOut:SetChange(1)
	Anchor.LeftParent.SOut:SetOrder(2)
	
	if right then
		Anchor.Right = Anchor:CreateFontString(nil, "OVERLAY")
		Anchor.Right:SetPoint("RIGHT", Anchor, -HEADER_SPACING, 0)
		Anchor.Right:SetSize(GROUP_WIDTH - 8, WIDGET_HEIGHT)
		HydraUI:SetFontInfo(Anchor.Right, Settings["ui-widget-font"], 14)
		Anchor.Right:SetJustifyH("RIGHT")
		Anchor.Right:SetText(right)
		
		Anchor.RightParent = CreateFrame("Frame", nil, Anchor)
		Anchor.RightParent:SetSize(Anchor.Right:GetStringWidth() + 8, WIDGET_HEIGHT + 4)
		Anchor.RightParent:SetPoint("RIGHT", Anchor.Right, 0, -1)
		Anchor.RightParent:SetAlpha(0.2)
		Anchor.RightParent:SetScript("OnShow", AnimatedLineOnShow)
		Anchor.RightParent:SetScript("OnHide", AnimatedLineOnHide)
		Anchor.RightParent:SetFrameLevel(Anchor:GetFrameLevel() - 1)
		
		Anchor.TopRight = Anchor.RightParent:CreateTexture(nil, "ARTWORK")
		Anchor.TopRight:SetSize(Anchor.RightParent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
		Anchor.TopRight:SetPoint("TOP", Anchor.RightParent, 3, 0)
		Anchor.TopRight:SetTexture(Assets:GetHighlight("RenHorizonUp"))
		Anchor.TopRight:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
		
		Anchor.BottomRight = Anchor.RightParent:CreateTexture(nil, "ARTWORK")
		Anchor.BottomRight:SetSize(Anchor.RightParent:GetWidth(), WIDGET_HEIGHT / 2 + 2)
		Anchor.BottomRight:SetPoint("BOTTOM", Anchor.RightParent, 3, 0)
		Anchor.BottomRight:SetTexture(Assets:GetHighlight("RenHorizonDown"))
		Anchor.BottomRight:SetVertexColor(r * 1.7, g * 1.7, b * 1.7)
		
		Anchor.RightParent.Fade = CreateAnimationGroup(Anchor.RightParent)
		Anchor.RightParent.Fade:SetLooping(true)
		
		Anchor.RightParent.In = Anchor.RightParent.Fade:CreateAnimation("Fade")
		Anchor.RightParent.In:SetEasing("in")
		Anchor.RightParent.In:SetDuration(1)
		Anchor.RightParent.In:SetChange(0.5)
		
		Anchor.RightParent.Out = Anchor.RightParent.Fade:CreateAnimation("Fade")
		Anchor.RightParent.Out:SetEasing("out")
		Anchor.RightParent.Out:SetDuration(1)
		Anchor.RightParent.Out:SetChange(0.2)
		Anchor.RightParent.Out:SetOrder(2)
		
		Anchor.RightParent.SIn = Anchor.RightParent.Fade:CreateAnimation("Scale")
		Anchor.RightParent.SIn:SetEasing("in")
		Anchor.RightParent.SIn:SetDuration(0.5)
		Anchor.RightParent.SIn:SetChange(0.8)
		
		Anchor.RightParent.SOut = Anchor.RightParent.Fade:CreateAnimation("Scale")
		Anchor.RightParent.SOut:SetEasing("out")
		Anchor.RightParent.SOut:SetDuration(0.5)
		Anchor.RightParent.SOut:SetChange(1)
		Anchor.RightParent.SOut:SetOrder(2)
	end
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Anchor.Left, Anchor.Right
end

GUI.Widgets.CreateHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("CENTER", Anchor, 0, 0)
	Anchor.Text:SetHeight(WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Text, Settings["ui-header-font"], 12)
	Anchor.Text:SetJustifyH("CENTER")
	Anchor.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	Anchor.Texture = Anchor:CreateTexture(nil, "OVERLAY")
	Anchor.Texture:SetPoint("TOPLEFT", Anchor, 1, -1)
	Anchor.Texture:SetPoint("BOTTOMRIGHT", Anchor, -1, 1)
	Anchor.Texture:SetTexture(Assets:GetTexture("Blank"))
	Anchor.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))

	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Footer
GUI.Widgets.CreateFooter = function(self)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Texture = Anchor:CreateTexture(nil, "BACKGROUND")
	Anchor.Texture:SetPoint("TOPLEFT", Anchor, 1, -1)
	Anchor.Texture:SetPoint("BOTTOMRIGHT", Anchor, -1, 1)
	Anchor.Texture:SetTexture(Assets:GetTexture("Blank"))
	Anchor.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	tinsert(self.Widgets, Anchor)
end

-- Header
GUI.Widgets.CreateSupportHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("CENTER", Anchor, 0, 0)
	Anchor.Text:SetHeight(WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Anchor.Text, Settings["ui-header-font"], Settings["ui-font-size"]) -- 14
	Anchor.Text:SetJustifyH("CENTER")
	Anchor.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	-- Header Left Line
	local HeaderLeft = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderLeft:SetHeight(4)
	HeaderLeft:SetPoint("LEFT", Anchor, 0, 0)
	HeaderLeft:SetPoint("RIGHT", Anchor.Text, "LEFT", -20, 0)
	HeaderLeft:SetBackdrop(HydraUI.BackdropAndBorder)
	HeaderLeft:SetBackdropColor(0, 0, 0)
	HeaderLeft:SetBackdropBorderColor(0, 0, 0)
	
	HeaderLeft.Texture = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.Texture:SetPoint("TOPLEFT", HeaderLeft, 1, -1)
	HeaderLeft.Texture:SetPoint("BOTTOMRIGHT", HeaderLeft, -1, 1)
	HeaderLeft.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderLeft.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	HeaderLeft.Star = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.Star:SetPoint("LEFT", HeaderLeft.Texture, "RIGHT", 1, -1)
	HeaderLeft.Star:SetSize(16, 16)
	HeaderLeft.Star:SetTexture(Assets:GetTexture("Small Star"))
	HeaderLeft.Star:SetVertexColor(HydraUI:HexToRGB("FFB900"))
	
	-- Header Right Line
	local HeaderRight = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderRight:SetHeight(4)
	HeaderRight:SetPoint("RIGHT", Anchor, 0, 0)
	HeaderRight:SetPoint("LEFT", Anchor.Text, "RIGHT", 16, 0)
	HeaderRight:SetBackdrop(HydraUI.BackdropAndBorder)
	HeaderRight:SetBackdropColor(0, 0, 0)
	HeaderRight:SetBackdropBorderColor(0, 0, 0)
	
	HeaderRight.Texture = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.Texture:SetPoint("TOPLEFT", HeaderRight, 1, -1)
	HeaderRight.Texture:SetPoint("BOTTOMRIGHT", HeaderRight, -1, 1)
	HeaderRight.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderRight.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	HeaderRight.Star = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.Star:SetPoint("RIGHT", HeaderRight.Texture, "LEFT", -1, -1)
	HeaderRight.Star:SetSize(16, 16)
	HeaderRight.Star:SetTexture(Assets:GetTexture("Small Star"))
	HeaderRight.Star:SetVertexColor(HydraUI:HexToRGB("FFB900"))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Button
local BUTTON_WIDTH = 130

local ButtonOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.ReloadFlag then
		HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.Hook, CANCEL)
	elseif self.Hook then
		self.Hook()
	end
end

local ButtonOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local ButtonWidgetOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ButtonWidgetOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ButtonRequiresReload = function(self, flag)
	self.ReloadFlag = flag
end

local ButtonEnable = function(self)
	self.Button:EnableMouse(true)
	
	self.Button.MiddleText:SetTextColor(1, 1, 1)
end

local ButtonDisable = function(self)
	self.Button:EnableMouse(false)
	
	self.Button.MiddleText:SetTextColor(HydraUI:HexToRGB("A5A5A5"))
end

GUI.Widgets.CreateButton = function(self, id, value, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = ButtonEnable
	Anchor.Disable = ButtonDisable
	Anchor.RequiresReload = ButtonRequiresReload
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Button = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Button:SetSize(BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetPoint("RIGHT", Anchor, 0, 0)
	Button:SetBackdrop(HydraUI.BackdropAndBorder)
	Button:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnMouseUp", ButtonOnMouseUp)
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnEnter", ButtonWidgetOnEnter)
	Button:SetScript("OnLeave", ButtonWidgetOnLeave)
	Button.Hook = hook
	
	Button.Texture = Button:CreateTexture(nil, "BORDER")
	Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetPoint("CENTER", Button, "CENTER", 0, 0)
	Button.MiddleText:SetSize(BUTTON_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Button.MiddleText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText(value)
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetSize(GROUP_WIDTH - BUTTON_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Anchor.Button = Button
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Anchor
end

-- StatusBar
local STATUSBAR_WIDTH = 100

GUI.Widgets.CreateStatusBar = function(self, id, value, minvalue, maxvalue, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Backdrop = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Backdrop:SetSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Backdrop:SetPoint("RIGHT", Anchor, 0, 0)
	Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Backdrop:SetBackdropBorderColor(0, 0, 0)
	Backdrop.Value = value
	
	Backdrop.BG = Backdrop:CreateTexture(nil, "ARTWORK")
	Backdrop.BG:SetPoint("TOPLEFT", Backdrop, 1, -1)
	Backdrop.BG:SetPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Backdrop.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Backdrop.BG:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Bar = CreateFrame("StatusBar", nil, Backdrop, "BackdropTemplate")
	Bar:SetSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Bar:SetPoint("TOPLEFT", Backdrop, 1, -1)
	Bar:SetPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Bar:SetBackdrop(HydraUI.BackdropAndBorder)
	Bar:SetBackdropColor(0, 0, 0, 0)
	Bar:SetBackdropBorderColor(0, 0, 0, 0)
	Bar:SetStatusBarTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Bar:SetStatusBarColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	Bar:SetMinMaxValues(minvalue, maxvalue)
	Bar:SetValue(value)
	Bar.Hook = hook
	Bar.Tooltip = tooltip
	
	Bar.Anim = CreateAnimationGroup(Bar):CreateAnimation("progress")
	Bar.Anim:SetEasing("in")
	Bar.Anim:SetDuration(0.15)
	
	Bar.Spark = Bar:CreateTexture(nil, "ARTWORK")
	Bar.Spark:SetSize(1, WIDGET_HEIGHT - 2)
	Bar.Spark:SetPoint("LEFT", Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	Bar.Spark:SetTexture(Assets:GetTexture("Blank"))
	Bar.Spark:SetVertexColor(0, 0, 0)
	
	Bar.MiddleText = Bar:CreateFontString(nil, "ARTWORK")
	Bar.MiddleText:SetPoint("CENTER", Bar, "CENTER", 0, 0)
	Bar.MiddleText:SetSize(STATUSBAR_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Bar.MiddleText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Bar.MiddleText:SetJustifyH("CENTER")
	Bar.MiddleText:SetText(value)
	
	Bar.Text = Bar:CreateFontString(nil, "OVERLAY")
	Bar.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Bar.Text:SetSize(GROUP_WIDTH - STATUSBAR_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Bar.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Bar.Text:SetJustifyH("LEFT")
	Bar.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Bar
end

-- Checkbox
local CHECKBOX_WIDTH = 20

local CheckboxOnMouseUp = function(self)
	if self.Value then
		self.FadeOut:Play()
		self.Value = false
	else
		self.FadeIn:Play()
		self.Value = true
	end
	
	SetVariable(self.ID, self.Value)
	
	if (self.ReloadFlag) then
		HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.Hook, CANCEL, nil, self.Value, self.ID)
	elseif self.Hook then
		self.Hook(self.Value, self.ID)
	end
end

local CheckboxOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local CheckboxOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CheckboxRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI.Widgets.CreateCheckbox = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Checkbox = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Checkbox:SetSize(CHECKBOX_WIDTH, WIDGET_HEIGHT)
	Checkbox:SetPoint("RIGHT", Anchor, 0, 0)
	Checkbox:SetBackdrop(HydraUI.BackdropAndBorder)
	Checkbox:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Checkbox:SetBackdropBorderColor(0, 0, 0)
	Checkbox:SetScript("OnMouseUp", CheckboxOnMouseUp)
	Checkbox:SetScript("OnEnter", CheckboxOnEnter)
	Checkbox:SetScript("OnLeave", CheckboxOnLeave)
	Checkbox.Value = value
	Checkbox.Hook = hook
	Checkbox.Tooltip = tooltip
	Checkbox.ID = id
	Checkbox.RequiresReload = CheckboxRequiresReload
	
	Checkbox.BG = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.BG:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.BG:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.BG:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	Checkbox.Highlight = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Highlight:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Highlight:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Checkbox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Checkbox.Highlight:SetAlpha(0)
	
	Checkbox.Texture = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.Texture:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Texture:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	Checkbox.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Checkbox.Text:SetSize(GROUP_WIDTH - CHECKBOX_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Checkbox.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Checkbox.Hover = Checkbox:CreateTexture(nil, "HIGHLIGHT")
	Checkbox.Hover:SetPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Hover:SetPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Hover:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	Checkbox.Hover:SetTexture(Assets:GetTexture("RenHorizonUp"))
	Checkbox.Hover:SetAlpha(0)
	
	Checkbox.Fade = CreateAnimationGroup(Checkbox.Texture)
	
	Checkbox.FadeIn = Checkbox.Fade:CreateAnimation("Fade")
	Checkbox.FadeIn:SetEasing("in")
	Checkbox.FadeIn:SetDuration(0.15)
	Checkbox.FadeIn:SetChange(1)
	
	Checkbox.FadeOut = Checkbox.Fade:CreateAnimation("Fade")
	Checkbox.FadeOut:SetEasing("out")
	Checkbox.FadeOut:SetDuration(0.15)
	Checkbox.FadeOut:SetChange(0)
	
	if Checkbox.Value then
		Checkbox.Texture:SetAlpha(1)
	else
		Checkbox.Texture:SetAlpha(0)
	end
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Checkbox
end

-- Switch
local SWITCH_WIDTH = 50
local SWITCH_TRAVEL = SWITCH_WIDTH - WIDGET_HEIGHT

local SwitchOnMouseUp = function(self)
	if self.Move:IsPlaying() then
		return
	end
	
	self.Thumb:ClearAllPoints()
	
	if self.Value then
		self.Thumb:SetPoint("RIGHT", self, 0, 0)
		self.Move:SetOffset(-SWITCH_TRAVEL, 0)
		self.Value = false
	else
		self.Thumb:SetPoint("LEFT", self, 0, 0)
		self.Move:SetOffset(SWITCH_TRAVEL, 0)
		self.Value = true
	end
	
	self.Move:Play()
	
	SetVariable(self.ID, self.Value)
	
	if self.ReloadFlag then
		HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.Hook, CANCEL, nil, self.Value, self.ID)
	elseif self.Hook then
		self.Hook(self.Value, self.ID)
	end
end

local SwitchOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	local CurrentValue = self.Value
	local NewValue
	
	if (delta < 0) then
		NewValue = false
	else
		NewValue = true
	end
	
	if (CurrentValue ~= NewValue) then
		SwitchOnMouseUp(self) -- This is already set up to handle everything, so just pass it along
	end
end

local SwitchOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local SwitchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SwitchEnable = function(self)
	self.Switch:EnableMouse(true)
	self.Switch:EnableMouseWheel(true)
	
	self.Switch.Flavor:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
end

local SwitchDisable = function(self)
	self.Switch:EnableMouse(false)
	self.Switch:EnableMouseWheel(false)
	
	self.Switch.Flavor:SetVertexColor(HydraUI:HexToRGB("A5A5A5"))
end

local SwitchRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI.Widgets.CreateSwitch = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = SwitchEnable
	Anchor.Disable = SwitchDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Switch = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Switch:SetSize(SWITCH_WIDTH, WIDGET_HEIGHT)
	Switch:SetPoint("RIGHT", Anchor, 0, 0)
	Switch:SetBackdrop(HydraUI.BackdropAndBorder)
	Switch:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Switch:SetBackdropBorderColor(0, 0, 0)
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch:SetScript("OnEnter", SwitchOnEnter)
	Switch:SetScript("OnLeave", SwitchOnLeave)
	Switch.Value = value
	Switch.Hook = hook
	Switch.Tooltip = tooltip
	Switch.ID = id
	Switch.RequiresReload = SwitchRequiresReload
	Switch.OnMouseWheel = SwitchOnMouseWheel
	
	Switch.BG = Switch:CreateTexture(nil, "ARTWORK")
	Switch.BG:SetPoint("TOPLEFT", Switch, 1, -1)
	Switch.BG:SetPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.BG:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	Switch.Thumb = CreateFrame("Frame", nil, Switch, "BackdropTemplate")
	Switch.Thumb:SetSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Switch.Thumb:SetBackdrop(HydraUI.BackdropAndBorder)
	Switch.Thumb:SetBackdropBorderColor(0, 0, 0)
	Switch.Thumb:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	Switch.Thumb:SetPoint(Switch.Value and "RIGHT" or "LEFT", Switch, 0, 0)
	
	Switch.ThumbTexture = Switch.Thumb:CreateTexture(nil, "ARTWORK")
	Switch.ThumbTexture:SetSize(WIDGET_HEIGHT - 2, WIDGET_HEIGHT - 2)
	Switch.ThumbTexture:SetPoint("TOPLEFT", Switch.Thumb, 1, -1)
	Switch.ThumbTexture:SetPoint("BOTTOMRIGHT", Switch.Thumb, -1, 1)
	Switch.ThumbTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.ThumbTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Switch.Flavor = Switch:CreateTexture(nil, "ARTWORK")
	Switch.Flavor:SetPoint("TOPLEFT", Switch, "TOPLEFT", 1, -1)
	Switch.Flavor:SetPoint("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.Flavor:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.Flavor:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	Switch.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Switch.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Switch.Text:SetSize(GROUP_WIDTH - SWITCH_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Switch.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Switch.Text:SetJustifyH("LEFT")
	Switch.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Switch.Highlight = Switch:CreateTexture(nil, "HIGHLIGHT")
	Switch.Highlight:SetPoint("TOPLEFT", Switch, 1, -1)
	Switch.Highlight:SetPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Switch.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Switch.Highlight:SetAlpha(0)
	
	Switch.Move = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Move:SetEasing("in")
	Switch.Move:SetDuration(0.1)
	
	Anchor.Switch = Switch
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Switch
end

-- Input
function GUI:SetInputObject(input)
	local Text = input.ButtonText:GetText() or ""
	
	self.InputWindow.ActiveInput = input
	self.InputWindow.Input:SetText(Text)
	self.InputWindow:Show()
	self.InputWindow.FadeIn:Play()
end

function GUI:ToggleInputWindow(input)
	if (not self.InputWindow) then
		self:CreateInputWindow()
	end
	
	if self.InputWindow:IsShown() then
		if (input ~= self.InputWindow.ActiveInput) then
			self:SetInputObject(input)
		else
			self.InputWindow.FadeOut:Play()
		end
	else
		self:SetInputObject(input)
	end
end

local InputWindowOnEnterPressed = function(self)
	local Text = self:GetText() or ""
	
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	if GUI.InputWindow.ActiveInput then
		local Input = GUI.InputWindow.ActiveInput
		
		if Input.IsSavingDisabled then
			Input.ButtonText:SetText("")
		else
			SetVariable(Input.ID, Text)
			Input.ButtonText:SetText(Text)
		end
		
		if Input.ReloadFlag then
			HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, Input.Hook, CANCEL, nil, Text, Input.ID)
		elseif Input.Hook then
			Input.Hook(Text, Input.ID)
		end
		
		GUI:ToggleInputWindow(Input)
	end
end

local InputWindowOnMouseDown = function(self)
	self:HighlightText()
	self:SetAutoFocus(true)
end

function GUI:CreateInputWindow()
	if self.InputWindow then
		return self.InputWindow
	end
	
	local Window = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Window:SetSize(300, 200)
	Window:SetPoint("CENTER", HydraUI.UIParent, 0, 0)
	Window:SetBackdrop(HydraUI.BackdropAndBorder)
	Window:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:SetClampedToScreen(true)
	Window:SetAlpha(0)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Header:SetHeight(HEADER_HEIGHT)
	Window.Header:SetPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetPoint("TOPRIGHT", Window, -((SPACING + 2) + HEADER_HEIGHT), -SPACING)
	Window.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	HydraUI:SetFontInfo(Window.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF" .. Settings["ui-header-font-color"] .. Language["Input"] .. "|r")
	
	-- Close button
	Window.CloseButton = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.CloseButton:SetPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.CloseButton:SetBackdropColor(0, 0, 0, 0)
	Window.CloseButton:SetBackdropBorderColor(0, 0, 0)
	Window.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	Window.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	Window.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		self:GetParent().FadeOut:Play()
	end)
	
	Window.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	Window.CloseButton.Texture = Window.CloseButton:CreateTexture(nil, "ARTWORK")
	Window.CloseButton.Texture:SetPoint("TOPLEFT", Window.CloseButton, 1, -1)
	Window.CloseButton.Texture:SetPoint("BOTTOMRIGHT", Window.CloseButton, -1, 1)
	Window.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.CloseButton.Cross = Window.CloseButton:CreateTexture(nil, "OVERLAY")
	Window.CloseButton.Cross:SetPoint("CENTER", Window.CloseButton, 0, 0)
	Window.CloseButton.Cross:SetSize(16, 16)
	Window.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	Window.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	Window.Inner = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Inner:SetPoint("TOPLEFT", Window.Header, "BOTTOMLEFT", 0, -2)
	Window.Inner:SetPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Inner:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	HydraUI:SetFontInfo(Window.Input, Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMultiLine(true)
	Window.Input:SetMaxLetters(9999)
	Window.Input:SetCursorPosition(0)
	
	Window.Input:SetScript("OnEnterPressed", InputWindowOnEnterPressed)
	Window.Input:SetScript("OnEscapePressed", InputWindowOnEnterPressed)
	Window.Input:SetScript("OnMouseDown", InputWindowOnMouseDown)
	
	--[[ This just makes the animation look better. That's all. ಠ_ಠ
	Window.BlackTexture = Window:CreateTexture(nil, "BACKGROUND", -7)
	Window.BlackTexture:SetPoint("TOPLEFT", Window, 0, 0)
	Window.BlackTexture:SetPoint("BOTTOMRIGHT", Window, 0, 0)
	Window.BlackTexture:SetTexture(Assets:GetTexture("Blank"))
	Window.BlackTexture:SetVertexColor(0, 0, 0, 0)]]
	
	Window.Fade = CreateAnimationGroup(Window)
	
	Window.FadeIn = Window.Fade:CreateAnimation("Fade")
	Window.FadeIn:SetEasing("in")
	Window.FadeIn:SetDuration(0.15)
	Window.FadeIn:SetChange(1)
	
	Window.FadeOut = Window.Fade:CreateAnimation("Fade")
	Window.FadeOut:SetEasing("out")
	Window.FadeOut:SetDuration(0.15)
	Window.FadeOut:SetChange(0)
	Window.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.InputWindow = Window
	
	return Window
end

local INPUT_WIDTH = 130

local InputOnMouseDown = function(self)
	GUI:ToggleInputWindow(self)
end

local InputOnEnter = function(self)
	self.Parent.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local InputOnLeave = function(self)
	self.Parent.Highlight:SetAlpha(0)
end

local InputRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

local InputDisableSaving = function(self)
	self.IsSavingDisabled = true
	
	return self
end

GUI.Widgets.CreateInput = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Input = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Input:SetSize(INPUT_WIDTH, WIDGET_HEIGHT)
	Input:SetPoint("RIGHT", Anchor, 0, 0)
	Input:SetBackdrop(HydraUI.BackdropAndBorder)
	Input:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	Input:SetBackdropBorderColor(0, 0, 0)
	Input.ID = id
	Input.Hook = hook
	Input.Parent = Input
	Input.RequiresReload = InputRequiresReload
	Input.DisableSaving = InputDisableSaving
	
	Input:SetScript("OnEnter", InputOnEnter)
	Input:SetScript("OnLeave", InputOnLeave)
	Input:SetScript("OnMouseUp", InputOnMouseDown)
	
	Input.Texture = Input:CreateTexture(nil, "ARTWORK")
	Input.Texture:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Texture:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Input.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Input.Flash = Input:CreateTexture(nil, "OVERLAY")
	Input.Flash:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Flash:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Flash:SetTexture(Assets:GetTexture("RenHorizonUp"))
	Input.Flash:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	Input.Flash:SetAlpha(0)
	
	Input.Highlight = Input:CreateTexture(nil, "OVERLAY")
	Input.Highlight:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Highlight:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Input.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Input.Highlight:SetAlpha(0)
	
	Input.ButtonText = Input:CreateFontString(nil, "OVERLAY")
	HydraUI:SetFontInfo(Input.ButtonText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Input.ButtonText:SetSize(INPUT_WIDTH, WIDGET_HEIGHT)
	Input.ButtonText:SetPoint("TOPLEFT", Input, SPACING, -SPACING)
	Input.ButtonText:SetPoint("BOTTOMRIGHT", Input, -SPACING, SPACING)
	Input.ButtonText:SetJustifyH("LEFT")
	Input.ButtonText:SetText(value)
	
	Input.Text = Input:CreateFontString(nil, "OVERLAY")
	Input.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Input.Text:SetSize(GROUP_WIDTH - INPUT_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Input.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Input.Text:SetJustifyH("LEFT")
	Input.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Input.Fade = CreateAnimationGroup(Input.Flash)
	
	Input.FadeIn = Input.Fade:CreateAnimation("Fade")
	Input.FadeIn:SetEasing("in")
	Input.FadeIn:SetDuration(0.15)
	Input.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Input.FadeOut = Input.Fade:CreateAnimation("Fade")
	Input.FadeOut:SetOrder(2)
	Input.FadeOut:SetEasing("out")
	Input.FadeOut:SetDuration(0.15)
	Input.FadeOut:SetChange(0)
	
	tinsert(self.Widgets, Anchor)
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	Anchor.Input = Input
	
	return Input
end

local InputButtonOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	InputOnEnterPressed(self.Input)
end

local INPUT_BUTTON_WIDTH = (GROUP_WIDTH / 2) - (SPACING / 2)

GUI.Widgets.CreateInputWithButton = function(self, id, value, button, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Text = Anchor:CreateFontString(nil, "OVERLAY")
	Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Text:SetSize(GROUP_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	local Anchor2 = CreateFrame("Frame", nil, self)
	Anchor2:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor2.ID = id
	Anchor2.Text = label
	
	local Button = CreateFrame("Frame", nil, Anchor2, "BackdropTemplate")
	Button:SetSize(INPUT_BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetPoint("RIGHT", Anchor2, 0, 0)
	Button:SetBackdrop(HydraUI.BackdropAndBorder)
	Button:SetBackdropColor(0.17, 0.17, 0.17)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnMouseUp", InputButtonOnMouseUp)
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnEnter", ButtonWidgetOnEnter)
	Button:SetScript("OnLeave", ButtonWidgetOnLeave)
	Button.Tooltip = tooltip
	
	Button.Texture = Button:CreateTexture(nil, "BORDER")
	Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetPoint("CENTER", Button, "CENTER", 0, 0)
	HydraUI:SetFontInfo(Button.MiddleText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText(button)
	
	local Input = CreateFrame("Frame", nil, Anchor2, "BackdropTemplate")
	Input:SetSize(INPUT_BUTTON_WIDTH, WIDGET_HEIGHT)
	Input:SetPoint("LEFT", Anchor2, 0, 0)
	Input:SetBackdrop(HydraUI.BackdropAndBorder)
	Input:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	Input:SetBackdropBorderColor(0, 0, 0)
	
	Input.Texture = Input:CreateTexture(nil, "ARTWORK")
	Input.Texture:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Texture:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Input.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Input.Flash = Input:CreateTexture(nil, "OVERLAY")
	Input.Flash:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Flash:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Flash:SetTexture(Assets:GetTexture("RenHorizonUp"))
	Input.Flash:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	Input.Flash:SetAlpha(0)
	
	Input.Highlight = Input:CreateTexture(nil, "OVERLAY")
	Input.Highlight:SetPoint("TOPLEFT", Input, 1, -1)
	Input.Highlight:SetPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Input.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Input.Highlight:SetAlpha(0)
	
	Input.Box = CreateFrame("EditBox", nil, Input)
	HydraUI:SetFontInfo(Input.Box, Settings["ui-widget-font"], Settings["ui-font-size"])
	Input.Box:SetPoint("TOPLEFT", Input, SPACING, -2)
	Input.Box:SetPoint("BOTTOMRIGHT", Input, -SPACING, 2)
	Input.Box:SetJustifyH("LEFT")
	Input.Box:SetAutoFocus(false)
	Input.Box:EnableKeyboard(true)
	Input.Box:EnableMouse(true)
	Input.Box:SetMultiLine(true)
	Input.Box:SetMaxLetters(9999)
	Input.Box:SetText(value)
	Input.Box.ID = id
	Input.Box.Hook = hook
	Input.Box.Parent = Input
	Input.Box.RequiresReload = InputRequiresReload
	
	Input.Button = Button
	Button.Input = Input.Box
	
	Input.Box:SetScript("OnMouseDown", InputOnMouseDown)
	Input.Box:SetScript("OnEscapePressed", InputOnEscapePressed)
	Input.Box:SetScript("OnEnterPressed", InputOnEnterPressed)
	Input.Box:SetScript("OnEditFocusLost", InputOnEditFocusLost)
	Input.Box:SetScript("OnChar", InputOnChar)
	Input.Box:SetScript("OnEnter", InputOnEnter)
	Input.Box:SetScript("OnLeave", InputOnLeave)
	
	Input.Fade = CreateAnimationGroup(Input.Flash)
	
	Input.FadeIn = Input.Fade:CreateAnimation("Fade")
	Input.FadeIn:SetEasing("in")
	Input.FadeIn:SetDuration(0.15)
	Input.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Input.FadeOut = Input.Fade:CreateAnimation("Fade")
	Input.FadeOut:SetOrder(2)
	Input.FadeOut:SetEasing("out")
	Input.FadeOut:SetDuration(0.15)
	Input.FadeOut:SetChange(0)
	
	tinsert(self.Widgets, Anchor)
	tinsert(self.Widgets, Anchor2)
	
	Anchor.Input = Input
	
	return Input
end

GUI.ToggleExportWindow = function(self)
	if (not self.ExportWindow) then
		self:CreateExportWindow()
	end
	
	if self.ExportWindow:IsShown() then
		self.ExportWindow:Hide()
	else
		self.ExportWindow:Show()
	end
end

GUI.SetExportWindowText = function(self, text)
	if (type(text) ~= "string") then
		return
	end
	
	if (not match(text, "%S")) then
		return
	end
	
	if self.ExportWindow then
		self.ExportWindow.Input:SetText(text)
		self.ExportWindow.Input:HighlightText()
		self.ExportWindow.Input:SetAutoFocus(true)
	end
end

local ExportWindowOnEnterPressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local ExportWindowOnMouseDown = function(self)
	self:HighlightText()
	self:SetAutoFocus(true)
end

GUI.CreateExportWindow = function(self)
	if self.ExportWindow then
		return self.ExportWindow
	end
	
	local Window = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Window:SetSize(300, 80)
	Window:SetPoint("CENTER", HydraUI.UIParent, 0, 230)
	Window:SetBackdrop(HydraUI.BackdropAndBorder)
	Window:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Header:SetHeight(HEADER_HEIGHT)
	Window.Header:SetPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	HydraUI:SetFontInfo(Window.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"]..Language["Export string"].."|r")
	
	-- Close button
	Window.Header.CloseButton = CreateFrame("Frame", nil, Window.Header)
	Window.Header.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.Header.CloseButton:SetPoint("RIGHT", Window.Header, 0, 0)
	Window.Header.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(1, 0, 0) end)
	Window.Header.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(1, 1, 1) end)
	Window.Header.CloseButton:SetScript("OnMouseUp", function() GUI.ExportWindow:Hide() end)
	
	Window.Header.CloseButton.Cross = Window.Header.CloseButton:CreateTexture(nil, "OVERLAY")
	Window.Header.CloseButton.Cross:SetPoint("CENTER", Window.Header.CloseButton, 0, 0)
	Window.Header.CloseButton.Cross:SetSize(16, 16)
	Window.Header.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	Window.Header.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	Window.Label = Window:CreateFontString(nil, "OVERLAY")
	Window.Label:SetPoint("LEFT", Window, 6, 0)
	HydraUI:SetFontInfo(Window.Label, Settings["ui-font"], Settings["ui-font-size"])
	Window.Label:SetJustifyH("LEFT")
	Window.Label:SetText(Language["Press ctrl + c to copy"])
	
	Window.Inner = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Inner:SetPoint("BOTTOMLEFT", Window, 3, 3)
	Window.Inner:SetPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetHeight(20)
	Window.Inner:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Inner:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	HydraUI:SetFontInfo(Window.Input, Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMaxLetters(9999)
	Window.Input:SetCursorPosition(0)
	
	Window.Input:SetScript("OnEnterPressed", ExportWindowOnEnterPressed)
	Window.Input:SetScript("OnEscapePressed", ExportWindowOnEnterPressed)
	Window.Input:SetScript("OnMouseDown", ExportWindowOnMouseDown)
	
	self.ExportWindow = Window
	
	return Window
end

GUI.ToggleImportWindow = function(self)
	if (not self.ImportWindow) then
		self:CreateImportWindow()
	end
	
	if self.ImportWindow:IsShown() then
		self.ImportWindow:Hide()
	else
		self.ImportWindow:Show()
		self.ImportWindow.Input:SetAutoFocus(true)
	end
end

local ImportWindowOnEnterPressed = function(self)
	local Text = self:GetText()
	
	if (not match(Text, "%S+")) then
		self:SetAutoFocus(false)
		self:ClearFocus()
		
		return
	end
	
	local Profile = HydraUI:DecodeProfile(Text)
	
	if Profile then
		HydraUI:AddProfile(Profile)
	end
	
	self:SetText("")
	self:SetAutoFocus(false)
	self:ClearFocus()
	
	GUI:ToggleImportWindow()
end

local ImportWindowOnMouseDown = function(self)
	self:HighlightText()
	self:SetAutoFocus(true)
end

GUI.CreateImportWindow = function(self)
	if self.ImportWindow then
		return self.ImportWindow
	end
	
	local Window = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Window:SetSize(300, 80)
	Window:SetPoint("CENTER", HydraUI.UIParent, 0, 230)
	Window:SetBackdrop(HydraUI.BackdropAndBorder)
	Window:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Header:SetHeight(HEADER_HEIGHT)
	Window.Header:SetPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	HydraUI:SetFontInfo(Window.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Import string".."|r")
	
	-- Close button
	Window.Header.CloseButton = CreateFrame("Frame", nil, Window.Header)
	Window.Header.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.Header.CloseButton:SetPoint("RIGHT", Window.Header, 0, 0)
	Window.Header.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(1, 0, 0) end)
	Window.Header.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(1, 1, 1) end)
	Window.Header.CloseButton:SetScript("OnMouseUp", function() GUI.ImportWindow:Hide() end)
	
	Window.Header.CloseButton.Cross = Window.Header.CloseButton:CreateTexture(nil, "OVERLAY")
	Window.Header.CloseButton.Cross:SetPoint("CENTER", Window.Header.CloseButton, 0, 0)
	Window.Header.CloseButton.Cross:SetSize(16, 16)
	Window.Header.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	Window.Header.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	Window.Label = Window:CreateFontString(nil, "OVERLAY")
	Window.Label:SetPoint("LEFT", Window, 6, 0)
	HydraUI:SetFontInfo(Window.Label, Settings["ui-font"], Settings["ui-font-size"])
	Window.Label:SetJustifyH("LEFT")
	Window.Label:SetText(Language["Paste your profile string below"])
	
	Window.Inner = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.Inner:SetPoint("BOTTOMLEFT", Window, 3, 3)
	Window.Inner:SetPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetHeight(20)
	Window.Inner:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.Inner:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	HydraUI:SetFontInfo(Window.Input, Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetFrameLevel(99)
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMaxLetters(9999)
	
	Window.Input:SetScript("OnEnterPressed", ImportWindowOnEnterPressed)
	Window.Input:SetScript("OnEscapePressed", ImportWindowOnEnterPressed)
	Window.Input:SetScript("OnMouseDown", ImportWindowOnMouseDown)
	
	self.ImportWindow = Window
	
	return Window
end

-- Dropdown
local DROPDOWN_WIDTH = 130
local DROPDOWN_HEIGHT = 20
local DROPDOWN_FADE_DELAY = 3 -- To be implemented
local DROPDOWN_MAX_SHOWN = 8

local SetArrowUp = function(button)
	button.Arrow:SetTexture(Assets:GetTexture("Arrow Up"))
end

local SetArrowDown = function(button)
	button.Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
end

local CloseLastDropdown = function(compare)
	if (LAST_ACTIVE_DROPDOWN and LAST_ACTIVE_DROPDOWN.Menu:IsShown() and (LAST_ACTIVE_DROPDOWN ~= compare)) then
		if (not LAST_ACTIVE_DROPDOWN.Menu.FadeOut:IsPlaying()) then
			LAST_ACTIVE_DROPDOWN.Menu.FadeOut:Play()
			SetArrowDown(LAST_ACTIVE_DROPDOWN)
		end
	end
end

local DropdownButtonOnMouseUp = function(self)
	self.Parent.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.Menu:IsVisible() then
		self.Menu.FadeOut:Play()
		SetArrowDown(self)
	else
		for i = 1, #self.Menu do
			if self.Parent.SpecificType then
				if (self.Menu[i].Key == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			else
				if (self.Menu[i].Value == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			end
		end
		
		CloseLastDropdown(self)
		self.Menu:Show()
		self.Menu.FadeIn:Play()
		SetArrowUp(self)
	end
	
	LAST_ACTIVE_DROPDOWN = self
end

local DropdownButtonOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Parent.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)
	
	self.Highlight:SetAlpha(0)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.GrandParent.SpecificType then
		SetVariable(self.ID, self.Key)
		
		self.GrandParent.Value = self.Key
		
		if self.GrandParent.ReloadFlag then
			HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.GrandParent.Hook, CANCEL, nil, self.Key, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Key, self.ID)
		end
	else
		SetVariable(self.ID, self.Value)
		
		self.GrandParent.Value = self.Value
		
		if self.GrandParent.ReloadFlag then
			HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.GrandParent.Hook, CANCEL, nil, self.Value, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Value, self.ID)
		end
	end
	
	if (self.GrandParent.SpecificType == "Texture") then
		self.GrandParent.Texture:SetTexture(Assets:GetTexture(self.Key))
	elseif (self.GrandParent.SpecificType == "Font") then
		HydraUI:SetFontInfo(self.GrandParent.Current, self.Key, Settings["ui-font-size"])
	end
	
	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local DropdownUpdateList = function(self)
	
end

local DropdownOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local DropdownOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local DropdownEnable = function(self)
	self.Dropdown.Button:EnableMouse(true)
	
	self.Dropdown.Current:SetTextColor(HydraUI:HexToRGB("FFFFFF"))
	
	self.Dropdown.Button.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
end

local DropdownDisable = function(self)
	self.Dropdown.Button:EnableMouse(false)
	
	self.Dropdown.Current:SetTextColor(HydraUI:HexToRGB("A5A5A5"))
	
	self.Dropdown.Button.Arrow:SetVertexColor(HydraUI:HexToRGB("A5A5A5"))
end

local DropdownRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

local ScrollMenu = function(self)
	local First = false
	
	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + DROPDOWN_MAX_SHOWN - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, 0, 0)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end
			
			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SetDropdownOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self - (DROPDOWN_MAX_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local DropdownOnMouseWheel = function(self, delta)
	self:SetDropdownOffsetByDelta(delta)
	self:ScrollMenu()
	self.ScrollBar:SetValue(self.Offset)
end

local SetDropdownOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self - DROPDOWN_MAX_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:ScrollMenu()
end

local DropdownScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value
	
	Parent:ScrollMenu()
end

local DropdownScrollBarOnMouseWheel = function(self, delta)
	DropdownOnMouseWheel(self:GetParent(), delta)
end

local AddDropdownScrollBar = function(self)
	local ScrollWidth = (WIDGET_HEIGHT / 2)
	
	local ScrollBar = CreateFrame("Slider", nil, self, "BackdropTemplate")
	ScrollBar:SetPoint("TOPRIGHT", self, 0, 0)
	ScrollBar:SetPoint("BOTTOMRIGHT", self, 0, 0)
	--ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -2, 0)
	--ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -2, 0)
	ScrollBar:SetWidth(ScrollWidth)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(HydraUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, (#self - (DROPDOWN_MAX_SHOWN - 1)))
	ScrollBar:SetValue(1)
	--ScrollBar:SetObeyStepOnDrag(true)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)
	
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetSize(ScrollWidth, WIDGET_HEIGHT)
	Thumb:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewThumb = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewThumb:SetPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewThumb:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewThumb:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.NewThumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewThumb2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewThumb2:SetPoint("TOPLEFT", ScrollBar.NewThumb, 1, -1)
	ScrollBar.NewThumb2:SetPoint("BOTTOMRIGHT", ScrollBar.NewThumb, -1, 1)
	ScrollBar.NewThumb2:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewThumb2:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetPoint("BOTTOMRIGHT", ScrollBar.NewThumb, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Progress:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)
	
	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetDropdownOffset(1)
	
	ScrollBar:Show()
	
	for i = 1, #self do
		self[i]:SetWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	end
	
	self:SetWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	self:SetHeight(((WIDGET_HEIGHT - 1) * DROPDOWN_MAX_SHOWN) + 1)
end

local DropdownSort = function(self)
	tsort(self.Menu, function(a, b)
		return TrimHex(a.Key) < TrimHex(b.Key)
	end)
	
	for i = 1, #self.Menu do
		if (i == 1) then
			self.Menu[i]:SetPoint("TOP", self.Menu, 0, 0)
		else
			self.Menu[i]:SetPoint("TOP", self.Menu[i-1], "BOTTOM", 0, 1)
		end
	end
	
	self.Menu:SetHeight(((WIDGET_HEIGHT - 1) * #self.Menu) + 1)
end

local DropdownCreateSelection = function(self, key, value)
	local MenuItem = CreateFrame("Frame", nil, self.Menu, "BackdropTemplate")
	MenuItem:SetSize(DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	MenuItem:SetBackdrop(HydraUI.BackdropAndBorder)
	MenuItem:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	MenuItem:SetBackdropBorderColor(0, 0, 0)
	MenuItem:SetScript("OnMouseDown", MenuItemOnMouseDown)
	MenuItem:SetScript("OnMouseUp", MenuItemOnMouseUp)
	MenuItem:SetScript("OnEnter", MenuItemOnEnter)
	MenuItem:SetScript("OnLeave", MenuItemOnLeave)
	MenuItem.Parent = MenuItem:GetParent()
	MenuItem.GrandParent = MenuItem.Parent:GetParent()
	MenuItem.Key = key
	MenuItem.Value = value
	MenuItem.ID = self.ID
	
	MenuItem.Highlight = MenuItem:CreateTexture(nil, "OVERLAY")
	MenuItem.Highlight:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Highlight:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Highlight:SetTexture(Assets:GetTexture("Blank"))
	MenuItem.Highlight:SetVertexColor(1, 1, 1, 0.4)
	MenuItem.Highlight:SetAlpha(0)
	
	MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
	MenuItem.Texture:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Texture:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	MenuItem.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
	MenuItem.Selected:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Selected:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Selected:SetTexture(Assets:GetTexture("RenHorizonUp"))
	MenuItem.Selected:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	MenuItem.Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
	
	MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
	MenuItem.Text:SetPoint("LEFT", MenuItem, 5, 0)
	MenuItem.Text:SetSize((DROPDOWN_WIDTH - 6) - 12, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(MenuItem.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	MenuItem.Text:SetJustifyH("LEFT")
	MenuItem.Text:SetText(key)
	
	tinsert(self.Menu, MenuItem)
	
	return MenuItem
end

local DropdownRemoveSelection = function(self, key)
	for i = 1, #self.Menu do
		if (self.Menu[i].Key == key) then
			self.Menu[i]:Hide() -- Handle this more thoroughly
			self.Menu[i]:EnableMouse(false)
			
			tremove(self.Menu, i)
			
			self:Sort()
			
			return
		end
	end
end

GUI.Widgets.CreateDropdown = function(self, id, value, values, label, tooltip, hook, specific)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = DropdownEnable
	Anchor.Disable = DropdownDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Dropdown = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Dropdown:SetSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown:SetPoint("RIGHT", Anchor, 0, 0)
	Dropdown:SetBackdrop(HydraUI.BackdropAndBorder)
	Dropdown:SetBackdropColor(0.6, 0.6, 0.6)
	Dropdown:SetBackdropBorderColor(0, 0, 0)
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 1)
	Dropdown.Values = values
	Dropdown.Value = value
	Dropdown.ID = id
	Dropdown.Hook = hook
	Dropdown.Tooltip = tooltip
	Dropdown.SpecificType = specific
	Dropdown.RequiresReload = DropdownRequiresReload
	
	Dropdown.Sort = DropdownSort
	Dropdown.CreateSelection = DropdownCreateSelection
	Dropdown.RemoveSelection = DropdownRemoveSelection
	
	Dropdown.Texture = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Texture:SetPoint("TOPLEFT", Dropdown, 1, -1)
	Dropdown.Texture:SetPoint("BOTTOMRIGHT", Dropdown, -1, 1)
	Dropdown.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:SetPoint("LEFT", Dropdown, HEADER_SPACING, 0)
	Dropdown.Current:SetSize(DROPDOWN_WIDTH - 20, Settings["ui-font-size"])
	HydraUI:SetFontInfo(Dropdown.Current, Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Current:SetJustifyH("LEFT")
	
	Dropdown.Button = CreateFrame("Frame", nil, Dropdown, "BackdropTemplate")
	Dropdown.Button:SetSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown.Button:SetPoint("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetBackdrop(HydraUI.BackdropAndBorder)
	Dropdown.Button:SetBackdropColor(0, 0, 0, 0)
	Dropdown.Button:SetBackdropBorderColor(0, 0, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	Dropdown.Button:SetScript("OnEnter", DropdownOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownOnLeave)
	
	Dropdown.Button.Highlight = Dropdown.Button:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.Highlight:SetPoint("TOPLEFT", Dropdown.Button, 1, -1)
	Dropdown.Button.Highlight:SetPoint("BOTTOMRIGHT", Dropdown.Button, -1, 1)
	Dropdown.Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Dropdown.Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Dropdown.Button.Highlight:SetAlpha(0)
	
	Dropdown.Text = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Dropdown.Text:SetSize(GROUP_WIDTH - DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Dropdown.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Text:SetJustifyH("LEFT")
	Dropdown.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:SetSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Dropdown.ArrowAnchor:SetPoint("RIGHT", Dropdown, 0, 0)
	
	Dropdown.Button.Arrow = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	Dropdown.Button.Arrow:SetPoint("CENTER", Dropdown.ArrowAnchor, 0, 0)
	Dropdown.Button.Arrow:SetSize(16, 16)
	Dropdown.Button.Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
	Dropdown.Button.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:SetPoint("TOPLEFT", Dropdown, "BOTTOMLEFT", SPACING, -2)
	Dropdown.Menu:SetPoint("TOPRIGHT", Dropdown, "BOTTOMRIGHT", -SPACING, -2)
	Dropdown.Menu:SetSize(DROPDOWN_WIDTH - (SPACING * 2), 1)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu:EnableMouseWheel(true)
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)
	
	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown
	
	Dropdown.Menu.Group = CreateAnimationGroup(Dropdown.Menu)
	
	Dropdown.Menu.FadeIn = Dropdown.Menu.Group:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in")
	Dropdown.Menu.FadeIn:SetDuration(0.15)
	Dropdown.Menu.FadeIn:SetChange(1)
	
	Dropdown.Menu.FadeOut = Dropdown.Menu.Group:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu, "BackdropTemplate")
	Dropdown.Menu.BG:SetPoint("BOTTOMLEFT", Dropdown.Menu, -SPACING, -SPACING)
	Dropdown.Menu.BG:SetPoint("TOPRIGHT", Dropdown, "BOTTOMRIGHT", 0, 1)
	Dropdown.Menu.BG:SetBackdrop(HydraUI.BackdropAndBorder)
	Dropdown.Menu.BG:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	Dropdown.Menu.BG:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu.BG:EnableMouse(true)
	Dropdown.Menu.BG:SetScript("OnMouseWheel", function() end) -- Just to prevent misclicks from going through the frame
	
	for Key, Value in pairs(values) do
		local MenuItem = Dropdown:CreateSelection(Key, Value)
		
		if (specific == "Texture") then
			MenuItem.Texture:SetTexture(Assets:GetTexture(Key))
		elseif (specific == "Font") then
			HydraUI:SetFontInfo(MenuItem.Text, Key, 12)
		end
		
		if specific then
			if (MenuItem.Key == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		else
			if (MenuItem.Value == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		end
		
		Dropdown:Sort()
	end
	
	if (specific == "Texture") then
		Dropdown.Texture:SetTexture(Assets:GetTexture(value))
	elseif (specific == "Font") then
		Dropdown.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		HydraUI:SetFontInfo(Dropdown.Current, Settings[id], Settings["ui-font-size"])
	else
		Dropdown.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	end
	
	if (#Dropdown.Menu > DROPDOWN_MAX_SHOWN) then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:SetHeight(((WIDGET_HEIGHT - 1) * #Dropdown.Menu) + 1)
	end
	
	Anchor.Dropdown = Dropdown
	
	if self.Widgets then
		tinsert(self.Widgets, Anchor)
	end
	
	if (id ~= "") then
		GUI.WidgetID[id] = Anchor
	end
	
	return Dropdown
end

-- Slider
local SLIDER_WIDTH = 80
local EDITBOX_WIDTH = 48

local SliderOnValueChanged = function(self)
	local Value = self:GetValue()
	
	if (self.EditBox.StepValue >= 1) then
		Value = floor(Value)
	else
		if (self.EditBox.StepValue <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	self.EditBox.Value = Value
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
	
	SetVariable(self.ID, Value)
	
	if self.ReloadFlag then
		HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, self.Hook, CANCEL, nil, Value, self.ID)
	elseif self.Hook then
		self.Hook(Value, self.ID)
	end
end

local SliderOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	local Value = self.EditBox.Value
	local Step = self.EditBox.StepValue
	
	if (delta < 0) then
		Value = Value - Step
	else
		Value = Value + Step
	end
	
	if (Step >= 1) then
		Value = floor(Value)
	else
		if (Step <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	if (Value < self.EditBox.MinValue) then
		Value = self.EditBox.MinValue
	elseif (Value > self.EditBox.MaxValue) then
		Value = self.EditBox.MaxValue
	end
	
	self.EditBox.Value = Value
	
	self:SetValue(Value)
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
end

local EditBoxOnEnterPressed = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		return
	end
	
	if (Value ~= self.Value) then
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)
	end
	
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
	self:SetText(self.Value)
end

local EditBoxOnEditFocusLost = function(self)
	if (self.Value > self.MaxValue) then
		self.Value = self.MaxValue
	elseif (self.Value < self.MinValue) then
		self.Value = self.MinValue
	end
	
	self:SetText(self.Prefix..self.Value..self.Postfix)
end

local EditBoxOnChar = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		self:SetText(self.Value)
	end
end

local EditBoxOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	if self:HasFocus() then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
	
	if (delta > 0) then
		self.Value = self.Value + self.StepValue
		
		if (self.Value > self.MaxValue) then
			self.Value = self.MaxValue
		end
	else
		self.Value = self.Value - self.StepValue
		
		if (self.Value < self.MinValue) then
			self.Value = self.MinValue
		end
	end
	
	self:SetText(self.Value)
	self.Slider:SetValue(self.Value)
end

local EditBoxOnEnter = function(self)
	self.Parent.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local EditboxOnLeave = function(self)
	self.Parent.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SliderOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local SliderOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SliderEnable = function(self)
	self.Slider:EnableMouse(true)
	self.Slider:EnableMouseWheel(true)
	
	self.Slider.EditBox:EnableKeyboard(true)
	self.Slider.EditBox:EnableMouse(true)
	self.Slider.EditBox:EnableMouseWheel(true)
	
	self.Slider.EditBox:SetTextColor(HydraUI:HexToRGB("FFFFFF"))
	self.Slider.Progress:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
end

local SliderDisable = function(self)
	self.Slider:EnableMouse(false)
	self.Slider:EnableMouseWheel(false)
	
	self.Slider.EditBox:EnableKeyboard(false)
	self.Slider.EditBox:EnableMouse(false)
	self.Slider.EditBox:EnableMouseWheel(false)
	
	self.Slider.EditBox:SetTextColor(HydraUI:HexToRGB("A5A5A5"))
	self.Slider.Progress:SetVertexColor(HydraUI:HexToRGB("A5A5A5"))
end

local SliderRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI.Widgets.CreateSlider = function(self, id, value, minvalue, maxvalue, step, label, tooltip, hook, prefix, postfix)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, DROPDOWN_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = SliderEnable
	Anchor.Disable = SliderDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	if (not prefix) then
		prefix = ""
	end
	
	if (not postfix) then
		postfix = ""
	end
	
	local EditBox = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	EditBox:SetSize(EDITBOX_WIDTH, WIDGET_HEIGHT)
	EditBox:SetPoint("RIGHT", Anchor, 0, 0)
	EditBox:SetBackdrop(HydraUI.BackdropAndBorder)
	EditBox:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	EditBox:SetBackdropBorderColor(0, 0, 0)
	
	EditBox.Texture = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Texture:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Texture:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	EditBox.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Highlight:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Highlight:SetTexture(Assets:GetTexture("Blank"))
	EditBox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	EditBox.Highlight:SetAlpha(0)
	
	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	HydraUI:SetFontInfo(EditBox.Box, Settings["ui-widget-font"], Settings["ui-font-size"])
	EditBox.Box:SetPoint("TOPLEFT", EditBox, SPACING, -2)
	EditBox.Box:SetPoint("BOTTOMRIGHT", EditBox, -SPACING, 2)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(5)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetText(prefix..value..postfix)
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = step
	EditBox.Box.Value = value
	EditBox.Box.Prefix = prefix
	EditBox.Box.Postfix = postfix
	EditBox.Box.Parent = EditBox
	EditBox.Box.OnMouseWheel = EditBoxOnMouseWheel
	
	EditBox.Box:SetScript("OnMouseDown", EditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	EditBox.Box:SetScript("OnChar", EditBoxOnChar)
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditboxOnLeave)
	
	local Slider = CreateFrame("Slider", nil, Anchor, "BackdropTemplate")
	Slider:SetPoint("RIGHT", EditBox, "LEFT", -2, 0)
	Slider:SetSize(SLIDER_WIDTH, WIDGET_HEIGHT)
	Slider:SetThumbTexture(Assets:GetTexture("Blank"))
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(step)
	Slider:SetBackdrop(HydraUI.BackdropAndBorder)
	Slider:SetBackdropColor(0, 0, 0)
	Slider:SetBackdropBorderColor(0, 0, 0)
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(value)
	Slider:EnableMouseWheel(true)
	Slider:SetObeyStepOnDrag(true)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider:SetScript("OnEnter", SliderOnEnter)
	Slider:SetScript("OnLeave", SliderOnLeave)
	Slider.Prefix = prefix or ""
	Slider.Postfix = postfix or ""
	Slider.EditBox = EditBox.Box
	Slider.Hook = hook
	Slider.ID = id
	Slider.RequiresReload = SliderRequiresReload
	Slider.OnMouseWheel = SliderOnMouseWheel
	
	Slider.Text = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Slider.Text:SetSize(GROUP_WIDTH - SLIDER_WIDTH - EDITBOX_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Slider.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Slider.Text:SetJustifyH("LEFT")
	Slider.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Slider.TrackTexture = Slider:CreateTexture(nil, "ARTWORK")
	Slider.TrackTexture:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.TrackTexture:SetPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.TrackTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.TrackTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Thumb = Slider:GetThumbTexture()
	Thumb:SetSize(8, WIDGET_HEIGHT)
	Thumb:SetTexture(Assets:GetTexture("Blank"))
	Thumb:SetVertexColor(0, 0, 0)
	
	Slider.NewThumb = CreateFrame("Frame", nil, Slider, "BackdropTemplate")
	Slider.NewThumb:SetPoint("TOPLEFT", Thumb, 0, -1)
	Slider.NewThumb:SetPoint("BOTTOMRIGHT", Thumb, 0, 1)
	Slider.NewThumb:SetBackdrop(HydraUI.BackdropAndBorder)
	Slider.NewThumb:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-widget-bg-color"]))
	Slider.NewThumb:SetBackdropBorderColor(0, 0, 0)
	
	Slider.NewThumb.Texture = Slider.NewThumb:CreateTexture(nil, "OVERLAY")
	Slider.NewThumb.Texture:SetPoint("TOPLEFT", Slider.NewThumb, 1, 0)
	Slider.NewThumb.Texture:SetPoint("BOTTOMRIGHT", Slider.NewThumb, -1, 0)
	Slider.NewThumb.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.NewThumb.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.Progress:SetPoint("BOTTOMRIGHT", Slider.NewThumb.Texture, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.Progress:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	
	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY", 8)
	Slider.Highlight:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.Highlight:SetPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Slider.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Slider.Highlight:SetAlpha(0)
	
	EditBox.Box.Slider = Slider
	Anchor.Slider = Slider
	
	Slider:Show()
	
	tinsert(self.Widgets, Anchor)
	
	return Slider
end

-- Color
local COLOR_WIDTH = 80
local SWATCH_SIZE = 20
local MAX_SWATCHES_X = 20
local MAX_SWATCHES_Y = 10

local ColorSwatchOnMouseUp = function(self)
	GUI.ColorPicker.Transition:SetChange(HydraUI:HexToRGB(self.Value))
	GUI.ColorPicker.Transition:Play()
	GUI.ColorPicker.NewHexText:SetText("#"..self.Value)
	GUI.ColorPicker.Selected = self.Value
end

local ColorSwatchOnEnter = function(self)
	self.Highlight:SetAlpha(1)
end

local ColorSwatchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ColorPickerAccept = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	local Active = self:GetParent().Active
	
	if GUI.ColorPicker.Selected then
		Active.Transition:SetChange(HydraUI:HexToRGB(GUI.ColorPicker.Selected))
		Active.Transition:Play()
		
		Active.MiddleText:SetText("#"..upper(GUI.ColorPicker.Selected))
		Active.Value = GUI.ColorPicker.Selected
		
		SetVariable(Active.ID, Active.Value)
		
		if Active.ReloadFlag then
			HydraUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], ACCEPT, Active.Hook, CANCEL, nil, Active.Value, Active.ID)
		elseif Active.Hook then
			Active.Hook(Active.Value, Active.ID)
		end
	end
	
	GUI.ColorPicker.FadeOut:Play()
end

local ColorPickerCancel = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	GUI.ColorPicker.FadeOut:Play()
end

local ColorPickerOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ColorPickerOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SwatchEditBoxOnEscapePressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local SwatchEditBoxOnEnterPressed = function(self)
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local SwatchEditBoxOnEditFocusLost = function(self)
	local Value = self:GetText()
	
	Value = gsub(Value, "#", "")
	
	if (Value and match(Value, "%x%x%x%x%x%x")) then
		self:SetText("#"..Value)
		
		GUI.ColorPicker.Transition:SetChange(HydraUI:HexToRGB(Value))
		GUI.ColorPicker.Selected = Value
	elseif (Value and Value == "CLASS") then
		local ClassColor = RAID_CLASS_COLORS[HydraUI.UserClass]
		local ClassHex = HydraUI:RGBToHex(ClassColor.r, ClassColor.g, ClassColor.b)
		
		self:SetText("#"..upper(ClassHex))
		
		GUI.ColorPicker.Transition:SetChange(HydraUI:HexToRGB(ClassHex))
		GUI.ColorPicker.Selected = ClassHex
	else
		HydraUI:print(format('Invalid hex code "%s".', Value))
		
		self:SetText("#" .. GUI.ColorPicker.Active.Value)
		
		GUI.ColorPicker.Transition:SetChange(HydraUI:HexToRGB(GUI.ColorPicker.Active.Value))
		GUI.ColorPicker.Selected = GUI.ColorPicker.Active.Value
	end
	
	GUI.ColorPicker.Transition:Play()
end

local SwatchEditBoxOnChar = function(self)
	local Value = self:GetText()
	
	Value = gsub(Value, "#", "")
	Value = upper(Value)
	
	self:SetText(Value)
	
	if match(Value, "%x%x%x%x%x%x") or (Value == "CLASS") then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
end

local SwatchEditBoxOnEditFocusGained = function(self)
	local Text = self:GetText()
	
	Text = gsub(Text, "#", "")
	
	self:SetText(Text)
	self:HighlightText()
end

local SwatchEditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
end

local SwatchButtonOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local UpdateColorPalette = function(value)
	GUI.ColorPicker:SetColorPalette(value)
end

local UpdateColorPickerTexture = function(value)
	local Texture = Assets:GetTexture(value)
	
	for i = 1, MAX_SWATCHES_Y do
		for j = 1, MAX_SWATCHES_X do
			GUI.ColorPicker.SwatchParent[i][j].Texture:SetTexture(Texture)
		end
	end
end

local CreateColorPicker = function()
	if GUI.ColorPicker then
		return
	end
	
	local ColorPicker = CreateFrame("Frame", "HydraUIColorPicker", GUI, "BackdropTemplate")
	ColorPicker:SetSize(388, 290)
	ColorPicker:SetPoint("CENTER", GUI, 0, 50)
	ColorPicker:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	ColorPicker:SetBackdropBorderColor(0, 0, 0)
	ColorPicker:SetFrameStrata("HIGH")
	ColorPicker:SetFrameLevel(10)
	ColorPicker:Hide()
	ColorPicker:SetAlpha(0)
	ColorPicker:SetMovable(true)
	ColorPicker:EnableMouse(true)
	ColorPicker:RegisterForDrag("LeftButton")
	ColorPicker:SetScript("OnDragStart", ColorPicker.StartMoving)
	ColorPicker:SetScript("OnDragStop", ColorPicker.StopMovingOrSizing)
	
	-- Header
	ColorPicker.Header = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.Header:SetHeight(HEADER_HEIGHT)
	ColorPicker.Header:SetPoint("TOPLEFT", ColorPicker, 2, -2)
	ColorPicker.Header:SetPoint("TOPRIGHT", ColorPicker, -(HEADER_HEIGHT + 2), -2)
	ColorPicker.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.Header:SetBackdropColor(0, 0, 0)
	ColorPicker.Header:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.HeaderTexture = ColorPicker.Header:CreateTexture(nil, "OVERLAY")
	ColorPicker.HeaderTexture:SetPoint("TOPLEFT", ColorPicker.Header, 1, -1)
	ColorPicker.HeaderTexture:SetPoint("BOTTOMRIGHT", ColorPicker.Header, -1, 1)
	ColorPicker.HeaderTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.HeaderTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.Header.Text = ColorPicker.Header:CreateFontString(nil, "OVERLAY")
	ColorPicker.Header.Text:SetPoint("LEFT", ColorPicker.Header, HEADER_SPACING, -1)
	HydraUI:SetFontInfo(ColorPicker.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	ColorPicker.Header.Text:SetJustifyH("LEFT")
	ColorPicker.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Select a color".."|r")
	
	-- Close button
	ColorPicker.CloseButton = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	ColorPicker.CloseButton:SetPoint("LEFT", ColorPicker.Header, "RIGHT", 2, 0)
	ColorPicker.CloseButton:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.CloseButton:SetBackdropColor(0, 0, 0, 0)
	ColorPicker.CloseButton:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	ColorPicker.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	ColorPicker.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		self:GetParent().FadeOut:Play()
	end)
	
	ColorPicker.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	ColorPicker.CloseButton.Texture = ColorPicker.CloseButton:CreateTexture(nil, "ARTWORK")
	ColorPicker.CloseButton.Texture:SetPoint("TOPLEFT", ColorPicker.CloseButton, 1, -1)
	ColorPicker.CloseButton.Texture:SetPoint("BOTTOMRIGHT", ColorPicker.CloseButton, -1, 1)
	ColorPicker.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.CloseButton.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.CloseButton.Cross = ColorPicker.CloseButton:CreateTexture(nil, "OVERLAY")
	ColorPicker.CloseButton.Cross:SetPoint("CENTER", ColorPicker.CloseButton, 0, 0)
	ColorPicker.CloseButton.Cross:SetSize(16, 16)
	ColorPicker.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	ColorPicker.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))
	
	-- Selection parent
	ColorPicker.SwatchParent = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.SwatchParent:SetPoint("TOPLEFT", ColorPicker.Header, "BOTTOMLEFT", 0, -2)
	ColorPicker.SwatchParent:SetPoint("TOPRIGHT", ColorPicker.CloseButton, "BOTTOMRIGHT", 0, -2)
	ColorPicker.SwatchParent:SetHeight((SWATCH_SIZE * MAX_SWATCHES_Y) - SPACING)
	ColorPicker.SwatchParent:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.SwatchParent:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	ColorPicker.SwatchParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Current
	ColorPicker.Current = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.Current:SetSize((390 / 3), 20)
	ColorPicker.Current:SetPoint("TOPLEFT", ColorPicker.SwatchParent, "BOTTOMLEFT", 0, -2)
	ColorPicker.Current:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.Current:SetBackdropColor(0, 0, 0)
	ColorPicker.Current:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentTexture = ColorPicker.Current:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentTexture:SetPoint("TOPLEFT", ColorPicker.Current, 1, -1)
	ColorPicker.CurrentTexture:SetPoint("BOTTOMRIGHT", ColorPicker.Current, -1, 1)
	ColorPicker.CurrentTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.CurrentTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.CurrentText = ColorPicker.Current:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentText:SetPoint("CENTER", ColorPicker.Current, HEADER_SPACING, -1)
	HydraUI:SetFontInfo(ColorPicker.CurrentText, Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.CurrentText:SetJustifyH("CENTER")
	ColorPicker.CurrentText:SetText(Language["Current"])
	ColorPicker.CurrentText:SetTextColor(HydraUI:HexToRGB(Settings["ui-header-font-color"]))
	
	ColorPicker.CurrentHex = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.CurrentHex:SetSize(108, 20)
	ColorPicker.CurrentHex:SetPoint("TOPLEFT", ColorPicker.Current, "BOTTOMLEFT", 0, -2)
	ColorPicker.CurrentHex:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.CurrentHex:SetBackdropColor(0, 0, 0)
	ColorPicker.CurrentHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentHexTexture = ColorPicker.CurrentHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentHexTexture:SetPoint("TOPLEFT", ColorPicker.CurrentHex, 1, -1)
	ColorPicker.CurrentHexTexture:SetPoint("BOTTOMRIGHT", ColorPicker.CurrentHex, -1, 1)
	ColorPicker.CurrentHexTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.CurrentHexTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	ColorPicker.CurrentHexText = ColorPicker.CurrentHex:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentHexText:SetPoint("CENTER", ColorPicker.CurrentHex, 0, 0)
	HydraUI:SetFontInfo(ColorPicker.CurrentHexText, Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.CurrentHexText:SetJustifyH("CENTER")
	
	ColorPicker.CompareCurrentParent = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.CompareCurrentParent:SetSize(20, 20)
	ColorPicker.CompareCurrentParent:SetPoint("LEFT", ColorPicker.CurrentHex, "RIGHT", 2, 0)
	ColorPicker.CompareCurrentParent:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.CompareCurrentParent:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.CompareCurrentParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareCurrent = ColorPicker.CompareCurrentParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareCurrent:SetPoint("TOPLEFT", ColorPicker.CompareCurrentParent, 1, -1)
	ColorPicker.CompareCurrent:SetPoint("BOTTOMRIGHT", ColorPicker.CompareCurrentParent, -1, 1)
	ColorPicker.CompareCurrent:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	-- New
	ColorPicker.New = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.New:SetSize((390 / 3), 20)
	ColorPicker.New:SetPoint("TOPLEFT", ColorPicker.Current, "TOPRIGHT", 2, 0)
	ColorPicker.New:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.New:SetBackdropColor(0, 0, 0)
	ColorPicker.New:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewTexture = ColorPicker.New:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewTexture:SetPoint("TOPLEFT", ColorPicker.New, 1, -1)
	ColorPicker.NewTexture:SetPoint("BOTTOMRIGHT", ColorPicker.New, -1, 1)
	ColorPicker.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.NewTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	ColorPicker.NewText = ColorPicker.New:CreateFontString(nil, "OVERLAY")
	ColorPicker.NewText:SetPoint("CENTER", ColorPicker.New, 0, -1)
	HydraUI:SetFontInfo(ColorPicker.NewText, Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.NewText:SetJustifyH("CENTER")
	ColorPicker.NewText:SetText(Language["New"])
	ColorPicker.NewText:SetTextColor(HydraUI:HexToRGB(Settings["ui-header-font-color"]))
	
	ColorPicker.NewHex = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.NewHex:SetSize(108, 20)
	ColorPicker.NewHex:SetPoint("TOPRIGHT", ColorPicker.New, "BOTTOMRIGHT", 0, -2)
	ColorPicker.NewHex:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.NewHex:SetBackdropColor(0, 0, 0)
	ColorPicker.NewHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewHexTexture = ColorPicker.NewHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewHexTexture:SetPoint("TOPLEFT", ColorPicker.NewHex, 1, -1)
	ColorPicker.NewHexTexture:SetPoint("BOTTOMRIGHT", ColorPicker.NewHex, -1, 1)
	ColorPicker.NewHexTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.NewHexTexture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	ColorPicker.NewHexText = CreateFrame("EditBox", nil, ColorPicker.NewHex)
	HydraUI:SetFontInfo(ColorPicker.NewHexText, Settings["ui-widget-font"], Settings["ui-font-size"])
	ColorPicker.NewHexText:SetPoint("TOPLEFT", ColorPicker.NewHex, SPACING, -2)
	ColorPicker.NewHexText:SetPoint("BOTTOMRIGHT", ColorPicker.NewHex, -SPACING, 2)
	ColorPicker.NewHexText:SetJustifyH("CENTER")
	ColorPicker.NewHexText:SetMaxLetters(7)
	ColorPicker.NewHexText:SetAutoFocus(false)
	ColorPicker.NewHexText:EnableKeyboard(true)
	ColorPicker.NewHexText:EnableMouse(true)
	ColorPicker.NewHexText:SetText("")
	ColorPicker.NewHexText:SetHighlightColor(0, 0, 0)
	ColorPicker.NewHexText:SetScript("OnMouseDown", SwatchEditBoxOnMouseDown)
	ColorPicker.NewHexText:SetScript("OnEscapePressed", SwatchEditBoxOnEscapePressed)
	ColorPicker.NewHexText:SetScript("OnEnterPressed", SwatchEditBoxOnEnterPressed)
	ColorPicker.NewHexText:SetScript("OnEditFocusLost", SwatchEditBoxOnEditFocusLost)
	ColorPicker.NewHexText:SetScript("OnEditFocusGained", SwatchEditBoxOnEditFocusGained)
	ColorPicker.NewHexText:SetScript("OnChar", SwatchEditBoxOnChar)
	
	ColorPicker.CompareNewParent = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.CompareNewParent:SetSize(20, 20)
	ColorPicker.CompareNewParent:SetPoint("RIGHT", ColorPicker.NewHex, "LEFT", -2, 0)
	ColorPicker.CompareNewParent:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.CompareNewParent:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.CompareNewParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareNew = ColorPicker.CompareNewParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareNew:SetSize(ColorPicker.CompareNewParent:GetWidth() - 2, 19)
	ColorPicker.CompareNew:SetPoint("TOPLEFT", ColorPicker.CompareNewParent, 1, -1)
	ColorPicker.CompareNew:SetPoint("BOTTOMRIGHT", ColorPicker.CompareNewParent, -1, 1)
	ColorPicker.CompareNew:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	
	ColorPicker.Transition = CreateAnimationGroup(ColorPicker.CompareNew):CreateAnimation("Color")
	ColorPicker.Transition:SetColorType("vertex")
	ColorPicker.Transition:SetEasing("in")
	ColorPicker.Transition:SetDuration(0.15)
	
	-- Accept
	ColorPicker.Accept = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.Accept:SetSize((390 / 3) - (SPACING * 3) + 1, 20)
	ColorPicker.Accept:SetPoint("TOPLEFT", ColorPicker.New, "TOPRIGHT", 2, 0)
	ColorPicker.Accept:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.Accept:SetBackdropColor(0, 0, 0)
	ColorPicker.Accept:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Accept:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Accept:SetScript("OnMouseUp", ColorPickerAccept)
	ColorPicker.Accept:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Accept:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Accept.Texture = ColorPicker.Accept:CreateTexture(nil, "ARTWORK")
	ColorPicker.Accept.Texture:SetPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Texture:SetPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Texture:SetTexture(Assets:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Accept.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	ColorPicker.Accept.Highlight = ColorPicker.Accept:CreateTexture(nil, "OVERLAY")
	ColorPicker.Accept.Highlight:SetPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Highlight:SetPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Highlight:SetTexture(Assets:GetTexture("Blank"))
	ColorPicker.Accept.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Accept.Highlight:SetAlpha(0)
	
	ColorPicker.AcceptText = ColorPicker.Accept:CreateFontString(nil, "OVERLAY")
	ColorPicker.AcceptText:SetPoint("CENTER", ColorPicker.Accept, 0, 0)
	HydraUI:SetFontInfo(ColorPicker.AcceptText, Settings["ui-button-font"], Settings["ui-font-size"])
	ColorPicker.AcceptText:SetJustifyH("CENTER")
	ColorPicker.AcceptText:SetText("|cFF"..Settings["ui-button-font-color"]..ACCEPT.."|r")
	
	-- Cancel
	ColorPicker.Cancel = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.Cancel:SetSize((390 / 3) - (SPACING * 3) + 1, 20)
	ColorPicker.Cancel:SetPoint("TOPLEFT", ColorPicker.Accept, "BOTTOMLEFT", 0, -2)
	ColorPicker.Cancel:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.Cancel:SetBackdropColor(0, 0, 0)
	ColorPicker.Cancel:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Cancel:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Cancel:SetScript("OnMouseUp", ColorPickerCancel)
	ColorPicker.Cancel:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Cancel:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Cancel.Texture = ColorPicker.Cancel:CreateTexture(nil, "ARTWORK")
	ColorPicker.Cancel.Texture:SetPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Texture:SetPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Texture:SetTexture(Assets:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Cancel.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	ColorPicker.Cancel.Highlight = ColorPicker.Cancel:CreateTexture(nil, "OVERLAY")
	ColorPicker.Cancel.Highlight:SetPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Highlight:SetPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Highlight:SetTexture(Assets:GetTexture("Blank"))
	ColorPicker.Cancel.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Cancel.Highlight:SetAlpha(0)
	
	ColorPicker.CancelText = ColorPicker.Cancel:CreateFontString(nil, "OVERLAY")
	ColorPicker.CancelText:SetPoint("CENTER", ColorPicker.Cancel, 0, 0)
	HydraUI:SetFontInfo(ColorPicker.CancelText, Settings["ui-button-font"], Settings["ui-font-size"])
	ColorPicker.CancelText:SetJustifyH("CENTER")
	ColorPicker.CancelText:SetText("|cFF"..Settings["ui-button-font-color"]..CANCEL.."|r")
	
	ColorPicker.BG = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
	ColorPicker.BG:SetPoint("TOPLEFT", ColorPicker.Header, -3, 3)
	ColorPicker.BG:SetPoint("BOTTOMRIGHT", ColorPicker, 3, 0)
	ColorPicker.BG:SetBackdrop(HydraUI.BackdropAndBorder)
	ColorPicker.BG:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	ColorPicker.BG:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.Fade = CreateAnimationGroup(ColorPicker)
	
	ColorPicker.FadeIn = ColorPicker.Fade:CreateAnimation("Fade")
	ColorPicker.FadeIn:SetEasing("in")
	ColorPicker.FadeIn:SetDuration(0.15)
	ColorPicker.FadeIn:SetChange(1)
	
	ColorPicker.FadeOut = ColorPicker.Fade:CreateAnimation("Fade")
	ColorPicker.FadeOut:SetEasing("out")
	ColorPicker.FadeOut:SetDuration(0.15)
	ColorPicker.FadeOut:SetChange(0)
	ColorPicker.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	local PaletteDropdown = GUI.Widgets.CreateDropdown(ColorPicker, "ui-picker-palette", Settings["ui-picker-palette"], Assets:GetPaletteList(), Language["Set Palette"], Language["Select a color palette to use"], UpdateColorPalette, "Palette")
	PaletteDropdown:ClearAllPoints()
	PaletteDropdown:SetPoint("BOTTOMLEFT", ColorPicker, 2, 3)
	PaletteDropdown:GetParent():SetPoint("BOTTOMLEFT", ColorPicker, 0, 3)
	PaletteDropdown.Text:ClearAllPoints()
	PaletteDropdown.Text:SetPoint("LEFT", PaletteDropdown, "RIGHT", LABEL_SPACING, 0)
	
	local Palette = Assets:GetPalette(Settings["ui-picker-palette"])
	
	ColorPicker.SetColorPalette = function(self, name)
		local Palette = Assets:GetPalette(name)
		local Swatch
		
		for i = 1, MAX_SWATCHES_Y do
			for j = 1, MAX_SWATCHES_X do
				Swatch = self.SwatchParent[i][j]
				
				if (Palette[i] and Palette[i][j]) then
					Swatch.Value = Palette[i][j]
					Swatch:SetScript("OnMouseUp", ColorSwatchOnMouseUp)
					Swatch:SetScript("OnEnter", ColorSwatchOnEnter)
					Swatch:SetScript("OnLeave", ColorSwatchOnLeave)
					--Swatch:Show()
				else
					Swatch.Value = "444444"
					Swatch:SetScript("OnMouseUp", nil)
					Swatch:SetScript("OnEnter", nil)
					Swatch:SetScript("OnLeave", nil)
					--Swatch:Hide()
				end
				
				Swatch.Texture:SetVertexColor(HydraUI:HexToRGB(Swatch.Value))
			end
		end
	end
	
	for i = 1, MAX_SWATCHES_Y do
		for j = 1, MAX_SWATCHES_X do
			local Swatch = CreateFrame("Frame", nil, ColorPicker, "BackdropTemplate")
			Swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
			Swatch:SetBackdrop(HydraUI.BackdropAndBorder)
			Swatch:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
			Swatch:SetBackdropBorderColor(0, 0, 0)
			
			if (Palette[i] and Palette[i][j]) then
				Swatch.Value = Palette[i][j]
				Swatch:SetScript("OnMouseUp", ColorSwatchOnMouseUp)
				Swatch:SetScript("OnEnter", ColorSwatchOnEnter)
				Swatch:SetScript("OnLeave", ColorSwatchOnLeave)
			else
				Swatch.Value = "444444"
				Swatch:SetScript("OnMouseUp", nil)
				Swatch:SetScript("OnEnter", nil)
				Swatch:SetScript("OnLeave", nil)
				--Swatch:Hide()
			end
			
			Swatch.Texture = Swatch:CreateTexture(nil, "OVERLAY")
			Swatch.Texture:SetPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Texture:SetPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
			Swatch.Texture:SetVertexColor(HydraUI:HexToRGB(Swatch.Value))
			
			Swatch.Highlight = CreateFrame("Frame", nil, Swatch, "BackdropTemplate")
			Swatch.Highlight:SetBackdrop(HydraUI.Outline)
			Swatch.Highlight:SetPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Highlight:SetPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Highlight:SetBackdropColor(0, 0, 0)
			Swatch.Highlight:SetBackdropBorderColor(1, 1, 1)
			Swatch.Highlight:SetAlpha(0)
			
			if (not ColorPicker.SwatchParent[i]) then
				ColorPicker.SwatchParent[i] = {}
			end
			
			if (i == 1) then
				if (j == 1) then
					Swatch:SetPoint("TOPLEFT", ColorPicker.SwatchParent, 3, -3)
				else
					Swatch:SetPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			else
				if (j == 1) then
					Swatch:SetPoint("TOPLEFT", ColorPicker.SwatchParent[i-1][1], "BOTTOMLEFT", 0, 1)
				else
					Swatch:SetPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			end
			
			ColorPicker.SwatchParent[i][j] = Swatch
		end
	end
	
	GUI.ColorPicker = ColorPicker
end

local SetSwatchObject = function(active)
	GUI.ColorPicker.Active = active
	
	GUI.ColorPicker.CompareCurrent:SetVertexColor(HydraUI:HexToRGB(active.Value))
	GUI.ColorPicker.CurrentHexText:SetText("#"..active.Value)
	
	GUI.ColorPicker.NewHexText:SetText("")
	GUI.ColorPicker.CompareNew:SetVertexColor(1, 1, 1)
	GUI.ColorPicker.Selected = active.Value
end

local ColorSelectionOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local ColorSelectionOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ColorSelectionOnMouseUp = function(self)
	if (not GUI.ColorPicker) then
		CreateColorPicker()
	end
	
	if GUI.ColorPicker:IsShown() then
		if (self ~= GUI.ColorPicker.Active) then
			SetSwatchObject(self)
		else
			GUI.ColorPicker.FadeOut:Play()
		end
	else
		SetSwatchObject(self)
		
		GUI.ColorPicker:Show()
		GUI.ColorPicker.FadeIn:Play()
	end
end

local ColorRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI.Widgets.CreateColorSelection = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Swatch = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
	Swatch:SetPoint("RIGHT", Anchor, 0, 0)
	Swatch:SetBackdrop(HydraUI.BackdropAndBorder)
	Swatch:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Swatch:SetBackdropBorderColor(0, 0, 0)
	
	Swatch.Texture = Swatch:CreateTexture(nil, "OVERLAY")
	Swatch.Texture:SetPoint("TOPLEFT", Swatch, 1, -1)
	Swatch.Texture:SetPoint("BOTTOMRIGHT", Swatch, -1, 1)
	Swatch.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Swatch.Texture:SetVertexColor(HydraUI:HexToRGB(value))
	
	local Button = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Button:SetSize(COLOR_WIDTH, WIDGET_HEIGHT)
	Button:SetPoint("RIGHT", Swatch, "LEFT", -2, 0)
	Button:SetBackdrop(HydraUI.BackdropAndBorder)
	Button:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnEnter", ColorSelectionOnEnter)
	Button:SetScript("OnLeave", ColorSelectionOnLeave)
	Button:SetScript("OnMouseUp", ColorSelectionOnMouseUp)
	Button.ID = id
	Button.Hook = hook
	Button.Value = value
	Button.Tooltip = tooltip
	Button.Swatch = Swatch
	Button.RequiresReload = ColorRequiresReload
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Texture = Button:CreateTexture(nil, "ARTWORK")
	Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Button.Transition = CreateAnimationGroup(Swatch.Texture):CreateAnimation("Color")
	Button.Transition:SetColorType("vertex")
	Button.Transition:SetEasing("in")
	Button.Transition:SetDuration(0.15)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetPoint("CENTER", Button, 0, 0)
	Button.MiddleText:SetSize(COLOR_WIDTH - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Button.MiddleText, Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText("#"..upper(value))
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetSize(GROUP_WIDTH - COLOR_WIDTH - SWATCH_SIZE - 6, WIDGET_HEIGHT)
	HydraUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Button
end