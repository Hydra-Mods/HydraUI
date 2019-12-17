local vUI, GUI, Language, Media, Settings, Defaults = select(2, ...):get()

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
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local IsModifierKeyDown = IsModifierKeyDown
local GetMouseFocus = GetMouseFocus

GUI.Widgets = {}

--[[
	
	Thoughts:
	
	- Rename RequiresReload to RequiresWarning etc
	
	To do:
	- widgets:
	Input (longer editbox that accepts text input, as well as dropping spells/actions/items into it)
	Input.Imprint = a string that shows when the editbox is empty; a suggestion, or default value.
	
	DoubleButton
	
	- If template == "None" then disable the styles page
	
	- Set the scrollbars to have arrow button
	- Dropdown breaks, when clicked won't respond. something like "---------------"
	
	- Widget methods
	widget:Disable()
	widget:Enable()
	widget:GetValue()
	widget:SetValue()
--]]

-- Constants
local GUI_WIDTH = 726
local GUI_HEIGHT = 340
local SPACING = 3

local HEADER_WIDTH = GUI_WIDTH - (SPACING * 2)
local HEADER_HEIGHT = 20
local HEADER_SPACING = 5

local BUTTON_LIST_WIDTH = 126
local BUTTON_LIST_HEIGHT = (GUI_HEIGHT - HEADER_HEIGHT - (SPACING * 2) - 2)

local PARENT_WIDTH = GUI_WIDTH - BUTTON_LIST_WIDTH - ((SPACING * 2) + 2)

local GROUP_HEIGHT = 80
local GROUP_WIDTH = 270

local MENU_BUTTON_WIDTH = BUTTON_LIST_WIDTH - (SPACING * 2)
local MENU_BUTTON_HEIGHT = 20

local WIDGET_HEIGHT = 20

local LABEL_SPACING = 3

local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local LAST_ACTIVE_DROPDOWN

local MAX_WIDGETS_SHOWN = 14

GUI.Ignore = {
	["ui-profile"] = true,
}

-- Functions
local SetVariable = function(id, value)
	if GUI.Ignore[id] then
		return
	end
	
	local Name = vUI:GetActiveProfileName()
	
	if Name then
		if (value ~= Defaults[id]) then -- Only saving a value if it's different than default
			vUIProfiles[Name][id] = value
			
			vUI:UpdateProfileLastModified(Name)
		else
			vUIProfiles[Name][id] = nil
		end
	end
	
	Settings[id] = value
end

local HexToRGB = function(hex)
    return tonumber("0x"..sub(hex, 1, 2)) / 255, tonumber("0x"..sub(hex, 3, 4)) / 255, tonumber("0x"..sub(hex, 5, 6)) / 255
end

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)
	
	return floor(num * Mult + 0.5) / Mult
end

local TrimHex = function(s)
	local Subbed = match(s, "|c%x%x%x%x%x%x%x%x(.-)|r")
	
	return Subbed or s
end

local CreateID = function(text)
	text = gsub(text, "%s", "-")
	text = gsub(text, ":", "")
	text = lower(text)
	
	return text
end

local AnchorOnEnter = function(self)
	if (self.Tooltip and self.Tooltip ~= "") then
		local R, G, B = vUI:HexToRGB(Settings["ui-widget-font-color"])
		
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		
		GameTooltip:AddLine(self.Tooltip, R, G, B)
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
GUI.Widgets.CreateLine = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = CreateID(text)
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetScaledPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Text:SetScaledSize(GROUP_WIDTH - 6, WIDGET_HEIGHT)
	Anchor.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Text:SetJustifyH("LEFT")
	Anchor.Text:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], text))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

local CheckStringLength = UIParent:CreateFontString(nil, "OVERLAY")
CheckStringLength:SetScaledWidth(GROUP_WIDTH - 6)
CheckStringLength:SetJustifyH("LEFT")
CheckStringLength:SetWordWrap(true)
CheckStringLength:SetIndentedWordWrap(false)

--[[local CheckLineHeight = function(msg)
	WrapCheck:SetText(msg)
	
	local LineHeight = ceil(WrapCheck:GetStringWidth() / 383) * 12
	
	return LineHeight
end]]

GUI.Widgets.CreateMessage = function(self, text) -- Create as many lines as needed for the message
	if (not CheckStringLength.FontSet) then
		CheckStringLength:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
		CheckStringLength.FontSet = true
	end
	
	CheckStringLength:SetText(text)
	
	local NumLines = ceil(CheckStringLength:GetStringHeight() / Settings["ui-font-size"])
	local Message = text
	
	--[[for i = 1, NumLines do
		print()
	end]]
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = CreateID(text)
	
	--[[local Text = Anchor:CreateFontString(nil, "OVERLAY")
	Text:SetScaledPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	Text:SetText("|cFF" .. Settings["ui-widget-font-color"] .. text .. "|r")
	
	tinsert(self.Widgets, Anchor)]]
	
	return Text
end

GUI.Widgets.CreateDoubleLine = function(self, left, right)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = CreateID(left)
	
	left = tostring(left)
	right = tostring(right)
	
	Anchor.Left = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Left:SetScaledPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Left:SetScaledSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	Anchor.Left:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Left:SetJustifyH("LEFT")
	Anchor.Left:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], left))
	
	Anchor.Right = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Right:SetScaledPoint("RIGHT", Anchor, -HEADER_SPACING, 0)
	Anchor.Right:SetScaledSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	Anchor.Right:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Right:SetJustifyH("RIGHT")
	Anchor.Right:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], right))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Left
end

GUI.Widgets.CreateHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetScaledPoint("CENTER", Anchor, 0, 0)
	Anchor.Text:SetScaledHeight(WIDGET_HEIGHT)
	Anchor.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"]) -- 14
	Anchor.Text:SetJustifyH("CENTER")
	Anchor.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	-- Header Left Line
	local HeaderLeft = CreateFrame("Frame", nil, Anchor)
	HeaderLeft:SetScaledHeight(4)
	HeaderLeft:SetScaledPoint("LEFT", Anchor, 0, 0)
	HeaderLeft:SetScaledPoint("RIGHT", Anchor.Text, "LEFT", -SPACING, 0)
	HeaderLeft:SetBackdrop(vUI.BackdropAndBorder)
	HeaderLeft:SetBackdropColorHex("000000")
	HeaderLeft:SetBackdropBorderColorHex("000000")
	
	HeaderLeft.NewTexture = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.NewTexture:SetScaledPoint("TOPLEFT", HeaderLeft, 1, -1)
	HeaderLeft.NewTexture:SetScaledPoint("BOTTOMRIGHT", HeaderLeft, -1, 1)
	HeaderLeft.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	HeaderLeft.NewTexture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	-- Header Right Line
	local HeaderRight = CreateFrame("Frame", nil, Anchor)
	HeaderRight:SetScaledHeight(4)
	HeaderRight:SetScaledPoint("RIGHT", Anchor, 0, 0)
	HeaderRight:SetScaledPoint("LEFT", Anchor.Text, "RIGHT", SPACING, 0)
	HeaderRight:SetBackdrop(vUI.BackdropAndBorder)
	HeaderRight:SetBackdropColorHex("000000")
	HeaderRight:SetBackdropBorderColorHex("000000")
	
	HeaderRight.NewTexture = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.NewTexture:SetScaledPoint("TOPLEFT", HeaderRight, 1, -1)
	HeaderRight.NewTexture:SetScaledPoint("BOTTOMRIGHT", HeaderRight, -1, 1)
	HeaderRight.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	HeaderRight.NewTexture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Footer
GUI.Widgets.CreateFooter = function(self)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	-- Header Left Line
	local Line = CreateFrame("Frame", nil, Anchor)
	Line:SetScaledHeight(4)
	Line:SetScaledPoint("LEFT", Anchor, 0, 0)
	Line:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Line:SetBackdrop(vUI.BackdropAndBorder)
	Line:SetBackdropColorHex(Settings["ui-button-texture-color"])
	Line:SetBackdropBorderColor(0, 0, 0)
	
	Line.NewTexture = Line:CreateTexture(nil, "OVERLAY")
	Line.NewTexture:SetScaledPoint("TOPLEFT", Line, 1, -1)
	Line.NewTexture:SetScaledPoint("BOTTOMRIGHT", Line, -1, 1)
	Line.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Line.NewTexture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	tinsert(self.Widgets, Anchor)
	
	return Header
end

-- Button
local BUTTON_WIDTH = 130

local ButtonOnMouseUp = function(self)
	self.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	if self.ReloadFlag then
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel")
	elseif self.Hook then
		self.Hook()
	end
end

local ButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
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
	
	self.Button.MiddleText:SetTextColorHex("FFFFFF")
end

local ButtonDisable = function(self)
	self.Button:EnableMouse(false)
	
	self.Button.MiddleText:SetTextColorHex("A5A5A5")
end

