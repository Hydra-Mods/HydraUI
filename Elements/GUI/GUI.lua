local HydraUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- Constants
local SPACING = 3
local WIDGET_HEIGHT = 20
local BUTTON_LIST_WIDTH = 126 -- 112
local GUI_WIDTH = 730 -- 710
local GUI_HEIGHT = 362 -- 340
local HEADER_WIDTH = GUI_WIDTH - (SPACING * 2)
local HEADER_HEIGHT = 20
local HEADER_SPACING = 5
local PARENT_WIDTH = GUI_WIDTH - BUTTON_LIST_WIDTH - ((SPACING * 2) + 2)
local GROUP_WIDTH = ((PARENT_WIDTH / 2) - (SPACING * 4) - 8) + 1

local MENU_BUTTON_WIDTH = BUTTON_LIST_WIDTH - (SPACING * 2)
local SELECTED_HIGHLIGHT_ALPHA = 0.25
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local MAX_WIDGETS_SHOWN = floor(GUI_HEIGHT / (WIDGET_HEIGHT + SPACING))

-- Locals
local type = type
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local floor = math.floor

local GUI = HydraUI:NewModule("GUI")

-- Storage
GUI.Categories = {}
GUI.Widgets = {}
GUI.WidgetID = {}
GUI.LoadCalls = {}
GUI.Buttons = {}
GUI.ButtonQueue = {}
GUI.ScrollButtons = {}

local Scroll = function(self)
	local FirstLeft
	local FirstRight
	local Offset = self.LeftWidgetsBG.ScrollingDisabled and 1 or self.Offset

	for i = 1, self.WidgetCount do
		if self.LeftWidgets[i] then
			self.LeftWidgets[i]:ClearAllPoints()

			if (i >= Offset) and (i <= Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not FirstLeft) then
					self.LeftWidgets[i]:SetPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
					FirstLeft = i
				else
					self.LeftWidgets[i]:SetPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
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
					self.RightWidgets[i]:SetPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
					FirstRight = i
				else
					self.RightWidgets[i]:SetPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
				end

				self.RightWidgets[i]:Show()
			else
				self.RightWidgets[i]:Hide()
			end
		end
	end
end

local NoScroll = function() end

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
	SetOffsetByDelta(self, delta)
	Scroll(self)
	self.ScrollBar:SetValue(self.Offset)

	if (self.Offset == 1) then
		self.ScrollUp.Arrow:SetVertexColor(0.65, 0.65, 0.65)
	else
		self.ScrollUp.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	end

	if (self.Offset == self.MaxScroll) then
		self.ScrollDown.Arrow:SetVertexColor(0.65, 0.65, 0.65)
	else
		self.ScrollDown.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	end
end

local SetWindowOffset = function(self, offset)
	self.Offset = offset

	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.WidgetCount - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end

	Scroll(self)
end

local WindowScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()

	Parent.Offset = Round(self:GetValue())

	Scroll(Parent)
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local WindowScrollBarOnMouseUp = function(self)
	self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

	WindowOnMouseWheel(self:GetParent(), 1)
end

