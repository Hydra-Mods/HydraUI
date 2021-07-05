local HydraUI, GUI, Language, Assets, Settings, Defaults = select(2, ...):get()

local AB = HydraUI:NewModule("Action Bars")

local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

local NumPad = KEY_NUMPAD1:gsub("%s%S$", "")
local WheelUp = KEY_MOUSEWHEELUP
local WheelDown = KEY_MOUSEWHEELDOWN
local MouseButton = KEY_BUTTON4:gsub("%s%S$", "")
local MiddleButton = KEY_BUTTON3

-- Action Bars
Defaults["ab-enable"] = true

Defaults["ab-show-hotkey"] = true
Defaults["ab-show-count"] = true
Defaults["ab-show-macro"] = true

Defaults["ab-font"] = "PT Sans"
Defaults["ab-font-size"] = 12
Defaults["ab-cd-size"] = 18
Defaults["ab-font-flags"] = ""

Defaults["ab-bar1-enable"] = true
Defaults["ab-bar1-hover"] = false
Defaults["ab-bar1-button-size"] = 32
Defaults["ab-bar1-button-gap"] = 2
Defaults["ab-bar1-button-max"] = 12
Defaults["ab-bar1-per-row"] = 12
Defaults["ab-bar1-alpha"] = 100

Defaults["ab-bar2-enable"] = true
Defaults["ab-bar2-hover"] = false
Defaults["ab-bar2-button-size"] = 32
Defaults["ab-bar2-button-gap"] = 2
Defaults["ab-bar2-button-max"] = 12
Defaults["ab-bar2-per-row"] = 12
Defaults["ab-bar2-alpha"] = 100

Defaults["ab-bar3-enable"] = true
Defaults["ab-bar3-hover"] = false
Defaults["ab-bar3-button-size"] = 32
Defaults["ab-bar3-button-gap"] = 2
Defaults["ab-bar3-button-max"] = 12
Defaults["ab-bar3-per-row"] = 12
Defaults["ab-bar3-alpha"] = 100

Defaults["ab-bar4-enable"] = true
Defaults["ab-bar4-hover"] = false
Defaults["ab-bar4-button-size"] = 32
Defaults["ab-bar4-button-gap"] = 2
Defaults["ab-bar4-button-max"] = 12
Defaults["ab-bar4-per-row"] = 1
Defaults["ab-bar4-alpha"] = 100

Defaults["ab-bar5-enable"] = true
Defaults["ab-bar5-hover"] = false
Defaults["ab-bar5-button-size"] = 32
Defaults["ab-bar5-button-gap"] = 2
Defaults["ab-bar5-button-max"] = 12
Defaults["ab-bar5-per-row"] = 1
Defaults["ab-bar5-alpha"] = 100

Defaults["ab-pet-enable"] = true
Defaults["ab-pet-hover"] = false
Defaults["ab-pet-button-size"] = 32
Defaults["ab-pet-button-gap"] = 2
Defaults["ab-pet-per-row"] = 1
Defaults["ab-pet-alpha"] = 100

Defaults["ab-stance-enable"] = true
Defaults["ab-stance-hover"] = false
Defaults["ab-stance-button-size"] = 32
Defaults["ab-stance-button-gap"] = 2
Defaults["ab-stance-per-row"] = 12
Defaults["ab-stance-alpha"] = 100