GUI.Widgets.CreateButton = function(self, value, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = CreateID(value)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = ButtonEnable
	Anchor.Disable = ButtonDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Button = CreateFrame("Frame", nil, Anchor)
	Button:SetScaledSize(BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColorHex(Settings["ui-widget-bright-color"])
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnMouseUp", ButtonOnMouseUp)
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnEnter", ButtonWidgetOnEnter)
	Button:SetScript("OnLeave", ButtonWidgetOnLeave)
	Button.Hook = hook
	Button.RequiresReload = ButtonRequiresReload
	
	Button.Texture = Button:CreateTexture(nil, "BORDER")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetScaledPoint("CENTER", Button, "CENTER", 0, 0)
	Button.MiddleText:SetScaledSize(BUTTON_WIDTH - 6, WIDGET_HEIGHT)
	Button.MiddleText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText(value)
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetScaledSize(GROUP_WIDTH - BUTTON_WIDTH - 6, WIDGET_HEIGHT)
	Button.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Anchor.Button = Button
	
	tinsert(self.Widgets, Anchor)
	
	return Button
end

-- StatusBar
local STATUSBAR_WIDTH = 100

GUI.Widgets.CreateStatusBar = function(self, value, minvalue, maxvalue, label, tooltip, hook)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Backdrop = CreateFrame("Frame", nil, Anchor)
	Backdrop:SetScaledSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Backdrop:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Backdrop:SetBackdropColorHex(Settings["ui-window-main-color"])
	Backdrop:SetBackdropBorderColor(0, 0, 0)
	Backdrop.Value = value
	--Backdrop.Hook = hook
	
	Backdrop.BG = Backdrop:CreateTexture(nil, "ARTWORK")
	Backdrop.BG:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Backdrop.BG:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Backdrop.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Backdrop.BG:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	local Bar = CreateFrame("StatusBar", nil, Backdrop)
	Bar:SetScaledSize(STATUSBAR_WIDTH, WIDGET_HEIGHT)
	Bar:SetScaledPoint("TOPLEFT", Backdrop, 1, -1)
	Bar:SetScaledPoint("BOTTOMRIGHT", Backdrop, -1, 1)
	Bar:SetBackdrop(vUI.BackdropAndBorder)
	Bar:SetBackdropColor(0, 0, 0, 0)
	Bar:SetBackdropBorderColor(0, 0, 0, 0)
	Bar:SetStatusBarTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Bar:SetStatusBarColorHex(Settings["ui-widget-color"])
	Bar:SetMinMaxValues(minvalue, maxvalue)
	Bar:SetValue(value)
	Bar.Hook = hook
	Bar.Tooltip = tooltip
	
	Bar.Anim = CreateAnimationGroup(Bar):CreateAnimation("progress")
	Bar.Anim:SetEasing("in")
	Bar.Anim:SetDuration(0.15)
	
	Bar.Spark = Bar:CreateTexture(nil, "ARTWORK")
	Bar.Spark:SetScaledSize(1, WIDGET_HEIGHT - 2)
	Bar.Spark:SetScaledPoint("LEFT", Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	Bar.Spark:SetTexture(Media:GetTexture("Blank"))
	Bar.Spark:SetVertexColor(0, 0, 0)
	
	Bar.MiddleText = Bar:CreateFontString(nil, "ARTWORK")
	Bar.MiddleText:SetScaledPoint("CENTER", Bar, "CENTER", 0, 0)
	Bar.MiddleText:SetScaledSize(STATUSBAR_WIDTH - 6, WIDGET_HEIGHT)
	Bar.MiddleText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Bar.MiddleText:SetJustifyH("CENTER")
	Bar.MiddleText:SetText(value)
	
	Bar.Text = Bar:CreateFontString(nil, "OVERLAY")
	Bar.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Bar.Text:SetScaledSize(GROUP_WIDTH - STATUSBAR_WIDTH - 6, WIDGET_HEIGHT)
	Bar.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Bar.Text:SetJustifyH("LEFT")
	Bar.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
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
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel", nil, self.Value, self.ID)
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
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Checkbox = CreateFrame("Frame", nil, Anchor)
	Checkbox:SetScaledSize(CHECKBOX_WIDTH, WIDGET_HEIGHT)
	Checkbox:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Checkbox:SetBackdrop(vUI.BackdropAndBorder)
	Checkbox:SetBackdropColorHex(Settings["ui-window-main-color"])
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
	Checkbox.BG:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.BG:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.BG:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	Checkbox.Highlight = Checkbox:CreateTexture(nil, "OVERLAY")
	Checkbox.Highlight:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Highlight:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Highlight:SetTexture(Media:GetTexture("Blank"))
	Checkbox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Checkbox.Highlight:SetAlpha(0)
	
	Checkbox.Texture = Checkbox:CreateTexture(nil, "ARTWORK")
	Checkbox.Texture:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Texture:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Checkbox.Texture:SetVertexColorHex(Settings["ui-widget-color"])
	
	Checkbox.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Checkbox.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Checkbox.Text:SetScaledSize(GROUP_WIDTH - CHECKBOX_WIDTH - 6, WIDGET_HEIGHT)
	Checkbox.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Checkbox.Text:SetJustifyH("LEFT")
	Checkbox.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Checkbox.Hover = Checkbox:CreateTexture(nil, "HIGHLIGHT")
	Checkbox.Hover:SetScaledPoint("TOPLEFT", Checkbox, 1, -1)
	Checkbox.Hover:SetScaledPoint("BOTTOMRIGHT", Checkbox, -1, 1)
	Checkbox.Hover:SetVertexColorHex(Settings["ui-widget-bright-color"])
	Checkbox.Hover:SetTexture(Media:GetTexture("RenHorizonUp"))
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
		self.Thumb:SetScaledPoint("RIGHT", self, 0, 0)
		self.Move:SetOffset(-SWITCH_TRAVEL, 0)
		self.Value = false
	else
		self.Thumb:SetScaledPoint("LEFT", self, 0, 0)
		self.Move:SetOffset(SWITCH_TRAVEL, 0)
		self.Value = true
	end
	
	self.Move:Play()
	
	SetVariable(self.ID, self.Value)
	
	if self.ReloadFlag then
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel", nil, self.Value, self.ID)
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
	
	self.Switch.Flavor:SetVertexColorHex(Settings["ui-widget-color"])
end

local SwitchDisable = function(self)
	self.Switch:EnableMouse(false)
	self.Switch:EnableMouseWheel(false)
	
	self.Switch.Flavor:SetVertexColorHex("A5A5A5")
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
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = SwitchEnable
	Anchor.Disable = SwitchDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:SetScaledSize(SWITCH_WIDTH, WIDGET_HEIGHT)
	Switch:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Switch:SetBackdrop(vUI.BackdropAndBorder)
	Switch:SetBackdropColorHex(Settings["ui-window-main-color"])
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
	Switch.BG:SetScaledPoint("TOPLEFT", Switch, 1, -1)
	Switch.BG:SetScaledPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.BG:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.BG:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	Switch.Thumb = CreateFrame("Frame", nil, Switch)
	Switch.Thumb:SetScaledSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Switch.Thumb:SetBackdrop(vUI.BackdropAndBorder)
	Switch.Thumb:SetBackdropBorderColor(0, 0, 0)
	Switch.Thumb:SetBackdropColorHex(Settings["ui-widget-bright-color"])
	Switch.Thumb:SetScaledPoint(Switch.Value and "RIGHT" or "LEFT", Switch, 0, 0)
	
	Switch.ThumbTexture = Switch.Thumb:CreateTexture(nil, "ARTWORK")
	Switch.ThumbTexture:SetScaledSize(WIDGET_HEIGHT - 2, WIDGET_HEIGHT - 2)
	Switch.ThumbTexture:SetScaledPoint("TOPLEFT", Switch.Thumb, 1, -1)
	Switch.ThumbTexture:SetScaledPoint("BOTTOMRIGHT", Switch.Thumb, -1, 1)
	Switch.ThumbTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.ThumbTexture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Switch.Flavor = Switch:CreateTexture(nil, "ARTWORK")
	Switch.Flavor:SetScaledPoint("TOPLEFT", Switch, "TOPLEFT", 1, -1)
	Switch.Flavor:SetScaledPoint("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.Flavor:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Switch.Flavor:SetVertexColorHex(Settings["ui-widget-color"])
	
	Switch.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Switch.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Switch.Text:SetScaledSize(GROUP_WIDTH - SWITCH_WIDTH - 6, WIDGET_HEIGHT)
	Switch.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Switch.Text:SetJustifyH("LEFT")
	Switch.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Switch.Highlight = Switch:CreateTexture(nil, "HIGHLIGHT")
	Switch.Highlight:SetScaledPoint("TOPLEFT", Switch, 1, -1)
	Switch.Highlight:SetScaledPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.Highlight:SetTexture(Media:GetTexture("Blank"))
	Switch.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Switch.Highlight:SetAlpha(0)
	
	Switch.Move = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Move:SetEasing("in")
	Switch.Move:SetDuration(0.1)
	
	Anchor.Switch = Switch
	
	tinsert(self.Widgets, Anchor)
	
	return Switch
end

-- Input
function GUI:SetInputObject(input)
	local Text = input.ButtonText:GetText() or ""
	
	self.InputWindow.ActiveInput = input
	self.InputWindow.Input:SetText(Text)
	--self.InputWindow.Input:SetAutoFocus(true)
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
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", Input.Hook, "Cancel", nil, Text, Input.ID)
		elseif Input.Hook then
			Input.Hook(Text, Input.ID)
		end
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
	
	local Window = CreateFrame("Frame", nil, self)
	Window:SetScaledSize(300, 200)
	Window:SetScaledPoint("CENTER", UIParent, 0, 0)
	Window:SetBackdrop(vUI.BackdropAndBorder)
	Window:SetBackdropColorHex(Settings["ui-window-bg-color"])
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
	Window.Header = CreateFrame("Frame", nil, Window)
	Window.Header:SetScaledHeight(HEADER_HEIGHT)
	Window.Header:SetScaledPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetScaledPoint("TOPRIGHT", Window, -((SPACING + 2) + HEADER_HEIGHT), -SPACING)
	Window.Header:SetBackdrop(vUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetScaledPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetScaledPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	Window.Header.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF" .. Settings["ui-header-font-color"] .. Language["Input"] .. "|r")
	
	-- Close button
	Window.CloseButton = CreateFrame("Frame", nil, Window)
	Window.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.CloseButton:SetScaledPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	Window.CloseButton:SetBackdropColor(0, 0, 0, 0)
	Window.CloseButton:SetBackdropBorderColor(0, 0, 0)
	Window.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColorHex("C0392B") end)
	Window.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColorHex("EEEEEE") end)
	Window.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
		
		self:GetParent().FadeOut:Play()
	end)
	
	Window.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	Window.CloseButton.Texture = Window.CloseButton:CreateTexture(nil, "ARTWORK")
	Window.CloseButton.Texture:SetScaledPoint("TOPLEFT", Window.CloseButton, 1, -1)
	Window.CloseButton.Texture:SetScaledPoint("BOTTOMRIGHT", Window.CloseButton, -1, 1)
	Window.CloseButton.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Window.CloseButton.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	Window.CloseButton.Cross = Window.CloseButton:CreateTexture(nil, "OVERLAY")
	Window.CloseButton.Cross:SetPoint("CENTER", Window.CloseButton, 0, 0)
	Window.CloseButton.Cross:SetScaledSize(16, 16)
	Window.CloseButton.Cross:SetTexture(Media:GetTexture("Close"))
	Window.CloseButton.Cross:SetVertexColorHex("EEEEEE")
	
	Window.Inner = CreateFrame("Frame", nil, Window)
	Window.Inner:SetScaledPoint("TOPLEFT", Window.Header, "BOTTOMLEFT", 0, -2)
	Window.Inner:SetScaledPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetBackdrop(vUI.BackdropAndBorder)
	Window.Inner:SetBackdropColorHex(Settings["ui-window-main-color"])
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	Window.Input:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetScaledPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetScaledPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetFrameLevel(99)
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMultiLine(true)
	Window.Input:SetMaxLetters(255)
	Window.Input:SetCursorPosition(0)
	
	Window.Input:SetScript("OnEnterPressed", InputWindowOnEnterPressed)
	Window.Input:SetScript("OnEscapePressed", InputWindowOnEnterPressed)
	Window.Input:SetScript("OnMouseDown", InputWindowOnMouseDown)
	
	--[[ This just makes the animation look better. That's all. ಠ_ಠ
	Window.BlackTexture = Window:CreateTexture(nil, "BACKGROUND", -7)
	Window.BlackTexture:SetScaledPoint("TOPLEFT", Window, 0, 0)
	Window.BlackTexture:SetScaledPoint("BOTTOMRIGHT", Window, 0, 0)
	Window.BlackTexture:SetTexture(Media:GetTexture("Blank"))
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
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Input = CreateFrame("Frame", nil, Anchor)
	Input:SetScaledSize(INPUT_WIDTH, WIDGET_HEIGHT)
	Input:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Input:SetBackdrop(vUI.BackdropAndBorder)
	Input:SetBackdropColorHex(Settings["ui-widget-bg-color"])
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
	Input.Texture:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Texture:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Input.Texture:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	Input.Flash = Input:CreateTexture(nil, "OVERLAY")
	Input.Flash:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Flash:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Flash:SetTexture(Media:GetTexture("RenHorizonUp"))
	Input.Flash:SetVertexColorHex(Settings["ui-widget-color"])
	Input.Flash:SetAlpha(0)
	
	Input.Highlight = Input:CreateTexture(nil, "OVERLAY")
	Input.Highlight:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Highlight:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Highlight:SetTexture(Media:GetTexture("Blank"))
	Input.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Input.Highlight:SetAlpha(0)
	
	Input.ButtonText = Input:CreateFontString(nil, "OVERLAY")
	Input.ButtonText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Input.ButtonText:SetScaledSize(INPUT_WIDTH, WIDGET_HEIGHT)
	Input.ButtonText:SetScaledPoint("TOPLEFT", Input, SPACING, -SPACING)
	Input.ButtonText:SetScaledPoint("BOTTOMRIGHT", Input, -SPACING, SPACING)
	Input.ButtonText:SetJustifyH("LEFT")
	Input.ButtonText:SetText(value)
	
	Input.Text = Input:CreateFontString(nil, "OVERLAY")
	Input.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Input.Text:SetScaledSize(GROUP_WIDTH - INPUT_WIDTH - 6, WIDGET_HEIGHT)
	Input.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
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
	
	return Input
end

local InputButtonOnMouseUp = function(self)
	self.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	InputOnEnterPressed(self.Input)
end

local INPUT_BUTTON_WIDTH = (GROUP_WIDTH / 2) - (SPACING / 2)

GUI.Widgets.CreateInputWithButton = function(self, id, value, button, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Text = Anchor:CreateFontString(nil, "OVERLAY")
	Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Text:SetScaledSize(GROUP_WIDTH - 6, WIDGET_HEIGHT)
	Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Text:SetJustifyH("LEFT")
	Text:SetShadowColor(0, 0, 0)
	Text:SetShadowOffset(1, -1)
	Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	local Anchor2 = CreateFrame("Frame", nil, self)
	Anchor2:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor2.ID = id
	Anchor2.Text = label
	
	local Button = CreateFrame("Frame", nil, Anchor2)
	Button:SetScaledSize(INPUT_BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetScaledPoint("RIGHT", Anchor2, 0, 0)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColor(0.17, 0.17, 0.17)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript("OnMouseUp", InputButtonOnMouseUp)
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnEnter", ButtonWidgetOnEnter)
	Button:SetScript("OnLeave", ButtonWidgetOnLeave)
	Button.Tooltip = tooltip
	
	Button.Texture = Button:CreateTexture(nil, "BORDER")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetScaledPoint("CENTER", Button, "CENTER", 0, 0)
	Button.MiddleText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText(button)
	
	local Input = CreateFrame("Frame", nil, Anchor2)
	Input:SetScaledSize(INPUT_BUTTON_WIDTH, WIDGET_HEIGHT)
	Input:SetScaledPoint("LEFT", Anchor2, 0, 0)
	Input:SetBackdrop(vUI.BackdropAndBorder)
	Input:SetBackdropColorHex(Settings["ui-widget-bg-color"])
	Input:SetBackdropBorderColor(0, 0, 0)
	
	Input.Texture = Input:CreateTexture(nil, "ARTWORK")
	Input.Texture:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Texture:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Input.Texture:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	Input.Flash = Input:CreateTexture(nil, "OVERLAY")
	Input.Flash:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Flash:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Flash:SetTexture(Media:GetTexture("RenHorizonUp"))
	Input.Flash:SetVertexColorHex(Settings["ui-widget-color"])
	Input.Flash:SetAlpha(0)
	
	Input.Highlight = Input:CreateTexture(nil, "OVERLAY")
	Input.Highlight:SetScaledPoint("TOPLEFT", Input, 1, -1)
	Input.Highlight:SetScaledPoint("BOTTOMRIGHT", Input, -1, 1)
	Input.Highlight:SetTexture(Media:GetTexture("Blank"))
	Input.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Input.Highlight:SetAlpha(0)
	
	Input.Box = CreateFrame("EditBox", nil, Input)
	Input.Box:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Input.Box:SetScaledPoint("TOPLEFT", Input, SPACING, -2)
	Input.Box:SetScaledPoint("BOTTOMRIGHT", Input, -SPACING, 2)
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
		--self.ExportWindow.Input:SetCursorPosition()
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
	
	local Window = CreateFrame("Frame", nil, self)
	Window:SetScaledSize(300, 220)
	Window:SetScaledPoint("CENTER", UIParent, 0, 0)
	Window:SetBackdrop(vUI.BackdropAndBorder)
	Window:SetBackdropColorHex(Settings["ui-window-bg-color"])
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window)
	Window.Header:SetScaledHeight(HEADER_HEIGHT)
	Window.Header:SetScaledPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetScaledPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.Header:SetBackdrop(vUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetScaledPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetScaledPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	Window.Header.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Export string".."|r")
	
	-- Close button
	Window.Header.CloseButton = CreateFrame("Frame", nil, Window.Header)
	Window.Header.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.Header.CloseButton:SetScaledPoint("RIGHT", Window.Header, 0, 0)
	Window.Header.CloseButton:SetScript("OnEnter", function(self) self.Text:SetTextColor(1, 0, 0) end)
	Window.Header.CloseButton:SetScript("OnLeave", function(self) self.Text:SetTextColor(1, 1, 1) end)
	Window.Header.CloseButton:SetScript("OnMouseUp", function() GUI.ExportWindow:Hide() end)
	
	Window.Header.CloseButton.Text = Window.Header.CloseButton:CreateFontString(nil, "OVERLAY", 7)
	Window.Header.CloseButton.Text:SetScaledPoint("CENTER", Window.Header.CloseButton, 0, 0)
	Window.Header.CloseButton:SetFontInfo("PT Sans", 18)
	Window.Header.CloseButton.Text:SetJustifyH("CENTER")
	Window.Header.CloseButton.Text:SetText("×")
	
	Window.Inner = CreateFrame("Frame", nil, Window)
	Window.Inner:SetScaledPoint("TOPLEFT", Window.Header, "BOTTOMLEFT", 0, -2)
	Window.Inner:SetScaledPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetBackdrop(vUI.BackdropAndBorder)
	Window.Inner:SetBackdropColorHex(Settings["ui-window-main-color"])
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	Window.Input:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetScaledPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetScaledPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetFrameLevel(99)
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMultiLine(true)
	Window.Input:SetMaxLetters(255)
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
	
	local Profile = vUI:GetDecoded(Text)
	
	if Profile then
		print('something?')
		vUI:AddProfile(Profile)
	end
	
	self:SetText("")
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local ImportWindowOnMouseDown = function(self)
	self:HighlightText()
	self:SetAutoFocus(true)
end

GUI.CreateImportWindow = function(self)
	if self.ImportWindow then
		return self.ImportWindow
	end
	
	local Window = CreateFrame("Frame", nil, self)
	Window:SetScaledSize(300, 220)
	Window:SetScaledPoint("CENTER", UIParent, 0, 0)
	Window:SetBackdrop(vUI.BackdropAndBorder)
	Window:SetBackdropColorHex(Settings["ui-window-bg-color"])
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:SetFrameStrata("DIALOG")
	Window:SetMovable(true)
	Window:EnableMouse(true)
	Window:RegisterForDrag("LeftButton")
	Window:SetScript("OnDragStart", Window.StartMoving)
	Window:SetScript("OnDragStop", Window.StopMovingOrSizing)
	Window:Hide()
	
	-- Header
	Window.Header = CreateFrame("Frame", nil, Window)
	Window.Header:SetScaledHeight(HEADER_HEIGHT)
	Window.Header:SetScaledPoint("TOPLEFT", Window, SPACING, -SPACING)
	Window.Header:SetScaledPoint("TOPRIGHT", Window, -SPACING, -SPACING)
	Window.Header:SetBackdrop(vUI.BackdropAndBorder)
	Window.Header:SetBackdropColor(0, 0, 0)
	Window.Header:SetBackdropBorderColor(0, 0, 0)
	
	Window.HeaderTexture = Window.Header:CreateTexture(nil, "OVERLAY")
	Window.HeaderTexture:SetScaledPoint("TOPLEFT", Window.Header, 1, -1)
	Window.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", Window.Header, -1, 1)
	Window.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Window.HeaderTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	Window.Header.Text = Window.Header:CreateFontString(nil, "OVERLAY")
	Window.Header.Text:SetScaledPoint("LEFT", Window.Header, HEADER_SPACING, -1)
	Window.Header.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-header-font-size"])
	Window.Header.Text:SetJustifyH("LEFT")
	Window.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Import string".."|r")
	
	-- Close button
	Window.Header.CloseButton = CreateFrame("Frame", nil, Window.Header)
	Window.Header.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	Window.Header.CloseButton:SetScaledPoint("RIGHT", Window.Header, 0, 0)
	Window.Header.CloseButton:SetScript("OnEnter", function(self) self.Text:SetTextColor(1, 0, 0) end)
	Window.Header.CloseButton:SetScript("OnLeave", function(self) self.Text:SetTextColor(1, 1, 1) end)
	Window.Header.CloseButton:SetScript("OnMouseUp", function() GUI.ImportWindow:Hide() end)
	
	Window.Header.CloseButton.Text = Window.Header.CloseButton:CreateFontString(nil, "OVERLAY", 7)
	Window.Header.CloseButton.Text:SetScaledPoint("CENTER", Window.Header.CloseButton, 0, 0)
	Window.Header.CloseButton.Text:SetFontInfo("PT Sans", 18)
	Window.Header.CloseButton.Text:SetJustifyH("CENTER")
	Window.Header.CloseButton.Text:SetText("×")
	
	Window.Inner = CreateFrame("Frame", nil, Window)
	Window.Inner:SetScaledPoint("TOPLEFT", Window.Header, "BOTTOMLEFT", 0, -2)
	Window.Inner:SetScaledPoint("BOTTOMRIGHT", Window, -3, 3)
	Window.Inner:SetBackdrop(vUI.BackdropAndBorder)
	Window.Inner:SetBackdropColorHex(Settings["ui-window-main-color"])
	Window.Inner:SetBackdropBorderColor(0, 0, 0)
	
	Window.Input = CreateFrame("EditBox", nil, Window.Inner)
	Window.Input:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Window.Input:SetScaledPoint("TOPLEFT", Window.Inner, 3, -3)
	Window.Input:SetScaledPoint("BOTTOMRIGHT", Window.Inner, -3, 3)
	Window.Input:SetFrameStrata("DIALOG")
	Window.Input:SetFrameLevel(99)
	Window.Input:SetJustifyH("LEFT")
	Window.Input:SetAutoFocus(false)
	Window.Input:EnableKeyboard(true)
	Window.Input:EnableMouse(true)
	Window.Input:SetMultiLine(true)
	Window.Input:SetMaxLetters(255)
	Window.Input:SetCursorPosition(0)
	
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
	button.ArrowTop.Anim:SetChange(2)
	button.ArrowBottom.Anim:SetChange(6)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
end

local SetArrowDown = function(button)
	button.ArrowTop.Anim:SetChange(6)
	button.ArrowBottom.Anim:SetChange(2)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
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
	if self.ArrowBottom.Anim:IsPlaying() then
		return
	end
	
	self.Parent.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
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
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Parent.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)
	
	self.Highlight:SetAlpha(0)
	self.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	if self.GrandParent.SpecificType then
		SetVariable(self.ID, self.Key)
		
		self.GrandParent.Value = self.Key
		
		if self.GrandParent.ReloadFlag then
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.GrandParent.Hook, "Cancel", nil, self.Key, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Key, self.ID)
		end
	else
		SetVariable(self.ID, self.Value)
		
		self.GrandParent.Value = self.Value
		
		if self.GrandParent.ReloadFlag then
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.GrandParent.Hook, "Cancel", nil, self.Value, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Value, self.ID)
		end
	end
	
	if (self.GrandParent.SpecificType == "Texture") then
		self.GrandParent.Texture:SetTexture(Media:GetTexture(self.Key))
	elseif (self.GrandParent.SpecificType == "Font") then
		self.GrandParent.Current:SetFontInfo(self.Key, Settings["ui-font-size"])
	end
	
	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
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
	
	self.Dropdown.Current:SetTextColorHex("FFFFFF")
	
	self.Dropdown.Button.ArrowBottom:SetVertexColorHex(Settings["ui-widget-color"])
	self.Dropdown.Button.ArrowMiddle:SetVertexColorHex(Settings["ui-widget-color"])
	self.Dropdown.Button.ArrowTop:SetVertexColorHex(Settings["ui-widget-color"])
end

local DropdownDisable = function(self)
	self.Dropdown.Button:EnableMouse(false)
	
	self.Dropdown.Current:SetTextColorHex("A5A5A5")
	
	self.Dropdown.Button.ArrowBottom:SetVertexColorHex("A5A5A5")
	self.Dropdown.Button.ArrowMiddle:SetVertexColorHex("A5A5A5")
	self.Dropdown.Button.ArrowTop:SetVertexColorHex("A5A5A5")
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
				self[i]:SetScaledPoint("TOPLEFT", self, 0, 0)
				First = true
			else
				self[i]:SetScaledPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
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
	local MaxValue = (#self - (DROPDOWN_MAX_SHOWN - 1))
	local ScrollWidth = (WIDGET_HEIGHT / 2)
	
	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetScaledPoint("TOPLEFT", self, "TOPRIGHT", 2, 0)
	ScrollBar:SetScaledPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0)
	ScrollBar:SetScaledWidth(ScrollWidth)
	ScrollBar:SetThumbTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColorHex(Settings["ui-window-main-color"])
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	--ScrollBar:SetObeyStepOnDrag(true)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)
	
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetScaledSize(ScrollWidth, WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetScaledPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetScaledPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetScaledPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Progress:SetVertexColorHex(Settings["ui-widget-color"])
	
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)
	
	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetDropdownOffset(1)
	
	ScrollBar:Show()
	
	for i = 1, #self do
		self[i]:SetScaledWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	end
	
	self:SetScaledWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	self:SetScaledHeight(((WIDGET_HEIGHT - 1) * DROPDOWN_MAX_SHOWN) + 1)
end

local DropdownSort = function(self)
	tsort(self.Menu, function(a, b)
		return TrimHex(a.Key) < TrimHex(b.Key)
	end)
	
	for i = 1, #self.Menu do
		if (i == 1) then
			self.Menu[i]:SetScaledPoint("TOP", self.Menu, 0, 0)
		else
			self.Menu[i]:SetScaledPoint("TOP", self.Menu[i-1], "BOTTOM", 0, 1)
		end
	end
	
	self.Menu:SetScaledHeight(((WIDGET_HEIGHT - 1) * #self.Menu) + 1)
end

local DropdownCreateSelection = function(self, key, value)
	local MenuItem = CreateFrame("Frame", nil, self.Menu)
	MenuItem:SetScaledSize(DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	MenuItem:SetBackdrop(vUI.BackdropAndBorder)
	MenuItem:SetBackdropColorHex(Settings["ui-widget-bg-color"])
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
	MenuItem.Highlight:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Highlight:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Highlight:SetTexture(Media:GetTexture("Blank"))
	MenuItem.Highlight:SetVertexColor(1, 1, 1, 0.4)
	MenuItem.Highlight:SetAlpha(0)
	
	MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
	MenuItem.Texture:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Texture:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	MenuItem.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
	MenuItem.Selected:SetScaledPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Selected:SetScaledPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Selected:SetTexture(Media:GetTexture("RenHorizonUp"))
	MenuItem.Selected:SetVertexColorHex(Settings["ui-widget-color"])
	MenuItem.Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
	
	MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
	MenuItem.Text:SetScaledPoint("LEFT", MenuItem, 5, 0)
	MenuItem.Text:SetScaledSize((DROPDOWN_WIDTH - 6) - 12, WIDGET_HEIGHT)
	MenuItem.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
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
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = DropdownEnable
	Anchor.Disable = DropdownDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Dropdown = CreateFrame("Frame", nil, Anchor)
	Dropdown:SetScaledSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Dropdown:SetBackdrop(vUI.BackdropAndBorder)
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
	Dropdown.Texture:SetScaledPoint("TOPLEFT", Dropdown, 1, -1)
	Dropdown.Texture:SetScaledPoint("BOTTOMRIGHT", Dropdown, -1, 1)
	Dropdown.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:SetScaledPoint("LEFT", Dropdown, HEADER_SPACING, 0)
	Dropdown.Current:SetScaledSize(DROPDOWN_WIDTH - 20, Settings["ui-font-size"])
	Dropdown.Current:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Current:SetJustifyH("LEFT")
	
	Dropdown.Button = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Button:SetScaledSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown.Button:SetScaledPoint("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Button:SetBackdropColor(0, 0, 0, 0)
	Dropdown.Button:SetBackdropBorderColor(0, 0, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	Dropdown.Button:SetScript("OnEnter", DropdownOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownOnLeave)
	
	Dropdown.Button.Highlight = Dropdown.Button:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.Highlight:SetScaledPoint("TOPLEFT", Dropdown.Button, 1, -1)
	Dropdown.Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Dropdown.Button, -1, 1)
	Dropdown.Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Dropdown.Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Dropdown.Button.Highlight:SetAlpha(0)
	
	Dropdown.Text = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Dropdown.Text:SetScaledSize(GROUP_WIDTH - DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	Dropdown.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Text:SetJustifyH("LEFT")
	Dropdown.Text:SetScaledWidth(DROPDOWN_WIDTH - 4)
	Dropdown.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:SetScaledSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Dropdown.ArrowAnchor:SetScaledPoint("RIGHT", Dropdown, 0, 0)
	
	local ArrowMiddle = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowMiddle:SetScaledPoint("CENTER", Dropdown.ArrowAnchor, 0, 0)
	ArrowMiddle:SetScaledSize(4, 1)
	ArrowMiddle:SetTexture(Media:GetTexture("Blank"))
	ArrowMiddle:SetVertexColorHex(Settings["ui-widget-color"])
	
	ArrowMiddle.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowMiddle.BG:SetScaledPoint("TOPLEFT", ArrowMiddle, -1, 1)
	ArrowMiddle.BG:SetScaledPoint("BOTTOMRIGHT", ArrowMiddle, 1, -1)
	ArrowMiddle.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowMiddle.BG:SetVertexColor(0, 0, 0)
	
	local ArrowTop = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowTop:SetScaledSize(6, 1)
	ArrowTop:SetScaledPoint("BOTTOM", ArrowMiddle, "TOP", 0, 0)
	ArrowTop:SetTexture(Media:GetTexture("Blank"))
	ArrowTop:SetVertexColorHex(Settings["ui-widget-color"])
	
	ArrowTop.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowTop.BG:SetScaledPoint("TOPLEFT", ArrowTop, -1, 1)
	ArrowTop.BG:SetScaledPoint("BOTTOMRIGHT", ArrowTop, 1, -1)
	ArrowTop.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowTop.BG:SetVertexColor(0, 0, 0)
	
	ArrowTop.Anim = CreateAnimationGroup(ArrowTop):CreateAnimation("Width")
	ArrowTop.Anim:SetEasing("in")
	ArrowTop.Anim:SetDuration(0.15)
	
	local ArrowBottom = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowBottom:SetScaledSize(2, 1)
	ArrowBottom:SetScaledPoint("TOP", ArrowMiddle, "BOTTOM", 0, 0)
	ArrowBottom:SetTexture(Media:GetTexture("Blank"))
	ArrowBottom:SetVertexColorHex(Settings["ui-widget-color"])
	
	ArrowBottom.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowBottom.BG:SetScaledPoint("TOPLEFT", ArrowBottom, -1, 1)
	ArrowBottom.BG:SetScaledPoint("BOTTOMRIGHT", ArrowBottom, 1, -1)
	ArrowBottom.BG:SetTexture(Media:GetTexture("Blank"))
	ArrowBottom.BG:SetVertexColor(0, 0, 0)
	
	ArrowBottom.Anim = CreateAnimationGroup(ArrowBottom):CreateAnimation("Width")
	ArrowBottom.Anim:SetEasing("in")
	ArrowBottom.Anim:SetDuration(0.15)
	
	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:SetScaledPoint("TOPLEFT", Dropdown, "BOTTOMLEFT", SPACING, -2)
	Dropdown.Menu:SetScaledSize(DROPDOWN_WIDTH - (SPACING * 2), 1)
	Dropdown.Menu:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu:SetBackdropColorHex(Settings["ui-window-main-color"])
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu:EnableMouseWheel(true)
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)
	
	Dropdown.Button.ArrowBottom = ArrowBottom
	Dropdown.Button.ArrowMiddle = ArrowMiddle
	Dropdown.Button.ArrowTop = ArrowTop
	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown
	
	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)
	
	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in")
	Dropdown.Menu.FadeIn:SetDuration(0.15)
	Dropdown.Menu.FadeIn:SetChange(1)
	
	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu)
	Dropdown.Menu.BG:SetScaledPoint("BOTTOMLEFT", Dropdown.Menu, -SPACING, -SPACING)
	Dropdown.Menu.BG:SetScaledPoint("TOPRIGHT", Dropdown, "BOTTOMRIGHT", 0, 1)
	Dropdown.Menu.BG:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu.BG:SetBackdropColorHex(Settings["ui-window-bg-color"])
	Dropdown.Menu.BG:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu.BG:EnableMouse(true)
	Dropdown.Menu.BG:SetScript("OnMouseWheel", function() end) -- Just to prevent misclicks from going through the frame
	
	for Key, Value in pairs(values) do
		local MenuItem = Dropdown:CreateSelection(Key, Value)
		
		if (specific == "Texture") then
			MenuItem.Texture:SetTexture(Media:GetTexture(Key))
		elseif (specific == "Font") then
			MenuItem.Text:SetFontInfo(Key, 12)
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
		Dropdown.Texture:SetTexture(Media:GetTexture(value))
	elseif (specific == "Font") then
		Dropdown.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
		Dropdown.Current:SetFontInfo(Settings[id], Settings["ui-font-size"])
	else
		Dropdown.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	end
	
	if (#Dropdown.Menu > DROPDOWN_MAX_SHOWN) then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:SetScaledHeight(((WIDGET_HEIGHT - 1) * #Dropdown.Menu) + 1)
	end
	
	Anchor.Dropdown = Dropdown
	
	if self.Widgets then
		tinsert(self.Widgets, Anchor)
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
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel", nil, Value, self.ID)
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
	
	self.Slider.EditBox:SetTextColorHex("FFFFFF")
	self.Slider.Progress:SetVertexColorHex(Settings["ui-widget-color"])
end

local SliderDisable = function(self)
	self.Slider:EnableMouse(false)
	self.Slider:EnableMouseWheel(false)
	
	self.Slider.EditBox:EnableKeyboard(false)
	self.Slider.EditBox:EnableMouse(false)
	self.Slider.EditBox:EnableMouseWheel(false)
	
	self.Slider.EditBox:SetTextColorHex("A5A5A5")
	self.Slider.Progress:SetVertexColorHex("A5A5A5")
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
	Anchor:SetScaledSize(GROUP_WIDTH, DROPDOWN_HEIGHT)
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
	
	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:SetScaledSize(EDITBOX_WIDTH, WIDGET_HEIGHT)
	EditBox:SetScaledPoint("RIGHT", Anchor, 0, 0)
	EditBox:SetBackdrop(vUI.BackdropAndBorder)
	EditBox:SetBackdropColorHex(Settings["ui-window-main-color"])
	EditBox:SetBackdropBorderColor(0, 0, 0)
	
	EditBox.Texture = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Texture:SetScaledPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Texture:SetScaledPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	EditBox.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetScaledPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Highlight:SetScaledPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Highlight:SetTexture(Media:GetTexture("Blank"))
	EditBox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	EditBox.Highlight:SetAlpha(0)
	
	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	EditBox.Box:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	EditBox.Box:SetScaledPoint("TOPLEFT", EditBox, SPACING, -2)
	EditBox.Box:SetScaledPoint("BOTTOMRIGHT", EditBox, -SPACING, 2)
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
	
	local Slider = CreateFrame("Slider", nil, Anchor)
	Slider:SetScaledPoint("RIGHT", EditBox, "LEFT", -2, 0)
	Slider:SetScaledSize(SLIDER_WIDTH, WIDGET_HEIGHT)
	Slider:SetThumbTexture(Media:GetTexture("Blank"))
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(step)
	Slider:SetBackdrop(vUI.BackdropAndBorder)
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
	Slider.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Slider.Text:SetScaledSize(GROUP_WIDTH - SLIDER_WIDTH - EDITBOX_WIDTH - 6, WIDGET_HEIGHT)
	Slider.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Slider.Text:SetJustifyH("LEFT")
	Slider.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Slider.TrackTexture = Slider:CreateTexture(nil, "ARTWORK")
	Slider.TrackTexture:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.TrackTexture:SetScaledPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.TrackTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.TrackTexture:SetVertexColorHex(Settings["ui-widget-bg-color"])
	
	local Thumb = Slider:GetThumbTexture()
	Thumb:SetScaledSize(8, WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture("Blank"))
	Thumb:SetVertexColor(0, 0, 0)
	
	Slider.NewThumb = CreateFrame("Frame", nil, Slider)
	Slider.NewThumb:SetScaledPoint("TOPLEFT", Thumb, 0, -1)
	Slider.NewThumb:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 1)
	Slider.NewThumb:SetBackdrop(vUI.BackdropAndBorder)
	Slider.NewThumb:SetBackdropColorHex(Settings["ui-widget-bg-color"])
	Slider.NewThumb:SetBackdropBorderColor(0, 0, 0)
	
	Slider.NewThumb.Texture = Slider.NewThumb:CreateTexture(nil, "OVERLAY")
	Slider.NewThumb.Texture:SetScaledPoint("TOPLEFT", Slider.NewThumb, 1, 0)
	Slider.NewThumb.Texture:SetScaledPoint("BOTTOMRIGHT", Slider.NewThumb, -1, 0)
	Slider.NewThumb.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.NewThumb.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.Progress:SetScaledPoint("BOTTOMRIGHT", Slider.NewThumb.Texture, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Slider.Progress:SetVertexColorHex(Settings["ui-widget-color"])
	
	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY", 8)
	Slider.Highlight:SetScaledPoint("TOPLEFT", Slider, 1, -1)
	Slider.Highlight:SetScaledPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.Highlight:SetTexture(Media:GetTexture("Blank"))
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
	GUI.ColorPicker.Transition:SetChange(HexToRGB(self.Value))
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
	self.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	local Active = self:GetParent().Active
	
	if GUI.ColorPicker.Selected then
		Active.Transition:SetChange(HexToRGB(GUI.ColorPicker.Selected))
		Active.Transition:Play()
		
		Active.MiddleText:SetText("#"..upper(GUI.ColorPicker.Selected))
		Active.Value = GUI.ColorPicker.Selected
		
		SetVariable(Active.ID, Active.Value)
		
		if Active.ReloadFlag then
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", Active.Hook, "Cancel", nil, Active.Value, Active.ID)
		elseif Active.Hook then
			Active.Hook(Active.Value, Active.ID)
		end
	end
	
	GUI.ColorPicker.FadeOut:Play()
end

local ColorPickerCancel = function(self)
	self.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
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
		
		GUI.ColorPicker.Transition:SetChange(HexToRGB(Value))
		GUI.ColorPicker.Selected = Value
	elseif (Value and Value == "CLASS") then
		local ClassColor = RAID_CLASS_COLORS[vUI.UserClass]
		local ClassHex = vUI:RGBToHex(ClassColor.r, ClassColor.g, ClassColor.b)
		
		self:SetText("#"..upper(ClassHex))
		
		GUI.ColorPicker.Transition:SetChange(HexToRGB(ClassHex))
		GUI.ColorPicker.Selected = ClassHex
	else
		vUI:print(format('Invalid hex code "%s".', Value))
		
		self:SetText("#" .. GUI.ColorPicker.Active.Value)
		
		GUI.ColorPicker.Transition:SetChange(HexToRGB(GUI.ColorPicker.Active.Value))
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
	local R, G, B = HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local UpdateColorPalette = function(value)
	GUI.ColorPicker:SetColorPalette(value)
end

local UpdateColorPickerTexture = function(value)
	local Texture = Media:GetTexture(value)
	
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
	
	local ColorPicker = CreateFrame("Frame", "vUIColorPicker", GUI)
	ColorPicker:SetScaledSize(388, 290)
	ColorPicker:SetScaledPoint("CENTER", GUI, 0, 50)
	ColorPicker:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker:SetBackdropColorHex(Settings["ui-window-main-color"])
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
	ColorPicker.Header = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Header:SetScaledHeight(HEADER_HEIGHT)
	ColorPicker.Header:SetScaledPoint("TOPLEFT", ColorPicker, 2, -2)
	ColorPicker.Header:SetScaledPoint("TOPRIGHT", ColorPicker, -(HEADER_HEIGHT + 2), -2)
	ColorPicker.Header:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Header:SetBackdropColor(0, 0, 0)
	ColorPicker.Header:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.HeaderTexture = ColorPicker.Header:CreateTexture(nil, "OVERLAY")
	ColorPicker.HeaderTexture:SetScaledPoint("TOPLEFT", ColorPicker.Header, 1, -1)
	ColorPicker.HeaderTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Header, -1, 1)
	ColorPicker.HeaderTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.HeaderTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ColorPicker.Header.Text = ColorPicker.Header:CreateFontString(nil, "OVERLAY")
	ColorPicker.Header.Text:SetScaledPoint("LEFT", ColorPicker.Header, HEADER_SPACING, -1)
	ColorPicker.Header.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-header-font-size"])
	ColorPicker.Header.Text:SetJustifyH("LEFT")
	ColorPicker.Header.Text:SetText("|cFF"..Settings["ui-header-font-color"].."Select a color".."|r")
	
	-- Close button
	ColorPicker.CloseButton = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	ColorPicker.CloseButton:SetScaledPoint("LEFT", ColorPicker.Header, "RIGHT", 2, 0)
	ColorPicker.CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CloseButton:SetBackdropColor(0, 0, 0, 0)
	ColorPicker.CloseButton:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColorHex("C0392B") end)
	ColorPicker.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColorHex("EEEEEE") end)
	ColorPicker.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
		
		self:GetParent().FadeOut:Play()
	end)
	
	ColorPicker.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	ColorPicker.CloseButton.Texture = ColorPicker.CloseButton:CreateTexture(nil, "ARTWORK")
	ColorPicker.CloseButton.Texture:SetScaledPoint("TOPLEFT", ColorPicker.CloseButton, 1, -1)
	ColorPicker.CloseButton.Texture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CloseButton, -1, 1)
	ColorPicker.CloseButton.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.CloseButton.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ColorPicker.CloseButton.Cross = ColorPicker.CloseButton:CreateTexture(nil, "OVERLAY")
	ColorPicker.CloseButton.Cross:SetPoint("CENTER", ColorPicker.CloseButton, 0, 0)
	ColorPicker.CloseButton.Cross:SetScaledSize(16, 16)
	ColorPicker.CloseButton.Cross:SetTexture(Media:GetTexture("Close"))
	ColorPicker.CloseButton.Cross:SetVertexColorHex("EEEEEE")
	
	-- Selection parent
	ColorPicker.SwatchParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.SwatchParent:SetScaledPoint("TOPLEFT", ColorPicker.Header, "BOTTOMLEFT", 0, -2)
	ColorPicker.SwatchParent:SetScaledPoint("TOPRIGHT", ColorPicker.CloseButton, "BOTTOMRIGHT", 0, -2)
	ColorPicker.SwatchParent:SetScaledHeight((SWATCH_SIZE * MAX_SWATCHES_Y) - SPACING)
	ColorPicker.SwatchParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.SwatchParent:SetBackdropColorHex(Settings["ui-window-main-color"])
	ColorPicker.SwatchParent:SetBackdropBorderColor(0, 0, 0)
	
	-- Current
	ColorPicker.Current = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Current:SetScaledSize((390 / 3), 20)
	ColorPicker.Current:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent, "BOTTOMLEFT", 0, -2)
	ColorPicker.Current:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Current:SetBackdropColor(0, 0, 0)
	ColorPicker.Current:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentTexture = ColorPicker.Current:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentTexture:SetScaledPoint("TOPLEFT", ColorPicker.Current, 1, -1)
	ColorPicker.CurrentTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Current, -1, 1)
	ColorPicker.CurrentTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.CurrentTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ColorPicker.CurrentText = ColorPicker.Current:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentText:SetScaledPoint("CENTER", ColorPicker.Current, HEADER_SPACING, -1)
	ColorPicker.CurrentText:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.CurrentText:SetJustifyH("CENTER")
	ColorPicker.CurrentText:SetText(Language["Current"])
	ColorPicker.CurrentText:SetTextColorHex(Settings["ui-header-font-color"])
	
	ColorPicker.CurrentHex = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CurrentHex:SetScaledSize(108, 20)
	ColorPicker.CurrentHex:SetScaledPoint("TOPLEFT", ColorPicker.Current, "BOTTOMLEFT", 0, -2)
	ColorPicker.CurrentHex:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CurrentHex:SetBackdropColor(0, 0, 0)
	ColorPicker.CurrentHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CurrentHexTexture = ColorPicker.CurrentHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.CurrentHexTexture:SetScaledPoint("TOPLEFT", ColorPicker.CurrentHex, 1, -1)
	ColorPicker.CurrentHexTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CurrentHex, -1, 1)
	ColorPicker.CurrentHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.CurrentHexTexture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	ColorPicker.CurrentHexText = ColorPicker.CurrentHex:CreateFontString(nil, "OVERLAY")
	ColorPicker.CurrentHexText:SetScaledPoint("CENTER", ColorPicker.CurrentHex, 0, 0)
	ColorPicker.CurrentHexText:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.CurrentHexText:SetJustifyH("CENTER")
	
	ColorPicker.CompareCurrentParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CompareCurrentParent:SetScaledSize(20, 20)
	ColorPicker.CompareCurrentParent:SetScaledPoint("LEFT", ColorPicker.CurrentHex, "RIGHT", 2, 0)
	ColorPicker.CompareCurrentParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CompareCurrentParent:SetBackdropColorHex(Settings["ui-window-bg-color"])
	ColorPicker.CompareCurrentParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareCurrent = ColorPicker.CompareCurrentParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareCurrent:SetScaledPoint("TOPLEFT", ColorPicker.CompareCurrentParent, 1, -1)
	ColorPicker.CompareCurrent:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CompareCurrentParent, -1, 1)
	ColorPicker.CompareCurrent:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	-- New
	ColorPicker.New = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.New:SetScaledSize((390 / 3), 20)
	ColorPicker.New:SetScaledPoint("TOPLEFT", ColorPicker.Current, "TOPRIGHT", 2, 0)
	ColorPicker.New:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.New:SetBackdropColor(0, 0, 0)
	ColorPicker.New:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewTexture = ColorPicker.New:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewTexture:SetScaledPoint("TOPLEFT", ColorPicker.New, 1, -1)
	ColorPicker.NewTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.New, -1, 1)
	ColorPicker.NewTexture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	ColorPicker.NewTexture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	ColorPicker.NewText = ColorPicker.New:CreateFontString(nil, "OVERLAY")
	ColorPicker.NewText:SetScaledPoint("CENTER", ColorPicker.New, 0, -1)
	ColorPicker.NewText:SetFontInfo(Settings["ui-header-font"], Settings["ui-font-size"])
	ColorPicker.NewText:SetJustifyH("CENTER")
	ColorPicker.NewText:SetText(Language["New"])
	ColorPicker.NewText:SetTextColorHex(Settings["ui-header-font-color"])
	
	ColorPicker.NewHex = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.NewHex:SetScaledSize(108, 20)
	ColorPicker.NewHex:SetScaledPoint("TOPRIGHT", ColorPicker.New, "BOTTOMRIGHT", 0, -2)
	ColorPicker.NewHex:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.NewHex:SetBackdropColor(0, 0, 0)
	ColorPicker.NewHex:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.NewHexTexture = ColorPicker.NewHex:CreateTexture(nil, "OVERLAY")
	ColorPicker.NewHexTexture:SetScaledPoint("TOPLEFT", ColorPicker.NewHex, 1, -1)
	ColorPicker.NewHexTexture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.NewHex, -1, 1)
	ColorPicker.NewHexTexture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ColorPicker.NewHexTexture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	ColorPicker.NewHexText = CreateFrame("EditBox", nil, ColorPicker.NewHex)
	ColorPicker.NewHexText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	ColorPicker.NewHexText:SetScaledPoint("TOPLEFT", ColorPicker.NewHex, SPACING, -2)
	ColorPicker.NewHexText:SetScaledPoint("BOTTOMRIGHT", ColorPicker.NewHex, -SPACING, 2)
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
	
	ColorPicker.CompareNewParent = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.CompareNewParent:SetScaledSize(20, 20)
	ColorPicker.CompareNewParent:SetScaledPoint("RIGHT", ColorPicker.NewHex, "LEFT", -2, 0)
	ColorPicker.CompareNewParent:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.CompareNewParent:SetBackdropColorHex(Settings["ui-window-bg-color"])
	ColorPicker.CompareNewParent:SetBackdropBorderColor(0, 0, 0)
	
	ColorPicker.CompareNew = ColorPicker.CompareNewParent:CreateTexture(nil, "OVERLAY")
	ColorPicker.CompareNew:SetScaledSize(ColorPicker.CompareNewParent:GetWidth() - 2, 19)
	ColorPicker.CompareNew:SetScaledPoint("TOPLEFT", ColorPicker.CompareNewParent, 1, -1)
	ColorPicker.CompareNew:SetScaledPoint("BOTTOMRIGHT", ColorPicker.CompareNewParent, -1, 1)
	ColorPicker.CompareNew:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	
	ColorPicker.Transition = CreateAnimationGroup(ColorPicker.CompareNew):CreateAnimation("Color")
	ColorPicker.Transition:SetColorType("vertex")
	ColorPicker.Transition:SetEasing("in")
	ColorPicker.Transition:SetDuration(0.15)
	
	-- Accept
	ColorPicker.Accept = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Accept:SetScaledSize((390 / 3) - (SPACING * 3) + 1, 20)
	ColorPicker.Accept:SetScaledPoint("TOPLEFT", ColorPicker.New, "TOPRIGHT", 2, 0)
	ColorPicker.Accept:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Accept:SetBackdropColor(0, 0, 0)
	ColorPicker.Accept:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Accept:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Accept:SetScript("OnMouseUp", ColorPickerAccept)
	ColorPicker.Accept:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Accept:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Accept.Texture = ColorPicker.Accept:CreateTexture(nil, "ARTWORK")
	ColorPicker.Accept.Texture:SetScaledPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Texture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Accept.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	ColorPicker.Accept.Highlight = ColorPicker.Accept:CreateTexture(nil, "OVERLAY")
	ColorPicker.Accept.Highlight:SetScaledPoint("TOPLEFT", ColorPicker.Accept, 1, -1)
	ColorPicker.Accept.Highlight:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Accept, -1, 1)
	ColorPicker.Accept.Highlight:SetTexture(Media:GetTexture("Blank"))
	ColorPicker.Accept.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Accept.Highlight:SetAlpha(0)
	
	ColorPicker.AcceptText = ColorPicker.Accept:CreateFontString(nil, "OVERLAY")
	ColorPicker.AcceptText:SetScaledPoint("CENTER", ColorPicker.Accept, 0, 0)
	ColorPicker.AcceptText:SetFontInfo(Settings["ui-button-font"], Settings["ui-font-size"])
	ColorPicker.AcceptText:SetJustifyH("CENTER")
	ColorPicker.AcceptText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Accept"].."|r")
	
	-- Cancel
	ColorPicker.Cancel = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.Cancel:SetScaledSize((390 / 3) - (SPACING * 3) + 1, 20)
	ColorPicker.Cancel:SetScaledPoint("TOPLEFT", ColorPicker.Accept, "BOTTOMLEFT", 0, -2)
	ColorPicker.Cancel:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.Cancel:SetBackdropColor(0, 0, 0)
	ColorPicker.Cancel:SetBackdropBorderColor(0, 0, 0)
	ColorPicker.Cancel:SetScript("OnMouseDown", SwatchButtonOnMouseDown)
	ColorPicker.Cancel:SetScript("OnMouseUp", ColorPickerCancel)
	ColorPicker.Cancel:SetScript("OnEnter", ColorPickerOnEnter)
	ColorPicker.Cancel:SetScript("OnLeave", ColorPickerOnLeave)
	
	ColorPicker.Cancel.Texture = ColorPicker.Cancel:CreateTexture(nil, "ARTWORK")
	ColorPicker.Cancel.Texture:SetScaledPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Texture:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	ColorPicker.Cancel.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	ColorPicker.Cancel.Highlight = ColorPicker.Cancel:CreateTexture(nil, "OVERLAY")
	ColorPicker.Cancel.Highlight:SetScaledPoint("TOPLEFT", ColorPicker.Cancel, 1, -1)
	ColorPicker.Cancel.Highlight:SetScaledPoint("BOTTOMRIGHT", ColorPicker.Cancel, -1, 1)
	ColorPicker.Cancel.Highlight:SetTexture(Media:GetTexture("Blank"))
	ColorPicker.Cancel.Highlight:SetVertexColor(1, 1, 1, 0.4)
	ColorPicker.Cancel.Highlight:SetAlpha(0)
	
	ColorPicker.CancelText = ColorPicker.Cancel:CreateFontString(nil, "OVERLAY")
	ColorPicker.CancelText:SetScaledPoint("CENTER", ColorPicker.Cancel, 0, 0)
	ColorPicker.CancelText:SetFontInfo(Settings["ui-button-font"], Settings["ui-font-size"])
	ColorPicker.CancelText:SetJustifyH("CENTER")
	ColorPicker.CancelText:SetText("|cFF"..Settings["ui-button-font-color"]..Language["Cancel"].."|r")
	
	ColorPicker.BG = CreateFrame("Frame", nil, ColorPicker)
	ColorPicker.BG:SetScaledPoint("TOPLEFT", ColorPicker.Header, -3, 3)
	ColorPicker.BG:SetScaledPoint("BOTTOMRIGHT", ColorPicker, 3, 0)
	ColorPicker.BG:SetBackdrop(vUI.BackdropAndBorder)
	ColorPicker.BG:SetBackdropColorHex(Settings["ui-window-bg-color"])
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
	
	local PaletteDropdown = GUI.Widgets.CreateDropdown(ColorPicker, "ui-picker-palette", Settings["ui-picker-palette"], Media:GetPaletteList(), "Set Palette", "", UpdateColorPalette, "Palette")
	PaletteDropdown:ClearAllPoints()
	PaletteDropdown:SetScaledPoint("BOTTOMLEFT", ColorPicker, 2, 3)
	PaletteDropdown:GetParent():SetScaledPoint("BOTTOMLEFT", ColorPicker, 0, 3)
	PaletteDropdown.Text:ClearAllPoints()
	PaletteDropdown.Text:SetScaledPoint("LEFT", PaletteDropdown, "RIGHT", LABEL_SPACING, 0)
	
	local Palette = Media:GetPalette(Settings["ui-picker-palette"])
	
	ColorPicker.SetColorPalette = function(self, name)
		local Palette = Media:GetPalette(name)
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
				
				Swatch.Texture:SetVertexColorHex(Swatch.Value)
			end
		end
	end
	
	for i = 1, MAX_SWATCHES_Y do
		for j = 1, MAX_SWATCHES_X do
			local Swatch = CreateFrame("Frame", nil, ColorPicker)
			Swatch:SetScaledSize(SWATCH_SIZE, SWATCH_SIZE)
			Swatch:SetBackdrop(vUI.BackdropAndBorder)
			Swatch:SetBackdropColorHex(Settings["ui-window-main-color"])
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
			Swatch.Texture:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Texture:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
			Swatch.Texture:SetVertexColorHex(Swatch.Value)
			
			Swatch.Highlight = CreateFrame("Frame", nil, Swatch)
			Swatch.Highlight:SetBackdrop(vUI.Outline)
			Swatch.Highlight:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
			Swatch.Highlight:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
			Swatch.Highlight:SetBackdropColor(0, 0, 0)
			Swatch.Highlight:SetBackdropBorderColor(1, 1, 1)
			Swatch.Highlight:SetAlpha(0)
			
			if (not ColorPicker.SwatchParent[i]) then
				ColorPicker.SwatchParent[i] = {}
			end
			
			if (i == 1) then
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent, 3, -3)
				else
					Swatch:SetScaledPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			else
				if (j == 1) then
					Swatch:SetScaledPoint("TOPLEFT", ColorPicker.SwatchParent[i-1][1], "BOTTOMLEFT", 0, 1)
				else
					Swatch:SetScaledPoint("LEFT", ColorPicker.SwatchParent[i][j-1], "RIGHT", -1, 0)
				end
			end
			
			ColorPicker.SwatchParent[i][j] = Swatch
		end
	end
	
	GUI.ColorPicker = ColorPicker