local WindowScrollBarOnMouseDown = function(self)
	local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])

	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local AddWindowScrollBar = function(self)
	-- Scroll up
	self.ScrollUp = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.ScrollUp:SetSize(16, WIDGET_HEIGHT)
	self.ScrollUp:SetPoint("TOPRIGHT", GUI, -SPACING, -((SPACING * 2) + HEADER_HEIGHT - 1))
	self.ScrollUp:SetBackdrop(HydraUI.BackdropAndBorder)
	self.ScrollUp:SetBackdropColor(0, 0, 0, 0)
	self.ScrollUp:SetBackdropBorderColor(0, 0, 0)
	self.ScrollUp:SetScript("OnMouseUp", WindowScrollBarOnMouseUp)
	self.ScrollUp:SetScript("OnMouseDown", WindowScrollBarOnMouseDown)

	self.ScrollUp.Texture = self.ScrollUp:CreateTexture(nil, "ARTWORK")
	self.ScrollUp.Texture:SetPoint("TOPLEFT", self.ScrollUp, 1, -1)
	self.ScrollUp.Texture:SetPoint("BOTTOMRIGHT", self.ScrollUp, -1, 1)
	self.ScrollUp.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.ScrollUp.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

	self.ScrollUp.Highlight = self.ScrollUp:CreateTexture(nil, "HIGHLIGHT")
	self.ScrollUp.Highlight:SetPoint("TOPLEFT", self.ScrollUp, 1, -1)
	self.ScrollUp.Highlight:SetPoint("BOTTOMRIGHT", self.ScrollUp, -1, 1)
	self.ScrollUp.Highlight:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.ScrollUp.Highlight:SetVertexColor(1, 1, 1)
	self.ScrollUp.Highlight:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)

	self.ScrollUp.Arrow = self.ScrollUp:CreateTexture(nil, "OVERLAY")
	self.ScrollUp.Arrow:SetPoint("CENTER", self.ScrollUp, 0, 0)
	self.ScrollUp.Arrow:SetSize(16, 16)
	self.ScrollUp.Arrow:SetTexture(Assets:GetTexture("Arrow Up"))
	self.ScrollUp.Arrow:SetVertexColor(0.65, 0.65, 0.65)

	-- Scroll down
	self.ScrollDown = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.ScrollDown:SetSize(16, WIDGET_HEIGHT)
	self.ScrollDown:SetPoint("BOTTOMRIGHT", GUI, -SPACING, SPACING)
	self.ScrollDown:SetBackdrop(HydraUI.BackdropAndBorder)
	self.ScrollDown:SetBackdropColor(0, 0, 0, 0)
	self.ScrollDown:SetBackdropBorderColor(0, 0, 0)
	self.ScrollDown:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

		WindowOnMouseWheel(self:GetParent(), -1)
	end)

	self.ScrollDown:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])

		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)

	self.ScrollDown.Texture = self.ScrollDown:CreateTexture(nil, "ARTWORK")
	self.ScrollDown.Texture:SetPoint("TOPLEFT", self.ScrollDown, 1, -1)
	self.ScrollDown.Texture:SetPoint("BOTTOMRIGHT", self.ScrollDown, -1, 1)
	self.ScrollDown.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.ScrollDown.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

	self.ScrollDown.Highlight = self.ScrollDown:CreateTexture(nil, "HIGHLIGHT")
	self.ScrollDown.Highlight:SetPoint("TOPLEFT", self.ScrollDown, 1, -1)
	self.ScrollDown.Highlight:SetPoint("BOTTOMRIGHT", self.ScrollDown, -1, 1)
	self.ScrollDown.Highlight:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.ScrollDown.Highlight:SetVertexColor(1, 1, 1)
	self.ScrollDown.Highlight:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)

	self.ScrollDown.Arrow = self.ScrollDown:CreateTexture(nil, "OVERLAY")
	self.ScrollDown.Arrow:SetPoint("CENTER", self.ScrollDown, 0, 0)
	self.ScrollDown.Arrow:SetSize(16, 16)
	self.ScrollDown.Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
	self.ScrollDown.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))

	local ScrollBar = CreateFrame("Slider", nil, self, "BackdropTemplate")
	ScrollBar:SetPoint("TOPLEFT", self.ScrollUp, "BOTTOMLEFT", 0, -2)
	ScrollBar:SetPoint("BOTTOMRIGHT", self.ScrollDown, "TOPRIGHT", 0, 2)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(HydraUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, self.MaxScroll)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)

	ScrollBar.Window = self

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
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

	ScrollBar.Highlight = ScrollBar:CreateTexture(nil, "HIGHLIGHT")
	ScrollBar.Highlight:SetPoint("TOPLEFT", ScrollBar.NewThumb, 1, -1)
	ScrollBar.Highlight:SetPoint("BOTTOMRIGHT", ScrollBar.NewThumb, -1, 1)
	ScrollBar.Highlight:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Highlight:SetVertexColor(1, 1, 1)
	ScrollBar.Highlight:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)

	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetPoint("BOTTOMRIGHT", ScrollBar.NewThumb, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	ScrollBar.Progress:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", WindowOnMouseWheel)

	self.ScrollBar = ScrollBar

	ScrollBar:Show()
end

function GUI:SortMenuButtons()
	tsort(self.Categories, function(a, b)
		return a.Name < b.Name
	end)

	self.NumShownButtons = 0

	for i = 1, #self.Categories do
		tsort(self.Categories[i].Buttons, function(a, b)
			return a.Name < b.Name
		end)

		for j = 1, #self.Categories[i].Buttons do
			if (j == 1) then
				self.Categories[i].Buttons[j]:SetPoint("TOPLEFT", self.Categories[i], "BOTTOMLEFT", 0, -2)
			else
				self.Categories[i].Buttons[j]:SetPoint("TOPLEFT", self.Categories[i].Buttons[j-1], "BOTTOMLEFT", 0, -2)
			end

			self.NumShownButtons = self.NumShownButtons + 1
		end

		if (i == 1) then
			self.Categories[i]:SetPoint("TOPLEFT", self.MenuParent, "TOPLEFT", SPACING, -SPACING)
		elseif #self.Categories[i-1].Buttons then
			self.Categories[i]:SetPoint("TOPLEFT", self.Categories[i-1].Buttons[#self.Categories[i-1].Buttons], "BOTTOMLEFT", 0, -2)
		else
			self.Categories[i]:SetPoint("TOPLEFT", self.Categories[i-1], "BOTTOMLEFT", 0, -2)
		end

		self.NumShownButtons = self.NumShownButtons + 1
	end
end

function GUI:CreateCategory(name)
	local Category = CreateFrame("Frame", nil, self)
	Category:SetSize(MENU_BUTTON_WIDTH, WIDGET_HEIGHT)
	Category:SetFrameLevel(self:GetFrameLevel() + 2)
	Category.SortName = name
	Category.Name = name
	Category.Buttons = {}

	Category.Text = Category:CreateFontString(nil, "OVERLAY")
	Category.Text:SetPoint("CENTER", Category, 0, 0)
	HydraUI:SetFontInfo(Category.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Category.Text:SetJustifyH("CENTER")
	Category.Text:SetText(format("|cFF%s%s|r", Settings["ui-header-font-color"], name))

	Category.BG = Category:CreateTexture(nil, "BORDER")
	Category.BG:SetAllPoints()
	Category.BG:SetColorTexture(0, 0, 0)

	Category.Texture = Category:CreateTexture(nil, "OVERLAY")
	Category.Texture:SetPoint("TOPLEFT", Category, 1, -1)
	Category.Texture:SetPoint("BOTTOMRIGHT", Category, -1, 1)
	Category.Texture:SetTexture(Assets:GetTexture("Blank"))
	Category.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))

	self.TotalSelections = (self.TotalSelections or 0) + 1

	self.Categories[#self.Categories + 1] = Category
	self.Categories[name] = Category
end

local DisableScrolling = function(self)
	self.ScrollingDisabled = true
end

function GUI:CreateWidgetWindow(category, name, parent)
	-- Window
	local Window = CreateFrame("Frame", nil, self)
	Window:SetWidth(PARENT_WIDTH)
	Window:SetPoint("TOPLEFT", self.ScrollUp, "TOPRIGHT", 2, 0)
	Window:SetPoint("TOPRIGHT", self.CloseButton, "BOTTOMRIGHT", 0, -2)
	Window:SetPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	Window:Hide()

	Window.LeftWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.LeftWidgetsBG:SetWidth(GROUP_WIDTH)
	Window.LeftWidgetsBG:SetPoint("TOPLEFT", Window, 0, 0)
	Window.LeftWidgetsBG:SetPoint("BOTTOMLEFT", Window, 0, 0)

	Window.LeftWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.LeftWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH)
	Window.LeftWidgetsBG.Backdrop:SetPoint("TOPLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.LeftWidgetsBG.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.LeftWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)

	Window.RightWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG:SetWidth(GROUP_WIDTH)
	Window.RightWidgetsBG:SetPoint("TOPLEFT", Window.LeftWidgetsBG, "TOPRIGHT", 2, 0)
	Window.RightWidgetsBG:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, "BOTTOMRIGHT", 2, 0)

	Window.RightWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.RightWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH)
	Window.RightWidgetsBG.Backdrop:SetPoint("TOPLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetPoint("BOTTOMLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.RightWidgetsBG.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.RightWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)

	Window.Category = category
	Window.Name = name
	Window.Parent = parent
	Window.LeftWidgets = {}
	Window.RightWidgets = {}

	Window.LeftWidgetsBG.Widgets = Window.LeftWidgets
	Window.LeftWidgetsBG.DisableScrolling = DisableScrolling
	Window.RightWidgetsBG.Widgets = Window.RightWidgets
	Window.RightWidgetsBG.DisableScrolling = DisableScrolling

	for Name, Function in next, self.Widgets do
		Window.LeftWidgetsBG[Name] = Function
		Window.RightWidgetsBG[Name] = Function
	end

	if (parent and self.LoadCalls[category][parent].Children) then
		for i = 1, #self.LoadCalls[category][parent].Children[name].Calls do
			self.LoadCalls[category][parent].Children[name].Calls[1](Window.LeftWidgetsBG, Window.RightWidgetsBG)

			tremove(self.LoadCalls[category][parent].Children[name].Calls, 1)
		end
	else
		for i = 1, #self.LoadCalls[category][name].Calls do
			self.LoadCalls[category][name].Calls[1](Window.LeftWidgetsBG, Window.RightWidgetsBG)

			tremove(self.LoadCalls[category][name].Calls, 1)
		end
	end

	if (#Window.LeftWidgetsBG.Widgets > 0) then
		Window.LeftWidgetsBG:CreateFooter()
	end

	if (#Window.RightWidgetsBG.Widgets > 0) then
		Window.RightWidgetsBG:CreateFooter()
	end

	Window.MaxScroll = max((#Window.LeftWidgets - (MAX_WIDGETS_SHOWN - 1)), (#Window.RightWidgets - (MAX_WIDGETS_SHOWN - 1)), 1)
	Window.WidgetCount = max(#Window.LeftWidgets, #Window.RightWidgets)

	if (Window.MaxScroll > 1) then
		AddWindowScrollBar(Window)
	else
		Window.ScrollFiller = CreateFrame("Frame", nil, Window, "BackdropTemplate")
		Window.ScrollFiller:SetPoint("TOPRIGHT", Window, 0, 0)
		Window.ScrollFiller:SetPoint("BOTTOMRIGHT", Window, 0, 0)
		Window.ScrollFiller:SetWidth(16)
		Window.ScrollFiller:SetBackdrop(HydraUI.BackdropAndBorder)
		Window.ScrollFiller:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
		Window.ScrollFiller:SetBackdropBorderColor(0, 0, 0)

		Window:SetScript("OnMouseWheel", NoScroll)
	end

	SetWindowOffset(Window, 1)

	return Window
end

function GUI:ShowWindow(category, name, parent)
	for i = 1, #self.Categories do
		for j = 1, #self.Categories[i].Buttons do
			if parent then
				if (self.Categories[i].Buttons[j].Name == parent and self.Categories[i].Buttons[j].Children) then
					for o = 1, #self.Categories[i].Buttons[j].Children do
						if (self.Categories[i].Buttons[j].Children[o].Name == name) then
							if (not self.Categories[i].Buttons[j].Children[o].Window) then
								self.Categories[i].Buttons[j].Children[o].Window = self:CreateWidgetWindow(category, name, parent)
							end

							self.Categories[i].Buttons[j].Window:Hide()

							self.Categories[i].Buttons[j].Children[o].Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
							self.Categories[i].Buttons[j].Children[o].Window:Show()
						elseif self.Categories[i].Buttons[j].Children[o].Window then
							self.Categories[i].Buttons[j].Children[o].Window:Hide()

							if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
								self.Categories[i].Buttons[j].Children[o].Selected:SetAlpha(0)
							end
						end
					end

					if (self.Categories[i].Buttons[j].Selected:GetAlpha() > 0) then
						self.Categories[i].Buttons[j].Selected:SetAlpha(0)
					end
				elseif self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
				end
			elseif (self.Categories[i].Name == category) and (self.Categories[i].Buttons[j].Name == name) then
				if (not self.Categories[i].Buttons[j].Window) then
					self.Categories[i].Buttons[j].Window = self:CreateWidgetWindow(category, name, parent)
				end

				self.Categories[i].Buttons[j].Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
				self.Categories[i].Buttons[j].Window:Show()

				if self.Categories[i].Buttons[j].Children then
					if self.Categories[i].Buttons[j].ChildrenShown then
						self.Categories[i].Buttons[j].Arrow:SetTexture(Assets:GetTexture("Arrow Down"))

						for o = 1, #self.Categories[i].Buttons[j].Children do
							if self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()

								if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
									self.Categories[i].Buttons[j].Children[o].Selected:SetAlpha(0)
								end
							end

							self.Categories[i].Buttons[j].Children[o]:Hide()
						end

						self.Categories[i].Buttons[j].ChildrenShown = false
					else
						self.Categories[i].Buttons[j].Arrow:SetTexture(Assets:GetTexture("Arrow Up"))

						for o = 1, #self.Categories[i].Buttons[j].Children do
							if self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()

								if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
									self.Categories[i].Buttons[j].Children[o].Selected:SetAlpha(0)
								end
							end

							self.Categories[i].Buttons[j].Children[o]:Hide()
						end

						self.Categories[i].Buttons[j].ChildrenShown = true
					end
				end
			else
				if self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()

					if (self.Categories[i].Buttons[j].Selected:GetAlpha() > 0) then
						self.Categories[i].Buttons[j].Selected:SetAlpha(0)
					end

					if self.Categories[i].Buttons[j].Children then
						self.Categories[i].Buttons[j].Arrow:SetTexture(Assets:GetTexture("Arrow Down"))

						for o = 1, #self.Categories[i].Buttons[j].Children do
							if self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()
							end

							self.Categories[i].Buttons[j].Children[o]:Hide()
						end

						self.Categories[i].Buttons[j].ChildrenShown = false
					end
				end
			end
		end
	end

	self:ScrollSelections()

	--CloseLastDropdown()
end

local WindowButtonOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local WindowButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local WindowButtonOnMouseUp = function(self)
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 4, 0)

	GUI:ShowWindow(self.Category, self.Name, self.Parent)
end

local WindowButtonOnMouseDown = function(self)
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, 6, -1)
end

local WindowSubButtonOnMouseUp = function(self)
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, SPACING * 3, 0)

	GUI:ShowWindow(self.Category, self.Name, self.Parent)
end

local WindowSubButtonOnMouseDown = function(self)
	self.Text:ClearAllPoints()
	self.Text:SetPoint("LEFT", self, (SPACING * 3) + 2, -1)
end

function GUI:HasButton(category, name, parent)
	if parent then
		if (self.Buttons[category] and self.Buttons[category][parent]) then
			return self.Buttons[category][parent][name]
		end
	else
		return (self.Buttons[category] and self.Buttons[category][name])
	end
end

function GUI:CreateWindow(category, name, parent)
	if self:HasButton(category, name, parent) then
		return
	end

	if (not self.Categories[category]) then
		self:CreateCategory(category)
	end

	local Category = self.Categories[category]

	local Button = CreateFrame("Frame", nil, self)
	Button:SetSize(MENU_BUTTON_WIDTH, WIDGET_HEIGHT)
	Button:SetFrameLevel(self:GetFrameLevel() + 2)
	Button.Name = name
	Button.Category = category
	Button:SetScript("OnEnter", WindowButtonOnEnter)
	Button:SetScript("OnLeave", WindowButtonOnLeave)

	Button.Selected = Button:CreateTexture(nil, "ARTWORK")
	Button.Selected:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Selected:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetTexture(Assets:GetTexture("Blank"))
	Button.Selected:SetAlpha(0)

	Button.Highlight = Button:CreateTexture(nil, "ARTWORK")
	Button.Highlight:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)

	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetSize(MENU_BUTTON_WIDTH - 6, WIDGET_HEIGHT)
	Button.Text:SetJustifyH("LEFT")

	Button.FadeIn = LibMotion:CreateAnimation(Button, "Fade")
	Button.FadeIn:SetEasing("in")
	Button.FadeIn:SetDuration(0.15)
	Button.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)

	Button.FadeOut = LibMotion:CreateAnimation(Button, "Fade")
	Button.FadeOut:SetEasing("out")
	Button.FadeOut:SetDuration(0.15)
	Button.FadeOut:SetChange(0)

	if parent then
		Button:SetScript("OnMouseUp", WindowSubButtonOnMouseUp)
		Button:SetScript("OnMouseDown", WindowSubButtonOnMouseDown)

		Button.Parent = parent

		Button.Selected:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))

		Button.Text:SetPoint("LEFT", Button, SPACING * 3, 0)
		HydraUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], 12)
		Button.Text:SetText("|cFF" .. Settings["ui-widget-font-color"] .. name .. "|r")

		for j = 1, #Category.Buttons do
			if (Category.Buttons[j].Name == parent) then
				if (not Category.Buttons[j].Children) then
					Category.Buttons[j].Children = {}

					Category.Buttons[j].Arrow = Category.Buttons[j]:CreateTexture(nil, "OVERLAY")
					Category.Buttons[j].Arrow:SetPoint("RIGHT", Category.Buttons[j], -3, -1)
					Category.Buttons[j].Arrow:SetSize(16, 16)
					Category.Buttons[j].Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
					Category.Buttons[j].Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
				end

				tinsert(Category.Buttons[j].Children, Button)

				break
			end
		end
	else
		Button:SetScript("OnMouseUp", WindowButtonOnMouseUp)
		Button:SetScript("OnMouseDown", WindowButtonOnMouseDown)

		Button.Selected:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

		Button.Text:SetPoint("LEFT", Button, 4, 0)
		HydraUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], Settings["ui-header-font-size"])
		Button.Text:SetText("|cFF" .. Settings["ui-button-font-color"] .. name .. "|r")

		tinsert(Category.Buttons, Button)

		self.TotalSelections = (self.TotalSelections or 0) + 1
	end

	if (not self.Buttons[category]) then
		self.Buttons[category] = {}
	end

	if parent then
		if (not self.Buttons[category][parent]) then
			self.Buttons[category][parent] = {}
		end

		self.Buttons[category][parent][name] = Button
	elseif (not self.Buttons[category][name]) then
		self.Buttons[category][name] = Button
	end
