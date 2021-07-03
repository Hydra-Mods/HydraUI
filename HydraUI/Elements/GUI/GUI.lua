local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

-- Constants
local SPACING = 3
local WIDGET_HEIGHT = 20
local GROUP_WIDTH = 270
local BUTTON_LIST_WIDTH = 112 -- 126
local GUI_WIDTH = 710
local GUI_HEIGHT = 340
local HEADER_WIDTH = GUI_WIDTH - (SPACING * 2)
local HEADER_HEIGHT = 20
local HEADER_SPACING = 5
local PARENT_WIDTH = GUI_WIDTH - BUTTON_LIST_WIDTH - ((SPACING * 2) + 2)
local MENU_BUTTON_WIDTH = BUTTON_LIST_WIDTH - (SPACING * 2)
local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local MAX_WIDGETS_SHOWN = 14

-- Locals
local type = type
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local floor = math.floor

-- Storage
GUI.Categories = {}
GUI.Widgets = {}
GUI.WidgetID = {}
GUI.LoadCalls = {}
GUI.Buttons = {}
GUI.ButtonQueue = {}
GUI.ScrollButtons = {}
GUI.WindowHooks = {onshow = {}, onhide = {}}

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

function GUI:SortButtons()
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
	Window.LeftWidgetsBG:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG:SetPoint("TOPLEFT", Window, 0, 0)
	Window.LeftWidgetsBG:SetPoint("BOTTOMLEFT", Window, 0, 0)
	
	Window.LeftWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.LeftWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG.Backdrop:SetPoint("TOPLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetBackdrop(HydraUI.BackdropAndBorder)
	Window.LeftWidgetsBG.Backdrop:SetBackdropColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.LeftWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	Window.RightWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG:SetPoint("TOPLEFT", Window.LeftWidgetsBG, "TOPRIGHT", 2, 0)
	Window.RightWidgetsBG:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, "BOTTOMRIGHT", 2, 0)
	
	Window.RightWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.RightWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH + (SPACING * 2))
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
							
							self.Categories[i].Buttons[j].Children[o].FadeIn:Play()
							self.Categories[i].Buttons[j].Children[o].Window:Show()
						elseif self.Categories[i].Buttons[j].Children[o].Window then
							self.Categories[i].Buttons[j].Children[o].Window:Hide()
							
							if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
								self.Categories[i].Buttons[j].Children[o].FadeOut:Play()
							end
						end
					end
					
					if (self.Categories[i].Buttons[j].Selected:GetAlpha() > 0) then
						self.Categories[i].Buttons[j].FadeOut:Play()
					end
				elseif self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
				end
			elseif (self.Categories[i].Name == category) and (self.Categories[i].Buttons[j].Name == name) then
				if (not self.Categories[i].Buttons[j].Window) then
					self.Categories[i].Buttons[j].Window = self:CreateWidgetWindow(category, name, parent)
				end
				
				self.Categories[i].Buttons[j].FadeIn:Play()
				self.Categories[i].Buttons[j].Window:Show()
				
				if self.Categories[i].Buttons[j].Children then
					if self.Categories[i].Buttons[j].ChildrenShown then
						self.Categories[i].Buttons[j].Arrow:SetTexture(Assets:GetTexture("Arrow Down"))
						
						for o = 1, #self.Categories[i].Buttons[j].Children do
							if self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()
								
								if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
									self.Categories[i].Buttons[j].Children[o].FadeOut:Play()
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
									self.Categories[i].Buttons[j].Children[o].FadeOut:Play()
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
						self.Categories[i].Buttons[j].FadeOut:Play()
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
	--[[if self.Texture then
		self.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-button-texture-color"]))
	end]]
	
	GUI:ShowWindow(self.Category, self.Name, self.Parent)
end