end

local SetSwatchObject = function(active)
	GUI.ColorPicker.Active = active
	
	GUI.ColorPicker.CompareCurrent:SetVertexColorHex(active.Value)
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
	Anchor:SetScaledSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Swatch = CreateFrame("Frame", nil, Anchor)
	Swatch:SetScaledSize(SWATCH_SIZE, SWATCH_SIZE)
	Swatch:SetScaledPoint("RIGHT", Anchor, 0, 0)
	Swatch:SetBackdrop(vUI.BackdropAndBorder)
	Swatch:SetBackdropColorHex(Settings["ui-window-main-color"])
	Swatch:SetBackdropBorderColor(0, 0, 0)
	
	Swatch.Texture = Swatch:CreateTexture(nil, "OVERLAY")
	Swatch.Texture:SetScaledPoint("TOPLEFT", Swatch, 1, -1)
	Swatch.Texture:SetScaledPoint("BOTTOMRIGHT", Swatch, -1, 1)
	Swatch.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Swatch.Texture:SetVertexColorHex(value)
	
	local Button = CreateFrame("Frame", nil, Anchor)
	Button:SetScaledSize(COLOR_WIDTH, WIDGET_HEIGHT)
	Button:SetScaledPoint("RIGHT", Swatch, "LEFT", -2, 0)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColorHex(Settings["ui-window-main-color"])
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
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Texture = Button:CreateTexture(nil, "ARTWORK")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Button.Texture:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	Button.Transition = CreateAnimationGroup(Swatch.Texture):CreateAnimation("Color")
	Button.Transition:SetColorType("vertex")
	Button.Transition:SetEasing("in")
	Button.Transition:SetDuration(0.15)
	
	Button.MiddleText = Button:CreateFontString(nil, "OVERLAY")
	Button.MiddleText:SetScaledPoint("CENTER", Button, 0, 0)
	Button.MiddleText:SetScaledSize(COLOR_WIDTH - 6, WIDGET_HEIGHT)
	Button.MiddleText:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.MiddleText:SetJustifyH("CENTER")
	Button.MiddleText:SetText("#"..upper(value))
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Button.Text:SetScaledSize(GROUP_WIDTH - COLOR_WIDTH - SWATCH_SIZE - 6, WIDGET_HEIGHT)
	Button.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-font-size"])
	Button.Text:SetJustifyH("LEFT")
	Button.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	tinsert(self.Widgets, Anchor)
	
	return Button