end

function GUI:AddWidgets(category, name, arg1, arg2)
	if (not self.LoadCalls[category]) then
		self.LoadCalls[category] = {}
	end

	if (not self.LoadCalls[category][name]) then
		self.LoadCalls[category][name] = {Calls = {}}
	end

	if (type(arg1) == "function") then
		tinsert(self.LoadCalls[category][name].Calls, arg1)
		tinsert(self.ButtonQueue, {category, name})
	else -- string
		if (not self.LoadCalls[category][arg1].Children) then
			self.LoadCalls[category][arg1].Children = {}
		end

		self.LoadCalls[category][arg1].Children[name] = {Calls = {}}

		tinsert(self.LoadCalls[category][arg1].Children[name].Calls, arg2)
		tinsert(self.ButtonQueue, {category, name, arg1})
	end
end

function GUI:GetWidget(id)
	if self.WidgetID[id] then
		return self.WidgetID[id]
	end
end

function GUI:ScrollSelections()
	local Count = 0

	-- Collect buttons
	for i = 1, #self.ScrollButtons do
		tremove(self.ScrollButtons, 1)
	end

	for i = 1, #self.Categories do
		Count = Count + 1

		if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
			tinsert(self.ScrollButtons, self.Categories[i])
		end

		self.Categories[i]:Hide()

		for j = 1, #self.Categories[i].Buttons do
			Count = Count + 1

			if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
				tinsert(self.ScrollButtons, self.Categories[i].Buttons[j])
			end

			if self.Categories[i].Buttons[j].ChildrenShown then
				for o = 1, #self.Categories[i].Buttons[j].Children do
					Count = Count + 1

					if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
						tinsert(self.ScrollButtons, self.Categories[i].Buttons[j].Children[o])
						self.Categories[i].Buttons[j].Children[o]:Show()
					else
						self.Categories[i].Buttons[j].Children[o]:Hide()
					end
				end
			end

			self.Categories[i].Buttons[j]:Hide()
		end
	end

	self.TotalSelections = Count

	self.ScrollBar:SetMinMaxValues(1, (Count - MAX_WIDGETS_SHOWN) + 1)

	for i = 1, #self.ScrollButtons do
		if self.ScrollButtons[i] then
			self.ScrollButtons[i]:ClearAllPoints()

			if (i == 1) then
				self.ScrollButtons[i]:SetPoint("TOPLEFT", self.MenuParent, SPACING, -SPACING)
			else
				self.ScrollButtons[i]:SetPoint("TOP", self.ScrollButtons[i-1], "BOTTOM", 0, -2)
			end

			self.ScrollButtons[i]:Show()
		end
	end

	if (self.Offset == 1) then
		self.ScrollUp.Arrow:SetVertexColor(0.65, 0.65, 0.65)
	else
		self.ScrollUp.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	end

	local Min, Max = self.ScrollBar:GetMinMaxValues()

	if (self.Offset == Max) then
		self.ScrollDown.Arrow:SetVertexColor(0.65, 0.65, 0.65)
	else
		self.ScrollDown.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	end