local WindowButtonOnMouseDown = function(self)
	--[[if (not self.Texture) then
		return
	end

	local R, G, B = HydraUI:HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)]]
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
	Button:SetScript("OnMouseUp", WindowButtonOnMouseUp)
	Button:SetScript("OnMouseDown", WindowButtonOnMouseDown)
	
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
	
	Button.Fade = CreateAnimationGroup(Button.Selected)
	
	Button.FadeIn = Button.Fade:CreateAnimation("Fade")
	Button.FadeIn:SetEasing("in")
	Button.FadeIn:SetDuration(0.15)
	Button.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Button.FadeOut = Button.Fade:CreateAnimation("Fade")
	Button.FadeOut:SetEasing("out")
	Button.FadeOut:SetDuration(0.15)
	Button.FadeOut:SetChange(0)
	
	if parent then
		Button.Parent = parent
		
		Button.Selected:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-color"]))
		
		Button.Text:SetPoint("LEFT", Button, SPACING * 3, 0)
		Button.Text:SetJustifyH("LEFT")
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
		Button.Selected:SetVertexColor(HydraUI:HexToRGB(Settings["ui-widget-bright-color"]))
		
		Button.Text:SetPoint("LEFT", Button, 4, 0)
		Button.Text:SetJustifyH("LEFT")
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

function GUI:AddWindowHook(hook, category, name, arg1, arg2)
	if (not self.WindowHooks[hook][category]) then
		self.WindowHooks[hook][category] = {}
	end
	
	if (not self.WindowHooks[hook][category][name]) then
		self.WindowHooks[hook][category][name] = {Hooks = {}}
	end
	
	if (type(arg1) == "function") then
		tinsert(self.WindowHooks[hook][category][name].Hooks, arg1)
	else -- string
		if (not self.WindowHooks[hook][category][arg1].Children) then
			self.WindowHooks[hook][category][arg1].Children = {}
		end
		
		self.WindowHooks[hook][category][arg1].Children[name] = {Hooks = {}}
		
		tinsert(self.WindowHooks[hook][category][arg1].Children[name].Hooks, arg2)
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
	
	self.Group = CreateAnimationGroup(self)
	
	self.ScaleIn = self.Group:CreateAnimation("Scale")
	self.ScaleIn:SetEasing("in")
	self.ScaleIn:SetDuration(0.15)
	self.ScaleIn:SetChange(1)
	
	self.FadeIn = self.Group:CreateAnimation("Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.15)
	self.FadeIn:SetChange(1)
	
	self.ScaleOut = self.Group:CreateAnimation("Scale")
	self.ScaleOut:SetEasing("out")
	self.ScaleOut:SetDuration(0.15)
	self.ScaleOut:SetChange(0.2)
	
	self.FadeOut = self.Group:CreateAnimation("Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.15)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.Fader = self.Group:CreateAnimation("Fade")
	self.Fader:SetDuration(0.15)
	
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
	--self.Header.Text:SetText(format(Language["- Hydra|cFFEAEAUI|r version %s -"], HydraUI.UIVersion))
	--self.Header.Text:SetText(Language["- Hydra|cFFEAEAEAUI|r -"])
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
	
	self:SortButtons()
	
	self.ScrollBar:SetMinMaxValues(1, ((self.NumShownButtons or 15) - MAX_WIDGETS_SHOWN) + 1)
	self.ScrollBar:SetValue(1)
	self:SetSelectionOffset(1)
	self.ScrollBar:Show()
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:SetScript("OnEvent", self.OnEvent)
	
	self:ShowWindow("General", "General")
	
	self.Loaded = true
end

function GUI:Toggle()
	if (not self.Loaded) then
		self:CreateGUI()
	end
	
	if self:IsShown() then
		self.ScaleOut:Play()
		self.FadeOut:Play()
		
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
		
		if Settings["gui-enable-fade"] then
			self:UnregisterEvent("PLAYER_STARTED_MOVING")
			self:UnregisterEvent("PLAYER_STOPPED_MOVING")
		end
	else
		if (not self.Loaded) then
			self:CreateGUI()
		end
		
		if (Settings["gui-hide-in-combat"] and InCombatLockdown()) then
			HydraUI:print(ERR_NOT_IN_COMBAT)
			
			return
		end
		
		if Settings["gui-enable-fade"] then
			self:RegisterEvent("PLAYER_STARTED_MOVING")
			self:RegisterEvent("PLAYER_STOPPED_MOVING")
		end
		
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
		self:SetAlpha(0)
		self:Show()
		self.ScaleIn:Play()
		self.FadeIn:Play()
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
		HydraUI:DisplayPopup(Language["Attention"], Language["The settings window was automatically closed due to combat. Would you like to open it again?"], Language["Accept"], ReopenWindow, Language["Decline"])
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