end

-- GUI
local ButtonOnEnter = function(self)
	self.Text:SetTextColor(1, 1, 0)
end

local ButtonOnLeave = function(self)
	self.Text:SetTextColor(1, 1, 1)
end

local DisableScrolling = function(self)
	self.ScrollingDisabled = true
end

local Scroll = function(self)
	local FirstLeft
	local FirstRight
	local Offset = self.LeftWidgetsBG.ScrollingDisabled and 1 or self.Offset
	
	for i = 1, self.WidgetCount do
		if self.LeftWidgets[i] then
			self.LeftWidgets[i]:ClearAllPoints()
			
			if (i >= Offset) and (i <= Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not FirstLeft) then
					self.LeftWidgets[i]:SetScaledPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
					FirstLeft = i
				else
					self.LeftWidgets[i]:SetScaledPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.LeftWidgets[i]:Show()
			else
				self.LeftWidgets[i]:Hide()
			end
		end
	end
	
	Offset = self.RightWidgetsBG.ScrollingDisabled and 1 or self.Offset
	
	for i = 1, self.WidgetCount do
		if self.RightWidgets[i] then
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i >= Offset) and (i <= Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not FirstRight) then
					self.RightWidgets[i]:SetScaledPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
					FirstRight = i
				else
					self.RightWidgets[i]:SetScaledPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.RightWidgets[i]:Show()
			else
				self.RightWidgets[i]:Hide()
			end
		end
	end