end

function GUI:SetSelectionOffset(offset)
	self.Offset = offset

	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.TotalSelections - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end

	self:ScrollSelections()
end

function GUI:SetSelectionOffsetByDelta(delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1

		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1

		if (self.Offset > (self.TotalSelections - (MAX_WIDGETS_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local SelectionOnMouseWheel = function(self, delta)
	self:SetSelectionOffsetByDelta(delta)
	self:ScrollSelections()
	self.ScrollBar:SetValue(self.Offset)
end

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)

	return floor(num * Mult + 0.5) / Mult
end

local SelectionScrollBarOnValueChanged = function(self)
	GUI.Offset = Round(self:GetValue())

	GUI:ScrollSelections()
end

local MenuParentOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent():GetParent(), delta)
end

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function GUI:CreateUpdateWindow()
	if self.UpdateWindow then
		return
	end

	self.UpdateWindow = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.UpdateWindow:SetFrameStrata("HIGH")
	self.UpdateWindow:SetFrameLevel(10)
	self.UpdateWindow:SetSize(340, 168) -- GUI_WIDTH / 3 -- 220 200
	self.UpdateWindow:SetPoint("CENTER", HydraUI.UIParent, 0, 0)
	self.UpdateWindow:SetBackdrop(HydraUI.BackdropAndBorder)
	self.UpdateWindow:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self.UpdateWindow:SetBackdropBorderColor(0, 0, 0)
	self.UpdateWindow:EnableMouse(true)
	self.UpdateWindow:SetMovable(true)
	self.UpdateWindow:RegisterForDrag("LeftButton")
	self.UpdateWindow:SetScript("OnDragStart", self.StartMoving)
	self.UpdateWindow:SetScript("OnDragStop", self.StopMovingOrSizing)
	self.UpdateWindow:SetClampedToScreen(true)

	self.UpdateWindow.Header = CreateFrame("Frame", nil, self.UpdateWindow, "BackdropTemplate")
	self.UpdateWindow.Header:SetHeight(HEADER_HEIGHT)
	self.UpdateWindow.Header:SetPoint("TOPLEFT", self.UpdateWindow, SPACING, -SPACING)
	self.UpdateWindow.Header:SetPoint("TOPRIGHT", self.UpdateWindow, -SPACING, -SPACING)
	self.UpdateWindow.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	self.UpdateWindow.Header:SetBackdropColor(0, 0, 0, 0)
	self.UpdateWindow.Header:SetBackdropBorderColor(0, 0, 0)

	self.UpdateWindow.Header.Texture = self.UpdateWindow.Header:CreateTexture(nil, "ARTWORK")
	self.UpdateWindow.Header.Texture:SetPoint("TOPLEFT", self.UpdateWindow.Header, 1, -1)
	self.UpdateWindow.Header.Texture:SetPoint("BOTTOMRIGHT", self.UpdateWindow.Header, -1, 1)
	self.UpdateWindow.Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.UpdateWindow.Header.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))

	self.UpdateWindow.Header.Text = self.UpdateWindow.Header:CreateFontString(nil, "OVERLAY")
	self.UpdateWindow.Header.Text:SetPoint("LEFT", self.UpdateWindow.Header, 5, 0)
	self.UpdateWindow.Header.Text:SetSize(340 - 6, HEADER_HEIGHT)
	HydraUI:SetFontInfo(self.UpdateWindow.Header.Text, Settings["ui-header-font"], Settings["ui-header-font-size"])
	self.UpdateWindow.Header.Text:SetJustifyH("LEFT")
	self.UpdateWindow.Header.Text:SetTextColor(HydraUI:HexToRGB(Settings["ui-header-font-color"]))
	self.UpdateWindow.Header.Text:SetText(Language["Update"])

	self.UpdateWindow.CloseButton = CreateFrame("Frame", nil, self.UpdateWindow.Header)
	self.UpdateWindow.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	self.UpdateWindow.CloseButton:SetPoint("RIGHT", self.UpdateWindow.Header, 0, -1)
	self.UpdateWindow.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	self.UpdateWindow.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	self.UpdateWindow.CloseButton:SetScript("OnMouseUp", function() self.UpdateWindow:Hide() end)

	self.UpdateWindow.CloseButton.Cross = self.UpdateWindow.CloseButton:CreateTexture(nil, "OVERLAY")
	self.UpdateWindow.CloseButton.Cross:SetPoint("CENTER", self.UpdateWindow.CloseButton, 0, 0)
	self.UpdateWindow.CloseButton.Cross:SetSize(16, 16)
	self.UpdateWindow.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	self.UpdateWindow.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))

	self.UpdateWindow.WidgetsBG = CreateFrame("Frame", nil, self.UpdateWindow)
	self.UpdateWindow.WidgetsBG:SetPoint("TOPLEFT", self.UpdateWindow.Header, "BOTTOMLEFT", 0, -2)
	self.UpdateWindow.WidgetsBG:SetPoint("BOTTOMRIGHT", self.UpdateWindow, -SPACING, SPACING)

	self.UpdateWindow.WidgetsBG.Backdrop = CreateFrame("Frame", nil, self.UpdateWindow, "BackdropTemplate")
	self.UpdateWindow.WidgetsBG.Backdrop:SetAllPoints(self.UpdateWindow.WidgetsBG)
	self.UpdateWindow.WidgetsBG.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	self.UpdateWindow.WidgetsBG.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.UpdateWindow.WidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)

	self.UpdateWindow.Text = CreateFrame("EditBox", nil, self.UpdateWindow.WidgetsBG)
	HydraUI:SetFontInfo(self.UpdateWindow.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	self.UpdateWindow.Text:SetTextColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	self.UpdateWindow.Text:SetPoint("TOPLEFT", self.UpdateWindow.WidgetsBG, 6, -6)
	self.UpdateWindow.Text:SetPoint("TOPRIGHT", self.UpdateWindow.WidgetsBG, -6, 6)
	self.UpdateWindow.Text:SetHeight(80)
	self.UpdateWindow.Text:SetJustifyH("LEFT")
	self.UpdateWindow.Text:SetAutoFocus(false)
	self.UpdateWindow.Text:SetMultiLine(true)
	self.UpdateWindow.Text:SetMaxLetters(500)
	self.UpdateWindow.Text:SetText(Language["Staying up-to-date ensures the latest features and bug fixes! Please consider using one of the websites below as they share a portion of ad revenue with creators."])

	for i = 1, 2 do
		local Box = CreateFrame("Frame", nil, self.UpdateWindow.WidgetsBG, "BackdropTemplate")
		Box:SetHeight(20)
		Box:SetPoint("LEFT", self.UpdateWindow.WidgetsBG, 3, 0)
		Box:SetPoint("RIGHT", self.UpdateWindow.WidgetsBG, -3, 0)
		Box:SetBackdrop(HydraUI.BackdropAndBorder)
		Box:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
		Box:SetBackdropBorderColor(0, 0, 0)

		--[[Box.Texture = Box:CreateTexture(nil, "BACKGROUND")
		Box.Texture:SetPoint("TOPLEFT", Box, 1, -1)
		Box.Texture:SetPoint("BOTTOMRIGHT", Box, -1, 1)
		Box.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		Box.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))]]

		Box.Input = CreateFrame("EditBox", nil, Box)
		HydraUI:SetFontInfo(Box.Input, Settings["ui-widget-font"], Settings["ui-font-size"])
		Box.Input:SetPoint("TOPLEFT", Box, 3, -3)
		Box.Input:SetPoint("BOTTOMRIGHT", Box, -3, 3)
		Box.Input:SetFrameLevel(10)
		Box.Input:SetFrameStrata("DIALOG")
		Box.Input:SetJustifyH("LEFT")
		Box.Input:SetAutoFocus(false)
		Box.Input:EnableKeyboard(true)
		Box.Input:EnableMouse(true)
		Box.Input:SetMaxLetters(999)

		Box.Label = Box.Input:CreateFontString(nil, "OVERLAY")
		Box.Label:SetPoint("BOTTOMLEFT", Box, "TOPLEFT", 3, 4)
		HydraUI:SetFontInfo(Box.Label, Settings["ui-font"], Settings["ui-font-size"])
		Box.Label:SetJustifyH("LEFT")

		Box.Input:SetScript("OnEditFocusLost", function(self)
			self:HighlightText(0, 0)
			self:SetCursorPosition(0)
		end)
		Box.Input:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
			self:HighlightText(0, 0)
			self:SetCursorPosition(0)
		end)
		Box.Input:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
			self:HighlightText(0, 0)
			self:SetCursorPosition(0)
		end)
		Box.Input:SetScript("OnTextChanged", function(self)
			if (self:GetText() ~= self.Link) then
				self:Insert(self.Link)
			end
		end)
		Box.Input:SetScript("OnMouseDown", function(self)
			self:SetFocus()
			self:HighlightText(0, self:GetText():len())
			self:SetCursorPosition(0)
		end)

		if (i == 1) then
			Box:SetPoint("BOTTOMLEFT", self.UpdateWindow.WidgetsBG, 3, 3)
			Box.Label:SetText(Language["Download at Wago (WeakAuras Addons)"])
			Box.Input.Link = "https://addons.wago.io/addons/hydraui"
			Box.Input:SetText("https://addons.wago.io/addons/hydraui")
		else
			Box:SetPoint("BOTTOMLEFT", self.UpdateWindow.WidgetsBG, 3, 50)
			Box.Label:SetText(Language["Download at CurseForge"])
			Box.Input.Link = "https://www.curseforge.com/wow/addons/hydraui"
			Box.Input:SetText("https://www.curseforge.com/wow/addons/hydraui")
		end

		Box.Input:SetCursorPosition(0)
	end