function AB:Disable(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	
	object:SetParent(self.Hide)
end

function AB:DisableBar(bar)
	bar:Hide()
end

function AB:PositionButtons(bar, numbuttons, perrow, size, spacing)
	if (numbuttons < perrow) then
		perrow = numbuttons
	end
	
	local Columns = ceil(numbuttons / perrow)
	
	if (Columns < 1) then
		Columns = 1
	end
	
	-- Bar sizing
	bar:SetWidth((size * perrow) + (spacing * (perrow - 1)))
	bar:SetHeight((size * Columns) + (spacing * (Columns - 1)))
	
	-- Actual moving
	for i = 1, #bar do
		local Button = bar[i]
		
		Button:ClearAllPoints()
		Button:SetSize(size, size)
		
		if (i == 1) then
			Button:SetPoint("TOPLEFT", bar, 0, 0)
		elseif ((i - 1) % perrow == 0) then
			Button:SetPoint("TOP", bar[i - perrow], "BOTTOM", 0, -spacing)
		else
			Button:SetPoint("LEFT", bar[i - 1], "RIGHT", spacing, 0)
		end
		
		if (i > numbuttons) then
			Button:SetParent(self.Hide)
		else
			Button:SetParent(bar.ButtonParent or bar)
		end
	end
end

function AB:StyleActionButton(button)
	if button.Styled then
		return
	end
	
	button:SetNormalTexture("")
	
	if button.action then
		button:SetAttribute("showgrid", 2)
		ActionButton_ShowGrid(button)
	end
	
	if button.Border then
		button.Border:SetTexture(nil)
	end
	
	if button.icon then
		button.icon:ClearAllPoints()
		button.icon:SetPoint("TOPLEFT", button, 1, -1)
		button.icon:SetPoint("BOTTOMRIGHT", button, -1, 1)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	
	if _G[button:GetName() .. "FloatingBG"] then
		self:Disable(_G[button:GetName() .. "FloatingBG"])
	end
	
	if button.HotKey then
		button.HotKey:ClearAllPoints()
		button.HotKey:SetPoint("TOPLEFT", button, 2, -3)
		HydraUI:SetFontInfo(button.HotKey, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.HotKey:SetJustifyH("LEFT")
		button.HotKey:SetDrawLayer("OVERLAY")
		button.HotKey:SetTextColor(1, 1, 1)
		button.HotKey.SetTextColor = function() end
		
		local HotKeyText = button.HotKey:GetText()
		
		if HotKeyText then
			HotKeyText = HotKeyText:gsub(NumPad, "N")
			HotKeyText = HotKeyText:gsub(WheelUp, "MWU")
			HotKeyText = HotKeyText:gsub(WheelDown, "MWD")
			HotKeyText = HotKeyText:gsub(MouseButton, "MB")
			HotKeyText = HotKeyText:gsub(MiddleButton, "MMB")
			
			button.HotKey:SetText("|cFFFFFFFF" .. HotKeyText .. "|r")
		end
		
		button.HotKey.OST = button.HotKey.SetText
		button.HotKey.SetText = function(self, text)
			self:OST("|cFFFFFFFF" .. text .. "|r")
		end
		
		if (not Settings["ab-show-hotkey"]) then
			button.HotKey:SetAlpha(0)
		end
	end
	
	if button.Name then
		button.Name:ClearAllPoints()
		button.Name:SetPoint("BOTTOMLEFT", button, 2, 2)
		button.Name:SetWidth(button:GetWidth() - 4)
		HydraUI:SetFontInfo(button.Name, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.Name:SetJustifyH("LEFT")
		button.Name:SetDrawLayer("OVERLAY")
		button.Name:SetTextColor(1, 1, 1)
		button.Name.SetTextColor = function() end
		
		if (not Settings["ab-show-macro"]) then
			button.Name:SetAlpha(0)
		end
	end
	
	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetPoint("TOPRIGHT", button, -2, -2)
		HydraUI:SetFontInfo(button.Count, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetDrawLayer("OVERLAY")
		button.Count:SetTextColor(1, 1, 1)
		button.Count.SetTextColor = function() end
		
		if (not Settings["ab-show-count"]) then
			button.Count:SetAlpha(0)
		end
	end
	
	button.Backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
	button.Backdrop:SetPoint("TOPLEFT", button, 0, 0)
	button.Backdrop:SetPoint("BOTTOMRIGHT", button, 0, 0)
	button.Backdrop:SetBackdrop(HydraUI.Backdrop)
	button.Backdrop:SetBackdropColor(0, 0, 0)
	button.Backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
	
	button.Backdrop.Texture = button.Backdrop:CreateTexture(nil, "BACKDROP")
	button.Backdrop.Texture:SetPoint("TOPLEFT", button.Backdrop, 1, -1)
	button.Backdrop.Texture:SetPoint("BOTTOMRIGHT", button.Backdrop, -1, 1)
	button.Backdrop.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	button.Backdrop.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	local Checked = button:GetCheckedTexture()
	Checked:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Checked:SetColorTexture(0.1, 0.9, 0.1, 0.2)
	Checked:SetPoint("TOPLEFT", button, 1, -1)
	Checked:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	if button:GetPushedTexture() then
		local Pushed = button:GetPushedTexture()
		Pushed:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
		Pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		Pushed:SetPoint("TOPLEFT", button, 1, -1)
		Pushed:SetPoint("BOTTOMRIGHT", button, -1, 1)
	end
	
	local Highlight = button:GetHighlightTexture()
	Highlight:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Highlight:SetColorTexture(1, 1, 1, 0.2)
	Highlight:SetPoint("TOPLEFT", button, 1, -1)
	Highlight:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	if button.Flash then
		--button.Flash:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
		button.Flash:SetVertexColor(0.7, 0.7, 0.1, 0.3)
		button.Flash:SetPoint("TOPLEFT", button, 1, -1)
		button.Flash:SetPoint("BOTTOMRIGHT", button, -1, 1)
	end
	
	local Range = button:CreateTexture(nil, "ARTWORK", button)
	Range:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Range:SetVertexColor(0.7, 0, 0)
	Range:SetPoint("TOPLEFT", button, 1, -1)
	Range:SetPoint("BOTTOMRIGHT", button, -1, 1)
	Range:SetAlpha(0)
	
	button.Range = Range
	
	if button.cooldown then
		button.cooldown:ClearAllPoints()
		button.cooldown:SetPoint("TOPLEFT", button, 1, -1)
		button.cooldown:SetPoint("BOTTOMRIGHT", button, -1, 1)
		
		button.cooldown:SetDrawEdge(true)
		button.cooldown:SetEdgeTexture(Assets:GetTexture("Blank"))
		button.cooldown:SetSwipeColor(0, 0, 0, 1)
		
		local FontString = button.cooldown:GetRegions()
		
		if FontString then
			HydraUI:SetFontInfo(FontString, Settings["ab-font"], Settings["ab-cd-size"], Settings["ab-font-flags"])
		end
	end
	
	button:SetFrameLevel(15)
	button:SetFrameStrata("MEDIUM")
	
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	
	button.Styled = true
end

function AB:StylePetActionButton(button)
	if button.Styled then
		return
	end
	
	button:SetSize(Settings["ab-pet-button-size"], Settings["ab-pet-button-size"])
	
	local Name = button:GetName()
	local Shine = _G[Name .. "Shine"]
	
	Shine:SetSize(Settings["ab-pet-button-size"] - 6, Settings["ab-pet-button-size"] - 6)
	Shine:ClearAllPoints()
	Shine:SetPoint("CENTER", button, 0, 0)
	
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.icon:SetDrawLayer("BACKGROUND", 7)
	button.icon:SetPoint("TOPLEFT", button, 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	button:SetNormalTexture("")
	
	if button.HotKey then
		button.HotKey:ClearAllPoints()
		button.HotKey:SetPoint("TOPLEFT", button, 2, -3)
		HydraUI:SetFontInfo(button.HotKey, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.HotKey:SetJustifyH("LEFT")
		button.HotKey:SetDrawLayer("OVERLAY")
		button.HotKey:SetTextColor(1, 1, 1)
		button.HotKey.SetTextColor = function() end
		
		local HotKeyText = button.HotKey:GetText()
		
		if HotKeyText then
			button.HotKey:SetText("|cFFFFFFFF" .. HotKeyText .. "|r")
		end
		
		button.HotKey.OST = button.HotKey.SetText
		button.HotKey.SetText = function(self, text)
			self:OST("|cFFFFFFFF" .. text .. "|r")
		end
		
		if (not Settings["ab-show-hotkey"]) then
			button.HotKey:SetAlpha(0)
		end
	end
	
	if button.Name then
		button.Name:ClearAllPoints()
		button.Name:SetPoint("BOTTOMLEFT", button, 2, 2)
		button.Name:SetWidth(button:GetWidth() - 4)
		HydraUI:SetFontInfo(button.Name, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.Name:SetJustifyH("LEFT")
		button.Name:SetDrawLayer("OVERLAY")
		button.Name:SetTextColor(1, 1, 1)
		button.Name.SetTextColor = function() end
		
		if (not Settings["action-bars-show-macro-names"]) then
			button.Name:SetAlpha(0)
		end
	end
	
	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetPoint("TOPRIGHT", button, -2, -2)
		HydraUI:SetFontInfo(button.Count, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetDrawLayer("OVERLAY")
		button.Count:SetTextColor(1, 1, 1)
		button.Count.SetTextColor = function() end
		
		if (not Settings["action-bars-show-count"]) then
			button.Count:SetAlpha(0)
		end
	end
	
	_G[Name.."Flash"]:SetTexture("")
	
	if _G[Name .. "NormalTexture2"] then
		_G[Name .. "NormalTexture2"]:Hide()
	end
	
	local Checked = button:GetCheckedTexture()
	Checked:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Checked:SetColorTexture(0.1, 0.9, 0.1, 0.3)
	Checked:SetPoint("TOPLEFT", button, 1, -1)
	Checked:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	local Pushed = button:GetPushedTexture()
	Pushed:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
	Pushed:SetPoint("TOPLEFT", button, 1, -1)
	Pushed:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	local Highlight = button:GetHighlightTexture()
	Highlight:SetTexture(Assets:GetTexture(Settings["action-bars-button-highlight"]))
	Highlight:SetColorTexture(1, 1, 1, 0.2)
	Highlight:SetPoint("TOPLEFT", button, 1, -1)
	Highlight:SetPoint("BOTTOMRIGHT", button, -1, 1)
	
	button.Backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
	button.Backdrop:SetPoint("TOPLEFT", button, 0, 0)
	button.Backdrop:SetPoint("BOTTOMRIGHT", button, 0, 0)
	button.Backdrop:SetBackdrop(HydraUI.Backdrop)
	button.Backdrop:SetBackdropColor(0, 0, 0)
	button.Backdrop:SetFrameLevel(button:GetFrameLevel() - 1)
	
	button.Backdrop.Texture = button.Backdrop:CreateTexture(nil, "BACKDROP")
	button.Backdrop.Texture:SetPoint("TOPLEFT", button.Backdrop, 1, -1)
	button.Backdrop.Texture:SetPoint("BOTTOMRIGHT", button.Backdrop, -1, 1)
	button.Backdrop.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	button.Backdrop.Texture:SetVertexColor(HydraUI:HexToRGB(Settings["ui-window-main-color"]))
	
	button.Styled = true
end

function AB:PetActionBar_Update()
	for i = 1, NUM_PET_ACTION_SLOTS do
		AB.PetBar[i]:SetNormalTexture("")
	end
end

function AB:StanceBar_UpdateState()
	if (GetNumShapeshiftForms() > 0) then
		if (not AB.StanceBar:IsShown()) then
			AB.StanceBar:Show()
		end
	elseif AB.StanceBar:IsShown() then
		AB.StanceBar:Hide()
	end
end

function AB:UpdateButtonStatus()
	local IsUsable, NoMana = IsUsableAction(self.action)
	
	if IsUsable then
		if (IsActionInRange(self.action) == false) then
			self.icon:SetVertexColor(HydraUI:HexToRGB("FF4C19"))
		else
			self.icon:SetVertexColor(HydraUI:HexToRGB("FFFFFF"))
		end
	elseif NoMana then
		self.icon:SetVertexColor(HydraUI:HexToRGB("3498D8"))
	else
		self.icon:SetVertexColor(HydraUI:HexToRGB("4C4C4C"))
	end
end

local BarButtonOnEnter = function(self)
	if self.ParentBar.Fader:IsPlaying() then
		self.ParentBar.Fader:Stop()
	end
	
	for i = 1, #self.ParentBar do
		self.ParentBar[i].cooldown:SetDrawBling(true)
	end
	
	self.ParentBar.Fader:SetChange(self.ParentBar.MaxAlpha / 100)
	self.ParentBar.Fader:Play()
end

local BarButtonOnLeave = function(self)
	if self.ParentBar.Fader:IsPlaying() then
		self.ParentBar.Fader:Stop()
	end
	
	for i = 1, #self.ParentBar do
		self.ParentBar[i].cooldown:SetDrawBling(false)
	end
	
	self.ParentBar.Fader:SetChange(self.ParentBar.ShouldFade and 0 or (self.ParentBar.MaxAlpha / 100))
	self.ParentBar.Fader:Play()
end

local BarOnEnter = function(self)
	if self.Fader:IsPlaying() then
		self.Fader:Stop()
	end
	
	for i = 1, #self do
		self[i].cooldown:SetDrawBling(true)
	end
	
	self.Fader:SetChange(self.MaxAlpha / 100)
	self.Fader:Play()
end

local BarOnLeave = function(self)
	if self.Fader:IsPlaying() then
		self.Fader:Stop()
	end
	
	for i = 1, #self do
		self[i].cooldown:SetDrawBling(false)
	end
	
	self.Fader:SetChange(self.ShouldFade and 0 or (self.MaxAlpha / 100))
	self.Fader:Play()
end

-- Bar 1
function AB:CreateBar1()
	self.Bar1 = CreateFrame("Frame", "HydraUI Action Bar 1", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.Bar1:SetPoint("BOTTOM", HydraUI.UIParent, "BOTTOM", 0, 13)
	self.Bar1:SetAlpha(Settings["ab-bar1-alpha"] / 100)
	self.Bar1.ShouldFade = Settings["ab-bar1-hover"]
	self.Bar1.MaxAlpha = Settings["ab-bar1-alpha"]
	
	self.Bar1.Fader = CreateAnimationGroup(self.Bar1):CreateAnimation("Fade")
	self.Bar1.Fader:SetDuration(0.15)
	self.Bar1.Fader:SetEasing("inout")
	
	if Settings["ab-bar1-hover"] then
		self.Bar1:SetAlpha(0)
		self.Bar1:SetScript("OnEnter", BarOnEnter)
		self.Bar1:SetScript("OnLeave", BarOnLeave)
	end
	
	for i = 1, 12 do
		local Button = _G["ActionButton" .. i]
		
		self:StyleActionButton(Button)
		
		Button:SetParent(self.Bar1)
		Button.ParentBar = self.Bar1
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.Bar1:SetFrameRef("Button" .. i, Button)
		
		self.Bar1[i] = Button
	end
	
	self.Bar1:Execute([[
		Buttons = table.new()
		
		for i = 1, 12 do
			table.insert(Buttons, self:GetFrameRef("Button" .. i))
		end
	]])
	
	self.Bar1:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end
		
		for i = 1, 12 do
			Buttons[i]:SetAttribute("actionpage", newstate)
		end
	]])
	
	RegisterStateDriver(self.Bar1, "page", "[vehicleui] 12; [possessbar] 12; [overridebar] 14; [shapeshift] 13; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10; [form] 1; 1")
	
	self:PositionButtons(self.Bar1, Settings["ab-bar1-button-max"], Settings["ab-bar1-per-row"], Settings["ab-bar1-button-size"], Settings["ab-bar1-button-gap"])
	
	if Settings["ab-bar1-enable"] then
		self.Bar1:Show()
	else
		self.Bar1:Hide()
	end
end

-- Bar 2
function AB:CreateBar2()
	self.Bar2 = CreateFrame("Frame", "HydraUI Action Bar 2", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.Bar2:SetPoint("BOTTOM", self.Bar1, "TOP", 0, Settings["ab-bar2-button-gap"])
	self.Bar2:SetAlpha(Settings["ab-bar2-alpha"] / 100)
	self.Bar2.ButtonParent = MultiBarBottomLeft
	self.Bar2.ShouldFade = Settings["ab-bar2-hover"]
	self.Bar2.MaxAlpha = Settings["ab-bar2-alpha"]
	
	self.Bar2.Fader = CreateAnimationGroup(self.Bar2):CreateAnimation("Fade")
	self.Bar2.Fader:SetDuration(0.15)
	self.Bar2.Fader:SetEasing("inout")
	
	if Settings["ab-bar2-hover"] then
		self.Bar2:SetAlpha(0)
		self.Bar2:SetScript("OnEnter", BarOnEnter)
		self.Bar2:SetScript("OnLeave", BarOnLeave)
	end
	
	MultiBarBottomLeft:SetParent(self.Bar2)
	
	for i = 1, 12 do
		local Button = _G["MultiBarBottomLeftButton" .. i]
		
		self:StyleActionButton(Button)
		
		Button.ParentBar = self.Bar2
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.Bar2[i] = Button
	end
	
	self:PositionButtons(self.Bar2, Settings["ab-bar2-button-max"], Settings["ab-bar2-per-row"], Settings["ab-bar2-button-size"], Settings["ab-bar2-button-gap"])
	
	if Settings["ab-bar2-enable"] then
		self.Bar2:Show()
	else
		self.Bar2:Hide()
	end
end

-- Bar 3
function AB:CreateBar3()
	self.Bar3 = CreateFrame("Frame", "HydraUI Action Bar 3", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.Bar3:SetPoint("BOTTOM", self.Bar2, "TOP", 0, Settings["ab-bar3-button-gap"])
	self.Bar3:SetAlpha(Settings["ab-bar3-alpha"] / 100)
	self.Bar3.ButtonParent = MultiBarBottomRight
	self.Bar3.ShouldFade = Settings["ab-bar3-hover"]
	self.Bar3.MaxAlpha = Settings["ab-bar3-alpha"]
	
	self.Bar3.Fader = CreateAnimationGroup(self.Bar3):CreateAnimation("Fade")
	self.Bar3.Fader:SetDuration(0.15)
	self.Bar3.Fader:SetEasing("inout")
	
	if Settings["ab-bar3-hover"] then
		self.Bar3:SetAlpha(0)
		self.Bar3:SetScript("OnEnter", BarOnEnter)
		self.Bar3:SetScript("OnLeave", BarOnLeave)
	end
	
	MultiBarBottomRight:SetParent(self.Bar3)
	
	for i = 1, 12 do
		local Button = _G["MultiBarBottomRightButton" .. i]
		
		self:StyleActionButton(Button)
		
		Button.ParentBar = self.Bar3
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.Bar3[i] = Button
	end
	
	self:PositionButtons(self.Bar3, Settings["ab-bar3-button-max"], Settings["ab-bar3-per-row"], Settings["ab-bar3-button-size"], Settings["ab-bar3-button-gap"])
	
	if Settings["ab-bar3-enable"] then
		self.Bar3:Show()
	else
		self.Bar3:Hide()
	end
end

-- Bar 4
function AB:CreateBar4()
	self.Bar4 = CreateFrame("Frame", "HydraUI Action Bar 4", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.Bar4:SetPoint("RIGHT", HydraUI.UIParent, -12, 0)
	self.Bar4:SetAlpha(Settings["ab-bar4-alpha"] / 100)
	self.Bar4.ButtonParent = MultiBarRight
	self.Bar4.ShouldFade = Settings["ab-bar4-hover"]
	self.Bar4.MaxAlpha = Settings["ab-bar4-alpha"]
	
	self.Bar4.Fader = CreateAnimationGroup(self.Bar4):CreateAnimation("Fade")
	self.Bar4.Fader:SetDuration(0.15)
	self.Bar4.Fader:SetEasing("inout")
	
	if Settings["ab-bar4-hover"] then
		self.Bar4:SetAlpha(0)
		self.Bar4:SetScript("OnEnter", BarOnEnter)
		self.Bar4:SetScript("OnLeave", BarOnLeave)
	end
	
	MultiBarRight:SetParent(self.Bar4)
	
	for i = 1, 12 do
		local Button = _G["MultiBarRightButton" .. i]
		
		self:StyleActionButton(Button)
		
		Button.ParentBar = self.Bar4
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.Bar4[i] = Button
	end
	
	self:PositionButtons(self.Bar4, Settings["ab-bar4-button-max"], Settings["ab-bar4-per-row"], Settings["ab-bar4-button-size"], Settings["ab-bar4-button-gap"])
	
	if Settings["ab-bar4-enable"] then
		self.Bar4:Show()
	else
		self.Bar4:Hide()
	end
end

-- Bar 5
function AB:CreateBar5()
	self.Bar5 = CreateFrame("Frame", "HydraUI Action Bar 5", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.Bar5:SetPoint("RIGHT", self.Bar4, "LEFT", -Settings["ab-bar5-button-gap"], 0)
	self.Bar5:SetAlpha(Settings["ab-bar5-alpha"] / 100)
	self.Bar5.ButtonParent = MultiBarLeft
	self.Bar5.ShouldFade = Settings["ab-bar5-hover"]
	self.Bar5.MaxAlpha = Settings["ab-bar5-alpha"]
	
	self.Bar5.Fader = CreateAnimationGroup(self.Bar5):CreateAnimation("Fade")
	self.Bar5.Fader:SetDuration(0.15)
	self.Bar5.Fader:SetEasing("inout")
	
	if Settings["ab-bar5-hover"] then
		self.Bar5:SetAlpha(0)
		self.Bar5:SetScript("OnEnter", BarOnEnter)
		self.Bar5:SetScript("OnLeave", BarOnLeave)
	end
	
	MultiBarLeft:SetParent(self.Bar5)
	
	for i = 1, 12 do
		local Button = _G["MultiBarLeftButton" .. i]
		
		self:StyleActionButton(Button)
		
		Button.ParentBar = self.Bar5
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.Bar5[i] = Button
	end
	
	self:PositionButtons(self.Bar5, Settings["ab-bar5-button-max"], Settings["ab-bar5-per-row"], Settings["ab-bar5-button-size"], Settings["ab-bar5-button-gap"])
	
	if Settings["ab-bar5-enable"] then
		self.Bar5:Show()
	else
		self.Bar5:Hide()
	end
end

-- Pet
function AB:CreatePetBar()
	self.PetBar = CreateFrame("Frame", "HydraUI Pet Bar", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.PetBar:SetPoint("RIGHT", self.Bar5, "LEFT", -Settings["ab-pet-button-gap"], 0)
	self.PetBar:SetAlpha(Settings["ab-pet-alpha"] / 100)
	self.PetBar.ButtonParent = PetActionBarFrame
	self.PetBar.ShouldFade = Settings["ab-pet-hover"]
	self.PetBar.MaxAlpha = Settings["ab-pet-alpha"]
	
	self.PetBar.Fader = CreateAnimationGroup(self.PetBar):CreateAnimation("Fade")
	self.PetBar.Fader:SetDuration(0.15)
	self.PetBar.Fader:SetEasing("inout")
	
	if Settings["ab-pet-hover"] then
		self.PetBar:SetAlpha(0)
		self.PetBar:SetScript("OnEnter", BarOnEnter)
		self.PetBar:SetScript("OnLeave", BarOnLeave)
	end
	
	PetActionBarFrame:SetParent(self.PetBar)
	
	for i = 1, NUM_PET_ACTION_SLOTS do
		local Button = _G["PetActionButton" .. i]
		
		self:StylePetActionButton(Button)
		
		Button.ParentBar = self.PetBar
		
		Button:HookScript("OnEnter", BarButtonOnEnter)
		Button:HookScript("OnLeave", BarButtonOnLeave)
		
		self.PetBar[i] = Button
	end
	
	self:PositionButtons(self.PetBar, NUM_PET_ACTION_SLOTS, Settings["ab-pet-per-row"], Settings["ab-pet-button-size"], Settings["ab-pet-button-gap"])
	
	self:Hook("PetActionBar_Update")
	
	if Settings["ab-pet-enable"] then
		self.PetBar:Show()
	else
		self.PetBar:Hide()
	end
end

-- Stance
function AB:CreateStanceBar()
	self.StanceBar = CreateFrame("Frame", "HydraUI Stance Bar", HydraUI.UIParent, "SecureHandlerStateTemplate")
	self.StanceBar:SetPoint("TOPLEFT", HydraUI.UIParent, 10, -10)
	self.StanceBar:SetAlpha(Settings["ab-stance-alpha"] / 100)
	self.StanceBar.ButtonParent = StanceBarFrame
	self.StanceBar.ShouldFade = Settings["ab-stance-hover"]
	self.StanceBar.MaxAlpha = Settings["ab-stance-alpha"]
	
	self.StanceBar.Fader = CreateAnimationGroup(self.StanceBar):CreateAnimation("Fade")
	self.StanceBar.Fader:SetDuration(0.15)
	self.StanceBar.Fader:SetEasing("inout")
	
	if Settings["ab-stance-hover"] then
		self.StanceBar:SetAlpha(0)
		self.StanceBar:SetScript("OnEnter", BarOnEnter)
		self.StanceBar:SetScript("OnLeave", BarOnLeave)
	end
	
	StanceBarFrame:SetParent(self.StanceBar)
	
	if (StanceBarFrame and StanceBarFrame.StanceButtons) then
		for i = 1, NUM_STANCE_SLOTS do
			local Button = StanceBarFrame.StanceButtons[i]
			
			self:StyleActionButton(Button)
			
			Button.ParentBar = self.StanceBar
			
			Button:HookScript("OnEnter", BarButtonOnEnter)
			Button:HookScript("OnLeave", BarButtonOnLeave)
			
			self.StanceBar[i] = Button
		end
		
		self:PositionButtons(self.StanceBar, NUM_STANCE_SLOTS, Settings["ab-stance-per-row"], Settings["ab-stance-button-size"], Settings["ab-stance-button-gap"])
		
		self:Hook("StanceBar_UpdateState")
		
		if Settings["ab-stance-enable"] then
			self.StanceBar:Show()
		else
			self.StanceBar:Hide()
		end
	end
end

function AB:CreateBars()
	self:CreateBar1()
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreatePetBar()
	self:CreateStanceBar()
end

-- Black magic, the movers won't budge if a secure frame is positioned on it
local Bar1PreMove = function(self)
	local A1, P, A2, X, Y = self:GetPoint()
	
	AB.Bar1:Hide()
	AB.Bar1:ClearAllPoints() -- Clear the bar from the mover
	AB.Bar1:SetPoint(A1, HydraUI.UIParent, A2, X, Y)
end

local Bar1PostMove = function(self)
	local A1, P, A2, X, Y = self:GetPoint()
	
	self:ClearAllPoints()
	
	AB.Bar1:ClearAllPoints()
	AB.Bar1:SetPoint("CENTER", self, 0, 0) -- Position the frame to the mover again
	AB.Bar1:Show()
	
	self:SetPoint(A1, HydraUI.UIParent, A2, X, Y)
end

function AB:CreateMovers()
	self.Bar1Mover = HydraUI:CreateMover(self.Bar1)
	HydraUI:CreateMover(self.Bar2)
	HydraUI:CreateMover(self.Bar3)
	HydraUI:CreateMover(self.Bar4)
	HydraUI:CreateMover(self.Bar5)
	HydraUI:CreateMover(self.StanceBar)
	HydraUI:CreateMover(self.PetBar)
	
	self.Bar1Mover.PreMove = Bar1PreMove
	self.Bar1Mover.PostMove = Bar1PostMove
end

function AB:Load()
	if (not Settings["ab-enable"]) then
		return
	end
	
	self.Hide = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	self.Hide:Hide()
	
	SetActionBarToggles(1, 1, 1, 1, 1)
	
	self:Disable(MainMenuBar)
	self:CreateBars()
	self:CreateMovers()

	self:Hook("ActionButton_Update", "UpdateButtonStatus")
	self:Hook("ActionButton_OnUpdate", "UpdateButtonStatus")
	self:Hook("ActionButton_UpdateUsable", "UpdateButtonStatus")
end

local UpdateBar1 = function()
	AB:PositionButtons(AB.Bar1, Settings["ab-bar1-button-max"], Settings["ab-bar1-per-row"], Settings["ab-bar1-button-size"], Settings["ab-bar1-button-gap"])
end

local UpdateBar2 = function()
	AB:PositionButtons(AB.Bar2, Settings["ab-bar2-button-max"], Settings["ab-bar2-per-row"], Settings["ab-bar2-button-size"], Settings["ab-bar2-button-gap"])
end

local UpdateBar3 = function()
	AB:PositionButtons(AB.Bar3, Settings["ab-bar3-button-max"], Settings["ab-bar3-per-row"], Settings["ab-bar3-button-size"], Settings["ab-bar3-button-gap"])
end

local UpdateBar4 = function()
	AB:PositionButtons(AB.Bar4, Settings["ab-bar4-button-max"], Settings["ab-bar4-per-row"], Settings["ab-bar4-button-size"], Settings["ab-bar4-button-gap"])
end

local UpdateBar5 = function()
	AB:PositionButtons(AB.Bar5, Settings["ab-bar5-button-max"], Settings["ab-bar5-per-row"], Settings["ab-bar5-button-size"], Settings["ab-bar5-button-gap"])
end

local UpdatePetBar = function()
	AB:PositionButtons(AB.PetBar, NUM_PET_ACTION_SLOTS, Settings["ab-pet-per-row"], Settings["ab-pet-button-size"], Settings["ab-pet-button-gap"])
end

local UpdateStanceBar = function()
	AB:PositionButtons(AB.StanceBar, NUM_STANCE_SLOTS, Settings["ab-stance-per-row"], Settings["ab-stance-button-size"], Settings["ab-stance-button-gap"])
end

local UpdateEnableBar1 = function(value)
	if value then
		AB.Bar1:Show()
	else
		AB.Bar1:Hide()
	end
end

local UpdateEnableBar2 = function(value)
	if value then
		AB.Bar2:Show()
	else
		AB.Bar2:Hide()
	end
end

local UpdateEnableBar3 = function(value)
	if value then
		AB.Bar3:Show()
	else
		AB.Bar3:Hide()
	end
end

local UpdateEnableBar4 = function(value)
	if value then
		AB.Bar4:Show()
	else
		AB.Bar4:Hide()
	end
end

local UpdateEnableBar5 = function(value)
	if value then
		AB.Bar5:Show()
	else
		AB.Bar5:Hide()
	end
end

local UpdateEnablePetBar = function(value)
	if value then
		AB.PetBar:Show()
	else
		AB.PetBar:Hide()
	end
end

local UpdateEnableStanceBar = function(value)
	if value then
		AB.StanceBar:Show()
	else
		AB.StanceBar:Hide()
	end
end

local UpdateShowHotKey = function(value)
	if value then
		for i = 1, 12 do
			AB.Bar1[i].HotKey:SetAlpha(1)
			AB.Bar2[i].HotKey:SetAlpha(1)
			AB.Bar3[i].HotKey:SetAlpha(1)
			AB.Bar4[i].HotKey:SetAlpha(1)
			AB.Bar5[i].HotKey:SetAlpha(1)
			
			if AB.PetBar[i] then
				AB.PetBar[i].HotKey:SetAlpha(1)
			end
			
			if AB.StanceBar[i] then
				AB.StanceBar[i].HotKey:SetAlpha(1)
			end
		end
		
		ExtraActionButton1.HotKey:SetAlpha(1)
	else
		for i = 1, 12 do
			AB.Bar1[i].HotKey:SetAlpha(0)
			AB.Bar2[i].HotKey:SetAlpha(0)
			AB.Bar3[i].HotKey:SetAlpha(0)
			AB.Bar4[i].HotKey:SetAlpha(0)
			AB.Bar5[i].HotKey:SetAlpha(0)
			
			if AB.PetBar[i] then
				AB.PetBar[i].HotKey:SetAlpha(0)
			end
			
			if AB.StanceBar[i] then
				AB.StanceBar[i].HotKey:SetAlpha(0)
			end
		end
		
		ExtraActionButton1.HotKey:SetAlpha(0)
	end
end

local UpdateShowMacroName = function(value)
	if value then
		for i = 1, 12 do
			AB.Bar1[i].Name:SetAlpha(1)
			AB.Bar2[i].Name:SetAlpha(1)
			AB.Bar3[i].Name:SetAlpha(1)
			AB.Bar4[i].Name:SetAlpha(1)
			AB.Bar5[i].Name:SetAlpha(1)
		end
	else
		for i = 1, 12 do
			AB.Bar1[i].Name:SetAlpha(0)
			AB.Bar2[i].Name:SetAlpha(0)
			AB.Bar3[i].Name:SetAlpha(0)
			AB.Bar4[i].Name:SetAlpha(0)
			AB.Bar5[i].Name:SetAlpha(0)
		end
	end
end

local UpdateShowCount = function(value)
	if value then
		for i = 1, 12 do
			AB.Bar1[i].Count:SetAlpha(1)
			AB.Bar2[i].Count:SetAlpha(1)
			AB.Bar3[i].Count:SetAlpha(1)
			AB.Bar4[i].Count:SetAlpha(1)
			AB.Bar5[i].Count:SetAlpha(1)
		end
	else
		for i = 1, 12 do
			AB.Bar1[i].Count:SetAlpha(0)
			AB.Bar2[i].Count:SetAlpha(0)
			AB.Bar3[i].Count:SetAlpha(0)
			AB.Bar4[i].Count:SetAlpha(0)
			AB.Bar5[i].Count:SetAlpha(0)
		end
	end
end

function AB:UpdateButtonFont(button)
	if button.HotKey then
		HydraUI:SetFontInfo(button.HotKey, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
	end
	
	if button.Name then
		HydraUI:SetFontInfo(button.Name, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
	end
	
	if button.Count then
		HydraUI:SetFontInfo(button.Count, Settings["ab-font"], Settings["ab-font-size"], Settings["ab-font-flags"])
	end
	
	if button.cooldown then
		local Cooldown = button.cooldown:GetRegions()
		
		if Cooldown then
			HydraUI:SetFontInfo(Cooldown, Settings["ab-font"], Settings["ab-cd-size"], Settings["ab-font-flags"])
		end
	end
end

local UpdateActionBarFont = function()
	for i = 1, 12 do
		AB:UpdateButtonFont(AB.Bar1[i])
		AB:UpdateButtonFont(AB.Bar2[i])
		AB:UpdateButtonFont(AB.Bar3[i])
		AB:UpdateButtonFont(AB.Bar4[i])
		AB:UpdateButtonFont(AB.Bar5[i])
		
		if AB.PetBar[i] then
			AB:UpdateButtonFont(AB.PetBar[i])
		end
		
		if AB.StanceBar[i] then
			AB:UpdateButtonFont(AB.StanceBar[i])
		end
	end
end

local UpdateBar1Hover = function(value)
	AB.Bar1.ShouldFade = value

	if value then
		AB.Bar1:SetAlpha(0)
		AB.Bar1:SetScript("OnEnter", BarOnEnter)
		AB.Bar1:SetScript("OnLeave", BarOnLeave)
	else
		AB.Bar1:SetAlpha(1)
		AB.Bar1:SetScript("OnEnter", nil)
		AB.Bar1:SetScript("OnLeave", nil)
	end
end

local UpdateBar2Hover = function(value)
	AB.Bar2.ShouldFade = value

	if value then
		AB.Bar2:SetAlpha(0)
		AB.Bar2:SetScript("OnEnter", BarOnEnter)
		AB.Bar2:SetScript("OnLeave", BarOnLeave)
	else
		AB.Bar2:SetAlpha(1)
		AB.Bar2:SetScript("OnEnter", nil)
		AB.Bar2:SetScript("OnLeave", nil)
	end
end

local UpdateBar3Hover = function(value)
	AB.Bar3.ShouldFade = value

	if value then
		AB.Bar3:SetAlpha(0)
		AB.Bar3:SetScript("OnEnter", BarOnEnter)
		AB.Bar3:SetScript("OnLeave", BarOnLeave)
	else
		AB.Bar3:SetAlpha(1)
		AB.Bar3:SetScript("OnEnter", nil)
		AB.Bar3:SetScript("OnLeave", nil)
	end
end

local UpdateBar4Hover = function(value)
	AB.Bar4.ShouldFade = value

	if value then
		AB.Bar4:SetAlpha(0)
		AB.Bar4:SetScript("OnEnter", BarOnEnter)
		AB.Bar4:SetScript("OnLeave", BarOnLeave)
	else
		AB.Bar4:SetAlpha(1)
		AB.Bar4:SetScript("OnEnter", nil)
		AB.Bar4:SetScript("OnLeave", nil)
	end
end

local UpdateBar5Hover = function(value)
	AB.Bar5.ShouldFade = value

	if value then
		AB.Bar5:SetAlpha(0)
		AB.Bar5:SetScript("OnEnter", BarOnEnter)
		AB.Bar5:SetScript("OnLeave", BarOnLeave)
	else
		AB.Bar5:SetAlpha(1)
		AB.Bar5:SetScript("OnEnter", nil)
		AB.Bar5:SetScript("OnLeave", nil)
	end
end

local UpdatePetHover = function(value)
	AB.PetBar.ShouldFade = value

	if value then
		AB.PetBar:SetAlpha(0)
		AB.PetBar:SetScript("OnEnter", BarOnEnter)
		AB.PetBar:SetScript("OnLeave", BarOnLeave)
	else
		AB.PetBar:SetAlpha(1)
		AB.PetBar:SetScript("OnEnter", nil)
		AB.PetBar:SetScript("OnLeave", nil)
	end
end

local UpdateStanceHover = function(value)
	AB.StanceBar.ShouldFade = value

	if value then
		AB.StanceBar:SetAlpha(0)
		AB.StanceBar:SetScript("OnEnter", BarOnEnter)
		AB.StanceBar:SetScript("OnLeave", BarOnLeave)
	else
		AB.StanceBar:SetAlpha(1)
		AB.StanceBar:SetScript("OnEnter", nil)
		AB.StanceBar:SetScript("OnLeave", nil)
	end
end

local UpdateBar1Alpha = function(value)
	AB.Bar1.MaxAlpha = value
	AB.Bar1:SetAlpha(value / 100)
end

local UpdateBar2Alpha = function(value)
	AB.Bar2.MaxAlpha = value
	AB.Bar2:SetAlpha(value / 100)
end

local UpdateBar3Alpha = function(value)
	AB.Bar3.MaxAlpha = value
	AB.Bar3:SetAlpha(value / 100)
end

local UpdateBar4Alpha = function(value)
	AB.Bar4.MaxAlpha = value
	AB.Bar4:SetAlpha(value / 100)
end

local UpdateBar5Alpha = function(value)
	AB.Bar5.MaxAlpha = value
	AB.Bar5:SetAlpha(value / 100)
end

local UpdatePetBarAlpha = function(value)
	AB.PetBar.MaxAlpha = value
	AB.PetBar:SetAlpha(value / 100)
end

local UpdateStanceBarAlpha = function(value)
	AB.StanceBar.MaxAlpha = value
	AB.StanceBar:SetAlpha(value / 100)
end

GUI:AddWidgets(Language["General"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"], UpdateShowHotKey)
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"], UpdateShowMacroName)
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"], UpdateShowCount)
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], UpdateActionBarFont, "Font")
	left:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"], UpdateActionBarFont)
	left:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"], UpdateActionBarFont)
	left:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"], UpdateActionBarFont)
end)

GUI:AddWidgets(Language["General"], Language["Bar 1"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Action Bar 1"])
	left:CreateSwitch("ab-bar1-enable", Settings["ab-bar1-enable"], Language["Enable Bar"], Language["Enable action bar 1"], UpdateEnableBar1)
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateBar1Hover)
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar1)
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"], UpdateBar1)
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateBar1)
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateBar1)
	left:CreateSlider("ab-bar1-alpha", Settings["ab-bar1-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateBar1Alpha)
end)

GUI:AddWidgets(Language["General"], Language["Bar 2"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Action Bar 2"])
	left:CreateSwitch("ab-bar2-enable", Settings["ab-bar2-enable"], Language["Enable Bar"], Language["Enable action bar 2"], UpdateEnableBar2)
	left:CreateSwitch("ab-bar2-hover", Settings["ab-bar2-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateBar2Hover)
	left:CreateSlider("ab-bar2-per-row", Settings["ab-bar2-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar2)
	left:CreateSlider("ab-bar2-button-max", Settings["ab-bar2-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"], UpdateBar2)
	left:CreateSlider("ab-bar2-button-size", Settings["ab-bar2-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateBar2)
	left:CreateSlider("ab-bar2-button-gap", Settings["ab-bar2-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateBar2)
	left:CreateSlider("ab-bar2-alpha", Settings["ab-bar2-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateBar2Alpha)
end)

GUI:AddWidgets(Language["General"], Language["Bar 3"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Action Bar 3"])
	left:CreateSwitch("ab-bar3-enable", Settings["ab-bar3-enable"], Language["Enable Bar"], Language["Enable action bar 3"], UpdateEnableBar3)
	left:CreateSwitch("ab-bar3-hover", Settings["ab-bar3-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateBar3Hover)
	left:CreateSlider("ab-bar3-per-row", Settings["ab-bar3-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar3)
	left:CreateSlider("ab-bar3-button-max", Settings["ab-bar3-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"], UpdateBar3)
	left:CreateSlider("ab-bar3-button-size", Settings["ab-bar3-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateBar3)
	left:CreateSlider("ab-bar3-button-gap", Settings["ab-bar3-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateBar3)
	left:CreateSlider("ab-bar3-alpha", Settings["ab-bar3-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateBar3Alpha)
end)

GUI:AddWidgets(Language["General"], Language["Bar 4"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Action Bar 4"])
	left:CreateSwitch("ab-bar4-enable", Settings["ab-bar4-enable"], Language["Enable Bar"], Language["Enable action bar 4"], UpdateEnableBar4)
	left:CreateSwitch("ab-bar4-hover", Settings["ab-bar4-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateBar4Hover)
	left:CreateSlider("ab-bar4-per-row", Settings["ab-bar4-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar4)
	left:CreateSlider("ab-bar4-button-max", Settings["ab-bar4-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"], UpdateBar4)
	left:CreateSlider("ab-bar4-button-size", Settings["ab-bar4-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateBar4)
	left:CreateSlider("ab-bar4-button-gap", Settings["ab-bar4-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateBar4)
	left:CreateSlider("ab-bar4-alpha", Settings["ab-bar4-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateBar4Alpha)
end)

GUI:AddWidgets(Language["General"], Language["Bar 5"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Action Bar 5"])
	left:CreateSwitch("ab-bar5-enable", Settings["ab-bar5-enable"], Language["Enable Bar"], Language["Enable action bar 5"], UpdateEnableBar5)
	left:CreateSwitch("ab-bar5-hover", Settings["ab-bar5-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateBar5Hover)
	left:CreateSlider("ab-bar5-per-row", Settings["ab-bar5-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateBar5)
	left:CreateSlider("ab-bar5-button-max", Settings["ab-bar5-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"], UpdateBar5)
	left:CreateSlider("ab-bar5-button-size", Settings["ab-bar5-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateBar5)
	left:CreateSlider("ab-bar5-button-gap", Settings["ab-bar5-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateBar5)
	left:CreateSlider("ab-bar5-alpha", Settings["ab-bar5-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateBar5Alpha)
end)

GUI:AddWidgets(Language["General"], Language["Pet Bar"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Pet Bar"])
	left:CreateSwitch("ab-pet-enable", Settings["ab-pet-enable"], Language["Enable Bar"], Language["Enable the pet action bar"], UpdateEnablePetBar)
	left:CreateSwitch("ab-pet-hover", Settings["ab-pet-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdatePetHover)
	left:CreateSlider("ab-pet-per-row", Settings["ab-pet-per-row"], 1, NUM_PET_ACTION_SLOTS, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdatePetBar)
	left:CreateSlider("ab-pet-button-size", Settings["ab-pet-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdatePetBar)
	left:CreateSlider("ab-pet-button-gap", Settings["ab-pet-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdatePetBar)
	left:CreateSlider("ab-pet-alpha", Settings["ab-pet-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdatePetBarAlpha)
end)

GUI:AddWidgets(Language["General"], Language["Stance Bar"], Language["Action Bars"], function(left, right)
	left:CreateHeader(Language["Stance Bar"])
	left:CreateSwitch("ab-stance-enable", Settings["ab-stance-enable"], Language["Enable Bar"], Language["Enable the stance bar"], UpdateEnableStanceBar)
	left:CreateSwitch("ab-stance-hover", Settings["ab-stance-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"], UpdateStanceHover)
	left:CreateSlider("ab-stance-per-row", Settings["ab-stance-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"], UpdateStanceBar)
	left:CreateSlider("ab-stance-button-size", Settings["ab-stance-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"], UpdateStanceBar)
	left:CreateSlider("ab-stance-button-gap", Settings["ab-stance-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"], UpdateStanceBar)
	left:CreateSlider("ab-stance-alpha", Settings["ab-stance-alpha"], 0, 100, 5, Language["Bar Opacity"], Language["Set the opacity of the action bar"], UpdateStanceBarAlpha)
end)