end

local SetOffsetByDelta = function(self, delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (self.WidgetCount - (MAX_WIDGETS_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	self:SetOffsetByDelta(delta)
	self:Scroll()
	self.ScrollBar:SetValue(self.Offset)
end

local SetWindowOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.WidgetCount - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:Scroll()
end

local WindowScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()
	
	Parent.Offset = Round(self:GetValue())
	
	Parent:Scroll()
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local NoScroll = function() end -- Just to prevent zooming while we're working in the GUI

local AddWindowScrollBar = function(self)
	local LeftMaxValue = (#self.LeftWidgets - (MAX_WIDGETS_SHOWN - 1))
	local RightMaxValue = (#self.RightWidgets - (MAX_WIDGETS_SHOWN - 1))
	
	self.MaxScroll = max(LeftMaxValue, RightMaxValue, 1)
	self.WidgetCount = max(#self.LeftWidgets, #self.RightWidgets)
	
	self.ScrollParent = CreateFrame("Frame", nil, self)
	self.ScrollParent:SetScaledPoint("TOPRIGHT", self, 0, 0)
	self.ScrollParent:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.ScrollParent:SetScaledWidth(WIDGET_HEIGHT)
	self.ScrollParent:SetBackdrop(vUI.BackdropAndBorder)
	self.ScrollParent:SetBackdropColorHex(Settings["ui-window-main-color"])
	self.ScrollParent:SetBackdropBorderColor(0, 0, 0)
	
	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetScaledPoint("TOPLEFT", self.ScrollParent, 3, -3)
	ScrollBar:SetScaledPoint("BOTTOMRIGHT", self.ScrollParent, -3, 3)
	ScrollBar:SetThumbTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColorHex(Settings["ui-widget-bg-color"])
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, self.MaxScroll)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)
	
	ScrollBar.Window = self
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetScaledSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetScaledPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetScaledPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetScaledPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	self:EnableMouseWheel(true)
	
	self.Scroll = Scroll
	self.SetWindowOffset = SetWindowOffset
	self.SetOffsetByDelta = SetOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetWindowOffset(1)
	
	ScrollBar:Show()
	
	if (self.MaxScroll == 1) then
		Thumb:Hide()
		ScrollBar.NewTexture:Hide()
		ScrollBar.NewTexture2:Hide()
		ScrollBar.Progress:Hide()
		self:SetScript("OnMouseWheel", NoScroll)
	else
		self:SetScript("OnMouseWheel", WindowOnMouseWheel)
	end
end

local SortWindow = function(self)
	local NumLeftWidgets = #self.LeftWidgets
	local NumRightWidgets = #self.RightWidgets
	
	if NumLeftWidgets then
		for i = 1, NumLeftWidgets do
			self.LeftWidgets[i]:ClearAllPoints()
		
			if (i == 1) then
				self.LeftWidgets[i]:SetScaledPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
			else
				self.LeftWidgets[i]:SetScaledPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	if NumRightWidgets then
		for i = 1, NumRightWidgets do
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i == 1) then
				self.RightWidgets[i]:SetScaledPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
			else
				self.RightWidgets[i]:SetScaledPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	AddWindowScrollBar(self)
end

function GUI:ShowWindow(name)
	for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()
			Window.Button.FadeOut:Play()
		end
	end
	
	CloseLastDropdown()
	
	local Window = self.Windows[name]
	
	if (not Window.Sorted) then
		Window:SortWindow()
		
		Window.Sorted = true
	end
	
	Window.Button.FadeIn:Play()
	Window:Show()
end

local WindowButtonOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local WindowButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local WindowButtonOnMouseUp = function(self)
	self.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	self.Parent:ShowWindow(self.Name)
end

local WindowButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

-- local Table, Count = Window:GetNonDefault()
local GetNonDefault = function(self)

end

function GUI:CreateSpacer(name)
	-- Button
	local Button = CreateFrame("Frame", nil, self)
	Button:SetScaledSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)
	Button:SetFrameLevel(self:GetFrameLevel() + 2)
	Button.SortName = override or name
	Button.Name = name
	Button.Parent = self
	
	Button.LineBG = CreateFrame("Frame", nil, Button)
	Button.LineBG:SetScaledHeight(4)
	Button.LineBG:SetScaledPoint("LEFT", Button, 0, 0)
	Button.LineBG:SetScaledPoint("RIGHT", Button, 0, 0)
	Button.LineBG:SetBackdrop(vUI.BackdropAndBorder)
	Button.LineBG:SetBackdropColorHex("000000")
	Button.LineBG:SetBackdropBorderColorHex("000000")
	
	Button.LineBG.Line = Button.LineBG:CreateTexture(nil, "OVERLAY")
	Button.LineBG.Line:SetScaledPoint("TOPLEFT", Button.LineBG, 1, -1)
	Button.LineBG.Line:SetScaledPoint("BOTTOMRIGHT", Button.LineBG, -1, 1)
	Button.LineBG.Line:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	Button.LineBG.Line:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	tinsert(self.Buttons, Button)
end

function GUI:CreateWindow(name, default, override)
	if self.Windows[name] then
		return self:GetWindow(name)
	end
	
	self.WindowCount = self.WindowCount or 0
	
	-- Button
	local Button = CreateFrame("Frame", nil, self)
	Button:SetScaledSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)
	Button:SetBackdrop(vUI.BackdropAndBorder)
	Button:SetBackdropColor(0, 0, 0)
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetFrameLevel(self:GetFrameLevel() + 2)
	Button.SortName = override or name
	Button.Name = name
	Button.Parent = self
	Button:SetScript("OnEnter", WindowButtonOnEnter)
	Button:SetScript("OnLeave", WindowButtonOnLeave)
	Button:SetScript("OnMouseUp", WindowButtonOnMouseUp)
	Button:SetScript("OnMouseDown", WindowButtonOnMouseDown)
	
	Button.Selected = Button:CreateTexture(nil, "OVERLAY")
	Button.Selected:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Selected:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetTexture(Media:GetTexture("RenHorizonUp"))
	Button.Selected:SetVertexColorHex(Settings["ui-widget-color"])
	Button.Selected:SetAlpha(0)
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Media:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Texture = Button:CreateTexture(nil, "ARTWORK")
	Button.Texture:SetScaledPoint("TOPLEFT", Button, 1, -1)
	Button.Texture:SetScaledPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Texture:SetTexture(Media:GetTexture(Settings["ui-button-texture"]))
	Button.Texture:SetVertexColorHex(Settings["ui-button-texture-color"])
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetScaledPoint("CENTER", Button, 0, -1)
	Button.Text:SetScaledSize(MENU_BUTTON_WIDTH - 6, MENU_BUTTON_HEIGHT)
	Button.Text:SetFontInfo(Settings["ui-widget-font"], Settings["ui-header-font-size"])
	Button.Text:SetJustifyH("CENTER")
	Button.Text:SetText("|cFF" .. Settings["ui-button-font-color"] .. name .. "|r")
	
	Button.Fade = CreateAnimationGroup(Button.Selected)
	
	Button.FadeIn = Button.Fade:CreateAnimation("Fade")
	Button.FadeIn:SetEasing("in")
	Button.FadeIn:SetDuration(0.15)
	Button.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Button.FadeOut = Button.Fade:CreateAnimation("Fade")
	Button.FadeOut:SetEasing("out")
	Button.FadeOut:SetDuration(0.15)
	Button.FadeOut:SetChange(0)
	
	tinsert(self.Buttons, Button)
	
	-- Window
	local Window = CreateFrame("Frame", nil, self)
	Window:SetScaledWidth(PARENT_WIDTH)
	Window:SetScaledPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	Window:SetScaledPoint("TOPRIGHT", self.CloseButton, "BOTTOMRIGHT", 0, -2)
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:Hide()
	
	Window.LeftWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.LeftWidgetsBG:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG:SetScaledPoint("TOPLEFT", Window, 16, 0)
	Window.LeftWidgetsBG:SetScaledPoint("BOTTOMLEFT", Window, 16, 0)
	
	Window.LeftWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window)
	Window.LeftWidgetsBG.Backdrop:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG.Backdrop:SetScaledPoint("TOPLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetScaledPoint("BOTTOMLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Window.LeftWidgetsBG.Backdrop:SetBackdropColorHex(Settings["ui-window-main-color"])
	Window.LeftWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	Window.RightWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG:SetScaledPoint("TOPLEFT", Window.LeftWidgetsBG, "TOPRIGHT", 2, 0)
	Window.RightWidgetsBG:SetScaledPoint("BOTTOMLEFT", Window.LeftWidgetsBG, "BOTTOMRIGHT", 2, 0)
	
	Window.RightWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG.Backdrop:SetScaledWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG.Backdrop:SetScaledPoint("TOPLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetScaledPoint("BOTTOMLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Window.RightWidgetsBG.Backdrop:SetBackdropColorHex(Settings["ui-window-main-color"])
	Window.RightWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	Window.Parent = self
	Window.Button = Button
	Window.LeftWidgets = {}
	Window.RightWidgets = {}
	Window.SortWindow = SortWindow
	
	Window.LeftWidgetsBG.Widgets = Window.LeftWidgets
	Window.LeftWidgetsBG.DisableScrolling = DisableScrolling
	Window.RightWidgetsBG.Widgets = Window.RightWidgets
	Window.RightWidgetsBG.DisableScrolling = DisableScrolling
	
	for Name, Function in pairs(self.Widgets) do
		Window.LeftWidgetsBG[Name] = Function
		Window.RightWidgetsBG[Name] = Function
	end
	
	self.Windows[name] = Window
	
	self.WindowCount = self.WindowCount + 1
	
	if default then
		self.DefaultWindow = name
	end
	
	return Window.LeftWidgetsBG, Window.RightWidgetsBG
end

function GUI:GetWindow(name)
	if self.Windows[name] then
		return self.Windows[name].LeftWidgetsBG, self.Windows[name].RightWidgetsBG
	else
		return self.Windows[self.DefaultWindow].LeftWidgetsBG, self.Windows[self.DefaultWindow].RightWidgetsBG
	end
end

GUI.SearchResults = {}

function GUI:ClearSearch()
	for i = 1, #self.SearchResults do
		tremove(self.SearchResults, 1)
	end
end

function GUI:AddSearchResult(result)
	self.SearchResults[#self.SearchResults + 1] = result
end

function GUI:GetNumSearchResults()
	return #self.SearchResults
end

function GUI:Search(query)
	for key, value in pairs(self.Windows) do
		for i = 1, #value.LeftWidgets do
			if (value.LeftWidgets[i].ID == id) then
				self:AddSearchResult(value.LeftWidgets[i].ID)
			end
		end
		
		for i = 1, #value.RightWidgets do
			if (value.RightWidgets[i].ID == id) then
				self:AddSearchResult(value.RightWidgets[i].ID)
			end
		end
	end
	
	if (self:GetNumSearchResults() > 0) then
		print('?')
	end
end

function GUI:GetWidgetByWindow(name, id)
	if self.Windows[name] then
		local Window = self.Windows[name]
		
		for i = 1, #Window.LeftWidgets do
			if (Window.LeftWidgets[i].ID == id) then
				return Window.LeftWidgets[i]
			end
		end
		
		for i = 1, #Window.RightWidgets do
			if (Window.RightWidgets[i].ID == id) then
				return Window.RightWidgets[i]
			end
		end
	end
end

function GUI:GetWidget(id)
	local Widget
	
	for Name in pairs(self.Windows) do
		Widget = self:GetWidgetByWindow(Name, id)
	end
	
	if Widget then
		return Widget
	end
end

function GUI:UpdateWidget(id, ...)
	-- Get the widget, add :Update() methods, and pass the vararg through it with the relevant information.
end

-- Selection scrolling
local ScrollSelections = function(self)
	local First
	
	for i = 1, #self.Buttons do
		if self.Buttons[i] then
			self.Buttons[i]:ClearAllPoints()
			
			if (i >= self.Offset) and (i <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not First) then
					self.Buttons[i]:SetScaledPoint("TOPLEFT", self.SelectionParent, SPACING, -SPACING)
					First = i
				else
					self.Buttons[i]:SetScaledPoint("TOP", self.Buttons[i-1], "BOTTOM", 0, -2)
				end
				
				self.Buttons[i]:Show()
			else
				self.Buttons[i]:Hide()
			end
		end
	end
end

local SetSelectionOffsetByDelta = function(self, delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self.Buttons - (MAX_WIDGETS_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local SelectionOnMouseWheel = function(self, delta)
	self:SetSelectionOffsetByDelta(delta)
	self:ScrollSelections()
	self.ScrollBar:SetValue(self.Offset)
end

local SetSelectionOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self.Buttons - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:ScrollSelections()
end

local SelectionScrollBarOnValueChanged = function(self)
	GUI.Offset = Round(self:GetValue())
	
	GUI:ScrollSelections()
end

local SelectionParentOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent():GetParent(), delta)
end

-- Frame
function GUI:Create()
	-- This just makes the animation look better. That's all. ಠ_ಠ
	self.BlackTexture = self:CreateTexture(nil, "BACKGROUND")
	self.BlackTexture:SetScaledPoint("TOPLEFT", self, 0, 0)
	self.BlackTexture:SetScaledPoint("BOTTOMRIGHT", self, 0, 0)
	self.BlackTexture:SetTexture(Media:GetTexture("Blank"))
	self.BlackTexture:SetVertexColor(0, 0, 0)
	
	self:SetFrameStrata("HIGH")
	self:SetScaledSize(GUI_WIDTH, GUI_HEIGHT)
	self:SetScaledPoint("CENTER", UIParent, 0, 0)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColorHex(Settings["ui-window-bg-color"])
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetClampedToScreen(true)
	self:Hide()
	
	self.Fade = CreateAnimationGroup(self)
	
	self.FadeIn = self.Fade:CreateAnimation("Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.15)
	self.FadeIn:SetChange(1)
	
	self.FadeOut = self.Fade:CreateAnimation("Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.15)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.Fader = self.Fade:CreateAnimation("Fade")
	self.Fader:SetDuration(0.15)
	
	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:SetScaledSize(HEADER_WIDTH - (HEADER_HEIGHT - 2) - SPACING - 1, HEADER_HEIGHT)
	self.Header:SetScaledPoint("TOPLEFT", self, SPACING, -SPACING)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	self.Header.Texture:SetScaledPoint("TOPLEFT", self.Header, 1, -1)
	self.Header.Texture:SetScaledPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetScaledPoint("CENTER", self.Header, 0, -1)
	self.Header.Text:SetScaledSize(HEADER_WIDTH - 6, HEADER_HEIGHT)
	self.Header.Text:SetFontInfo(Settings["ui-header-font"], Settings["ui-title-font-size"])
	self.Header.Text:SetJustifyH("CENTER")
	self.Header.Text:SetTextColorHex(Settings["ui-header-font-color"])
	self.Header.Text:SetText(format(Language["- vUI version %s -"], vUI.UIVersion))
	
	-- Selection parent
	self.SelectionParent = CreateFrame("Frame", nil, self)
	self.SelectionParent:SetScaledWidth(BUTTON_LIST_WIDTH + 16)
	self.SelectionParent:SetScaledPoint("BOTTOMLEFT", self, SPACING, SPACING)
	self.SelectionParent:SetScaledPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.SelectionParent:SetBackdrop(vUI.BackdropAndBorder)
	self.SelectionParent:SetBackdropColorHex(Settings["ui-window-main-color"])
	self.SelectionParent:SetBackdropBorderColor(0, 0, 0)
	self.SelectionParent:SetScript("OnMouseWheel", SelectionParentOnMouseWheel)
	
	-- Selection scrollbar
	local ScrollBar = CreateFrame("Slider", nil, self.SelectionParent)
	ScrollBar:SetScaledWidth(14)
	ScrollBar:SetScaledPoint("TOPRIGHT", self.SelectionParent, -3, -3)
	ScrollBar:SetScaledPoint("BOTTOMRIGHT", self.SelectionParent, -3, 3)
	ScrollBar:SetThumbTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColorHex(Settings["ui-window-main-color"])
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
	
	self.ScrollSelections = ScrollSelections
	self.SetSelectionOffset = SetSelectionOffset
	self.SetSelectionOffsetByDelta = SetSelectionOffsetByDelta
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetScaledSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
	Thumb:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetScaledPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetScaledPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetScaledPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Media:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColorHex(Settings["ui-widget-bright-color"])
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetScaledPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetScaledPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Media:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self)
	self.CloseButton:SetScaledSize(HEADER_HEIGHT, HEADER_HEIGHT)
	self.CloseButton:SetScaledPoint("TOPRIGHT", self, -SPACING, -SPACING)
	self.CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	self.CloseButton:SetBackdropColor(0, 0, 0, 0)
	self.CloseButton:SetBackdropBorderColor(0, 0, 0)
	self.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColorHex("C0392B") end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColorHex("EEEEEE") end)
	self.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
		
		GUI.FadeOut:Play()
		
		if (GUI.ColorPicker and GUI.ColorPicker:GetAlpha() > 0) then
			GUI.ColorPicker.FadeOut:Play()
		end
	end)
	
	self.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	self.CloseButton.Texture = self.CloseButton:CreateTexture(nil, "ARTWORK")
	self.CloseButton.Texture:SetScaledPoint("TOPLEFT", self.CloseButton, 1, -1)
	self.CloseButton.Texture:SetScaledPoint("BOTTOMRIGHT", self.CloseButton, -1, 1)
	self.CloseButton.Texture:SetTexture(Media:GetTexture(Settings["ui-header-texture"]))
	self.CloseButton.Texture:SetVertexColorHex(Settings["ui-header-texture-color"])
	
	self.CloseButton.Cross = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Cross:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Cross:SetScaledSize(16, 16)
	self.CloseButton.Cross:SetTexture(Media:GetTexture("Close"))
	self.CloseButton.Cross:SetVertexColorHex("EEEEEE")
end

-- Groups
GUI.Buttons = {}
GUI.Windows = {}

function GUI:AddFooters()
	local Window
	
	for Name in pairs(self.Windows) do
		Window = self.Windows[Name]
		
		if (#Window.LeftWidgets > 0) then
			Window.LeftWidgetsBG:CreateFooter()
		end
		
		if (#Window.RightWidgets > 0) then
			Window.RightWidgetsBG:CreateFooter()
		end
	end
end

function GUI:RunQueue()
	if (#self.Queue > 0) then
		local Func
		
		for i = 1, #self.Queue do
			Func = tremove(self.Queue, 1)
			
			Func(self)
		end
	end
	
	self:AddFooters()
end

function GUI:PLAYER_REGEN_DISABLED()
	if (Settings["gui-hide-in-combat"] and self:IsVisible()) then
		self:SetAlpha(0)
		self:Hide()
		CloseLastDropdown()
		self.WasCombatClosed = true
	end
end

local ReopenWindow = function(self)
	GUI:SetAlpha(0)
	GUI:Show()
	GUI.FadeIn:Play()
end

function GUI:PLAYER_REGEN_ENABLED()
	if (Settings["gui-hide-in-combat"] and self.WasCombatClosed) then
		vUI:DisplayPopup(Language["Attention"], Language["The settings window was automatically closed due to combat. Would you like to open it again?"], Language["Accept"], ReopenWindow, Language["Decline"])
	end
	
	self.WasCombatClosed = false
end

-- Enabling the mouse wheel will stop the scrolling if we pass over a widget, but I really want mousewheeling 
function GUI:MODIFIER_STATE_CHANGED(key, state)
	local MouseFocus = GetMouseFocus()
	
	if (not MouseFocus) then
		return
	end
	
	if (MouseFocus.OnMouseWheel and state == 1) then
		MouseFocus:SetScript("OnMouseWheel", MouseFocus.OnMouseWheel)
	elseif (MouseFocus.HasScript and MouseFocus:HasScript("OnMouseWheel")) then
		MouseFocus:SetScript("OnMouseWheel", nil)
	end
end

function GUI:PLAYER_STARTED_MOVING()
	if self.Fader:IsPlaying() then
		self.Fader:Stop()
	end
	
	self.Fader:SetEasing("out")
	self.Fader:SetChange(Settings["gui-faded-alpha"] / 100)
	self.Fader:Play()
end

function GUI:PLAYER_STOPPED_MOVING()
	if self.Fader:IsPlaying() then
		self.Fader:Stop()
	end
	
	self.Fader:SetEasing("in")
	self.Fader:SetChange(1)
	self.Fader:Play()
end

GUI:RegisterEvent("PLAYER_REGEN_DISABLED")
GUI:RegisterEvent("PLAYER_REGEN_ENABLED")
GUI:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)

function GUI:Toggle()
	if (not self:IsVisible()) then
		if (Settings["gui-hide-in-combat"] and InCombatLockdown()) then
			vUI:print(ERR_NOT_IN_COMBAT)
			
			return
		end
		
		if Settings["gui-enable-fade"] then
			self:RegisterEvent("PLAYER_STARTED_MOVING")
			self:RegisterEvent("PLAYER_STOPPED_MOVING")
		end
		
		tsort(self.Buttons, function(a, b)
			return a.SortName < b.SortName
		end)
		
		self.ScrollBar:SetMinMaxValues(1, (#self.Buttons - MAX_WIDGETS_SHOWN) + 1)
		self.ScrollBar:SetValue(1)
		self:SetSelectionOffset(1)
		self.ScrollBar:Show()
		
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
		self:SetAlpha(0)
		self:Show()
		self.FadeIn:Play()
	else
		self.FadeOut:Play()
		
		if (self.ColorPicker and self.ColorPicker:GetAlpha() > 0) then
			self.ColorPicker.FadeOut:Play()
		end
		
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
		
		if Settings["gui-enable-fade"] then
			self:UnregisterEvent("PLAYER_STARTED_MOVING")
			self:UnregisterEvent("PLAYER_STOPPED_MOVING")
		end
		
		CloseLastDropdown()
	end
end

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Styles"])
	
	Left:CreateHeader(Language["Styles"])
	Left:CreateDropdown("ui-style", Settings["ui-style"], Media:GetStyleList(), Language["Select Style"], "", function(v) Media:ApplyStyle(v); ReloadUI(); end):RequiresReload(true)
	
	Left:CreateHeader(Language["Headers"])
	Left:CreateColorSelection("ui-header-font-color", Settings["ui-header-font-color"], Language["Text Color"], "")
	Left:CreateColorSelection("ui-header-texture-color", Settings["ui-header-texture-color"], Language["Texture Color"], "")
	Left:CreateDropdown("ui-header-texture", Settings["ui-header-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-header-font", Settings["ui-header-font"], Media:GetFontList(), Language["Header Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Widgets"])
	Left:CreateColorSelection("ui-widget-color", Settings["ui-widget-color"], Language["Color"], "")
	Left:CreateColorSelection("ui-widget-bright-color", Settings["ui-widget-bright-color"], Language["Bright Color"], "")
	Left:CreateColorSelection("ui-widget-bg-color", Settings["ui-widget-bg-color"], Language["Background Color"], "")
	Left:CreateColorSelection("ui-widget-font-color", Settings["ui-widget-font-color"], Language["Label Color"], "")
	Left:CreateDropdown("ui-widget-texture", Settings["ui-widget-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Left:CreateDropdown("ui-widget-font", Settings["ui-widget-font"], Media:GetFontList(), Language["Font"], "", nil, "Font")
	
	Right:CreateHeader(Language["What is a style?"])
	Right:CreateLine(Language["Styles store media settings such as fonts,"])
	Right:CreateLine(Language["textures, and colors to create an overall theme."])
	
	Right:CreateHeader(Language["Console"])
	Right:CreateButton(Language["Reload"], Language["Reload UI"], "", ReloadUI)
	Right:CreateButton(Language["Delete"], Language["Delete Saved Variables"], "", function() vUIProfileData = nil; vUIProfiles = nil; ReloadUI(); end):RequiresReload(true)
	
	Right:CreateHeader(Language["Windows"])
	Right:CreateColorSelection("ui-window-bg-color", Settings["ui-window-bg-color"], Language["Background Color"], "")
	Right:CreateColorSelection("ui-window-main-color", Settings["ui-window-main-color"], Language["Main Color"], "")
	
	Right:CreateHeader(Language["Buttons"])
	Right:CreateColorSelection("ui-button-texture-color", Settings["ui-button-texture-color"], Language["Texture Color"], "")
	Right:CreateDropdown("ui-button-texture", Settings["ui-button-texture"], Media:GetTextureList(), Language["Texture"], "", nil, "Texture")
	Right:CreateDropdown("ui-button-font", Settings["ui-button-font"], Media:GetFontList(), Language["Font"], "", nil, "Font")
	
	Left:CreateHeader(Language["Font Sizes"])
	Left:CreateSlider("ui-font-size", Settings["ui-font-size"], 8, 18, 1, Language["General Font Size"], Language["Set the general font size of the UI"])
	Left:CreateSlider("ui-header-font-size", Settings["ui-header-font-size"], 8, 18, 1, Language["Header Font Size"], Language["Set the font size of header elements in the UI"])
	Left:CreateSlider("ui-title-font-size", Settings["ui-title-font-size"], 8, 18, 1, Language["Title Font Size"], Language["Set the font size of title elements in the UI"])
end)