end

function GUI:CreateUpdateAlert()
	if self.Alert then
		return
	end

	if (not self.Header) then
		self.QueueAlert = true

		return
	end

	self.Alert = CreateFrame("Frame", nil, self.Header)
	self.Alert:SetPoint("LEFT", self.Header, 0, 0)
	self.Alert:SetHeight(32)

	self.AlertBG = self.Alert:CreateTexture(nil, "OVERLAY", 1)
	self.AlertBG:SetPoint("LEFT", self.Alert, 0, 0)
	self.AlertBG:SetSize(32, 32)
	self.AlertBG:SetTexture(Assets:GetTexture("Warning"))
	self.AlertBG:SetVertexColor(1, 0.8, 0.1)

	self.AlertInside = self.Alert:CreateTexture(nil, "OVERLAY", 2)
	self.AlertInside:SetPoint("LEFT", self.Alert, 0, 0)
	self.AlertInside:SetSize(32, 32)
	self.AlertInside:SetTexture(Assets:GetTexture("WarningInner"))
	self.AlertInside:SetVertexColor(0.95, 0.95, 0.95)

	self.Alert.Text = self.Alert:CreateFontString(nil, "OVERLAY")
	self.Alert.Text:SetPoint("LEFT", self.Alert, 30, -1)
	HydraUI:SetFontInfo(self.Alert.Text, Settings["ui-header-font"], Settings["ui-font-size"])
	self.Alert.Text:SetJustifyH("LEFT")
	self.Alert.Text:SetTextColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	self.Alert.Text:SetText("Update available") -- localize

	self.Alert:SetWidth(self.Alert.Text:GetStringWidth() + 32)

	self.Alert:SetScript("OnEnter", function(self)
		self.Text:SetTextColor(1, 1, 1)
	end)

	self.Alert:SetScript("OnLeave", function(self)
		self.Text:SetTextColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	end)

	self.Alert:SetScript("OnMouseDown", function(self)
		self.Text:SetPoint("LEFT", self, 31, -2)

		HydraUI:print(Language["You can get an updated version of HydraUI at https://www.curseforge.com/wow/addons/hydraui"])

		if GUI.UpdateWindow then
			GUI.UpdateWindow:Show()
		else
			GUI:CreateUpdateWindow()
		end
	end)

	self.Alert:SetScript("OnMouseUp", function(self)
		self.Text:SetPoint("LEFT", self, 30, -1)
	end)
end

function GUI:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function GUI:CreateGUI()
	-- This just makes the animation look better. That's all. ಠ_ಠ
	self.BlackTexture = self:CreateTexture(nil, "BACKGROUND")
	self.BlackTexture:SetPoint("TOPLEFT", self, 0, 0)
	self.BlackTexture:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.BlackTexture:SetTexture(Assets:GetTexture("Blank"))
	self.BlackTexture:SetVertexColor(0, 0, 0)

	self:SetFrameStrata("HIGH")
	self:SetSize(GUI_WIDTH, GUI_HEIGHT)
	self:SetPoint("CENTER", HydraUI.UIParent, 0, 0)
	self:SetBackdrop(HydraUI.BackdropAndBorder)
	self:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetClampedToScreen(true)
	self:SetScale(0.2)
	self:Hide()
	self:SetAlpha(0)

	self.ScaleIn = LibMotion:CreateAnimation(self, "Scale")
	self.ScaleIn:SetEasing("in")
	self.ScaleIn:SetDuration(0.2)
	self.ScaleIn:SetChange(1)

	self.FadeIn = LibMotion:CreateAnimation(self, "Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.2)
	self.FadeIn:SetChange(1)

	self.ScaleOut = LibMotion:CreateAnimation(self, "Scale")
	self.ScaleOut:SetEasing("out")
	self.ScaleOut:SetDuration(0.2)
	self.ScaleOut:SetChange(0.2)

	self.FadeOut = LibMotion:CreateAnimation(self, "Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.2)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)

	self.Fader = LibMotion:CreateAnimation(self, "Fade")
	self.Fader:SetDuration(0.5)

	-- Header
	self.Header = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Header:SetSize(HEADER_WIDTH, HEADER_HEIGHT)
	self.Header:SetPoint("TOPLEFT", self, SPACING, -SPACING)
	self.Header:SetBackdrop(HydraUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)

	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	self.Header.Texture:SetPoint("TOPLEFT", self.Header, 1, -1)
	self.Header.Texture:SetPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-header-texture-color"]))

	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetPoint("CENTER", self.Header, 0, -1)
	self.Header.Text:SetSize(HEADER_WIDTH - 6, HEADER_HEIGHT)
	HydraUI:SetFontInfo(self.Header.Text, Settings["ui-header-font"], Settings["ui-title-font-size"])
	self.Header.Text:SetJustifyH("CENTER")
	self.Header.Text:SetTextColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
	self.Header.Text:SetText("Hydra|cFFEAEAEAUI|r")

	-- Menu parent
	self.MenuParent = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.MenuParent:SetWidth(BUTTON_LIST_WIDTH)
	self.MenuParent:SetPoint("BOTTOMLEFT", self, SPACING, SPACING)
	self.MenuParent:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.MenuParent:SetBackdrop(HydraUI.BackdropAndBorder)
	self.MenuParent:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	self.MenuParent:SetBackdropBorderColor(0, 0, 0)
	self.MenuParent:SetScript("OnMouseWheel", MenuParentOnMouseWheel)

	-- Scroll up
	self.ScrollUp = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.ScrollUp:SetSize(16, WIDGET_HEIGHT)
	self.ScrollUp:SetPoint("TOPLEFT", self.MenuParent, "TOPRIGHT", 2, 0)
	self.ScrollUp:SetBackdrop(HydraUI.BackdropAndBorder)
	self.ScrollUp:SetBackdropColor(0, 0, 0, 0)
	self.ScrollUp:SetBackdropBorderColor(0, 0, 0)
	self.ScrollUp:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

		SelectionOnMouseWheel(self:GetParent(), 1)
	end)

	self.ScrollUp:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])

		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)

	self.ScrollUp.Texture = self.ScrollUp:CreateTexture(nil, "ARTWORK")
	self.ScrollUp.Texture:SetPoint("TOPLEFT", self.ScrollUp, 1, -1)
	self.ScrollUp.Texture:SetPoint("BOTTOMRIGHT", self.ScrollUp, -1, 1)
	self.ScrollUp.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.ScrollUp.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

	self.ScrollUp.Highlight = self.ScrollUp:CreateTexture(nil, "HIGHLIGHT")
	self.ScrollUp.Highlight:SetPoint("TOPLEFT", self.ScrollUp, 1, -1)
	self.ScrollUp.Highlight:SetPoint("BOTTOMRIGHT", self.ScrollUp, -1, 1)
	self.ScrollUp.Highlight:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.ScrollUp.Highlight:SetVertexColor(1, 1, 1)
	self.ScrollUp.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)

	self.ScrollUp.Arrow = self.ScrollUp:CreateTexture(nil, "OVERLAY")
	self.ScrollUp.Arrow:SetPoint("CENTER", self.ScrollUp, 0, 0)
	self.ScrollUp.Arrow:SetSize(16, 16)
	self.ScrollUp.Arrow:SetTexture(Assets:GetTexture("Arrow Up"))
	self.ScrollUp.Arrow:SetVertexColor(0.65, 0.65, 0.65)

	-- Scroll down
	self.ScrollDown = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.ScrollDown:SetSize(16, WIDGET_HEIGHT)
	self.ScrollDown:SetPoint("BOTTOMLEFT", self.MenuParent, "BOTTOMRIGHT", 2, 0)
	self.ScrollDown:SetBackdrop(HydraUI.BackdropAndBorder)
	self.ScrollDown:SetBackdropColor(0, 0, 0, 0)
	self.ScrollDown:SetBackdropBorderColor(0, 0, 0)
	self.ScrollDown:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

		SelectionOnMouseWheel(self:GetParent(), -1)
	end)

	self.ScrollDown:SetScript("OnMouseDown", function(self)
		local R, G, B = HydraUI:HexToRGB(Settings["ui-widget-bright-color"])

		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)

	self.ScrollDown.Texture = self.ScrollDown:CreateTexture(nil, "ARTWORK")
	self.ScrollDown.Texture:SetPoint("TOPLEFT", self.ScrollDown, 1, -1)
	self.ScrollDown.Texture:SetPoint("BOTTOMRIGHT", self.ScrollDown, -1, 1)
	self.ScrollDown.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.ScrollDown.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))

	self.ScrollDown.Highlight = self.ScrollDown:CreateTexture(nil, "HIGHLIGHT")
	self.ScrollDown.Highlight:SetPoint("TOPLEFT", self.ScrollDown, 1, -1)
	self.ScrollDown.Highlight:SetPoint("BOTTOMRIGHT", self.ScrollDown, -1, 1)
	self.ScrollDown.Highlight:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	self.ScrollDown.Highlight:SetVertexColor(1, 1, 1)
	self.ScrollDown.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)

	self.ScrollDown.Arrow = self.ScrollDown:CreateTexture(nil, "OVERLAY")
	self.ScrollDown.Arrow:SetPoint("CENTER", self.ScrollDown, 0, 0)
	self.ScrollDown.Arrow:SetSize(16, 16)
	self.ScrollDown.Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
	self.ScrollDown.Arrow:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))

	-- Selection scrollbar
	local ScrollBar = CreateFrame("Slider", nil, self.MenuParent, "BackdropTemplate")
	ScrollBar:SetPoint("TOPLEFT", self.ScrollUp, "BOTTOMLEFT", 0, -2)
	ScrollBar:SetPoint("BOTTOMRIGHT", self.ScrollDown, "TOPRIGHT", 0, 2)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(HydraUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)

	self.ScrollBar = ScrollBar

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
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
	ScrollBar.Progress:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
	ScrollBar.Progress:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)

	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self)
	self.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	self.CloseButton:SetPoint("RIGHT", self.Header, 0, -1)
	self.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("C0392B")) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE")) end)
	self.CloseButton:SetScript("OnMouseUp", function(self)
		GUI.ScaleOut:Play()
		GUI.FadeOut:Play()

		if (GUI.ColorPicker and GUI.ColorPicker:GetAlpha() > 0) then
			GUI.ColorPicker.FadeOut:Play()
		end
	end)

	self.CloseButton.Cross = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Cross:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Cross:SetSize(16, 16)
	self.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	self.CloseButton.Cross:SetVertexColor(HydraUI:HexToRGB("EEEEEE"))

	for i = 1, #self.ButtonQueue do
		self:CreateWindow(unpack(tremove(self.ButtonQueue, 1)))
	end

	self:SortMenuButtons()

	self.ScrollBar:SetMinMaxValues(1, ((self.NumShownButtons or 15) - MAX_WIDGETS_SHOWN) + 1)
	self.ScrollBar:SetValue(1)
	self:SetSelectionOffset(1)
	self.ScrollBar:Show()

	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:SetScript("OnEvent", self.OnEvent)

	self:ShowWindow("General", "General")

	if self.QueueAlert then
		self.QueueAlert = nil
		self:CreateUpdateAlert()
	end

	self.Loaded = true
end

function GUI:Toggle()
	if (not self.Loaded) then
		self:CreateGUI()
	end

	if self:IsShown() then
		self.FadeOut:Play()
		self.ScaleOut:Play()
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")

		if Settings["gui-enable-fade"] then
			self:UnregisterEvent("PLAYER_STARTED_MOVING")
			self:UnregisterEvent("PLAYER_STOPPED_MOVING")
		end
	else
		if (Settings["gui-hide-in-combat"] and InCombatLockdown()) then
			HydraUI:print(ERR_NOT_IN_COMBAT)

			return
		end

		if Settings["gui-enable-fade"] then
			self:RegisterEvent("PLAYER_STARTED_MOVING")
			self:RegisterEvent("PLAYER_STOPPED_MOVING")
		end

		if (not self.FirstToggle) then
			C_Timer.After(0.2, function()
				self:Show()
				self.FadeIn:Play()
				self.ScaleIn:Play()
			end)

			self.FirstToggle = true
		else
			self:Show()
			self.FadeIn:Play()
			self.ScaleIn:Play()
		end

		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end
end

function GUI:PLAYER_REGEN_DISABLED()
	if (Settings["gui-hide-in-combat"] and self:IsVisible()) then
		self:SetAlpha(0)
		self:Hide()
		--CloseLastDropdown()
		self.WasCombatClosed = true
	end
end

local ReopenWindow = function()
	GUI:SetAlpha(0)
	GUI:Show()
	GUI.ScaleIn:Play()
	GUI.FadeIn:Play()
end

function GUI:PLAYER_REGEN_ENABLED()
	if (Settings["gui-hide-in-combat"] and self.WasCombatClosed) then
		HydraUI:DisplayPopup(Language["Attention"], Language["The settings window was automatically closed due to combat. Would you like to open it again?"], ACCEPT, ReopenWindow, CANCEL)
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